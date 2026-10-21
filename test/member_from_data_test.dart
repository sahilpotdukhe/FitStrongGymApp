import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitstrong_gym/provider/member_provider.dart';
import 'package:flutter_test/flutter_test.dart';

/// A record as Firestore hands it over, with any field swapped out or
/// dropped so the awkward cases can be checked one at a time.
Map<String, dynamic> record({
  Map<String, dynamic> changes = const {},
  List<String> missing = const [],
}) {
  final data = <String, dynamic>{
    'name': 'Asha',
    'mobileNumber': '9876543210',
    'dateOfBirth': Timestamp.fromDate(DateTime(1995, 4, 12)),
    'height': 170.0,
    'weight': 62.5,
    'photoUrl': 'https://example.com/a.jpg',
    'planId': 'plan-1',
    'dateOfAdmission': Timestamp.fromDate(DateTime(2025, 1, 10)),
    'renewalDate': Timestamp.fromDate(DateTime(2026, 1, 10)),
    'expiryDate': Timestamp.fromDate(DateTime(2026, 1, 10)),
    'address': 'Pune',
    'gender': 'Female',
    'checkInTime': '06:00',
    'checkOutTime': '07:30',
    'trainerId': 'trainer-1',
  };
  for (final key in missing) {
    data.remove(key);
  }
  return {...data, ...changes};
}

void main() {
  group('MemberProvider.memberFromData', () {
    test('reads a well formed record', () {
      final member = MemberProvider.memberFromData('m1', record());

      expect(member, isNotNull);
      expect(member!.id, 'm1');
      expect(member.name, 'Asha');
      expect(member.weight, 62.5);
      expect(member.expiryDate, DateTime(2026, 1, 10));
      expect(member.trainerId, 'trainer-1');
    });

    test('accepts a weight or height saved as a whole number', () {
      // Firestore gives back an int for a whole number, which someone typing
      // 70 into the Firebase console creates. That used to fail the cast to
      // double and take the record down with it.
      final member = MemberProvider.memberFromData(
        'm1',
        record(changes: {'height': 170, 'weight': 70}),
      );

      expect(member, isNotNull);
      expect(member!.height, 170.0);
      expect(member.weight, 70.0);
    });

    test('fills in the fields that are only ever shown', () {
      final member = MemberProvider.memberFromData(
        'm1',
        record(missing: ['name', 'address', 'gender', 'trainerId']),
      );

      expect(member, isNotNull);
      expect(member!.name, '');
      expect(member.address, '');
      expect(member.trainerId, '');
    });

    test('falls back on an admission or renewal date that is missing', () {
      final member = MemberProvider.memberFromData(
        'm1',
        record(missing: ['dateOfAdmission', 'renewalDate']),
      );

      expect(member, isNotNull);
      expect(member!.dateOfAdmission, DateTime(2026, 1, 10));
      expect(member.renewalDate, DateTime(2026, 1, 10));
    });

    test('leaves out a record with no expiry or birth date', () {
      // Guessing either would send the wrong reminder to a real person: the
      // expiry decides who counts as expired, the birth date who gets a
      // birthday message.
      expect(MemberProvider.memberFromData('m1', record(missing: ['expiryDate'])),
          isNull);
      expect(
          MemberProvider.memberFromData('m1', record(missing: ['dateOfBirth'])),
          isNull);
    });

    test('leaves out a record that is not readable at all', () {
      expect(MemberProvider.memberFromData('m1', null), isNull);
      expect(MemberProvider.memberFromData('m1', 'not a record'), isNull);
      expect(MemberProvider.memberFromData('m1', <String, dynamic>{}), isNull);
    });

    test('one bad record does not take the good ones with it', () {
      // The whole point of the change: a damaged record used to throw, and
      // the fetch caught it and returned an empty list, so the owner was
      // told they had no members at all.
      final raw = [
        record(changes: {'name': 'Asha'}),
        record(missing: ['expiryDate']),
        record(changes: {'name': 'Ravi'}),
      ];

      final members = raw
          .map((data) => MemberProvider.memberFromData('m', data))
          .whereType<Object>()
          .toList();

      expect(members.length, 2);
    });
  });
}
