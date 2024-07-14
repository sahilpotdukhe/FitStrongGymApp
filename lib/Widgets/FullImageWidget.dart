

import 'package:fitstrong_gym/src/custom_import.dart';

class FullImageWidget extends StatelessWidget {
  final String imageUrl;
  final String noImageAvailable =
      "https://www.esm.rochester.edu/uploads/NoPhotoAvailable.jpg";

  const FullImageWidget({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: Center(
          child: Hero(
            tag: 'imageHero',
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              },
              errorWidget: (context, url, error) =>
                  Image.network(noImageAvailable, fit: BoxFit.cover),
            ),
          ),
        ),
      ),
    );
  }
}
