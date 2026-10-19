import 'package:fitstrong_gym/models/member_model.dart';

/// Why a member is on the reminders list.
enum ReminderKind {
  /// Their birthday is today.
  birthdayToday,

  /// Their birthday falls within the next few days.
  birthdaySoon,

  /// Their membership runs out within the next few days.
  expiringSoon,

  /// Their membership has just run out and they have not renewed.
  expiredRecently,
}

/// One member, and the reason to get in touch with them today.
class MemberReminder {
  const MemberReminder({
    required this.member,
    required this.kind,
    required this.daysAway,
  });

  final MemberModel member;
  final ReminderKind kind;

  /// Days from today: 0 is today, 2 is the day after tomorrow, and a
  /// negative number means it already happened that many days ago.
  final int daysAway;

  /// "Today", "Tomorrow", "In 3 days", "2 days ago" — the same phrasing the
  /// owner would use out loud.
  String get whenLabel {
    if (daysAway == 0) return 'Today';
    if (daysAway == 1) return 'Tomorrow';
    if (daysAway == -1) return 'Yesterday';
    if (daysAway > 1) return 'In $daysAway days';
    return '${-daysAway} days ago';
  }
}

/// Everything worth a nudge today, grouped so the screen can show it in the
/// order it matters.
class ReminderDigest {
  const ReminderDigest({
    required this.birthdays,
    required this.expiring,
    required this.expired,
  });

  const ReminderDigest.empty()
      : birthdays = const [],
        expiring = const [],
        expired = const [];

  /// Birthdays today first, then the ones coming up.
  final List<MemberReminder> birthdays;

  /// Memberships about to run out, soonest first.
  final List<MemberReminder> expiring;

  /// Memberships that ran out in the last few days and were not renewed.
  final List<MemberReminder> expired;

  List<MemberReminder> get all => [...birthdays, ...expiring, ...expired];

  int get count => birthdays.length + expiring.length + expired.length;

  bool get isEmpty => count == 0;

  /// The one line the morning notification shows: "2 memberships expiring,
  /// 1 birthday today". Empty when there is nothing to say.
  String get headline {
    final parts = <String>[];

    final today = birthdays.where((r) => r.daysAway == 0).length;
    if (today > 0) {
      parts.add(today == 1 ? '1 birthday today' : '$today birthdays today');
    }
    if (expiring.isNotEmpty) {
      parts.add(expiring.length == 1
          ? '1 membership expiring soon'
          : '${expiring.length} memberships expiring soon');
    }
    if (expired.isNotEmpty) {
      parts.add(expired.length == 1
          ? '1 membership just expired'
          : '${expired.length} memberships just expired');
    }
    // Birthdays later in the week are worth listing on the screen but not
    // worth waking the owner's phone for on their own.
    if (parts.isEmpty && birthdays.isNotEmpty) {
      parts.add(birthdays.length == 1
          ? '1 birthday coming up'
          : '${birthdays.length} birthdays coming up');
    }
    return parts.join(' · ');
  }
}

/// Works out who to contact today, from the member list the app already has.
///
/// Deliberately plain Dart with no Firebase or plugin behind it: the same
/// calculation runs on screen and behind the morning notification, and it
/// can be tested without a phone.
class ReminderService {
  const ReminderService._();

  /// How many days ahead a membership counts as "expiring soon". Two days'
  /// warning was the ask; three gives a day of slack for a phone that was
  /// off or an owner who was busy.
  static const int defaultExpiryWindowDays = 3;

  /// How long a lapsed membership stays on the list before it becomes a
  /// job for the expired-members screen rather than a daily nudge.
  static const int defaultExpiredWindowDays = 7;

  /// Birthdays are visible a week ahead so a card or a small gift can be
  /// organised, with today's shown first.
  static const int defaultBirthdayWindowDays = 7;

