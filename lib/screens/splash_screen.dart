import 'package:fitstrong_gym/src/custom_import.dart';

/// Brand moment shown for three seconds after sign-in while the user's
/// profile loads.
///
/// Deliberately dark in both themes: the logo artwork has a dark background
/// baked into the image, and a brand splash is one of the few places a fixed
/// color is the right call.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const Color _splashBackground = Color(0xFF0B0D16);

  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.refreshUser();
    Future.delayed(const Duration(seconds: 3), () {
      // The screen can be popped by a sign-out before the timer fires.
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => CustomBottomNavigationBar()),
      );
    });
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
