import 'package:fitstrong_gym/src/custom_import.dart';

class DashBoard extends StatefulWidget {
  const DashBoard({Key? key});

  @override
  State<DashBoard> createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  void initState() {
    super.initState();
    final memberProvider = Provider.of<MemberProvider>(context, listen: false);
    final gymPlanProvider = Provider.of<GymPlanProvider>(context, listen: false);
    memberProvider.getAllMembers();
    gymPlanProvider.fetchPlans(); // Fetch plans
    memberProvider.fetchActiveMembers();
    memberProvider.fetchExpiredMembers();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.refreshUser();
  }

  @override
  Widget build(BuildContext context) {
    ScaleUtils.init(context);
    final memberProvider = Provider.of<MemberProvider>(context);
    final gymPlanProvider = Provider.of<GymPlanProvider>(context);
    final members = memberProvider.members;
    final plans = gymPlanProvider.plans;
    // final active = memberProvider.fetchActiveMembers();
    final activemembers = memberProvider.activeMembers;
    final expiredmembers = memberProvider.expiredMembers;
    UserProvider userProvider = Provider.of<UserProvider>(context);
    UserModel? userModel = userProvider.getUser;
    AuthMethods authMethods = AuthMethods();
    ScaleUtils.init(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          userModel?.name ?? 'Gym',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: UniversalVariables.appThemeColor,
        elevation: 10,
        // leading: IconButton(
        //   icon: Icon(Icons.nat,color: Colors.white,),
        //   onPressed: (){
        //     Navigator.push(context, MaterialPageRoute(builder: (context)=>AttendancePage()));
        //   },
        // ),
      ),
      body: Stack(children: [
        Image.asset(
          'assets/home3.jpg',
          height: ScaleUtils.height,
          width: ScaleUtils.width,
          fit: BoxFit.cover,
        ),
        ListView(
          children: [
            SizedBox(
              height: 220 * ScaleUtils.verticalScale,
            ),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(20*ScaleUtils.horizontalScale, 10*ScaleUtils.verticalScale, 10*ScaleUtils.horizontalScale, 10*ScaleUtils.verticalScale),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => DisplayAllMembers()),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: HexColor('FD8024'),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          height: 150 * ScaleUtils.verticalScale,
                          width: 150 * ScaleUtils.horizontalScale,
                          child: Center(
                              child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Total Members',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 14*ScaleUtils.scaleFactor),
                              ),
                              Text(
                                '${members.length}',
                                style: TextStyle(
                                    fontSize: 38*ScaleUtils.scaleFactor, color: Colors.white),
                              ),
                            ],
                          )),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(20*ScaleUtils.horizontalScale, 10*ScaleUtils.verticalScale, 10*ScaleUtils.horizontalScale, 10*ScaleUtils.verticalScale),
                      child: InkWell(
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context)=>GymPlansPage()));
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: HexColor('007FFF'),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          height: 150 * ScaleUtils.verticalScale,
                          width: 150 * ScaleUtils.horizontalScale,
                          child: Center(
                              child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Gym Plans',
                                style:
                                    TextStyle(color: Colors.white, fontSize: 14*ScaleUtils.scaleFactor),
                              ),
                              Text(
                                '${plans.length}',
                                style:
                                    TextStyle(fontSize: 40*ScaleUtils.scaleFactor, color: Colors.white),
                              ),
                            ],
                          )),
                        ),
                      ),
                    )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>ActiveMembersPage()));
                      },
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(20*ScaleUtils.horizontalScale, 10*ScaleUtils.verticalScale, 10*ScaleUtils.horizontalScale, 10*ScaleUtils.verticalScale),
                        child: Container(
                          decoration: BoxDecoration(
                            color: HexColor('2BC155'),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          height: 150 * ScaleUtils.verticalScale,
                          width: 150 * ScaleUtils.horizontalScale,
                          child: Center(
                              child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Active Members',
                                style:
                                    TextStyle(color: Colors.white, fontSize: 14*ScaleUtils.scaleFactor),
                              ),
                              Text(
                                '${activemembers.length}',
                                style:
                                    TextStyle(fontSize: 38*ScaleUtils.scaleFactor, color: Colors.white),
                              ),
                            ],
                          )),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>ExpiredMembersPage()));
                      },
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(20*ScaleUtils.horizontalScale, 10*ScaleUtils.verticalScale, 10*ScaleUtils.horizontalScale, 10*ScaleUtils.verticalScale),
                        child: Container(
                          decoration: BoxDecoration(
                            color: HexColor('FF0000'),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          height: 150 * ScaleUtils.verticalScale,
                          width: 150 * ScaleUtils.horizontalScale,
                          child: Center(
                              child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Expired Members',
                                style:
                                    TextStyle(color: Colors.white, fontSize: 14*ScaleUtils.scaleFactor),
                              ),
                              Text(
                                '${expiredmembers.length}',
                                style:
                                    TextStyle(fontSize: 38*ScaleUtils.scaleFactor, color: Colors.white),
                              ),
                            ],
                          )),
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ],
        ),
      ]),
    );
  }
}
