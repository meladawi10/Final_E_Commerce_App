import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:t_store/core/common/view_models/rounded_image_view_model.dart';
import 'package:t_store/core/utils/constants/colors.dart';
import 'package:t_store/core/utils/helpers/helper_functions.dart';

class RoundedImage extends StatelessWidget {
  const RoundedImage({
    super.key,
    required this.roundedImageModel,
  });
  final RoundedImageModel roundedImageModel;

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);

    return GestureDetector(
      onTap: roundedImageModel.onTap,
      child: Container(
        width: roundedImageModel.width,
        height: roundedImageModel.height,
        decoration: BoxDecoration(
          border: roundedImageModel.border,
          borderRadius: BorderRadius.circular(roundedImageModel.borderRadius),
          color: roundedImageModel.backgroundColor,
        ),
        child: ClipRRect(
          borderRadius: roundedImageModel.applyImageRadius
              ? BorderRadius.circular(roundedImageModel.borderRadius)
              : BorderRadius.zero,
          child: roundedImageModel.isNetworkImage
              ? CachedNetworkImage(
                  imageUrl: roundedImageModel.image,
                  placeholderFadeInDuration: Duration.zero,
                  placeholder: (context, url) => Shimmer.fromColors(
                    baseColor: dark ? Colors.grey[850]! : Colors.grey[300]!,
                    highlightColor:
                        dark ? Colors.grey[700]! : Colors.grey[100]!,
                    child: Container(
                      width: roundedImageModel.width,
                      height: roundedImageModel.height,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: roundedImageModel.applyImageRadius
                            ? BorderRadius.circular(
                                roundedImageModel.borderRadius)
                            : null,
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: roundedImageModel.width,
                    height: roundedImageModel.height,
                    decoration: BoxDecoration(
                      color: dark ? TColors.darkerGrey : TColors.light,
                      borderRadius: roundedImageModel.applyImageRadius
                          ? BorderRadius.circular(
                              roundedImageModel.borderRadius)
                          : null,
                    ),
                    child: Icon(
                      Icons.error,
                      color: dark ? TColors.light : TColors.dark,
                    ),
                  ),
                  color: roundedImageModel.overlayColor,
                  fit: roundedImageModel.fit,
                )
              : Image.asset(
                  roundedImageModel.image,
                  color: roundedImageModel.overlayColor,
                  fit: roundedImageModel.fit ?? BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    // دي بتطبع في الديباج كونسول لو فيه مشكلة في مسار الصورة عشان تعرفه فوراً
                    debugPrint('❌ Failed to load asset image: ${roundedImageModel.image} | Error: $error');
                    return Container(
                      color: dark ? TColors.darkerGrey : TColors.light,
                      child: Center(
                        child: Icon(
                          Icons.image_not_supported_rounded,
                          color: dark ? Colors.white54 : Colors.black54,
                          size: 35,
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}