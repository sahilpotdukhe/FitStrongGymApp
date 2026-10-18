import 'package:fitstrong_gym/src/custom_import.dart';

/// The account tab: who is signed in, shortcuts to everything that isn't on
/// the dashboard, appearance settings and sign out.
class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  final AuthMethods authMethods = AuthMethods();

  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.refreshUser();
  }

  Future<void> _confirmLogout() async {
    final t = context.shadcn;
    final confirmed = await showShadcnAlertDialog(
      context,
      icon: ShadcnIconBadge(Icons.logout_rounded, color: t.destructive),
      title: 'Sign out?',
      description: 'You will need your email and password to get back in.',
      confirmLabel: 'Sign out',
      destructive: true,
    );
    if (confirmed != true || !mounted) return;

    // Everything held in memory is dropped before signing out. Without this
    // the previous gym's members, plans and takings stayed loaded and could
    // flash on screen for the next owner to log in on this phone.
    Provider.of<MemberProvider>(context, listen: false).clear();
    Provider.of<GymPlanProvider>(context, listen: false).clear();
    Provider.of<UserProvider>(context, listen: false).clear();
    Provider.of<AttendanceProvider>(context, listen: false).clear();
    Provider.of<InvoiceProvider>(context, listen: false).clear();
    Provider.of<TrainerProvider>(context, listen: false).clear();

    authMethods.logOut(context);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.shadcn;
    final status = context.status;
    final UserModel? userModel = Provider.of<UserProvider>(context).getUser;

    return AppScaffold(
      title: 'Account',
      automaticallyImplyLeading: false,
      actions: const [ThemeModeToggle()],
      body: userModel == null
          ? const Loading()
          : ListView(
              padding: const EdgeInsets.fromLTRB(
                ShadcnSpacing.lg,
                ShadcnSpacing.lg,
                ShadcnSpacing.lg,
                ShadcnSpacing.xl4,
              ),
              children: [
                _ProfileCard(user: userModel),
                const ShadcnGap(ShadcnSpacing.xl2),
                const AppSectionHeader(title: 'Members'),
                const ShadcnGap(ShadcnSpacing.md),
                _MenuGroup(
                  items: [
                    _MenuItem(
                      icon: Icons.person_add_alt_1_rounded,
                      color: status.info,
                      label: 'Add new member',
                      onTap: () => _push(const AddMemberPage()),
                    ),
                    _MenuItem(
                      icon: Icons.groups_rounded,
                      color: status.info,
                      label: 'All members',
                      onTap: () => _push(const DisplayAllMembers()),
                    ),
                    _MenuItem(
                      icon: Icons.delete_outline_rounded,
                      color: status.danger,
                      label: 'Recycle bin',
                      onTap: () => _push(const RecycleBinPage()),
                    ),
                  ],
                ),
                const ShadcnGap(ShadcnSpacing.xl2),
                const AppSectionHeader(title: 'Team'),
                const ShadcnGap(ShadcnSpacing.md),
                _MenuGroup(
                  items: [
                    _MenuItem(
                      icon: Icons.sports_gymnastics_rounded,
                      color: status.info,
                      label: 'Trainers',
                      onTap: () => _push(const TrainersPage()),
                    ),
                    _MenuItem(
                      icon: Icons.person_add_alt_rounded,
                      color: status.info,
                      label: 'Add a trainer',
                      onTap: () => _push(const TrainerFormPage()),
                    ),
                  ],
                ),
                const ShadcnGap(ShadcnSpacing.xl2),
                const AppSectionHeader(title: 'Business'),
                const ShadcnGap(ShadcnSpacing.md),
                _MenuGroup(
                  items: [
                    _MenuItem(
                      icon: Icons.add_card_rounded,
                      color: status.warning,
                      label: 'Create a plan',
                      onTap: () => _push(const AddGymPlanPage()),
                    ),
                    _MenuItem(
                      icon: Icons.card_membership_rounded,
                      color: status.warning,
                      label: 'Membership plans',
                      onTap: () => _push(const GymPlansPage()),
                    ),
                    _MenuItem(
                      icon: Icons.currency_rupee_rounded,
                      color: status.success,
                      label: 'Revenue and invoices',
                      onTap: () => _push(const RevenuePage()),
                    ),
                  ],
                ),
                const ShadcnGap(ShadcnSpacing.xl2),
                const AppSectionHeader(title: 'About'),
                const ShadcnGap(ShadcnSpacing.md),
                _MenuGroup(
                  items: [
                    _MenuItem(
                      icon: Icons.code_rounded,
                      color: t.mutedForeground,
                      label: 'About the developer',
                      onTap: _openDeveloperSite,
                    ),
                  ],
                ),
                const ShadcnGap(ShadcnSpacing.xl2),
                ShadcnButton(
                  fullWidth: true,
                  variant: ShadcnButtonVariant.outline,
                  foregroundColor: t.destructive,
                  leading: const Icon(Icons.logout_rounded, size: 18),
                  onPressed: _confirmLogout,
                  child: const Text('Sign out'),
                ),
              ],
            ),
    );
  }

  void _push(Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }

  Future<void> _openDeveloperSite() async {
    final Uri url =
        Uri.parse('https://sahilpotdukhe.github.io/Portfolio-website/');
    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (!mounted) return;
      showErrorToast(context, 'Could not open the link');
    }
  }
}

/// The signed-in gym owner, tappable through to their profile.
class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.user});

  final UserModel user;

  @override
  Widget build(BuildContext context) {
    final t = context.shadcn;
    return ShadcnCard(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ProfilePage()),
      ),
      child: Row(
        children: [
          ShadcnAvatar(
            user.profilePhoto,
            size: 56,
            placeholder: const ShadcnSkeleton.circle(size: 56),
            initials: user.name,
            backgroundColor: t.secondary,
          ),
          const ShadcnGap(ShadcnSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w700,
                    color: t.cardForeground,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  user.email,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 13, color: t.mutedForeground),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: t.mutedForeground),
        ],
      ),
    );
  }
}

/// A card holding several [_MenuItem]s with dividers between them — the
/// grouped-list pattern, instead of one elevated card per row.
class _MenuGroup extends StatelessWidget {
  const _MenuGroup({required this.items});

  final List<_MenuItem> items;

  @override
  Widget build(BuildContext context) {
    final t = context.shadcn;
    return ShadcnCard(
      padding: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) Divider(height: 1, color: t.border),
            items[i],
          ],
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.shadcn;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: ShadcnSpacing.lg,
          vertical: ShadcnSpacing.md,
        ),
        child: Row(
          children: [
            Container(
              height: 38,
              width: 38,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(t.radiusMd),
              ),
              child: Icon(icon, size: 19, color: color),
            ),
            const ShadcnGap(ShadcnSpacing.md),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: t.cardForeground,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: t.mutedForeground,
            ),
          ],
        ),
      ),
    );
  }
}
