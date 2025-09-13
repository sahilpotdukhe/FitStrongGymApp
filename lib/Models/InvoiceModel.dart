class Invoice {
  final InvoiceInfo info;
  final Owner owner;
  final Customer customer;
  final List<InvoiceItem> items;

  const Invoice({
    required this.info,
    required this.owner,
    required this.customer,
    required this.items,
  });
}

class InvoiceInfo {
  final String invoiceNumber;
  final DateTime todayDate;
  final DateTime invoiceDate;
  final String transactionType;

  const InvoiceInfo(
      {required this.invoiceDate,
      required this.todayDate,
      required this.invoiceNumber,
      required this.transactionType});
}

class InvoiceItem {
  final String description;
  final String days;
  final String months;
  final String fees;
  final String total;

  const InvoiceItem(
      {required this.description,
      required this.days,
      required this.months,
      required this.fees,
      required this.total});
}

class Customer {
  final String name;
  final String address;
  final String mobileNumber;
  final DateTime dateOfAdmission;
  final DateTime expiryDate;
  final String gender;

  const Customer(
      {required this.name,
      required this.address,
      required this.mobileNumber,
      required this.dateOfAdmission,
      required this.expiryDate,
      required this.gender});
}

class Owner {
  final String name;
  final String address;
  final String mobileNumber;

  const Owner(
      {required this.name, required this.address, required this.mobileNumber});
}
