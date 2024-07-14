import 'dart:ffi';
import 'dart:io';
import 'package:fitstrong_gym/Models/InvoiceModel.dart';
import 'package:fitstrong_gym/Resources/PdfApi.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';

class PdfInvoiceApi {
  static Future<File> generate(Invoice invoice) async {
    final pdf = Document();
    final img = await rootBundle.load('assets/arjunalogo.jpg');
    final imageBytes = img.buffer.asUint8List();
    Image image1 = Image(MemoryImage(imageBytes));
    final img2 = await rootBundle.load('assets/invoiceimage.png');
    final imageBytes1 = img2.buffer.asUint8List();
    Image image2 = Image(MemoryImage(imageBytes1));
    final img3 = await rootBundle.load('assets/demosign.jpg');
    final imageBytes3 = img3.buffer.asUint8List();
    Image image3 = Image(MemoryImage(imageBytes3));
    pdf.addPage(MultiPage(
        build: (context) => [
              Row(children: [
                Container(child: image1, height: 300, width: 300),
                Container(child: image2, height: 200, width: 200),
              ]),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(
                  'Address: ',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(invoice.owner.address, style: TextStyle(fontSize: 16))
              ]),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(
                  'Mobile Number: ',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(invoice.owner.mobileNumber, style: TextStyle(fontSize: 16))
              ]),
              Divider(),
              Center(
                  child: Text('Invoice',
                      style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: PdfColors.red))),
              SizedBox(height: 5),
              buildInvoiceDetails(invoice),
              Divider(),
              buildTitle(invoice),
              SizedBox(height: 0.6 * PdfPageFormat.cm),
              buildTable(invoice),
              Divider(),
              buildTotal(invoice),
              Spacer(),
              buildSignature(invoice, image3),
              Divider(),
              buildFooter(),
            ]));
    return PdfApi.saveDocument(name: '${invoice.customer.name} ${DateFormat('dd-MM-yyyy').format(invoice.customer.dateOfAdmission)}.pdf', pdf: pdf);
  }

  static Widget buildTitle(Invoice invoice) {
    return Row(children: [
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(
            'Name: ',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          Text(invoice.customer.name, style: TextStyle(fontSize: 15))
        ]),
        Row(children: [
          Text(
            'Mobile Number: ',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          Text(invoice.customer.mobileNumber, style: TextStyle(fontSize: 15))
        ]),
        Row(children: [
          Text(
            'Admission/Renewal Date: ',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          Text(
              '${DateFormat('dd-MM-yyyy').format(invoice.customer.dateOfAdmission)}',
              style: TextStyle(fontSize: 15))
        ]),
      ]),
      Spacer(),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(
            'Gender: ',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          Text(invoice.customer.gender, style: TextStyle(fontSize: 15))
        ]),
        Row(children: [
          Text(
            'Address: ',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          Text(invoice.customer.address, style: TextStyle(fontSize: 15))
        ]),
        Row(children: [
          Text(
            'Expiry Date: ',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          Text(
              '${DateFormat('dd-MM-yyyy').format(invoice.customer.expiryDate)}',
              style: TextStyle(fontSize: 15))
        ]),
      ])
    ]);
  }

  static Widget buildTable(Invoice invoice) {
    final tableheaders = ['Description', 'Months', 'Quantity', 'Fees', 'Total'];
    final data = invoice.items.map((item) {
      return [
        item.description,
        item.months,
        item.applied,
        item.fees,
        item.total
      ];
    }).toList();
    return Table.fromTextArray(
        data: data,
        headers: tableheaders,
        border: null,
        headerStyle: TextStyle(fontWeight: FontWeight.bold),
        headerDecoration: BoxDecoration(color: PdfColors.green300),
        cellHeight: 30,
        cellAlignments: {
          0: Alignment.centerLeft,
          1: Alignment.center,
          2: Alignment.center,
          3: Alignment.centerRight,
          4: Alignment.centerRight
        });
  }

  static Widget buildTotal(Invoice invoice) {
    return Container(
        alignment: Alignment.centerRight,
        child: Row(children: [
          Spacer(flex: 6),
          Expanded(
              flex: 4,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Net Total',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(invoice.items[0].total,
                              style: TextStyle(fontWeight: FontWeight.bold))
                        ]),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Taxes',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('0',
                              style: TextStyle(fontWeight: FontWeight.bold))
                        ]),
                    Divider(),
                    Row(children: [
                      Text('Total Amount ',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Spacer(),
                      Text(invoice.items[0].total,
                          style: TextStyle(fontWeight: FontWeight.bold))
                    ]),
                    SizedBox(height: 2 * PdfPageFormat.mm),
                    Container(height: 1, color: PdfColors.green400),
                    SizedBox(height: 0.5 * PdfPageFormat.mm),
                  ]))
        ]));
  }

  static Widget buildFooter() {
    return Container(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Terms & Conditions', style: TextStyle(fontWeight: FontWeight.bold)),
      Text('1. Amount Paid is non-refundable '),
      Text(
          '2. Memberships are non-transferable and cannot be assigned to friends or family members.')
    ]));
  }

  static Widget buildSignature(
    Invoice invoice,
    Image image3,
  ) {
    return Row(children: [
      Spacer(flex: 6),
      Column(children: [
        Container(
            alignment: Alignment.centerRight,
            child: image3,
            height: 70,
            width: 100),
        Text(invoice.owner.name, style: TextStyle(fontWeight: FontWeight.bold))
      ])
    ]);
  }

  static Widget buildInvoiceDetails(Invoice invoice) {
    return Row(children: [
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(
            'Invoice number: ',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(invoice.info.invoiceNumber)
        ]),
        Row(children: [
          Text(
            'Invoice date: ',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text('${DateFormat('dd-MM-yyyy').format(invoice.info.invoiceDate)}')
        ]),
      ]),
      Spacer(),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(
            'Nature of Transaction: ',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(invoice.info.transactionType)
        ]),
        Row(children: [
          Text(
            'Today date: ',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text('${DateFormat('dd-MM-yyyy').format(invoice.info.todayDate)}')
        ]),
      ]),
    ]);
  }
}
