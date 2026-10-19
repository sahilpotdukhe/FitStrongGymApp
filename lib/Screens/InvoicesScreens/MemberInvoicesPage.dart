import 'package:fitstrong_gym/src/custom_import.dart';

/// One member's payment history.
///
/// The same saved bills the revenue screen lists, narrowed to this person,
/// so the owner can answer "what has she paid us?" and hand back any past
/// receipt without hunting through every payment the gym has taken.
class MemberInvoicesPage extends StatefulWidget {
  const MemberInvoicesPage({required this.member, super.key});

  final MemberModel member;

  @override
  State<MemberInvoicesPage> createState() => _MemberInvoicesPageState();
}

class _MemberInvoicesPageState extends State<MemberInvoicesPage> {
  bool _isLoading = true;
  String? _downloadingId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadInvoices());
  }

  Future<void> _loadInvoices() async {
    await Provider.of<InvoiceProvider>(context, listen: false).fetchInvoices();
    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  String _rupees(double amount) => '₹${amount.toStringAsFixed(2)}';

  Future<void> _downloadInvoice(InvoiceRecord invoice) async {
    if (_downloadingId != null) return;
    setState(() => _downloadingId = invoice.id);
    await InvoicePdfService.openRecord(context, invoice);
    if (!mounted) return;
    setState(() => _downloadingId = null);
  }


  /// Rebuilds the bill and opens the phone's share sheet, so it can go to
  /// the member on WhatsApp without printing anything.
  Future<void> _shareInvoice(InvoiceRecord invoice) async {
    if (_downloadingId != null) return;
    setState(() => _downloadingId = invoice.id);
    await InvoicePdfService.shareRecord(
      context,
      invoice,
      gymName: Provider.of<UserProvider>(context, listen: false).getUser?.name,
    );
    if (!mounted) return;
    setState(() => _downloadingId = null);
  }

  @override
  Widget build(BuildContext context) {
    final status = context.status;
    final invoiceProvider = Provider.of<InvoiceProvider>(context);
    final invoices = invoiceProvider.invoicesForMember(widget.member.id);

    return AppScaffold(
      title: 'Invoices',
      body: _isLoading
          ? const Loading()
          : invoices.isEmpty
              ? AppEmptyState(
                  icon: Icons.receipt_long_rounded,
                  title: 'No payments yet',
                  description:
                      '${widget.member.name} has no saved bills. Payments '
                      'taken from now on will be listed here.',
                )
              : RefreshIndicator(
                  color: context.shadcn.primary,
                  backgroundColor: context.shadcn.card,
                  onRefresh: _loadInvoices,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(
                      ShadcnSpacing.lg,
                      ShadcnSpacing.lg,
                      ShadcnSpacing.lg,
                      ShadcnSpacing.xl3,
                    ),
                    children: [
                      AppStatCard(
                        label: '${widget.member.name} has paid',
                        value: _rupees(
                          InvoiceProvider.totalOf(invoices),
                        ),
                        icon: Icons.account_balance_wallet_outlined,
                        accent: status.success,
                        accentSurface: status.successSurface,
                        footnote: '${invoices.length} '
                            'payment${invoices.length == 1 ? '' : 's'} '
                            'on record',
                      ),
                      const ShadcnGap(ShadcnSpacing.xl),
                      for (final invoice in invoices)
                        InvoiceCard(
                          invoice: invoice,
                          showMemberName: false,
                          isDownloading: _downloadingId == invoice.id,
                          onDownload: () => _downloadInvoice(invoice),
                          onShare: () => _shareInvoice(invoice),
                        ),
                    ],
                  ),
                ),
    );
  }
}
