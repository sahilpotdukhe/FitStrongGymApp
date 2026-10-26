import 'package:fitstrong_core/fitstrong_core.dart';
import 'package:fitstrong_gym/resources/attendance_insights.dart';
import 'package:flutter_test/flutter_test.dart';

Attendance visit(
  DateTime at, {
  String memberId = 'm1',
  String name = 'Asha',
}) {
  return Attendance(
    id: '$memberId-${at.toIso8601String()}',
    memberId: memberId,
    memberName: name,
    at: at,
    source: AttendanceSource.scanner,
  );
}

void main() {
  group('an empty history', () {
    final insights = AttendanceInsights.from(const []);

    test('says so rather than showing zeros as findings', () {
      expect(insights.isEmpty, isTrue);
      expect(insights.totalVisits, 0);
      expect(insights.distinctMembers, 0);
      expect(insights.daysOpen, 0);
    });

    test('has no peak to report', () {
      // Nothing is the busiest hour when nobody has ever come in. Showing
      // "12 AM" because that bucket sorts first would be a made up answer.
      expect(insights.busiestHour, isNull);
      expect(insights.busiestWeekday, isNull);
      expect(insights.busiestHourLabel, '—');
      expect(insights.busiestWeekdayLabel, '—');
    });

    test('does not divide by zero', () {
      expect(insights.averagePerOpenDay, 0);
      expect(insights.bestDay, 0);
    });
  });

  group('counting arrivals', () {
    // Monday 9 March 2026 is a Monday; the dates below are chosen so the
    // weekday maths is checkable by hand.
    final insights = AttendanceInsights.from([
      visit(DateTime(2026, 3, 9, 18, 10), memberId: 'm1', name: 'Asha'),
      visit(DateTime(2026, 3, 9, 18, 40), memberId: 'm2', name: 'Bilal'),
      visit(DateTime(2026, 3, 9, 7, 5), memberId: 'm3', name: 'Chen'),
      visit(DateTime(2026, 3, 10, 18, 20), memberId: 'm1', name: 'Asha'),
      visit(DateTime(2026, 3, 11, 6, 30), memberId: 'm1', name: 'Asha'),
    ]);

    test('totals every arrival', () {
      expect(insights.totalVisits, 5);
    });

    test('counts each person once however often they came', () {
      expect(insights.distinctMembers, 3);
    });

    test('counts the days the gym actually saw somebody', () {
      expect(insights.daysOpen, 3);
    });

    test('averages over open days, not the calendar', () {
      expect(insights.averagePerOpenDay, closeTo(5 / 3, 0.001));
    });

    test('reports the busiest single day', () {
      expect(insights.bestDay, 3);
    });
  });

  group('peak hours', () {
    test('finds the hour most people arrive in', () {
      final insights = AttendanceInsights.from([
        visit(DateTime(2026, 3, 9, 18, 10), memberId: 'm1'),
        visit(DateTime(2026, 3, 9, 18, 55), memberId: 'm2'),
        visit(DateTime(2026, 3, 10, 7, 0), memberId: 'm3'),
      ]);

      expect(insights.busiestHour, 18);
      expect(insights.busiestHourLabel, '6 PM – 7 PM');
    });

    test('buckets by the hour the arrival started, not by rounding', () {
      // 6:55 PM is a 6 PM arrival, not a 7 PM one.
      final insights = AttendanceInsights.from([
        visit(DateTime(2026, 3, 9, 18, 55)),
      ]);
      expect(insights.hourCounts[18], 1);
      expect(insights.hourCounts[19], 0);
    });

    test('a late night hour rolls round to midnight in the label', () {
      final insights = AttendanceInsights.from([
        visit(DateTime(2026, 3, 9, 23, 10)),
      ]);
      expect(insights.busiestHourLabel, '11 PM – 12 AM');
    });

    test('an early hour reads as AM', () {
      final insights = AttendanceInsights.from([
        visit(DateTime(2026, 3, 9, 6, 10)),
      ]);
      expect(insights.busiestHourLabel, '6 AM – 7 AM');
    });
  });

  group('busiest day of the week', () {
    test('counts Monday first and names it correctly', () {
      // 9 and 16 March 2026 are both Mondays.
      final insights = AttendanceInsights.from([
        visit(DateTime(2026, 3, 9, 18), memberId: 'm1'),
        visit(DateTime(2026, 3, 16, 18), memberId: 'm2'),
        visit(DateTime(2026, 3, 14, 10), memberId: 'm3'),
      ]);

      expect(insights.weekdayCounts[0], 2);
      expect(insights.busiestWeekday, 0);
      expect(insights.busiestWeekdayLabel, 'Monday');
    });

    test('a Sunday lands in the last bucket, not the first', () {
      // 15 March 2026 is a Sunday. Getting this wrong would quietly report
      // the wrong day to the owner forever.
      final insights =
          AttendanceInsights.from([visit(DateTime(2026, 3, 15, 10))]);
      expect(insights.weekdayCounts[6], 1);
      expect(insights.busiestWeekdayLabel, 'Sunday');
    });
  });

  group('the recent trend', () {
    final insights = AttendanceInsights.from([
      visit(DateTime(2026, 3, 11, 18), memberId: 'm1'),
      visit(DateTime(2026, 3, 11, 19), memberId: 'm2'),
      visit(DateTime(2026, 3, 9, 7), memberId: 'm3'),
    ]);

    test('returns exactly the days asked for, ending today', () {
      final days = insights.recentDays(5, today: DateTime(2026, 3, 11, 22));
      expect(days.length, 5);
      expect(days.first.day, DateTime(2026, 3, 7));
      expect(days.last.day, DateTime(2026, 3, 11));
    });

    test('shows the days nobody came as zero rather than skipping them', () {
      // A gap is part of the picture; closing it up would make a quiet week
      // look like a busy one.
      final days = insights.recentDays(5, today: DateTime(2026, 3, 11));
      expect(days.map((d) => d.visits).toList(), [0, 0, 1, 0, 2]);
    });

    test('ignores the time of day when deciding which day is today', () {
      final late = insights.recentDays(1, today: DateTime(2026, 3, 11, 23, 59));
      expect(late.single.visits, 2);
    });
  });

  group('the regulars', () {
    final insights = AttendanceInsights.from([
      visit(DateTime(2026, 3, 9, 18), memberId: 'm1', name: 'Asha'),
      visit(DateTime(2026, 3, 10, 18), memberId: 'm1', name: 'Asha'),
      visit(DateTime(2026, 3, 11, 18), memberId: 'm1', name: 'Asha'),
      visit(DateTime(2026, 3, 9, 7), memberId: 'm2', name: 'Bilal'),
      visit(DateTime(2026, 3, 10, 7), memberId: 'm2', name: 'Bilal'),
      visit(DateTime(2026, 3, 9, 8), memberId: 'm3', name: 'Chen'),
    ]);

    test('leads with whoever comes most often', () {
      final top = insights.topMembers(3);
      expect(top.map((m) => m.memberName).toList(), ['Asha', 'Bilal', 'Chen']);
      expect(top.first.visits, 3);
    });

    test('remembers when each of them was last in', () {
      expect(insights.topMembers(1).single.lastVisit,
          DateTime(2026, 3, 11, 18));
    });

    test('asking for more than there are does not break', () {
      expect(insights.topMembers(50).length, 3);
    });

    test('a tie goes to whoever came most recently', () {
      final tied = AttendanceInsights.from([
        visit(DateTime(2026, 3, 1, 18), memberId: 'old', name: 'Old'),
        visit(DateTime(2026, 3, 11, 18), memberId: 'new', name: 'New'),
      ]);
      expect(tied.topMembers(2).first.memberName, 'New');
    });

    test('a renamed member keeps one row, under their current name', () {
      // History is keyed on the member id, so a name change must not split
      // somebody into two people.
      final renamed = AttendanceInsights.from([
        visit(DateTime(2026, 3, 9, 18), memberId: 'm1', name: 'Asha'),
        visit(DateTime(2026, 3, 10, 18), memberId: 'm1', name: 'Asha Khan'),
      ]);
      expect(renamed.distinctMembers, 1);
      expect(renamed.topMembers(1).single.visits, 2);
    });
  });
}
