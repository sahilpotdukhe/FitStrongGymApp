import 'package:fitstrong_gym/src/custom_import.dart';

/// One empty state for the whole app.
///
/// Every list previously shipped its own near-identical "quiet box" — a white
/// card with a PNG, a bold title and a blue button — each with slightly
/// different padding and corner radius. This wraps the kit's
/// [ShadcnEmptyState] once so all of them match and follow the theme.
class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.actionLabel,
    this.onAction,
    this.secondaryActionLabel,
    this.onSecondaryAction,
  });

  final IconData icon;
  final String title;
  final String description;

  /// The button is only drawn when both a label and a callback are given, so
  /// a purely informational empty state stays uncluttered.
  final String? actionLabel;
  final VoidCallback? onAction;
  final String? secondaryActionLabel;
  final VoidCallback? onSecondaryAction;

  @override
  Widget build(BuildContext context) {
    final hasAction = actionLabel != null && onAction != null;
    final hasSecondary =
        secondaryActionLabel != null && onSecondaryAction != null;

    // A ListView rather than a plain Column: these sit inside pull-to-refresh
    // wrappers, which need a scrollable child even when there is nothing to
    // scroll.
    return ListView(
      padding: const EdgeInsets.symmetric(
        horizontal: ShadcnSpacing.xl2,
        vertical: ShadcnSpacing.xl5,
      ),
      children: [
        ShadcnEmptyState(
          icon: icon,
          title: title,
          description: description,
          action: hasAction
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ShadcnButton(
                      onPressed: onAction,
                      child: Text(actionLabel!),
                    ),
                    if (hasSecondary) ...[
                      const ShadcnGap(ShadcnSpacing.sm),
                      ShadcnButton(
                        variant: ShadcnButtonVariant.ghost,
                        onPressed: onSecondaryAction,
                        child: Text(secondaryActionLabel!),
                      ),
                    ],
                  ],
                )
              : null,
        ),
      ],
    );
  }
}
