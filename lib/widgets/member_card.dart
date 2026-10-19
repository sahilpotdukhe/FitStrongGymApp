import 'package:fitstrong_gym/src/custom_import.dart';
import 'package:intl/intl.dart';

/// A member in a list: photo, name, plan, status, key dates and the three
/// actions a gym owner reaches for — edit, renew, delete.
class MemberCard extends StatefulWidget {
  const MemberCard({super.key, required this.member, this.onTap});

  final MemberModel member;

  /// Opens the member's full details. Optional so the card still works in
  /// places where tapping it should do nothing.
  final VoidCallback? onTap;

  @override
  State<MemberCard> createState() => _MemberCardState();
}

class _MemberCardState extends State<MemberCard> {
  bool _deleting = false;

  Future<void> _confirmDelete() async {
    final t = context.shadcn;
    final confirmed = await showShadcnAlertDialog(
      context,
      icon: ShadcnIconBadge(
        Icons.delete_outline_rounded,
        color: t.destructive,
      ),
      title: 'Delete ${widget.member.name}?',
      // Says where the record actually goes — the old copy implied the data
      // was gone for good, when it is recoverable from the recycle bin.
      description:
          'They move to the recycle bin, so you can restore them later if '
          'this was a mistake.',
      confirmLabel: 'Delete',
      destructive: true,
    );

    if (confirmed != true || !mounted) return;

    setState(() => _deleting = true);
    final memberProvider = Provider.of<MemberProvider>(context, listen: false);
    try {
      // Goes through the provider, which moves the member into the recycle
      // bin and removes them from the member list in a single batch.
      await memberProvider.deleteMember(widget.member);
      if (!mounted) return;
      showSuccessToast(
        context,
        'Member deleted',
        description: '${widget.member.name} moved to the recycle bin',
      );
    } catch (_) {
      if (!mounted) return;
      showErrorToast(
        context,
        'Could not delete member',
        description: 'Check your connection and try again.',
      );
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.shadcn;
    final plans = Provider.of<GymPlanProvider>(context, listen: false).plans;
    final plan = GymPlanModel.findById(plans, widget.member.planId);
    final planName = plan?.name ?? 'Unknown plan';
    final member = widget.member;

    return Padding(
      padding: const EdgeInsets.only(bottom: ShadcnSpacing.md),
      child: ShadcnCard(
        onTap: widget.onTap,
        padding: const EdgeInsets.all(ShadcnSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppAvatar(
                  member.photoUrl,
                  size: 52,
                  backgroundColor: t.secondary,
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
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: t.cardForeground,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        planName,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          color: t.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                ),
                const ShadcnGap(ShadcnSpacing.sm),
                MembershipBadge(member: member),
              ],
            ),
            const ShadcnGap(ShadcnSpacing.lg),
            // A two-column grid of facts. The old version used a fixed 30px
            // gap between label and value, so longer values pushed out of
            // alignment from row to row.
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Fact(label: 'Mobile', value: member.mobileNumber),
                      const ShadcnGap(ShadcnSpacing.sm),
                      _Fact(label: 'Gender', value: member.gender),
                    ],
                  ),
                ),
                const ShadcnGap(ShadcnSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Fact(
                        label: 'Joined',
                        value: DateFormat('d MMM yyyy')
                            .format(member.dateOfAdmission),
                      ),
                      const ShadcnGap(ShadcnSpacing.sm),
                      _Fact(
                        label: 'Expires',
                        value:
                            DateFormat('d MMM yyyy').format(member.expiryDate),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const ShadcnGap(ShadcnSpacing.lg),
            const ShadcnSeparator(),
            const ShadcnGap(ShadcnSpacing.md),
            Row(
              children: [
                Expanded(
                  child: ShadcnButton(
                    variant: ShadcnButtonVariant.outline,
                    size: ShadcnButtonSize.sm,
                    leading: const Icon(Icons.edit_outlined, size: 16),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            EditMemberDetailsPage(member: member),
                      ),
                    ),
                    child: const Text('Edit'),
                  ),
                ),
                const ShadcnGap(ShadcnSpacing.sm),
                Expanded(
                  child: ShadcnButton(
                    size: ShadcnButtonSize.sm,
                    leading: const Icon(Icons.autorenew_rounded, size: 16),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            RenewMembershipPage(member: member),
                      ),
                    ),
                    child: const Text('Renew'),
                  ),
                ),
                const ShadcnGap(ShadcnSpacing.sm),
                ShadcnButton(
                  variant: ShadcnButtonVariant.ghost,
                  size: ShadcnButtonSize.icon,
                  loading: _deleting,
                  foregroundColor: t.destructive,
                  onPressed: _confirmDelete,
                  child: const Icon(Icons.delete_outline_rounded, size: 18),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// One label/value pair inside a card.
class _Fact extends StatelessWidget {
  const _Fact({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final t = context.shadcn;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 10,
            letterSpacing: 0.6,
            fontWeight: FontWeight.w600,
            color: t.mutedForeground,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          value.isEmpty ? '—' : value,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 13.5, color: t.cardForeground),
        ),
      ],
    );
  }
}
