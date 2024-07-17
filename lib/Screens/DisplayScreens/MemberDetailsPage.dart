


import 'package:fitstrong_gym/Widgets/CachedImage.dart';
import 'package:fitstrong_gym/src/custom_import.dart';
import 'package:intl/intl.dart';

class MemberDetailsPage extends StatelessWidget {
  final MemberModel member;

  const MemberDetailsPage({required this.member, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ScaleUtils.init(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: UniversalVariables.appThemeColor,
        iconTheme: IconThemeData(
          color: Colors.white, //change your color here
        ),
        title: Text('Member Details',style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding:  EdgeInsets.all(16.0*ScaleUtils.scaleFactor),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: GestureDetector(
                  onTap: (){
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) {
                          return FullImageWidget(
                            imageUrl: member.photoUrl,
                          );
                        }));
                  },
                  child:  CachedImage(
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
              SizedBox(height: 10*ScaleUtils.verticalScale,),
              Padding(
                padding: EdgeInsets.all(8.0*ScaleUtils.scaleFactor),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    InkWell(
                      onTap: () {
                        String message = "Hi ${member.name}! Your membership plan has been expired on ${DateFormat('dd-MM-yyyy').format(member.expiryDate)}.  We invite you to renew your membership to continue enjoying our gym facilities.\n Best Regards,\n Arjuna Fitness Gym";
                        _sendSMS(message, [member.mobileNumber]);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20*ScaleUtils.scaleFactor),
                          color: HexColor("3957ED"),
                        ),
                        child: Padding(
                          padding:  EdgeInsets.all(12.0*ScaleUtils.scaleFactor),
                          child: Row(
                            children:  [
                              Text(
                                "Message",
                                style: TextStyle(fontSize:16*ScaleUtils.scaleFactor,color: Colors.white),
                              ),
                              SizedBox(width: 8*ScaleUtils.horizontalScale,),
                              Icon(Icons.message,color: Colors.white,)
                            ],
                          ),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () async{
                        final Uri callUrl = Uri(
                          scheme: 'tel',
                          path: '${member.mobileNumber}',
                        );
                        try{
                          await launchUrl(callUrl);
                        }catch(e){
                          print(e.toString());
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20*ScaleUtils.scaleFactor),
                          color: HexColor("3957ED"),
                        ),
                        child: Padding(
                          padding:  EdgeInsets.all(12.0*ScaleUtils.scaleFactor),
                          child:  Row(
                            children:  [
                              Text(
                                "Call",
                                style: TextStyle(fontSize:16*ScaleUtils.scaleFactor,color: Colors.white),
                              ),
                              SizedBox(width: 8*ScaleUtils.horizontalScale,),
                              Icon(Icons.call,color: Colors.white,)
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10*ScaleUtils.verticalScale,),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  elevation: 10,
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30*ScaleUtils.scaleFactor),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: Offset(0, 3), // changes position of shadow
                          ),
                        ]),
                    child: Padding(
                      padding:  EdgeInsets.all(18.0*ScaleUtils.scaleFactor),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "Name",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18*ScaleUtils.scaleFactor),
                          ),
                          Text(
                            member.name,
                            style: TextStyle(fontSize: 16*ScaleUtils.scaleFactor),
                          ),
                          Divider(),
                          Text(
                            "Mobile Number",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18*ScaleUtils.scaleFactor),
                          ),
                          Text(
                            member.mobileNumber,
                            style: TextStyle(fontSize: 16*ScaleUtils.scaleFactor),
                          ),
                          Divider(),
                          Text(
                            "Height",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18*ScaleUtils.scaleFactor),
                          ),
                          Text(
                            member.height.toString(),
                            style: TextStyle(fontSize: 16*ScaleUtils.scaleFactor),
                          ),
                          Divider(),
                          Text(
                            "Weight",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18*ScaleUtils.scaleFactor),
                          ),
                          Text(
                            member.weight.toString(),
                            style: TextStyle(fontSize: 16*ScaleUtils.scaleFactor),
                          ),
                          Divider(),
                          Text(
                            "Address",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18*ScaleUtils.scaleFactor),
                          ),
                          Text(
                            member.address,
                            style: TextStyle(fontSize: 16*ScaleUtils.scaleFactor),
                          ),
                          Divider(),
                          Text(
                            "Gender",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18*ScaleUtils.scaleFactor),
                          ),
                          Text(
                            member.gender,
                            style: TextStyle(fontSize: 16*ScaleUtils.scaleFactor),
                          ),
                          Divider(),
                          Text(
                            "Date of Birth",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18*ScaleUtils.scaleFactor),
                          ),
                          Text(
                            '${DateFormat('dd-MM-yyyy').format(member.dateOfBirth)}',
                            style: TextStyle(fontSize: 16*ScaleUtils.scaleFactor),
                          ),
                          Divider(),
                          Text(
                            "Date of Admission",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18*ScaleUtils.scaleFactor),
                          ),
                          Text(
                            '${DateFormat('dd-MM-yyyy').format(member.dateOfAdmission)}',
                            style: TextStyle(fontSize: 16*ScaleUtils.scaleFactor),
                          ),
                          Divider(),
                          Text(
                            "Renewal Date",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18*ScaleUtils.scaleFactor),
                          ),
                          Text(
                            '${DateFormat('dd-MM-yyyy').format(member.renewalDate)}',
                            style: TextStyle(fontSize: 16*ScaleUtils.scaleFactor),
                          ),
                          Divider(),
                          Text(
                            "Check In Time",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18*ScaleUtils.scaleFactor),
                          ),
                          Text(
                            member.checkInTime.toString(),
                            style: TextStyle(fontSize: 16*ScaleUtils.scaleFactor),
                          ),
                          Divider(),
                          Text(
                            "CheckOutTime",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18*ScaleUtils.scaleFactor),
                          ),
                          Text(
                            member.checkOutTime.toString(),
                            style: TextStyle(fontSize: 16*ScaleUtils.scaleFactor),
                          ),
                          Divider(),
                          Text(
                            "Member Id",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18*ScaleUtils.scaleFactor),
                          ),
                          Text(
                            member.id,
                            style: TextStyle(fontSize: 16*ScaleUtils.scaleFactor),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Back'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _sendSMS(String message, List<String> recipents) async {
    String _result = await sendSMS(message: message, recipients: recipents)
        .catchError((onError) {
      print(onError);
          return 'Error';

    });
    print(_result);
  }
}
