import 'package:fitstrong_gym/src/custom_import.dart';

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
        if (!context.mounted) return false;
        showErrorToast(
          context,
          'Profile still loading',
          description: 'Give it a moment and try again.',
        );
        return false;
      }

      final plan = GymPlanModel.findById(planProvider.plans, record.planId);
      final member = _findMember(memberProvider.members, record.memberId);

      final pdfFile = await PdfInvoiceApi.generate(
        buildInvoice(
          record: record,
          member: member,
          plan: plan,
          owner: userModel,
        ),
        userModel,
      );
      await PdfApi.openFile(pdfFile);
      return true;
    } catch (_) {
      if (!context.mounted) return false;
      showErrorToast(
        context,
        'Could not open the invoice',
        description: 'Check your connection and try again.',
      );
      return false;
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
