import 'package:fitstrong_gym/Models/GymPlanModel.dart';
import 'package:fitstrong_gym/Models/MemberModel.dart';
import 'package:fitstrong_gym/Models/TrainerModel.dart';
import 'package:fitstrong_gym/Provider/TrainerProvider.dart';
import 'package:flutter_test/flutter_test.dart';

TrainerModel _trainer({
  String id = 't1',
  String name = 'Ravi',
  String shiftStart = '6:00 AM',
  String shiftEnd = '11:00 AM',
  List<String> workingDays = const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'],
  bool isActive = true,
}) {
  return TrainerModel(
    id: id,
    name: name,
    mobileNumber: '9999999999',
    gender: 'Male',
    specialization: 'Strength Training',
    experienceYears: 4,
    photoUrl: '',
    joiningDate: DateTime(2024, 1, 1),
    shiftStart: shiftStart,
    shiftEnd: shiftEnd,
    workingDays: workingDays,
    salary: 20000,
    address: 'Nagpur',
    isActive: isActive,
  );
}

MemberModel _member({required String id, String trainerId = ''}) {
  return MemberModel(
    id: id,
    name: 'Member $id',
    mobileNumber: '8888888888',
    dateOfBirth: DateTime(2000, 1, 1),
    height: 5.8,
    weight: 70,
    photoUrl: '',
    planId: 'plan1',
    dateOfAdmission: DateTime(2026, 1, 1),
    renewalDate: DateTime(2026, 2, 1),
    expiryDate: DateTime(2026, 2, 1),
    address: 'Nagpur',
    gender: 'Male',
    checkInTime: '',
    checkOutTime: '',
    trainerId: trainerId,
  );
}

void main() {
  group('TrainerModel.shiftLabel', () {
    test('joins both ends of the shift', () {
      expect(_trainer().shiftLabel, '6:00 AM – 11:00 AM');
    });

    test('copes with only one end being set', () {
      expect(_trainer(shiftEnd: '').shiftLabel, 'From 6:00 AM');
      expect(_trainer(shiftStart: '').shiftLabel, 'Until 11:00 AM');
    });

    test('says so when no shift is recorded', () {
      expect(
        _trainer(shiftStart: '', shiftEnd: '').shiftLabel,
        'Shift not set',
      );
    });
  });

  group('TrainerModel.workingDaysLabel', () {
    test('collapses a six day week', () {
      expect(_trainer().workingDaysLabel, 'Mon – Sat');
    });

    test('collapses a weekday-only week', () {
      expect(
        _trainer(workingDays: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'])
            .workingDaysLabel,
        'Mon – Fri',
      );
    });

    test('calls a full week every day', () {
      expect(
        _trainer(workingDays: TrainerModel.allWorkingDays).workingDaysLabel,
        'Every day',
      );
    });

    test('lists an irregular pattern in weekday order, not tick order', () {
      expect(
        _trainer(workingDays: ['Fri', 'Mon', 'Wed']).workingDaysLabel,
        'Mon, Wed, Fri',
      );
    });

    test('says so when no days are recorded', () {
      expect(_trainer(workingDays: []).workingDaysLabel, 'Days not set');
    });
  });

  group('TrainerModel.fromMap', () {
    test('fills in defaults for a document written before a field existed', () {
      final trainer = TrainerModel.fromMap('t9', {'name': 'Asha'});

      expect(trainer.id, 't9');
      expect(trainer.name, 'Asha');
      expect(trainer.mobileNumber, '');
      expect(trainer.experienceYears, 0);
      expect(trainer.salary, 0);
      expect(trainer.workingDays, isEmpty);
      // A trainer with no stored flag is assumed to still be working.
      expect(trainer.isActive, isTrue);
    });

    test('reads an integer salary as a double', () {
      final trainer = TrainerModel.fromMap('t9', {'salary': 15000});
      expect(trainer.salary, 15000.0);
    });
  });

  group('TrainerModel.findById', () {
    final trainers = [_trainer(id: 't1'), _trainer(id: 't2', name: 'Asha')];

    test('finds a trainer by id', () {
      expect(TrainerModel.findById(trainers, 't2')?.name, 'Asha');
    });

    test('returns null for an unknown or empty id', () {
      expect(TrainerModel.findById(trainers, 'gone'), isNull);
      expect(TrainerModel.findById(trainers, ''), isNull);
    });
  });

  group('membersOfTrainer', () {
    final members = [
      _member(id: 'm1', trainerId: 't1'),
      _member(id: 'm2', trainerId: 't2'),
      _member(id: 'm3', trainerId: 't1'),
      _member(id: 'm4'),
    ];

    test('returns only the members assigned to that trainer', () {
      expect(
        membersOfTrainer(members, 't1').map((m) => m.id),
        ['m1', 'm3'],
      );
    });

    test('an empty trainer id matches nobody, not every unassigned member', () {
      expect(membersOfTrainer(members, ''), isEmpty);
    });
  });

  group('MemberModel trainer assignment', () {
    test('defaults to nobody when not given', () {
      expect(_member(id: 'm1').trainerId, '');
    });

    test('survives a renewal', () {
      final plan = GymPlanModel(
          id: 'plan1', name: 'Monthly', months: 1, days: 0, fee: 1000);
      final renewed = _member(id: 'm1', trainerId: 't1')
          .renewMembership(plan, DateTime(2026, 3, 1));

      // Renewing buys more time; it does not change who coaches them.
      expect(renewed.trainerId, 't1');
      expect(renewed.expiryDate, DateTime(2026, 4, 1));
    });

    test('copyWith can reassign the trainer', () {
      final moved =
          _member(id: 'm1', trainerId: 't1').copyWith(trainerId: 't2');
      expect(moved.trainerId, 't2');
    });

    test('toMap carries the trainer, so the field reaches Firestore', () {
      expect(_member(id: 'm1', trainerId: 't7').toMap()['trainerId'], 't7');
    });
  });
}