  static ReminderDigest build(
    List<MemberModel> members, {
    DateTime? now,
    int expiryWindowDays = defaultExpiryWindowDays,
    int expiredWindowDays = defaultExpiredWindowDays,
    int birthdayWindowDays = defaultBirthdayWindowDays,
  }) {
    final today = _dateOnly(now ?? DateTime.now());

    final birthdays = <MemberReminder>[];
    final expiring = <MemberReminder>[];
    final expired = <MemberReminder>[];

    for (final member in members) {
      final daysToBirthday = daysUntilBirthday(member.dateOfBirth, today);
      if (daysToBirthday <= birthdayWindowDays) {
        birthdays.add(MemberReminder(
          member: member,
          kind: daysToBirthday == 0
              ? ReminderKind.birthdayToday
              : ReminderKind.birthdaySoon,
          daysAway: daysToBirthday,
        ));
      }

      final daysToExpiry =
          _dateOnly(member.expiryDate).difference(today).inDays;
      if (daysToExpiry >= 0 && daysToExpiry <= expiryWindowDays) {
        expiring.add(MemberReminder(
          member: member,
          kind: ReminderKind.expiringSoon,
          daysAway: daysToExpiry,
        ));
      } else if (daysToExpiry < 0 && daysToExpiry >= -expiredWindowDays) {
        expired.add(MemberReminder(
          member: member,
          kind: ReminderKind.expiredRecently,
          daysAway: daysToExpiry,
        ));
      }
    }

    birthdays.sort((a, b) => a.daysAway.compareTo(b.daysAway));
    expiring.sort((a, b) => a.daysAway.compareTo(b.daysAway));
    // Most recently lapsed first: they are the easiest to win back.
    expired.sort((a, b) => b.daysAway.compareTo(a.daysAway));

    return ReminderDigest(
      birthdays: birthdays,
      expiring: expiring,
      expired: expired,
    );
  }

  /// Days until the next time this birthday comes round, counting today as
  /// 0. Someone born on 29 February is wished on 28 February in years that
  /// have no 29th, rather than being skipped for three years running.
  static int daysUntilBirthday(DateTime dateOfBirth, DateTime today) {
    final thisYear = _birthdayInYear(dateOfBirth, today.year);
    if (!thisYear.isBefore(today)) return thisYear.difference(today).inDays;
    final nextYear = _birthdayInYear(dateOfBirth, today.year + 1);
    return nextYear.difference(today).inDays;
  }

  static DateTime _birthdayInYear(DateTime dateOfBirth, int year) {
    final lastDayOfMonth = DateTime(year, dateOfBirth.month + 1, 0).day;
    final day =
        dateOfBirth.day <= lastDayOfMonth ? dateOfBirth.day : lastDayOfMonth;
    return DateTime(year, dateOfBirth.month, day);
  }

  static DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);
}

/// The ready-written WhatsApp messages. Kept here so the wording is in one
/// place and reads the same whoever sends it.
class ReminderMessages {
  const ReminderMessages._();

  static String birthday(MemberReminder reminder, String gymName) {
    final from = gymName.trim().isEmpty ? '' : ' — $gymName';
    return 'Happy birthday, ${reminder.member.name}! 🎉 '
        'Wishing you a great year ahead and stronger lifts than ever$from.';
  }

  static String expiring(MemberReminder reminder, String gymName) {
    final from = gymName.trim().isEmpty ? 'us' : gymName.trim();
    final when = reminder.daysAway == 0
        ? 'today'
        : reminder.daysAway == 1
            ? 'tomorrow'
            : 'in ${reminder.daysAway} days';
    return 'Hi ${reminder.member.name}, a quick reminder from $from — '
        'your gym membership expires $when. '
        'Drop by the counter to renew and keep your streak going!';
  }

  static String expired(MemberReminder reminder, String gymName) {
    final from = gymName.trim().isEmpty ? 'us' : gymName.trim();
    final when = reminder.daysAway == -1
        ? 'yesterday'
        : '${-reminder.daysAway} days ago';
    return 'Hi ${reminder.member.name}, your gym membership at $from ended '
        '$when. We would love to have you back — renew any time and pick up '
        'right where you left off.';
  }

  static String forReminder(MemberReminder reminder, String gymName) {
    switch (reminder.kind) {
      case ReminderKind.birthdayToday:
      case ReminderKind.birthdaySoon:
        return birthday(reminder, gymName);
      case ReminderKind.expiringSoon:
        return expiring(reminder, gymName);
      case ReminderKind.expiredRecently:
        return expired(reminder, gymName);
    }
  }
}
