import 'package:fitstrong_gym/Screens/BMICalculator.dart';
import 'package:fitstrong_gym/src/custom_import.dart';

class DashBoard extends StatefulWidget {
  const DashBoard({super.key});

  @override
  State<DashBoard> createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  FirebaseFirestore fireStore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  void _fetchInitialData() {
    final memberProvider = Provider.of<MemberProvider>(context, listen: false);
    final gymPlanProvider =
        Provider.of<GymPlanProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    memberProvider.getAllMembers();
    gymPlanProvider.fetchPlans();
    memberProvider.fetchActiveMembers();
    memberProvider.fetchExpiredMembers();
    userProvider.refreshUser();
  }

  @override
  Widget build(BuildContext context) {
    ScaleUtils.init(context);
    final memberProvider = Provider.of<MemberProvider>(context);
    final gymPlanProvider = Provider.of<GymPlanProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final members = memberProvider.members;
    final plans = gymPlanProvider.plans;
    final activeMembers = memberProvider.activeMembers;
    final expiredMembers = memberProvider.expiredMembers;
    UserModel? userModel = userProvider.getUser;
    return Scaffold(
      // extendBodyBehindAppBar: true,
      // appBar: AppBar(
      //   title: Text(
      //     'FitStrong Gym',
      //     style: TextStyle(color: Colors.grey[800]),
      //   ),
      //   elevation: 0,
      //   centerTitle: true,
      //   backgroundColor: Colors.white70,
      // ),
      body: Stack(children: [
        Image.asset(
          'assets/home3.jpg',
          height: ScaleUtils.height,
          width: ScaleUtils.width,
          fit: BoxFit.cover,
        ),
        ListView(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 14, 8, 0),
              child: Text(
                'Welcome back, ${userModel?.name}!',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 22),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
              child: Text(
                'Let\'s check your dashboard',
                style: TextStyle(color: Colors.grey.shade300, fontSize: 16),
              ),
            ),
            SizedBox(
              height: 240 * ScaleUtils.verticalScale,
            ),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                          20 * ScaleUtils.horizontalScale,
                          10 * ScaleUtils.verticalScale,
                          10 * ScaleUtils.horizontalScale,
                          10 * ScaleUtils.verticalScale),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MemberListPage()),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: const [
                                Colors.white, // Light grey
                                Colors.white70, // Darker grey
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          height: 130 * ScaleUtils.verticalScale,
                          width: 150 * ScaleUtils.horizontalScale,
                          child: Center(
                              child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/totalmembers.png',
                                height: 40 * ScaleUtils.verticalScale,
                                width: 40 * ScaleUtils.horizontalScale,
                              ),
                              Text(
                                'Total Members',
                                style: TextStyle(
                                    color: Colors.grey[800],
                                    fontSize: 14 * ScaleUtils.scaleFactor),
                              ),
                              Text(
                                '${members.length}',
                                style: TextStyle(
                                    fontSize: 20 * ScaleUtils.scaleFactor,
                                    color: Colors.black),
                              ),
                            ],
                          )),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                          20 * ScaleUtils.horizontalScale,
                          10 * ScaleUtils.verticalScale,
                          10 * ScaleUtils.horizontalScale,
                          10 * ScaleUtils.verticalScale),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => GymPlansPage()));
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: const [
                                Colors.white, // Light grey
                                Colors.white70, // Darker grey
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          // decoration: BoxDecoration(
                          //   color: Colors.white,
                          // ),
                          height: 130 * ScaleUtils.verticalScale,
                          width: 150 * ScaleUtils.horizontalScale,
                          child: Center(
                              child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/plan.png',
                                height: 40 * ScaleUtils.verticalScale,
                                width: 40 * ScaleUtils.horizontalScale,
                              ),
                              Text(
                                'Gym Plans',
                                style: TextStyle(
                                    color: Colors.grey[800],
                                    fontSize: 14 * ScaleUtils.scaleFactor),
                              ),
                              Text(
                                '${plans.length}',
                                style: TextStyle(
                                  fontSize: 20 * ScaleUtils.scaleFactor,
                                ),
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
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ActiveMembersPage()));
                      },
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                            20 * ScaleUtils.horizontalScale,
                            10 * ScaleUtils.verticalScale,
                            10 * ScaleUtils.horizontalScale,
                            10 * ScaleUtils.verticalScale),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: const [
                                Colors.white, // Light grey
                                Colors.white70, // Darker grey
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          height: 130 * ScaleUtils.verticalScale,
                          width: 150 * ScaleUtils.horizontalScale,
                          child: Center(
                              child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/active.png',
                                height: 40 * ScaleUtils.verticalScale,
                                width: 40 * ScaleUtils.horizontalScale,
                              ),
                              Text(
                                'Active Members',
                                style: TextStyle(
                                    color: Colors.grey[800],
                                    fontSize: 14 * ScaleUtils.scaleFactor),
                              ),
                              Text(
                                '${activeMembers.length}',
                                style: TextStyle(
                                  fontSize: 20 * ScaleUtils.scaleFactor,
                                ),
                              ),
                            ],
                          )),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ExpiredMembersPage()));
                      },
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                            20 * ScaleUtils.horizontalScale,
                            10 * ScaleUtils.verticalScale,
                            10 * ScaleUtils.horizontalScale,
                            10 * ScaleUtils.verticalScale),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: const [
                                Colors.white, // Light grey
                                Colors.white70, // Darker grey
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          height: 130 * ScaleUtils.verticalScale,
                          width: 150 * ScaleUtils.horizontalScale,
                          child: Center(
                              child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/expired.png',
                                height: 40 * ScaleUtils.verticalScale,
                                width: 40 * ScaleUtils.horizontalScale,
                              ),
                              Text(
                                'Expired Members',
                                style: TextStyle(
                                    color: Colors.grey[800],
                                    fontSize: 14 * ScaleUtils.scaleFactor),
                              ),
                              Text(
                                '${expiredMembers.length}',
                                style: TextStyle(
                                  fontSize: 20 * ScaleUtils.scaleFactor,
                                ),
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
            Padding(
              padding: const EdgeInsets.all(28.0),
              child: InkWell(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => BMICalculator()));
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
                          "BMI Calculator",
                          style: TextStyle(
                              fontSize: 16 * ScaleUtils.scaleFactor,
                              color: Colors.white),
                        ),
                        SizedBox(
                          width: 8 * ScaleUtils.horizontalScale,
                        ),
                        Icon(
                          Icons.fitness_center,
                          color: Colors.white,
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ]),
    );
  }
}
