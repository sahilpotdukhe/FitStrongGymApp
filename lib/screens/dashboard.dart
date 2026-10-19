import 'package:fitstrong_gym/screens/bmi_calculator.dart';
import 'package:fitstrong_gym/src/custom_import.dart';

class DashBoard extends StatefulWidget {
  const DashBoard({super.key});

  @override
  State<DashBoard> createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  FirebaseFirestore fireStore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  void _fetchInitialData() {
    final memberProvider = Provider.of<MemberProvider>(context, listen: false);
    final gymPlanProvider =
        Provider.of<GymPlanProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // One member fetch is enough: the active and expired counts are worked
    // out from that same list rather than fetched separately.
    // Re-book the morning reminder as soon as the member list lands, so it
    // always reflects today's expiry dates and birthdays.
    memberProvider.getAllMembers().then((_) {
      if (mounted) ReminderScheduler.refresh(context);
    });
    gymPlanProvider.fetchPlans();
    userProvider.refreshUser();
    Provider.of<TrainerProvider>(context, listen: false).fetchTrainers();
  }

  Future<void> _refresh() async {
    final memberProvider = Provider.of<MemberProvider>(context, listen: false);
    final gymPlanProvider =
        Provider.of<GymPlanProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await Future.wait([
      memberProvider.getAllMembers(),
      gymPlanProvider.fetchPlans(),
      userProvider.refreshUser(),
      Provider.of<TrainerProvider>(context, listen: false).fetchTrainers(),
    ]);
    if (mounted) await ReminderScheduler.refresh(context);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.shadcn;
    final status = context.status;
    final memberProvider = Provider.of<MemberProvider>(context);
    final gymPlanProvider = Provider.of<GymPlanProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final members = memberProvider.members;
    // The dashboard counts what the gym currently sells, not retired plans.
    final plans = gymPlanProvider.sellablePlans;
    final activeMembers = memberProvider.activeMembers;
    final expiredMembers = memberProvider.expiredMembers;
    final UserModel? userModel = userProvider.getUser;
    final trainerCount =
        Provider.of<TrainerProvider>(context).activeTrainers.length;

    return Scaffold(
      backgroundColor: t.background,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: t.primary,
          backgroundColor: t.card,
          onRefresh: _refresh,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              ShadcnSpacing.lg,
              ShadcnSpacing.sm,
              ShadcnSpacing.lg,
              ShadcnSpacing.xl3,
            ),
            children: [
              _Greeting(user: userModel),
              const ShadcnGap(ShadcnSpacing.lg),

              // Who needs a message today, before the counts: it is the one
              // thing on this screen that goes stale if it is not acted on.
              _RemindersBanner(digest: ReminderService.build(members)),
              const ShadcnGap(ShadcnSpacing.md),

              // Two columns of equal-height cards. The old layout used fixed
              // pixel heights multiplied by a scale factor, which clipped the
              // numbers on small phones and on large text settings.
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: ShadcnSpacing.md,
                mainAxisSpacing: ShadcnSpacing.md,
                childAspectRatio: 1.35,
                children: [
                  AppStatCard(
                    label: 'Total members',
                    value: '${members.length}',
                    icon: Icons.groups_rounded,
                    accent: t.primary,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MemberListPage()),
                    ),
                  ),
                  AppStatCard(
                    label: 'Active memberships',
                    value: '${activeMembers.length}',
                    icon: Icons.verified_rounded,
                    accent: status.success,
                    accentSurface: status.successSurface,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ActiveMembersPage()),
                    ),
                  ),
                  AppStatCard(
                    label: 'Expired memberships',
                    value: '${expiredMembers.length}',
                    icon: Icons.event_busy_rounded,
                    accent: status.danger,
                    accentSurface: status.dangerSurface,
                    footnote: expiredMembers.isEmpty ? null : 'Needs follow-up',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ExpiredMembersPage()),
                    ),
                  ),
                  AppStatCard(
                    label: 'Membership plans',
                    value: '${plans.length}',
                    icon: Icons.card_membership_rounded,
                    accent: status.warning,
                    accentSurface: status.warningSurface,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => GymPlansPage()),
                    ),
                  ),
                ],
              ),

              const ShadcnGap(ShadcnSpacing.xl2),
              const AppSectionHeader(title: 'Quick actions'),
              const ShadcnGap(ShadcnSpacing.md),
              _QuickActions(),

              const ShadcnGap(ShadcnSpacing.xl2),
              const AppSectionHeader(title: 'Your gym'),
              const ShadcnGap(ShadcnSpacing.md),
              _LinkCard(
                icon: Icons.sports_gymnastics_rounded,
                iconColor: status.info,
                iconSurface: status.infoSurface,
                title: 'Trainers',
                subtitle: trainerCount == 0
                    ? 'Add your coaches and assign members to them'
                    : '$trainerCount trainer${trainerCount == 1 ? '' : 's'} on the team',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TrainersPage()),
                ),
              ),
              const ShadcnGap(ShadcnSpacing.md),
              _LinkCard(
                icon: Icons.monitor_weight_outlined,
                iconColor: status.info,
                iconSurface: status.infoSurface,
                title: 'BMI calculator',
                subtitle: "Check a member's body mass index in seconds",
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BMICalculator()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Greeting row with the gym owner's name, their photo, and the light/dark
/// switch. The old header sat on a photographic background, which forced
/// white text and left the page unreadable in bright sunlight.
class _Greeting extends StatelessWidget {
  const _Greeting({required this.user});

  final UserModel? user;

  @override
  Widget build(BuildContext context) {
    final t = context.shadcn;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShadcnText(
                // Falls back to a neutral greeting while the profile loads,
                // instead of flashing "Welcome back, null!" on every open.
                user == null ? 'Welcome back!' : 'Hi, ${user!.name}',
                variant: ShadcnTextVariant.h2,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              ShadcnText(
                "Here's how your gym is doing today",
                variant: ShadcnTextVariant.muted,
              ),
            ],
          ),
        ),
        const ShadcnGap(ShadcnSpacing.sm),
        const ThemeModeToggle(),
        const ShadcnGap(ShadcnSpacing.xs),
        AppAvatar(
          user?.profilePhoto,
          size: 40,
          backgroundColor: t.secondary,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ProfilePage()),
          ),
        ),
      ],
    );
  }
}

