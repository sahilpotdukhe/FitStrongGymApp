import 'package:fitstrong_gym/Widgets/CachedImage.dart';
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
    Future.delayed(Duration(seconds: 5),(){
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) =>CustomBottomNavigationBar()));
    });
  }

  @override
  Widget build(BuildContext context) {
    UserProvider userProvider = Provider.of<UserProvider>(context);
    UserModel? userModel = userProvider.getUser;
    ScaleUtils.init(context);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 100*ScaleUtils.verticalScale,
            ),
            (userModel != null)
                ?  CachedImage(
                imageUrl: userModel.profilePhoto,
                isRound: false,
                radius: 0,
                height: 250*ScaleUtils.verticalScale,
                width: 250*ScaleUtils.horizontalScale,
                fit: BoxFit.cover)
                : Image.asset(
                    'assets/invoiceimage.png',
                    height: 250*ScaleUtils.verticalScale,
                    width: 250*ScaleUtils.horizontalScale,
                  ),
            Lottie.asset(
              'assets/splashweight.json',
              height: 200*ScaleUtils.verticalScale,
              width: 200*ScaleUtils.horizontalScale
            ),
            Spacer(),
            Image.asset(
              'assets/developer.png',
              height: 200*ScaleUtils.verticalScale,
              width: 200*ScaleUtils.horizontalScale,
            ),
          ],
        ),
      ),
    );
  }
}
