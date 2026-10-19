import 'package:fitstrong_gym/src/custom_import.dart';

/// Confirmation shown after a record is saved, renewed or deleted.
///
/// Uses the kit's dialog so it inherits the app's radius, surface and dark
/// mode automatically. The green check is the semantic success color rather
/// than a raw `Colors.green`, so it stays legible on dark surfaces.
Future<void> showSuccessDialog({
  required BuildContext context,
  required String title,
  required String desc,
}) {
  final status = AppStatus.of(context);
  return showShadcnDialog<void>(
    context: context,
    builder: (dialogContext) => ShadcnDialog(
      icon: ShadcnIconBadge(
        Icons.check_circle_rounded,
        color: status.success,
      ),
      title: title,
      description: desc,
      footer: [
        ShadcnButton(
          fullWidth: true,
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: const Text('Done'),
        ),
      ],
    ),
  );
}

/// Error counterpart to [showSuccessDialog], so failures stop appearing as
/// bare snackbars in some places and dialogs in others.
Future<void> showErrorDialog({
  required BuildContext context,
  required String title,
  required String desc,
}) {
  final t = ShadcnTheme.of(context);
  return showShadcnDialog<void>(
    context: context,
    builder: (dialogContext) => ShadcnDialog(
      icon: ShadcnIconBadge(Icons.error_outline_rounded, color: t.destructive),
      title: title,
      description: desc,
      footer: [
        ShadcnButton(
          fullWidth: true,
          variant: ShadcnButtonVariant.secondary,
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: const Text('Close'),
        ),
      ],
    ),
  );
}

/// Short, non-blocking confirmation for actions that don't deserve a modal
/// (copied, refreshed, marked present).
void showSuccessToast(BuildContext context, String title,
    {String? description}) {
  showShadcnToast(
    context,
    title: title,
    description: description,
    variant: ShadcnToastVariant.success,
  );
}

void showErrorToast(BuildContext context, String title, {String? description}) {
  showShadcnToast(
    context,
    title: title,
    description: description,
    variant: ShadcnToastVariant.destructive,
  );
}
