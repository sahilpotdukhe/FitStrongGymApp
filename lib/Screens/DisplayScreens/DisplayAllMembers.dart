import 'package:fitstrong_gym/src/custom_import.dart';

/// The "Members" tab in the bottom bar: every member, filterable by plan and
/// gender.
class DisplayAllMembers extends StatefulWidget {
  const DisplayAllMembers({super.key});

  @override
  State<DisplayAllMembers> createState() => _DisplayAllMembersState();
}

class _DisplayAllMembersState extends State<DisplayAllMembers> {
  String selectedPlanId = 'All';
  String selectedGender = 'All';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final memberProvider = Provider.of<MemberProvider>(context, listen: false);
    final planProvider = Provider.of<GymPlanProvider>(context, listen: false);
    await Future.wait([
      memberProvider.getAllMembers(),
      planProvider.fetchPlans(),
    ]);
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

    final filtersActive = selectedPlanId != 'All' || selectedGender != 'All';

    return AppScaffold(
      title: 'Members',
      automaticallyImplyLeading: false,
      actions: [
        ShadcnButton(
          variant: ShadcnButtonVariant.ghost,
          size: ShadcnButtonSize.icon,
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SearchScreen(screen: 'All'),
            ),
          ),
          child: const Icon(Icons.search_rounded, size: 20),
        ),
      ],
      body: MemberListView(
        members: filteredMembers,
        onRefresh: _load,
        header: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: ShadcnSelect<String>(
                    value: selectedPlanId,
                    placeholder: 'Plan',
                    items: [
                      const ShadcnSelectItem(value: 'All', label: 'All plans'),
                      for (final plan in plans)
                        ShadcnSelectItem(value: plan.id, label: plan.name),
                    ],
                    onChanged: (value) =>
                        setState(() => selectedPlanId = value),
                  ),
                ),
                const ShadcnGap(ShadcnSpacing.sm),
                Expanded(
                  child: ShadcnSelect<String>(
                    value: selectedGender,
                    placeholder: 'Gender',
                    items: const [
                      ShadcnSelectItem(value: 'All', label: 'All genders'),
                      ShadcnSelectItem(value: 'Male', label: 'Male'),
                      ShadcnSelectItem(value: 'Female', label: 'Female'),
                    ],
                    onChanged: (value) =>
                        setState(() => selectedGender = value),
                  ),
                ),
              ],
            ),
            if (filtersActive) ...[
              const ShadcnGap(ShadcnSpacing.sm),
              Row(
                children: [
                  ShadcnText(
                    '${filteredMembers.length} of ${members.length} members',
                    variant: ShadcnTextVariant.small,
                  ),
                  const Spacer(),
                  ShadcnButton(
                    variant: ShadcnButtonVariant.link,
                    size: ShadcnButtonSize.sm,
                    onPressed: () => setState(() {
                      selectedPlanId = 'All';
                      selectedGender = 'All';
                    }),
                    child: const Text('Clear filters'),
                  ),
                ],
              ),
            ],
          ],
        ),
        empty: members.isEmpty
            ? const MembersQuietBox(screen: 'nomembers')
            // Nothing matched the filters — offer the way out rather than
            // the "add your first member" message, which would be wrong here.
            : AppEmptyState(
                icon: Icons.filter_alt_off_outlined,
                title: 'No members match',
                description:
                    'No member fits the filters you picked. Try widening them.',
                actionLabel: 'Clear filters',
                onAction: () => setState(() {
                  selectedPlanId = 'All';
                  selectedGender = 'All';
                }),
              ),
      ),
    );
  }
}
