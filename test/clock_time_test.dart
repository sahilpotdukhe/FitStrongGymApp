import 'package:fitstrong_gym/resources/clock_time.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ClockTime.toStorage', () {
    test('writes a 24 hour clock with both parts padded', () {
      expect(ClockTime.toStorage(const TimeOfDay(hour: 17, minute: 30)),
          '17:30');
      expect(ClockTime.toStorage(const TimeOfDay(hour: 6, minute: 5)), '06:05');
      expect(ClockTime.toStorage(const TimeOfDay(hour: 0, minute: 0)), '00:00');
    });

    test('a time nobody picked is stored blank instead of throwing', () {
      // Saving a member used to throw here, part way through, because check
      // in and check out were assumed to have been filled in.
      expect(ClockTime.toStorage(null), '');
    });
  });

  group('ClockTime.parse', () {
    test('reads back what toStorage wrote', () {
      for (final time in [
        const TimeOfDay(hour: 0, minute: 0),
        const TimeOfDay(hour: 6, minute: 5),
        const TimeOfDay(hour: 12, minute: 0),
        const TimeOfDay(hour: 23, minute: 59),
      ]) {
        expect(ClockTime.parse(ClockTime.toStorage(time)), time);
      }
    });

    test('still reads the 12 hour text older versions saved', () {
      // The bug this guards: a phone set to a 12 hour clock stored "5:30 PM",
      // and reading it back split at the colon and tried to turn "30 PM" into
      // a number, so opening the record to edit it threw straight away.
      expect(ClockTime.parse('5:30 PM'), const TimeOfDay(hour: 17, minute: 30));
      expect(ClockTime.parse('9:05 AM'), const TimeOfDay(hour: 9, minute: 5));
      expect(ClockTime.parse('6:00 AM'), const TimeOfDay(hour: 6, minute: 0));
    });

    test('midnight and noon land on the right side of the day', () {
      expect(ClockTime.parse('12:00 AM'), const TimeOfDay(hour: 0, minute: 0));
      expect(ClockTime.parse('12:30 PM'), const TimeOfDay(hour: 12, minute: 30));
      expect(ClockTime.parse('12:15 AM'), const TimeOfDay(hour: 0, minute: 15));
    });

    test('copes with the odd spaces and dots some locales use', () {
      expect(ClockTime.parse('5:30 PM'),
          const TimeOfDay(hour: 17, minute: 30));
      expect(ClockTime.parse('5:30 pm'),
          const TimeOfDay(hour: 17, minute: 30));
      expect(ClockTime.parse('5:30 p.m.'),
          const TimeOfDay(hour: 17, minute: 30));
      expect(ClockTime.parse('  5:30 PM  '),
          const TimeOfDay(hour: 17, minute: 30));
    });

    test('gives back nothing for a blank or unreadable value', () {
      for (final bad in [null, '', '   ', 'morning', '25:00', '5:99', '530']) {
        expect(ClockTime.parse(bad), isNull, reason: 'for "$bad"');
      }
    });

    test('refuses an hour that cannot exist on a 12 hour clock', () {
      expect(ClockTime.parse('17:30 PM'), isNull);
      expect(ClockTime.parse('0:30 AM'), isNull);
    });
  });

  group('ClockTime.normalize', () {
    test('brings old 12 hour text into the stored shape', () {
      expect(ClockTime.normalize('5:30 PM'), '17:30');
      expect(ClockTime.normalize('6:00 AM'), '06:00');
    });

    test('leaves what it already understands alone', () {
      expect(ClockTime.normalize('17:30'), '17:30');
      expect(ClockTime.normalize(''), '');
    });

    test('hands back anything it cannot read, rather than wiping it', () {
      // Opening a record must never quietly erase a time it failed to parse.
      expect(ClockTime.normalize('sometime after lunch'),
          'sometime after lunch');
    });
  });

  group('ClockTime.label', () {
    test('writes a stored time out for people', () {
      expect(ClockTime.label('17:30'), '5:30 PM');
      expect(ClockTime.label('06:00'), '6:00 AM');
      expect(ClockTime.label('00:00'), '12:00 AM');
    });

    test('passes a blank or unreadable value straight through', () {
      expect(ClockTime.label(''), '');
      expect(ClockTime.label('not a time'), 'not a time');
    });
  });
}
