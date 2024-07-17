import 'package:cached_network_image/cached_network_image.dart';
import 'package:fitstrong_gym/src/custom_import.dart';
import 'package:flutter/material.dart';

class CachedImage extends StatelessWidget {
  final String imageUrl;
  final bool isRound;
  final double radius;
  final double height;
  final double width;
  final BoxFit fit;
  final String noImageAvailable = "https://www.esm.rochester.edu/uploads/NoPhotoAvailable.jpg";
  const CachedImage({super.key, required this.imageUrl, required this.isRound, required this.radius, required this.height, required this.width, required this.fit});

  @override
  Widget build(BuildContext context) {
    try{
      return  SizedBox(
        height: isRound ? radius : height,
        width: isRound ? radius : width,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            fit: fit,
            placeholder: (context,url){
              return Center(
                child: CircularProgressIndicator(color: UniversalVariables.appThemeColor,),
              );
            },
            errorWidget: (context,url,error)=> Image.network(noImageAvailable,fit: BoxFit.cover),
          ),
        ),
      );
    }catch(e){
      return Image.network(noImageAvailable,fit: BoxFit.cover);
    }

  }
}
