import 'package:fitstrong_gym/src/custom_import.dart';

/// Empty state for the membership plans list.
class PlansQuietBox extends StatelessWidget {
  const PlansQuietBox({super.key});

  @override
  Widget build(BuildContext context) {
    return AppEmptyState(
      icon: Icons.card_membership_rounded,
      title: 'No membership plans',
      description:
          'Create a plan — monthly, quarterly, yearly — and you can assign it to members as you enrol them.',
      actionLabel: 'Create plan',
      onAction: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AddGymPlanPage()),
      ),
    );
  }
}
