import 'dart:typed_data';

import 'package:fitstrong_gym/Resources/BrandingImagePrep.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

/// A plain coloured rectangle, encoded as PNG.
Uint8List _png(int width, int height, {img.Color? color}) {
  final image = img.Image(width: width, height: height, numChannels: 3);
  img.fill(image, color: color ?? img.ColorRgb8(10, 120, 200));
  return Uint8List.fromList(img.encodePng(image));
}

/// A transparent sheet with a dark blob in the middle, like a scanned
/// signature saved as a PNG.
Uint8List _signatureOnTransparentSheet(int sheet, int blob) {
  final image = img.Image(width: sheet, height: sheet, numChannels: 4);
  img.fill(image, color: img.ColorRgba8(0, 0, 0, 0));
  final start = (sheet - blob) ~/ 2;
  img.fillRect(
    image,
    x1: start,
    y1: start,
    x2: start + blob,
    y2: start + blob,
    color: img.ColorRgba8(20, 20, 20, 255),
  );
  return Uint8List.fromList(img.encodePng(image));
}

void main() {
  group('prepareBrandingImage', () {
    test('accepts an odd size instead of demanding exact pixels', () {
      final result =
          prepareBrandingImage(_png(640, 360), BrandingImageSpec.logo);

      expect(result.ok, isTrue);
      expect(result.error, isNull);
      expect(result.notice, isNull);
    });

    test('rejects a picture too small to print sharply', () {
      final result =
          prepareBrandingImage(_png(40, 20), BrandingImageSpec.logo);

      expect(result.ok, isFalse);
      expect(result.error, contains('too small'));
      expect(result.errorDetail, contains('40 × 20'));
    });

    test('rejects a file that is not a picture at all', () {
      final junk = Uint8List.fromList([1, 2, 3, 4, 5]);

      final result = prepareBrandingImage(junk, BrandingImageSpec.logo);

      expect(result.ok, isFalse);
      expect(result.error, contains('Could not read'));
    });

    test('shrinks an oversized picture but keeps its shape', () {
      final result =
          prepareBrandingImage(_png(4000, 2000), BrandingImageSpec.logo);

      expect(result.ok, isTrue);
      expect(result.width, lessThanOrEqualTo(1200));
      expect(result.height, lessThanOrEqualTo(1200));
      expect(result.width / result.height, closeTo(2.0, 0.02));
    });

    test('warns, but still accepts, a very tall logo', () {
      final result =
          prepareBrandingImage(_png(200, 900), BrandingImageSpec.logo);

      expect(result.ok, isTrue);
      expect(result.notice, isNotNull);
    });

    test('trims the empty sheet around a signature', () {
      final result = prepareBrandingImage(
        _signatureOnTransparentSheet(800, 200),
        BrandingImageSpec.signature,
      );

      expect(result.ok, isTrue);
      // Only the blob plus a small padding border should survive.
      expect(result.width, lessThan(300));
      expect(result.height, lessThan(300));
    });

    test('a see-through signature is laid on white, never black', () {
      final result = prepareBrandingImage(
        _signatureOnTransparentSheet(800, 200),
        BrandingImageSpec.signature,
      );

      final decoded = img.decodeImage(result.bytes!)!;
      final corner = decoded.getPixel(0, 0);
      expect(corner.r, greaterThan(230));
      expect(corner.g, greaterThan(230));
      expect(corner.b, greaterThan(230));
    });

    test('keeps the original when trimming would leave almost nothing', () {
      final result =
          prepareBrandingImage(_png(600, 400), BrandingImageSpec.signature);

      expect(result.ok, isTrue);
      expect(result.width, 600);
      expect(result.height, 400);
    });
  });
}
