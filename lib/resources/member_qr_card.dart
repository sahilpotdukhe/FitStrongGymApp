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

  /// Printed as the gym's contact number, so a member can ring the gym
  /// straight from the image.
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
const String _attendanceAppAsset = 'assets/attendance_app.png';

// Laid out at the design width and painted at [_scale], so a chat app's
// recompression still leaves a crisp, scannable image.
const double _cardWidth = 393;
const double _scale = 4;

const double _headerHeight = 112;
const double _waveDrop = 26;
const double _logoTile = 60;
const double _headerPad = 24;

// The white card floats on the page with a margin all round.
const double _pageMargin = 18;
const double _cardPad = 22;
const double _cardTop = _headerHeight + _waveDrop + 6;
const double _cardLeft = _pageMargin;
const double _cardInnerLeft = _cardLeft + _cardPad;
const double _cardInnerWidth = _cardWidth - (_pageMargin + _cardPad) * 2;

const double _qrPlate = 266;
const double _pillHeight = 74;
const double _appRowHeight = 66;
const double _developerWidth = 128;

const ui.Color _page = ui.Color(0xFFF2F4F7);
const ui.Color _header = ui.Color(0xFF0F172A);
const ui.Color _paper = ui.Color(0xFFFFFFFF);
const ui.Color _ink = ui.Color(0xFF0F172A);
const ui.Color _muted = ui.Color(0xFF64748B);
const ui.Color _rule = ui.Color(0xFFE5E7EB);
const ui.Color _brand = ui.Color(0xFF16A34A);
const ui.Color _brandSoft = ui.Color(0xFFEFFAF3);
const ui.Color _shadow = ui.Color(0x1A0F172A);

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
  final appIcon = await _loadAsset(_attendanceAppAsset, width: (46 * _scale).round());

  // A long member name changes the card's height, and the white card behind
  // the content has to be drawn before it. So the body is laid out once on a
  // throwaway canvas purely to measure, then painted for real on top of the
  // background it just sized.
  final probe = ui.PictureRecorder();
  final cardBottom =
      _paintBody(ui.Canvas(probe), data, developer, appIcon, qr);
  probe.endRecording().dispose();

  final height = cardBottom + _pageMargin;

  final recorder = ui.PictureRecorder();
  final canvas = ui.Canvas(recorder);
  canvas.scale(_scale);

  _paintChrome(canvas, data, logo, height, cardBottom);
  _paintBody(canvas, data, developer, appIcon, qr);

  final image = await recorder.endRecording().toImage(
        (_cardWidth * _scale).round(),
        (height * _scale).round(),
      );
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();
  logo.dispose();
  developer.dispose();
  appIcon.dispose();
  return bytes?.buffer.asUint8List();
}

/// Paints everything behind the content: the page, the dark header with its
/// green sweep, and the white card the details sit on.
void _paintChrome(
  ui.Canvas canvas,
  MemberQrCardData data,
  ui.Image logo,
  double height,
  double cardBottom,
) {
  canvas.drawRect(
    ui.Rect.fromLTWH(0, 0, _cardWidth, height),
    ui.Paint()..color = _page,
  );

  // The green curve is drawn first and the dark band over it, so only the
  // sliver that peeks past the band's curved edge shows: one green sweep
  // under the header rather than two stacked shapes.
  canvas.drawPath(_sweep(_headerHeight + _waveDrop), ui.Paint()..color = _brand);
  canvas.drawPath(_sweep(_headerHeight), ui.Paint()..color = _header);

  final cardRect = ui.RRect.fromRectAndRadius(
    ui.Rect.fromLTWH(
      _cardLeft,
      _cardTop,
      _cardWidth - _cardLeft * 2,
      cardBottom - _cardTop,
    ),
    const ui.Radius.circular(26),
  );
  canvas.drawRRect(
    cardRect.shift(const ui.Offset(0, 6)),
    ui.Paint()
      ..color = _shadow
      ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 10),
  );
  canvas.drawRRect(cardRect, ui.Paint()..color = _paper);

  // The brand mark is a dark image, so it sits in the dark band where its own
  // background disappears instead of showing as a black square on white.
  final tileTop = (_headerHeight - _logoTile) / 2 - 4;
  final tile = ui.RRect.fromRectAndRadius(
    ui.Rect.fromLTWH(_headerPad, tileTop, _logoTile, _logoTile),
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

  if (data.gymName.isEmpty) return;

  // A short green rule separates the mark from the gym's own name.
  final dividerX = _headerPad + _logoTile + 16;
  canvas.drawRect(
    ui.Rect.fromLTWH(dividerX, tileTop + 10, 2, _logoTile - 20),
    ui.Paint()..color = _brand,
  );

  final nameLeft = dividerX + 16;
  final gym = _paragraph(
    [(text: data.gymName, bold: true)],
    size: 20,
    color: _paper,
    align: ui.TextAlign.left,
    maxWidth: _cardWidth - nameLeft - _headerPad,
    height: 1.2,
    maxLines: 2,
  );
  canvas.drawParagraph(
    gym,
    ui.Offset(nameLeft, (_headerHeight - 8 - gym.height) / 2),
  );
}

