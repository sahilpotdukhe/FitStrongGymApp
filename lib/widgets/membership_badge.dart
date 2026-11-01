import 'package:fitstrong_gym/src/custom_import.dart';

/// Where a membership stands right now.
enum MembershipState { active, expiringSoon, paymentDue, expired }

/// Works out a membership's state from its expiry date.
///
/// "Expiring soon" is new: previously a membership was only ever green or
/// red, so the day before it lapsed looked exactly like the day after it was
/// renewed — and renewals were only noticed once a member was already locked
/// out.
MembershipState membershipStateOf(MemberModel member, {int soonDays = 7}) {
  // The same shared rule the front desk scanner applies, so a member the
  // scanner still lets in never reads as flatly "Expired" in the office.
  switch (CheckinRules.accessOn(member.expiryDate, DateTime.now())) {
    case MembershipAccess.locked:
      return MembershipState.expired;
    case MembershipAccess.paymentDue:
      return MembershipState.paymentDue;
    case MembershipAccess.active:
      return daysUntilExpiry(member) <= soonDays
          ? MembershipState.expiringSoon
          : MembershipState.active;
  }
}

/// How many whole days until the membership lapses; negative once it has.
///
/// Counted between dates with the time of day thrown away, the same way the
/// reminders are worked out. Subtracting the two moments instead dropped the
/// part day on the floor: at six in the evening a membership four days off
/// came out as three, so the badge and the reminders list disagreed by a day
/// and the badge was always the pessimistic one.
int daysUntilExpiry(MemberModel member) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final expiry = DateTime(
    member.expiryDate.year,
    member.expiryDate.month,
    member.expiryDate.day,
  );
  return expiry.difference(today).inDays;
}

/// Coloured status chip used on member cards, the details page and the lists.
class MembershipBadge extends StatelessWidget {
  const MembershipBadge(
      {super.key, required this.member, this.compact = false});

  final MemberModel member;

  /// Drops the day count, for tight rows.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final status = context.status;
    final state = membershipStateOf(member);
    final daysLeft = daysUntilExpiry(member);

    final (Color fg, Color bg, String label) = switch (state) {
      MembershipState.active => (
          status.successForeground,
          status.successSurface,
          'Active',
        ),
      MembershipState.expiringSoon => (
          status.warningForeground,
          status.warningSurface,
          // A membership is past on its expiry date, so the last day a
          // member can actually train is the day before it: one day left
          // means today is that last day.
          compact
              ? 'Due soon'
              : daysLeft <= 0
                  ? 'Expires today'
                  : daysLeft == 1
                      ? 'Last day today'
                      : 'Expires in ${daysLeft}d',
        ),
      MembershipState.paymentDue => (
          status.warningForeground,
          status.warningSurface,
          // Amber, matching the scanner: this member is still let in. Red is
          // kept for the ones actually turned away at the door.
          compact
              ? 'Payment due'
              : 'Payment due · ${CheckinRules.graceDaysLeft(
                  member.expiryDate,
                  DateTime.now(),
                )}d left',
        ),
      MembershipState.expired => (
          status.dangerForeground,
          status.dangerSurface,
          'Expired',
        ),
    };

    return ShadcnBadge(
      style: ShadcnBadgeStyle(
        backgroundColor: bg,
        foregroundColor: fg,
        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
      child: Text(label),
    );
  }
}
