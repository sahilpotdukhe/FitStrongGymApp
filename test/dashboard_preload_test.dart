import 'dart:async';

import 'package:fitstrong_gym/src/custom_import.dart';
import 'package:flutter_test/flutter_test.dart';

/// The dashboard's opening fetches now run behind the splash screen.
///
/// The thing that must never break is the escape hatch: a gym with bad wifi
/// has to be able to get into the app. So a fetch that fails, and a fetch that
/// never answers at all, both have to let go rather than stranding the owner
/// on the logo.
void main() {
  group('loadTogether', () {
    test('waits for every fetch before reporting back', () async {
      var slowFinished = false;

      await loadTogether(
        [
          Future<void>.delayed(const Duration(milliseconds: 10)),
          Future<void>.delayed(const Duration(milliseconds: 60))
              .then((_) => slowFinished = true),
        ],
        timeout: const Duration(seconds: 5),
      );

      // The slowest fetch decides, not the quickest.
      expect(slowFinished, isTrue);
    });

    test('a fetch that fails does not stop the app opening', () async {
      var goodFinished = false;

      await expectLater(
        loadTogether(
          [
            Future<void>.error(StateError('no connection')),
            Future<void>.delayed(const Duration(milliseconds: 10))
                .then((_) => goodFinished = true),
          ],
          timeout: const Duration(seconds: 5),
        ),
        completes,
      );

      // The failure is swallowed and the fetch beside it still lands.
      expect(goodFinished, isTrue);
    });

    test('gives up on a fetch that never answers', () async {
      // A request that hangs forever, which is what a dead network looks like
      // from here — not an error, just silence.
      final hanging = Completer<void>();

      final took = await loadTogether(
        [hanging.future],
        timeout: const Duration(milliseconds: 80),
      );

      expect(took, greaterThanOrEqualTo(const Duration(milliseconds: 60)));
      expect(hanging.isCompleted, isFalse);
    });

    test('reports roughly how long the fetches took', () async {
      final took = await loadTogether(
        [Future<void>.delayed(const Duration(milliseconds: 120))],
        timeout: const Duration(seconds: 5),
      );

      // Loose bounds on purpose: this asserts the clock is running, not that
      // the machine is fast.
      expect(took, greaterThanOrEqualTo(const Duration(milliseconds: 100)));
      expect(took, lessThan(const Duration(seconds: 5)));
    });
  });

  group('DashboardPreload.claim', () {
    setUp(DashboardPreload.reset);

    test('the first dashboard after the splash picks the preload up', () {
      DashboardPreload.reset(pending: true);

      expect(DashboardPreload.claim(), isTrue);
    });

    test('a later dashboard fetches for itself instead', () {
      DashboardPreload.reset(pending: true);
      DashboardPreload.claim();

      // Signing up lands on the app shell without a splash. If the flag stayed
      // true that dashboard would sit empty, waiting for data nobody asked for.
      expect(DashboardPreload.claim(), isFalse);
    });

    test('with no splash run at all, the dashboard fetches for itself', () {
      expect(DashboardPreload.claim(), isFalse);
    });
  });
}
