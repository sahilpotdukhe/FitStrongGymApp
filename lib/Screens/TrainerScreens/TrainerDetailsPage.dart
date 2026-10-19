import 'package:fitstrong_gym/src/custom_import.dart';
import 'package:intl/intl.dart';

/// Everything about one trainer, including the members they coach.
class TrainerDetailsPage extends StatelessWidget {
  const TrainerDetailsPage({super.key, required this.trainer});

  final TrainerModel trainer;

  @override
  Widget build(BuildContext context) {
    final t = context.shadcn;
    final status = context.status;

    // Read live from the providers rather than from the trainer that was
    // passed in, so edits made on this screen show up without going back.
    final trainerProvider = Provider.of<TrainerProvider>(context);
    final current = trainerProvider.byId(trainer.id) ?? trainer;
    final members = Provider.of<MemberProvider>(context).members;
    final assigned = membersOfTrainer(members, current.id);

    return AppScaffold(
      title: 'Trainer',
      actions: [
        ShadcnButton(
          variant: ShadcnButtonVariant.ghost,
          size: ShadcnButtonSize.icon,
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TrainerFormPage(trainer: current),
            ),
          ),
          child: const Icon(Icons.edit_outlined, size: 20),
        ),
        ShadcnButton(
          variant: ShadcnButtonVariant.ghost,
          size: ShadcnButtonSize.icon,
          foregroundColor: t.destructive,
          onPressed: () => _confirmDelete(context, current, assigned.length),
          child: const Icon(Icons.delete_outline_rounded, size: 20),
        ),
      ],
      bottomBar: Row(
        children: [
          Expanded(
            child: ShadcnButton(
              variant: ShadcnButtonVariant.outline,
              leading: const FaIcon(FontAwesomeIcons.whatsapp, size: 16),
              onPressed: () => _openWhatsapp(context, current),
              child: const Text('WhatsApp'),
            ),
          ),
          const ShadcnGap(ShadcnSpacing.md),
          Expanded(
            child: ShadcnButton(
              leading: const Icon(Icons.call_outlined, size: 18),
              onPressed: () => _call(context, current),
              child: const Text('Call'),
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
          Center(
            child: Column(
              children: [
                // Tapping the photo opens it full screen, the same as a
                // member's does.
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FullImageWidget(
                        imageUrl: current.photoUrl,
                        title: current.name,
                      ),
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: t.border, width: 2),
                    ),
                    child: AppAvatar(
                      current.photoUrl,
                      size: 104,
                      backgroundColor: t.secondary,
                    ),
                  ),
                ),
                const ShadcnGap(ShadcnSpacing.lg),
                ShadcnText(current.name, variant: ShadcnTextVariant.h2),
                const ShadcnGap(ShadcnSpacing.xs),
                ShadcnText(
                  current.specialization,
                  variant: ShadcnTextVariant.muted,
                ),
                const ShadcnGap(ShadcnSpacing.md),
                ShadcnBadge(
                  style: ShadcnBadgeStyle(
                    backgroundColor: current.isActive
                        ? status.successSurface
                        : status.dangerSurface,
                    foregroundColor: current.isActive
                        ? status.successForeground
                        : status.dangerForeground,
                    textStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: Text(
                    current.isActive ? 'Currently working' : 'No longer here',
                  ),
                ),
              ],
            ),
          ),
          const ShadcnGap(ShadcnSpacing.xl2),
          AppDetailSection(
            title: 'Schedule',
            children: [
              AppInfoRow(
                label: 'Shift',
                value: current.shiftLabel,
                icon: Icons.schedule_rounded,
              ),
              AppInfoRow(
                label: 'Working days',
                value: current.workingDaysLabel,
                icon: Icons.calendar_month_outlined,
              ),
              AppInfoRow(
                label: 'Joined on',
                value: DateFormat('d MMM yyyy').format(current.joiningDate),
                icon: Icons.event_available_outlined,
                last: true,
              ),
            ],
          ),
          const ShadcnGap(ShadcnSpacing.xl),
          AppDetailSection(
            title: 'Details',
            children: [
              AppInfoRow(label: 'Mobile', value: current.mobileNumber),
              AppInfoRow(label: 'Gender', value: current.gender),
              AppInfoRow(
                label: 'Experience',
                value: current.experienceYears == 0
                    ? 'Not recorded'
                    : '${current.experienceYears} year'
                        '${current.experienceYears == 1 ? '' : 's'}',
              ),
              AppInfoRow(
                label: 'Monthly pay',
                value: current.salary == 0
                    ? 'Not recorded'
                    : '₹${current.salary.toStringAsFixed(0)}',
              ),
              AppInfoRow(
                label: 'Address',
                value: current.address,
                last: true,
              ),
            ],
          ),
          const ShadcnGap(ShadcnSpacing.xl),
          AppSectionHeader(
            title: 'Members they train (${assigned.length})',
          ),
          const ShadcnGap(ShadcnSpacing.md),
          if (assigned.isEmpty)
            ShadcnCard(
              child: Row(
                children: [
                  Icon(Icons.group_off_outlined, color: t.mutedForeground),
                  const ShadcnGap(ShadcnSpacing.md),
                  Expanded(
                    child: ShadcnText(
                      'No members are assigned to this trainer yet. Pick them '
                      'as the trainer when you add or edit a member.',
                      variant: ShadcnTextVariant.small,
                    ),
                  ),
                ],
              ),
            )
          else
            ShadcnCard(
              padding: EdgeInsets.zero,
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  for (var i = 0; i < assigned.length; i++) ...[
                    if (i > 0) Divider(height: 1, color: t.border),
                    ShadcnListTile(
                      leading: AppAvatar(
                        assigned[i].photoUrl,
                        size: 38,
                        backgroundColor: t.secondary,
                      ),
                      title: Text(assigned[i].name),
                      subtitle: Text(assigned[i].mobileNumber),
                      trailing: MembershipBadge(
                        member: assigned[i],
                        compact: true,
                      ),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              MemberDetailsPage(member: assigned[i]),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    TrainerModel trainer,
    int memberCount,
  ) async {
    final t = context.shadcn;
    final confirmed = await showShadcnAlertDialog(
      context,
      icon: ShadcnIconBadge(
        Icons.delete_outline_rounded,
        color: t.destructive,
      ),
      title: 'Delete ${trainer.name}?',
      // Says exactly what happens to the members, because deleting a trainer
      // quietly changes their records too.
      description: memberCount == 0
          ? 'This removes the trainer permanently. It cannot be undone.'
          : 'This removes the trainer permanently and unassigns them from '
              '$memberCount member${memberCount == 1 ? '' : 's'}. The members '
              'themselves are not deleted.',
      confirmLabel: 'Delete',
      destructive: true,
    );
    if (confirmed != true || !context.mounted) return;

    try {
      await Provider.of<TrainerProvider>(context, listen: false)
          .deleteTrainer(trainer);
      if (!context.mounted) return;
      // The member list holds the old trainerId until it is reloaded.
      await Provider.of<MemberProvider>(context, listen: false).getAllMembers();
      if (!context.mounted) return;
      showSuccessToast(context, 'Trainer deleted');
      Navigator.pop(context);
    } catch (_) {
      if (!context.mounted) return;
      showErrorToast(context, 'Could not delete trainer');
    }
  }

  Future<void> _call(BuildContext context, TrainerModel trainer) async {
    final Uri callUrl = Uri(scheme: 'tel', path: trainer.mobileNumber);
    try {
      await launchUrl(callUrl);
    } catch (_) {
      if (!context.mounted) return;
      showErrorToast(context, 'Could not start the call');
    }
  }

  /// Opens WhatsApp with the trainer. Goes through the shared helper so a
  /// number saved with spaces, a plus sign or a leading zero still works.
  Future<void> _openWhatsapp(BuildContext context, TrainerModel trainer) async {
    final opened = await WhatsAppHelper.openChat(
      phoneNumber: trainer.mobileNumber,
      message: 'Hi ${trainer.name},',
    );
    if (opened || !context.mounted) return;

    showErrorToast(
      context,
      WhatsAppHelper.canMessage(trainer.mobileNumber)
          ? 'WhatsApp not installed'
          : 'No usable mobile number',
      description: WhatsAppHelper.canMessage(trainer.mobileNumber)
          ? 'Install WhatsApp, or call the trainer instead.'
          : 'The number saved for ${trainer.name} is not a full mobile number.',
    );
  }
}
