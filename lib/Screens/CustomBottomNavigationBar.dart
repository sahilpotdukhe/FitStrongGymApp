import 'package:fitstrong_gym/src/custom_import.dart';

class CustomBottomNavigationBar extends StatefulWidget {
  const CustomBottomNavigationBar({super.key});

  @override
  State<CustomBottomNavigationBar> createState() => _CustomBottomNavigationBarState();
}

class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar> {
  int page = 2;
  GlobalKey<CurvedNavigationBarState> bottomNavigationKey = GlobalKey(); // The GlobalKey class is commonly used in Flutter to provide access to the state of a widget from outside of the widget itself.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      bottomNavigationBar: CurvedNavigationBar(
        key: bottomNavigationKey,
        index: 2,
        items: const [
          Icon(Icons.inventory_outlined),
          Icon(Icons.person_add),
          Icon(Icons.dashboard),
          FaIcon(FontAwesomeIcons.addressCard),
          Icon(Icons.person)
        ],
        height: 60,
        color: Colors.white,
        buttonBackgroundColor: Colors.white,
        backgroundColor: UniversalVariables.appThemeColor,
        animationCurve: Curves.easeInOut,
        animationDuration: Duration(milliseconds: 300),
        onTap: (index) {
          setState(() {
            page = index;
          });
        },
        letIndexChange: (index) => true,
      ),
      body: getPage(page),
    );
  }
}

getPage(int page) {
  switch (page) {
    case 0:
      return AttendancePage();
    case 1:
      return AddMemberPage();
    case 2:
      return DashBoard();
    case 3:
      return MemberListPage();
    case 4:
      return MenuPage();
  }
}
