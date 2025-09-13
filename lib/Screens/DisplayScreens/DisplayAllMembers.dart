import 'package:fitstrong_gym/src/custom_import.dart';

class DisplayAllMembers extends StatefulWidget {
  @override
  _DisplayAllMembersState createState() => _DisplayAllMembersState();
}

class _DisplayAllMembersState extends State<DisplayAllMembers> {
  String selectedPlanId = 'All';
  String selectedGender = 'All';

  @override
  void initState() {
    super.initState();
    final memberProvider = Provider.of<MemberProvider>(context, listen: false);
    final planProvider = Provider.of<GymPlanProvider>(context, listen: false);

    memberProvider.getAllMembers();
    planProvider.fetchPlans();
  }

  @override
  Widget build(BuildContext context) {
    final memberProvider = Provider.of<MemberProvider>(context);
    final planProvider = Provider.of<GymPlanProvider>(context);
    final members = memberProvider.members;
    final plans = planProvider.plans;

    final filteredMembers = members.where((member) {
      final matchesPlan =
          selectedPlanId == 'All' || member.planId == selectedPlanId;
      final matchesGender =
          selectedGender == 'All' || member.gender == selectedGender;
      return matchesPlan && matchesGender;
    }).toList();

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
            icon: Icon(Icons.search, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => SearchScreen(screen: 'All')),
              );
            },
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              children: [
                Expanded(
                    child: DropdownButtonHideUnderline(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: UniversalVariables.appThemeColor, width: 1.5),
                    ),
                    child: DropdownButton<String>(
                      value: selectedPlanId,
                      isExpanded: true,
                      icon: Icon(Icons.filter_list_outlined,
                          color: UniversalVariables.appThemeColor),
                      dropdownColor: Colors.white,
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.w500),
                      items: ['All', ...plans.map((plan) => plan.id)]
                          .map((planId) {
                        final planName = planId == 'All'
                            ? 'Sort by Plan'
                            : plans
                                .firstWhere((plan) => plan.id == planId)
                                .name;
                        return DropdownMenuItem<String>(
                          value: planId,
                          child: Text(
                            planName,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: UniversalVariables.appThemeColor),
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedPlanId = newValue!;
                        });
                      },
                    ),
                  ),
                )),
                SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonHideUnderline(
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: UniversalVariables.appThemeColor,
                            width: 1.5),
                      ),
                      child: DropdownButton<String>(
                        value: selectedGender,
                        isExpanded: true,
                        icon: Icon(Icons.person,
                            color: UniversalVariables.appThemeColor),
                        dropdownColor: Colors.white,
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.w500),
                        items: ['All', 'Male', 'Female'].map((gender) {
                          return DropdownMenuItem<String>(
                            value: gender,
                            child: Text(
                              gender == 'All' ? 'Sort by Gender' : gender,
                              style: TextStyle(
                                  color: UniversalVariables.appThemeColor),
                            ),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedGender = newValue!;
                          });
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: filteredMembers.isEmpty
                ? MembersQuietBox(screen: 'nomembers')
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
                                  MemberDetailsPage(member: member),
                            ),
                          );
                        },
                        child: MemberCard(member: member),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
