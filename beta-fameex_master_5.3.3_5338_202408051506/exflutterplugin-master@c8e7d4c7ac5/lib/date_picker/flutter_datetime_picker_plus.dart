library flutter_datetime_picker;

import 'dart:async';

import 'package:chainup_flutter_ex/date_picker/flutter_dateTime_picker_controller.dart';
import 'package:chainup_flutter_ex/date_picker/src/date_model.dart';
import 'package:chainup_flutter_ex/date_picker/src/i18n_model.dart';
import 'package:chainup_flutter_ex/themes/Themes.dart';
import 'package:chainup_flutter_ex/utils/date_utils.dart';
import 'package:chainup_flutter_ex/widgets/gaps.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:chainup_flutter_ex/date_picker/src/datetime_picker_theme.dart'
    as picker_theme;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

import '../constants/color_constant.dart';

export 'package:chainup_flutter_ex/date_picker/src/date_model.dart';
export 'package:chainup_flutter_ex/date_picker/src/datetime_picker_theme.dart';
export 'package:chainup_flutter_ex/date_picker/src/i18n_model.dart';

typedef DateChangedCallback(DateTime startTime, DateTime endTime);
typedef DateEndChangedCallback(DateTime startTime, DateTime endTime);

typedef DateCancelledCallback();
typedef String? StringAtIndexCallBack(int index);

class DatePicker {
  ///
  /// Display date picker bottom sheet.
  ///
  static Future<DateTime?> showDatePicker(
    BuildContext context, {
    bool showTitleActions = true,
    DateTime? minTime,
    DateTime? maxTime,
    DateEndChangedCallback? onChanged,
    DateEndChangedCallback? onConfirm,
    DateCancelledCallback? onCancel,
    locale = LocaleType.en,
    DateTime? currentTime,
    picker_theme.DatePickerTheme? theme,
    bool isShowDoubleTime = false,
    required DateTime? startTime,
    required DateTime? endTime,
  }) async {
    return await Navigator.push(
      context,
      _DatePickerRoute(
        showTitleActions: showTitleActions,
        onChanged: onChanged,
        onConfirm: onConfirm,
        onCancel: onCancel,
        locale: locale,
        theme: theme,
        currentTime: currentTime,
        barrierLabel:
            MaterialLocalizations.of(context).modalBarrierDismissLabel,
        startTime: startTime,
        endTime: endTime,
        isShowDoubleTime: isShowDoubleTime,
        pickerModel: DatePickerModel(
          currentTime: currentTime,
          maxTime: maxTime ?? DateTime(2049, 12, 31),
          minTime: minTime ?? DateTime(1970, 1, 1),
          locale: locale,
        ),
      ),
    );
  }

  ///
  /// Display time picker bottom sheet.
  ///
  static Future<DateTime?> showTimePicker(
    BuildContext context, {
    bool showTitleActions = true,
    bool showSecondsColumn = true,
    DateChangedCallback? onChanged,
    DateChangedCallback? onConfirm,
    DateCancelledCallback? onCancel,
    locale = LocaleType.en,
    DateTime? currentTime,
    picker_theme.DatePickerTheme? theme,
  }) async {
    return await Navigator.push(
      context,
      _DatePickerRoute(
        showTitleActions: showTitleActions,
        onChanged: onChanged,
        onConfirm: onConfirm,
        onCancel: onCancel,
        locale: locale,
        theme: theme,
        barrierLabel:
            MaterialLocalizations.of(context).modalBarrierDismissLabel,
        pickerModel: TimePickerModel(
          currentTime: currentTime,
          locale: locale,
          showSecondsColumn: showSecondsColumn,
        ),
      ),
    );
  }

  ///
  /// Display time picker bottom sheet with AM/PM.
  ///
  static Future<DateTime?> showTime12hPicker(
    BuildContext context, {
    bool showTitleActions = true,
    DateChangedCallback? onChanged,
    DateChangedCallback? onConfirm,
    DateCancelledCallback? onCancel,
    locale = LocaleType.en,
    DateTime? currentTime,
    picker_theme.DatePickerTheme? theme,
  }) async {
    return await Navigator.push(
      context,
      _DatePickerRoute(
        showTitleActions: showTitleActions,
        onChanged: onChanged,
        onConfirm: onConfirm,
        onCancel: onCancel,
        locale: locale,
        theme: theme,
        barrierLabel:
            MaterialLocalizations.of(context).modalBarrierDismissLabel,
        pickerModel: Time12hPickerModel(
          currentTime: currentTime,
          locale: locale,
        ),
      ),
    );
  }

