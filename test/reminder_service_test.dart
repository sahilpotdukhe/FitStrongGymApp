import 'package:fitstrong_gym/models/member_model.dart';
import 'package:fitstrong_gym/resources/reminder_service.dart';
import 'package:flutter_test/flutter_test.dart';

MemberModel member({
  required String name,
  required DateTime dateOfBirth,
  required DateTime expiryDate,
}) {
  return MemberModel(
    id: name,
    name: name,
    mobileNumber: '9876543210',
    dateOfBirth: dateOfBirth,
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

void main() {
  final today = DateTime(2026, 3, 10);

  group('expiry reminders', () {
    test('picks up a membership expiring in two days', () {
      final digest = ReminderService.build(
        [
          member(
            name: 'Arjun',
            dateOfBirth: DateTime(1995, 8, 1),
            expiryDate: DateTime(2026, 3, 12),
          ),
        ],
        now: today,
      );

      expect(digest.expiring, hasLength(1));
      expect(digest.expiring.single.daysAway, 2);
      expect(digest.expiring.single.whenLabel, 'In 2 days');
    });

    test('leaves out a membership that runs for another month', () {
      final digest = ReminderService.build(
        [
          member(
            name: 'Arjun',
            dateOfBirth: DateTime(1995, 8, 1),
            expiryDate: DateTime(2026, 4, 12),
          ),
        ],
        now: today,
      );

      expect(digest.isEmpty, isTrue);
    });

    test('a membership that lapsed last week still needs a follow-up', () {
      final digest = ReminderService.build(
        [
          member(
            name: 'Arjun',
            dateOfBirth: DateTime(1995, 8, 1),
            expiryDate: DateTime(2026, 3, 7),
          ),
        ],
        now: today,
      );

      expect(digest.expired, hasLength(1));
      expect(digest.expired.single.whenLabel, '3 days ago');
    });

    test('a membership that lapsed months ago is left alone', () {
      final digest = ReminderService.build(
        [
          member(
            name: 'Arjun',
            dateOfBirth: DateTime(1995, 8, 1),
            expiryDate: DateTime(2025, 11, 1),
          ),
        ],
        now: today,
      );

      expect(digest.isEmpty, isTrue);
    });

    test('soonest expiry is listed first', () {
      final digest = ReminderService.build(
        [
          member(
            name: 'Later',
            dateOfBirth: DateTime(1995, 8, 1),
            expiryDate: DateTime(2026, 3, 13),
          ),
          member(
            name: 'Today',
            dateOfBirth: DateTime(1995, 8, 1),
            expiryDate: DateTime(2026, 3, 10),
          ),
        ],
        now: today,
      );

      expect(digest.expiring.map((r) => r.member.name), ['Today', 'Later']);
    });
  });

  group('birthdays', () {
    test("today's birthday is found whatever year they were born", () {
      final digest = ReminderService.build(
        [
          member(
            name: 'Arjun',
            dateOfBirth: DateTime(1990, 3, 10),
            expiryDate: DateTime(2026, 12, 1),
          ),
        ],
        now: today,
      );

      expect(digest.birthdays, hasLength(1));
      expect(digest.birthdays.single.kind, ReminderKind.birthdayToday);
      expect(digest.birthdays.single.whenLabel, 'Today');
    });

    test('a birthday later this week is listed, one next month is not', () {
      final digest = ReminderService.build(
        [
          member(
            name: 'Soon',
            dateOfBirth: DateTime(1990, 3, 14),
            expiryDate: DateTime(2026, 12, 1),
          ),
          member(
            name: 'Later',
            dateOfBirth: DateTime(1990, 4, 20),
            expiryDate: DateTime(2026, 12, 1),
          ),
        ],
        now: today,
      );

      expect(digest.birthdays.map((r) => r.member.name), ['Soon']);
    });

    test('a birthday just gone counts as nearly a year away, not overdue',
        () {
      final days = ReminderService.daysUntilBirthday(
        DateTime(1990, 3, 9),
        today,
      );

      expect(days, greaterThan(300));
    });

    test('someone born on 29 February is wished on the 28th in a short year',
        () {
      // 2027 is not a leap year, so there is no 29 February to wait for.
      final days = ReminderService.daysUntilBirthday(
        DateTime(2000, 2, 29),
        DateTime(2027, 2, 28),
      );

      expect(days, 0);
    });
  });

  group('headline', () {
    test('says what the morning notification should say', () {
      final digest = ReminderService.build(
        [
          member(
            name: 'Birthday',
            dateOfBirth: DateTime(1990, 3, 10),
            expiryDate: DateTime(2026, 12, 1),
          ),
          member(
            name: 'Expiring',
            dateOfBirth: DateTime(1990, 9, 9),
            expiryDate: DateTime(2026, 3, 11),
          ),
        ],
        now: today,
      );

      expect(digest.headline, '1 birthday today · 1 membership expiring soon');
    });

    test('a quiet day has nothing to announce', () {
      expect(const ReminderDigest.empty().headline, '');
      expect(const ReminderDigest.empty().isEmpty, isTrue);
    });
  });

  group('messages', () {
    test('the expiry message says when, by name', () {
      final digest = ReminderService.build(
        [
          member(
            name: 'Arjun',
            dateOfBirth: DateTime(1990, 9, 9),
            expiryDate: DateTime(2026, 3, 11),
          ),
        ],
        now: today,
      );

      final text = ReminderMessages.forReminder(
        digest.expiring.single,
        'FitStrong Gym',
      );

      expect(text, contains('Arjun'));
      expect(text, contains('tomorrow'));
      expect(text, contains('FitStrong Gym'));
    });

    test('the birthday message is a birthday message', () {
      final digest = ReminderService.build(
        [
          member(
            name: 'Arjun',
            dateOfBirth: DateTime(1990, 3, 10),
            expiryDate: DateTime(2026, 12, 1),
          ),
        ],
        now: today,
      );

      final text =
          ReminderMessages.forReminder(digest.birthdays.single, 'FitStrong');

      expect(text, contains('Happy birthday'));
      expect(text, contains('Arjun'));
    });
  });
}
