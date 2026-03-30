import 'package:fitstrong_gym/src/custom_import.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://dkjdxyevbvisszhbrojt.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRramR4eWV2YnZpc3N6aGJyb2p0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQ3OTE5MTUsImV4cCI6MjA5MDM2NzkxNX0.vrt2V5xUyoRLtMXIUCQt_4EskMsEd7sZpmPMHzQ215A', // Check your Supabase project settings for this key
  );
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    AuthMethods authMethods = AuthMethods();
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => GymPlanProvider()..fetchPlans()),
        ChangeNotifierProvider(create: (context) => MemberProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => AttendanceProvider()),
      ],
      child: MaterialApp(
        title: 'Gym Management App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        debugShowCheckedModeBanner: false,
        home: FutureBuilder(
          future: authMethods.getCurrentUser(),
          builder: (context, AsyncSnapshot<User?> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }else if (snapshot.hasData) {
              return SplashScreen();
            } else {
              return  Authenticate();
            }
          },
        ),
        routes: {
          '/home': (context) => CustomBottomNavigationBar(),
          '/add-plan': (context) => AddGymPlanPage(),
          '/add-member': (context) => AddMemberPage(),
          '/gym-plans' : (context) => GymPlansPage()
        },
      ),
    );
  }
}

