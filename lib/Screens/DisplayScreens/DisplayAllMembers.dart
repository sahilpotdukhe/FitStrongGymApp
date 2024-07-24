import 'package:fitstrong_gym/src/custom_import.dart';

class DisplayAllMembers extends StatefulWidget {
  @override
  _DisplayAllMembersState createState() => _DisplayAllMembersState();
}

class _DisplayAllMembersState extends State<DisplayAllMembers> {
  String selectedPlanId = 'All'; // Initialize with 'All' to show all members

  @override
  void initState() {
    super.initState();
    // Fetch members and plans when the page is initialized
    final memberProvider = Provider.of<MemberProvider>(context, listen: false);
    final planProvider = Provider.of<GymPlanProvider>(context, listen: false);

    memberProvider.getAllMembers().then((_) {
      setState(() {}); // Rebuild the widget after fetching members
    });
    planProvider.fetchPlans().then((_) {
      setState(() {}); // Rebuild the widget after fetching plans
    });
  }

  @override
  Widget build(BuildContext context) {
    final memberProvider = Provider.of<MemberProvider>(context);
    final planProvider = Provider.of<GymPlanProvider>(context);
    final members = memberProvider.members;
    final plans = planProvider.plans;

    // Filter members based on the selected plan
    final filteredMembers = selectedPlanId == 'All'
        ? members
        : members.where((member) => member.planId == selectedPlanId).toList();

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: UniversalVariables.appThemeColor,
        title: Text(
          'Members',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          // DropdownButton for selecting plan
          DropdownButton<String>(
            value: selectedPlanId,
            icon: Icon(Icons.filter_list, color: Colors.white),
            dropdownColor: UniversalVariables.appThemeColor,
            underline: SizedBox(),
            items: ['All', ...plans.map((plan) => plan.id)]
                .map((planId) => DropdownMenuItem<String>(
              value: planId,
              child: Text(
                planId == 'All'
                    ? 'All'
                    : plans.firstWhere((plan) => plan.id == planId).name,
                style: TextStyle(color: Colors.white),
              ),
            ))
                .toList(),
            onChanged: (String? newValue) {
              setState(() {
                selectedPlanId = newValue!;
              });
            },
          ),
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
      body: filteredMembers.isEmpty
          ? MembersQuietBox(screen: 'nomembers',)
          : ListView.builder(
        itemCount: filteredMembers.length,
        itemBuilder: (context, index) {
          final member = filteredMembers[index];
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
