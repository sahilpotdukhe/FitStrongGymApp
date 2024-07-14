
import 'package:fitstrong_gym/src/custom_import.dart';

class MembersQuietBox extends StatelessWidget {
  final screen;

  const MembersQuietBox({super.key, this.screen});

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
                  (screen == "nomembers")
                      ? Image.asset('assets/nomembersbg.png')
                      : Image.asset('assets/recyclebin.png'),
                  Text(
                    (screen == "nomembers") ? "No Members" : "Empty Recycle Bin",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 25 * ScaleUtils.scaleFactor),
                  ),
                  SizedBox(height: 10 * ScaleUtils.verticalScale),
                  Text(
                    (screen == "nomembers")
                        ? "No members found. Please add new members to the gym app for admission."
                        : "No items found in the recycle bin.",
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
                      (screen == "nomembers") ? 'Add Members' : 'Back',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      (screen == "nomembers") ? Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AddMemberPage()))
                          :Navigator.pop(context);
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
