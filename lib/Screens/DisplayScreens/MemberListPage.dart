import 'package:fitstrong_gym/src/custom_import.dart';

class MemberListPage extends StatefulWidget {
  @override
  _MemberListPageState createState() => _MemberListPageState();
}

class _MemberListPageState extends State<MemberListPage> {
  @override
  void initState() {
    super.initState();
    final memberProvider = Provider.of<MemberProvider>(context, listen: false);
    final gymPlanProvider =
        Provider.of<GymPlanProvider>(context, listen: false);
    memberProvider.getAllMembers();
    gymPlanProvider.fetchPlans(); // Fetch plans
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: UniversalVariables.bgColor,
        appBar: AppBar(
          backgroundColor: UniversalVariables.appThemeColor,
          iconTheme: IconThemeData(
            color: Colors.white, //change your color here
          ),
          title: Text(
            'Members',
            style: TextStyle(color: Colors.white),
          ),
          bottom: TabBar(
            tabs: const [
              Tab(text: 'All Members'),
              Tab(text: 'Active Members'),
              Tab(text: 'Expired Members'),
            ],
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white,
            indicatorColor: Colors.white,
          ),
          actions: [
            IconButton(
              icon: Icon(
                Icons.search,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SearchScreen(
                              screen: 'All',
                            )));
              },
            )
          ],
        ),
        body: TabBarView(
          children: [
            MemberListSection(
              filter: (member, plans) => true,
              emptyMessage: 'No members found.',
            ),
            MemberListSection(
              filter: (member, plans) => !member.isExpired(plans),
              emptyMessage: 'No active members found.',
            ),
            MemberListSection(
              filter: (member, plans) => member.isExpired(plans),
              emptyMessage: 'No expired members found.',
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => AddMemberPage()));
          },
          foregroundColor: Colors.white,
          backgroundColor: UniversalVariables.appThemeColor,
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}

class MemberListSection extends StatelessWidget {
  final bool Function(MemberModel, List<GymPlanModel>) filter;
  final String emptyMessage;

  const MemberListSection({
    required this.filter,
    required this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    final memberProvider = Provider.of<MemberProvider>(context);
    final gymPlanProvider = Provider.of<GymPlanProvider>(context);
    final members = memberProvider.members;
    final plans = gymPlanProvider.plans;

    if (members.isEmpty) {
      return MembersQuietBox(
        screen: 'nomembers',
      );
    }

    final filteredMembers =
        members.where((member) => filter(member, plans)).toList();

    if (filteredMembers.isEmpty) {
      return Center(child: Text(emptyMessage));
    }

    return ListView.builder(
      itemCount: filteredMembers.length,
      itemBuilder: (context, index) {
        final member = filteredMembers[index];
        final plan = GymPlanModel.findById(plans, member.planId);
        final planName = plan?.name ?? 'Unknown Plan';
        return InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MemberDetailsPage(member: member)));
            },
            child: MemberCard(member: member));
      },
    );
  }
}
