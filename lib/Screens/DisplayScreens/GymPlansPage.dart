import 'package:fitstrong_gym/src/custom_import.dart';

/// Every membership plan the gym sells.
class GymPlansPage extends StatefulWidget {
  const GymPlansPage({super.key});

  @override
  State<GymPlansPage> createState() => _GymPlansPageState();
}

class _GymPlansPageState extends State<GymPlansPage> {
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await Provider.of<GymPlanProvider>(context, listen: false).fetchPlans();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.shadcn;
    final plans = Provider.of<GymPlanProvider>(context).plans;

    return AppScaffold(
      title: 'Membership plans',
      leading: ShadcnButton(
        variant: ShadcnButtonVariant.ghost,
        size: ShadcnButtonSize.icon,
        onPressed: () => Navigator.popAndPushNamed(context, '/home'),
        child: const Icon(Icons.arrow_back_rounded, size: 20),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: t.primary,
        foregroundColor: t.primaryForeground,
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AddGymPlanPage()),
        ),
        child: const Icon(Icons.add_rounded),
      ),
      body: plans.isEmpty
          ? const PlansQuietBox()
          : RefreshIndicator(
              color: t.primary,
              backgroundColor: t.card,
              onRefresh: _load,
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(
                  ShadcnSpacing.lg,
                  ShadcnSpacing.md,
                  ShadcnSpacing.lg,
                  ShadcnSpacing.xl4,
                ),
                itemCount: plans.length,
                itemBuilder: (context, index) => _PlanCard(plan: plans[index]),
              ),
            ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({required this.plan});

  final GymPlanModel plan;

  /// Longer plans read as more premium, which the old card expressed with
  /// five-stop metallic gradients per duration. The same idea survives as a
  /// single tier accent that works in dark mode.
  Color _tierColor(AppStatus status, ShadcnTheme t) {
    if (plan.months >= 12) return status.warning;
    if (plan.months >= 6) return status.info;
    return t.mutedForeground;
  }

  String get _duration {
    final parts = <String>[
      if (plan.months != 0)
        '${plan.months} month${plan.months == 1 ? '' : 's'}',
      if (plan.days != 0) '${plan.days} day${plan.days == 1 ? '' : 's'}',
    ];
    return parts.isEmpty ? 'No duration set' : parts.join(' · ');
  }

  /// Monthly equivalent, so two plans of different lengths can be compared.
  /// Guards against a plan with no duration, which used to divide by zero
  /// and print "Infinity" on the card.
  String get _perMonth {
    final months = plan.months + (plan.days / 30);
    if (months <= 0) return '—';
    return '₹${(plan.fee / months).toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    final t = context.shadcn;
    final status = context.status;
    final tier = _tierColor(status, t);

    return Padding(
      padding: const EdgeInsets.only(bottom: ShadcnSpacing.md),
      child: ShadcnCard(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => EditPlanPage(plan: plan)),
        ),
        padding: const EdgeInsets.all(ShadcnSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  height: 44,
                  width: 44,
                  decoration: BoxDecoration(
                    color: tier.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(t.radiusMd),
                  ),
                  child: FaIcon(
                    FontAwesomeIcons.crown,
                    size: 18,
                    color: tier,
                  ),
                ),
                const ShadcnGap(ShadcnSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plan.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: t.cardForeground,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _duration,
                        style: TextStyle(
                          fontSize: 13,
                          color: t.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.edit_outlined, size: 18, color: t.mutedForeground),
              ],
            ),
            const ShadcnGap(ShadcnSpacing.lg),
            const ShadcnSeparator(),
            const ShadcnGap(ShadcnSpacing.md),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TOTAL',
                      style: TextStyle(
                        fontSize: 10,
                        letterSpacing: 0.6,
                        fontWeight: FontWeight.w600,
                        color: t.mutedForeground,
                      ),
                    ),
                    Text(
                      '₹${plan.fee.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 22,
                        height: 1.2,
                        fontWeight: FontWeight.w700,
                        color: t.cardForeground,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  '$_perMonth / month',
                  style: TextStyle(fontSize: 13, color: t.mutedForeground),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
