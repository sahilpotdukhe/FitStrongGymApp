import 'package:fitstrong_gym/Widgets/CachedImage.dart';
import 'package:fitstrong_gym/src/custom_import.dart';
import 'package:intl/intl.dart';

class MemberCard extends StatefulWidget {
  final MemberModel member;

  const MemberCard({super.key, required this.member});

  @override
  State<MemberCard> createState() => _MemberCardState();
}

class _MemberCardState extends State<MemberCard> {
  @override
  Widget build(BuildContext context) {
    ScaleUtils.init(context);
    final plans = Provider.of<GymPlanProvider>(context, listen: false).plans;
    final plan = GymPlanModel.findById(plans, widget.member.planId);
    final planName = plan?.name ?? 'Unknown Plan';
    final isExpired = widget.member.isExpired(plans);

    return Padding(
      padding: EdgeInsets.all(8.0 * ScaleUtils.scaleFactor),
      child: Card(
        elevation: 15,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30 * ScaleUtils.scaleFactor),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 10 * ScaleUtils.horizontalScale,
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0 * ScaleUtils.scaleFactor),
                    child: CachedImage(
                        imageUrl: widget.member.photoUrl,
                        isRound: true,
                        radius: 60,
                        height: 0,
                        width: 0,
                        fit: BoxFit.cover),
                  ),
                  SizedBox(
                    width: 10 * ScaleUtils.horizontalScale,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.member.name,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 16 * ScaleUtils.scaleFactor,
                              fontWeight: FontWeight.w700),
                        ),
                        Text(
                          planName,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 13 * ScaleUtils.scaleFactor,
                              color: HexColor('#6B7280')),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color:
                          isExpired ? HexColor('#FEE2E2') : HexColor('#8ceaba'),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      child: Text(
                        isExpired ? "Expired" : "Active",
                        style: TextStyle(
                            color: isExpired ? Colors.red : HexColor('#047857'),
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 20 * ScaleUtils.horizontalScale,
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Row(
                  children: [
                    SizedBox(
                      width: 10 * ScaleUtils.horizontalScale,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Gender: ',
                              style: TextStyle(
                                  color: HexColor('#6B7280'),
                                  fontSize: 13 * ScaleUtils.scaleFactor),
                            ),
                            SizedBox(width: 30),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                widget.member.gender,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: 13 * ScaleUtils.scaleFactor),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              'Mobile: ',
                              style: TextStyle(
                                  color: HexColor('#6B7280'),
                                  fontSize: 13 * ScaleUtils.scaleFactor),
                            ),
                            SizedBox(width: 30),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                widget.member.mobileNumber,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: 13 * ScaleUtils.scaleFactor),
                              ),
                            )
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              'Joined: ',
                              style: TextStyle(
                                  color: HexColor('#6B7280'),
                                  fontSize: 13 * ScaleUtils.scaleFactor),
                            ),
                            SizedBox(width: 30),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                DateFormat('d MMM, yyyy')
                                    .format(widget.member.dateOfAdmission),
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: 13 * ScaleUtils.scaleFactor),
                              ),
                            )
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              'Expires:',
                              style: TextStyle(
                                  color: HexColor('#6B7280'),
                                  fontSize: 13 * ScaleUtils.scaleFactor),
                            ),
                            SizedBox(width: 30),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                DateFormat('d MMM, yyyy')
                                    .format(widget.member.expiryDate),
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: 13 * ScaleUtils.scaleFactor),
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              EditMemberDetailsPage(member: widget.member),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: HexColor('#d5d9e0'),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.edit),
                            SizedBox(
                              width: 6 * ScaleUtils.horizontalScale,
                            ),
                            Text(
                              'Edit',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
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
                          builder: (context) =>
                              RenewMembershipPage(member: widget.member),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          color: HexColor('#DBEAFE'),
                          borderRadius: BorderRadius.circular(10)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.autorenew,
                              color: HexColor('#1D69E3'),
                            ),
                            SizedBox(
                              width: 6 * ScaleUtils.horizontalScale,
                            ),
                            Text(
                              'Renew',
                              style: TextStyle(
                                  color: HexColor('#1D69E3'),
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () async {
                      bool confirmDelete = await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Confirm Deletion'),
                            content: Text(
                                'Are you sure you want to delete this member?'),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                child: Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
                                child: Text('Delete'),
                              ),
                            ],
                          );
                        },
                      );

                      if (confirmDelete == true) {
                        try {
                          User? currentUser = FirebaseAuth.instance.currentUser;
                          if (currentUser != null) {
                            // Delete the member from the user's members subCollection
                            await FirebaseFirestore.instance
                                .collection('Users')
                                .doc(currentUser.uid)
                                .collection('members')
                                .doc(widget.member.id)
                                .delete();

                            // Move the member to the user's recycleBin subCollection
                            await FirebaseFirestore.instance
                                .collection('Users')
                                .doc(currentUser.uid)
                                .collection('recyclebin')
                                .doc(widget.member.id)
                                .set(widget.member.toMap());

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text('Member deleted successfully')),
                            );

                            // Refresh the member list
                            Provider.of<MemberProvider>(context, listen: false)
                                .getAllMembers();
                          }
                        } catch (error) {
                          print('Error deleting member: $error');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed to delete member')),
                          );
                        }
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          color: HexColor('#FEE2E2'),
                          borderRadius: BorderRadius.circular(10)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.delete,
                              color: HexColor('#B91C3C'),
                            ),
                            SizedBox(
                              width: 6 * ScaleUtils.horizontalScale,
                            ),
                            Text(
                              'Delete',
                              style: TextStyle(
                                  color: HexColor('#B91C3C'),
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
