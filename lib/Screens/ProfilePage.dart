import 'package:fitstrong_gym/src/custom_import.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  AuthMethods authMethods = AuthMethods();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.refreshUser();
  }

  @override
  Widget build(BuildContext context) {
    ScaleUtils.init(context);
    UserProvider userProvider = Provider.of<UserProvider>(context);
    UserModel? userModel = userProvider.getUser;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: UniversalVariables.appThemeColor,
        iconTheme: IconThemeData(
          color: Colors.white, //change your color here
        ),
        title: Text('Profile', style: TextStyle(color: Colors.white)),
      ),
      backgroundColor: Colors.white,
      body: userModel == null
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Container(
                child: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 70 * ScaleUtils.verticalScale),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (_) {
                            return FullImageWidget(
                              imageUrl: userModel!.profilePhoto,
                            );
                          }));
                        },
                        child: CircleAvatar(
                          radius: 65 * ScaleUtils.scaleFactor,
                          child: CircleAvatar(
                            radius: 60 * ScaleUtils.scaleFactor,
                            backgroundColor: Colors.transparent,
                            backgroundImage: AssetImage('assets/user.jpg'),
                            foregroundImage:
                                NetworkImage(userModel!.profilePhoto),
                          ),
                        ),
                      ),

                      SizedBox(
                        height: 10 * ScaleUtils.verticalScale,
                      ),
                      Text(
                        userModel.name,
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 25 * ScaleUtils.scaleFactor,
                            fontWeight: FontWeight.bold),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding:
                                EdgeInsets.all(8.0 * ScaleUtils.scaleFactor),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                EditProfilePage(
                                                    userModel: userModel)));
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                          20 * ScaleUtils.scaleFactor),
                                      color: HexColor("3957ED"),
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.all(
                                          12.0 * ScaleUtils.scaleFactor),
                                      child: Row(
                                        children: [
                                          Text(
                                            "Edit Profile",
                                            style: TextStyle(
                                                fontSize:
                                                    14 * ScaleUtils.scaleFactor,
                                                color: Colors.white),
                                          ),
                                          SizedBox(
                                            width: 8 * ScaleUtils.verticalScale,
                                          ),
                                          Icon(
                                            Icons.edit,
                                            color: Colors.white,
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              authMethods.logOut(context);
                              // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {return NewLoginScreen();}));
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content:
                                          Text("Account Logging Out....")));
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                    20 * ScaleUtils.scaleFactor),
                                color: HexColor("EE3427"),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(
                                    12.0 * ScaleUtils.scaleFactor),
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
                        ],
                      ),
                      // SizedBox(
                      //   height: 20*ScaleUtils.verticalScale,
                      // ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 10 * ScaleUtils.horizontalScale,
                            vertical: 20 * ScaleUtils.verticalScale),
                        child: Card(
                          elevation: 10,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(
                                  18 * ScaleUtils.scaleFactor),
                            ),
                            child: Padding(
                              padding:
                                  EdgeInsets.all(18.0 * ScaleUtils.scaleFactor),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Name",
                                    style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 16 * ScaleUtils.scaleFactor),
                                  ),
                                  Text(
                                    userModel.name,
                                    style: TextStyle(
                                        fontSize: 15 * ScaleUtils.scaleFactor),
                                  ),
                                  Divider(),
                                  Text(
                                    "Email",
                                    style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 16 * ScaleUtils.scaleFactor),
                                  ),
                                  Text(
                                    userModel.email,
                                    style: TextStyle(
                                        fontSize: 15 * ScaleUtils.scaleFactor),
                                  ),
                                  (userModel.merchantName == '')
                                      ? Container()
                                      : Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Divider(),
                                            Text(
                                              "Merchant Name(Payment)",
                                              style: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 16 *
                                                      ScaleUtils.scaleFactor),
                                            ),
                                            Text(
                                              userModel.merchantName,
                                              style: TextStyle(
                                                  fontSize: 15 *
                                                      ScaleUtils.scaleFactor),
                                            ),
                                          ],
                                        ),
                                  (userModel.upiId == '')
                                      ? Container()
                                      : Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Divider(),
                                            Text(
                                              "UPI Id",
                                              style: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 16 *
                                                      ScaleUtils.scaleFactor),
                                            ),
                                            Text(
                                              userModel.upiId,
                                              style: TextStyle(
                                                  fontSize: 15 *
                                                      ScaleUtils.scaleFactor),
                                            ),
                                          ],
                                        ),
                                  (userModel.phoneNumber == '')
                                      ? Container()
                                      : Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Divider(),
                                            Text(
                                              "Phone number",
                                              style: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 16 *
                                                      ScaleUtils.scaleFactor),
                                            ),
                                            Text(
                                              userModel.phoneNumber,
                                              style: TextStyle(
                                                  fontSize: 15 *
                                                      ScaleUtils.scaleFactor),
                                            ),
                                          ],
                                        ),
                                  (userModel.address == '')
                                      ? Container()
                                      : Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Divider(),
                                            Text(
                                              "Address",
                                              style: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 16 *
                                                      ScaleUtils.scaleFactor),
                                            ),
                                            Text(
                                              userModel.address,
                                              style: TextStyle(
                                                  fontSize: 15 *
                                                      ScaleUtils.scaleFactor),
                                            ),
                                          ],
                                        ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
