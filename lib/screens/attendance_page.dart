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

  /// Pull down to pick up check-ins the scanner has written since the screen
  /// was opened. Without this the list only ever showed what was there at
  /// load, which on a desk running all day is quickly out of date.
  Future<void> _refresh() async {
    await Provider.of<AttendanceProvider>(context, listen: false)
        .fetchAttendance();
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

    // Records arrive newest first, so the months and days already come out
    // in order. One pass gathers everything: asking the provider for each
    // day's head count per row would re-read the whole history each time.
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
      actions: [
        // Only offered once there is something to draw conclusions from; an
        // empty chart teaches the owner nothing.
        if (allAttendance.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.insights_rounded),
            tooltip: 'Insights',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const AttendanceInsightsPage(),
              ),
            ),
          ),
      ],
      body: _isLoading
          ? const Loading()
          : allAttendance.isEmpty
              // Still refreshable: the first check-in of the day arrives
              // while this empty state is on screen.
              ? RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [
                      SizedBox(height: 120),
                      AttendanceQuietBox(),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView.builder(
                    // A short list must still be draggable, or there is no
                    // way to pull it down.
                    physics: const AlwaysScrollableScrollPhysics(),
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
                                ShadcnText(month,
                                    variant: ShadcnTextVariant.h4),
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
                              padding: const EdgeInsets.only(
                                  bottom: ShadcnSpacing.sm),
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
