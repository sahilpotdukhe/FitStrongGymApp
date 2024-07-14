import 'package:fitstrong_gym/src/custom_import.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
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
            if (snapshot.hasData) {
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

