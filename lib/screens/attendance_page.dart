import 'package:fitstrong_gym/src/custom_import.dart';
import 'package:intl/intl.dart';

/// Attendance history, grouped by month with the newest first.
class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAndSetGymId();
  }

  Future<void> _fetchAndSetGymId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await Provider.of<AttendanceProvider>(context, listen: false)
          .setGymId(user.uid);
    }
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.shadcn;
    final provider = Provider.of<AttendanceProvider>(context);
    final allAttendance = provider.allAttendance;

    // The records arrive newest first, so walking them in order already puts
    // the months and the days inside them in the right order. The old screen
    // sorted month names through a lookup table to achieve the same thing,
    // because the time was spread across four separate strings.
    //
    // Everything the list needs is gathered in this one pass. Asking the
    // provider for each day's head count while building the rows instead
    // would re-read the whole history once per row.
    final months = <String, List<String>>{};
    final membersSeen = <String, Set<String>>{};
    for (final record in allAttendance) {
      final dates = months.putIfAbsent(record.monthLabel, () => <String>[]);
      // Sorted by time, so every record for one day sits next to the rest.
      if (dates.isEmpty || dates.last != record.dateKey) {
        dates.add(record.dateKey);
      }
      membersSeen
          .putIfAbsent(record.dateKey, () => <String>{})
          .add(record.memberId);
    }
    final monthLabels = months.keys.toList();

    return AppScaffold(
      title: 'Attendance',
      automaticallyImplyLeading: false,
      body: _isLoading
          ? const Loading()
          : allAttendance.isEmpty
              ? const AttendanceQuietBox()
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(
                    ShadcnSpacing.lg,
                    ShadcnSpacing.md,
                    ShadcnSpacing.lg,
                    ShadcnSpacing.xl4,
                  ),
                  itemCount: monthLabels.length,
                  itemBuilder: (context, index) {
                    final month = monthLabels[index];
                    final dates = months[month]!;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (index != 0) const ShadcnGap(ShadcnSpacing.xl),
                        Padding(
                          padding: const EdgeInsets.only(
                            bottom: ShadcnSpacing.sm,
                          ),
                          child: Row(
                            children: [
                              ShadcnText(month, variant: ShadcnTextVariant.h4),
                              const ShadcnGap(ShadcnSpacing.sm),
                              Text(
                                '${dates.length} day${dates.length == 1 ? '' : 's'}',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: t.mutedForeground,
                                ),
                              ),
                            ],
                          ),
                        ),
                        for (final date in dates)
                          Padding(
                            padding:
                                const EdgeInsets.only(bottom: ShadcnSpacing.sm),
                            child: ShadcnCard(
                              padding: const EdgeInsets.symmetric(
                                horizontal: ShadcnSpacing.lg,
                                vertical: ShadcnSpacing.md,
                              ),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      AttendanceDetailPage(date: date),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.event_available_rounded,
                                    size: 18,
                                    color: t.primary,
                                  ),
                                  const ShadcnGap(ShadcnSpacing.md),
                                  Expanded(
                                    child: Text(
                                      formatAttendanceDate(date),
                                      style: TextStyle(
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.w500,
                                        color: t.cardForeground,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '${membersSeen[date]?.length ?? 0}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: t.mutedForeground,
                                    ),
                                  ),
                                  Icon(
                                    Icons.chevron_right_rounded,
                                    color: t.mutedForeground,
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
    );
  }
}

/// Turns a stored "2024-11-25" into "25 November 2024".
///
/// Shared by the list and the detail page, which each had their own copy.
String formatAttendanceDate(String date) {
  try {
    return DateFormat('d MMMM yyyy').format(DateTime.parse(date));
  } catch (_) {
    return date;
  }
}
