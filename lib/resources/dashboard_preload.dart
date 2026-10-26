import 'package:fitstrong_gym/src/custom_import.dart';

/// Runs the dashboard's opening data fetches while the splash screen is still
/// on show, so the owner waits once instead of twice.
///
/// The dashboard used to start its four Firestore queries from its own
/// `initState`, which only runs after the splash has been replaced. The owner
/// sat through the brand screen, then watched an empty dashboard fill in.
///
/// Nothing here touches how the splash looks — only when the app moves on.
class DashboardPreload {
  DashboardPreload._();

  /// How long the last preload took. Printed on every run; kept here so a
  /// screen or a test can read the number back.
  static Duration? lastDuration;

  static bool _pending = false;

  /// Whether a finished preload is still waiting to be picked up.
  static bool get hasPending => _pending;

  /// Claims the preload: true for the first dashboard built after the splash,
  /// false for every one after it.
  ///
  /// One-shot rather than sticky on purpose. Not every route into the
  /// dashboard goes through the splash — signing up and the `/home` route land
  /// on the app shell directly — so a flag that stayed true would leave the
  /// dashboard of a freshly signed-up account waiting for data nobody fetched.
  static bool claim() {
    final wasPending = _pending;
    _pending = false;
    return wasPending;
  }

  /// Fetches members, plans, trainers and the owner's profile together.
  ///
  /// Reads its providers before the first `await`, so it is safe to call
  /// straight from `initState`.
  static Future<Duration> run(
    BuildContext context, {
    Duration timeout = const Duration(seconds: 8),
  }) async {
    final members = Provider.of<MemberProvider>(context, listen: false);
    final plans = Provider.of<GymPlanProvider>(context, listen: false);
    final user = Provider.of<UserProvider>(context, listen: false);
    final trainers = Provider.of<TrainerProvider>(context, listen: false);

    // One member fetch is enough: the active and expired counts are worked out
    // from that same list rather than fetched separately.
    final took = await loadTogether(
      [
        members.getAllMembers(),
        plans.fetchPlans(),
        user.refreshUser(),
        trainers.fetchTrainers(),
      ],
      timeout: timeout,
    );

    lastDuration = took;
    _pending = true;
    debugPrint('Dashboard preload finished in ${took.inMilliseconds}ms');
    return took;
  }

  /// Lets a test start from a known state, standing in for a splash run that
  /// has (or has not) just finished.
  @visibleForTesting
  static void reset({bool pending = false}) {
    _pending = pending;
    lastDuration = null;
  }
}

/// Waits for [fetches] to finish together and reports how long that took.
///
/// A failure or a stall must never trap the owner on the splash screen, so
/// both are swallowed and timed rather than thrown: the gym's wifi drops, and
/// an app that will not open is worse than one opening on stale counts. The
/// dashboard's pull-to-refresh is there to fill in whatever did not arrive.
///
/// [timeout] is a cap on how long the owner is asked to wait, not a promise
/// that the data came back.
Future<Duration> loadTogether(
  Iterable<Future<void>> fetches, {
  required Duration timeout,
}) async {
  final started = DateTime.now();

  // Each fetch catches its own failure. Letting `Future.wait` reject on the
  // first one would leave the others to fail later with nobody listening,
  // which Flutter reports as an unhandled error.
  final settled = fetches.map(
    (fetch) => fetch.catchError(
      (Object error) => debugPrint('Start-up fetch failed: $error'),
    ),
  );

  await Future.wait(settled).timeout(
    timeout,
    onTimeout: () {
      debugPrint('Start-up fetches still running after ${timeout.inSeconds}s; '
          'opening the app anyway');
      return <void>[];
    },
  );

  return DateTime.now().difference(started);
}
