import 'package:fitstrong_gym/src/custom_import.dart';
import 'package:intl/intl.dart';

/// One saved payment, as a row in the receipt book.
///
/// Used by both the gym-wide revenue list and a single member's payment
/// history, so a bill looks the same wherever it is read. Tapping the card —
/// or its download button — rebuilds the printable bill as a PDF.
class InvoiceCard extends StatelessWidget {
  const InvoiceCard({
    super.key,
    required this.invoice,
    this.onDownload,
    this.onShare,
    this.isDownloading = false,
    this.showMemberName = true,
  });

  final InvoiceRecord invoice;
  final VoidCallback? onDownload;

  /// Sends the same bill out through the phone's share sheet, which is
  /// where WhatsApp lives. Left out where sharing makes no sense.
  final VoidCallback? onShare;

  /// Swaps the download button for a spinner while this one bill is being
  /// turned into a PDF, so a slow phone does not look frozen.
  final bool isDownloading;

  /// Off on a single member's own history, where repeating their name on
  /// every row says nothing.
  final bool showMemberName;

  String get _rupees => '₹${invoice.amount.toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) {
    final t = context.shadcn;
    final status = context.status;
    final isRenewal = invoice.transactionType.toLowerCase().contains('renew');
    final title = showMemberName ? invoice.memberName : invoice.planName;
    final subtitle = showMemberName
        ? '${invoice.planName} · ${invoice.transactionType}'
        : invoice.transactionType;

    return Padding(
      padding: const EdgeInsets.only(bottom: ShadcnSpacing.md),
      child: ShadcnCard(
        onTap: onDownload,
        padding: const EdgeInsets.all(ShadcnSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: status.successSurface,
                    borderRadius: BorderRadius.circular(t.radiusMd),
                  ),
                  child: Icon(
                    isRenewal
                        ? Icons.autorenew_rounded
                        : Icons.person_add_alt_1_rounded,
                    size: 19,
                    color: status.success,
                  ),
                ),
                const ShadcnGap(ShadcnSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                          color: t.cardForeground,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: t.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                ),
                const ShadcnGap(ShadcnSpacing.sm),
                Text(
                  _rupees,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: t.cardForeground,
                  ),
                ),
              ],
            ),
            const ShadcnGap(ShadcnSpacing.md),
            Row(
              children: [
                ShadcnBadge(
                  variant: ShadcnBadgeVariant.outline,
                  child: Text(invoice.paymentMethod),
                ),
                const ShadcnGap(ShadcnSpacing.sm),
                // The number and date can be long together, so they get
                // whatever room is left and trim rather than overflow on a
                // narrow phone.
                Expanded(
                  child: Text(
                    '${invoice.invoiceNumber} · '
                    '${DateFormat('d MMM yyyy').format(invoice.issuedAt)}',
                    textAlign: TextAlign.right,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: t.mutedForeground),
                  ),
                ),
                if (onShare != null) ...[
                  const ShadcnGap(ShadcnSpacing.xs),
                  SizedBox(
                    height: 32,
                    width: 32,
                    child: ShadcnButton(
                      variant: ShadcnButtonVariant.ghost,
                      size: ShadcnButtonSize.icon,
                      onPressed: isDownloading ? null : onShare,
                      child: const Icon(Icons.share_outlined, size: 17),
                    ),
                  ),
                ],
                if (onDownload != null) ...[
                  const ShadcnGap(ShadcnSpacing.xs),
                  SizedBox(
                    height: 32,
                    width: 32,
                    child: isDownloading
                        ? Center(
                            child: SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: t.primary,
                              ),
                            ),
                          )
                        : ShadcnButton(
                            variant: ShadcnButtonVariant.ghost,
                            size: ShadcnButtonSize.icon,
                            onPressed: onDownload,
                            child: const Icon(
                              Icons.download_rounded,
                              size: 18,
                            ),
                          ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
