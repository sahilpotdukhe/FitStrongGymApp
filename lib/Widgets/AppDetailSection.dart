import 'package:fitstrong_gym/src/custom_import.dart';

/// A titled card holding label/value rows — the shape every "details" screen
/// in the app repeats.
class AppDetailSection extends StatelessWidget {
  const AppDetailSection({
    super.key,
    required this.title,
    required this.children,
    this.action,
  });

  final String title;
  final List<Widget> children;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: ShadcnText(title, variant: ShadcnTextVariant.h4),
            ),
            if (action != null) action!,
          ],
        ),
        const ShadcnGap(ShadcnSpacing.md),
        ShadcnCard(
          padding: const EdgeInsets.symmetric(
            horizontal: ShadcnSpacing.lg,
            vertical: ShadcnSpacing.xs,
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

/// One fact inside an [AppDetailSection]. Label on the left, value on the
/// right, so a column of them lines up instead of each value sitting under
/// its own label.
class AppInfoRow extends StatelessWidget {
  const AppInfoRow({
    super.key,
    required this.label,
    required this.value,
    this.valueWidget,
    this.icon,
    this.last = false,
  });

  final String label;
  final String value;

  /// Replaces the plain text value — a badge, a link, a chip.
  final Widget? valueWidget;
  final IconData? icon;

  /// Drops the divider under the row; set on the final row of a card.
  final bool last;

  @override
  Widget build(BuildContext context) {
    final t = context.shadcn;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: ShadcnSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: t.mutedForeground),
                const ShadcnGap(ShadcnSpacing.sm),
              ],
              Expanded(
                flex: 4,
                child: Text(
                  label,
                  style: TextStyle(fontSize: 13.5, color: t.mutedForeground),
                ),
              ),
              const ShadcnGap(ShadcnSpacing.md),
              Expanded(
                flex: 5,
                child: valueWidget ??
                    Text(
                      // An empty field reads as a dash rather than a blank
                      // gap, so it's clear nothing was recorded.
                      value.trim().isEmpty ? '—' : value,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: t.cardForeground,
                      ),
                    ),
              ),
            ],
          ),
        ),
        if (!last) Divider(height: 1, color: t.border),
      ],
    );
  }
}
