import 'package:fitstrong_gym/src/custom_import.dart';

/// Full screen view of a member, trainer or owner photo.
///
/// Pinch or double-tap to zoom, drag to move around while zoomed, and swipe
/// down or tap once to close. The close gestures only work while the photo
/// is at its normal size, so moving a zoomed-in photo never dismisses it by
/// accident — which is what the old version did.
class FullImageWidget extends StatefulWidget {
  const FullImageWidget({
    super.key,
    required this.imageUrl,
    this.title,
    this.heroTag,
  });

  final String imageUrl;

  /// Whose photo this is, shown along the top. Left out when it would only
  /// repeat what the previous screen already said.
  final String? title;

  /// Ties the photo to the thumbnail it was opened from, so it grows out of
  /// it instead of appearing from nowhere. Must be unique on the screen the
  /// tap came from; leaving it out simply skips the animation.
  final Object? heroTag;

  @override
  State<FullImageWidget> createState() => _FullImageWidgetState();
}

class _FullImageWidgetState extends State<FullImageWidget>
    with SingleTickerProviderStateMixin {
  final TransformationController _controller = TransformationController();
  late final AnimationController _animation = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
  );
  Animation<Matrix4>? _zoomAnimation;

  /// Where the last double-tap landed, so the zoom goes towards the part of
  /// the photo that was tapped rather than the middle.
  TapDownDetails? _doubleTapAt;

  bool _isZoomed = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_watchZoom);
    _animation.addListener(() {
      final value = _zoomAnimation?.value;
      if (value != null) _controller.value = value;
    });
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_watchZoom)
      ..dispose();
    _animation.dispose();
    super.dispose();
  }

  void _watchZoom() {
    // Anything above 1.05 counts as zoomed in; the small margin stops a
    // stray pinch from locking the close gestures out.
    final zoomed = _controller.value.getMaxScaleOnAxis() > 1.05;
    if (zoomed != _isZoomed) setState(() => _isZoomed = zoomed);
  }

  void _animateTo(Matrix4 target) {
    _zoomAnimation = Matrix4Tween(begin: _controller.value, end: target)
        .animate(CurvedAnimation(parent: _animation, curve: Curves.easeOut));
    _animation.forward(from: 0);
  }

  void _handleDoubleTap() {
    if (_isZoomed) {
      _animateTo(Matrix4.identity());
      return;
    }
    final position = _doubleTapAt?.localPosition;
    if (position == null) return;
    // Zoom to 2.5× centred on the tap: enough to read a face on a thumbnail
    // sized photo without hunting for it.
    const scale = 2.5;
    _animateTo(
      Matrix4.identity()
        ..translateByDouble(
          -position.dx * (scale - 1),
          -position.dy * (scale - 1),
          0,
          1,
        )
        ..scaleByDouble(scale, scale, scale, 1),
    );
  }

  void _close() => Navigator.pop(context);

  @override
  Widget build(BuildContext context) {
    final hasPhoto = widget.imageUrl.trim().isNotEmpty;

    Widget photo = InteractiveViewer(
      transformationController: _controller,
      minScale: 1,
      maxScale: 5,
      // Keeps the photo inside the screen instead of letting it be flung
      // off into the corner where it has to be hunted back.
      panEnabled: true,
      child: Center(
        child: hasPhoto
            ? CachedNetworkImage(
                imageUrl: widget.imageUrl,
                fit: BoxFit.contain,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white54,
                  ),
                ),
                errorWidget: (context, url, error) => const _NoPhoto(
                  message: 'This photo could not be loaded',
                ),
              )
            : const _NoPhoto(message: 'No photo'),
      ),
    );

    if (widget.heroTag != null) {
      photo = Hero(tag: widget.heroTag!, child: photo);
    }

    return Scaffold(
      // Photos read best against a dark surround in either theme, and the
      // close button needs a predictable background to sit on.
      backgroundColor: Colors.black,
      body: GestureDetector(
        // A plain tap closes, but only when the photo is not zoomed in.
        onTap: _isZoomed ? null : _close,
        onDoubleTapDown: (details) => _doubleTapAt = details,
        onDoubleTap: _handleDoubleTap,
        // Swipe down to dismiss, the way every photo app behaves.
        onVerticalDragEnd: _isZoomed
            ? null
            : (details) {
                if ((details.primaryVelocity ?? 0) > 300) _close();
              },
        child: Stack(
          children: [
            Positioned.fill(child: photo),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: ShadcnSpacing.sm,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: widget.title == null
                            ? const SizedBox.shrink()
                            : Padding(
                                padding: const EdgeInsets.only(
                                  left: ShadcnSpacing.sm,
                                ),
                                child: Text(
                                  widget.title!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    shadows: [
                                      Shadow(blurRadius: 8, color: Colors.black)
                                    ],
                                  ),
                                ),
                              ),
                      ),
                      if (_isZoomed)
                        IconButton(
                          tooltip: 'Reset zoom',
                          icon: const Icon(
                            Icons.zoom_out_map_rounded,
                            color: Colors.white,
                          ),
                          onPressed: () => _animateTo(Matrix4.identity()),
                        ),
                      IconButton(
                        tooltip: 'Close',
                        icon: const Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                        ),
                        onPressed: _close,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (hasPhoto && !_isZoomed)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: ShadcnSpacing.md),
                    child: Text(
                      'Double-tap to zoom · swipe down to close',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.55),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NoPhoto extends StatelessWidget {
  const _NoPhoto({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.person_rounded, size: 72, color: Colors.white24),
          const SizedBox(height: ShadcnSpacing.md),
          Text(message, style: const TextStyle(color: Colors.white54)),
        ],
      ),
    );
  }
}
