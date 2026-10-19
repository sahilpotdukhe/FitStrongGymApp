import 'package:fitstrong_gym/src/custom_import.dart';
import 'package:intl/intl.dart';

/// A deleted member, with the two things you can do about it: put them back,
/// or remove them for good.
class RecycleMemberCard extends StatefulWidget {
  const RecycleMemberCard({super.key, required this.recycleBinMember});

  final MemberModel recycleBinMember;

  @override
  State<RecycleMemberCard> createState() => _RecycleMemberCardState();
}

class _RecycleMemberCardState extends State<RecycleMemberCard> {
  bool _busy = false;

  Future<void> _restore() async {
    final member = widget.recycleBinMember;
    final confirmed = await showShadcnAlertDialog(
      context,
      icon: const ShadcnIconBadge(Icons.restore_rounded),
      title: 'Restore ${member.name}?',
      description:
          'They go back into your member list with the same plan and dates.',
      confirmLabel: 'Restore',
    );
    if (confirmed != true || !mounted) return;

    setState(() => _busy = true);
    final memberProvider = Provider.of<MemberProvider>(context, listen: false);
    try {
      await memberProvider.restoreMember(member);
      if (!mounted) return;
      showSuccessToast(context, '${member.name} restored');
    } catch (_) {
      if (!mounted) return;
      showErrorToast(context, 'Could not restore member');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _deleteForever() async {
    final member = widget.recycleBinMember;
    final t = context.shadcn;
    final confirmed = await showShadcnAlertDialog(
      context,
      icon: ShadcnIconBadge(
        Icons.delete_forever_rounded,
        color: t.destructive,
      ),
      title: 'Delete ${member.name} forever?',
      description:
          'Their record and photo are removed permanently. This cannot be '
          'undone.',
      confirmLabel: 'Delete forever',
      destructive: true,
    );
    if (confirmed != true || !mounted) return;

    setState(() => _busy = true);
    final memberProvider = Provider.of<MemberProvider>(context, listen: false);
    try {
      await memberProvider.permanentlyDeleteMember(member);
      if (!mounted) return;
      showSuccessToast(context, '${member.name} deleted permanently');
    } catch (_) {
      if (!mounted) return;
      showErrorToast(context, 'Could not delete member');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.shadcn;
    final status = context.status;
    final member = widget.recycleBinMember;
    final plans = Provider.of<GymPlanProvider>(context, listen: false).plans;
    final planName =
        GymPlanModel.findById(plans, member.planId)?.name ?? 'Unknown plan';

    return Padding(
      padding: const EdgeInsets.only(bottom: ShadcnSpacing.md),
      child: ShadcnCard(
        padding: const EdgeInsets.all(ShadcnSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Dimmed, because this person is not an active member any
                // more — the old card looked identical to a live one.
                Opacity(
                  opacity: 0.6,
                  child: AppAvatar(
                    member.photoUrl,
                    size: 48,
                    backgroundColor: t.muted,
                  ),
                ),
                const ShadcnGap(ShadcnSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        member.name,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                          color: t.cardForeground,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$planName · ${member.mobileNumber}',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          color: t.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                ),
                ShadcnBadge(
                  style: ShadcnBadgeStyle(
                    backgroundColor: status.dangerSurface,
                    foregroundColor: status.dangerForeground,
                    textStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: const Text('Deleted'),
                ),
              ],
            ),
            const ShadcnGap(ShadcnSpacing.md),
            Text(
              'Joined ${DateFormat('d MMM yyyy').format(member.dateOfAdmission)} · '
              'Expired ${DateFormat('d MMM yyyy').format(member.expiryDate)}',
              style: TextStyle(fontSize: 12.5, color: t.mutedForeground),
            ),
            const ShadcnGap(ShadcnSpacing.md),
            const ShadcnSeparator(),
            const ShadcnGap(ShadcnSpacing.md),
            Row(
              children: [
                Expanded(
                  child: ShadcnButton(
                    size: ShadcnButtonSize.sm,
                    loading: _busy,
                    leading: const Icon(Icons.restore_rounded, size: 16),
                    onPressed: _restore,
                    child: const Text('Restore'),
                  ),
                ),
                const ShadcnGap(ShadcnSpacing.sm),
                Expanded(
                  child: ShadcnButton(
                    variant: ShadcnButtonVariant.outline,
                    size: ShadcnButtonSize.sm,
                    foregroundColor: t.destructive,
                    leading: const Icon(Icons.delete_forever_rounded, size: 16),
                    onPressed: _busy ? null : _deleteForever,
                    child: const Text('Delete'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
