

import 'package:fitstrong_gym/src/custom_import.dart';
import 'package:intl/intl.dart';

class RecycleMemberCard extends StatefulWidget {
  final MemberModel recycleBinMember;

  const RecycleMemberCard({super.key, required this.recycleBinMember});

  @override
  State<RecycleMemberCard> createState() => _RecycleMemberCardState();
}

class _RecycleMemberCardState extends State<RecycleMemberCard> {
  @override
  Widget build(BuildContext context) {
    final plans = Provider.of<GymPlanProvider>(context, listen: false).plans;
    final plan = GymPlanModel.findById(plans, widget.recycleBinMember.planId);
    final planName = plan?.name ?? 'Unknown Plan';
    ScaleUtils.init(context);
    return Padding(
      padding:  EdgeInsets.all(8.0*ScaleUtils.scaleFactor),
      child: Card(
        elevation: 15,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30*ScaleUtils.scaleFactor),
            color: Colors.black,
          ),
          child: Padding(
            padding:  EdgeInsets.all(8.0*ScaleUtils.scaleFactor),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(8.0*ScaleUtils.scaleFactor),
                      child: Container(
                        height: 80*ScaleUtils.verticalScale,
                        width: 80*ScaleUtils.horizontalScale,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                              image: CachedNetworkImageProvider(
                                  widget.recycleBinMember.photoUrl),
                              fit: BoxFit.cover),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 40*ScaleUtils.horizontalScale,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Name: ',
                              style: TextStyle(color: Colors.grey,fontSize: 13*ScaleUtils.scaleFactor),
                            ),
                            Text(widget.recycleBinMember.name,style: TextStyle(color: Colors.white,fontSize: 13*ScaleUtils.scaleFactor),),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              'Address: ',
                              style: TextStyle(color: Colors.grey,fontSize: 13*ScaleUtils.scaleFactor),
                            ),
                            Text(widget.recycleBinMember.address,style: TextStyle(color: Colors.white,fontSize: 13*ScaleUtils.scaleFactor),),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              'Gender: ',
                              style: TextStyle(color: Colors.grey,fontSize: 13*ScaleUtils.scaleFactor),
                            ),
                            Text(widget.recycleBinMember.gender,style: TextStyle(color: Colors.white,fontSize: 13*ScaleUtils.scaleFactor),),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              'Mobile: ',
                              style: TextStyle(color: Colors.grey,fontSize: 13*ScaleUtils.scaleFactor),
                            ),
                            Text(widget.recycleBinMember.mobileNumber,style: TextStyle(color: Colors.white,fontSize: 13*ScaleUtils.scaleFactor),),
                          ],
                        ),
                      ],
                    ),
                    Spacer(),
                    IconButton(
                      icon: Icon(
                        Icons.restore,
                        size: 30,
                      ),
                      color: Colors.red,
                      onPressed: () async {
                        _showConfirmationDialog(context, widget.recycleBinMember);
                      },
                    ),
                    SizedBox(
                      width: 20,
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Date of Birth: ',
                              style: TextStyle(color: Colors.grey,fontSize: 13*ScaleUtils.scaleFactor),
                            ),
                            Text(
                              '${DateFormat('dd-MM-yyyy').format(widget.recycleBinMember.dateOfBirth)}',style: TextStyle(color: Colors.white,fontSize: 13*ScaleUtils.scaleFactor),),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              'Admission Date: ',
                              style: TextStyle(color: Colors.grey,fontSize: 13*ScaleUtils.scaleFactor),
                            ),
                            Text(
                              '${DateFormat('dd-MM-yyyy').format(widget.recycleBinMember.dateOfAdmission)}',style: TextStyle(color: Colors.white,fontSize: 13*ScaleUtils.scaleFactor),),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Plan: ',
                              style: TextStyle(color: Colors.grey,fontSize: 13*ScaleUtils.scaleFactor),
                            ),
                            Text(planName,style: TextStyle(color: Colors.white,fontSize: 13*ScaleUtils.scaleFactor),),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              'Expiry Date: ',
                              style: TextStyle(color: Colors.grey,fontSize: 13*ScaleUtils.scaleFactor),
                            ),
                            Text(
                              '${DateFormat('dd-MM-yyyy').format(widget.recycleBinMember.expiryDate)}',style: TextStyle(color: Colors.white,fontSize: 13*ScaleUtils.scaleFactor),),
                          ],
                        ),
                      ],
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showConfirmationDialog(BuildContext context, MemberModel recycleBinMember) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Restore'),
          content: Text('Do you want to restore ${recycleBinMember.name}?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                Provider.of<MemberProvider>(context, listen: false)
                    .restoreMember(recycleBinMember);
                // Refresh the page by re-fetching the recycle bin members
                Provider.of<MemberProvider>(context, listen: false)
                    .fetchRecycleBinMembers();
              },
              child: Text('Restore'),
            ),
          ],
        );
      },
    );
  }
}
