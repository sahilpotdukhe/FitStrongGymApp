import 'package:fitstrong_gym/src/custom_import.dart';

const supabaseUrl = String.fromEnvironment('SUPABASE_URL');

/// Supabase renamed this key from "anon" to "publishable". The environment
/// variable keeps its old name so existing env files still work.
const supabaseKey = String.fromEnvironment('SUPABASE_ANON_KEY');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (supabaseUrl.isEmpty || supabaseKey.isEmpty) {
    throw StateError(
        'Missing SUPABASE_URL / SUPABASE_ANON_KEY. Pass them with --dart-define-from-file=env/dev.json');
  }
  await Supabase.initialize(
    url: supabaseUrl,
    publishableKey: supabaseKey,
  );
  await Firebase.initializeApp();
  // Read the saved theme before the first frame so the app never flashes the
  // wrong brightness on launch.
  final themeMode = await ThemeModeStore.load();
  runApp(MyApp(initialThemeMode: themeMode));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.initialThemeMode = ThemeMode.system});

  final ThemeMode initialThemeMode;

  @override
  Widget build(BuildContext context) {
    AuthMethods authMethods = AuthMethods();
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (context) => GymPlanProvider()..fetchPlans()),
        ChangeNotifierProvider(create: (context) => MemberProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => AttendanceProvider()),
        ChangeNotifierProvider(create: (_) => InvoiceProvider()),
        ChangeNotifierProvider(create: (_) => TrainerProvider()),
      ],
      child: ShadcnApp(
        title: 'Gym Management App',
        light: AppTheme.light(),
        dark: AppTheme.dark(),
        initialMode: initialThemeMode,
        materialThemeBuilder: AppTheme.materialOverrides,
        home: FutureBuilder(
          future: authMethods.getCurrentUser(),
          builder: (context, AsyncSnapshot<User?> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const AppStartupScreen();
            } else if (snapshot.hasError) {
              return AppStartupScreen(error: '${snapshot.error}');
            } else if (snapshot.hasData) {
              return SplashScreen();
            } else {
              return Authenticate();
            }
          },
        ),
        routes: {
          '/home': (context) => CustomBottomNavigationBar(),
          '/add-plan': (context) => AddGymPlanPage(),
          '/add-member': (context) => AddMemberPage(),
          '/gym-plans': (context) => GymPlansPage(),
          '/trainers': (context) => TrainersPage(),
        },
      ),
    );
  }
}

/// Shown while the app works out whether someone is already signed in, and
/// if that check fails. Previously a bare spinner on a white page; now it
/// sits on the themed background so launch doesn't flash.
class AppStartupScreen extends StatelessWidget {
  const AppStartupScreen({super.key, this.error});

  final String? error;

  @override
  Widget build(BuildContext context) {
    final t = context.shadcn;
    return Scaffold(
      backgroundColor: t.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(ShadcnSpacing.xl2),
          child: error == null
              ? CircularProgressIndicator(color: t.primary)
              : ShadcnEmptyState(
                  icon: Icons.wifi_off_rounded,
                  title: 'Could not start',
                  description:
                      'Something went wrong while checking your session.\n$error',
                ),
        ),
      ),
    );
  }
}
