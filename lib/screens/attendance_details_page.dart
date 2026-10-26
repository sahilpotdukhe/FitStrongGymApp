import 'package:fitstrong_gym/src/custom_import.dart';

/// Who came in on one day, and at what time.
class AttendanceDetailPage extends StatelessWidget {
  const AttendanceDetailPage({super.key, required this.date});

  final String date;

  @override
  Widget build(BuildContext context) {
    final t = context.shadcn;
    final status = context.status;
    final provider = Provider.of<AttendanceProvider>(context);
    final scans = provider.getByDate(date);
    // Read once for the whole list rather than per row: a check-in stores
    // only the member id, so each row has to be matched back to a person.
    final memberProvider = Provider.of<MemberProvider>(context);

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
                          '${scans.length} member'
                          '${scans.length == 1 ? '' : 's'} checked in',
                          variant: ShadcnTextVariant.small,
                        ),
                      ],
                    ),
                  );
                }

                final scan = scans[index - 1];
                final member = memberProvider.byId(scan.memberId);

                return Padding(
                  padding: const EdgeInsets.only(bottom: ShadcnSpacing.sm),
                  child: ShadcnCard(
                    padding: const EdgeInsets.symmetric(
                      horizontal: ShadcnSpacing.lg,
                      vertical: ShadcnSpacing.md,
                    ),
                    // Opens the person behind the check-in: their plan,
                    // expiry, trainer and payment history.
                    onTap: () => _openMember(context, member, scan.memberName),
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
                            backgroundColor: status.successSurface,
                            foregroundColor: status.successForeground,
                            textStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          child: Text(scan.timeLabel),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          size: 20,
                          color: t.mutedForeground,
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

/// Opens [member], or explains why it cannot be opened.
///
/// A check-in outlives the member record: the name is copied into the
/// record at scan time precisely so history survives a deletion. When the
/// person is gone there is nothing to show, and saying so is better than a
/// tap that silently does nothing.
void _openMember(BuildContext context, MemberModel? member, String name) {
  if (member == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$name is no longer in your member list.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
    return;
  }

  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => MemberDetailsPage(member: member)),
  );
}
