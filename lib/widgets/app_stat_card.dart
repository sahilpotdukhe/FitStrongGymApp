import 'package:fitstrong_gym/src/custom_import.dart';

/// A single headline number — total members, active, expired, revenue.
///
/// Replaces four near-identical hand-built containers on the dashboard, each
/// with its own gradient and fixed pixel size. The number leads, the label
/// follows, and the accent color carries the meaning.
class AppStatCard extends StatelessWidget {
  const AppStatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.accent,
    this.accentSurface,
    this.onTap,
    this.footnote,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color accent;

  /// Tint behind the icon. Defaults to a faded [accent], which works on both
  /// light and dark cards.
  final Color? accentSurface;
  final VoidCallback? onTap;
  final String? footnote;

  @override
  Widget build(BuildContext context) {
    final t = context.shadcn;
    return ShadcnCard(
      onTap: onTap,
      padding: const EdgeInsets.all(ShadcnSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                height: 36,
                width: 36,
                decoration: BoxDecoration(
                  color: accentSurface ?? accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(t.radiusMd),
                ),
                child: Icon(icon, size: 19, color: accent),
              ),
              const Spacer(),
              if (onTap != null)
                Icon(
                  Icons.arrow_outward_rounded,
                  size: 16,
                  color: t.mutedForeground,
                ),
            ],
          ),
          const ShadcnGap(ShadcnSpacing.md),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 26,
              height: 1.1,
              fontWeight: FontWeight.w700,
              color: t.cardForeground,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 13, color: t.mutedForeground),
          ),
          if (footnote != null) ...[
            const SizedBox(height: 6),
            Text(
              footnote!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                color: accent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// A titled section with an optional trailing action, used to break long
/// screens into scannable blocks.
class AppSectionHeader extends StatelessWidget {
  const AppSectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Flexible with an ellipsis: on a narrow phone a long section title
        // would otherwise run past the edge of the screen, which Flutter
        // reports as a layout error rather than just a clipped word.
        Flexible(
          child: ShadcnText(
            title,
            variant: ShadcnTextVariant.h4,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (actionLabel != null && onAction != null)
          ShadcnButton(
            variant: ShadcnButtonVariant.link,
            size: ShadcnButtonSize.sm,
            onPressed: onAction,
            child: Text(actionLabel!),
          ),
      ],
    );
  }
}
