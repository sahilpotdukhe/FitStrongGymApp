import 'dart:async';

import 'package:fitstrong_gym/src/custom_import.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool _isHidden = true;
  bool _isLoading = false;
  bool isVerified = false;
  bool isPressed = false;
  Timer? timer;
  final _signupKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController mobileController = TextEditingController();

  AuthMethods authMethods = AuthMethods();

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future checkEmailVerified(User user) async {
    await FirebaseAuth.instance.currentUser!.reload();
    setState(() {
      isVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    });

    if (isVerified) timer?.cancel();
    if (isVerified) {
      authMethods.setUserProfile(
        name: nameController.text,
        email: emailController.text,
        profilePic:
            'https://firebasestorage.googleapis.com/v0/b/echat-888ef.appspot.com/o/user.jpg?alt=media&token=6f598b3e-9c10-49ee-8a68-49468b32bddf',
        authType: 'emailAuth',
        mobilenumber: mobileController.text,
        qrImageUrl:
            'https://firebasestorage.googleapis.com/v0/b/fitstrong-gym.appspot.com/o/qrgeneral.png?alt=media&token=ffa3b5fe-ade2-4d7e-b675-bfdf2b281f5a',
        address: '',
        signature: '',
      );
      AwesomeDialog(
        context: context,
        animType: AnimType.leftSlide,
        headerAnimationLoop: true,
        dialogType: DialogType.success,
        showCloseIcon: true,
        //autoHide: Duration(seconds: 6),
        title: 'Verified!',
        desc:
            'You have successfully verified the account.\n Please wait you will be redirected to the HomePage.',
        btnOkOnPress: () {
          debugPrint('OnClcik');
        },
        btnOkIcon: Icons.check_circle,
        onDismissCallback: (type) {
          debugPrint('Dialog Dissmiss from callback $type');
        },
      ).show();
      // showToast('Account Created Successfully');
      await Future.delayed(Duration(seconds: 6));
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => CustomBottomNavigationBar()),
          (route) => false);
    } else {
      // setState(() {
      //   _auth.currentUser=null;
      // });
    }
  }

  void _togglePasswordView() {
    setState(() {
      _isHidden = !_isHidden;
    });
  }

  @override
  Widget build(BuildContext context) {
    ScaleUtils.init(context);
    return Scaffold(
      backgroundColor: UniversalVariables.appThemeColor,
      body: Stack(
        children: [
          ListView(
            shrinkWrap: true,
            children: [
              SizedBox(
                height: 267 * ScaleUtils.verticalScale,
                child: Row(
                  children: [
                    SizedBox(
                      width: 30 * ScaleUtils.horizontalScale,
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0 * ScaleUtils.scaleFactor),
                      child: Text(
                        "Create\nYour\nAccount",
                        style: TextStyle(
                            fontSize: 26 * ScaleUtils.scaleFactor,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    Spacer(),
                    Image.asset(
                      'assets/gymlog1.png',
                      width: 240 * ScaleUtils.horizontalScale,
                    )
                  ],
                ),
              ),
              Container(
                height: ScaleUtils.height - 267 * ScaleUtils.verticalScale,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(50 * ScaleUtils.scaleFactor),
                        topRight:
                            Radius.circular(50 * ScaleUtils.scaleFactor))),
                child: Form(
                  key: _signupKey,
                  child: Container(
                    margin: EdgeInsets.fromLTRB(
                        24 * ScaleUtils.horizontalScale,
                        24 * ScaleUtils.verticalScale,
                        24 * ScaleUtils.horizontalScale,
                        0),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(25 * ScaleUtils.scaleFactor)),
                    child: ListView(
                      padding: EdgeInsets.fromLTRB(
                          25 * ScaleUtils.horizontalScale,
                          10 * ScaleUtils.verticalScale,
                          24 * ScaleUtils.horizontalScale,
                          10 * ScaleUtils.verticalScale),
                      shrinkWrap: true,
                      children: [
                        TextFormField(
                          controller: nameController,
                          decoration: InputDecoration(
                              hintText: 'Enter Your Name',
                              hintStyle: TextStyle(
                                  fontSize: 14 * ScaleUtils.scaleFactor,
                                  color: UniversalVariables.appThemeColor),
                              labelText: 'Name',
                              floatingLabelStyle: TextStyle(
                                  fontSize: 18 * ScaleUtils.scaleFactor,
                                  fontWeight: FontWeight.w500,
                                  color: UniversalVariables.appThemeColor),
                              labelStyle: TextStyle(
                                fontSize: 16 * ScaleUtils.scaleFactor,
                              ),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: UniversalVariables.appThemeColor,
                                      width: 2)),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: UniversalVariables.appThemeColor,
                                    width: 2),
                              ),
                              suffixIcon: Icon(Icons.person,
                                  color: UniversalVariables.appThemeColor)),
                          keyboardType: TextInputType.name,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please Enter Name';
                            } else if (!RegExp(r'^[a-z A-Z]+$')
                                .hasMatch(value)) {
                              return 'Please enter a valid Name';
                            }
                            return null;
                          },
                        ),
                        SizedBox(
                          height: 12 * ScaleUtils.verticalScale,
                        ),
                        TextFormField(
                          controller: emailController,
                          decoration: InputDecoration(
                              hintText: 'Enter Your Email',
                              hintStyle: TextStyle(
                                  fontSize: 14 * ScaleUtils.scaleFactor,
                                  color: UniversalVariables.appThemeColor),
                              labelText: 'Email',
                              floatingLabelStyle: TextStyle(
                                  fontSize: 16 * ScaleUtils.scaleFactor,
                                  fontWeight: FontWeight.w500,
                                  color: UniversalVariables.appThemeColor),
                              labelStyle: TextStyle(
                                fontSize: 16 * ScaleUtils.scaleFactor,
                              ),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: UniversalVariables.appThemeColor,
                                      width: 2)),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: UniversalVariables.appThemeColor,
                                    width: 2),
                              ),
                              suffixIcon: Icon(Icons.email,
                                  color: UniversalVariables.appThemeColor)),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Enter email address';
                            } else if (!RegExp(
                                    r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?"
                                    r"(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$")
                                .hasMatch(value)) {
                              return 'Please enter a valid email address';
                            }
                            return null;
                          },
                        ),
                        SizedBox(
                          height: 12 * ScaleUtils.verticalScale,
                        ),
                        TextFormField(
                          controller: passwordController,
                          decoration: InputDecoration(
                              hintText: 'Set Password',
                              hintStyle: TextStyle(
                                  fontSize: 14 * ScaleUtils.scaleFactor,
                                  color: UniversalVariables.appThemeColor),
                              labelStyle: TextStyle(
                                fontSize: 16 * ScaleUtils.scaleFactor,
                              ),
                              labelText: 'Password',
                              floatingLabelStyle: TextStyle(
                                  fontSize: 16 * ScaleUtils.scaleFactor,
                                  fontWeight: FontWeight.w500,
                                  color: UniversalVariables.appThemeColor),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      width: 2,
                                      color: UniversalVariables.appThemeColor)),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: UniversalVariables.appThemeColor,
                                    width: 2),
                              ),
                              suffix: InkWell(
                                onTap: _togglePasswordView,
                                child: Icon(
                                    _isHidden
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: UniversalVariables.appThemeColor),
                              ),
                              errorMaxLines: 2),
                          obscureText: _isHidden,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Set the Password';
                            } else if (!RegExp(
                                    r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$')
                                .hasMatch(value)) {
                              return 'Password must have atleast one Uppercase, one Lowercase, one special character, and one numeric value';
                            }
                            return null;
                          },
                        ),
                        SizedBox(
                          height: 12 * ScaleUtils.verticalScale,
                        ),
                        TextFormField(
                          controller: mobileController,
                          decoration: InputDecoration(
                              hintText: 'Enter Your Number',
                              hintStyle: TextStyle(
                                  fontSize: 14 * ScaleUtils.scaleFactor,
                                  color: UniversalVariables.appThemeColor),
                              labelText: 'Phone Number',
                              floatingLabelStyle: TextStyle(
                                  fontSize: 16 * ScaleUtils.scaleFactor,
                                  fontWeight: FontWeight.w500,
                                  color: UniversalVariables.appThemeColor),
                              labelStyle: TextStyle(
                                fontSize: 16 * ScaleUtils.scaleFactor,
                              ),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: UniversalVariables.appThemeColor,
                                      width: 2)),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: UniversalVariables.appThemeColor,
                                    width: 2),
                              ),
                              suffixIcon: Icon(
                                Icons.phone,
                                color: UniversalVariables.appThemeColor,
                              ),
                              counterText: ""),
                          keyboardType: TextInputType.phone,
                          maxLength: 10,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please Enter Phone No';
                            } else if (!RegExp(
                                    r'^[+]*[(]{0,1}[0-9]{1,4}[)]{0,1}[-\s\./0-9]*$')
                                .hasMatch(value)) {
                              return 'Please enter a valid Phone Number';
                            } else if (value.length < 10) {
                              return 'Enter 10 digit Phone number';
                            }
                            return null;
                          },
                        ),
                        SizedBox(
                          height: 18 * ScaleUtils.verticalScale,
                        ),
                        Center(
                          child: (_isLoading)
                              ? Loading()
                              : ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          UniversalVariables.appThemeColor),
                                  onPressed: () async {
                                    if (_signupKey.currentState!.validate()) {
                                      setState(() {
                                        _isLoading = true;
                                      });
                                      authMethods
                                          .createAccountByEmail(
                                              emailController.text,
                                              passwordController.text,
                                              context)
                                          .then((user) async {
                                        if (user != null) {
                                          print(user);
                                          if (!isVerified) {
                                            showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  Future.delayed(
                                                      Duration(seconds: 13),
                                                      () {
                                                    Navigator.of(context)
                                                        .pop(true);
                                                  });
                                                  return AlertDialog(
                                                    title: Center(
                                                      child: Column(
                                                        children: [
                                                          Lottie.asset(
                                                              'assets/email.json',
                                                              height: 0.15 *
                                                                  ScaleUtils
                                                                      .verticalScale,
                                                              width: 0.5 *
                                                                  ScaleUtils
                                                                      .scaleFactor),
                                                          Text(
                                                            'Verify Your Email',
                                                            style: TextStyle(
                                                                color:
                                                                    Colors.red,
                                                                fontSize: 22 *
                                                                    ScaleUtils
                                                                        .scaleFactor,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    content: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Text(
                                                          'Verification link has been sent to ',
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(),
                                                        ),
                                                        Text(
                                                          emailController.text,
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        Text(
                                                          'Please check your inbox.Click the link in the email to confirm your email address.',
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                        SizedBox(
                                                          height: 10 *
                                                              ScaleUtils
                                                                  .verticalScale,
                                                        ),
                                                        Text(
                                                          'Didn\'t get the email?',
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        Text(
                                                          'Check entered email or check spam folder.',
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                });

                                            await user.sendEmailVerification();
                                            timer = Timer.periodic(
                                                Duration(seconds: 3),
                                                (_) =>
                                                    checkEmailVerified(user));
                                            print(FirebaseAuth.instance
                                                .currentUser!.displayName);
                                            setState(() {
                                              _isLoading = false;
                                            });
                                          }
                                        } else {
                                          setState(() {
                                            _isLoading = false;
                                          });
                                          showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                    title: Center(
                                                      child: Text(
                                                        'Account Creation Failed!',
                                                        style: TextStyle(
                                                            color: Colors.red,
                                                            fontSize: 22 *
                                                                ScaleUtils
                                                                    .scaleFactor,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ),
                                                    content: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Text(
                                                          'The email address ',
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                        Text(
                                                          '${emailController.text}',
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                        Text(
                                                          'is already in use by another account.',
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                      ],
                                                    ),
                                                    actions: [
                                                      Center(
                                                        child: ElevatedButton(
                                                          child: Text('Retry'),
                                                          onPressed: () {
                                                            Navigator.pop(
                                                                context, true);
                                                          },
                                                          style: ElevatedButton
                                                              .styleFrom(
                                                                  backgroundColor:
                                                                      Colors
                                                                          .red),
                                                        ),
                                                      )
                                                    ]);
                                              });
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                                  content: Text(
                                                      "Account Creation Failed")));
                                        }
                                      });
                                    }
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.fromLTRB(
                                        80 * ScaleUtils.horizontalScale,
                                        8 * ScaleUtils.verticalScale,
                                        80 * ScaleUtils.horizontalScale,
                                        8 * ScaleUtils.verticalScale),
                                    child: Text(
                                      'SIGN UP',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18 * ScaleUtils.scaleFactor,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ),
                        ),
                        SizedBox(
                          height: 14 * ScaleUtils.verticalScale,
                        ),
                        Column(
                          children: [
                            Text(
                              "Already have a account?",
                              style: TextStyle(
                                  fontSize: 15 * ScaleUtils.scaleFactor,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w500),
                            ),
                            MaterialButton(
                                child: Text(
                                  "Sign in",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18 * ScaleUtils.scaleFactor),
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                }),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
