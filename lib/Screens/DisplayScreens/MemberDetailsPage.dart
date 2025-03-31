import 'package:fitstrong_gym/Widgets/CachedImage.dart';
import 'package:fitstrong_gym/src/custom_import.dart';
import 'package:intl/intl.dart';
import 'package:telephony_sms/telephony_sms.dart';

final TelephonySMS _telephonySMS = TelephonySMS();

class MemberDetailsPage extends StatelessWidget {
  final MemberModel member;

  const MemberDetailsPage({required this.member, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    UserProvider userProvider = Provider.of<UserProvider>(context);
    UserModel? userModel = userProvider.getUser;
    ScaleUtils.init(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: UniversalVariables.appThemeColor,
        iconTheme: IconThemeData(
          color: Colors.white, //change your color here
        ),
        title: Text('Member Details', style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0 * ScaleUtils.scaleFactor),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) {
                      return FullImageWidget(
                        imageUrl: member.photoUrl,
                      );
                    }));
                  },
                  child: CachedImage(
                      imageUrl: member.photoUrl,
                      isRound: true,
                      radius: 120,
                      height: 0,
                      width: 0,
                      fit: BoxFit.cover),
                  // CircleAvatar(
                  //   radius: 70,
                  //   backgroundImage:AssetImage('assets/user.jpg'),
                  //   foregroundImage: NetworkImage(
                  //     member.photoUrl.isNotEmpty
                  //         ? member.photoUrl
                  //         : 'https://icons.veryicon.com/png/o/miscellaneous/administration/person-16.png',
                  //   ),
                  // ),
                ),
              ),
              SizedBox(
                height: 10 * ScaleUtils.verticalScale,
              ),
              Padding(
                padding: EdgeInsets.all(8.0 * ScaleUtils.scaleFactor),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          String message =
                              "Hi ${member.name}! Your membership plan has been expired on ${DateFormat('dd-MM-yyyy').format(member.expiryDate)}.  We invite you to renew your membership to continue enjoying our gym facilities.\n Best Regards,\n Arjuna Fitness Gym";
                          sendSMS(
                              member.mobileNumber, message, userModel!.name);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                                14 * ScaleUtils.scaleFactor),
                            color: HexColor("3957ED"),
                          ),
                          child: Padding(
                            padding:
                                EdgeInsets.all(12.0 * ScaleUtils.scaleFactor),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.message,
                                  color: Colors.white,
                                ),
                                SizedBox(
                                  width: 8 * ScaleUtils.horizontalScale,
                                ),
                                Text(
                                  "Message",
                                  style: TextStyle(
                                      fontSize: 16 * ScaleUtils.scaleFactor,
                                      color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          openWhatsapp(
                              context, member.mobileNumber, userModel!.name);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                                14 * ScaleUtils.scaleFactor),
                            color: HexColor("3957ED"),
                          ),
                          child: Padding(
                            padding:
                                EdgeInsets.all(12.0 * ScaleUtils.scaleFactor),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  FontAwesomeIcons.whatsapp,
                                  color: Colors.white,
                                ),
                                SizedBox(
                                  width: 8 * ScaleUtils.horizontalScale,
                                ),
                                Text(
                                  "WhatsApp",
                                  style: TextStyle(
                                      fontSize: 16 * ScaleUtils.scaleFactor,
                                      color: Colors.white),
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
              InkWell(
                onTap: () async {
                  final Uri callUrl = Uri(
                    scheme: 'tel',
                    path: member.mobileNumber,
                  );
                  try {
                    await launchUrl(callUrl);
                  } catch (e) {
                    print(e.toString());
                  }
                },
                child: Center(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(14 * ScaleUtils.scaleFactor),
                      color: HexColor("3957ED"),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: 12.0 * ScaleUtils.scaleFactor,
                          horizontal: 18 * ScaleUtils.scaleFactor),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.call,
                            color: Colors.white,
                          ),
                          SizedBox(
                            width: 8 * ScaleUtils.horizontalScale,
                          ),
                          Text(
                            "Call",
                            style: TextStyle(
                                fontSize: 16 * ScaleUtils.scaleFactor,
                                color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 10 * ScaleUtils.verticalScale,
              ),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(30 * ScaleUtils.scaleFactor),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(18.0 * ScaleUtils.scaleFactor),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Full Name",
                          style: TextStyle(
                              color: Colors.grey,
                              fontSize: 16 * ScaleUtils.scaleFactor),
                        ),
                        Text(
                          member.name,
                          style:
                              TextStyle(fontSize: 15 * ScaleUtils.scaleFactor),
                        ),
                        Divider(),
                        Text(
                          "Mobile Number",
                          style: TextStyle(
                              color: Colors.grey,
                              fontSize: 16 * ScaleUtils.scaleFactor),
                        ),
                        Text(
                          member.mobileNumber,
                          style:
                              TextStyle(fontSize: 15 * ScaleUtils.scaleFactor),
                        ),
                        Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Height(in feet)",
                                    style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 16 * ScaleUtils.scaleFactor),
                                  ),
                                  Text(
                                    member.height.toString(),
                                    style: TextStyle(
                                        fontSize: 15 * ScaleUtils.scaleFactor),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Weight(in kg)",
                                    style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 16 * ScaleUtils.scaleFactor),
                                  ),
                                  Text(
                                    member.weight.toString(),
                                    style: TextStyle(
                                        fontSize: 15 * ScaleUtils.scaleFactor),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Divider(),
                        Text(
                          "Address",
                          style: TextStyle(
                              color: Colors.grey,
                              fontSize: 16 * ScaleUtils.scaleFactor),
                        ),
                        Text(
                          member.address,
                          style:
                              TextStyle(fontSize: 15 * ScaleUtils.scaleFactor),
                        ),
                        Divider(),
                        Text(
                          "Gender",
                          style: TextStyle(
                              color: Colors.grey,
                              fontSize: 16 * ScaleUtils.scaleFactor),
                        ),
                        Text(
                          member.gender,
                          style:
                              TextStyle(fontSize: 15 * ScaleUtils.scaleFactor),
                        ),
                        Divider(),
                        Text(
                          "Date of Birth",
                          style: TextStyle(
                              color: Colors.grey,
                              fontSize: 16 * ScaleUtils.scaleFactor),
                        ),
                        Text(
                          DateFormat('d MMM, yyyy').format(member.dateOfBirth),
                          style:
                              TextStyle(fontSize: 15 * ScaleUtils.scaleFactor),
                        ),
                        Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Admission Date",
                                    style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 16 * ScaleUtils.scaleFactor),
                                  ),
                                  Text(
                                    DateFormat('d MMM, yyyy')
                                        .format(member.dateOfAdmission),
                                    style: TextStyle(
                                        fontSize: 15 * ScaleUtils.scaleFactor),
                                  ),
                                ],
                              ),
                            ),
                            Divider(),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Renewal Date",
                                    style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 16 * ScaleUtils.scaleFactor),
                                  ),
                                  Text(
                                    DateFormat('d MMM, yyyy')
                                        .format(member.renewalDate),
                                    style: TextStyle(
                                        fontSize: 15 * ScaleUtils.scaleFactor),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Check In Time",
                                    style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 16 * ScaleUtils.scaleFactor),
                                  ),
                                  Text(
                                    member.checkInTime.toString(),
                                    style: TextStyle(
                                        fontSize: 15 * ScaleUtils.scaleFactor),
                                  ),
                                ],
                              ),
                            ),
                            Divider(),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "CheckOutTime",
                                    style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 16 * ScaleUtils.scaleFactor),
                                  ),
                                  Text(
                                    member.checkOutTime.toString(),
                                    style: TextStyle(
                                        fontSize: 15 * ScaleUtils.scaleFactor),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // void _sendSMS(String message, List<String> recipents) async {
  //   // String _result = await sendSMS(message: message, recipients: recipents)
  //   //     .catchError((onError) {
  //   //   print(onError);
  //   //       return 'Error';
  //   //
  //   // });
  //   // print(_result);
  // }

  // void openWhatsApp(String phoneNumber, String gymName) async {
  //   var message =
  //       "Hi ${member.name}! Your membership plan has been expired on ${DateFormat('dd-MM-yyyy').format(member.expiryDate)}. We invite you to renew your membership to continue enjoying our gym facilities.Thanks ${gymName}";
  //   final Uri whatsappUri =
  //       Uri.parse("https://wa.me/$phoneNumber?text=${Uri.encodeFull(message)}");
  //
  //   if (await canLaunchUrl(whatsappUri)) {
  //     await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
  //   } else {
  //     print("Could not open WhatsApp");
  //   }
  // }

  void openWhatsapp(
      BuildContext context, String phoneNumber, String gymName) async {
    var whatsapp = phoneNumber; //+92xx enter like this
    var message =
        "Hi ${member.name}! Your membership plan has been expired on ${DateFormat('dd-MM-yyyy').format(member.expiryDate)}. We invite you to renew your membership to continue enjoying our gym facilities.Thanks ${gymName}";
    var whatsappURlAndroid =
        "whatsapp://send?phone=" + whatsapp + "&text=$message";
    var whatsappURLIos =
        "https://wa.me/$whatsapp?text=${Uri.tryParse(message)}";
    if (Platform.isIOS) {
      // for iOS phone only
      if (await canLaunchUrl(Uri.parse(whatsappURLIos))) {
        await launchUrl(Uri.parse(
          whatsappURLIos,
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Whatsapp not installed")));
      }
    } else {
      // android , web
      if (await canLaunchUrl(Uri.parse(whatsappURlAndroid))) {
        await launchUrl(Uri.parse(whatsappURlAndroid));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Whatsapp not installed")));
      }
    }
  }

  Future<void> sendSMS(
      String phoneNumber, String message, String gymName) async {
    // String encodedMessage = Uri.encodeComponent(message);

    print("Sending SMS to: $phoneNumber");
    // print("Message: $encodedMessage");
    // String message =
    //     ;
    await _telephonySMS.requestPermission();
    print("Name" + gymName);
    try {
      await _telephonySMS.sendSMS(
          phone: phoneNumber.toString(),
          message:
              "Hi ${member.name}, your gym membership plan has been expired on ${DateFormat('dd-MM-yyyy').format(member.expiryDate)}. Renew now to keep enjoying our facilities. - $gymName");
      print("SMS sent successfully to $phoneNumber");
    } catch (e) {
      print("SMS error: " + e.toString());
    }
  }
}
