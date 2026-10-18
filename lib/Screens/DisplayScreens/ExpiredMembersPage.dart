import 'package:fitstrong_gym/src/custom_import.dart';

/// Members whose membership has lapsed — the follow-up list.
class ExpiredMembersPage extends StatefulWidget {
  const ExpiredMembersPage({super.key});

  @override
  State<ExpiredMembersPage> createState() => _ExpiredMembersPageState();
}

class _ExpiredMembersPageState extends State<ExpiredMembersPage> {
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final memberProvider = Provider.of<MemberProvider>(context, listen: false);
    await memberProvider.fetchExpiredMembers();
  }

  @override
  Widget build(BuildContext context) {
    final expiredMembers = Provider.of<MemberProvider>(context).expiredMembers;

    return AppScaffold(
      title: 'Expired members',
      actions: [
        ShadcnButton(
          variant: ShadcnButtonVariant.ghost,
          size: ShadcnButtonSize.icon,
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SearchScreen(screen: 'Expired'),
            ),
          ),
          child: const Icon(Icons.search_rounded, size: 20),
        ),
      ],
      body: MemberListView(
        members: expiredMembers,
        onRefresh: _load,
        empty: const AppEmptyState(
          icon: Icons.verified_rounded,
          title: 'Nothing expired',
          description:
              'Every membership on your books is up to date. Lapsed ones will '
              'show up here so you can follow them up.',
        ),
      ),
    );
  }
}
