import 'package:fitstrong_gym/src/custom_import.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

/// Shortest side, in pixels, that a person's photo is stored at.
///
/// Photos of members and trainers are only ever shown as an avatar (104px at
/// the very largest) or opened full-screen on a phone. A phone screen is about
/// 1200px tall, so a short side of 900 still looks sharp zoomed in, while the
/// camera's own 3000-4000px original was roughly twenty times the bytes for no
/// visible gain. Compression alone did not fix that: it was only ever given a
/// quality setting, so a 4000px photo stayed a 1920px photo.
const int personPhotoShortestSide = 900;

/// Shrinks a just-taken photo down to something worth uploading.
///
/// Returns the prepared file, or the original when the platform cannot
/// re-encode it — a slightly large photo is better than a failed save.
///
/// Shared by members and trainers so there is one place to tune how big a
/// stored photo is, and so the two can never drift apart.
Future<File> preparePersonPhoto(XFile photo) async {
  final target = p.join(
    (await getTemporaryDirectory()).path,
    '${const Uuid().v4()}.jpg',
  );

  // `minWidth`/`minHeight` are floors, not targets: the photo is scaled down
  // as far as it can go while keeping both sides at or above them, so the
  // shorter side lands on [personPhotoShortestSide] and the aspect ratio is
  // kept. Portrait and landscape shots both come out sensibly sized.
  final compressed = await FlutterImageCompress.compressAndGetFile(
    photo.path,
    target,
    quality: 70,
    minWidth: personPhotoShortestSide,
    minHeight: personPhotoShortestSide,
    format: CompressFormat.jpeg,
  );

  return compressed == null ? File(photo.path) : File(compressed.path);
}
