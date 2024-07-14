import 'package:fitstrong_gym/src/custom_import.dart';

class GymPlansPage extends StatefulWidget {
  @override
  State<GymPlansPage> createState() => _GymPlansPageState();
}

class _GymPlansPageState extends State<GymPlansPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final gymPlanProvider =
        Provider.of<GymPlanProvider>(context, listen: false);
    gymPlanProvider.fetchPlans();
  }

  @override
  Widget build(BuildContext context) {
    ScaleUtils.init(context);
    final gymPlanProvider = Provider.of<GymPlanProvider>(context);
    final plans = gymPlanProvider.plans;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Gym Plans',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(
          color: Colors.white, //change your color here
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.popAndPushNamed(context, '/home');
          },
          icon: Icon(Icons.arrow_back_outlined),
        ),
        actions: [
          InkWell(
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=>AddGymPlanPage()));
            },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                            'Add',
                            style: TextStyle(
                  color: Colors.white, fontSize: 18*ScaleUtils.scaleFactor, fontWeight: FontWeight.w500),
                          ),
              ))
        ],
        backgroundColor: UniversalVariables.appThemeColor,
      ),
      body: (plans.length==0)?PlansQuietBox():ListView.builder(
        itemCount: plans.length,
        itemBuilder: (context, index) {
          GymPlanModel plan = plans[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            child: Card(
              elevation: 14,
              child: Container(
                margin: EdgeInsets.all(20*ScaleUtils.scaleFactor),
                // height: 200,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          height: 80*ScaleUtils.verticalScale,
                          width: 80*ScaleUtils.horizontalScale,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: HexColor('F7EF8A'),
                              gradient: (plan.months == 1)
                                  ? LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        // HexColor('a67c00'),
                                        HexColor('cccccc'),
                                        HexColor('c7c7c7'),
                                        HexColor('ffffff'),
                                        HexColor('bdbdbd'),
                                        HexColor('b1b1b1')
                                      ],
                                    )
                                  : (plan.months == 6)
                                      ? LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            // HexColor('a67c00'),
                                            HexColor('dd0909'),
                                            HexColor('df4242'),
                                            HexColor('df6464'),
                                            HexColor('e38c8c'),
                                            HexColor('f4bebe ')
                                          ],
                                        )
                                      : (plan.months == 12)
                                          ? LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: [
                                                // HexColor('a67c00'),
                                                HexColor('facfd9'),
                                                HexColor('f7a1bc'),
                                                HexColor('fe1381'),
                                                HexColor('8e1f62'),
                                                HexColor('e6e1e5')
                                              ],
                                            )
                                          : LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: [
                                                // HexColor('a67c00'),
                                                HexColor('bf9b30'),
                                                HexColor('ffbf00'),
                                                HexColor('ffcf40'),
                                                HexColor('ffdc73'),
                                                HexColor('fff0cc')
                                              ],
                                            )),
                          child: Center(child: FaIcon(FontAwesomeIcons.crown)),
                        ),
                        SizedBox(
                          width: 20*ScaleUtils.horizontalScale,
                        ),
                        Text(
                          plan.name,
                          style: TextStyle(
                              fontSize: 18*ScaleUtils.scaleFactor, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Description:',
                                  style: TextStyle(
                                      fontSize: 16*ScaleUtils.scaleFactor,
                                      fontWeight: FontWeight.w500),
                                ),
                                SizedBox(
                                  width: 10*ScaleUtils.horizontalScale,
                                ),
                                Text(
                                  '${plan.months} months',
                                  style: TextStyle(
                                      fontSize: 14*ScaleUtils.scaleFactor,
                                      fontWeight: FontWeight.w400),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  'Price:',
                                  style: TextStyle(
                                      fontSize: 16*ScaleUtils.scaleFactor,
                                      fontWeight: FontWeight.w500),
                                ),
                                SizedBox(
                                  width: 10*ScaleUtils.verticalScale,
                                ),
                                Text(
                                  '\₹${plan.fee}',
                                  style: TextStyle(
                                      fontSize: 14*ScaleUtils.scaleFactor,
                                      fontWeight: FontWeight.w400),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Spacer(),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditPlanPage(plan: plan),
                              ),
                            );
                          },
                          child: Container(
                            width: 100*ScaleUtils.verticalScale,
                            height: 40*ScaleUtils.horizontalScale,
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Edit',
                                  style: TextStyle(
                                      fontSize: 16*ScaleUtils.scaleFactor, color: Colors.white),
                                ),
                                SizedBox(
                                  width: 10*ScaleUtils.horizontalScale,
                                ),
                                Icon(
                                  Icons.edit,
                                  size: 18*ScaleUtils.scaleFactor,
                                  color: Colors.white,
                                )
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 20*ScaleUtils.scaleFactor,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 10,
        backgroundColor: UniversalVariables.appThemeColor,
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => AddGymPlanPage()));
        },
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}