  ///
  /// Display date&time picker bottom sheet.
  ///
  static Future<DateTime?> showDateTimePicker(
    BuildContext context, {
    bool showTitleActions = true,
    DateTime? minTime,
    DateTime? maxTime,
    DateChangedCallback? onChanged,
    DateChangedCallback? onConfirm,
    DateCancelledCallback? onCancel,
    locale = LocaleType.en,
    DateTime? currentTime,
    picker_theme.DatePickerTheme? theme,
  }) async {
    return await Navigator.push(
      context,
      _DatePickerRoute(
        showTitleActions: showTitleActions,
        onChanged: onChanged,
        onConfirm: onConfirm,
        onCancel: onCancel,
        locale: locale,
        theme: theme,
        barrierLabel:
            MaterialLocalizations.of(context).modalBarrierDismissLabel,
        pickerModel: DateTimePickerModel(
          currentTime: currentTime,
          minTime: minTime,
          maxTime: maxTime,
          locale: locale,
        ),
      ),
    );
  }

  ///
  /// Display date picker bottom sheet witch custom picker model.
  ///
  static Future<DateTime?> showPicker(
    BuildContext context, {
    bool showTitleActions = true,
    DateChangedCallback? onChanged,
    DateChangedCallback? onConfirm,
    DateCancelledCallback? onCancel,
    locale = LocaleType.en,
    BasePickerModel? pickerModel,
    picker_theme.DatePickerTheme? theme,
  }) async {
    return await Navigator.push(
      context,
      _DatePickerRoute(
        showTitleActions: showTitleActions,
        onChanged: onChanged,
        onConfirm: onConfirm,
        onCancel: onCancel,
        locale: locale,
        theme: theme,
        barrierLabel:
            MaterialLocalizations.of(context).modalBarrierDismissLabel,
        pickerModel: pickerModel,
      ),
    );
  }
}

class _DatePickerRoute<T> extends PopupRoute<T> {
  _DatePickerRoute({
    this.showTitleActions,
    this.onChanged,
    this.onConfirm,
    this.onCancel,
    picker_theme.DatePickerTheme? theme,
    this.barrierLabel,
    this.locale,
    RouteSettings? settings,
    BasePickerModel? pickerModel,
    this.startTime,
    this.endTime,
    this.isShowDoubleTime = false,
    this.currentTime,
  })  : this.pickerModel = pickerModel ?? DatePickerModel(),
        this.theme = theme ?? picker_theme.DatePickerTheme(),
        super(settings: settings);

  final DateTime? currentTime;
  final bool isShowDoubleTime;
  final bool? showTitleActions;
  final DateChangedCallback? onChanged;
  final DateChangedCallback? onConfirm;
  final DateCancelledCallback? onCancel;
  final DateTime? startTime;
  final DateTime? endTime;
  final LocaleType? locale;
  final picker_theme.DatePickerTheme theme;
  final BasePickerModel pickerModel;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 200);

  @override
  bool get barrierDismissible => true;

  @override
  final String? barrierLabel;

  @override
  Color get barrierColor => Colors.black54;

  AnimationController? _animationController;

  @override
  AnimationController createAnimationController() {
    assert(_animationController == null);
    _animationController =
        BottomSheet.createAnimationController(navigator!.overlay!);
    return _animationController!;
  }

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    Widget bottomSheet = MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: _DatePickerComponent(
        currentTime: currentTime,
        onChanged: onChanged,
        onConfirm: onConfirm,
        locale: this.locale,
        route: this,
        pickerModel: pickerModel,
        startTime: startTime,
        endTime: endTime,
        isShowDoubleTime: isShowDoubleTime,
      ),
    );
    return InheritedTheme.captureAll(context, bottomSheet);
  }
}

