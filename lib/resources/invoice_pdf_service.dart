import 'package:fitstrong_gym/src/custom_import.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

/// Rebuilds the printable bill for a payment that was saved earlier.
///
/// The stored record only keeps the money side of a payment (who, which
/// plan, how much, when). The printed bill also needs the gym's letterhead,
/// the member's contact details and the plan's length, so those are looked
/// up again here. Anything that has since been deleted simply prints as a
/// dash instead of blocking the download, because the payment itself still
/// happened and the owner still needs the receipt.
class InvoicePdfService {
  const InvoicePdfService._();

  /// Generates the PDF for [record] and hands it to the phone to open, where
  /// it can be saved, printed or shared. Returns false when it could not be
  /// built, after telling the owner why.
  static Future<bool> openRecord(
    BuildContext context,
    InvoiceRecord record,
  ) async {
    final pdfFile = await _buildPdf(context, record);
    if (pdfFile == null) return false;
    await PdfApi.openFile(pdfFile);
    return true;
  }

  /// Builds the same bill and hands it to the phone's share sheet, where
  /// WhatsApp sits alongside email and everything else. A short summary of
  /// the payment goes along with it as the message text, so the member gets
  /// the amount in words as well as the attachment.
  ///
  /// WhatsApp does not allow an app to attach a file straight into one
  /// person's chat, so the owner picks the member in WhatsApp's own list.
  /// Nothing is sent without them pressing send.
  static Future<bool> shareRecord(
    BuildContext context,
    InvoiceRecord record, {
    String? gymName,
  }) async {
    final pdfFile = await _buildPdf(context, record);
    if (pdfFile == null) return false;

    final amount = record.amount.toStringAsFixed(0);
    final date = DateFormat('d MMM yyyy').format(record.issuedAt);
    final from = (gymName == null || gymName.trim().isEmpty)
        ? ''
        : ' from ${gymName.trim()}';

    try {
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(pdfFile.path, mimeType: 'application/pdf')],
          text: 'Hi ${record.memberName}, here is your receipt$from.\n'
              '₹$amount for ${record.planName}, paid on $date.\n'
              'Invoice no. ${record.invoiceNumber}. Thank you!',
          subject: 'Invoice ${record.invoiceNumber}',
        ),
      );
      return true;
    } catch (_) {
      if (!context.mounted) return false;
      showErrorToast(
        context,
        'Could not share the invoice',
        description: 'The bill was created but the share sheet would not '
            'open. Try the print button instead.',
      );
      return false;
    }
  }

  /// Regenerates the PDF for [record] on disk, or tells the owner why it
  /// could not be done and returns null.
  static Future<File?> _buildPdf(
    BuildContext context,
    InvoiceRecord record,
  ) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final planProvider = Provider.of<GymPlanProvider>(context, listen: false);
    final memberProvider = Provider.of<MemberProvider>(context, listen: false);

    try {
      if (userProvider.getUser == null) await userProvider.refreshUser();
      if (planProvider.plans.isEmpty) await planProvider.fetchPlans();
      // Opening the revenue list straight after signing in means the member
      // list has not been loaded yet; without it every bill would print as
      // though the member had been deleted.
      if (memberProvider.members.isEmpty) await memberProvider.getAllMembers();

      final userModel = userProvider.getUser;
      if (userModel == null) {
        if (!context.mounted) return null;
        showErrorToast(
          context,
          'Profile still loading',
          description: 'Give it a moment and try again.',
        );
        return null;
      }

      final plan = GymPlanModel.findById(planProvider.plans, record.planId);
      final member = _findMember(memberProvider.members, record.memberId);

      return await PdfInvoiceApi.generate(
        buildInvoice(
          record: record,
          member: member,
          plan: plan,
          owner: userModel,
        ),
        userModel,
      );
    } catch (_) {
      if (!context.mounted) return null;
      showErrorToast(
        context,
        'Could not open the invoice',
        description: 'Check your connection and try again.',
      );
      return null;
    }
  }

  /// Assembles the printable bill. Kept separate from the screen so the same
  /// layout is used whether the bill is printed the moment it is raised or
  /// months later from the invoice list.
  static Invoice buildInvoice({
    required InvoiceRecord record,
    MemberModel? member,
    GymPlanModel? plan,
    UserModel? owner,
  }) {
    const unknown = '—';
    return Invoice(
      owner: Owner(
        name: owner?.name ?? '',
        address: owner?.address ?? '',
        mobileNumber: owner?.phoneNumber ?? '',
      ),
      customer: Customer(
        name: member?.name ?? record.memberName,
        address: member?.address ?? unknown,
        mobileNumber: member?.mobileNumber ?? unknown,
        dateOfAdmission: member?.dateOfAdmission ?? record.issuedAt,
        expiryDate: member?.expiryDate ?? record.issuedAt,
        gender: member?.gender ?? unknown,
      ),
      info: InvoiceInfo(
        todayDate: record.issuedAt,
        invoiceDate: record.issuedAt,
        invoiceNumber: record.invoiceNumber,
        transactionType: record.paymentMethod,
      ),
      items: [
        InvoiceItem(
          description: plan?.name ?? record.planName,
          fees: '${record.amount}',
          days: '${plan?.days ?? 0}',
          months: '${plan?.months ?? 0}',
          total: '${record.amount}',
        ),
      ],
    );
  }

  static MemberModel? _findMember(List<MemberModel> members, String id) {
    for (final member in members) {
      if (member.id == id) return member;
    }
    return null;
  }
}
