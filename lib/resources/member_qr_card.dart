import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:fitstrong_core/fitstrong_core.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:qr_flutter/qr_flutter.dart';

/// Everything the shared check-in card prints. Built by the caller so this
/// file stays a pure renderer.
class MemberQrCardData {
  const MemberQrCardData({
    required this.memberName,
    required this.token,
    required this.gymName,
    this.gymPhone = '',
  });

  final String memberName;

  /// The member's check-in token; drawn as the QR.
  final String token;

  /// Printed in the header. Empty when the gym has not named itself yet.
  final String gymName;

  /// Printed in the footer so a member can ring the gym from the image.
  final String gymPhone;
}

/// Builds the member's QR with the strongest error correction.
///
/// Level H rebuilds the code from 30% of it, so a scratched screen, a thumb
/// over a corner, a reprinted photo or a poor camera still reads it. The code
/// is denser than the default, but a denser code that recovers beats a
/// sparser one that does not.
QrCode buildCheckinQr(String token) => QrCode.fromData(
      data: CheckinCode.encode(token),
      errorCorrectLevel: QrErrorCorrectLevel.H,
    );

const String _logoAsset = 'assets/logobg.png';
const String _developerAsset = 'assets/developer.png';

// Laid out at the design width and painted at [_scale], so a chat app's
// recompression still leaves a crisp, scannable image.
const double _cardWidth = 393;
const double _scale = 4;

const double _pad = 28;
const double _headerHeight = 104;
const double _logoTile = 64;
const double _qrPlate = 272;
const double _developerWidth = 132;

const ui.Color _header = ui.Color(0xFF111827);
const ui.Color _paper = ui.Color(0xFFFFFFFF);
const ui.Color _ink = ui.Color(0xFF111827);
const ui.Color _muted = ui.Color(0xFF6B7280);
const ui.Color _plate = ui.Color(0xFFF1F1F6);
const ui.Color _rule = ui.Color(0xFFE5E7EB);
const ui.Color _brand = ui.Color(0xFF15803D);

/// Renders the member's check-in card to PNG bytes.
///
/// Painted on a canvas rather than captured from widgets: a share can fire
/// while the page is navigating away, and a canvas also works in tests.
Future<Uint8List?> renderMemberQrCard(MemberQrCardData data) async {
  if (data.token.isEmpty) return null;

  final qr = buildCheckinQr(data.token);
  final logo = await _loadAsset(_logoAsset, width: (_logoTile * _scale).round());
  final developer =
      await _loadAsset(_developerAsset, width: (_developerWidth * _scale).round());

  // The height is only known after laying the paragraphs out, so paint the
  // body first and size the image from it. A fixed height clips long names.
  final recorder = ui.PictureRecorder();
  final canvas = ui.Canvas(recorder);
  canvas.scale(_scale);

  final height = _paintCard(canvas, data, logo, developer, qr);

  // Painted last, behind everything, now that the height is known.
  canvas.drawRect(
    ui.Rect.fromLTWH(0, 0, _cardWidth, height),
    ui.Paint()
      ..color = _paper
      ..blendMode = ui.BlendMode.dstOver,
  );

  final image = await recorder.endRecording().toImage(
        (_cardWidth * _scale).round(),
        (height * _scale).round(),
      );
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();
  logo.dispose();
  developer.dispose();
  return bytes?.buffer.asUint8List();
}

double _paintCard(
  ui.Canvas canvas,
  MemberQrCardData data,
  ui.Image logo,
  ui.Image developer,
  QrCode qr,
) {
  // The brand mark is a dark image, so it sits in a dark band where its own
  // background disappears instead of showing as a black square on white.
  canvas.drawRect(
    ui.Rect.fromLTWH(0, 0, _cardWidth, _headerHeight),
    ui.Paint()..color = _header,
  );

  final tileTop = (_headerHeight - _logoTile) / 2;
  final tile = ui.RRect.fromRectAndRadius(
    ui.Rect.fromLTWH(_pad, tileTop, _logoTile, _logoTile),
    const ui.Radius.circular(14),
  );
  canvas.save();
  canvas.clipRRect(tile);
  canvas.drawImageRect(
    logo,
    ui.Rect.fromLTWH(0, 0, logo.width.toDouble(), logo.height.toDouble()),
    tile.outerRect,
    ui.Paint()..filterQuality = ui.FilterQuality.high,
  );
  canvas.restore();

  if (data.gymName.isNotEmpty) {
    final nameWidth = _cardWidth - _pad * 2 - _logoTile - 16;
    final gym = _paragraph(
      [(text: data.gymName, bold: true)],
      size: 19,
      color: _paper,
      align: ui.TextAlign.left,
      maxWidth: nameWidth,
      height: 1.2,
      maxLines: 2,
    );
    canvas.drawParagraph(
      gym,
      ui.Offset(_pad + _logoTile + 16, (_headerHeight - gym.height) / 2),
    );
  }

  var y = _headerHeight + 28;

  y += _drawCentered(
    canvas,
    [(text: 'CHECK-IN CODE', bold: true)],
    y: y,
    size: 12,
    color: _brand,
    letterSpacing: 2.4,
  );

  y += 10;
  y += _drawCentered(
    canvas,
    [(text: data.memberName, bold: true)],
    y: y,
    size: 27,
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
  const cardInset = 12.0;
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
    ui.Paint()..color = _paper,
  );

  // Snap each module to whole output pixels: fractional modules blur, and a
  // blurred QR is slow or impossible to scan. The remainder becomes margin.
  const qrInset = cardInset + 16;
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

  y += _drawCentered(
    canvas,
    [(text: 'Show this at the front desk', bold: true)],
    y: y,
    size: 15,
    color: _ink,
  );

  // Nothing about the plan is printed: the same code keeps working after a
  // renewal, so a plan or expiry date on the image would go stale while the
  // member still has it on their phone.
  if (data.gymPhone.isNotEmpty) {
    y += 6;
    y += _drawCentered(
      canvas,
      [(text: data.gymPhone, bold: false)],
      y: y,
      size: 13,
      color: _muted,
    );
  }

  y += 22;
  canvas.drawRect(
    ui.Rect.fromLTWH(_pad, y, _cardWidth - _pad * 2, 1),
    ui.Paint()..color = _rule,
  );

  y += 14;
  final developerHeight = _developerWidth * developer.height / developer.width;
  canvas.drawImageRect(
    developer,
    ui.Rect.fromLTWH(
        0, 0, developer.width.toDouble(), developer.height.toDouble()),
    ui.Rect.fromLTWH(
      (_cardWidth - _developerWidth) / 2,
      y,
      _developerWidth,
      developerHeight,
    ),
    ui.Paint()..filterQuality = ui.FilterQuality.high,
  );

  return y + developerHeight + 10;
}

/// Draws a full-width centred paragraph at [y]; returns its height.
double _drawCentered(
  ui.Canvas canvas,
  List<({String text, bool bold})> spans, {
  required double y,
  required double size,
  required ui.Color color,
  double height = 1.2,
  double letterSpacing = 0,
}) {
  const maxWidth = _cardWidth - _pad * 2;
  final paragraph = _paragraph(
    spans,
    size: size,
    color: color,
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
  double height = 1.2,
  double letterSpacing = 0,
  int? maxLines,
}) {
  final builder = ui.ParagraphBuilder(
    ui.ParagraphStyle(
      textAlign: align,
      fontSize: size,
      height: height,
      maxLines: maxLines,
      ellipsis: maxLines == null ? null : '…',
    ),
  );
  for (final span in spans) {
    builder.pushStyle(
      ui.TextStyle(
        color: color,
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
