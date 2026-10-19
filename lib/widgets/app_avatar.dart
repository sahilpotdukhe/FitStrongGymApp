import 'package:fitstrong_gym/src/custom_import.dart';

/// Someone's photo: a member, a trainer or the gym owner.
///
/// Two states matter and they say different things:
/// * while the photo downloads, a small spinner — something is coming;
/// * when there is no photo, or it failed, the bundled person picture
///   (`assets/user.jpg`) — nothing is coming, this is what you get.
///
/// Wrapping the kit's avatar once means every photo in the app behaves the
/// same way and the placeholder can be changed in a single place.
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

  Widget _loader(BuildContext context) {
    final t = context.shadcn;
    // Sized off the avatar so a 38px list thumbnail and a 104px profile
    // picture both get a spinner in proportion to them.
    final indicator = (size * 0.4).clamp(14.0, 28.0);
    return SizedBox(
      height: indicator,
      width: indicator,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        color: t.mutedForeground,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final url = photoUrl?.trim();
    return ShadcnAvatar(
      // Null rather than an empty string: an empty source would be treated
      // as an asset path, fail to load, and only then fall back.
      (url == null || url.isEmpty) ? null : url,
      size: size,
      backgroundColor: backgroundColor,
      onTap: onTap,
      placeholder: _loader(context),
      fallback: _personImage(context),
    );
  }
}
