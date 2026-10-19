import 'package:fitstrong_gym/src/custom_import.dart';

class InvoiceProvider with ChangeNotifier {
  List<InvoiceRecord> _invoices = [];

  List<InvoiceRecord> get invoices => _invoices;

  /// Everything collected in the calendar month we are currently in.
  double get thisMonthTotal {
    final now = DateTime.now();
    return _invoices
        .where(
            (i) => i.issuedAt.year == now.year && i.issuedAt.month == now.month)
        .fold(0.0, (runningTotal, i) => runningTotal + i.amount);
  }

  /// Everything collected since 1 January of the current year.
  double get thisYearTotal {
    final year = DateTime.now().year;
    return _invoices
        .where((i) => i.issuedAt.year == year)
        .fold(0.0, (runningTotal, i) => runningTotal + i.amount);
  }

  /// Every rupee the gym has ever taken, joining fees and renewals alike.
  /// Read back from the saved bills, so it survives a member being edited,
  /// deleted or moved to the recycle bin.
  double get allTimeTotal => _invoices.fold(0.0, (runningTotal, i) => runningTotal + i.amount);

  /// Adds up a batch of bills. Kept separate from the provider's own list so
  /// the revenue screen can total whatever subset it is currently showing.
  static double totalOf(List<InvoiceRecord> invoices) =>
      invoices.fold(0.0, (runningTotal, i) => runningTotal + i.amount);

  /// The distinct calendar months that have at least one bill in them,
  /// newest first. Each entry is the first day of that month, so it can be
  /// compared and formatted without worrying about the day or the time.
  static List<DateTime> monthsOf(List<InvoiceRecord> invoices) {
    final months = <DateTime>{};
    for (final invoice in invoices) {
      months.add(DateTime(invoice.issuedAt.year, invoice.issuedAt.month));
    }
    final sorted = months.toList()..sort((a, b) => b.compareTo(a));
    return sorted;
  }

  /// Narrows a list of bills down to one month and/or a member name.
  ///
  /// A null [month] means every month. The [query] is matched the same way
  /// the member search does it: a case-insensitive "contains" on the name.
  static List<InvoiceRecord> filter(
    List<InvoiceRecord> invoices, {
    DateTime? month,
    String query = '',
  }) {
    final trimmedQuery = query.trim().toLowerCase();
    return invoices.where((invoice) {
      if (month != null &&
          (invoice.issuedAt.year != month.year ||
              invoice.issuedAt.month != month.month)) {
        return false;
      }
      if (trimmedQuery.isEmpty) return true;
      return invoice.memberName.toLowerCase().contains(trimmedQuery);
    }).toList();
  }

  /// The months the gym has taken money in, newest first.
  List<DateTime> get monthsWithInvoices => monthsOf(_invoices);

  /// Everything collected in one calendar month.
  double totalForMonth(DateTime month) =>
      totalOf(filter(_invoices, month: month));

  /// One member's own bills, newest first. Matched on the member's id, not
  /// their name, so two members with the same name never share a history.
  List<InvoiceRecord> invoicesForMember(String memberId) =>
      _invoices.where((invoice) => invoice.memberId == memberId).toList();

  /// Everything one member has ever paid.
  double totalForMember(String memberId) =>
      totalOf(invoicesForMember(memberId));

  /// The stored bills, narrowed by month and member name.
  List<InvoiceRecord> invoicesFor({DateTime? month, String query = ''}) =>
      filter(_invoices, month: month, query: query);

  DocumentReference<Map<String, dynamic>>? _userDoc() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return null;
    return FirebaseFirestore.instance.collection('Users').doc(currentUser.uid);
  }

  /// Saves a bill and hands back the stored record.
  ///
  /// The invoice number comes from a counter on the gym's own user document,
  /// bumped inside a transaction so two bills raised at the same moment can
  /// never share a number. Previously a fresh random number was invented every
  /// time the invoice screen was opened, so reprinting a bill produced a
  /// different number each time and nothing was ever saved.
  Future<InvoiceRecord?> createInvoice({
    required MemberModel member,
    required GymPlanModel plan,
    required String paymentMethod,
    required double amount,
    required String transactionType,
  }) async {
    final userDoc = _userDoc();
    if (userDoc == null) return null;

    final invoiceRef = userDoc.collection('invoices').doc();

    final invoiceNumber = await FirebaseFirestore.instance
        .runTransaction<String>((transaction) async {
      final snapshot = await transaction.get(userDoc);
      final lastNumber = (snapshot.data()?['lastInvoiceNumber'] as int?) ?? 0;
      final nextNumber = lastNumber + 1;
      transaction.update(userDoc, {'lastInvoiceNumber': nextNumber});
      return 'INV-${nextNumber.toString().padLeft(4, '0')}';
    });

    final record = InvoiceRecord(
      id: invoiceRef.id,
      invoiceNumber: invoiceNumber,
      memberId: member.id,
      memberName: member.name,
      planId: plan.id,
      planName: plan.name,
      amount: amount,
      paymentMethod: paymentMethod,
      transactionType: transactionType,
      issuedAt: DateTime.now(),
    );

    await invoiceRef.set(record.toMap());

    _invoices.insert(0, record);
    notifyListeners();
    return record;
  }

  Future<List<InvoiceRecord>> fetchInvoices() async {
    final userDoc = _userDoc();
    if (userDoc == null) return [];
    try {
      final querySnapshot = await userDoc
          .collection('invoices')
          .orderBy('issuedAt', descending: true)
          .get();
      _invoices = querySnapshot.docs
          .map((doc) => InvoiceRecord.fromSnapshot(doc))
          .toList();
      notifyListeners();
      return _invoices;
    } catch (error) {
      debugPrint('Error fetching invoices: $error');
      return [];
    }
  }

  /// Dropped when the gym owner signs out, so the next person to log in on
  /// this phone never sees the previous gym's takings.
  void clear() {
    _invoices = [];
    notifyListeners();
  }
}
