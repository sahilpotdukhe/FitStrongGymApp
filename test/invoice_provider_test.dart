import 'package:flutter_test/flutter_test.dart';
import 'package:fitstrong_gym/models/invoice_record.dart';
import 'package:fitstrong_gym/provider/invoice_provider.dart';

InvoiceRecord invoice({
  String number = 'INV-0001',
  String memberName = 'Asha',
  double amount = 1000,
  required DateTime issuedAt,
}) {
  return InvoiceRecord(
    id: number,
    invoiceNumber: number,
    memberId: 'm1',
    memberName: memberName,
    planId: 'p1',
    planName: 'Monthly',
    amount: amount,
    paymentMethod: 'Cash',
    transactionType: 'New Membership',
    issuedAt: issuedAt,
  );
}

void main() {
  final records = [
    invoice(
        number: 'INV-0003',
        memberName: 'Ravi Kumar',
        amount: 2500,
        issuedAt: DateTime(2026, 3, 14)),
    invoice(
        number: 'INV-0002',
        memberName: 'Asha Patel',
        amount: 1500.50,
        issuedAt: DateTime(2026, 2, 28)),
    invoice(
        number: 'INV-0001',
        memberName: 'asha patel',
        amount: 1000,
        issuedAt: DateTime(2026, 2, 1)),
  ];

  group('InvoiceProvider.totalOf', () {
    test('adds up every amount in the list', () {
      expect(InvoiceProvider.totalOf(records), 5000.50);
    });

    test('is zero for an empty list', () {
      expect(InvoiceProvider.totalOf([]), 0.0);
    });
  });

  group('InvoiceProvider.monthsOf', () {
    test('collapses bills into one entry per calendar month, newest first', () {
      expect(InvoiceProvider.monthsOf(records),
          [DateTime(2026, 3), DateTime(2026, 2)]);
    });

    test('ignores the day and time inside a month', () {
      final sameMonth = [
        invoice(issuedAt: DateTime(2026, 5, 1, 9, 30)),
        invoice(issuedAt: DateTime(2026, 5, 31, 23, 59)),
      ];
      expect(InvoiceProvider.monthsOf(sameMonth), [DateTime(2026, 5)]);
    });

    test('is empty when there are no bills', () {
      expect(InvoiceProvider.monthsOf([]), isEmpty);
    });
  });

  group('InvoiceProvider.filter', () {
    test('returns everything when no month or name is given', () {
      expect(InvoiceProvider.filter(records).length, 3);
    });

    test('keeps only the bills raised in the chosen month', () {
      final february =
          InvoiceProvider.filter(records, month: DateTime(2026, 2));
      expect(february.map((i) => i.invoiceNumber), ['INV-0002', 'INV-0001']);
      expect(InvoiceProvider.totalOf(february), 2500.50);
    });

    test('matches a member name regardless of capitals or spacing', () {
      expect(
        InvoiceProvider.filter(records, query: '  ASHA ')
            .map((i) => i.invoiceNumber),
        ['INV-0002', 'INV-0001'],
      );
    });

    test('matches part of a name, not just the start', () {
      expect(
        InvoiceProvider.filter(records, query: 'kumar')
            .map((i) => i.invoiceNumber),
        ['INV-0003'],
      );
    });

    test('applies the month and the name together', () {
      expect(
        InvoiceProvider.filter(records,
            month: DateTime(2026, 2), query: 'ravi'),
        isEmpty,
      );
      expect(
        InvoiceProvider.filter(records, month: DateTime(2026, 2), query: 'asha')
            .length,
        2,
      );
    });

    test('a blank or spaces-only search is treated as no search', () {
      expect(InvoiceProvider.filter(records, query: '   ').length, 3);
    });

    test('ignores the day of the month on the month that is passed in', () {
      // The screen hands over the first of the month, but a date picked any
      // other way must still select the whole month.
      expect(
        InvoiceProvider.filter(records, month: DateTime(2026, 2, 17)).length,
        2,
      );
    });
  });
}
