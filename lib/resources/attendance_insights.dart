import 'package:fitstrong_core/fitstrong_core.dart';
import 'package:intl/intl.dart';

/// One member and how often they have come in.
class MemberVisits {
  const MemberVisits({
    required this.memberId,
    required this.memberName,
    required this.visits,
    required this.lastVisit,
  });

  final String memberId;
  final String memberName;
  final int visits;
  final DateTime lastVisit;

  String get lastVisitLabel => DateFormat('d MMM').format(lastVisit);
}

/// One day and its head count, including days nobody came.
class DailyCount {
  const DailyCount({required this.day, required this.visits});

  final DateTime day;
  final int visits;

  /// The single letter under a bar on the trend chart.
  String get initial => DateFormat('E').format(day).substring(0, 1);

  String get label => DateFormat('d MMM').format(day);
}

/// What the attendance history says about how the gym is actually used.
///
/// Every number here is counted from arrivals, because arrivals are all that
/// is recorded. How long anyone stayed is deliberately absent: the desk does
/// not scan people out, so a visit has a start and no end, and any "average
/// session length" would be invented rather than measured.
class AttendanceInsights {
  AttendanceInsights._({
    required this.totalVisits,
    required this.distinctMembers,
    required this.hourCounts,
    required this.weekdayCounts,
    required Map<String, int> perDay,
    required List<MemberVisits> regulars,
  })  : _perDay = perDay,
        _regulars = regulars;

  /// Builds the whole summary in one pass over the history.
  factory AttendanceInsights.from(List<Attendance> records) {
    final hours = List<int>.filled(24, 0);
    // Monday first, matching how a week is read on a wall planner.
    final weekdays = List<int>.filled(7, 0);
    final perDay = <String, int>{};
    final members = <String, _MemberTally>{};

    for (final record in records) {
      final at = record.at;
      hours[at.hour]++;
      weekdays[at.weekday - 1]++;
      perDay[record.dateKey] = (perDay[record.dateKey] ?? 0) + 1;

      final tally = members.putIfAbsent(
        record.memberId,
        () => _MemberTally(record.memberName, at),
      );
      tally.visits++;
      tally.name = record.memberName.isNotEmpty ? record.memberName : tally.name;
      if (at.isAfter(tally.lastVisit)) tally.lastVisit = at;
    }

    final regulars = members.entries
        .map((e) => MemberVisits(
              memberId: e.key,
              memberName: e.value.name,
              visits: e.value.visits,
              lastVisit: e.value.lastVisit,
            ))
        .toList()
      // Most visits first; a tie goes to whoever was here most recently, so
      // the list leads with members who are still coming.
      ..sort((a, b) {
        final byVisits = b.visits.compareTo(a.visits);
        return byVisits != 0 ? byVisits : b.lastVisit.compareTo(a.lastVisit);
      });

    return AttendanceInsights._(
      totalVisits: records.length,
      distinctMembers: members.length,
      hourCounts: List.unmodifiable(hours),
      weekdayCounts: List.unmodifiable(weekdays),
      perDay: perDay,
      regulars: List.unmodifiable(regulars),
    );
  }

  /// Total arrivals. One member can only be recorded once a day, so this is
  /// also the number of member-visits.
  final int totalVisits;

  /// How many different people have ever been in.
  final int distinctMembers;

  /// Arrivals per hour of the day, from midnight (index 0) to 11 PM.
  final List<int> hourCounts;

  /// Arrivals per day of the week, Monday (index 0) to Sunday.
  final List<int> weekdayCounts;

  final Map<String, int> _perDay;
  final List<MemberVisits> _regulars;

  bool get isEmpty => totalVisits == 0;

  /// Days on which at least one person came in.
  ///
  /// Averages use this rather than every date on the calendar, so the days
  /// the gym was shut do not quietly drag the figure down.
  int get daysOpen => _perDay.length;

  /// Average arrivals on a day the gym actually saw someone.
  double get averagePerOpenDay =>
      daysOpen == 0 ? 0 : totalVisits / daysOpen;

  /// The hour the gym is busiest, or null when nothing is recorded yet.
  int? get busiestHour => _peak(hourCounts);

  /// The day of the week the gym is busiest, Monday being 0.
  int? get busiestWeekday => _peak(weekdayCounts);

  /// Reads as "6 PM – 7 PM": the hour people arrive in, not a single instant.
  String get busiestHourLabel {
    final hour = busiestHour;
    if (hour == null) return '—';
    return '${_hourLabel(hour)} – ${_hourLabel((hour + 1) % 24)}';
  }

  String get busiestWeekdayLabel {
    final day = busiestWeekday;
    if (day == null) return '—';
    // Any Monday will do; only the weekday name is wanted.
    return DateFormat('EEEE').format(DateTime(2024, 1, 1).add(Duration(days: day)));
  }

  /// The busiest single day on record, as a head count.
  int get bestDay =>
      _perDay.isEmpty ? 0 : _perDay.values.reduce((a, b) => a > b ? a : b);

  /// The last [days] calendar days ending on [today], including the days
  /// nobody came — a gap is part of the trend and should be visible.
  List<DailyCount> recentDays(int days, {DateTime? today}) {
    final end = _startOfDay(today ?? DateTime.now());
    return List.generate(days, (i) {
      final day = end.subtract(Duration(days: days - 1 - i));
      final key = DateFormat('yyyy-MM-dd').format(day);
      return DailyCount(day: day, visits: _perDay[key] ?? 0);
    });
  }

  /// The members who come most often, most frequent first.
  List<MemberVisits> topMembers(int limit) =>
      _regulars.take(limit).toList(growable: false);

  /// The index of the largest count, or null when every bucket is empty.
  static int? _peak(List<int> counts) {
    var best = -1;
    var bestAt = -1;
    for (var i = 0; i < counts.length; i++) {
      if (counts[i] > best) {
        best = counts[i];
        bestAt = i;
      }
    }
    return best <= 0 ? null : bestAt;
  }

  static String _hourLabel(int hour) =>
      DateFormat('h a').format(DateTime(2024, 1, 1, hour));

  static DateTime _startOfDay(DateTime value) =>
      DateTime(value.year, value.month, value.day);
}

/// Running totals while the history is walked once.
class _MemberTally {
  _MemberTally(this.name, this.lastVisit);

  String name;
  int visits = 0;
  DateTime lastVisit;
}
