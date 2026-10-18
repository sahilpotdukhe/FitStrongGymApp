import 'package:fitstrong_gym/src/custom_import.dart';

/// The gym owner's own profile — what's on file, and the way out of the app.
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthMethods authMethods = AuthMethods();

  @override
  void initState() {
    super.initState();
    Provider.of<UserProvider>(context, listen: false).refreshUser();
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

    // Matches the menu page: nothing from this gym is left in memory for the
    // next person who signs in on this phone.
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
    final UserModel? userModel = Provider.of<UserProvider>(context).getUser;

    if (userModel == null) {
      return const AppScaffold(title: 'Profile', body: Loading());
    }

    return AppScaffold(
      title: 'Profile',
      actions: [
        ShadcnButton(
          variant: ShadcnButtonVariant.ghost,
          size: ShadcnButtonSize.icon,
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditProfilePage(userModel: userModel),
            ),
          ),
          child: const Icon(Icons.edit_outlined, size: 20),
        ),
      ],
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          ShadcnSpacing.lg,
          ShadcnSpacing.xl,
          ShadcnSpacing.lg,
          ShadcnSpacing.xl2,
        ),
        children: [
          Center(
            child: Column(
              children: [
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          FullImageWidget(imageUrl: userModel.profilePhoto),
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: t.border, width: 2),
                    ),
                    child: ShadcnAvatar(
                      userModel.profilePhoto,
                      size: 104,
                      placeholder: const ShadcnSkeleton.circle(size: 104),
                      initials: userModel.name,
                      backgroundColor: t.secondary,
                    ),
                  ),
                ),
                const ShadcnGap(ShadcnSpacing.lg),
                ShadcnText(userModel.name, variant: ShadcnTextVariant.h2),
                const ShadcnGap(ShadcnSpacing.xs),
                ShadcnText(userModel.email, variant: ShadcnTextVariant.muted),
              ],
            ),
          ),
          const ShadcnGap(ShadcnSpacing.xl2),
          AppDetailSection(
            title: 'Contact',
            children: [
              AppInfoRow(
                label: 'Phone',
                value: userModel.phoneNumber,
                icon: Icons.phone_outlined,
              ),
              AppInfoRow(
                label: 'Address',
                value: userModel.address,
                icon: Icons.place_outlined,
                last: true,
              ),
            ],
          ),
          const ShadcnGap(ShadcnSpacing.xl),
          AppDetailSection(
            title: 'Payments',
            children: [
              AppInfoRow(
                label: 'Merchant name',
                value: userModel.merchantName,
                icon: Icons.storefront_outlined,
              ),
              AppInfoRow(
                label: 'UPI ID',
                value: userModel.upiId,
                icon: Icons.qr_code_rounded,
                last: true,
              ),
            ],
          ),
          const ShadcnGap(ShadcnSpacing.xl2),
          ShadcnButton(
            fullWidth: true,
            variant: ShadcnButtonVariant.outline,
            leading: const Icon(Icons.edit_outlined, size: 18),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditProfilePage(userModel: userModel),
              ),
            ),
            child: const Text('Edit profile'),
          ),
          const ShadcnGap(ShadcnSpacing.md),
          ShadcnButton(
            fullWidth: true,
            variant: ShadcnButtonVariant.ghost,
            foregroundColor: t.destructive,
            leading: const Icon(Icons.logout_rounded, size: 18),
            onPressed: _confirmLogout,
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
  }
}
