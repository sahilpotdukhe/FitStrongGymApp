import 'package:fitstrong_gym/src/custom_import.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.refreshUser();
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => CustomBottomNavigationBar()));
    });
  }

  @override
  Widget build(BuildContext context) {
    ScaleUtils.init(context);
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 100 * ScaleUtils.verticalScale,
            ),
            Image.asset(
              'assets/logobg.png',
              height: 250 * ScaleUtils.verticalScale,
              width: 250 * ScaleUtils.horizontalScale,
            ),
            // Lottie.asset('assets/pushUp.json',
            //     height: 200 * ScaleUtils.verticalScale,
            //     width: 200 * ScaleUtils.horizontalScale),
            Image.asset(
              'assets/sloganGym.png',
              height: 250 * ScaleUtils.verticalScale,
              width: 250 * ScaleUtils.horizontalScale,
            ),
            Spacer(),
            Image.asset(
              'assets/spwhitelogo.png',
              height: 200 * ScaleUtils.verticalScale,
              width: 200 * ScaleUtils.horizontalScale,
            ),
          ],
        ),
      ),
    );
  }
}