/// The three things a gym owner does most, one tap from the home screen.
class _QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickAction(
            icon: Icons.person_add_alt_1_rounded,
            label: 'Add member',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddMemberPage()),
            ),
          ),
        ),
        const ShadcnGap(ShadcnSpacing.md),
        Expanded(
          child: _QuickAction(
            icon: Icons.search_rounded,
            label: 'Find member',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SearchScreen(screen: 'All'),
              ),
            ),
          ),
        ),
        const ShadcnGap(ShadcnSpacing.md),
        Expanded(
          child: _QuickAction(
            icon: Icons.add_card_rounded,
            label: 'New plan',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddGymPlanPage()),
            ),
          ),
        ),
      ],
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.shadcn;
    return ShadcnCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(
        vertical: ShadcnSpacing.lg,
        horizontal: ShadcnSpacing.sm,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: t.primary, size: 22),
          const ShadcnGap(ShadcnSpacing.sm),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: TextStyle(
              fontSize: 12.5,
              height: 1.2,
              fontWeight: FontWeight.w600,
              color: t.cardForeground,
            ),
          ),
        ],
      ),
    );
  }
}

/// A full-width row that opens another screen: icon, title, one line of
/// explanation, chevron. Used for the dashboard's shortcuts.
class _LinkCard extends StatelessWidget {
  const _LinkCard({
    required this.icon,
    required this.iconColor,
    required this.iconSurface,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconSurface;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.shadcn;
    return ShadcnCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: iconSurface,
              borderRadius: BorderRadius.circular(t.radiusMd),
            ),
            child: Icon(icon, color: iconColor),
          ),
          const ShadcnGap(ShadcnSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShadcnText(title, variant: ShadcnTextVariant.h4),
                ShadcnText(subtitle, variant: ShadcnTextVariant.muted),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: t.mutedForeground),
        ],
      ),
    );
  }
}

/// A single line across the top of the dashboard saying how many people
/// need a message today. Hidden entirely when nobody does, so a quiet day
/// looks quiet.
class _RemindersBanner extends StatelessWidget {
  const _RemindersBanner({required this.digest});

  final ReminderDigest digest;

  @override
  Widget build(BuildContext context) {
    final t = context.shadcn;
    final status = context.status;
    if (digest.isEmpty) return const SizedBox.shrink();

    return ShadcnCard(
      padding: const EdgeInsets.all(ShadcnSpacing.md),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const RemindersPage()),
      ),
      child: Row(
        children: [
          Container(
            height: 38,
            width: 38,
            decoration: BoxDecoration(
              color: status.warningSurface,
              borderRadius: BorderRadius.circular(t.radiusMd),
            ),
            child: Icon(
              Icons.notifications_active_rounded,
              size: 19,
              color: status.warning,
            ),
          ),
          const ShadcnGap(ShadcnSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Needs a message today',
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: t.cardForeground,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  digest.headline,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12.5, color: t.mutedForeground),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            size: 20,
            color: t.mutedForeground,
          ),
        ],
      ),
    );
  }
}
