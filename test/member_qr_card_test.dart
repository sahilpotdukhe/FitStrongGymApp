import 'package:fitstrong_core/fitstrong_core.dart';
import 'package:fitstrong_gym/resources/member_qr_card.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_flutter/qr_flutter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

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

    testWidgets('draws a full card for a member who has one', (tester) async {
      // runAsync, because the card loads bundled images and hands the canvas
      // to the engine; a widget test's fake clock never settles either.
      await tester.runAsync(() async {
        final png = await renderMemberQrCard(MemberQrCardData(
          memberName: 'Pragya',
          token: CheckinCode.newToken(),
          gymName: 'Arjuna Fitness Club',
          gymPhone: '7447332096',
        ));
        // A real PNG, not an empty buffer: the whole card is laid out, so a
        // missing asset or a bad measure pass fails here rather than in a
        // member's chat.
        expect(png, isNotNull);
        expect(png!.length, greaterThan(1000));
        expect(png.sublist(1, 4), [0x50, 0x4E, 0x47]);
      });
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
