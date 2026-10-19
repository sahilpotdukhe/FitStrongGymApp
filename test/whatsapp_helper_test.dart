import 'package:fitstrong_gym/resources/whatsapp_helper.dart';
import 'package:flutter_test/flutter_test.dart';

/// Members' numbers are typed in by hand, so they arrive in every shape.
/// WhatsApp only accepts digits with a country code in front.
void main() {
  group('normalizeNumber', () {
    test('adds the country code to a plain ten-digit number', () {
      expect(WhatsAppHelper.normalizeNumber('9876543210'), '919876543210');
    });

    test('strips spaces, dashes and the plus sign', () {
      expect(WhatsAppHelper.normalizeNumber('+91 98765-43210'),
          '919876543210');
    });

    test('drops the leading zero people dial at home', () {
      expect(WhatsAppHelper.normalizeNumber('09876543210'), '919876543210');
    });

    test('leaves a number that already has its country code alone', () {
      expect(WhatsAppHelper.normalizeNumber('919876543210'), '919876543210');
    });

    test('refuses a number that is too short to be real', () {
      expect(WhatsAppHelper.normalizeNumber('12345'), isNull);
      expect(WhatsAppHelper.canMessage('12345'), isFalse);
    });

    test('refuses an empty or text-only field', () {
      expect(WhatsAppHelper.normalizeNumber(''), isNull);
      expect(WhatsAppHelper.normalizeNumber('not given'), isNull);
    });
  });
}
