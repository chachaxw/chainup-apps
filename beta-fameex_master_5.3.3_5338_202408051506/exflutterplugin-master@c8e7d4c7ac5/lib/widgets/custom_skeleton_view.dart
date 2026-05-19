import 'package:chainup_flutter_ex/widgets/gaps.dart';
import 'package:chainup_flutter_ex/widgets/hor_dashed_line.dart';
import 'package:chainup_flutter_ex/widgets/skeleton_widget.dart';
import 'package:flutter/material.dart';

import '../constants/color_constant.dart';

class CustomSkeleton extends StatelessWidget {
  const CustomSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return buildSkeletonWidget(context);
  }

  Widget buildSkeletonWidget(BuildContext context) => Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(
            Radius.circular(8),
          ),
          border: Border.all(
            color: ExColors.fill_5(context),
            width: 1,
          ),
        ),
        margin: const EdgeInsets.only(left: 16, right: 16, top: 16),
        padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SkeletonWidget.circular(
                  height: 32,
                  width: 32,
                ),
                SkeletonWidget.rectangular(
                  height: 30,
                  width: 137,
                )
              ],
            ),
            Container(
              margin: const EdgeInsets.only(top: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonWidget.rectangular(
                    height: 30,
                    width: 170,
                  ),
                  Gaps.vGap8,
                  SkeletonWidget.rectangular(
                    height: 16,
                    width: 224,
                  ),
                  Gaps.vGap8,
                  SkeletonWidget.rectangular(
                    height: 16,
                    width: double.infinity,
                  ),
                  Gaps.vGap8,
                  SkeletonWidget.rectangular(
                    height: 16,
                    width: double.infinity,
                  )
                ],
              ),
            ),
            Gaps.vGap24,
            DashedLine(
              height: 1,
              color: ExColors.fill_5(context),
            ),
            Gaps.vGap16,
            SkeletonWidget.rectangular(
              height: 16,
              width: 224,
            ),
            Gaps.vGap4,
            SkeletonWidget.rectangular(
              height: 16,
              width: 224,
            ),
            Gaps.vGap20,
            SkeletonWidget.rectangular(
              height: 44,
              width: 224,
            ),
            Gaps.vGap14,
          ],
        ),
      );
}
