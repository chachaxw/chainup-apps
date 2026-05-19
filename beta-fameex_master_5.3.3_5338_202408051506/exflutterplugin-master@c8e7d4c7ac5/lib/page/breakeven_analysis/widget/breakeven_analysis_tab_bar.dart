import 'package:chainup_flutter_ex/constants/color_constant.dart';
import 'package:chainup_flutter_ex/ext/datetime_ext.dart';
import 'package:chainup_flutter_ex/models/bottom_sheet_entity.dart';
import 'package:flutter/material.dart';

import '../../../date_picker/flutter_datetime_picker_plus.dart';
import '../../../themes/Themes.dart';
import 'package:chainup_flutter_ex/date_picker/src/datetime_picker_theme.dart'
    as picker_theme;

typedef DateEndChangedCallback = Function(DateTime startTime, DateTime endTime);

class BreakevenAnalysisTabBar extends StatefulWidget {
  final List<BottomSheetEntity> tabData;
  final ValueChanged<int> tabClickCallback;
  final double itemWidth;
  final double itemHeight;
  final DateEndChangedCallback? selectDateCallback;
  final bool isShowCustomDateBtn;
  final int? currentSelectTab;
  final VoidCallback? cancelSelectTimeCallback;
  const BreakevenAnalysisTabBar({
    required this.tabData,
    required this.tabClickCallback,
    this.itemHeight = 24,
    this.itemWidth = 113,
    this.selectDateCallback,
    this.isShowCustomDateBtn = false,
    this.currentSelectTab,
    this.cancelSelectTimeCallback,
    super.key,
  });

  @override
  State<BreakevenAnalysisTabBar> createState() =>
      _BreakevenAnalysisTabBarState();
}

class _BreakevenAnalysisTabBarState extends State<BreakevenAnalysisTabBar> {
  int _currentSelectTab = 0;

  @override
  void initState() {
    _currentSelectTab = widget.currentSelectTab ?? 0;
    super.initState();
  }

  void updateCurrentTabIndex(int index) {
    // if (_currentSelectTab != index) {
    //   setState(() {
    //     _currentSelectTab = index;
    //   });
    // }
  }

  @override
  Widget build(BuildContext context) {
    _currentSelectTab = widget.currentSelectTab ?? 0;
    return Container(
      color: ExColors.fill_2(context),
      child: _content(context),
    );
  }

  Widget _content(BuildContext context) {
    double scale = 375 / MediaQuery.of(context).size.width;
    return Container(
      color: ExColors.fill_2(context),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(4)),
          border: Border.all(color: ExColors.fill_4(context), width: 1),
        ),
        child: Stack(
          children: [
            AnimatedAlign(
              alignment: _currentSelectTab == 0
                  ? Alignment.centerLeft
                  : _currentSelectTab == 1
                      ? !widget.isShowCustomDateBtn
                          ? Alignment.centerRight
                          : Alignment.center
                      : Alignment.centerRight,
              duration: const Duration(milliseconds: 200),
              child: Container(
                width: widget.itemWidth,
                height: widget.itemHeight,
                decoration: BoxDecoration(
                  color: ExColors.fill_3(context),
                  borderRadius: const BorderRadius.all(Radius.circular(4)),
                ),
                alignment: Alignment.center,
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: _tabItem(context, 0, scale),
            ),
            Align(
              alignment: !widget.isShowCustomDateBtn
                  ? Alignment.centerRight
                  : Alignment.center,
              child: _tabItem(context, 1, scale),
            ),
            widget.isShowCustomDateBtn
                ? Align(
                    alignment: Alignment.centerRight,
                    child: _tabItem(context, 2, scale),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }

  Widget _tabItem(BuildContext context, int index, double scale) {
    BottomSheetEntity entity = widget.tabData[index];
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        updateCurrentTabIndex(index);
        widget.tabClickCallback.call(index);
        if (index == 2) {
          showDatePicker(context);
        }
      },
      child: Container(
        width: widget.itemWidth,
        height: widget.itemHeight,
        alignment: Alignment.center,
        padding: const EdgeInsets.only(top: 1, left: 1),
        child: Text(
          entity.showName!,
          style: _currentSelectTab == index
              ? ExThemes.textstyle_sm_color1_14(context)
              : ExThemes.textstyle_sm_color2_14(context),
        ),
      ),
    );
  }

  void showDatePicker(BuildContext context) {
    DateTime currentDate = DateTime.now();
    // 2023-12-1
    DateTime endDate = DateTime(2023, 12, 1);

    // 计算当前时间到2023-12-1的差值
    Duration difference = currentDate.difference(endDate);

    // 如果差值大于180天（半年），则起始时间为当前时间的半年前，否则为2023-12-1
    DateTime startDate = (difference.inDays > 180)
        ? currentDate.subtract(const Duration(days: 180))
        : DateTime(2023, 12, 1);

    DatePicker.showDatePicker(
      context,
      showTitleActions: true,
      minTime: startDate, //startDate,
      maxTime: currentDate, //currentDate,
      startTime: startDate,
      endTime: currentDate,
      isShowDoubleTime: true,
      currentTime: startDate,
      theme: picker_theme.DatePickerTheme(
        backgroundColor: Colors.transparent, //ExColors.fill_6(context),
        headerColor: ExColors.fill_6(context),
        cancelStyle: ExThemes.textstyle_hm_color2_14(context),
        doneStyle: ExThemes.textstyle_hm_color2_14(context).copyWith(
          color: ExColors.main_4(context),
        ),
        descStyle: ExThemes.textstyle_hr_color2_12(context),
        titleStyle: ExThemes.textstyle_hm_color1_16(context),
        itemStyle: ExThemes.textstyle_hm_color1_20(context),
        itemHeight: 32,
        totalHeight: 407,
      ),
      onConfirm: (startTime, endTime) {
        debugPrint('+++++ onConfirm $startTime $endTime');
        widget.selectDateCallback?.call(startTime, endTime);
      },
      onCancel: () {
        widget.cancelSelectTimeCallback?.call();
      },
    );
  }
}
