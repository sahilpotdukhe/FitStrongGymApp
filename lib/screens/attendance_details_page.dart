import 'package:fitstrong_gym/src/custom_import.dart';

/// Every scan on one day: who, when, and which way through the door.
class AttendanceDetailPage extends StatelessWidget {
  const AttendanceDetailPage({super.key, required this.date});

  final String date;

  @override
  Widget build(BuildContext context) {
    final t = context.shadcn;
    final status = context.status;
    final provider = Provider.of<AttendanceProvider>(context);
    final scans = provider.getByDate(date);
    // A member who came in and left again is one person, not two.
    final people = provider.distinctMembersOn(date);

    return AppScaffold(
      title: formatAttendanceDate(date),
      body: scans.isEmpty
          // Previously white text on a white page, so it read as a blank
          // screen whenever a day had no records.
          ? const AppEmptyState(
              icon: Icons.event_busy_rounded,
              title: 'No check-ins',
              description: 'Nobody was marked present on this date.',
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(
                ShadcnSpacing.lg,
                ShadcnSpacing.md,
                ShadcnSpacing.lg,
                ShadcnSpacing.xl4,
              ),
              itemCount: scans.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: ShadcnSpacing.md),
                    child: Row(
                      children: [
                        Icon(
                          Icons.groups_rounded,
                          size: 18,
                          color: status.success,
                        ),
                        const ShadcnGap(ShadcnSpacing.sm),
                        ShadcnText(
                          '$people member${people == 1 ? '' : 's'} checked in',
                          variant: ShadcnTextVariant.small,
                        ),
                      ],
                    ),
                  );
                }

                final scan = scans[index - 1];
                final isArrival = scan.type == CheckinType.checkIn;

                return Padding(
                  padding: const EdgeInsets.only(bottom: ShadcnSpacing.sm),
                  child: ShadcnCard(
                    padding: const EdgeInsets.symmetric(
                      horizontal: ShadcnSpacing.lg,
                      vertical: ShadcnSpacing.md,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isArrival
                              ? Icons.login_rounded
                              : Icons.logout_rounded,
                          size: 18,
                          color: isArrival
                              ? status.success
                              : t.mutedForeground,
                        ),
                        const ShadcnGap(ShadcnSpacing.md),
                        Expanded(
                          child: Text(
                            scan.memberName,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w500,
                              color: t.cardForeground,
                            ),
                          ),
                        ),
                        ShadcnBadge(
                          style: ShadcnBadgeStyle(
                            backgroundColor: isArrival
                                ? status.successSurface
                                : t.muted,
                            foregroundColor: isArrival
                                ? status.successForeground
                                : t.mutedForeground,
                            textStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          child: Text(scan.timeLabel),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
