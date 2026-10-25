import 'package:fitstrong_core/fitstrong_core.dart';
import 'package:fitstrong_gym/resources/member_qr_card.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_flutter/qr_flutter.dart';

void main() {
  group('the shared check-in card', () {
    test('draws nothing for a member with no token', () async {
      // Guarded before any asset is loaded: a blank QR would look like a
      // real code and fail silently at the desk.
      final png = await renderMemberQrCard(const MemberQrCardData(
        memberName: 'Asha',
        token: '',
        gymName: 'FitStrong',
      ));
      expect(png, isNull);
    });
  });

  group('the code itself', () {
    test('carries the strongest error correction', () {
      // Level H rebuilds the code from 30% of it, which is what lets a
      // scratched screen or a poor camera still read it.
      final qr = buildCheckinQr(CheckinCode.newToken());
      expect(qr.errorCorrectLevel, QrErrorCorrectLevel.H);
    });

    test('encodes the member token', () {
      final token = CheckinCode.newToken();
      // Same payload the scanner decodes, so what is drawn is what is read.
      expect(CheckinCode.decode(CheckinCode.encode(token)), token);
      expect(() => buildCheckinQr(token), returnsNormally);
    });
  });
}
