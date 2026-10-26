import 'package:fitstrong_gym/src/custom_import.dart';

/// Asks whether to close FitStrong, and returns true only if the owner said so.
///
/// Back on the home screen used to close the app outright. That is easy to hit
/// by accident one-handed at the front desk, and it throws away whatever was
/// half-filled on the add-member tab.
///
/// Reassurance rather than a warning in the wording: nothing actually is lost,
/// and a dialog that implies otherwise would make people hesitate over a
/// harmless choice.
Future<bool> confirmExitApp(BuildContext context) async {
  final leave = await showShadcnDialog<bool>(
    context: context,
    builder: (dialogContext) => ShadcnDialog(
      icon: ShadcnIconBadge(
        Icons.logout_rounded,
        color: context.shadcn.destructive,
      ),
      title: 'Do you really want to exit?',
      description: 'FitStrong will close. Your members, plans and attendance '
          'are all saved, so nothing is lost.',
      footer: [
        ShadcnButton(
          fullWidth: true,
          variant: ShadcnButtonVariant.destructive,
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: const Text('Exit'),
        ),
        ShadcnButton(
          fullWidth: true,
          variant: ShadcnButtonVariant.secondary,
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text('Stay'),
        ),
      ],
    ),
  );
  // Dismissing by tapping outside gives null, which means stay.
  return leave == true;
}
