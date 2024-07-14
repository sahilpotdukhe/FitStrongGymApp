

import 'package:fitstrong_gym/src/custom_import.dart';

class SearchQuietBox extends StatelessWidget {
  final screen;

  const SearchQuietBox({super.key, this.screen});

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
                  (screen == "empty")
                      ? Image.asset('assets/search.jpg')
                      : Image.asset('assets/search.jpg'),
                  Text(
                    (screen == "empty") ? "No Members" : "Search",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 25 * ScaleUtils.scaleFactor),
                  ),
                  SizedBox(height: 10 * ScaleUtils.verticalScale),
                  Text(
                    (screen == "empty")
                        ? "No results found for your search query. Please try different keywords, check for typos, or adjust your filters and search again for better results."
                        : "Effortlessly find members by name with our intuitive search feature. Streamline your search process and connect with ease. Try it now and discover the simplicity of finding members by name.",
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
                      (screen == "empty") ? 'Search' : 'Search',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SearchScreen()));
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
