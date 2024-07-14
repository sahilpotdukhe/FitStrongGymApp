import 'package:fitstrong_gym/src/custom_import.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  AuthMethods authMethods = AuthMethods();

  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.refreshUser();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ScaleUtils.init(context);
    UserProvider userProvider = Provider.of<UserProvider>(context);
    UserModel? userModel = userProvider.getUser;
    return Scaffold(
      backgroundColor: UniversalVariables.bgColor,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Account',
          style: TextStyle(
              color: UniversalVariables.appThemeColor,
              fontWeight: FontWeight.bold),
        ),
        backgroundColor: UniversalVariables.bgColor,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_outlined,
            color: UniversalVariables.appThemeColor,
          ),
          onPressed: () {
            Navigator.popAndPushNamed(context, '/home');
          },
        ),
      ),
      body: userModel == null
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(20.0 * ScaleUtils.scaleFactor),
              child: ListView(children: [
                InkWell(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => ProfilePage()));
                  },
                  child: Card(
                    elevation: 20,
                    shadowColor: Colors.grey,
                    child: Container(
                      width: ScaleUtils.width,
                      height: 120 * ScaleUtils.verticalScale,
                      // color: Colors.red,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: CircleAvatar(
                              radius: 40 * ScaleUtils.scaleFactor,
                              child: CircleAvatar(
                                radius: 35 * ScaleUtils.scaleFactor,
                                backgroundColor: Colors.transparent,
                                backgroundImage: AssetImage('assets/user.jpg'),
                                foregroundImage:
                                    NetworkImage(userModel!.profilePhoto),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  userModel.name,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20 * ScaleUtils.scaleFactor,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  userModel.email,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14 * ScaleUtils.scaleFactor,
                                      fontWeight: FontWeight.w300),
                                ),
                                Text(
                                  userModel.phoneNumber,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w300,
                                      fontSize: 14 * ScaleUtils.scaleFactor),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(
                              Icons.arrow_forward_ios_sharp,
                              color: Colors.white,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 30 * ScaleUtils.verticalScale,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: 18.0 * ScaleUtils.horizontalScale),
                  child: Card(
                    elevation: 10,
                    shadowColor: Colors.grey,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.0 * ScaleUtils.horizontalScale,
                            vertical: 12 * ScaleUtils.verticalScale),
                        child: Column(
                          children: [
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => AddMemberPage()));
                              },
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(18, 10, 18, 10),
                                child: Row(
                                  children: [
                                    Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: UniversalVariables.bgColor,
                                        ),
                                        height: 40,
                                        width: 40,
                                        child: Center(
                                            child: Icon(Icons.person_add))),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      'Add new Member',
                                      style: TextStyle(
                                          fontSize:
                                              17 * ScaleUtils.scaleFactor),
                                    ),
                                    Spacer(),
                                    Icon(Icons.arrow_forward_ios_sharp)
                                  ],
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            DisplayAllMembers()));
                              },
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(18, 10, 18, 10),
                                child: Row(
                                  children: [
                                    Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: UniversalVariables.bgColor,
                                        ),
                                        height: 40,
                                        width: 40,
                                        child: Center(
                                          child: FaIcon(
                                              FontAwesomeIcons.addressCard),
                                        )),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      'All Members',
                                      style: TextStyle(
                                          fontSize:
                                              17 * ScaleUtils.scaleFactor),
                                    ),
                                    Spacer(),
                                    Icon(Icons.arrow_forward_ios_sharp)
                                  ],
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            AddGymPlanPage()));
                              },
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(18, 10, 18, 10),
                                child: Row(
                                  children: [
                                    Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: UniversalVariables.bgColor,
                                        ),
                                        height: 40,
                                        width: 40,
                                        child: Center(
                                            child: Icon(Icons.add_card))),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      'Add Gym Plan',
                                      style: TextStyle(
                                          fontSize:
                                              17 * ScaleUtils.scaleFactor),
                                    ),
                                    Spacer(),
                                    Icon(Icons.arrow_forward_ios_sharp)
                                  ],
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => GymPlansPage()));
                              },
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(18, 10, 18, 10),
                                child: Row(
                                  children: [
                                    Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: UniversalVariables.bgColor,
                                        ),
                                        height: 40,
                                        width: 40,
                                        child: Center(
                                            child: Icon(Icons.fitness_center))),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      'All Gym Plans',
                                      style: TextStyle(
                                          fontSize:
                                              17 * ScaleUtils.scaleFactor),
                                    ),
                                    Spacer(),
                                    Icon(Icons.arrow_forward_ios_sharp)
                                  ],
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            RecycleBinPage()));
                              },
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(18, 10, 18, 10),
                                child: Row(
                                  children: [
                                    Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: UniversalVariables.bgColor,
                                        ),
                                        height: 40,
                                        width: 40,
                                        child: Center(
                                            child: Icon(Icons.delete_forever))),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      'Recycle Bin',
                                      style: TextStyle(
                                          fontSize:
                                              17 * ScaleUtils.scaleFactor),
                                    ),
                                    Spacer(),
                                    Icon(Icons.arrow_forward_ios_sharp)
                                  ],
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () async {
                                final Uri url = Uri.parse(
                                    'https://sahilpotdukhe.github.io/Portfolio-website/');
                                try {
                                  await launchUrl(url);
                                } catch (e) {
                                  print(e.toString());
                                }
                              },
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(18, 10, 18, 10),
                                child: Row(
                                  children: [
                                    Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: UniversalVariables.bgColor,
                                        ),
                                        height: 40,
                                        width: 40,
                                        child: Center(child: Icon(Icons.code))),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      'About Developer',
                                      style: TextStyle(
                                          fontSize:
                                              17 * ScaleUtils.scaleFactor),
                                    ),
                                    Spacer(),
                                    Icon(Icons.arrow_forward_ios_sharp)
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                Padding(
                  padding: const EdgeInsets.all(28.0),
                  child: InkWell(
                    onTap: () {
                      authMethods.logOut(context);
                      // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {return NewLoginScreen();}));
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Account Logging Out....")));
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(20 * ScaleUtils.scaleFactor),
                        color: HexColor("EE3427"),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(12.0 * ScaleUtils.scaleFactor),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Logout",
                              style: TextStyle(
                                  fontSize: 16 * ScaleUtils.scaleFactor,
                                  color: Colors.white),
                            ),
                            SizedBox(
                              width: 8 * ScaleUtils.horizontalScale,
                            ),
                            Icon(
                              Icons.logout,
                              color: Colors.white,
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ]),
            ),
    );
  }
}
