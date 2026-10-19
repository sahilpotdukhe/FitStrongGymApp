import 'package:fitstrong_gym/src/custom_import.dart';

/// Empty state for the member lists and the recycle bin.
///
/// `screen` keeps its old contract ("nomembers" vs anything else) so every
/// existing call site works unchanged.
class MembersQuietBox extends StatelessWidget {
  const MembersQuietBox({super.key, this.screen});

  final String? screen;

  @override
  Widget build(BuildContext context) {
    final isMembers = screen == "nomembers";
    return AppEmptyState(
      icon: isMembers
          ? Icons.person_add_alt_1_rounded
          : Icons.delete_outline_rounded,
      title: isMembers ? 'No members yet' : 'Recycle bin is empty',
      description: isMembers
          ? 'Add your first member to start tracking memberships, attendance and payments.'
          : 'Deleted members land here for 30 days before they are removed for good.',
      actionLabel: isMembers ? 'Add member' : 'Go back',
      onAction: () {
        if (isMembers) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => AddMemberPage()),
          );
        } else {
          Navigator.pop(context);
        }
      },
    );
  }
}