class _DatePickerComponent extends StatefulWidget {
  const _DatePickerComponent({
    Key? key,
    required this.route,
    required this.pickerModel,
    this.onChanged,
    this.locale,
    this.endTime,
    this.startTime,
    this.onConfirm,
    this.isShowDoubleTime = false,
    this.currentTime,
  }) : super(key: key);

  final DateTime? currentTime;

  final bool isShowDoubleTime;
  final DateChangedCallback? onChanged;
  final DateChangedCallback? onConfirm;

  final _DatePickerRoute route;

  final LocaleType? locale;

  final BasePickerModel pickerModel;

  final DateTime? endTime;

  final DateTime? startTime;

  @override
  State<StatefulWidget> createState() {
    return _DatePickerState();
  }
}

class _DatePickerState extends State<_DatePickerComponent> {
  late FlutterDateTimePickerController controller;

  late FixedExtentScrollController leftScrollCtrl,
      middleScrollCtrl,
      rightScrollCtrl;

  String startTimeStr = "";
  String endTimeStr = "";
  DateTime? startDateTime;
  DateTime? endDateTime;

  ///是否滚动滚轮选择了时间
  bool isHaveSelectedTime = false;

  DateTime? _tempCurrentTime;

  @override
  void initState() {
    super.initState();
    Get.lazyPut(() => FlutterDateTimePickerController());
    controller = Get.find();

    _tempCurrentTime = widget.currentTime;
    handleInitTime();

    leftScrollCtrl = FixedExtentScrollController(
        initialItem: widget.pickerModel.currentLeftIndex());
    middleScrollCtrl = FixedExtentScrollController(
        initialItem: widget.pickerModel.currentMiddleIndex());
    rightScrollCtrl = FixedExtentScrollController(
        initialItem: widget.pickerModel.currentRightIndex());
  }

  @override
  void dispose() {
    leftScrollCtrl.dispose();
    middleScrollCtrl.dispose();
    rightScrollCtrl.dispose();
    controller.onClose();
    super.dispose();
  }

  void handleInitTime() {
    if (widget.startTime != null) {
      startDateTime = widget.startTime!;
    } else {
      startDateTime = _tempCurrentTime ?? DateTime.now();
    }
    if (widget.endTime != null) {
      endDateTime = widget.endTime!;
    } else {
      endDateTime = DateTime.now();
    }
    if (endDateTime!.isBefore(startDateTime!)) {
      Fluttertoast.showToast(msg: "breakeven_analysis_text20".tr);
    }
    startTimeStr = EXDateUtils.formateDateTimeToString(startDateTime!,
        format: "yyyy-MM-dd");
    endTimeStr =
        EXDateUtils.formateDateTimeToString(endDateTime!, format: "yyyy-MM-dd");

    controller.startTimeStr.value = startTimeStr;
    controller.endTimeStr.value = endTimeStr;
  }

  void refreshScrollOffset({bool isInit = false}) {
    if (isInit) {
      leftScrollCtrl = FixedExtentScrollController(
          initialItem: widget.pickerModel.currentLeftIndex());
      middleScrollCtrl = FixedExtentScrollController(
          initialItem: widget.pickerModel.currentMiddleIndex());
      rightScrollCtrl = FixedExtentScrollController(
          initialItem: widget.pickerModel.currentRightIndex());
    } else {
      rightScrollCtrl.animateToItem(widget.pickerModel.currentRightIndex(),
          duration: const Duration(milliseconds: 300), curve: Curves.bounceIn);
      leftScrollCtrl.animateToItem(widget.pickerModel.currentLeftIndex(),
          duration: const Duration(milliseconds: 300), curve: Curves.bounceIn);

      middleScrollCtrl.animateToItem(widget.pickerModel.currentMiddleIndex(),
          duration: const Duration(milliseconds: 300), curve: Curves.bounceIn);
    }
  }

