import 'package:fitstrong_gym/models/gym_plan_model.dart';
import 'package:fitstrong_gym/models/member_model.dart';
import 'package:fitstrong_gym/models/trainer_model.dart';
import 'package:fitstrong_gym/resources/member_csv_export.dart';
import 'package:flutter_test/flutter_test.dart';

MemberModel member({
  String name = 'Asha Patil',
  String mobileNumber = '9876543210',
  String address = 'Pune',
  String gender = 'Female',
  double height = 165,
  double weight = 58.5,
  String planId = 'plan-1',
  String trainerId = 'trainer-1',
  DateTime? expiryDate,
  String checkInTime = '06:00',
  String checkOutTime = '07:30',
}) {
  return MemberModel(
    id: 'm1',
    name: name,
    mobileNumber: mobileNumber,
    dateOfBirth: DateTime(1995, 4, 12),
    height: height,
    weight: weight,
    photoUrl: '',
    planId: planId,
    dateOfAdmission: DateTime(2025, 1, 10),
    renewalDate: DateTime(2026, 1, 10),
    expiryDate: expiryDate ?? DateTime(2026, 1, 10),
    address: address,
    gender: gender,
    checkInTime: checkInTime,
    checkOutTime: checkOutTime,
    trainerId: trainerId,
  );
}

GymPlanModel plan({String id = 'plan-1', String name = 'Quarterly'}) {
  return GymPlanModel(
    id: id,
    name: name,
    months: 3,
    days: 0,
    fee: 3000,
  );
}

TrainerModel trainer({String id = 'trainer-1', String name = 'Ravi Kumar'}) {
  return TrainerModel(
    id: id,
    name: name,
    mobileNumber: '9000000000',
    gender: 'Male',
    specialization: 'Strength',
    experienceYears: 5,
    photoUrl: '',
    joiningDate: DateTime(2024, 1, 1),
    shiftStart: '06:00',
    shiftEnd: '11:00',
    workingDays: const ['Mon'],
    salary: 20000,
    address: 'Pune',
    isActive: true,
  );
}

/// The file split back into rows, so a test can look at one at a time.
List<String> rowsOf(String csv) => csv.split('\r\n');

