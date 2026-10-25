import 'package:fitstrong_core/fitstrong_core.dart';
import 'package:fitstrong_gym/resources/attendance_insights.dart';
import 'package:flutter_test/flutter_test.dart';

/// Belongs with the offline queue: it relies on [Attendance.pendingSync],
/// which only exists once the shared package carries a device clock.
void main() {
  group('records still waiting to sync', () {
    test('are counted like any other arrival', () {
      // The member was let in and the scanner wrote it down. Leaving it out
      // of the figures until the Wi-Fi returns would understate the day.
      final queued = Attendance(
        id: 'q1',
        memberId: 'm9',
        memberName: 'Dev',
        at: DateTime(2026, 3, 11, 18, 30),
        source: AttendanceSource.scanner,
        pendingSync: true,
      );

      final insights = AttendanceInsights.from([queued]);
      expect(insights.totalVisits, 1);
      expect(insights.hourCounts[18], 1);
    });
  });
}
