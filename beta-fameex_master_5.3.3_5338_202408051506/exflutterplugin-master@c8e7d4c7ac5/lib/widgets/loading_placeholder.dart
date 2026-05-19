import 'package:chainup_flutter_ex/widgets/gaps.dart';
import 'package:chainup_flutter_ex/widgets/skeleton_widget.dart';
import 'package:flutter/material.dart';

class ExLoadingPlaceholderView extends StatelessWidget {
  const ExLoadingPlaceholderView({super.key});

  @override
  Widget build(BuildContext context) {
    return buildSkeletonWidget();
  }

  Widget buildSkeletonWidget() => Container(
        margin: EdgeInsets.only(left: 16, right: 16, top: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    SkeletonWidget.circular(
                      height: 32,
                      width: 32,
                    ),
                    Gaps.hGap8,
                    SkeletonWidget.rectangular(
                      height: 32,
                      width: 150,
                    )
                  ],
                ),
                SkeletonWidget.rectangular(
                  height: 32,
                  width: 80,
                )
              ],
            ),
            Container(
              margin: EdgeInsets.only(left: 40, top: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonWidget.rectangular(
                    height: 20,
                    width: 140,
                  ),
                  Gaps.vGap8,
                  SkeletonWidget.rectangular(
                    height: 20,
                    width: 170,
                  ),
                  Gaps.vGap10,
                  SkeletonWidget.rectangular(
                    height: 20,
                    width: double.infinity,
                  )
                ],
              ),
            ),
            Gaps.vGap16,
            Gaps.hLine,
          ],
        ),
      );
}
