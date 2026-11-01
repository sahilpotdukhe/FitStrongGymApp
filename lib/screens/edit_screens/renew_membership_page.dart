import 'package:fitstrong_gym/src/custom_import.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// Extend a member's membership: pick the restart date, the plan they are
/// buying, and record the payment. Ends on their renewal invoice.
class RenewMembershipPage extends StatefulWidget {
  const RenewMembershipPage({required this.member, super.key});

  final MemberModel member;

  @override
  State<RenewMembershipPage> createState() => _RenewMembershipPageState();
}

class _RenewMembershipPageState extends State<RenewMembershipPage> {
  /// The date the renewed term starts from.
  late DateTime _renewalDate;

  GymPlanModel? _selectedPlan;
  String? _planId;
  double _selectedPlanFee = 0.0;
  String? _selectedPaymentMethod;
  static const List<String> _paymentMethods = ['Cash', 'Online'];
  bool _isLoading = false;
  bool _showErrors = false;

  @override
  void initState() {
    super.initState();
    _renewalDate = widget.member.renewalDate;
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.refreshUser();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.shadcn;
    // A renewal has to be sold on a plan still offered, so hidden plans
    // are left out here the same way they are when adding a member.
    final plans = Provider.of<GymPlanProvider>(context).sellablePlans;
    final UserModel? userModel = Provider.of<UserProvider>(context).getUser;

    // Shows what the renewal actually buys before it is saved, which the old
    // form never did — you found out the new expiry date on the invoice.
    final newExpiry = _selectedPlan == null
        ? null
        : MemberModel.addMonths(_renewalDate, _selectedPlan!.months)
            .add(Duration(days: _selectedPlan!.days));

    // Renewals are often backdated on purpose: a member who ran out of money
    // but kept training is charged from the day their last term ended, so the
    // days they have already used are paid for rather than given away. That
    // is why "Renew from" starts on their old expiry date.
    //
    // The catch is that a short plan backdated far enough ends before today.
    // The money is taken, the bill is raised, and the member is still turned
    // away at the scanner — which is the one thing a renewal must not do.
    final today = _dateOnly(DateTime.now());
    final daysAlreadyUsed = today.difference(_dateOnly(_renewalDate)).inDays;
    final endsInThePast =
        newExpiry != null && !_dateOnly(newExpiry).isAfter(today);

    return Stack(
      children: [
        AppScaffold(
          title: 'Renew membership',
          bottomBar: ShadcnButton(
            fullWidth: true,
            size: ShadcnButtonSize.lg,
            loading: _isLoading,
            leading: const Icon(Icons.autorenew_rounded, size: 18),
            onPressed: _renewMembership,
            child: const Text('Renew membership'),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(
              ShadcnSpacing.lg,
              ShadcnSpacing.xl,
              ShadcnSpacing.lg,
              ShadcnSpacing.xl2,
            ),
            children: [
              ShadcnCard(
                child: Row(
                  children: [
                    AppAvatar(
                      widget.member.photoUrl,
                      size: 48,
                      backgroundColor: t.secondary,
                    ),
                    const ShadcnGap(ShadcnSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.member.name,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w700,
                              color: t.cardForeground,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Currently expires '
                            '${DateFormat('d MMM yyyy').format(widget.member.expiryDate)}',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: t.mutedForeground,
                            ),
                          ),
                        ],
                      ),
                    ),
                    MembershipBadge(member: widget.member, compact: true),
                  ],
                ),
              ),
              const ShadcnGap(ShadcnSpacing.xl2),
              ShadcnText('Renewal', variant: ShadcnTextVariant.h4),
              const ShadcnGap(ShadcnSpacing.md),
              AppPickerField(
                label: 'Renew from',
                value: DateFormat('d MMM yyyy').format(_renewalDate),
                onTap: _pickRenewalDate,
              ),
              const ShadcnGap(ShadcnSpacing.lg),
              AppSelect<String>(
                label: 'New plan',
                placeholder: plans.isEmpty
                    ? 'No plans yet — create one first'
                    : 'Select a plan',
                value: _planId,
                errorText: _showErrors && _selectedPlan == null
                    ? 'Please select a plan'
                    : null,
                items: [
                  for (final plan in plans)
                    ShadcnSelectItem(value: plan.id, label: _planLabel(plan)),
                ],
                onChanged: (value) {
                  setState(() {
                    _planId = value;
                    _selectedPlan = GymPlanModel.findById(plans, value);
                    if (_selectedPlan != null) {
                      _selectedPlanFee = _selectedPlan!.fee;
                    }
                  });
                },
              ),
              if (newExpiry != null) ...[
                const ShadcnGap(ShadcnSpacing.md),
                _RenewalSummary(
                  fee: _selectedPlanFee,
                  newExpiry: newExpiry,
                  daysAlreadyUsed: daysAlreadyUsed,
                  endsInThePast: endsInThePast,
                ),
              ],
              const ShadcnGap(ShadcnSpacing.xl2),
              ShadcnText('Payment', variant: ShadcnTextVariant.h4),
              const ShadcnGap(ShadcnSpacing.md),
              AppSelect<String>(
                label: 'Payment mode',
                placeholder: 'How did they pay?',
                value: _selectedPaymentMethod,
                errorText: _showErrors && _selectedPaymentMethod == null
                    ? 'Please select a payment mode'
                    : null,
                items: [
                  for (final method in _paymentMethods)
                    ShadcnSelectItem(value: method, label: method),
                ],
                onChanged: (value) =>
                    setState(() => _selectedPaymentMethod = value),
              ),
              if (_selectedPaymentMethod == 'Online') ...[
                const ShadcnGap(ShadcnSpacing.lg),
                _UpiQr(user: userModel, amount: _selectedPlanFee),
              ],
            ],
          ),
        ),
        if (_isLoading) const AppSavingOverlay(message: 'Renewing…'),
      ],
    );
  }

  static DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  String _planLabel(GymPlanModel plan) {
    final parts = <String>[
      if (plan.months != 0)
        '${plan.months} month${plan.months == 1 ? '' : 's'}',
      if (plan.days != 0) '${plan.days} day${plan.days == 1 ? '' : 's'}',
    ];
    return parts.isEmpty ? plan.name : '${plan.name} · ${parts.join(' ')}';
  }

  Future<void> _pickRenewalDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _renewalDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null && mounted) {
      setState(() => _renewalDate = pickedDate);
    }
  }

  Future<void> _renewMembership() async {
    setState(() => _showErrors = true);
    if (_selectedPlan == null || _selectedPaymentMethod == null) return;

    if (!await _confirmRenewalThatIsAlreadyOver()) return;
    if (!mounted) return;

    setState(() => _isLoading = true);

    // An empty or unreadable box falls back to the plan fee.
    // Always the plan fee. A typed-in amount disagreed with the UPI QR beside
    // it, which always asked for the full fee, and nothing in the app tracks
    // a balance owing, so a part payment left an invoice nothing reconciled.
    final amountPaid = _selectedPlanFee;

    try {
      final renewedMember =
          widget.member.renewMembership(_selectedPlan!, _renewalDate);
      await Provider.of<MemberProvider>(context, listen: false)
          .updateMember(renewedMember);

      if (!mounted) return;
      setState(() => _isLoading = false);

      await showSuccessDialog(
        context: context,
        title: 'Membership renewed',
        desc: '${widget.member.name} is active until '
            '${DateFormat('d MMM yyyy').format(renewedMember.expiryDate)}.',
      );

      // Leaving the screen while the dialog was open used to throw, because
      // the code carried on updating a screen that no longer existed.
      if (!mounted) return;

      // Replaces this screen rather than popping and then pushing onto
      // whatever was underneath, so back from the invoice does not land the
      // owner on the renewal form again.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ViewInvoicePage(
            member: renewedMember,
            paymentMethod: _selectedPaymentMethod!,
            amountPaid: amountPaid,
            transactionType: 'Renewal',
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      showErrorDialog(
        context: context,
        title: 'Could not renew',
        desc: 'Check your connection and try again.',
      );
    }
  }

  /// Checks a backdated renewal that ends on or before today, and asks before
  /// letting it through.
  ///
  /// Not a hard block: the owner may genuinely be recording a term that was
  /// paid for late and will renew again straight afterwards. But it must
  /// never happen by accident, because the member walks away believing they
  /// are paid up while the scanner still refuses them.
  Future<bool> _confirmRenewalThatIsAlreadyOver() async {
    final plan = _selectedPlan;
    if (plan == null) return false;

    final newExpiry = MemberModel.addMonths(_renewalDate, plan.months)
        .add(Duration(days: plan.days));
    final today = _dateOnly(DateTime.now());
    if (_dateOnly(newExpiry).isAfter(today)) return true;

    final dates = DateFormat('d MMM yyyy');
    final goAhead = await showShadcnDialog<bool>(
      context: context,
      builder: (dialogContext) => ShadcnDialog(
        icon: ShadcnIconBadge(
          Icons.warning_amber_rounded,
          color: context.status.warning,
        ),
        title: 'This renewal has already run out',
        description:
            '"${plan.name}" starting ${dates.format(_renewalDate)} ends on '
            '${dates.format(newExpiry)}, which has already passed.\n\n'
            '${widget.member.name} would still count as expired and would '
            'still be turned away at check-in. Renew from a later date, or '
            'pick a plan long enough to reach today.',
        footer: [
          ShadcnButton(
            fullWidth: true,
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Change the dates'),
          ),
          ShadcnButton(
            fullWidth: true,
            variant: ShadcnButtonVariant.secondary,
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Renew anyway'),
          ),
        ],
      ),
    );
    return goAhead == true;
  }
}

