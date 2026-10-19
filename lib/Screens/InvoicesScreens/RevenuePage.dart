import 'package:fitstrong_gym/src/custom_import.dart';
import 'package:intl/intl.dart';

/// Shows the gym owner what has actually been collected.
///
/// Every bill the app raises is stored under `Users/{uid}/invoices`, so the
/// totals here are read back from what was actually collected rather than
/// recalculated from member records — editing or deleting a member leaves
/// the history untouched.
///
/// The cards at the top answer "how are we doing?" (all time, this month,
/// this year) and the list underneath is the receipt book: newest payment
/// first, filterable by month, searchable by member name, and every row
/// re-printable as a PDF.
class RevenuePage extends StatefulWidget {
  const RevenuePage({super.key});

  @override
  State<RevenuePage> createState() => _RevenuePageState();
}

class _RevenuePageState extends State<RevenuePage> {
  /// null means "All months".
  DateTime? _selectedMonth;
  String _query = "";
  bool _isLoading = true;

  /// The bill currently being turned into a PDF, so only that row shows a
  /// spinner and a second tap cannot start the same download twice.
  String? _downloadingId;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadInvoices());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInvoices() async {
    await Provider.of<InvoiceProvider>(context, listen: false).fetchInvoices();
    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  /// Rupees everywhere in the app are printed with two decimal places, so a
  /// payment of 1500 reads as ₹1500.00 here just as it does on the invoice.
  String _rupees(double amount) => '₹${amount.toStringAsFixed(2)}';

  void _clearFilters() {
    _searchController.clear();
    setState(() {
      _query = "";
      _selectedMonth = null;
    });
  }

  /// Rebuilds a saved bill as a PDF and hands it to the phone, where it can
  /// be saved, printed or shared.
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
    final invoiceProvider = Provider.of<InvoiceProvider>(context);
    final months = invoiceProvider.monthsWithInvoices;

    // A month that was picked earlier can disappear if the list is reloaded
    // and that month no longer has any bills in it. Falling back to "All"
    // keeps the dropdown from holding a value it can no longer show.
    final DateTime? activeMonth =
        (_selectedMonth != null && months.contains(_selectedMonth))
            ? _selectedMonth
            : null;

    final visibleInvoices =
        invoiceProvider.invoicesFor(month: activeMonth, query: _query);

    return AppScaffold(
      title: 'Revenue',
      body: _isLoading
          ? const Loading()
          : invoiceProvider.invoices.isEmpty
              ? const AppEmptyState(
                  icon: Icons.receipt_long_rounded,
                  title: 'No payments yet',
                  description:
                      'Payments show up here as soon as you add or renew a '
                      'member and collect their fees.',
                )
              : Column(
                  children: [
                    _buildTotals(invoiceProvider, activeMonth),
                    _buildControls(months, activeMonth),
                    Expanded(
                      child: visibleInvoices.isEmpty
                          ? AppEmptyState(
                              icon: Icons.search_off_rounded,
                              title: 'No payments found',
                              description:
                                  'No payments match this month or this name. '
                                  'Clear the filters to see every payment again.',
                              actionLabel: 'Clear filters',
                              onAction: _clearFilters,
                            )
                          : RefreshIndicator(
                              color: context.shadcn.primary,
                              backgroundColor: context.shadcn.card,
                              onRefresh: _loadInvoices,
                              child: ListView.builder(
                                padding: const EdgeInsets.fromLTRB(
                                  ShadcnSpacing.lg,
                                  ShadcnSpacing.xs,
                                  ShadcnSpacing.lg,
                                  ShadcnSpacing.xl3,
                                ),
                                itemCount: visibleInvoices.length,
                                itemBuilder: (context, index) {
                                  final invoice = visibleInvoices[index];
                                  return InvoiceCard(
                                    invoice: invoice,
                                    isDownloading:
                                        _downloadingId == invoice.id,
                                    onDownload: () =>
                                        _downloadInvoice(invoice),
                                    onShare: () => _shareInvoice(invoice),
                                  );
                                },
                              ),
                            ),
                    ),
                  ],
                ),
    );
  }

  /// What the gym has taken: the lifetime figure first, then this month and
  /// this year underneath it. When a month is picked from the dropdown the
  /// month card follows that month instead, so the number on screen always
  /// matches the list below it.
  Widget _buildTotals(InvoiceProvider invoiceProvider, DateTime? activeMonth) {
    final status = context.status;
    final bool isCurrentMonth = activeMonth == null;
    final double periodTotal = isCurrentMonth
        ? invoiceProvider.thisMonthTotal
        : invoiceProvider.totalForMonth(activeMonth);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        ShadcnSpacing.lg,
        ShadcnSpacing.lg,
        ShadcnSpacing.lg,
        ShadcnSpacing.sm,
      ),
      child: Column(
        children: [
          AppStatCard(
            label: 'Revenue to date',
            value: _rupees(invoiceProvider.allTimeTotal),
            icon: Icons.account_balance_wallet_outlined,
            accent: status.info,
            accentSurface: status.infoSurface,
            footnote: '${invoiceProvider.invoices.length} '
                'payment${invoiceProvider.invoices.length == 1 ? '' : 's'} '
                'recorded',
          ),
          const ShadcnGap(ShadcnSpacing.md),
          Row(
            children: [
              Expanded(
                child: AppStatCard(
                  label: isCurrentMonth
                      ? 'This month'
                      : DateFormat('MMMM yyyy').format(activeMonth),
                  value: _rupees(periodTotal),
                  icon: Icons.trending_up_rounded,
                  accent: status.success,
                  accentSurface: status.successSurface,
                ),
              ),
              const ShadcnGap(ShadcnSpacing.md),
              Expanded(
                child: AppStatCard(
                  label: 'This year',
                  value: _rupees(invoiceProvider.thisYearTotal),
                  icon: Icons.calendar_month_rounded,
                  accent: status.warning,
                  accentSurface: status.warningSurface,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControls(List<DateTime> months, DateTime? activeMonth) {
    final hasFilters = _query.isNotEmpty || activeMonth != null;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        ShadcnSpacing.lg,
        ShadcnSpacing.sm,
        ShadcnSpacing.lg,
        ShadcnSpacing.md,
      ),
      child: Column(
        children: [
          ShadcnInput(
            controller: _searchController,
            placeholder: 'Search by member name',
            leading: const Icon(Icons.search_rounded, size: 18),
            onChanged: (value) => setState(() => _query = value),
          ),
          const ShadcnGap(ShadcnSpacing.sm),
          Row(
            children: [
              Expanded(
                child: AppSelect<String>(
                  value: activeMonth == null
                      ? 'all'
                      : activeMonth.toIso8601String(),
                  placeholder: 'All months',
                  items: [
                    const ShadcnSelectItem(value: 'all', label: 'All months'),
                    for (final month in months)
                      ShadcnSelectItem(
                        value: month.toIso8601String(),
                        label: DateFormat('MMMM yyyy').format(month),
                      ),
                  ],
                  onChanged: (value) => setState(() {
                    _selectedMonth =
                        value == 'all' ? null : DateTime.parse(value);
                  }),
                ),
              ),
              if (hasFilters) ...[
                const ShadcnGap(ShadcnSpacing.sm),
                ShadcnButton(
                  variant: ShadcnButtonVariant.outline,
                  onPressed: _clearFilters,
                  child: const Text('Clear'),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

}
