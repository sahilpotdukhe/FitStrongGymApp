import 'package:fitstrong_gym/src/custom_import.dart';
import 'package:fitstrong_gym/resources/attendance_insights.dart';

/// What the check-in history says about how the gym is actually used.
///
/// Everything here is counted from arrivals, because arrivals are all the
/// desk records. There is deliberately no "average session length": members
/// are not scanned out, so a visit has a start and no end, and any such
/// figure would be guessed rather than measured.
class AttendanceInsightsPage extends StatefulWidget {
  const AttendanceInsightsPage({super.key});

  @override
  State<AttendanceInsightsPage> createState() =>
      _AttendanceInsightsPageState();
}

class _AttendanceInsightsPageState extends State<AttendanceInsightsPage> {
  Future<void> _refresh() async {
    await Provider.of<AttendanceProvider>(context, listen: false)
        .fetchAttendance();
  }

  @override
  Widget build(BuildContext context) {
    final records = Provider.of<AttendanceProvider>(context).allAttendance;
    final insights = AttendanceInsights.from(records);

    return AppScaffold(
      title: 'Insights',
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: AttendanceInsightsView(insights: insights),
      ),
    );
  }
}

/// Everything the insights page draws, given numbers that are already
/// worked out.
///
/// Split from the page so it can be rendered in a test with a history made
/// up on the spot — the charts are drawn by hand, and a layout mistake in
/// one of them would otherwise only show up on a real device.
class AttendanceInsightsView extends StatelessWidget {
  const AttendanceInsightsView({super.key, required this.insights});

  final AttendanceInsights insights;

  @override
  Widget build(BuildContext context) {
    if (insights.isEmpty) {
      return const AppEmptyState(
        icon: Icons.insights_rounded,
        title: 'Nothing to show yet',
        description:
            'Once members start scanning in at the desk, this page shows '
            'when the gym is busiest and who comes most often.',
      );
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        ShadcnSpacing.lg,
        ShadcnSpacing.md,
        ShadcnSpacing.lg,
        ShadcnSpacing.xl4,
      ),
      children: [
        _Headlines(insights: insights),
        const ShadcnGap(ShadcnSpacing.xl),
        const AppSectionHeader(title: 'When people come in'),
        const ShadcnGap(ShadcnSpacing.sm),
        _HourChart(insights: insights),
        const ShadcnGap(ShadcnSpacing.xl),
        const AppSectionHeader(title: 'Across the week'),
        const ShadcnGap(ShadcnSpacing.sm),
        _WeekChart(insights: insights),
        const ShadcnGap(ShadcnSpacing.xl),
        const AppSectionHeader(title: 'The last two weeks'),
        const ShadcnGap(ShadcnSpacing.sm),
        _TrendChart(insights: insights),
        const ShadcnGap(ShadcnSpacing.xl),
        const AppSectionHeader(title: 'Who comes most'),
        const ShadcnGap(ShadcnSpacing.sm),
        _Regulars(insights: insights),
        const ShadcnGap(ShadcnSpacing.lg),
        const _SessionLengthNote(),
      ],
    );
  }
}

/// The four numbers an owner wants before reading any chart.
class _Headlines extends StatelessWidget {
  const _Headlines({required this.insights});

  final AttendanceInsights insights;

