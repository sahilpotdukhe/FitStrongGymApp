import 'package:fitstrong_gym/src/custom_import.dart';
import 'package:flutter_test/flutter_test.dart';

/// Member photos used to be downloaded at whatever size the camera produced
/// and decoded in full to paint a 38px list thumbnail. Avatars now ask for the
/// number of real pixels they actually paint, which is what this works out.
void main() {
  /// Reads the extent an avatar of [size] would ask for on a screen of
  /// [devicePixelRatio].
  Future<int> extentFor(
    WidgetTester tester, {
    required double size,
    required double devicePixelRatio,
  }) async {
    late int extent;
    await tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData(devicePixelRatio: devicePixelRatio),
        child: Builder(
          builder: (context) {
            extent = avatarCacheExtent(context, size);
            return const SizedBox();
          },
        ),
      ),
    );
    return extent;
  }

  testWidgets('asks for the real pixels a 3x screen paints', (tester) async {
    // The owner's photo on the dashboard: 40 logical pixels on a typical
    // phone, so 120 real ones — not the 1920px upload it used to fetch.
    expect(await extentFor(tester, size: 40, devicePixelRatio: 3), 120);
  });

  testWidgets('scales with the screen, so a 1x screen asks for less',
      (tester) async {
    expect(await extentFor(tester, size: 104, devicePixelRatio: 1), 104);
  });

  testWidgets('never asks for less than a usable thumbnail', (tester) async {
    // A floor keeps a tiny avatar from caching a blurry copy that a bigger
    // avatar of the same person would then have to re-fetch anyway.
    expect(await extentFor(tester, size: 8, devicePixelRatio: 1), 64);
  });

  testWidgets('never asks for the original camera file again', (tester) async {
    // The cap is headroom: nothing in the app is this big today, but it means
    // a future oversized avatar still cannot request a 4000px photo.
    expect(await extentFor(tester, size: 1000, devicePixelRatio: 3), 512);
  });
}
