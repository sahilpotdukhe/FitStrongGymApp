

import 'package:fitstrong_gym/src/custom_import.dart';

class DisplayAllMembers extends StatefulWidget {
  @override
  _DisplayAllMembersState createState() => _DisplayAllMembersState();
}

class _DisplayAllMembersState extends State<DisplayAllMembers> {
  @override
  void initState() {
    super.initState();
    // Fetch members when the page is initialized
    final memberProvider = Provider.of<MemberProvider>(context, listen: false);
    memberProvider.getAllMembers().then((_) {
      setState(() {}); // Rebuild the widget after fetching members
    });
  }

  @override
  Widget build(BuildContext context) {
    final memberProvider = Provider.of<MemberProvider>(context);
    final members = memberProvider.members;

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: UniversalVariables.appThemeColor,
        title: Text(
          'Members',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.search,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => SearchScreen()));
            },
          )
        ],
      ),
      body: members.isEmpty
          ? MembersQuietBox(screen: 'nomembers',)
          : ListView.builder(
              itemCount: members.length,
              itemBuilder: (context, index) {
                final member = members[index];
                return InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  MemberDetailsPage(member: member)));
                    },
                    child: MemberCard(
                      member: member,
                    ));
              },
            ),
    );
  }
}
