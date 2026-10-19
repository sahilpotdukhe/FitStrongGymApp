import 'package:fitstrong_gym/src/custom_import.dart';

/// What the owner chose when asked about removing a plan.
enum PlanRemoval { cancel, delete, hide }

/// The questions asked before a plan is removed, shared by the plans list
/// and the edit screen so both behave identically.
///
/// A plan nobody is on can be deleted outright. A plan with members on it
/// cannot: deleting it would leave their membership pointing at nothing and
/// blank the plan name on every invoice already raised against it. In that
/// case hiding is offered instead, which retires the plan without touching
/// anybody's record.
class PlanActions {
  const PlanActions._();

  /// Counts the members on [plan], loading the member list and the recycle
  /// bin first. Returns null when they could not be loaded — in which case
  /// it is not safe to delete anything, and the owner has been told why.
  static Future<int?> countMembersOn(
    BuildContext context,
    GymPlanModel plan,
  ) async {
    final memberProvider = Provider.of<MemberProvider>(context, listen: false);
    try {
      if (memberProvider.members.isEmpty) {
        await memberProvider.getAllMembers();
      }
      // The recycle bin counts too: a member restored later would otherwise
      // come back onto a plan that had been deleted meanwhile.
      await memberProvider.fetchRecycleBinMembers();
    } catch (_) {
      if (!context.mounted) return null;
      await showErrorDialog(
        context: context,
        title: 'Could not check the plan',
        desc: 'The member list could not be loaded, so it is not safe to '
            'delete this plan yet. Check your connection and try again.',
      );
      return null;
    }

    return GymPlanProvider.membersOnPlan(
      plan.id,
      members: memberProvider.members,
      recycleBinMembers: memberProvider.recycleBinMembers,
    );
  }

  /// Asks the right question for how many members are on the plan, and
  /// reports back what the owner decided.
  static Future<PlanRemoval> askRemoval(
    BuildContext context,
    GymPlanModel plan,
    int membersOnPlan,
  ) async {
    if (membersOnPlan > 0) {
      final people =
          membersOnPlan == 1 ? '1 member is' : '$membersOnPlan members are';
      final hide = await showShadcnDialog<bool>(
        context: context,
        builder: (dialogContext) => ShadcnDialog(
          icon: ShadcnIconBadge(
            Icons.info_outline_rounded,
            color: context.status.info,
          ),
          title: 'This plan is still in use',
          description: '$people on "${plan.name}", so it cannot be deleted — '
              'their membership and their past invoices depend on it.\n\n'
              'Hiding it instead takes it off the list you pick from when '
              'adding or renewing a member, and changes nothing for the '
              'members already on it.',
          footer: [
            ShadcnButton(
              fullWidth: true,
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Hide this plan'),
            ),
            ShadcnButton(
              fullWidth: true,
              variant: ShadcnButtonVariant.secondary,
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
          ],
        ),
      );
      return hide == true ? PlanRemoval.hide : PlanRemoval.cancel;
    }

    final confirmed = await showShadcnDialog<bool>(
      context: context,
      builder: (dialogContext) => ShadcnDialog(
        icon: ShadcnIconBadge(
          Icons.delete_outline_rounded,
          color: context.shadcn.destructive,
        ),
        title: 'Delete "${plan.name}"?',
        description: 'Nobody is on this plan, so removing it changes nothing '
            'for your members. This cannot be undone.',
        footer: [
          ShadcnButton(
            fullWidth: true,
            variant: ShadcnButtonVariant.destructive,
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete plan'),
          ),
          ShadcnButton(
            fullWidth: true,
            variant: ShadcnButtonVariant.secondary,
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
    return confirmed == true ? PlanRemoval.delete : PlanRemoval.cancel;
  }
}
