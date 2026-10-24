import 'package:fitstrong_gym/resources/member_qr_card.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('the shared check-in card', () {
    test('draws nothing for a member with no token', () async {
      // Guarded before any asset is loaded: a blank QR would look like a
      // real code and fail silently at the desk.
      final png = await renderMemberQrCard(const MemberQrCardData(
        memberName: 'Asha',
        token: '',
        gymName: 'FitStrong',
        lines: [],
      ));
      expect(png, isNull);
    });
  });

  group('dates on the card', () {
    test('read the long way round, not as digits', () {
      expect(formatCardDate(DateTime(2026, 4, 8)), '8 April 2026');
    });
  });
}