void main() {
  group('MemberCsvExport.build', () {
    test('starts with a heading row naming every column', () {
      final csv = MemberCsvExport.build(
        members: [member()],
        plans: [plan()],
        trainers: [trainer()],
      );

      expect(rowsOf(csv).first, MemberCsvExport.columns.join(','));
    });

    test('writes one row per member with the names the owner knows', () {
      final csv = MemberCsvExport.build(
        members: [member()],
        plans: [plan()],
        trainers: [trainer()],
        asOf: DateTime(2025, 6, 1),
      );
      final row = rowsOf(csv)[1].split(',');

      expect(row[0], 'Asha Patil');
      expect(row[1], '9876543210');
      // The plan and the trainer are stored as ids; the file shows the names.
      expect(row[7], 'Quarterly');
      expect(row[8], 'Ravi Kumar');
    });

    test('dates go out in the order every spreadsheet reads the same way', () {
      final csv = MemberCsvExport.build(
        members: [member()],
        plans: [plan()],
        trainers: [trainer()],
      );
      final row = rowsOf(csv)[1].split(',');

      expect(row[3], '1995-04-12'); // date of birth
      expect(row[9], '2025-01-10'); // joined on
      expect(row[11], '2026-01-10'); // expiry
    });

    test('says whether the membership is live as of the export date', () {
      String statusOn(DateTime asOf) {
        final csv = MemberCsvExport.build(
          members: [member(expiryDate: DateTime(2026, 1, 10))],
          plans: [plan()],
          trainers: [trainer()],
          asOf: asOf,
        );
        return rowsOf(csv)[1].split(',')[12];
      }

      expect(statusOn(DateTime(2025, 6, 1)), 'Active');
      expect(statusOn(DateTime(2026, 6, 1)), 'Expired');
    });

    test('writes times out the way people read them', () {
      final csv = MemberCsvExport.build(
        members: [member(checkInTime: '06:00', checkOutTime: '19:30')],
        plans: [plan()],
        trainers: [trainer()],
      );
      final row = rowsOf(csv)[1].split(',');

      expect(row[13], '6:00 AM');
      expect(row[14], '7:30 PM');
    });

    test('drops the trailing zero on a whole height or weight', () {
      final csv = MemberCsvExport.build(
        members: [member(height: 170, weight: 62.5)],
        plans: [plan()],
        trainers: [trainer()],
      );
      final row = rowsOf(csv)[1].split(',');

      expect(row[5], '170');
      expect(row[6], '62.5');
    });

    test('leaves a deleted plan or trainer blank instead of failing', () {
      final csv = MemberCsvExport.build(
        members: [member(planId: 'gone', trainerId: 'gone')],
        plans: [plan()],
        trainers: [trainer()],
      );
      final row = rowsOf(csv)[1].split(',');

      expect(row[7], '');
      expect(row[8], '');
    });

    test('an address with a comma stays in one column', () {
      // Without quoting, this would split in two and shift the whole row.
      final csv = MemberCsvExport.build(
        members: [member(address: 'Flat 2, MG Road')],
        plans: [plan()],
        trainers: [trainer()],
      );

      expect(rowsOf(csv)[1], contains('"Flat 2, MG Road"'));
    });

    test('a quote or a line break inside a value is handled', () {
      final csv = MemberCsvExport.build(
        members: [member(name: 'A "Max" B', address: 'Line one\nLine two')],
        plans: [plan()],
        trainers: [trainer()],
      );

      expect(csv, contains('"A ""Max"" B"'));
      expect(csv, contains('"Line one\nLine two"'));
    });

    test('a value that looks like a formula is marked as plain text', () {
      // Excel would otherwise run this as a calculation when the owner
      // opened their own export.
      final csv = MemberCsvExport.build(
        members: [member(name: '=1+1', address: '@SUM(A1)')],
        plans: [plan()],
        trainers: [trainer()],
      );
      final row = rowsOf(csv)[1].split(',');

      expect(row[0], "'=1+1");
      expect(row[4], "'@SUM(A1)");
    });

    test('an ordinary name is left exactly as it was typed', () {
      final csv = MemberCsvExport.build(
        members: [member(name: 'Asha Patil')],
        plans: [plan()],
        trainers: [trainer()],
      );

      expect(rowsOf(csv)[1].split(',')[0], 'Asha Patil');
    });

    test('a gym with no members still produces the heading row', () {
      final csv = MemberCsvExport.build(
        members: const [],
        plans: const [],
        trainers: const [],
      );

      expect(rowsOf(csv), hasLength(1));
      expect(rowsOf(csv).first, startsWith('Name,'));
    });

    test('every row has the same number of columns as the heading', () {
      final csv = MemberCsvExport.build(
        members: [member(), member(name: 'Second'), member(name: 'Third')],
        plans: [plan()],
        trainers: [trainer()],
      );

      for (final row in rowsOf(csv)) {
        expect(_columnCount(row), MemberCsvExport.columns.length,
            reason: 'for row: $row');
      }
    });
  });

  group('MemberCsvExport.fileName', () {
    test('carries the gym name and the day it was taken', () {
      expect(
        MemberCsvExport.fileName(
            gymName: 'FitStrong Gym', asOf: DateTime(2026, 10, 21)),
        'fitstrong-gym-members-2026-10-21.csv',
      );
    });

    test('falls back to a plain name when the gym has none', () {
      expect(
        MemberCsvExport.fileName(gymName: '', asOf: DateTime(2026, 10, 21)),
        'members-2026-10-21.csv',
      );
    });

    test('keeps punctuation and spaces out of the file name', () {
      expect(
        MemberCsvExport.fileName(
            gymName: "Raj's Gym & Fitness!", asOf: DateTime(2026, 10, 21)),
        'raj-s-gym-fitness-members-2026-10-21.csv',
      );
    });
  });
}

/// Counts the columns in a row, honouring the quotes that let a value hold a
/// comma of its own.
int _columnCount(String row) {
  var count = 1;
  var inQuotes = false;
  for (final char in row.split('')) {
    if (char == '"') {
      inQuotes = !inQuotes;
    } else if (char == ',' && !inQuotes) {
      count++;
    }
  }
  return count;
}
