import 'package:flutter_test/flutter_test.dart';
import 'package:fitstrong_gym/Models/MemberModel.dart';

void main() {
  group('MemberModel.addMonths', () {
    test('keeps the same day of the month when that day exists', () {
      expect(
        MemberModel.addMonths(DateTime(2026, 1, 15), 1),
        DateTime(2026, 2, 15),
      );
      expect(
        MemberModel.addMonths(DateTime(2026, 3, 10), 6),
        DateTime(2026, 9, 10),
      );
    });

    test('clamps to the last day when the target month is shorter', () {
      // The old arithmetic rolled this into 3 March and gave away two days.
      expect(
        MemberModel.addMonths(DateTime(2026, 1, 31), 1),
        DateTime(2026, 2, 28),
      );
      expect(
        MemberModel.addMonths(DateTime(2026, 5, 31), 1),
        DateTime(2026, 6, 30),
      );
    });

    test('handles February in a leap year', () {
      expect(
        MemberModel.addMonths(DateTime(2028, 1, 31), 1),
        DateTime(2028, 2, 29),
      );
    });

    test('rolls over the year boundary', () {
      expect(
        MemberModel.addMonths(DateTime(2026, 11, 20), 3),
        DateTime(2027, 2, 20),
      );
      expect(
        MemberModel.addMonths(DateTime(2026, 12, 31), 12),
        DateTime(2027, 12, 31),
      );
    });

    test('returns the same date when no months are added', () {
      expect(
        MemberModel.addMonths(DateTime(2026, 7, 4), 0),
        DateTime(2026, 7, 4),
      );
    });
  });
}