  @override
  Widget build(BuildContext context) {
    picker_theme.DatePickerTheme theme = widget.route.theme;
    return GetBuilder<FlutterDateTimePickerController>(
      builder: (controller) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            Navigator.pop(context);
            if (widget.route.onCancel != null) {
              widget.route.onCancel!();
            }
          },
          child: AnimatedBuilder(
            animation: widget.route.animation!,
            builder: (BuildContext context, Widget? child) {
              final double bottomPadding =
                  MediaQuery.of(context).padding.bottom - 50;
              return ClipRect(
                child: CustomSingleChildLayout(
                  delegate: _BottomPickerLayout(
                    widget.route.animation!.value,
                    theme,
                    showTitleActions: widget.route.showTitleActions!,
                    bottomPadding: bottomPadding,
                  ),
                  child: Container(
                    child: Material(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                      color: Colors.transparent, //  theme.backgroundColor,
                      child: _renderPickerView(theme),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  bool isStartTimeCanSelect(DateTime dateTime) {
    // 2023-12-1
    DateTime minDate = widget.startTime ?? DateTime(2023, 12, 1);

    // 计算当前时间到2023-12-1的差值
    Duration difference1 = dateTime.difference(minDate);

    if (difference1.inDays >= 0) {
      return true;
    } else {
      return false;
    }
  }

  bool isEndTimeCanSelect(DateTime dateTime) {
    // 2023-12-1
    DateTime maxDate = widget.endTime ?? DateTime.now();

    // 计算当前时间到2023-12-1的差值
    Duration difference2 = dateTime.difference(maxDate);

    if (difference2.inDays <= 0) {
      return true;
    } else {
      return false;
    }
  }

  void _notifyDateChanged() {
    isHaveSelectedTime = true;
    if (startDateTime != null && endDateTime != null) {
      _tempCurrentTime = widget.pickerModel.finalTime()!;
      if (controller.isSelectingStartDate.value) {
        if (isStartTimeCanSelect(_tempCurrentTime!)) {
          startDateTime = _tempCurrentTime;
          widget.onChanged?.call(startDateTime!, endDateTime!);
          startTimeStr = EXDateUtils.formateDateTimeToString(startDateTime!,
              format: "yyyy-MM-dd");
          controller.startTimeStr.value = startTimeStr;
          widget.pickerModel.setCurrentTime(startDateTime ?? widget.startTime!);

          setState(() {
            refreshScrollOffset(isInit: true);
          });
        } else {
          widget.pickerModel.setCurrentTime(startDateTime ?? widget.startTime!);
          Future.delayed(const Duration(milliseconds: 100), () {
            refreshScrollOffset();
          });
        }
      }
      if (controller.isSelectingEndDate.value) {
        if (isEndTimeCanSelect(_tempCurrentTime!)) {
          endDateTime = _tempCurrentTime;
          widget.onChanged?.call(startDateTime!, endDateTime!);
          endTimeStr = EXDateUtils.formateDateTimeToString(endDateTime!,
              format: "yyyy-MM-dd");
          widget.pickerModel.setCurrentTime(endDateTime ?? widget.endTime!);

          controller.endTimeStr.value = endTimeStr;

          setState(() {
            refreshScrollOffset(isInit: true);
          });
        } else {
          widget.pickerModel.setCurrentTime(widget.endTime!);
          Future.delayed(const Duration(milliseconds: 100), () {
            refreshScrollOffset();
          });
        }
      }
    } else {
      if (widget.onChanged != null) {
        widget.onChanged?.call(
          widget.pickerModel.finalTime()!,
          endDateTime!,
        );
      }
    }
  }

  Widget _renderPickerView(picker_theme.DatePickerTheme theme) {
    Widget itemView = _renderItemView(theme);
    if (widget.route.showTitleActions == true) {
      return GestureDetector(
        onTap: () {},
        child: Container(
          decoration: BoxDecoration(
            color: theme.headerColor ?? theme.backgroundColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
          ),
          child: Column(
            children: <Widget>[
              _renderTitleActionsView(theme),
              itemView,
            ],
          ),
        ),
      );
    }
    return itemView;
  }

  Widget _timeWidget(
      picker_theme.DatePickerTheme theme, int index, BuildContext context) {
    return GestureDetector(
      onTap: () {
        controller.changeTitle(index);
        if (index == 0) {
          controller.isSelectingStartDate.value = true;
          controller.isSelectingEndDate.value = false;
          widget.pickerModel
              .setCurrentTime(startDateTime ?? DateTime.parse(startTimeStr));
          _tempCurrentTime = startDateTime ?? DateTime.parse(startTimeStr);
        } else {
          controller.isSelectingStartDate.value = false;
          controller.isSelectingEndDate.value = true;
          widget.pickerModel
              .setCurrentTime(endDateTime ?? DateTime.parse(endTimeStr));
          _tempCurrentTime = endDateTime ?? DateTime.parse(endTimeStr);
        }
        // Future.delayed(Duration(milliseconds: 100), () {
        refreshScrollOffset();
        // });
      },
      child: GetBuilder<FlutterDateTimePickerController>(
        builder: (controller) {
          return Container(
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(
                Radius.circular(2),
              ),
              color: ExColors.fill_3(context),
            ),
            child: Obx(
              () => Text(
                index == 0
                    ? controller.startTimeStr.value
                    : controller.endTimeStr.value,
                style: index == 0
                    ? controller.isSelectingStartDate.value
                        ? ExThemes.textstyle_hm_color1_14(context)
                            .copyWith(color: ExColors.main_4(context))
                        : ExThemes.textstyle_hm_color1_14(context)
                    : controller.isSelectingEndDate.value
                        ? ExThemes.textstyle_hm_color1_14(context)
                            .copyWith(color: ExColors.main_4(context))
                        : ExThemes.textstyle_hm_color1_14(context),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _renderColumnView(
    ValueKey key,
    picker_theme.DatePickerTheme theme,
    StringAtIndexCallBack stringAtIndexCB,
    FixedExtentScrollController scrollController,
    int layoutProportion,
    ValueChanged<int> selectedChangedWhenScrolling,
    ValueChanged<int> selectedChangedWhenScrollEnd,
  ) {
    return Expanded(
      flex: layoutProportion,
      child: Container(
        // padding: EdgeInsets.all(8.0),
        height: theme.containerHeight,
        decoration: BoxDecoration(
          color: theme.headerColor,
        ),
        child: NotificationListener(
          onNotification: (ScrollNotification notification) {
            if (notification.depth == 0 &&
                notification is ScrollEndNotification &&
                notification.metrics is FixedExtentMetrics) {
              final FixedExtentMetrics metrics =
                  notification.metrics as FixedExtentMetrics;
              final int currentItemIndex = metrics.itemIndex;
              selectedChangedWhenScrollEnd(currentItemIndex);
            }
            return false;
          },
          child: CupertinoPicker.builder(
            key: key,
            backgroundColor: theme.headerColor,
            scrollController: scrollController,
            itemExtent: theme.itemHeight!,
            onSelectedItemChanged: (int index) {
              selectedChangedWhenScrolling(index);
            },
            magnification: 1.0,
            useMagnifier: true,
            squeeze: 1.2,
            diameterRatio: 1.0,
            selectionOverlay: Container(
              color: ExColors.fill_3(context).withOpacity(0.4),
            ),
            itemBuilder: (BuildContext context, int index) {
              final content = stringAtIndexCB(index);
              if (content == null) {
                return null;
              }
              return Container(
                // height: theme.itemHeight,
                alignment: Alignment.center,
                color: theme.headerColor,

                child: Text(
                  content,
                  style: theme.itemStyle.copyWith(),
                  textAlign: TextAlign.start,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _renderItemView(picker_theme.DatePickerTheme theme) {
    return Container(
      color: theme.backgroundColor,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              child: widget.pickerModel.layoutProportions()[0] > 0
                  ? _renderColumnView(
                      ValueKey(widget.pickerModel.currentLeftIndex()),
                      theme,
                      widget.pickerModel.leftStringAtIndex,
                      leftScrollCtrl,
                      widget.pickerModel.layoutProportions()[0], (index) {
                      widget.pickerModel.setLeftIndex(index);
                    }, (index) {
                      // setState(() {
                      //   // refreshScrollOffset();

                      // });
                      _notifyDateChanged();
                    })
                  : null,
            ),
            Text(
              widget.pickerModel.leftDivider(),
              style: theme.itemStyle,
            ),
            Container(
              child: widget.pickerModel.layoutProportions()[1] > 0
                  ? _renderColumnView(
                      ValueKey(widget.pickerModel.currentMiddleIndex()),
                      theme,
                      widget.pickerModel.middleStringAtIndex,
                      middleScrollCtrl,
                      widget.pickerModel.layoutProportions()[1], (index) {
                      widget.pickerModel.setMiddleIndex(index);
                    }, (index) {
                      _notifyDateChanged();
                    })
                  : null,
            ),
            Text(
              widget.pickerModel.rightDivider(),
              style: theme.itemStyle,
            ),
            Container(
              child: widget.pickerModel.layoutProportions()[2] > 0
                  ? _renderColumnView(
                      ValueKey(widget.pickerModel.currentMiddleIndex() * 100 +
                          widget.pickerModel.currentLeftIndex()),
                      theme,
                      widget.pickerModel.rightStringAtIndex,
                      rightScrollCtrl,
                      widget.pickerModel.layoutProportions()[2], (index) {
                      widget.pickerModel.setRightIndex(index);
                    }, (index) {
                      _notifyDateChanged();
                    })
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  // Title View
  Widget _renderTitleActionsView(picker_theme.DatePickerTheme theme) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            CupertinoButton(
              pressedOpacity: 0.3,
              child: Text(
                'text88'.tr,
                style: theme.cancelStyle,
              ),
              onPressed: () {
                Navigator.pop(context);
                if (widget.route.onCancel != null) {
                  widget.route.onCancel!();
                }
              },
            ),
            Obx(
              () => Text(
                controller.title.value,
                style: theme.titleStyle,
              ),
            ),
            CupertinoButton(
              pressedOpacity: 0.3,
              child: Text(
                'kline_pop_dialog_confirm'.tr,
                style: theme.doneStyle,
              ),
              onPressed: () {
                if (widget.isShowDoubleTime) {
                  Duration difference = endDateTime!.difference(startDateTime!);
                  if (difference.inDays > 0) {
                    widget.onConfirm?.call(startDateTime!, endDateTime!);
                    Navigator.pop(context, widget.pickerModel.finalTime());
                  } else {
                    Fluttertoast.showToast(
                        msg: "breakeven_analysis_text20".tr,
                        gravity: ToastGravity.CENTER);
                  }
                } else {
                  if (isHaveSelectedTime) {
                    widget.onConfirm?.call(startDateTime!, startDateTime!);
                    Navigator.pop(context, widget.pickerModel.finalTime());
                  } else {
                    widget.onConfirm
                        ?.call(widget.currentTime!, widget.currentTime!);
                    Navigator.pop(context, widget.pickerModel.finalTime());
                  }
                }
              },
            ),
          ],
        ),
        widget.isShowDoubleTime
            ? Column(
                children: [
                  Gaps.vGap18,
                  Text(
                    'breakeven_analysis_text15'.tr,
                    style: theme.descStyle,
                  ),
                  Gaps.vGap16,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Gaps.hGap16,
                      Expanded(child: _timeWidget(theme, 0, context)),
                      Gaps.hGap10,
                      Container(
                        height: 3,
                        width: 13,
                        color: ExColors.fill_5(context),
                      ),
                      Gaps.hGap10,
                      Expanded(child: _timeWidget(theme, 1, context)),
                      Gaps.hGap16,
                    ],
                  )
                ],
              )
            : Container(),
        Gaps.vGap15,
      ],
    );
  }

  String _localeDone() {
    return i18nObjInLocale(widget.locale)['done'] as String;
  }

  String _localeCancel() {
    return i18nObjInLocale(widget.locale)['cancel'] as String;
  }
}

class _BottomPickerLayout extends SingleChildLayoutDelegate {
  _BottomPickerLayout(
    this.progress,
    this.theme, {
    this.showTitleActions,
    this.bottomPadding = 0,
  });

  final double progress;
  final bool? showTitleActions;
  final picker_theme.DatePickerTheme theme;
  final double bottomPadding;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    return BoxConstraints(
      minWidth: constraints.maxWidth,
      maxWidth: constraints.maxWidth,
      minHeight: 0.0,
      maxHeight: theme.totalHeight! + bottomPadding,
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final height = size.height - childSize.height * progress;
    return Offset(0.0, height);
  }

  @override
  bool shouldRelayout(_BottomPickerLayout oldDelegate) {
    return progress != oldDelegate.progress;
  }
}
