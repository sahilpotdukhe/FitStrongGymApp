import 'package:fitstrong_gym/src/custom_import.dart';

/// Brand moment shown after sign-in while the dashboard's data loads.
///
/// Deliberately dark in both themes: the logo artwork has a dark background
/// baked into the image, and a brand splash is one of the few places a fixed
/// color is the right call.
///
/// It used to sit here for a flat three seconds and then hand over to a
/// dashboard that only started fetching once it was built — two waits, back to
/// back. Now the fetching happens behind this screen and the app moves on as
/// soon as it is done.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const Color _splashBackground = Color(0xFF0B0D16);

  /// Shortest time the logo stays up, even when the data is already there.
  /// Without it a warm start would flash the brand screen for a few frames,
  /// which reads as a glitch rather than as a splash.
  static const Duration _minimumShow = Duration(milliseconds: 1200);

  /// Longest the owner is asked to look at the logo. A dead connection should
  /// still let them into the app, on whatever counts were cached.
  static const Duration _loadTimeout = Duration(seconds: 8);

  @override
  void initState() {
    super.initState();
    _openWhenReady();
  }

  Future<void> _openWhenReady() async {
    // Started before the first await, so the providers are read while this
    // widget is definitely still mounted.
    final loaded = DashboardPreload.run(context, timeout: _loadTimeout);
    // Both clocks start here, so the wait is the longer of the two rather
    // than one after the other.
    final shown = Future<void>.delayed(_minimumShow);

    await loaded;
    await shown;

    // The screen can be popped by a sign-out while the data is loading.
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => CustomBottomNavigationBar()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _splashBackground,
      body: SafeArea(
        // Without an explicit full width the column shrink-wraps to the logo
        // and lands left of centre, which is what pushed the whole splash to
        // one side of the screen.
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: ShadcnSpacing.xl3),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppTheme.radius * 2),
                  // A fixed 260 width overflowed the padding on the narrowest
                  // phones; a cap lets the logo shrink to fit instead.
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 260),
                    child: Image.asset(
                      'assets/logobg.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              const ShadcnGap(ShadcnSpacing.xl3),
              const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white24,
                ),
              ),
              const Spacer(flex: 3),
              Text(
                'FITSTRONG GYM',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.55),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 4,
                ),
              ),
              const ShadcnGap(ShadcnSpacing.xl2),
            ],
          ),
        ),
      ),
    );
  }
}
