import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../constants/color_constant.dart';
import '../../../themes/Themes.dart';

class BreakevenAnalysisSpecialNote extends StatelessWidget {
  const BreakevenAnalysisSpecialNote({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(color: ExColors.fill_1(context)),
        padding: const EdgeInsets.all(16),
        child: Text(
          "breakeven_analysis_text12".tr,
          style: ExThemes.textstyle_hr_color2_12(context).copyWith(height: 1.5),
        ),
      ),
    );
  }
}
