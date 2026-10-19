import 'dart:io';
import 'dart:typed_data';

import 'package:fitstrong_gym/models/invoice_model.dart';
import 'package:fitstrong_gym/models/user_model.dart';
import 'package:fitstrong_gym/resources/pdf_api.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';

/// Builds the printable bill a member is given.
///
/// Laid out like a real invoice: the gym's letterhead, who it is for, what
/// they bought, what it cost, and a signature. The on-screen app theme does
/// not apply to a PDF, so the palette below is the print equivalent of it —
/// the same brand blue on white paper.
class PdfInvoiceApi {
  /// The app's brand blue, as a print colour.
  static const PdfColor _brand = PdfColor.fromInt(0xFF3957ED);
  static const PdfColor _ink = PdfColor.fromInt(0xFF12152B);
  static const PdfColor _muted = PdfColor.fromInt(0xFF6B7190);
  static const PdfColor _line = PdfColor.fromInt(0xFFE3E5F0);
  static const PdfColor _tint = PdfColor.fromInt(0xFFEDEFFE);

  static Future<File> generate(Invoice invoice, UserModel userModel) async {
    final pdf = Document();
    final fontData = await rootBundle.load('assets/Roboto-Regular.ttf');
    final ttf = Font.ttf(fontData);

    // The owner uploads a logo and a signature in their profile — at the
    // exact sizes this page prints them at. The old version ignored both and
    // printed bundled demo artwork from another gym instead.
    final logo = await _loadImage(
      url: userModel.profilePhoto,
      fallbackAsset: 'assets/arjunalogo.jpg',
    );
    final signature = await _loadImage(
      url: userModel.signatureImageUrl,
      fallbackAsset: 'assets/demosign.jpg',
    );

    pdf.addPage(
      MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const EdgeInsets.all(32),
        theme: ThemeData.withFont(base: ttf, bold: ttf),
        header: (context) =>
            context.pageNumber == 1 ? SizedBox() : _buildRunningHeader(invoice),
        footer: (context) => _buildPageFooter(context),
        build: (context) => [
          _buildLetterhead(invoice, logo),
          SizedBox(height: 18),
          _buildInvoiceBar(invoice),
          SizedBox(height: 18),
          _buildBillTo(invoice),
          SizedBox(height: 18),
          _buildTable(invoice),
          SizedBox(height: 14),
          _buildTotals(invoice),
          SizedBox(height: 26),
          _buildSignature(invoice, signature),
          SizedBox(height: 22),
          _buildTerms(),
        ],
      ),
    );

    final file = await PdfApi.saveDocument(
      // Spaces and commas in a filename trip up some file managers and mail
      // clients, so the name is built from safe characters only.
      name: _fileName(invoice),
      pdf: pdf,
    );

