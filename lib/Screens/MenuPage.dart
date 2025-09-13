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
              padding: EdgeInsets.symmetric(
                  horizontal: 20.0 * ScaleUtils.scaleFactor,
                  vertical: 10.0 * ScaleUtils.scaleFactor),
              child: ListView(children: [
                InkWell(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => ProfilePage()));
                  },
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
                            radius: 32 * ScaleUtils.scaleFactor,
                            backgroundColor: Colors.transparent,
                            backgroundImage: AssetImage('assets/user.jpg'),
                            foregroundImage:
                                NetworkImage(userModel.profilePhoto),
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
                        SizedBox(
                          width: 10,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.arrow_forward_ios_sharp,
                            color: Colors.grey,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 30 * ScaleUtils.verticalScale,
                ),
                Column(
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AddMemberPage()));
                      },
                      child: Card(
                        elevation: 10,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(18, 16, 18, 16),
                          child: Row(
                            children: [
                              Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: HexColor('#DBEAFE'),
                                  ),
                                  height: 46,
                                  width: 46,
                                  child: Center(
                                      child: Icon(
                                    Icons.person_add,
                                    color: HexColor('#2563EB'),
                                  ))),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                'Add new Member',
                                style: TextStyle(
                                    fontSize: 17 * ScaleUtils.scaleFactor,
                                    fontWeight: FontWeight.w500),
                              ),
                              Spacer(),
                              Icon(
                                Icons.arrow_forward_ios_sharp,
                                color: Colors.grey,
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => DisplayAllMembers()));
                      },
                      child: Card(
                        elevation: 10,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(18, 14, 18, 14),
                          child: Row(
                            children: [
                              Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: HexColor('#EDE9FE'),
                                  ),
                                  height: 46,
                                  width: 46,
                                  child: Center(
                                    child: FaIcon(
                                      FontAwesomeIcons.addressCard,
                                      color: HexColor('#7C3AED'),
                                    ),
                                  )),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                'All Members',
                                style: TextStyle(
                                    fontSize: 17 * ScaleUtils.scaleFactor,
                                    fontWeight: FontWeight.w500),
                              ),
                              Spacer(),
                              Icon(
                                Icons.arrow_forward_ios_sharp,
                                color: Colors.grey,
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AddGymPlanPage()));
                      },
                      child: Card(
                        elevation: 10,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(18, 14, 18, 14),
                          child: Row(
                            children: [
                              Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: HexColor('#D1FAE5'),
                                  ),
                                  height: 46,
                                  width: 46,
                                  child: Center(
                                      child: Icon(
                                    Icons.add_card,
                                    color: HexColor('#059669'),
                                  ))),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                'Add Gym Plan',
                                style: TextStyle(
                                    fontSize: 17 * ScaleUtils.scaleFactor,
                                    fontWeight: FontWeight.w500),
                              ),
                              Spacer(),
                              Icon(
                                Icons.arrow_forward_ios_sharp,
                                color: Colors.grey,
                              )
                            ],
                          ),
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
                      child: Card(
                        elevation: 10,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(18, 14, 18, 14),
                          child: Row(
                            children: [
                              Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: HexColor('#FEF3C7'),
                                  ),
                                  height: 46,
                                  width: 46,
                                  child: Center(
                                      child: Icon(
                                    Icons.fitness_center,
                                    color: HexColor('#D97706'),
                                  ))),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                'All Gym Plans',
                                style: TextStyle(
                                    fontSize: 17 * ScaleUtils.scaleFactor,
                                    fontWeight: FontWeight.w500),
                              ),
                              Spacer(),
                              Icon(
                                Icons.arrow_forward_ios_sharp,
                                color: Colors.grey,
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => RecycleBinPage()));
                      },
                      child: Card(
                        elevation: 10,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(18, 14, 18, 14),
                          child: Row(
                            children: [
                              Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: HexColor('#FEE2E2'),
                                  ),
                                  height: 46,
                                  width: 46,
                                  child: Center(
                                      child: Icon(
                                    Icons.delete_forever,
                                    color: HexColor('#DC2626'),
                                  ))),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                'Recycle Bin',
                                style: TextStyle(
                                    fontSize: 17 * ScaleUtils.scaleFactor,
                                    fontWeight: FontWeight.w500),
                              ),
                              Spacer(),
                              Icon(Icons.arrow_forward_ios_sharp,
                                  color: Colors.grey)
                            ],
                          ),
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
                      child: Card(
                        elevation: 10,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(18, 10, 18, 10),
                          child: Row(
                            children: [
                              Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: UniversalVariables.bgColor,
                                  ),
                                  height: 46,
                                  width: 46,
                                  child: Center(child: Icon(Icons.code))),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                'About Developer',
                                style: TextStyle(
                                    fontSize: 17 * ScaleUtils.scaleFactor,
                                    fontWeight: FontWeight.w500),
                              ),
                              Spacer(),
                              Icon(Icons.arrow_forward_ios_sharp,
                                  color: Colors.grey)
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
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
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Account Logging Out....")));
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
