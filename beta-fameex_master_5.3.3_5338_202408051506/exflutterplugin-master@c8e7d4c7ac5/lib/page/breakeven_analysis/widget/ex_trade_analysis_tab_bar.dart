import 'package:chainup_flutter_ex/themes/Themes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../constants/color_constant.dart';
import '../breakeven_analysis_controller/ex_trade_analysis_tab_bar_controller.dart';
import '../../../models/bottom_sheet_entity.dart';

class ExMaiginTradeAnalysisTabBar extends StatefulWidget {
  final List<BottomSheetEntity> titleList;
  final int defaultSelectIndex;
  final ValueChanged? changedCallback;
  const ExMaiginTradeAnalysisTabBar({
    required this.titleList,
    this.defaultSelectIndex = 0,
    this.changedCallback,
    super.key,
  });

  @override
  State<ExMaiginTradeAnalysisTabBar> createState() =>
      _ExMaiginTradeTabBarAnalysisState();
}

class _ExMaiginTradeTabBarAnalysisState
    extends State<ExMaiginTradeAnalysisTabBar> {
  @override
  void initState() {
    super.initState();

    ExTradeAnalysisTabBarController controller = Get.find();
    controller.updateCurrentTabIndex(widget.defaultSelectIndex);
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ExTradeAnalysisTabBarController>(
      builder: (controller) {
        return widget.titleList.length == 1
            ? Text(
                widget.titleList.first.showName ?? "",
                style: ExThemes.textstyle_hm_color1_16(context),
              )
            : Container(
                width: 138,
                height: 24,
                padding: const EdgeInsets.all(2),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: ExColors.fill_1(context),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(2),
                  ),
                ),
                child: Stack(
                  children: [
                    AnimatedAlign(
                      alignment: controller.selectedTabIndex.value == 0
                          ? Alignment.centerLeft
                          : Alignment.centerRight,
                      duration: const Duration(milliseconds: 200),
                      child: _indicator(),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: _tab(0, controller),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: _tab(1, controller),
                    ),
                  ],
                ),
              );
      },
    );
  }

  Widget _indicator() {
    return Container(
      width: 67,
      height: 20,
      decoration: BoxDecoration(
        color: ExColors.fill_3(context),
        borderRadius: const BorderRadius.all(
          Radius.circular(2),
        ),
      ),
    );
  }

  Widget _tab(int index, ExTradeAnalysisTabBarController controller) {
    String title = widget.titleList[index].showName!;
    return GestureDetector(
      onTap: () {
        debugPrint("$index ===== ");
        setState(() {
          controller.updateCurrentTabIndex(index);
        });
        widget.changedCallback?.call(index);
      },
      child: Container(
        width: 67,
        height: 20,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          // color: ExColors.fill_1(context),
          borderRadius: BorderRadius.all(
            Radius.circular(2),
          ),
        ),
        child: Text(
          title,
          style: controller.selectedTabIndex.value == index
              ? ExThemes.textstyle_hm_color1_14(context)
              : ExThemes.textstyle_hm_color2_14(context),
        ),
      ),
    );
  }
}
