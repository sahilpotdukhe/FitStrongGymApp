import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/services.dart' show rootBundle;
import 'package:fitstrong_core/fitstrong_core.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// One `Label: value` line under the QR.
typedef MemberCardLine = ({String label, String value});

/// Everything the shared check-in card prints. Built by the caller so this
/// file stays a pure renderer.
class MemberQrCardData {
  const MemberQrCardData({
    required this.memberName,
    required this.token,
    required this.gymName,
    required this.lines,
  });

  final String memberName;

  /// The member's check-in token; drawn as the QR.
  final String token;

  /// Printed top right. Empty when the gym has not named itself yet.
  final String gymName;

  final List<MemberCardLine> lines;
}

const String _logoAsset = 'assets/logobg.png';

// Laid out at the design width and painted at [_scale], so a chat app's
// recompression still leaves a crisp, scannable image.
const double _cardWidth = 393;
const double _scale = 4;

const double _pad = 28;
const double _logoSize = 44;
const double _qrPlate = 268;

const ui.Color _background = ui.Color(0xFFFAFAFA);
const ui.Color _ink = ui.Color(0xFF111827);
const ui.Color _muted = ui.Color(0xFF6B7280);
const ui.Color _plate = ui.Color(0xFFF1F1F6);
const ui.Color _white = ui.Color(0xFFFFFFFF);
const ui.Color _brand = ui.Color(0xFF15803D);

/// Renders the member's check-in card to PNG bytes.
///
/// Painted on a canvas rather than captured from widgets: a share can fire
/// while the page is navigating away, and a canvas also works in tests.
Future<Uint8List?> renderMemberQrCard(MemberQrCardData data) async {
  if (data.token.isEmpty) return null;

  final qr = QrCode.fromData(
    data: CheckinCode.encode(data.token),
    // A shared image gets recompressed and reprinted; the extra recovery
    // data is worth the slightly denser code.
    errorCorrectLevel: QrErrorCorrectLevel.M,
  );

  final logo = await _loadAsset(_logoAsset, width: (_logoSize * _scale).round());

  // The height is only known after laying the paragraphs out, so paint the
  // body first and size the image from it. A fixed height clips long names.
  final recorder = ui.PictureRecorder();
  final canvas = ui.Canvas(recorder);
  canvas.scale(_scale);

  final height = _paintBody(canvas, data, logo, qr);

  // Painted last, behind everything, now that the height is known.
  canvas.drawRect(
    ui.Rect.fromLTWH(0, 0, _cardWidth, height),
    ui.Paint()
      ..color = _background
      ..blendMode = ui.BlendMode.dstOver,
  );

  final image = await recorder.endRecording().toImage(
        (_cardWidth * _scale).round(),
        (height * _scale).round(),
      );
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();
  logo.dispose();
  return bytes?.buffer.asUint8List();
}

