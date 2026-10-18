import 'package:fitstrong_gym/src/custom_import.dart';

/// Tap-to-dismiss full screen view of a member or owner photo.
class FullImageWidget extends StatelessWidget {
  const FullImageWidget({super.key, required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Photos read best against a dark surround in either theme, and the
      // close button needs a predictable background to sit on.
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Stack(
          children: [
            Center(
              child: Hero(
                tag: 'imageHero',
                child: InteractiveViewer(
                  // Pinch to zoom: a thumbnail-sized photo of a member card
                  // was previously impossible to inspect.
                  maxScale: 4,
                  child: imageUrl.trim().isEmpty
                      ? const _NoPhoto()
                      : CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.contain,
                          placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white54,
                            ),
                          ),
                          errorWidget: (context, url, error) =>
                              const _NoPhoto(),
                        ),
                ),
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: SafeArea(
                child: IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
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
  const _NoPhoto();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.person_rounded, size: 72, color: Colors.white24),
          SizedBox(height: ShadcnSpacing.md),
          Text('No photo', style: TextStyle(color: Colors.white54)),
        ],
      ),
    );
  }
}
