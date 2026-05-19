import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../constants/color_constant.dart';

class SkeletonWidget extends StatelessWidget {
  final double width;
  final double height;
  final ShapeBorder shapeBorder;

  SkeletonWidget.rectangular(
      {super.key, this.width = double.infinity, required this.height})
      : shapeBorder =
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(4));

  const SkeletonWidget.circular(
      {super.key,
      this.width = double.infinity,
      required this.height,
      this.shapeBorder = const CircleBorder()});

  @override
  Widget build(BuildContext context) => Shimmer.fromColors(
        baseColor: ExColors.fill_3(context),
        highlightColor: ExColors.fill_5(context),
        period: const Duration(seconds: 2),
        child: Container(
          width: width,
          height: height,
          decoration: ShapeDecoration(
            color: ExColors.fill_5(context),
            shape: shapeBorder,
          ),
        ),
      );
}
