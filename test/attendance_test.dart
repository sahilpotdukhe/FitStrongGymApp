import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitstrong_gym/models/attendance_model.dart';
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

Map<String, dynamic> _record({Map<String, dynamic> changes = const {}}) {
  return <String, dynamic>{
    'memberId': 'm1',
    'memberName': 'Asha',
    'at': Timestamp.fromDate(DateTime(2026, 3, 9, 7, 5)),
    'type': 'in',
    'source': 'scanner',
    ...changes,
  };
}

void main() {
  group('reading a scan back', () {
    test('reads every field', () {
      final scan = Attendance.fromDoc('a1', _record());
      expect(scan!.memberId, 'm1');
      expect(scan.memberName, 'Asha');
      expect(scan.type, CheckinType.checkIn);
      expect(scan.at, DateTime(2026, 3, 9, 7, 5));
    });

    test('a record still waiting for its server time is skipped', () {
      // A write reaches the local cache before the server has stamped it.
      // Showing it would mean inventing a time that nothing agrees with.
      expect(Attendance.fromDoc('a1', _record(changes: {'at': null})), isNull);
      expect(Attendance.fromDoc('a1', null), isNull);
    });

    test('an unreadable direction falls back to an arrival', () {
      final scan = Attendance.fromDoc('a1', _record(changes: {'type': null}));
      expect(scan!.type, CheckinType.checkIn);
    });

    test('a missing name does not drop the record', () {
      // The time is the part that must be right. A blank name is survivable.
      final scan =
          Attendance.fromDoc('a1', _record(changes: {'memberName': null}));
      expect(scan, isNotNull);
      expect(scan!.memberName, '');
    });
  });

  group('labels derived from the one timestamp', () {
    final scan = _scan(at: DateTime(2026, 3, 9, 7, 5));

    test('the day, the month and the clock all come from the same moment', () {
      expect(scan.dateKey, '2026-03-09');
      expect(scan.monthLabel, 'March 2026');
      expect(scan.timeLabel, '7:05 AM');
    });

    test('an evening scan reads as PM', () {
      expect(_scan(at: DateTime(2026, 3, 9, 19, 5)).timeLabel, '7:05 PM');
    });

    test('midnight and noon are not confused with each other', () {
      expect(_scan(at: DateTime(2026, 3, 9, 0, 30)).timeLabel, '12:30 AM');
      expect(_scan(at: DateTime(2026, 3, 9, 12, 30)).timeLabel, '12:30 PM');
    });
  });

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
