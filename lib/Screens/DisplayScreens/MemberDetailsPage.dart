import 'package:fitstrong_gym/src/custom_import.dart';
import 'package:intl/intl.dart';

/// Everything recorded about one member, plus the actions you take on them:
/// message, call, mark present, edit and renew.
class MemberDetailsPage extends StatelessWidget {
  const MemberDetailsPage({required this.member, super.key});

  final MemberModel member;

  /// Records today's check in for this member. Marking the same person twice
  /// in one day does nothing beyond saying so.
  Future<void> _markAttendance(BuildContext context) async {
    final attendanceProvider =
        Provider.of<AttendanceProvider>(context, listen: false);
    try {
      final marked = await attendanceProvider.markAttendance(member.name);
      if (!context.mounted) return;
      if (marked) {
        showSuccessToast(
          context,
          'Marked present',
          description: '${member.name} is checked in for today',
        );
      } else {
        showShadcnToast(
          context,
          title: 'Already checked in',
          description: '${member.name} was marked present earlier today',
        );
      }
    } catch (_) {
      if (!context.mounted) return;
      showErrorToast(
        context,
        'Could not mark attendance',
        description: 'Check your connection and try again.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.shadcn;
    final userProvider = Provider.of<UserProvider>(context);
    final UserModel? userModel = userProvider.getUser;
    final plans = Provider.of<GymPlanProvider>(context).plans;
    final plan = GymPlanModel.findById(plans, member.planId);
    final trainer =
        Provider.of<TrainerProvider>(context).byId(member.trainerId);

    return AppScaffold(
      title: 'Member details',
      actions: [
        // This member's own receipt book: every payment they have made,
        // each one re-printable as a PDF.
        ShadcnButton(
          variant: ShadcnButtonVariant.ghost,
          size: ShadcnButtonSize.icon,
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MemberInvoicesPage(member: member),
            ),
          ),
          child: const Icon(Icons.receipt_long_outlined, size: 20),
        ),
        ShadcnButton(
          variant: ShadcnButtonVariant.ghost,
          size: ShadcnButtonSize.icon,
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditMemberDetailsPage(member: member),
            ),
          ),
          child: const Icon(Icons.edit_outlined, size: 20),
        ),
      ],
      bottomBar: Row(
        children: [
          Expanded(
            child: ShadcnButton(
              variant: ShadcnButtonVariant.outline,
              leading: const Icon(Icons.how_to_reg_rounded, size: 18),
              onPressed: () => _markAttendance(context),
              child: const Text('Mark present'),
            ),
          ),
          const ShadcnGap(ShadcnSpacing.md),
          Expanded(
            child: ShadcnButton(
              leading: const Icon(Icons.autorenew_rounded, size: 18),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RenewMembershipPage(member: member),
                ),
              ),
              child: const Text('Renew'),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          ShadcnSpacing.lg,
          ShadcnSpacing.lg,
          ShadcnSpacing.lg,
          ShadcnSpacing.xl2,
        ),
        children: [
          _Header(member: member, planName: plan?.name ?? 'Unknown plan'),
          const ShadcnGap(ShadcnSpacing.xl),
          Row(
            children: [
              Expanded(
                child: ShadcnButton(
                  variant: ShadcnButtonVariant.outline,
                  leading: const FaIcon(FontAwesomeIcons.whatsapp, size: 16),
                  onPressed: () => openWhatsapp(
                    context,
                    member.mobileNumber,
                    userModel?.name ?? 'your gym',
                  ),
                  child: const Text('WhatsApp'),
                ),
              ),
              const ShadcnGap(ShadcnSpacing.md),
              Expanded(
                child: ShadcnButton(
                  variant: ShadcnButtonVariant.outline,
                  leading: const Icon(Icons.call_outlined, size: 16),
                  onPressed: () => _call(context),
                  child: const Text('Call'),
                ),
              ),
            ],
          ),
          const ShadcnGap(ShadcnSpacing.xl2),
          AppDetailSection(
            title: 'Membership',
            children: [
              AppInfoRow(
                label: 'Status',
                value: '',
                valueWidget: Align(
                  alignment: Alignment.centerRight,
                  child: MembershipBadge(member: member),
                ),
              ),
              AppInfoRow(label: 'Plan', value: plan?.name ?? 'Unknown plan'),
              AppInfoRow(
                label: 'Admission date',
                value: DateFormat('d MMM yyyy').format(member.dateOfAdmission),
              ),
              AppInfoRow(
                label: 'Last renewal',
                value: DateFormat('d MMM yyyy').format(member.renewalDate),
              ),
              AppInfoRow(
                label: 'Expires on',
                value: DateFormat('d MMM yyyy').format(member.expiryDate),
              ),
              AppInfoRow(
                label: 'Trainer',
                value: trainer?.name ?? 'Not assigned',
                valueWidget: trainer == null
                    ? null
                    : Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  TrainerDetailsPage(trainer: trainer),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                trainer.name,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: t.primary,
                                ),
                              ),
                              Icon(
                                Icons.chevron_right_rounded,
                                size: 18,
                                color: t.primary,
                              ),
                            ],
                          ),
                        ),
                      ),
                last: true,
              ),
            ],
          ),
          const ShadcnGap(ShadcnSpacing.xl),
          AppDetailSection(
            title: 'Personal',
            children: [
              AppInfoRow(label: 'Full name', value: member.name),
              AppInfoRow(label: 'Mobile number', value: member.mobileNumber),
              AppInfoRow(label: 'Gender', value: member.gender),
              AppInfoRow(
                label: 'Date of birth',
                value: DateFormat('d MMM yyyy').format(member.dateOfBirth),
              ),
              AppInfoRow(
                label: 'Height',
                value: '${member.height} ft',
              ),
              AppInfoRow(
                label: 'Weight',
                value: '${member.weight} kg',
              ),
              AppInfoRow(
                label: 'Address',
                value: member.address,
                last: true,
              ),
            ],
          ),
          const ShadcnGap(ShadcnSpacing.xl),
          AppDetailSection(
            title: 'Gym timings',
            children: [
              AppInfoRow(
                label: 'Check in',
                value: member.checkInTime,
                icon: Icons.login_rounded,
              ),
              AppInfoRow(
                label: 'Check out',
                value: member.checkOutTime,
                icon: Icons.logout_rounded,
                last: true,
              ),
            ],
          ),
          const ShadcnGap(ShadcnSpacing.xl),
          Center(
            child: Text(
              'Member ID · ${member.id}',
              style: TextStyle(fontSize: 11, color: t.mutedForeground),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _call(BuildContext context) async {
    final Uri callUrl = Uri(scheme: 'tel', path: member.mobileNumber);
    try {
      await launchUrl(callUrl);
    } catch (_) {
      if (!context.mounted) return;
      showErrorToast(context, 'Could not start the call');
    }
  }

  void openWhatsapp(
      BuildContext context, String phoneNumber, String gymName) async {
    final whatsapp = "+91$phoneNumber"; //+92xx enter like this
    final message =
        "Hi ${member.name}! Your membership plan has been expired on ${DateFormat('dd-MM-yyyy').format(member.expiryDate)}. We invite you to renew your membership to continue enjoying our gym facilities. Thanks $gymName";
    final whatsappUrlAndroid =
        "whatsapp://send?phone=$whatsapp&text=${Uri.encodeComponent(message)}";
    // The iOS link previously used `Uri.tryParse(message)`, which stringifies
    // to the whole Uri object and sent a broken message body.
    final whatsappUrlIos =
        "https://wa.me/$whatsapp?text=${Uri.encodeComponent(message)}";

    final target = Platform.isIOS ? whatsappUrlIos : whatsappUrlAndroid;
    if (await canLaunchUrl(Uri.parse(target))) {
      await launchUrl(Uri.parse(target), mode: LaunchMode.externalApplication);
    } else {
      if (!context.mounted) return;
      showErrorToast(
        context,
        'WhatsApp not installed',
        description: 'Install WhatsApp, or call the member instead.',
      );
    }
  }
}

/// Photo, name, plan and status, sitting on a tinted panel.
class _Header extends StatelessWidget {
  const _Header({required this.member, required this.planName});

  final MemberModel member;
  final String planName;

  @override
  Widget build(BuildContext context) {
    final t = context.shadcn;
    return Column(
      children: [
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => FullImageWidget(imageUrl: member.photoUrl),
            ),
          ),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: t.border, width: 2),
            ),
            child: ShadcnAvatar(
              member.photoUrl,
              size: 104,
              placeholder: const ShadcnSkeleton.circle(size: 104),
              initials: member.name,
              backgroundColor: t.secondary,
            ),
          ),
        ),
        const ShadcnGap(ShadcnSpacing.lg),
        ShadcnText(
          member.name,
          variant: ShadcnTextVariant.h2,
          textAlign: TextAlign.center,
        ),
        const ShadcnGap(ShadcnSpacing.xs),
        ShadcnText(planName, variant: ShadcnTextVariant.muted),
        const ShadcnGap(ShadcnSpacing.md),
        MembershipBadge(member: member),
      ],
    );
  }
}
