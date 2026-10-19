import 'package:fitstrong_gym/src/custom_import.dart';

/// Keeps tomorrow morning's notification in step with the member list.
///
/// Whenever the app has fresh member data, it works out what tomorrow's
/// reminder should say and re-books it. If the owner never opens the app
/// again, the last booked reminder still repeats every morning — it just
/// keeps saying what was true the last time the app ran, which is why it is
/// re-booked at every opportunity.
class ReminderScheduler {
  const ReminderScheduler._();

  /// Re-books the morning reminder from the members already in memory.
  /// Quietly does nothing when notifications are not set up or there is
  /// nothing worth saying.
  static Future<void> refresh(BuildContext context) async {
    final service = NotificationService.instance;
    if (!service.isReady) return;

    final members = Provider.of<MemberProvider>(context, listen: false).members;
    if (members.isEmpty) return;

    final digest = ReminderService.build(members);
    await service.scheduleDailyDigest(
      headline: digest.headline,
      memberCount: digest.count,
    );
  }
}
