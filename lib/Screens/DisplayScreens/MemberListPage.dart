import 'package:fitstrong_gym/src/custom_import.dart';

/// All members, filterable by membership state.
///
/// Was three Material tabs over three copies of the same list; now one list
/// with a segmented filter that also shows how many members are in each
/// bucket, so the counts are visible without switching tabs.
class MemberListPage extends StatefulWidget {
  const MemberListPage({super.key});

  @override
  State<MemberListPage> createState() => _MemberListPageState();
}

enum _MemberFilter { all, active, expired }

class _MemberListPageState extends State<MemberListPage> {
  _MemberFilter _filter = _MemberFilter.all;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final memberProvider = Provider.of<MemberProvider>(context, listen: false);
    final gymPlanProvider =
        Provider.of<GymPlanProvider>(context, listen: false);
    await Future.wait([
      memberProvider.getAllMembers(),
      gymPlanProvider.fetchPlans(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.shadcn;
    final memberProvider = Provider.of<MemberProvider>(context);
    final members = memberProvider.members;
    final active = members.where((m) => !m.isExpired()).toList();
    final expired = members.where((m) => m.isExpired()).toList();

    final visible = switch (_filter) {
      _MemberFilter.all => members,
      _MemberFilter.active => active,
      _MemberFilter.expired => expired,
    };

    return AppScaffold(
      title: 'Members',
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
        members: visible,
        onRefresh: _load,
        header: AppSegmentedFilter<_MemberFilter>(
          value: _filter,
          onChanged: (value) => setState(() => _filter = value),
          segments: [
            AppSegment(
              value: _MemberFilter.all,
              label: 'All',
              count: members.length,
            ),
            AppSegment(
              value: _MemberFilter.active,
              label: 'Active',
              count: active.length,
            ),
            AppSegment(
              value: _MemberFilter.expired,
              label: 'Expired',
              count: expired.length,
            ),
          ],
        ),
        empty: members.isEmpty
            ? const MembersQuietBox(screen: 'nomembers')
            : AppEmptyState(
                icon: _filter == _MemberFilter.expired
                    ? Icons.verified_rounded
                    : Icons.event_busy_rounded,
                title: _filter == _MemberFilter.expired
                    ? 'No expired memberships'
                    : 'No active memberships',
                description: _filter == _MemberFilter.expired
                    ? 'Everyone on your books is up to date. Nice.'
                    : 'Every membership has lapsed. Renew one to bring it back here.',
                actionLabel: 'Show all members',
                onAction: () => setState(() => _filter = _MemberFilter.all),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AddMemberPage()),
        ),
        foregroundColor: t.primaryForeground,
        backgroundColor: t.primary,
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}
