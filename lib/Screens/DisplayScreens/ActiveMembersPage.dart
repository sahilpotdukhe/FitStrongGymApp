import 'package:fitstrong_gym/src/custom_import.dart';

/// Members whose membership is still running.
class ActiveMembersPage extends StatefulWidget {
  const ActiveMembersPage({super.key});

  @override
  State<ActiveMembersPage> createState() => _ActiveMembersPageState();
}

class _ActiveMembersPageState extends State<ActiveMembersPage> {
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final memberProvider = Provider.of<MemberProvider>(context, listen: false);
    await memberProvider.fetchActiveMembers();
    // The provider notifies its listeners, so no manual setState is needed
    // here any more.
  }

  @override
  Widget build(BuildContext context) {
    final activeMembers = Provider.of<MemberProvider>(context).activeMembers;

    return AppScaffold(
      title: 'Active members',
      actions: [
        ShadcnButton(
          variant: ShadcnButtonVariant.ghost,
          size: ShadcnButtonSize.icon,
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SearchScreen(screen: 'Active'),
            ),
          ),
          child: const Icon(Icons.search_rounded, size: 20),
        ),
      ],
      body: MemberListView(
        members: activeMembers,
        onRefresh: _load,
        empty: const AppEmptyState(
          icon: Icons.person_off_outlined,
          title: 'No active members',
          description:
              'Nobody has a running membership right now. Renew a membership '
              'or add a new member to see them here.',
        ),
      ),
    );
  }
}
