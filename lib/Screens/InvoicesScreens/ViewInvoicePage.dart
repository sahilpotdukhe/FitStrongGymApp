import 'package:fitstrong_gym/src/custom_import.dart';
import 'package:intl/intl.dart';

class ViewInvoicePage extends StatefulWidget {
  final MemberModel member;

  /// How the member paid, carried over from the screen that took the money.
  /// The bill used to say "Cash" no matter what was actually chosen.
  final String paymentMethod;

  /// What was actually collected. Falls back to the plan fee when a screen
  /// does not pass it.
  final double? amountPaid;

  /// "New Membership" or "Renewal", printed on the bill.
  final String transactionType;

  const ViewInvoicePage({
    super.key,
    required this.member,
    this.paymentMethod = 'Cash',
    this.amountPaid,
    this.transactionType = 'New Membership',
  });

  @override
  State<ViewInvoicePage> createState() => _ViewInvoicePageState();
}

class _ViewInvoicePageState extends State<ViewInvoicePage> {
  InvoiceRecord? _record;
  bool _isSaving = true;
  bool _isPrinting = false;
  String? _error;

  /// A missing plan cannot be fixed by trying again, so only a failed save
  /// offers the retry button.
  bool _canRetry = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _saveInvoice());
  }

  /// Records the payment once, as soon as the screen opens, because reaching
  /// this screen means the money has been taken. The saved record is then
  /// reused for every print, so the same bill always carries the same number.
  Future<void> _saveInvoice() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final planProvider = Provider.of<GymPlanProvider>(context, listen: false);
    final invoiceProvider =
        Provider.of<InvoiceProvider>(context, listen: false);

    try {
      await userProvider.refreshUser();
      // Plans may not be loaded yet if this screen was reached directly, and
      // without them every plan would look deleted.
      if (planProvider.plans.isEmpty) await planProvider.fetchPlans();
      final plan =
          GymPlanModel.findById(planProvider.plans, widget.member.planId);

      if (plan == null) {
        if (!mounted) return;
        setState(() {
          _isSaving = false;
          _canRetry = false;
          _error =
              'This member\'s plan no longer exists, so no bill could be raised. Renew the membership with a current plan.';
        });
        return;
      }

      final record = await invoiceProvider.createInvoice(
        member: widget.member,
        plan: plan,
        paymentMethod: widget.paymentMethod,
        amount: widget.amountPaid ?? plan.fee,
        transactionType: widget.transactionType,
      );

      if (!mounted) return;
      setState(() {
        _record = record;
        _isSaving = false;
        _canRetry = record == null;
        if (record == null) {
          _error = 'Could not save this invoice. Please check your connection.';
        }
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _canRetry = true;
        _error = 'Could not save this invoice. Please check your connection.';
      });
    }
  }

  /// The money has already changed hands by the time this screen opens, so a
  /// failed save must be retryable — otherwise the payment is missing from
  /// the gym's records for good.
  void _retrySave() {
    setState(() {
      _isSaving = true;
      _error = null;
      _canRetry = false;
    });
    _saveInvoice();
  }

  Future<void> _generatePdf() async {
    final record = _record;
    if (record == null || _isPrinting) return;
    setState(() => _isPrinting = true);
    // The same builder the invoice list uses, so a bill printed now and the
    // same bill reprinted months later come out identical.
    await InvoicePdfService.openRecord(context, record);
    if (!mounted) return;
    setState(() => _isPrinting = false);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.shadcn;
    final status = context.status;
    final record = _record;

    return AppScaffold(
      title: 'Invoice',
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(ShadcnSpacing.xl2),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_isSaving) ...[
                  SizedBox(
                    height: 28,
                    width: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: t.primary,
                    ),
                  ),
                  const ShadcnGap(ShadcnSpacing.lg),
                  ShadcnText(
                    'Recording the payment…',
                    variant: ShadcnTextVariant.muted,
                  ),
                ] else if (_error != null) ...[
                  ShadcnIconBadge(
                    Icons.error_outline_rounded,
                    color: t.destructive,
                    size: 56,
                  ),
                  const ShadcnGap(ShadcnSpacing.lg),
                  ShadcnText('Invoice not raised',
                      variant: ShadcnTextVariant.h3),
                  const ShadcnGap(ShadcnSpacing.sm),
                  ShadcnText(
                    _error!,
                    variant: ShadcnTextVariant.muted,
                    textAlign: TextAlign.center,
                  ),
                  if (_canRetry) ...[
                    const ShadcnGap(ShadcnSpacing.xl),
                    ShadcnButton(
                      fullWidth: true,
                      size: ShadcnButtonSize.lg,
                      leading: const Icon(Icons.refresh_rounded, size: 18),
                      onPressed: _retrySave,
                      child: const Text('Try saving again'),
                    ),
                  ],
                ] else if (record != null) ...[
                  // The receipt itself, so the owner can read the amount back
                  // to the member before printing anything.
                  ShadcnCard(
                    padding: const EdgeInsets.all(ShadcnSpacing.xl),
                    child: Column(
                      children: [
                        ShadcnIconBadge(
                          Icons.check_circle_rounded,
                          color: status.success,
                          size: 56,
                        ),
                        const ShadcnGap(ShadcnSpacing.lg),
                        ShadcnText(
                          'Payment recorded',
                          variant: ShadcnTextVariant.h3,
                        ),
                        const ShadcnGap(ShadcnSpacing.xs),
                        ShadcnText(
                          widget.member.name,
                          variant: ShadcnTextVariant.muted,
                        ),
                        const ShadcnGap(ShadcnSpacing.lg),
                        Text(
                          '₹${record.amount.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 34,
                            height: 1.1,
                            fontWeight: FontWeight.w700,
                            color: t.cardForeground,
                          ),
                        ),
                        const ShadcnGap(ShadcnSpacing.lg),
                        const ShadcnSeparator(),
                        AppInfoRow(
                          label: 'Invoice number',
                          value: record.invoiceNumber,
                        ),
                        AppInfoRow(
                          label: 'Payment mode',
                          value: record.paymentMethod,
                        ),
                        AppInfoRow(
                          label: 'Date',
                          value:
                              DateFormat('d MMM yyyy').format(record.issuedAt),
                          last: true,
                        ),
                      ],
                    ),
                  ),
                  const ShadcnGap(ShadcnSpacing.xl),
                  ShadcnButton(
                    fullWidth: true,
                    size: ShadcnButtonSize.lg,
                    leading:
                        const Icon(Icons.picture_as_pdf_outlined, size: 18),
                    onPressed: _isPrinting ? null : _generatePdf,
                    child: Text(
                      _isPrinting
                          ? 'Preparing invoice…'
                          : 'Open printable invoice',
                    ),
                  ),
                ],
                const ShadcnGap(ShadcnSpacing.md),
                ShadcnButton(
                  fullWidth: true,
                  variant: ShadcnButtonVariant.ghost,
                  onPressed: () {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                        '/home', (Route<dynamic> route) => false);
                  },
                  child: const Text('Back to home'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
