import 'dart:typed_data';

import 'package:image/image.dart' as img;

/// Describes one of the two branding pictures the owner uploads, and the box
/// it is printed in on the invoice.
///
/// The box tells us the shape we would *like*; it is not a rule the picture
/// has to obey. Anything reasonable is accepted and then tidied up so the
/// invoice always looks the same.
class BrandingImageSpec {
  const BrandingImageSpec({
    required this.label,
    required this.boxWidth,
    required this.boxHeight,
    required this.minWidth,
    required this.minHeight,
    required this.maxWidth,
    required this.maxHeight,
    this.trimBorder = false,
  });

  /// What to call this picture when talking to the owner.
  final String label;

  /// Size of the slot it is printed in on the invoice, in PDF points.
  final double boxWidth;
  final double boxHeight;

  /// Below this it would look blurry in print, so it is refused.
  final int minWidth;
  final int minHeight;

  /// Above this it is shrunk down: bigger only costs upload time.
  final int maxWidth;
  final int maxHeight;

  /// Signatures are usually a small mark on a big sheet of white or on a
  /// transparent background, so the empty border is cut away first.
  final bool trimBorder;

  double get boxAspect => boxWidth / boxHeight;

  /// The gym logo in the invoice letterhead (114 × 64 pt).
  static const logo = BrandingImageSpec(
    label: 'Logo',
    boxWidth: 114,
    boxHeight: 64,
    minWidth: 120,
    minHeight: 60,
    maxWidth: 1200,
    maxHeight: 1200,
  );

  /// The owner's signature above the name line (110 × 54 pt).
  static const signature = BrandingImageSpec(
    label: 'Signature',
    boxWidth: 110,
    boxHeight: 54,
    minWidth: 100,
    minHeight: 40,
    maxWidth: 1200,
    maxHeight: 1200,
    trimBorder: true,
  );
}

/// What came back from preparing a picture: either ready-to-upload bytes,
/// or a reason it cannot be used.
class BrandingImageResult {
  const BrandingImageResult._({
    this.bytes,
    this.width = 0,
    this.height = 0,
    this.error,
    this.errorDetail,
    this.notice,
  });

  factory BrandingImageResult.ready(
    Uint8List bytes, {
    required int width,
    required int height,
    String? notice,
  }) =>
      BrandingImageResult._(
        bytes: bytes,
        width: width,
        height: height,
        notice: notice,
      );

  factory BrandingImageResult.failure(String error, String detail) =>
      BrandingImageResult._(error: error, errorDetail: detail);

  /// The cleaned-up picture, ready to upload. Null when [error] is set.
  final Uint8List? bytes;
  final int width;
  final int height;

  /// Short headline of why the picture cannot be used.
  final String? error;

  /// Plain-English explanation to show under [error].
  final String? errorDetail;

  /// Set when the picture was accepted but its shape is far from the slot on
  /// the invoice, so it will print smaller than the space allows.
  final String? notice;

  bool get ok => bytes != null;
}

/// How far the shape may drift from the invoice slot before we mention it.
/// 1.9 means "almost twice as tall or twice as wide as the slot" — the
/// picture still prints correctly, it just leaves white space beside it.
const double _aspectNoticeFactor = 1.9;

/// Turns whatever the owner picked into a picture that drops neatly into the
/// invoice: upright, no see-through background, no wasted border, and not
/// larger than it needs to be.
///
/// Nothing here forces an exact pixel size. The only hard limits are "we can
/// read the file" and "it is not so tiny that it prints blurry".
BrandingImageResult prepareBrandingImage(
  Uint8List rawBytes,
  BrandingImageSpec spec,
) {
  img.Image? decoded;
  try {
    decoded = img.decodeImage(rawBytes);
  } catch (_) {
    decoded = null;
  }

  if (decoded == null) {
    return BrandingImageResult.failure(
      'Could not read that picture',
      'Pick a JPG or PNG file and try again.',
    );
  }

  // Photos from a phone carry a rotation flag instead of being stored the
  // right way up; baking it in stops sideways logos on the bill.
  var image = img.bakeOrientation(decoded);

  if (spec.trimBorder) {
    image = _trimEmptyBorder(image);
  }

  if (image.width < spec.minWidth || image.height < spec.minHeight) {
    return BrandingImageResult.failure(
      '${spec.label} is too small to print',
      'It needs to be at least ${spec.minWidth} × ${spec.minHeight} pixels, '
          'but this one is ${image.width} × ${image.height}. A bigger copy '
          'will print sharp instead of blurry.',
    );
  }

  image = _shrinkToFit(image, spec);
  image = _flattenOntoWhite(image);

  String? notice;
  final aspect = image.width / image.height;
  final drift = aspect > spec.boxAspect
      ? aspect / spec.boxAspect
      : spec.boxAspect / aspect;
  if (drift > _aspectNoticeFactor) {
    notice = 'It is a very different shape from the space on the invoice, so '
        'it will print smaller with blank space beside it. A picture close '
        'to ${spec.boxWidth.round()} × ${spec.boxHeight.round()} in shape '
        'fills the space best.';
  }

  final encoded = Uint8List.fromList(img.encodeJpg(image, quality: 90));
  return BrandingImageResult.ready(
    encoded,
    width: image.width,
    height: image.height,
    notice: notice,
  );
}

/// Cuts away a plain or see-through border, so a signature scanned on an A4
/// sheet is not printed as a speck in the middle of the slot.
///
/// If trimming would leave almost nothing — a near-blank or evenly coloured
/// picture — the original is kept rather than returning a sliver.
img.Image _trimEmptyBorder(img.Image image) {
  final mode = image.hasAlpha
      ? img.TrimMode.transparent
      : img.TrimMode.topLeftColor;
  img.Image trimmed;
  try {
    // A little fuzz forgives JPEG speckle around the edge of a scan, and the
    // padding keeps the ink from touching the sides.
    trimmed = img.trim(image, mode: mode, fuzzy: 0.08, padding: 2);
  } catch (_) {
    return image;
  }

  final shrankTooFar = trimmed.width < image.width * 0.05 ||
      trimmed.height < image.height * 0.05;
  if (trimmed.width < 2 || trimmed.height < 2 || shrankTooFar) {
    return image;
  }
  return trimmed;
}

/// Scales a large picture down so the longest side fits the allowance,
/// keeping its shape. Smaller pictures are left alone — blowing them up
/// would only make them blurry.
img.Image _shrinkToFit(img.Image image, BrandingImageSpec spec) {
  if (image.width <= spec.maxWidth && image.height <= spec.maxHeight) {
    return image;
  }
  final scale = (spec.maxWidth / image.width) < (spec.maxHeight / image.height)
      ? spec.maxWidth / image.width
      : spec.maxHeight / image.height;
  return img.copyResize(
    image,
    width: (image.width * scale).round().clamp(1, spec.maxWidth),
    height: (image.height * scale).round().clamp(1, spec.maxHeight),
    interpolation: img.Interpolation.average,
  );
}

/// Lays the picture on a white sheet. Invoices are printed on white, and a
/// see-through PNG saved as a JPG would otherwise turn black.
img.Image _flattenOntoWhite(img.Image image) {
  if (!image.hasAlpha) return image;
  final canvas = img.Image(
    width: image.width,
    height: image.height,
    numChannels: 3,
  );
  img.fill(canvas, color: img.ColorRgb8(255, 255, 255));
  return img.compositeImage(canvas, image);
}
