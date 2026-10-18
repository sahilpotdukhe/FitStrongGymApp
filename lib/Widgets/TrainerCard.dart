import 'package:fitstrong_gym/src/custom_import.dart';

/// A trainer in a list: photo, what they coach, their shift, and how many
/// members they look after.
class TrainerCard extends StatelessWidget {
  const TrainerCard({
    super.key,
    required this.trainer,
    required this.memberCount,
    this.onTap,
  });

  final TrainerModel trainer;
  final int memberCount;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.shadcn;
    final status = context.status;

    return Padding(
      padding: const EdgeInsets.only(bottom: ShadcnSpacing.md),
      child: ShadcnCard(
        onTap: onTap,
        padding: const EdgeInsets.all(ShadcnSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Opacity(
                  // A trainer who has left is dimmed rather than hidden, so
                  // their members still show who used to coach them.
                  opacity: trainer.isActive ? 1 : 0.55,
                  child: ShadcnAvatar(
                    trainer.photoUrl,
                    size: 52,
                    placeholder: const ShadcnSkeleton.circle(size: 52),
                    initials: trainer.name,
                    backgroundColor: t.secondary,
                  ),
                ),
                const ShadcnGap(ShadcnSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trainer.name,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: t.cardForeground,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        trainer.specialization.isEmpty
                            ? 'Trainer'
                            : trainer.specialization,
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
                ShadcnBadge(
                  style: ShadcnBadgeStyle(
                    backgroundColor: trainer.isActive
                        ? status.successSurface
                        : status.dangerSurface,
                    foregroundColor: trainer.isActive
                        ? status.successForeground
                        : status.dangerForeground,
                    textStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: Text(trainer.isActive ? 'Active' : 'Left'),
                ),
              ],
            ),
            const ShadcnGap(ShadcnSpacing.md),
            Row(
              children: [
                Expanded(
                  child: _Chip(
                    icon: Icons.schedule_rounded,
                    label: trainer.shiftLabel,
                  ),
                ),
                const ShadcnGap(ShadcnSpacing.sm),
                Expanded(
                  child: _Chip(
                    icon: Icons.groups_rounded,
                    label: '$memberCount member'
                        '${memberCount == 1 ? '' : 's'}',
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

class _Chip extends StatelessWidget {
  const _Chip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final t = context.shadcn;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: ShadcnSpacing.sm,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: t.muted,
        borderRadius: BorderRadius.circular(t.radiusSm),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: t.mutedForeground),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12, color: t.mutedForeground),
            ),
          ),
        ],
      ),
    );
  }
}

/// Picks which trainer coaches a member, with "No trainer" always available.
///
/// Shared by the add and edit member forms so the option reads the same in
/// both places.
class AppTrainerSelect extends StatelessWidget {
  const AppTrainerSelect({
    super.key,
    required this.trainers,
    required this.value,
    required this.onChanged,
  });

  final List<TrainerModel> trainers;

  /// '' means no trainer assigned.
  final String value;
  final ValueChanged<String> onChanged;

  static const String noneValue = '';

  @override
  Widget build(BuildContext context) {
    // A stored trainer can be inactive or deleted by the time a member is
    // edited; without this the select would hold a value that isn't in its
    // own list.
    final known = trainers.any((t) => t.id == value);
    final effective = known ? value : noneValue;

    return ShadcnSelect<String>(
      label: 'Trainer',
      helperText: trainers.isEmpty
          ? 'Add trainers from the Account tab to assign one here.'
          : 'Who coaches this member. Optional.',
      value: effective,
      items: [
        const ShadcnSelectItem(value: noneValue, label: 'No trainer'),
        for (final trainer in trainers)
          ShadcnSelectItem(
            value: trainer.id,
            label: trainer.specialization.isEmpty
                ? trainer.name
                : '${trainer.name} · ${trainer.specialization}',
          ),
      ],
      onChanged: onChanged,
    );
  }
}
