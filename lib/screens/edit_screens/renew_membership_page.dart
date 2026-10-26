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
}

/// What this renewal costs and what it buys.
class _RenewalSummary extends StatelessWidget {
  const _RenewalSummary({required this.fee, required this.newExpiry});

  final double fee;
  final DateTime newExpiry;

  @override
  Widget build(BuildContext context) {
    final t = context.shadcn;
    final status = context.status;
    return Container(
      padding: const EdgeInsets.all(ShadcnSpacing.lg),
      decoration: BoxDecoration(
        color: status.infoSurface,
        borderRadius: BorderRadius.circular(t.radiusMd),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Fee to collect',
                style: TextStyle(fontSize: 13.5, color: status.infoForeground),
              ),
              const Spacer(),
              Text(
                '₹${fee.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: status.infoForeground,
                ),
              ),
            ],
          ),
          const ShadcnGap(ShadcnSpacing.sm),
          Row(
            children: [
              Text(
                'New expiry date',
                style: TextStyle(fontSize: 13.5, color: status.infoForeground),
              ),
              const Spacer(),
              Text(
                DateFormat('d MMM yyyy').format(newExpiry),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: status.infoForeground,
                ),
              ),
            ],
          ),
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