  @override
  Widget build(BuildContext context) {
    final t = context.shadcn;
    final average = insights.averagePerOpenDay;

    return Column(
      children: [
        // IntrinsicHeight so the pair match each other's height. Asking a
        // Row to stretch inside a scrolling list gives it nothing finite to
        // stretch to, which is a layout crash rather than a tall card.
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: AppStatCard(
                  label: 'Busiest hour',
                  value: insights.busiestHourLabel,
                  icon: Icons.schedule_rounded,
                  accent: t.primary,
                ),
              ),
              const ShadcnGap(ShadcnSpacing.md),
              Expanded(
                child: AppStatCard(
                  label: 'Busiest day',
                  value: insights.busiestWeekdayLabel,
                  icon: Icons.calendar_today_rounded,
                  accent: t.primary,
                ),
              ),
            ],
          ),
        ),
        const ShadcnGap(ShadcnSpacing.md),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: AppStatCard(
                  label: 'Check-ins recorded',
                  value: '${insights.totalVisits}',
                  icon: Icons.how_to_reg_rounded,
                  accent: t.primary,
                  footnote:
                      '${average.toStringAsFixed(1)} a day the gym was open',
                ),
              ),
              const ShadcnGap(ShadcnSpacing.md),
              Expanded(
                child: AppStatCard(
                  label: 'Members seen',
                  value: '${insights.distinctMembers}',
                  icon: Icons.groups_rounded,
                  accent: t.primary,
                  footnote: 'Best day: ${insights.bestDay}',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Arrivals by hour, midnight to midnight.
class _HourChart extends StatelessWidget {
  const _HourChart({required this.insights});

  final AttendanceInsights insights;

  @override
  Widget build(BuildContext context) {
    return _ChartCard(
      child: _Bars(
        values: insights.hourCounts,
        // 24 labels will not fit on a phone, so only the quarter marks are
        // written and the rest are read from them.
        labelAt: (i) => switch (i) {
          0 => '12a',
          6 => '6a',
          12 => '12p',
          18 => '6p',
          _ => '',
        },
        tooltipAt: (i, v) =>
            '${_clock(i)} – ${_clock((i + 1) % 24)}: $v check-in'
            '${v == 1 ? '' : 's'}',
        highlight: insights.busiestHour,
      ),
    );
  }

  static String _clock(int hour) {
    final suffix = hour < 12 ? 'AM' : 'PM';
    final display = hour % 12 == 0 ? 12 : hour % 12;
    return '$display $suffix';
  }
}

/// Arrivals by day of the week, Monday first.
class _WeekChart extends StatelessWidget {
  const _WeekChart({required this.insights});

  final AttendanceInsights insights;

  static const List<String> _names = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  @override
  Widget build(BuildContext context) {
    return _ChartCard(
      child: _Bars(
        values: insights.weekdayCounts,
        labelAt: (i) => _names[i],
        tooltipAt: (i, v) =>
            '${_names[i]}: $v check-in${v == 1 ? '' : 's'}',
        highlight: insights.busiestWeekday,
      ),
    );
  }
}

/// The last fourteen days, including the days nobody came.
class _TrendChart extends StatelessWidget {
  const _TrendChart({required this.insights});

  final AttendanceInsights insights;

  @override
  Widget build(BuildContext context) {
    final days = insights.recentDays(14);

    return _ChartCard(
      child: _Bars(
        values: days.map((d) => d.visits).toList(),
        labelAt: (i) => days[i].initial,
        tooltipAt: (i, v) =>
            '${days[i].label}: $v check-in${v == 1 ? '' : 's'}',
      ),
    );
  }
}

/// A row of bars scaled to the tallest one.
///
/// Drawn by hand rather than with a charting package: it is a dozen lines,
/// it follows the app's theme without being told to, and it adds nothing to
/// the download size.
class _Bars extends StatelessWidget {
  const _Bars({
    required this.values,
    required this.labelAt,
    required this.tooltipAt,
    this.highlight,
  });

  final List<int> values;
  final String Function(int index) labelAt;
  final String Function(int index, int value) tooltipAt;

  /// Drawn in the full accent colour; everything else is faded, so the peak
  /// is obvious without reading any numbers.
  final int? highlight;

  @override
  Widget build(BuildContext context) {
    final t = context.shadcn;
    // Guards the division below: an all-zero stretch would otherwise make
    // every bar infinitely tall.
    final tallest =
        values.fold<int>(0, (best, v) => v > best ? v : best).clamp(1, 1 << 30);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 132,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (var i = 0; i < values.length; i++)
                Expanded(
                  child: Tooltip(
                    message: tooltipAt(i, values[i]),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 1.5),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            // A day with nobody still gets a sliver, so the
                            // row reads as a chart rather than a gap.
                            height: values[i] == 0
                                ? 3
                                : 3 + (values[i] / tallest) * 117,
                            decoration: BoxDecoration(
                              color: highlight == i
                                  ? t.primary
                                  : t.primary.withValues(alpha: 0.28),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const ShadcnGap(ShadcnSpacing.sm),
        Row(
          children: [
            for (var i = 0; i < values.length; i++)
              Expanded(
                child: Text(
                  labelAt(i),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.clip,
                  style: TextStyle(
                    fontSize: 10,
                    color: t.mutedForeground,
                    fontWeight: highlight == i ? FontWeight.w700 : null,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ShadcnCard(
      padding: const EdgeInsets.fromLTRB(
        ShadcnSpacing.md,
        ShadcnSpacing.lg,
        ShadcnSpacing.md,
        ShadcnSpacing.md,
      ),
      child: child,
    );
  }
}

/// The members who turn up most often.
class _Regulars extends StatelessWidget {
  const _Regulars({required this.insights});

  final AttendanceInsights insights;

  @override
  Widget build(BuildContext context) {
    final t = context.shadcn;
    final top = insights.topMembers(8);

    return ShadcnCard(
      padding: const EdgeInsets.symmetric(
        horizontal: ShadcnSpacing.lg,
        vertical: ShadcnSpacing.sm,
      ),
      child: Column(
        children: [
          for (var i = 0; i < top.length; i++) ...[
            if (i != 0) Divider(height: 1, color: t.border),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: ShadcnSpacing.md),
              child: Row(
                children: [
                  SizedBox(
                    width: 22,
                    child: Text(
                      '${i + 1}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: t.mutedForeground,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          top[i].memberName.isEmpty
                              ? 'Unnamed member'
                              : top[i].memberName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w500,
                            color: t.cardForeground,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Last in ${top[i].lastVisitLabel}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: t.mutedForeground,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const ShadcnGap(ShadcnSpacing.md),
                  Text(
                    '${top[i].visits}',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: t.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Says plainly what this page cannot tell you, so the absence reads as a
/// decision rather than an oversight.
class _SessionLengthNote extends StatelessWidget {
  const _SessionLengthNote();

  @override
  Widget build(BuildContext context) {
    final t = context.shadcn;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.info_outline_rounded, size: 15, color: t.mutedForeground),
        const ShadcnGap(ShadcnSpacing.sm),
        Expanded(
          child: Text(
            'The desk records arrivals only, so these figures count visits, '
            'not how long anyone stayed.',
            style: TextStyle(fontSize: 12, color: t.mutedForeground),
          ),
        ),
      ],
    );
  }
}
