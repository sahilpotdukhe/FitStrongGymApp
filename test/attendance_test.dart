import 'package:fitstrong_core/fitstrong_core.dart';
import 'package:fitstrong_gym/provider/attendance_provider.dart';
import 'package:flutter_test/flutter_test.dart';

Attendance _scan({
  required DateTime at,
  CheckinType type = CheckinType.checkIn,
  String memberId = 'm1',
}) {
  return Attendance(
    id: 'a1',
    memberId: memberId,
    memberName: 'Asha',
    at: at,
    type: type,
    source: AttendanceSource.scanner,
  );
}

void main() {
  group('which direction the next scan is', () {
    test('a member who has not been in today is arriving', () {
      expect(AttendanceProvider.nextType(null), CheckinType.checkIn);
    });

    test('a member who is already in is leaving', () {
      final last = _scan(at: DateTime(2026, 3, 9, 7, 5));
      expect(AttendanceProvider.nextType(last), CheckinType.checkOut);
    });

    test('a member who has left is arriving again', () {
      final last =
          _scan(at: DateTime(2026, 3, 9, 9, 0), type: CheckinType.checkOut);
      expect(AttendanceProvider.nextType(last), CheckinType.checkIn);
    });
  });

  group('the camera reading the same code twice', () {
    final at = DateTime(2026, 3, 9, 7, 5);

    test('a second read moments later is ignored', () {
      // Without this the next frame would check the member straight back out
      // and they would walk in already marked gone.
      expect(
        AttendanceProvider.isRepeatScan(
            _scan(at: at), at.add(const Duration(seconds: 2))),
        isTrue,
      );
    });

    test('a genuine scan later in the day counts', () {
      expect(
        AttendanceProvider.isRepeatScan(
            _scan(at: at), at.add(const Duration(hours: 2))),
        isFalse,
      );
    });

    test('the very first scan of the day is never a repeat', () {
      expect(AttendanceProvider.isRepeatScan(null, at), isFalse);
    });

    test('a clock that drifted backwards still suppresses the repeat', () {
      // The difference is taken either way round, so a moment that lands
      // just before the last one does not slip through as a real scan.
      expect(
        AttendanceProvider.isRepeatScan(
            _scan(at: at), at.subtract(const Duration(seconds: 2))),
        isTrue,
      );
    });
  });
}
