import 'package:cloud_firestore/cloud_firestore.dart';

/// A payment that was actually collected, stored under
/// `Users/{uid}/invoices`. The app used to print bills without keeping any
/// record of them, so the gym had no history of what had been charged.
class InvoiceRecord {
  final String id;
  final String invoiceNumber;
  final String memberId;
  final String memberName;
  final String planId;
  final String planName;
  final double amount;
  final String paymentMethod;
  final String transactionType;
  final DateTime issuedAt;

  const InvoiceRecord({
    required this.id,
    required this.invoiceNumber,
    required this.memberId,
    required this.memberName,
    required this.planId,
    required this.planName,
    required this.amount,
    required this.paymentMethod,
    required this.transactionType,
    required this.issuedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'invoiceNumber': invoiceNumber,
      'memberId': memberId,
      'memberName': memberName,
      'planId': planId,
      'planName': planName,
      'amount': amount,
      'paymentMethod': paymentMethod,
      'transactionType': transactionType,
      'issuedAt': Timestamp.fromDate(issuedAt),
    };
  }

  factory InvoiceRecord.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final amount = data['amount'];
    return InvoiceRecord(
      id: doc.id,
      invoiceNumber: data['invoiceNumber'] ?? '',
      memberId: data['memberId'] ?? '',
      memberName: data['memberName'] ?? '',
      planId: data['planId'] ?? '',
      planName: data['planName'] ?? '',
      amount: (amount is int) ? amount.toDouble() : (amount as double? ?? 0.0),
      paymentMethod: data['paymentMethod'] ?? '',
      transactionType: data['transactionType'] ?? '',
      issuedAt: (data['issuedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