/// Paints the card; returns its full height.
double _paintBody(
  ui.Canvas canvas,
  MemberQrCardData data,
  ui.Image logo,
  QrCode qr,
) {
  var y = _pad;

  canvas.drawImageRect(
    logo,
    ui.Rect.fromLTWH(0, 0, logo.width.toDouble(), logo.height.toDouble()),
    ui.Rect.fromLTWH(_pad, y, _logoSize, _logoSize),
    ui.Paint()..filterQuality = ui.FilterQuality.high,
  );

  if (data.gymName.isNotEmpty) {
    const gymWidth = _cardWidth - _pad * 2 - _logoSize - 16;
    final gym = _paragraph(
      [(text: data.gymName, bold: true)],
      size: 14,
      color: _ink,
      align: ui.TextAlign.right,
      maxWidth: gymWidth,
      height: 1.3,
    );
    canvas.drawParagraph(
      gym,
      ui.Offset(_cardWidth - _pad - gymWidth, y + (_logoSize - gym.height) / 2),
    );
  }
  y += _logoSize + 26;

  y += _drawCentered(
    canvas,
    [(text: 'CHECK-IN CODE', bold: true)],
    y: y,
    size: 12,
    color: _brand,
    letterSpacing: 2.4,
  );

  y += 8;
  y += _drawCentered(
    canvas,
    [(text: data.memberName, bold: true)],
    y: y,
    size: 26,
    color: _ink,
    height: 1.15,
  );

  // Light plate with a white card inside: a QR needs a light quiet zone to
  // scan whatever the chat app's theme does to the background.
  y += 22;
  const plateLeft = (_cardWidth - _qrPlate) / 2;
  canvas.drawRRect(
    ui.RRect.fromRectAndRadius(
      ui.Rect.fromLTWH(plateLeft, y, _qrPlate, _qrPlate),
      const ui.Radius.circular(26),
    ),
    ui.Paint()..color = _plate,
  );
  const cardInset = 14.0;
  canvas.drawRRect(
    ui.RRect.fromRectAndRadius(
      ui.Rect.fromLTWH(
        plateLeft + cardInset,
        y + cardInset,
        _qrPlate - cardInset * 2,
        _qrPlate - cardInset * 2,
      ),
      const ui.Radius.circular(18),
    ),
    ui.Paint()..color = _white,
  );

  // Snap each module to whole output pixels: fractional modules blur, and a
  // blurred QR is slow or impossible to scan. The remainder becomes margin.
  const qrInset = cardInset + 18;
  const qrBox = _qrPlate - qrInset * 2;
  final modules = QrImage(qr).moduleCount;
  final modulePx = (qrBox * _scale / modules).floorToDouble();
  final qrSize = modulePx * modules / _scale;
  canvas.save();
  canvas.translate(
    plateLeft + qrInset + (qrBox - qrSize) / 2,
    y + qrInset + (qrBox - qrSize) / 2,
  );
  QrPainter.withQr(
    qr: qr,
    gapless: true,
    eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: _ink),
    dataModuleStyle: const QrDataModuleStyle(
      dataModuleShape: QrDataModuleShape.square,
      color: _ink,
    ),
  ).paint(canvas, ui.Size(qrSize, qrSize));
  canvas.restore();
  y += _qrPlate + 24;

  for (final line in data.lines) {
    y += _drawCentered(
      canvas,
      [(text: '${line.label}: ', bold: true), (text: line.value, bold: false)],
      y: y,
      size: 13,
      color: _muted,
      boldColor: _ink,
      height: 1.6,
    );
  }

  y += 22;
  canvas.drawRect(
    ui.Rect.fromLTWH(_pad, y, _cardWidth - _pad * 2, 1),
    ui.Paint()..color = const ui.Color(0xFFE5E7EB),
  );

  y += 18;
  y += _drawCentered(
    canvas,
    [(text: 'Show this at the front desk', bold: false)],
    y: y,
    size: 13.5,
    color: _muted,
  );

  return y + _pad;
}

/// Draws a full-width centred paragraph at [y]; returns its height.
double _drawCentered(
  ui.Canvas canvas,
  List<({String text, bool bold})> spans, {
  required double y,
  required double size,
  required ui.Color color,
  ui.Color? boldColor,
  double height = 1.2,
  double letterSpacing = 0,
}) {
  const maxWidth = _cardWidth - _pad * 2;
  final paragraph = _paragraph(
    spans,
    size: size,
    color: color,
    boldColor: boldColor,
    align: ui.TextAlign.center,
    maxWidth: maxWidth,
    height: height,
    letterSpacing: letterSpacing,
  );
  canvas.drawParagraph(paragraph, ui.Offset(_pad, y));
  return paragraph.height;
}

ui.Paragraph _paragraph(
  List<({String text, bool bold})> spans, {
  required double size,
  required ui.Color color,
  required ui.TextAlign align,
  required double maxWidth,
  ui.Color? boldColor,
  double height = 1.2,
  double letterSpacing = 0,
}) {
  final builder = ui.ParagraphBuilder(
    ui.ParagraphStyle(textAlign: align, fontSize: size, height: height),
  );
  for (final span in spans) {
    builder.pushStyle(
      ui.TextStyle(
        color: span.bold ? (boldColor ?? color) : color,
        fontSize: size,
        height: height,
        letterSpacing: letterSpacing,
        fontWeight: span.bold ? ui.FontWeight.w700 : ui.FontWeight.w400,
      ),
    );
    builder.addText(span.text);
    builder.pop();
  }
  return builder.build()..layout(ui.ParagraphConstraints(width: maxWidth));
}

/// Decodes a bundled PNG at the size it will be drawn, to save memory.
Future<ui.Image> _loadAsset(String key, {int? width}) async {
  final data = await rootBundle.load(key);
  final codec = await ui.instantiateImageCodec(
    data.buffer.asUint8List(),
    targetWidth: width,
  );
  final frame = await codec.getNextFrame();
  codec.dispose();
  return frame.image;
}

/// The date as the card prints it.
String formatCardDate(DateTime date) => DateFormat('d MMMM yyyy').format(date);
