import 'package:fitstrong_gym/src/custom_import.dart';

/// Who checked in on one particular day, and at what time.
class AttendanceDetailPage extends StatelessWidget {
  const AttendanceDetailPage({super.key, required this.date});

  final String date;

  @override
  Widget build(BuildContext context) {
    final t = context.shadcn;
    final status = context.status;
    final provider = Provider.of<AttendanceProvider>(context);
    final attendanceList = provider.getByDate(date);

    return AppScaffold(
      title: formatAttendanceDate(date),
      body: attendanceList.isEmpty
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
              itemCount: attendanceList.length + 1,
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
                          '${attendanceList.length} member'
                          '${attendanceList.length == 1 ? '' : 's'} checked in',
                          variant: ShadcnTextVariant.small,
                        ),
                      ],
                    ),
                  );
                }

                final a = attendanceList[index - 1];
                return Padding(
                  padding: const EdgeInsets.only(bottom: ShadcnSpacing.sm),
                  child: ShadcnCard(
                    padding: const EdgeInsets.symmetric(
                      horizontal: ShadcnSpacing.lg,
                      vertical: ShadcnSpacing.md,
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 26,
                          child: Text(
                            '$index',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: t.mutedForeground,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            a.name,
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
                            backgroundColor: status.successSurface,
                            foregroundColor: status.successForeground,
                            textStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          child: Text(a.time),
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
