import 'package:fitstrong_gym/Models/GymPlanModel.dart';
import 'package:fitstrong_gym/Models/MemberModel.dart';
import 'package:fitstrong_gym/Provider/GymPlanProvider.dart';
import 'package:flutter_test/flutter_test.dart';

MemberModel memberOn(String planId, {String id = 'm'}) {
  return MemberModel(
    id: id,
    name: id,
    mobileNumber: '9876543210',
    dateOfBirth: DateTime(1995, 1, 1),
    height: 170,
    weight: 70,
    photoUrl: '',
    planId: planId,
    dateOfAdmission: DateTime(2025, 1, 1),
    renewalDate: DateTime(2026, 1, 1),
    expiryDate: DateTime(2026, 1, 1),
    address: '',
    gender: 'Male',
    checkInTime: '',
    checkOutTime: '',
  );
}

GymPlanModel plan({
  String id = 'p1',
  int months = 3,
  int days = 0,
  bool isHidden = false,
}) {
  return GymPlanModel(
    id: id,
    name: 'Plan $id',
    months: months,
    days: days,
    fee: 3000,
    isHidden: isHidden,
  );
}

void main() {
  group('membersOnPlan', () {
    test('counts only the members actually on that plan', () {
      final count = GymPlanProvider.membersOnPlan(
        'p1',
        members: [
          memberOn('p1', id: 'a'),
          memberOn('p2', id: 'b'),
          memberOn('p1', id: 'c'),
        ],
        recycleBinMembers: const [],
      );

      expect(count, 2);
    });

    test('a member in the recycle bin still holds the plan', () {
      // They can be restored later, and would land back on this plan.
      final count = GymPlanProvider.membersOnPlan(
        'p1',
        members: const [],
        recycleBinMembers: [memberOn('p1', id: 'deleted')],
      );

      expect(count, 1);
    });

    test('a plan nobody is on counts zero, so it is safe to delete', () {
      final count = GymPlanProvider.membersOnPlan(
        'p-unused',
        members: [memberOn('p1')],
        recycleBinMembers: [memberOn('p2')],
      );

      expect(count, 0);
    });
  });

  group('plan model', () {
    test('a hidden plan can still be looked up by an old invoice', () {
      final plans = [plan(id: 'p1', isHidden: true)];

      expect(GymPlanModel.findById(plans, 'p1')?.name, 'Plan p1');
    });

    test('length in days puts plans of different shapes in order', () {
      final yearly = plan(id: 'y', months: 12);
      final trial = plan(id: 't', months: 0, days: 15);

      expect(yearly.lengthInDays, greaterThan(trial.lengthInDays));
    });

    test('hiding a plan changes nothing else about it', () {
      final hidden = plan(id: 'p1').copyWith(isHidden: true);

      expect(hidden.isHidden, isTrue);
      expect(hidden.id, 'p1');
      expect(hidden.fee, 3000);
      expect(hidden.months, 3);
    });
  });
}
