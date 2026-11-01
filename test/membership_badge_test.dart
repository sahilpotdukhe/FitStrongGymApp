import 'package:fitstrong_gym/models/member_model.dart';
import 'package:fitstrong_gym/widgets/membership_badge.dart';
import 'package:flutter_test/flutter_test.dart';

MemberModel memberExpiring(DateTime expiryDate) {
  return MemberModel(
    id: 'member-1',
    name: 'Arjun',
    mobileNumber: '9876543210',
    dateOfBirth: DateTime(1995, 8, 1),
    height: 170,
    weight: 70,
    photoUrl: '',
    planId: 'plan-1',
    dateOfAdmission: DateTime(2024, 1, 1),
    renewalDate: expiryDate,
    expiryDate: expiryDate,
    address: '',
    gender: 'Male',
    checkInTime: '',
    checkOutTime: '',
  );
}

/// Midnight today, and midnight [days] from now.
DateTime daysFromToday(int days) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day + days);
}

void main() {
  group('daysUntilExpiry', () {
    test('counts whole calendar days whatever the time of day', () {
      // Subtracting the two moments instead of the two dates threw the part
      // day away, so from six in the evening every count came out one short.
      expect(daysUntilExpiry(memberExpiring(daysFromToday(4))), 4);
      expect(daysUntilExpiry(memberExpiring(daysFromToday(1))), 1);
    });

    test('is zero on the expiry date itself and negative after it', () {
      expect(daysUntilExpiry(memberExpiring(daysFromToday(0))), 0);
      expect(daysUntilExpiry(memberExpiring(daysFromToday(-3))), -3);
    });
  });

  group('membershipStateOf', () {
    test('payment is due from the expiry date through the week after', () {
      // The scanner still lets these members in, so the office must not
      // read them as flatly expired: the owner's job here is to chase the
      // money, not to assume they are gone.
      expect(
        membershipStateOf(memberExpiring(daysFromToday(0))),
        MembershipState.paymentDue,
      );
      expect(
        membershipStateOf(memberExpiring(daysFromToday(-6))),
        MembershipState.paymentDue,
      );
    });

    test('expired once the days to pay have run out', () {
      expect(
        membershipStateOf(memberExpiring(daysFromToday(-7))),
        MembershipState.expired,
      );
      expect(
        membershipStateOf(memberExpiring(daysFromToday(-40))),
        MembershipState.expired,
      );
    });

    test('the last few days before expiry are flagged, earlier ones are not',
        () {
      expect(
        membershipStateOf(memberExpiring(daysFromToday(3))),
        MembershipState.expiringSoon,
      );
      expect(
        membershipStateOf(memberExpiring(daysFromToday(7))),
        MembershipState.expiringSoon,
      );
      // Eight days out used to land on seven and be flagged a day early.
      expect(
        membershipStateOf(memberExpiring(daysFromToday(8))),
        MembershipState.active,
      );
    });
  });
}
