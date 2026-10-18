import 'package:fitstrong_gym/src/custom_import.dart';

/// Network image with a themed placeholder and a graceful fallback.
///
/// Previously a failed load fetched a "no photo available" JPEG from an
/// unrelated website — a second network round trip that also fails offline.
/// Now the fallback is drawn locally from theme tokens.
class CachedImage extends StatelessWidget {
  const CachedImage({
    super.key,
    required this.imageUrl,
    required this.isRound,
    required this.radius,
    required this.height,
    required this.width,
    required this.fit,
    this.fallbackIcon = Icons.person_rounded,
  });

  final String imageUrl;
  final bool isRound;
  final double radius;
  final double height;
  final double width;
  final BoxFit fit;
  final IconData fallbackIcon;

  @override
  Widget build(BuildContext context) {
    final t = context.shadcn;
    final boxHeight = isRound ? radius : height;
    final boxWidth = isRound ? radius : width;
    final borderRadius = BorderRadius.circular(isRound ? radius : t.radiusLg);

    // While the photo downloads: a block the exact size and shape of the
    // picture, gently pulsing. A spinner said "something is happening"; this
    // also shows what is about to appear, so the layout never jumps.
    Widget loadingSkeleton() => isRound
        ? ShadcnSkeleton.circle(size: boxWidth)
        : ShadcnSkeleton(
            height: boxHeight,
            width: boxWidth,
            borderRadius: borderRadius,
          );

    // No photo, or the photo failed: a still fallback icon, because a pulsing
    // block would promise an image that is never going to arrive.
    Widget fallback() => Container(
          color: t.muted,
          alignment: Alignment.center,
          child: Icon(
            fallbackIcon,
            color: t.mutedForeground,
            size: (boxHeight * 0.45).clamp(16, 48),
          ),
        );

    return SizedBox(
      height: boxHeight,
      width: boxWidth,
      child: ClipRRect(
        borderRadius: borderRadius,
        child: imageUrl.trim().isEmpty
            ? fallback()
            : CachedNetworkImage(
                imageUrl: imageUrl,
                fit: fit,
                placeholder: (context, url) => loadingSkeleton(),
                errorWidget: (context, url, error) => fallback(),
              ),
      ),
    );
  }
}