/// What this renewal costs and what it buys.
class _RenewalSummary extends StatelessWidget {
  const _RenewalSummary({
    required this.fee,
    required this.newExpiry,
    required this.daysAlreadyUsed,
    required this.endsInThePast,
  });

  final double fee;
  final DateTime newExpiry;

  /// How far the start date has been backdated, in days. Zero or less when
  /// the term starts today or later.
  final int daysAlreadyUsed;

  /// The new term is already over, so the member stays expired.
  final bool endsInThePast;

  @override
  Widget build(BuildContext context) {
    final t = context.shadcn;
    final status = context.status;
    // A term that is already over is the one case worth colouring
    // differently: everything else here is routine.
    final surface =
        endsInThePast ? status.warningSurface : status.infoSurface;
    final foreground =
        endsInThePast ? status.warningForeground : status.infoForeground;
    return Container(
      padding: const EdgeInsets.all(ShadcnSpacing.lg),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(t.radiusMd),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Fee to collect',
                style: TextStyle(fontSize: 13.5, color: foreground),
              ),
              const Spacer(),
              Text(
                '₹${fee.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: foreground,
                ),
              ),
            ],
          ),
          const ShadcnGap(ShadcnSpacing.sm),
          Row(
            children: [
              Text(
                'New expiry date',
                style: TextStyle(fontSize: 13.5, color: foreground),
              ),
              const Spacer(),
              Text(
                DateFormat('d MMM yyyy').format(newExpiry),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: foreground,
                ),
              ),
            ],
          ),
          // Spelled out rather than left for the owner to work out from two
          // dates: a backdated renewal is charging the member for days they
          // have already trained, which is usually the intention but should
          // never be a surprise.
          if (daysAlreadyUsed > 0) ...[
            const ShadcnGap(ShadcnSpacing.sm),
            Row(
              children: [
                Icon(Icons.history_rounded, size: 16, color: foreground),
                const ShadcnGap(ShadcnSpacing.sm),
                Expanded(
                  child: Text(
                    'Backdated — covers $daysAlreadyUsed '
                    '${daysAlreadyUsed == 1 ? 'day' : 'days'} already used',
                    style: TextStyle(fontSize: 12.5, color: foreground),
                  ),
                ),
              ],
            ),
          ],
          if (endsInThePast) ...[
            const ShadcnGap(ShadcnSpacing.sm),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  size: 16,
                  color: foreground,
                ),
                const ShadcnGap(ShadcnSpacing.sm),
                Expanded(
                  child: Text(
                    'This term is already over, so the member stays expired. '
                    'Use a longer plan or a later start date.',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: foreground,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// UPI QR code for taking the renewal payment on the spot.
class _UpiQr extends StatelessWidget {
  const _UpiQr({required this.user, required this.amount});

  final UserModel? user;
  final double amount;

  @override
  Widget build(BuildContext context) {
    final t = context.shadcn;

    if (user == null || user!.upiId.trim().isEmpty) {
      return ShadcnCard(
        child: Row(
          children: [
            Icon(Icons.info_outline_rounded, color: t.mutedForeground),
            const ShadcnGap(ShadcnSpacing.md),
            Expanded(
              child: ShadcnText(
                'Add your UPI ID in Profile to show a payment QR code here.',
                variant: ShadcnTextVariant.small,
              ),
            ),
          ],
        ),
      );
    }

    return ShadcnCard(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(ShadcnSpacing.md),
            decoration: BoxDecoration(
              // Always light: inverting a QR code stops most scanners.
              color: Colors.white,
              borderRadius: BorderRadius.circular(t.radiusMd),
            ),
            child: QrImageView(
              data:
                  'upi://pay?pa=${user!.upiId}&pn=${user!.merchantName}&mc=0000&cu=INR&am=$amount',
              size: 220,
            ),
          ),
          const ShadcnGap(ShadcnSpacing.md),
          ShadcnText(
            'Scan to pay ₹${amount.toStringAsFixed(0)}',
            variant: ShadcnTextVariant.small,
          ),
        ],
      ),
    );
  }
}
