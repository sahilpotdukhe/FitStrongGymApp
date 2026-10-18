import 'package:fitstrong_gym/src/custom_import.dart';

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

    // Group by year > month > date
    final grouped = <String, Map<String, List<String>>>{};
    for (var record in allAttendance) {
      final year = record.year;
      final month = "${record.month} $year";
      grouped.putIfAbsent(year, () => {});
      grouped[year]!.putIfAbsent(month, () => []);
      if (!grouped[year]![month]!.contains(record.date)) {
        grouped[year]![month]!.add(record.date);
      }
    }

    final years = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    // Flattened into one list of months so the page is a single ListView
    // instead of a ListView whose every item builds another Column of
    // Columns — same result, far less work per scroll.
    final months = <String>[];
    for (final year in years) {
      final yearMonths = grouped[year]!.keys.toList()
        ..sort((a, b) => _monthSortValue(b).compareTo(_monthSortValue(a)));
      months.addAll(yearMonths);
    }

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
                  itemCount: months.length,
                  itemBuilder: (context, index) {
                    final month = months[index];
                    final year = month.split(' ').last;
                    final dates = grouped[year]![month]!
                      ..sort((a, b) => b.compareTo(a));

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
                                      _formatReadableDate(date),
                                      style: TextStyle(
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.w500,
                                        color: t.cardForeground,
                                      ),
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

  /// Sort months by value for descending order (January = 1, December = 12)
  int _monthSortValue(String monthYear) {
    final parts = monthYear.split(' ');
    const monthOrder = {
      'January': 1,
      'February': 2,
      'March': 3,
      'April': 4,
      'May': 5,
      'June': 6,
      'July': 7,
      'August': 8,
      'September': 9,
      'October': 10,
      'November': 11,
      'December': 12
    };
    // A record with a missing or odd month string used to bring the whole
    // screen down here, because int.parse throws on anything unexpected.
    if (parts.length < 2) return 0;
    final year = int.tryParse(parts[1]) ?? 0;
    return year * 100 + (monthOrder[parts[0]] ?? 0);
  }

  String _formatReadableDate(String date) => formatAttendanceDate(date);
}

/// Turns a stored "2024-11-25" into "25 November 2024".
///
/// Shared by the list and the detail page, which each had their own copy.
String formatAttendanceDate(String date) {
  try {
    final parts = date.split('-'); // "2024-11-25"
    final day = int.parse(parts[2]);
    final month = int.parse(parts[1]);
    final year = parts[0];
    const monthNames = [
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return '$day ${monthNames[month]} $year';
  } catch (_) {
    return date;
  }
}
