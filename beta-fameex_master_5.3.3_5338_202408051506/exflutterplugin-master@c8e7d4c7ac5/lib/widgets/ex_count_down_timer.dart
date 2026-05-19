import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/task_info_list_entity.dart';
import '../themes/Themes.dart';
import '../utils/string_utils.dart';

class EXCountDownTimerWidget extends StatefulWidget {
  final int? initTime;
  final bool isEnd;
  final TextStyle? textStyle;
  const EXCountDownTimerWidget({
    super.key,
    required this.initTime,
    required this.isEnd,
    this.textStyle,
  });

  @override
  State<EXCountDownTimerWidget> createState() => _EXCountDownTimerWidgetState();
}

class _EXCountDownTimerWidgetState extends State<EXCountDownTimerWidget> {
  Timer? _timer;
  late DateTime _targetTime;
  late Duration _remainingTime;

  RxString showTime = "".obs;

  @override
  void initState() {
    super.initState();
    if (widget.isEnd == true) {
      showTime.value = "00d 00:00:00";
      return;
    }
    _targetTime = DateTime.fromMillisecondsSinceEpoch(widget.initTime!);

    calculateRemainingTime();
    _timer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
      calculateRemainingTime();
    });
  }

  void calculateRemainingTime() {
    DateTime currentTime = DateTime.now();
    _remainingTime = _targetTime.difference(currentTime);
    if (_remainingTime.isNegative) {
      showTime.value = "00d 00:00:00";
      _timer?.cancel();
    } else {
      showTime.value = StringUtils.formateTime(_remainingTime);
    }
  }

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Text(
        showTime.value,
        style: widget.textStyle ?? ExThemes.textstyle_sm_color1_14(context),
      ),
    );
  }
}