/// The curved bottom edge shared by the header band and the green sweep
/// behind it; [bottom] is where the curve bites deepest.
ui.Path _sweep(double bottom) => ui.Path()
  ..moveTo(0, 0)
  ..lineTo(_cardWidth, 0)
  ..lineTo(_cardWidth, bottom - 40)
  ..cubicTo(_cardWidth * 0.62, bottom + 16, _cardWidth * 0.34, bottom - 22, 0,
      bottom)
  ..close();

/// Paints the card's contents and returns the y the white card ends at.
double _paintBody(
  ui.Canvas canvas,
  MemberQrCardData data,
  ui.Image developer,
  ui.Image appIcon,
  QrCode qr,
) {
  var y = _cardTop + 26;

  y += _drawRuledLabel(canvas, 'CHECK-IN CODE', y: y);

  y += 10;
  y += _drawCentered(
    canvas,
    [(text: data.memberName, bold: true)],
    y: y,
    size: 28,
    color: _ink,
    height: 1.15,
    maxLines: 2,
  );

  // A QR needs a light quiet zone to scan whatever the chat app's theme does
  // to the background, so it keeps its own white plate inside a green frame.
  y += 20;
  const plateLeft = (_cardWidth - _qrPlate) / 2;
  final plate = ui.RRect.fromRectAndRadius(
    ui.Rect.fromLTWH(plateLeft, y, _qrPlate, _qrPlate),
    const ui.Radius.circular(24),
  );
  canvas.drawRRect(plate, ui.Paint()..color = _paper);
  canvas.drawRRect(
    plate.deflate(1),
    ui.Paint()
      ..color = _brand
      ..style = ui.PaintingStyle.stroke
      ..strokeWidth = 2,
  );

  // Snap each module to whole output pixels: fractional modules blur, and a
  // blurred QR is slow or impossible to scan. The remainder becomes margin.
  const qrInset = 20.0;
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
  y += _qrPlate + 20;

  y += _drawInstructionPill(canvas, data, y: y);

  y += 12;
  y += _drawAttendanceAppRow(canvas, appIcon, y: y);

  // Nothing about the plan is printed: the same code keeps working after a
  // renewal, so a plan or expiry date on the image would go stale while the
  // member still has it on their phone.
  y += 18;
  canvas.drawRect(
    ui.Rect.fromLTWH(_cardInnerLeft, y, _cardInnerWidth, 1),
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

  return y + developerHeight + 18;
}

/// The small green caption with a hairline reaching out to either side.
double _drawRuledLabel(ui.Canvas canvas, String text, {required double y}) {
  final label = _paragraph(
    [(text: text, bold: true)],
    size: 12,
    color: _brand,
    align: ui.TextAlign.center,
    maxWidth: _cardInnerWidth,
    letterSpacing: 2.4,
  );
  canvas.drawParagraph(label, ui.Offset(_cardInnerLeft, y));

  // The rules stop short of the text, so a long caption simply leaves no
  // room for them rather than striking through itself.
  final gap = label.longestLine / 2 + 14;
  final midY = y + label.height / 2;
  final reach = _cardInnerWidth / 2 - gap;
  if (reach > 12) {
    final paint = ui.Paint()..color = _rule;
    canvas.drawRect(
      ui.Rect.fromLTWH(_cardInnerLeft, midY, reach, 1),
      paint,
    );
    canvas.drawRect(
      ui.Rect.fromLTWH(_cardWidth - _cardInnerLeft - reach, midY, reach, 1),
      paint,
    );
  }
  return label.height;
}

/// The tinted strip holding the one instruction and the gym's number.
double _drawInstructionPill(
  ui.Canvas canvas,
  MemberQrCardData data, {
  required double y,
}) {
  canvas.drawRRect(
    ui.RRect.fromRectAndRadius(
      ui.Rect.fromLTWH(_cardInnerLeft, y, _cardInnerWidth, _pillHeight),
      const ui.Radius.circular(20),
    ),
    ui.Paint()..color = _brandSoft,
  );

  const badge = 42.0;
  final badgeCentre = ui.Offset(
    _cardInnerLeft + 14 + badge / 2,
    y + _pillHeight / 2,
  );
  canvas.drawCircle(badgeCentre, badge / 2, ui.Paint()..color = _brand);
  _drawScanGlyph(canvas, badgeCentre);

  final textLeft = _cardInnerLeft + 14 + badge + 12;
  final textWidth = _cardInnerLeft + _cardInnerWidth - 12 - textLeft;

  final headline = _paragraph(
    [(text: 'Show this at the front desk', bold: true)],
    size: 14.5,
    color: _ink,
    align: ui.TextAlign.center,
    maxWidth: textWidth,
    maxLines: 2,
  );
  final contact = data.gymPhone.isEmpty
      ? null
      : _paragraph(
          [
            (text: 'Contact number  ', bold: false),
            (text: data.gymPhone, bold: true),
          ],
          size: 12.5,
          color: _muted,
          align: ui.TextAlign.center,
          maxWidth: textWidth,
          maxLines: 1,
        );

  final block = headline.height + (contact == null ? 0 : contact.height + 3);
  var textY = y + (_pillHeight - block) / 2;
  canvas.drawParagraph(headline, ui.Offset(textLeft, textY));
  if (contact != null) {
    textY += headline.height + 3;
    canvas.drawParagraph(contact, ui.Offset(textLeft, textY));
  }
  return _pillHeight;
}

/// Four white corner brackets, the usual "point your camera here" mark.
void _drawScanGlyph(ui.Canvas canvas, ui.Offset centre) {
  const half = 9.0;
  const arm = 5.0;
  final paint = ui.Paint()
    ..color = _paper
    ..style = ui.PaintingStyle.stroke
    ..strokeWidth = 2
    ..strokeCap = ui.StrokeCap.round;
  for (final x in const [-1.0, 1.0]) {
    for (final yy in const [-1.0, 1.0]) {
      final corner = centre + ui.Offset(half * x, half * yy);
      canvas.drawLine(corner, corner + ui.Offset(-arm * x, 0), paint);
      canvas.drawLine(corner, corner + ui.Offset(0, -arm * yy), paint);
    }
  }
}

/// Names the app the desk scans with, so a member who is handed this image
/// knows what is about to be pointed at it.
double _drawAttendanceAppRow(
  ui.Canvas canvas,
  ui.Image appIcon, {
  required double y,
}) {
  final row = ui.RRect.fromRectAndRadius(
    ui.Rect.fromLTWH(_cardInnerLeft, y, _cardInnerWidth, _appRowHeight),
    const ui.Radius.circular(18),
  );
  canvas.drawRRect(row, ui.Paint()..color = const ui.Color(0xFFFAFAFB));
  canvas.drawRRect(
    row.deflate(0.5),
    ui.Paint()
      ..color = _rule
      ..style = ui.PaintingStyle.stroke
      ..strokeWidth = 1,
  );

  const tileSize = 42.0;
  final tile = ui.RRect.fromRectAndRadius(
    ui.Rect.fromLTWH(
      _cardInnerLeft + 14,
      y + (_appRowHeight - tileSize) / 2,
      tileSize,
      tileSize,
    ),
    const ui.Radius.circular(11),
  );
  canvas.save();
  canvas.clipRRect(tile);
  canvas.drawImageRect(
    appIcon,
    ui.Rect.fromLTWH(0, 0, appIcon.width.toDouble(), appIcon.height.toDouble()),
    tile.outerRect,
    ui.Paint()..filterQuality = ui.FilterQuality.high,
  );
  canvas.restore();

  final textLeft = _cardInnerLeft + 14 + tileSize + 12;
  final textWidth = _cardInnerLeft + _cardInnerWidth - 14 - textLeft;
  final title = _paragraph(
    [(text: 'FitStrong Attendance', bold: true)],
    size: 14,
    color: _ink,
    align: ui.TextAlign.left,
    maxWidth: textWidth,
    maxLines: 1,
  );
  final sub = _paragraph(
    [(text: 'The desk scans this code in the app', bold: false)],
    size: 11.5,
    color: _muted,
    align: ui.TextAlign.left,
    maxWidth: textWidth,
    maxLines: 1,
  );
  final block = title.height + sub.height + 2;
  final textY = y + (_appRowHeight - block) / 2;
  canvas.drawParagraph(title, ui.Offset(textLeft, textY));
  canvas.drawParagraph(sub, ui.Offset(textLeft, textY + title.height + 2));
  return _appRowHeight;
}

/// Draws a card-width centred paragraph at [y]; returns its height.
double _drawCentered(
  ui.Canvas canvas,
  List<({String text, bool bold})> spans, {
  required double y,
  required double size,
  required ui.Color color,
  double height = 1.2,
  double letterSpacing = 0,
  int? maxLines,
}) {
  final paragraph = _paragraph(
    spans,
    size: size,
    color: color,
    align: ui.TextAlign.center,
    maxWidth: _cardInnerWidth,
    height: height,
    letterSpacing: letterSpacing,
    maxLines: maxLines,
  );
  canvas.drawParagraph(paragraph, ui.Offset(_cardInnerLeft, y));
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