    return file;
  }

  static String _fileName(Invoice invoice) {
    final safeName = invoice.customer.name
        .replaceAll(RegExp(r'[^A-Za-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');
    final date = DateFormat('yyyy-MM-dd').format(invoice.info.invoiceDate);
    final number =
        invoice.info.invoiceNumber.replaceAll(RegExp(r'[^A-Za-z0-9]+'), '-');
    return 'Invoice-$number-$safeName-$date.pdf';
  }

  /// Fetches the owner's uploaded image, falling back to a bundled asset.
  ///
  /// A bill must print even with no signal, so a slow or failed download
  /// gives up after a few seconds rather than hanging the export.
  static Future<Image?> _loadImage({
    required String url,
    required String fallbackAsset,
  }) async {
    if (url.trim().isNotEmpty) {
      try {
        final client = HttpClient()
          ..connectionTimeout = const Duration(seconds: 5);
        final request = await client.getUrl(Uri.parse(url));
        final response =
            await request.close().timeout(const Duration(seconds: 8));
        if (response.statusCode == 200) {
          final builder = BytesBuilder(copy: false);
          await for (final chunk in response) {
            builder.add(chunk);
          }
          client.close();
          return Image(MemoryImage(builder.takeBytes()));
        }
        client.close();
      } catch (_) {
        // Falls through to the bundled asset below.
      }
    }

    try {
      final bytes = (await rootBundle.load(fallbackAsset)).buffer.asUint8List();
      return Image(MemoryImage(bytes));
    } catch (_) {
      // A missing asset should not stop the bill being produced; the block
      // that would hold the image is simply left out.
      return null;
    }
  }

  /// Gym name, logo and contact details, as a letterhead.
  static Widget _buildLetterhead(Invoice invoice, Image? logo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (logo != null)
              Container(
                height: 64,
                width: 114,
                margin: const EdgeInsets.only(right: 16),
                child: FittedBox(fit: BoxFit.contain, child: logo),
              ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    invoice.owner.name,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: _ink,
                    ),
                  ),
                  SizedBox(height: 4),
                  if (invoice.owner.address.trim().isNotEmpty)
                    Text(
                      invoice.owner.address,
                      style: TextStyle(fontSize: 10, color: _muted),
                    ),
                  if (invoice.owner.mobileNumber.trim().isNotEmpty)
                    Text(
                      'Phone ${invoice.owner.mobileNumber}',
                      style: TextStyle(fontSize: 10, color: _muted),
                    ),
                ],
              ),
            ),
            Text(
              'INVOICE',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: _brand,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
        SizedBox(height: 14),
        Container(height: 2, color: _brand),
      ],
    );
  }

  /// Invoice number, dates and the nature of the transaction, in a tinted
  /// strip so the reference details are easy to find later.
  static Widget _buildInvoiceBar(Invoice invoice) {
    return Container(
      decoration: BoxDecoration(
        color: _tint,
        borderRadius: BorderRadius.all(Radius.circular(6)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _labelled('Invoice number', invoice.info.invoiceNumber),
          ),
          Expanded(
            child: _labelled(
              'Invoice date',
              DateFormat('d MMM yyyy').format(invoice.info.invoiceDate),
            ),
          ),
          Expanded(
            child: _labelled('Payment', invoice.info.transactionType),
          ),
          Expanded(
            child: _labelled(
              'Issued on',
              DateFormat('d MMM yyyy').format(invoice.info.todayDate),
            ),
          ),
        ],
      ),
    );
  }

  /// Who the bill is for, and the membership window it covers.
  static Widget _buildBillTo(Invoice invoice) {
    final customer = invoice.customer;
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: _line),
        borderRadius: BorderRadius.all(Radius.circular(6)),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'BILLED TO',
                  style: TextStyle(
                    fontSize: 8,
                    color: _muted,
                    letterSpacing: 1,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  customer.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: _ink,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  customer.mobileNumber,
                  style: TextStyle(fontSize: 10, color: _muted),
                ),
                if (customer.address.trim().isNotEmpty) ...[
                  SizedBox(height: 2),
                  Text(
                    customer.address,
                    style: TextStyle(fontSize: 10, color: _muted),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _labelled('Gender', customer.gender),
                SizedBox(height: 6),
                _labelled(
                  'Membership from',
                  DateFormat('d MMM yyyy').format(customer.dateOfAdmission),
                ),
                SizedBox(height: 6),
                _labelled(
                  'Valid until',
                  DateFormat('d MMM yyyy').format(customer.expiryDate),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildTable(Invoice invoice) {
    final headers = ['Description', 'Months', 'Days', 'Fee', 'Amount'];
    final data = invoice.items
        .map((item) => [
              item.description,
              item.months,
              item.days,
              _rupees(item.fees),
              _rupees(item.total),
            ])
        .toList();

    return TableHelper.fromTextArray(
      data: data,
      headers: headers,
      border: null,
      headerStyle: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 10,
        color: PdfColors.white,
      ),
      headerDecoration: BoxDecoration(color: _brand),
      headerHeight: 28,
      cellHeight: 26,
      cellStyle: TextStyle(fontSize: 10, color: _ink),
      oddRowDecoration: BoxDecoration(color: PdfColor.fromInt(0xFFF7F8FD)),
      cellAlignments: {
        0: Alignment.centerLeft,
        1: Alignment.center,
        2: Alignment.center,
        3: Alignment.centerRight,
        4: Alignment.centerRight,
      },
    );
  }

  static Widget _buildTotals(Invoice invoice) {
    // Sums every line rather than reading item[0], so a bill with more than
    // one line would still total correctly.
    final total = invoice.items.fold<double>(
      0,
      (running, item) => running + (double.tryParse(item.total) ?? 0),
    );
    final formatted = _rupees(total.toStringAsFixed(2));

    return Row(
      children: [
        Spacer(flex: 6),
        Expanded(
          flex: 5,
          child: Column(
            children: [
              _totalRow('Subtotal', formatted),
              SizedBox(height: 4),
              _totalRow('Taxes', _rupees('0')),
              SizedBox(height: 8),
              Container(height: 1, color: _line),
              SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: _tint,
                  borderRadius: BorderRadius.all(Radius.circular(6)),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Amount paid',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: _ink,
                      ),
                    ),
                    Text(
                      formatted,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: _brand,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static Widget _buildSignature(Invoice invoice, Image? signature) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Text(
            'Thank you — we are glad to have you training with us.',
            style: TextStyle(fontSize: 10, color: _muted),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (signature != null)
              Container(
                height: 54,
                width: 110,
                child: FittedBox(fit: BoxFit.contain, child: signature),
              )
            else
              SizedBox(height: 54, width: 110),
            Container(height: 1, width: 130, color: _line),
            SizedBox(height: 4),
            Text(
              invoice.owner.name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 10,
                color: _ink,
              ),
            ),
            Text(
              'Authorised signatory',
              style: TextStyle(fontSize: 8, color: _muted),
            ),
          ],
        ),
      ],
    );
  }

  static Widget _buildTerms() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: _line),
        borderRadius: BorderRadius.all(Radius.circular(6)),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Terms & conditions',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 10,
              color: _ink,
            ),
          ),
          SizedBox(height: 4),
          Text(
            '1. The amount paid is non-refundable.',
            style: TextStyle(fontSize: 9, color: _muted),
          ),
          Text(
            '2. Memberships are non-transferable and cannot be assigned to others.',
            style: TextStyle(fontSize: 9, color: _muted),
          ),
        ],
      ),
    );
  }

  /// Repeated at the top of any page after the first, so a bill that runs
  /// over is still identifiable on its own.
  static Widget _buildRunningHeader(Invoice invoice) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: _line)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            invoice.owner.name,
            style: TextStyle(fontSize: 9, color: _muted),
          ),
          Text(
            'Invoice ${invoice.info.invoiceNumber}',
            style: TextStyle(fontSize: 9, color: _muted),
          ),
        ],
      ),
    );
  }

  static Widget _buildPageFooter(Context context) {
    return Container(
      alignment: Alignment.centerRight,
      margin: const EdgeInsets.only(top: 10),
      child: Text(
        'Page ${context.pageNumber} of ${context.pagesCount}',
        style: TextStyle(fontSize: 8, color: _muted),
      ),
    );
  }

  static Widget _labelled(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 7,
            color: _muted,
            letterSpacing: 0.8,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 2),
        Text(
          value.trim().isEmpty ? '-' : value,
          style: TextStyle(fontSize: 10, color: _ink),
        ),
      ],
    );
  }

  static Widget _totalRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 10, color: _muted)),
        Text(value, style: TextStyle(fontSize: 10, color: _ink)),
      ],
    );
  }

  /// Rupee amounts print with the symbol and two decimals, matching what the
  /// Revenue screen shows for the same payment.
  static String _rupees(String raw) {
    final parsed = double.tryParse(raw);
    if (parsed == null) return raw;
    return 'Rs. ${parsed.toStringAsFixed(2)}';
  }
}
