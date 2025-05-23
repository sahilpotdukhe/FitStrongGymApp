import 'package:fitstrong_gym/src/custom_import.dart';

class PlansQuietBox extends StatelessWidget {

  const PlansQuietBox({super.key});

  @override
  Widget build(BuildContext context) {
    ScaleUtils.init(context);
    return ListView(
      children: [
        SizedBox(
          height: 70 * ScaleUtils.verticalScale,
        ),
        Center(
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: 30 * ScaleUtils.horizontalScale),
            child: Container(
              decoration: BoxDecoration(
                borderRadius:
                BorderRadius.circular(50 * ScaleUtils.scaleFactor),
                color: Colors.white,
              ),
              padding: EdgeInsets.symmetric(
                  vertical: 25 * ScaleUtils.verticalScale,
                  horizontal: 25 * ScaleUtils.horizontalScale),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/noplans.png'),
                  Text(
                    "No Memberships",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 25 * ScaleUtils.scaleFactor),
                  ),
                  SizedBox(height: 10 * ScaleUtils.verticalScale),
                  Text(
                     "No memberships plans found. Please add new memberships for the gym.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.normal,
                        fontSize: 15 * ScaleUtils.scaleFactor),
                  ),
                  SizedBox(height: 25 * ScaleUtils.verticalScale),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: UniversalVariables.appThemeColor),
                    child: Text(
                       'Add Plan',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AddGymPlanPage()));

                    },
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
