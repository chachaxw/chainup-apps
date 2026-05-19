import 'package:chainup_flutter_ex/constants/color_constant.dart';
import 'package:chainup_flutter_ex/constants/icon_constant.dart';
import 'package:flutter/material.dart';

class ExBlockSelector extends StatelessWidget {
  final Widget child;
  GestureTapCallback? onTap;
  bool isSelected;
  double width;
  double height;

  ExBlockSelector({
    super.key,
    required this.child,
    required this.width,
    required this.height,
    this.isSelected = false,
    this.onTap = null
  });


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              height: double.infinity,
              // color: ExColors.card_bg_color_2(context),
              decoration: ShapeDecoration(
                color: ExColors.fill_3(context),
                shape: RoundedRectangleBorder(
                  borderRadius: const BorderRadius.all(Radius.circular(2.0)),
                  side: BorderSide(width: 1.0, style: BorderStyle.solid, color: isSelected ? ExColors.main_1(context): const Color(0x00000000))
                ),
              ),
              child: child,
            ),
            Align(
              alignment: Alignment.topRight,
              child: Visibility(visible: isSelected,child: ExIcon.icCornerMarkerSelect()),
            )
          ],
        ),
      ),
    );
  }
}
