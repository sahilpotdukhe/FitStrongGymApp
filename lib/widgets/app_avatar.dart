import 'package:fitstrong_gym/src/custom_import.dart';

/// Someone's photo: a member, a trainer or the gym owner.
///
/// Two states matter and they say different things:
/// * while the photo downloads, a pulsing circle the size of the avatar —
///   something is coming, and the row keeps its shape meanwhile;
/// * when there is no photo, or it failed, the bundled person picture
///   (`assets/user.jpg`) — nothing is coming, this is what you get.
///
/// Wrapping the kit's avatar once means every photo in the app behaves the
/// same way and the placeholder can be changed in a single place.
///
/// The kit turns a URL string into a plain [NetworkImage], which only ever
/// lives in Flutter's in-memory cache: every cold start re-downloaded every
/// member photo, and a full-resolution upload was decoded in full just to
/// paint a 38px list thumbnail. Handing it a [CachedNetworkImageProvider]
/// instead keeps photos on disk between launches and fetches them at the size
/// they are actually drawn at.
class AppAvatar extends StatelessWidget {
  const AppAvatar(
    this.photoUrl, {
    super.key,
    this.size = 40,
    this.backgroundColor,
    this.onTap,
  });

  /// The stored photo URL. Empty or null means the person has no photo.
  final String? photoUrl;
  final double size;
  final Color? backgroundColor;
  final VoidCallback? onTap;

  /// The stand-in face. If the asset itself cannot be read, a plain person
  /// icon is drawn rather than an error box.
  Widget _personImage(BuildContext context) {
    final t = context.shadcn;
    return Image.asset(
      'assets/user.jpg',
      width: size,
      height: size,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Icon(
        Icons.person_rounded,
        size: size * 0.55,
        color: t.mutedForeground,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final url = photoUrl?.trim();
    if (url == null || url.isEmpty) {
      // Null source rather than an empty string: an empty one would be read as
      // an asset path, fail to load, and only then fall back.
      return ShadcnAvatar(
        null,
        size: size,
        backgroundColor: backgroundColor,
        onTap: onTap,
        fallback: _personImage(context),
      );
    }

    return ShadcnAvatar.provider(
      CachedNetworkImageProvider(
        url,
        maxWidth: avatarCacheExtent(context, size),
        maxHeight: avatarCacheExtent(context, size),
      ),
      size: size,
      backgroundColor: backgroundColor,
      onTap: onTap,
      // A circle the exact size of the avatar, gently pulsing. The old spinner
      // only said "something is happening"; now that photos come off the disk
      // on the second look, a spinner would mostly just flash.
      placeholder: ShadcnSkeleton.circle(size: size),
      fallback: _personImage(context),
    );
  }
}

/// How many real pixels an avatar of [size] logical pixels needs.
///
/// Scaled by the screen's density so a photo is sharp on a 3x phone, and
/// capped so a hypothetical huge avatar can never ask for the original camera
/// file again. Avatars in this app run from 38 to 104 logical pixels, so the
/// cap is headroom rather than a limit anything hits today.
int avatarCacheExtent(BuildContext context, double size) {
  final ratio = MediaQuery.maybeDevicePixelRatioOf(context) ?? 1.0;
  return (size * ratio).round().clamp(64, 512);
}
