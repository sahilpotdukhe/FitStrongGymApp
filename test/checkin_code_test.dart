import 'package:fitstrong_gym/models/member_model.dart';
import 'package:fitstrong_gym/models/gym_plan_model.dart';
import 'package:fitstrong_gym/provider/member_provider.dart';
import 'package:fitstrong_gym/resources/checkin_code.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

MemberModel _member({String checkinToken = ''}) {
  return MemberModel(
    id: 'm1',
    name: 'Asha',
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
    gender: 'Female',
    checkInTime: '',
    checkOutTime: '',
    checkinToken: checkinToken,
  );
}

Map<String, dynamic> _record({Map<String, dynamic> changes = const {}}) {
  return <String, dynamic>{
    'name': 'Asha',
    'mobileNumber': '8888888888',
    'dateOfBirth': Timestamp.fromDate(DateTime(2000, 1, 1)),
    'height': 170.0,
    'weight': 62.5,
    'photoUrl': '',
    'planId': 'plan1',
    'dateOfAdmission': Timestamp.fromDate(DateTime(2026, 1, 1)),
    'renewalDate': Timestamp.fromDate(DateTime(2026, 2, 1)),
    'expiryDate': Timestamp.fromDate(DateTime(2026, 2, 1)),
    'address': 'Nagpur',
    'gender': 'Female',
    'checkInTime': '',
    'checkOutTime': '',
    'trainerId': '',
    ...changes,
  };
}

void main() {
  group('CheckinCode', () {
    test('encodes a token behind the prefix', () {
      expect(CheckinCode.encode('abc-123'), 'FSGC:abc-123');
    });

    test('round trips', () {
      final token = CheckinCode.newToken();
      expect(CheckinCode.decode(CheckinCode.encode(token)), token);
    });

    test('issues a different token every time', () {
      final tokens = List.generate(50, (_) => CheckinCode.newToken()).toSet();
      expect(tokens.length, 50);
    });

    test('ignores surrounding whitespace a scanner may hand over', () {
      expect(CheckinCode.decode('  FSGC:abc-123\n'), 'abc-123');
    });

    test('rejects a QR that is not one of ours', () {
      // The front desk will have payment and Wi-Fi codes held up at it, and
      // none of them should cost a member lookup.
      expect(CheckinCode.decode('upi://pay?pa=someone@bank'), isNull);
      expect(CheckinCode.decode('https://example.com'), isNull);
      expect(CheckinCode.decode(''), isNull);
    });

    test('rejects our prefix with nothing behind it', () {
      expect(CheckinCode.decode('FSGC:'), isNull);
    });
  });

  group('MemberModel check-in token', () {
    test('defaults to empty for members added before check-in existed', () {
      expect(_member().checkinToken, '');
    });

    test('survives a renewal', () {
      // Renewing rebuilds the member field by field. Dropping the token here
      // would silently kill the QR code already on the member's phone.
      final plan = GymPlanModel(
          id: 'plan1', name: 'Monthly', months: 1, days: 0, fee: 1000);
      final renewed = _member(checkinToken: 'tok-1')
          .renewMembership(plan, DateTime(2026, 3, 1));

      expect(renewed.checkinToken, 'tok-1');
    });

    test('survives an unrelated copyWith', () {
      final moved = _member(checkinToken: 'tok-1').copyWith(trainerId: 't2');
      expect(moved.checkinToken, 'tok-1');
    });

    test('copyWith can reissue the token', () {
      final reissued =
          _member(checkinToken: 'tok-1').copyWith(checkinToken: 'tok-2');
      expect(reissued.checkinToken, 'tok-2');
    });

    test('toMap carries the token, so it reaches Firestore', () {
      expect(_member(checkinToken: 'tok-1').toMap()['checkinToken'], 'tok-1');
    });
  });

  group('reading a member back', () {
    test('picks up a stored token', () {
      final member = MemberProvider.memberFromData(
        'm1',
        _record(changes: {'checkinToken': 'tok-1'}),
      );
      expect(member!.checkinToken, 'tok-1');
    });

    test('an older record with no token stays readable', () {
      // These are repaired on demand when their code is first opened, so a
      // missing token must never drop the member from the list.
      final member = MemberProvider.memberFromData('m1', _record());
      expect(member, isNotNull);
      expect(member!.checkinToken, '');
    });
  });
}
