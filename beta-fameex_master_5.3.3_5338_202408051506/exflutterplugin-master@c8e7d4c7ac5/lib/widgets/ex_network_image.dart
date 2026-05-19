import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../constants/icon_constant.dart';

// ignore: must_be_immutable
class ExNetworkImage extends CachedNetworkImage {
  String imgUrl;

  ExNetworkImage(
    this.imgUrl, {
    width,
    fit,
    height,
    Key? key,
  }) : super(
          key: key,
          imageUrl: imgUrl,
          height: height,
          width: width,
          fit: fit,
          placeholder: (context, url) {
            double size = 50;
            if (width != null && width != double.infinity) {
              size = width * 0.5;
            } else if (height != null) {
              size = height * 0.5;
            }
            return Icon(
              Icons.image,
              size: size,
            );
            return Image.asset(
              "assets/images/back_placeholder.png", width: width,
              height: height,
              // centerSlice: const Rect.fromLTRB(24, 26, 95, 93),  //.9图的效果（有问题，待处理）
            );
          },
          errorWidget: (context, url, error) {
            debugPrint(error.toString());
            double size = 50;
            if (width != null && width != double.infinity) {
              size = width;
            } else if (height != null) {
              size = height;
            }
            return ExIcon.icTask1();
            return Image.asset(
              "assets/images/back_placeholder.png", width: width,
              height: height,
              // centerSlice: const Rect.fromLTRB(24, 26, 95, 93),  //.9图的效果（有问题，待处理）
            );
          },
          fadeInDuration: const Duration(milliseconds: 0),
          fadeOutDuration: const Duration(milliseconds: 0),
        );
}
