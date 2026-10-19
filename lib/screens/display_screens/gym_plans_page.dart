import 'package:fitstrong_gym/src/custom_import.dart';

/// Every membership plan the gym sells, longest first, with the retired ones
/// tucked underneath.
class GymPlansPage extends StatefulWidget {
  const GymPlansPage({super.key});

  @override
  State<GymPlansPage> createState() => _GymPlansPageState();
}

class _GymPlansPageState extends State<GymPlansPage> {
  bool _showHidden = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final planProvider = Provider.of<GymPlanProvider>(context, listen: false);
    final memberProvider = Provider.of<MemberProvider>(context, listen: false);
    await planProvider.fetchPlans();
    // The member list is what tells us whether a plan is safe to delete, so
    // it has to be loaded before the delete button can answer honestly.
    if (memberProvider.members.isEmpty) await memberProvider.getAllMembers();
  }

  /// Longest plans first, so the yearly offer leads the list and the trial
  /// packs sit at the bottom.
  List<GymPlanModel> _sorted(List<GymPlanModel> plans) {
    final sorted = [...plans];
    sorted.sort((a, b) => b.lengthInDays.compareTo(a.lengthInDays));
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    final t = context.shadcn;
    final planProvider = Provider.of<GymPlanProvider>(context);
    final memberProvider = Provider.of<MemberProvider>(context);
    final onSale = _sorted(planProvider.sellablePlans);
    final hidden = _sorted(planProvider.hiddenPlans);

    return Stack(
      children: [
        AppScaffold(
          title: 'Membership plans',
          leading: ShadcnButton(
            variant: ShadcnButtonVariant.ghost,
            size: ShadcnButtonSize.icon,
            // Plain pop: go back to whatever opened this page. The old
            // `popAndPushNamed('/home')` built a second home screen on top
            // of the one already underneath, which is what made home blink.
            onPressed: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back_rounded, size: 20),
          ),
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: t.primary,
            foregroundColor: t.primaryForeground,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddGymPlanPage()),
            ),
            icon: const Icon(Icons.add_rounded),
            label: const Text('New plan'),
          ),
          body: onSale.isEmpty && hidden.isEmpty
              ? const PlansQuietBox()
              : RefreshIndicator(
                  color: t.primary,
                  backgroundColor: t.card,
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(
                      ShadcnSpacing.lg,
                      ShadcnSpacing.md,
                      ShadcnSpacing.lg,
                      ShadcnSpacing.xl4,
                    ),
                    children: [
                      for (final plan in onSale)
                        _PlanCard(
                          plan: plan,
                          memberCount: _countFor(plan, memberProvider),
                          onEdit: () => _openEditor(plan),
                          onHide: () => _setHidden(plan, true),
                          onDelete: () => _confirmDelete(plan),
                        ),
                      if (hidden.isNotEmpty)
                        _HiddenSection(
                          plans: hidden,
                          expanded: _showHidden,
                          onToggle: () =>
                              setState(() => _showHidden = !_showHidden),
                          countFor: (plan) => _countFor(plan, memberProvider),
                          onUnhide: (plan) => _setHidden(plan, false),
                          onDelete: _confirmDelete,
                        ),
                    ],
                  ),
                ),
        ),
        if (_busy) const AppSavingOverlay(message: 'Updating plans…'),
      ],
    );
  }

  int _countFor(GymPlanModel plan, MemberProvider provider) {
    return GymPlanProvider.membersOnPlan(
      plan.id,
      members: provider.members,
      recycleBinMembers: provider.recycleBinMembers,
    );
  }

  void _openEditor(GymPlanModel plan) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditPlanPage(plan: plan)),
    );
  }

  Future<void> _setHidden(GymPlanModel plan, bool hidden) async {
    setState(() => _busy = true);
    try {
      await Provider.of<GymPlanProvider>(context, listen: false)
          .setPlanHidden(plan.id, hidden);
      if (!mounted) return;
      showSuccessToast(
        context,
        hidden ? 'Plan hidden' : 'Plan back on sale',
        description: hidden
            ? 'It will not show up when adding or renewing a member.'
            : 'It can be picked again when adding or renewing a member.',
      );
    } catch (_) {
      if (!mounted) return;
      showErrorDialog(
        context: context,
        title: 'Could not update the plan',
        desc: 'Check your connection and try again.',
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// Deleting is only offered when nobody is on the plan; otherwise the
  /// owner is asked whether to hide it instead.
  Future<void> _confirmDelete(GymPlanModel plan) async {
    setState(() => _busy = true);
    final inUse = await PlanActions.countMembersOn(context, plan);
    if (!mounted) return;
    setState(() => _busy = false);
    if (inUse == null) return;

    final choice = await PlanActions.askRemoval(context, plan, inUse);
    if (!mounted) return;

    switch (choice) {
      case PlanRemoval.cancel:
        return;
      case PlanRemoval.hide:
        await _setHidden(plan, true);
      case PlanRemoval.delete:
        await _delete(plan);
    }
  }

  Future<void> _delete(GymPlanModel plan) async {
    setState(() => _busy = true);
    try {
      await Provider.of<GymPlanProvider>(context, listen: false)
          .deletePlan(plan.id);
      if (!mounted) return;
      showSuccessToast(context, 'Plan deleted');
    } catch (_) {
      if (!mounted) return;
      showErrorDialog(
        context: context,
        title: 'Could not delete the plan',
        desc: 'Check your connection and try again.',
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}

/// A plan, shown as a price card: how long it runs, what it costs, what that
/// works out to per month, and how many people are on it.
class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.plan,
    required this.memberCount,
    required this.onEdit,
    required this.onHide,
    required this.onDelete,
    this.muted = false,
    this.onUnhide,
  });

  final GymPlanModel plan;
  final int memberCount;
  final VoidCallback onEdit;
  final VoidCallback onHide;
  final VoidCallback onDelete;

  /// Hidden plans are drawn flatter, so the list you actually sell from
  /// stands out from the retired one.
  final bool muted;
  final VoidCallback? onUnhide;

  /// Longer plans read as more premium. One accent colour per tier carries
  /// that without the metallic gradients the old card used, which went
  /// muddy in dark mode.
  Color _tierColor(AppStatus status, ShadcnTheme t) {
    if (muted) return t.mutedForeground;
    if (plan.months >= 12) return status.warning;
    if (plan.months >= 6) return status.info;
    if (plan.months >= 3) return status.success;
    return t.mutedForeground;
  }

  /// The big number on the badge, with its unit underneath: "12 MO" for a
  /// yearly plan, "15 D" for a trial pack. Far more use at a glance than the
  /// same crown on every card.
  ({String value, String unit}) get _badge {
    if (plan.months > 0) {
      return (value: '${plan.months}', unit: plan.months == 1 ? 'MONTH' : 'MO');
    }
    if (plan.days > 0) {
      return (value: '${plan.days}', unit: plan.days == 1 ? 'DAY' : 'DAYS');
    }
    return (value: '—', unit: 'SET');
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
        onTap: onEdit,
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // A thin band of the tier colour across the top, so the yearly,
            // half-yearly and short plans are told apart before reading a
            // single word.
            Container(
              height: 4,
              decoration: BoxDecoration(
                color: tier.withValues(alpha: muted ? 0.3 : 1),
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(t.radiusXl),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(ShadcnSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _DurationBadge(value: _badge.value, unit: _badge.unit,
                          color: tier),
                      const ShadcnGap(ShadcnSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    plan.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 16.5,
                                      fontWeight: FontWeight.w700,
                                      color: muted
                                          ? t.mutedForeground
                                          : t.cardForeground,
                                    ),
                                  ),
                                ),
                                if (muted) ...[
                                  const SizedBox(width: 6),
                                  const ShadcnBadge(
                                    variant: ShadcnBadgeVariant.outline,
                                    child: Text('Hidden'),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 3),
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
                      _PlanMenu(
                        muted: muted,
                        onEdit: onEdit,
                        onHide: onHide,
                        onUnhide: onUnhide,
                        onDelete: onDelete,
                      ),
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
                              fontSize: 23,
                              height: 1.2,
                              fontWeight: FontWeight.w700,
                              color:
                                  muted ? t.mutedForeground : t.cardForeground,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '$_perMonth / month',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: t.mutedForeground,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Icon(
                                Icons.group_outlined,
                                size: 13,
                                color: t.mutedForeground,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                memberCount == 1
                                    ? '1 member'
                                    : '$memberCount members',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: t.mutedForeground,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The tier square: plan length as a number you can read across the room.
class _DurationBadge extends StatelessWidget {
  const _DurationBadge({
    required this.value,
    required this.unit,
    required this.color,
  });

  final String value;
  final String unit;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final t = context.shadcn;
    return Container(
      height: 52,
      width: 52,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(t.radiusLg),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            maxLines: 1,
            style: TextStyle(
              fontSize: 20,
              height: 1,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            unit,
            maxLines: 1,
            style: TextStyle(
              fontSize: 8.5,
              height: 1,
              letterSpacing: 0.5,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// Edit, hide and delete, behind one button so the card stays clean.
class _PlanMenu extends StatelessWidget {
  const _PlanMenu({
    required this.muted,
    required this.onEdit,
    required this.onHide,
    required this.onUnhide,
    required this.onDelete,
  });

  final bool muted;
  final VoidCallback onEdit;
  final VoidCallback onHide;
  final VoidCallback? onUnhide;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final t = context.shadcn;
    return PopupMenuButton<String>(
      tooltip: 'Plan options',
      icon: Icon(Icons.more_vert_rounded, size: 20, color: t.mutedForeground),
      padding: EdgeInsets.zero,
      color: t.popover,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(t.radiusLg),
        side: BorderSide(color: t.border),
      ),
      onSelected: (value) {
        switch (value) {
          case 'edit':
            onEdit();
          case 'hide':
            onHide();
          case 'unhide':
            onUnhide?.call();
          case 'delete':
            onDelete();
        }
      },
      itemBuilder: (context) => [
        _item('edit', Icons.edit_outlined, 'Edit plan', t.popoverForeground),
        if (muted)
          _item('unhide', Icons.visibility_outlined, 'Put back on sale',
              t.popoverForeground)
        else
          _item('hide', Icons.visibility_off_outlined, 'Hide from new sales',
              t.popoverForeground),
        _item('delete', Icons.delete_outline_rounded, 'Delete plan',
            t.destructive),
      ],
    );
  }

  PopupMenuItem<String> _item(
    String value,
    IconData icon,
    String label,
    Color color,
  ) {
    return PopupMenuItem<String>(
      value: value,
      height: 44,
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: ShadcnSpacing.md),
          Text(label, style: TextStyle(fontSize: 14, color: color)),
        ],
      ),
    );
  }
}

/// Retired plans, collapsed by default so they do not crowd the plans the
/// gym actually sells.
class _HiddenSection extends StatelessWidget {
  const _HiddenSection({
    required this.plans,
    required this.expanded,
    required this.onToggle,
    required this.countFor,
    required this.onUnhide,
    required this.onDelete,
  });

  final List<GymPlanModel> plans;
  final bool expanded;
  final VoidCallback onToggle;
  final int Function(GymPlanModel) countFor;
  final void Function(GymPlanModel) onUnhide;
  final void Function(GymPlanModel) onDelete;

  @override
  Widget build(BuildContext context) {
    final t = context.shadcn;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const ShadcnGap(ShadcnSpacing.sm),
        InkWell(
          onTap: onToggle,
          borderRadius: BorderRadius.circular(t.radiusMd),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: ShadcnSpacing.md,
              horizontal: ShadcnSpacing.sm,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.visibility_off_outlined,
                  size: 16,
                  color: t.mutedForeground,
                ),
                const SizedBox(width: ShadcnSpacing.sm),
                Text(
                  'Hidden plans (${plans.length})',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: t.mutedForeground,
                  ),
                ),
                const Spacer(),
                Icon(
                  expanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  size: 20,
                  color: t.mutedForeground,
                ),
              ],
            ),
          ),
        ),
        if (expanded)
          for (final plan in plans)
            _PlanCard(
              plan: plan,
              memberCount: countFor(plan),
              muted: true,
              onEdit: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditPlanPage(plan: plan),
                ),
              ),
              onHide: () {},
              onUnhide: () => onUnhide(plan),
              onDelete: () => onDelete(plan),
            ),
      ],
    );
  }
}
