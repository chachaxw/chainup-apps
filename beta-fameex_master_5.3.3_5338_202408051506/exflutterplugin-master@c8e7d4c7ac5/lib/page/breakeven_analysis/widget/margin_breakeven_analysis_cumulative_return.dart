import 'dart:async';

import 'package:chainup_flutter_ex/constants/color_constant.dart';
import 'package:chainup_flutter_ex/page/breakeven_analysis/widget/chart_bottom_titles.dart';
import 'package:chainup_flutter_ex/page/breakeven_analysis/widget/gesture_capture.dart';
import 'package:chainup_flutter_ex/page/common/task_center_common.dart';
import 'package:chainup_flutter_ex/utils/date_utils.dart';
import 'package:chainup_flutter_ex/utils/decimal_utils.dart';
import 'package:chainup_flutter_ex/widgets/ex_drop_down_button.dart';
import 'package:chainup_flutter_ex/widgets/ex_loading_view.dart';
import 'package:decimal/decimal.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_utils/get_utils.dart';

import '../../../constants/icon_constant.dart';
import '../../../models/user_asset_profit_loss_data_lever_entity.dart';
import '../../../themes/Themes.dart';
import '../../../widgets/gaps.dart';
import '../util/breakeven_analysis_util.dart';

class MarginBreakevenAnalysisCumulativeReturn extends StatefulWidget {
  final bool showDropdownButton;
  final String? selectedValue;
  final ValueChanged<String>? selectCoinCallback;
  final String? profitNum;
  final String? profitRatio;
  final String? profitTime;
  final List<String>? chartBottomTitles;
  final List<String>? chartLeftTitles;
  final List<double>? chartRightTitles;
  final List<UserAssetProfitLossDataLeverEntity>? sourceDataList;
  final List<String>? bottomDateList;
  final bool? needTransformToBTC;
  final int? btcPrecision;
  final ExLoadingStatus? loadStatus;
  final VoidCallback? tryCallback;
  final bool? showAmount;
  final VoidCallback? showAmountChanged;

  ///
  MarginBreakevenAnalysisCumulativeReturn({
    this.selectedValue = "BTC",
    this.showDropdownButton = false,
    this.selectCoinCallback,
    this.profitNum = "0.00",
    this.profitRatio = "0.00",
    this.profitTime,
    this.loadStatus = ExLoadingStatus.failed,
    this.tryCallback,
    this.showAmount = true,
    this.needTransformToBTC = true,
    this.showAmountChanged,
    required this.chartBottomTitles,
    required this.chartRightTitles,
    required this.chartLeftTitles,
    required this.sourceDataList,
    required this.bottomDateList,
    required this.btcPrecision,
    super.key,
  });

  @override
  State<MarginBreakevenAnalysisCumulativeReturn> createState() =>
      _MarginBreakevenAnalysisCumulativeReturnState();
}

class _MarginBreakevenAnalysisCumulativeReturnState
    extends State<MarginBreakevenAnalysisCumulativeReturn> {
  Timer? _timer;

  List<double> leftShowTagList = [];
  List<double> rightShowTagList = [];
  List<int> bottomTagIndexList = [];

  double minX = 0;
  double maxX = 0;
  double minY = 0;
  double maxY = 0;
  double minZ = 0;
  double maxZ = 0;

  String _profitNum = "";
  String _profitTime = "";
  String _profitRatio = "";

  int clickedSpotIndex = -1;
  double chartLineWidth = 0.0;

  @override
  void initState() {
    super.initState();

    initShowData();
  }

  @override
  void dispose() {
    _timer?.cancel();

    super.dispose();
  }

  void initShowData() {
    _profitNum = widget.profitNum ?? "0.00";
    if (double.parse(_profitNum) == 0) {
      _profitNum = "0.00";
    }
    _profitRatio = widget.profitRatio ?? "0.00";
    if (double.parse(_profitRatio) == 0) {
      _profitRatio = "0.00";
    } else {
      _profitRatio = DecimalUtils.showSNormal(double.parse(_profitRatio),
          isShowThous: true, digits: 8);
    }

    _profitTime = widget.profitTime ??
        EXDateUtils.formateDateTimeToString(EXDateUtils.getUtc8TimeNow(),
            format: "yyyy-MM-dd");
  }

  void _onTimerFinished() {
    setState(() {
      clickedSpotIndex = -1;
      initShowData();
    });
  }

  void _startTimer() {
    // _timer?.cancel();
    // // 启动定时器
    // _timer = Timer(const Duration(seconds: 2), _onTimerFinished);
  }

  void _stopTimer() {
    // 停止定时器
    // _timer?.cancel();
    // setState(() {
    //   clickedSpotIndex = -1;
    // });
  }

  void handleInitData() {
    if (clickedSpotIndex == -1) {
      initShowData();
    }
    if (widget.chartLeftTitles == null || widget.chartLeftTitles!.isEmpty) {
      bottomTagIndexList = [0, 2, 4, 6];
      minX = double.parse(bottomTagIndexList.first.toString());
      maxX = double.parse(bottomTagIndexList.last.toString());
      minY = 0;
      maxY = 10;
    } else {
      minY = 0;
      maxY = 0;

      bottomTagIndexList = BreakevenAnalysisUtil.getEquallySpacedIntNumbers(0,
          widget.chartLeftTitles!.length - 1, widget.chartBottomTitles!.length);

      minX = double.parse(bottomTagIndexList.first.toString());
      maxX = double.parse(bottomTagIndexList.last.toString());

      for (var i = 0; i < widget.chartLeftTitles!.length; i++) {
        double num = double.tryParse(widget.chartLeftTitles![i]) ?? 0;
        if (num >= maxY) {
          maxY = num;
        }
        if (num < minY) {
          minY = num;
        }
      }

      if (minY == 0 && maxY == 0) {
        maxY = 10;
      }

      leftShowTagList =
          BreakevenAnalysisUtil.getEquallySpacedDoubleNumbers(minY, maxY, 5);
      // minZ = widget.chartRightTitles!.first;
      // maxZ = widget.chartRightTitles!.last;

      // rightShowTagList =
      //     BreakevenAnalysisUtil.getEquallySpacedDoubleNumbers(minZ, maxZ, 5);
    }
  }

  bool isEmpty() {
    return widget.sourceDataList == null || widget.sourceDataList!.isEmpty;
  }

  @override
  Widget build(BuildContext context) {
    handleInitData();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Gaps.vGap12,
          Row(
            children: [
              Text(
                "breakeven_analysis_text25".tr,
                style: ExThemes.textstyle_hm_color1_16((context)),
              ),
              Gaps.hGap4,
              GestureDetector(
                onTap: () {
                  widget.showAmountChanged?.call();
                },
                child: widget.showAmount!
                    ? BreakevenAnalysisIcon.eyeIcon()
                    : BreakevenAnalysisIcon.assetsEyeoff(),
              ),
              const Spacer(),
              _dropdownButton(context)
            ],
          ),
          Gaps.vGap4,
          Text(
            _profitTime,
            style: ExThemes.textstyle_hr_color2_12((context)),
          ),
          Gaps.vGap20,
          Row(
            children: [
              _item(0, context),
              _item(1, context),
            ],
          ),
          Gaps.vGap10,
          widget.loadStatus == ExLoadingStatus.loading ||
                  widget.loadStatus == ExLoadingStatus.failed
              ? Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 10),
                  child: LoadingView(
                    loadingStatus: widget.loadStatus,
                    tryCallback: () {
                      widget.tryCallback?.call();
                    },
                  ),
                )
              : _chartView(),
          Gaps.vGap5,
        ],
      ),
    );
  }

  Widget _chartView() {
    return Stack(
      children: [
        Positioned(
          top: 17.5,
          left: 0,
          height: 169,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Container(
                margin: EdgeInsets.only(
                    left: MediaQuery.of(context).size.width -
                        chartLineWidth -
                        32),
                width: chartLineWidth,
                child: Column(
                  children: [
                    _gapLine(),
                    _gapLine(),
                    _gapLine(),
                    _gapLine(),
                    _gapLine(),
                  ],
                ),
              );
            },
          ),
        ),
        SizedBox(
          height: 230,
          child: Row(
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  return Column(
                    children: _leftTitles(),
                  );
                },
              ),
              Gaps.hGap8,
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    chartLineWidth = constraints.maxWidth;
                    return BaseGestureCapture(
                      onPointerCancel: (event) {
                        _onTimerFinished();
                      },
                      onPointerUp: (event) {
                        _onTimerFinished();
                      },
                      child: SizedBox(
                        height: 197,
                        child: _kline(
                          context,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        _chartBottomTitles(),
      ],
    );
  }

  Widget _icon() {
    return Row(
      children: [
        Container(
          width: 3,
          height: 1,
          color: ExColors.main_1(context),
        ),
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(
                Radius.circular(6),
              ),
              border: Border.all(
                width: 1,
                color: ExColors.main_1(context),
              )),
        ),
        Container(
          width: 3,
          height: 1,
          color: ExColors.main_1(context),
        ),
      ],
    );
  }

  Widget _chartBottomTitles() {
    return Positioned(
      right: 0,
      bottom: 23,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SizedBox(
            width: chartLineWidth,
            child: ChartBottomTitles(
              dataList: widget.chartBottomTitles ?? [],
            ),
          );
        },
      ),
    );
  }

  Widget _gapLine() {
    return Column(
      children: [
        Divider(
          height: 1,
          color: ExColors.fill_4(context),
        ),
        const SizedBox(
          height: 158 / 5,
        ),
      ],
    );
  }

  List<Widget> _leftTitles() {
    List<Widget> list = [];
    List titles = [];
    if (!isEmpty()) {
      List<Decimal> calculateMidpointsList = DecimalUtils.calculateMidpoints(
          Decimal.parse(minY.toString()), Decimal.parse(maxY.toString()), 5);

      for (var i = 0; i < calculateMidpointsList.length; i++) {
        String title = TaskCenterCommon.truncateToSpecifiedDecimalPlaces(
            calculateMidpointsList[i],
            widget.needTransformToBTC! ? widget.btcPrecision : 2,
            needAddZero: true);
        titles.add(title);
      }

      titles = titles.reversed.toList();
    } else {
      titles = ["0.00", "2.00", "4.00", "6.00", "8.00", "10.00"];
      titles = titles.reversed.toList();
    }
    for (var i = 0; i < titles.length; i++) {
      list.add(
        Container(
          height: 197 / 6,
          // color: Colors.red,
          // constraints: const BoxConstraints(maxWidth: 33),
          alignment: Alignment.center,
          child: Text(
            titles[i],
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: ExThemes.textstyle_hr_color2_12(context),
          ),
        ),
      );
    }
    return list;
  }

  Widget _dropdownButton(BuildContext context) {
    return widget.showDropdownButton
        ? ExDropDownButton(
            items: const [
              'BTC',
              'USDT',
            ],
            selectedCallback: (value) {
              widget.selectCoinCallback?.call(value);
            },
            selectedValue: widget.selectedValue,
          )
        : Container();
  }

  Widget _item(int index, BuildContext context) {
    String profitNum = _profitNum;
    String profitRatio = _profitRatio;
    double num = double.tryParse(
            TaskCenterCommon.truncateToSpecifiedDecimalPlaces(_profitNum,
                widget.needTransformToBTC! ? widget.btcPrecision : 2)) ??
        0;
    double ratio = double.tryParse(
            TaskCenterCommon.truncateToSpecifiedDecimalPlaces(
                profitRatio, 2)) ??
        0.0;
    if (widget.loadStatus == ExLoadingStatus.loading) {
      num = 0;
      ratio = 0;
    }

    if (widget.showAmount!) {
      profitNum = num == 0
          ? widget.needTransformToBTC!
              ? "0.00000000"
              : "0.00"
          : num > 0
              ? "+${DecimalUtils.formateNum(_profitNum, isShowThous: true, digits: widget.needTransformToBTC! ? widget.btcPrecision : 2)}"
              : DecimalUtils.formateNum(_profitNum,
                  isShowThous: true,
                  digits: widget.needTransformToBTC! ? widget.btcPrecision : 2);

      profitRatio = ratio == 0
          ? "0.00%"
          : ratio > 0
              ? "+${DecimalUtils.formateNum(profitRatio, isShowThous: true, digits: 2)}%"
              : "${DecimalUtils.formateNum(profitRatio, isShowThous: true, digits: 2)}%";
    } else {
      profitNum = "******";
      profitRatio = "******";
    }

    Color color1 = ExColors.setRiseFallTextColor(
        TaskCenterCommon.truncateToSpecifiedDecimalPlaces(
            _profitNum, widget.needTransformToBTC! ? 8 : 2),
        ExColors.text_1(context),
        context);
    Color color2 = ExColors.setRiseFallTextColor(
        TaskCenterCommon.truncateToSpecifiedDecimalPlaces(ratio, 2),
        ExColors.text_1(context),
        context);
    if (!widget.showAmount!) {
      color1 = ExColors.text_1(context);
      color2 = ExColors.text_1(context);
    }

    return Flexible(
      flex: 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            index == 0 ? profitNum : profitRatio,
            style: ExThemes.textstyle_hm_color1_14(context).copyWith(
              color: index == 0 ? color1 : color2,
            ),
          ),
          Gaps.vGap4,
          Row(
            children: [
              index == 0
                  ? _icon()
                  : Container(
                      // height: 6,
                      // width: 6,
                      // decoration: BoxDecoration(
                      //   borderRadius:
                      //       const BorderRadius.all(Radius.circular(1)),
                      //   color: index == 0
                      //       ? ExColors.main_yellow_color(context)
                      //       : ExColors.main_3(context),
                      // ),
                      ),
              // Gaps.hGap4,
              Text(
                index == 0
                    ? "${"breakeven_analysis_text26".tr}(${widget.selectedValue})"
                    : "breakeven_analysis_text27".tr,
                style: ExThemes.textstyle_hr_color2_10((context)),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _kline(BuildContext context) {
    return LineChart(
      LineChartData(
        minX: minX,
        maxX: maxX,
        minY: minY,
        maxY: maxY,
        backgroundColor: Colors.transparent, //ExColors.fill_2(context),
        borderData: FlBorderData(
          show: true,
          border: Border(
            top: const BorderSide(
              color: Colors.transparent, //ExColors.fill_4(context),
            ),
            bottom: BorderSide(
              color: ExColors.fill_4(context),
            ),
          ),
        ),
        gridData: FlGridData(
          show: false,
          drawVerticalLine: false,
          horizontalInterval: 10, //(maxY - minY) / 5,
          getDrawingHorizontalLine: (value) {
            return FlLine(color: ExColors.fill_4(context), strokeWidth: 1);
          },
          checkToShowHorizontalLine: (value) {
            return true;
          },
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: false,
              reservedSize: 29,
              interval: (maxY - minY) / 4,
              getTitlesWidget: (value, meta) {
                return _leftTitleWidgets(value, meta, context);
              },
            ),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(
              showTitles: false,
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 29,
              interval: 1,
              getTitlesWidget: (value, meta) {
                return _bottomTitleWidgets(value, meta, context);
              },
            ),
          ),
        ),
        lineBarsData: [
          _lineChartBarData1(context),
          // _lineChartBarData2(context),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            fitInsideHorizontally: true,
            fitInsideVertically: true,
            tooltipBgColor: Colors.transparent, //ExColors.main_3(context),
            tooltipRoundedRadius: 2,
            tooltipPadding:
                const EdgeInsets.only(left: 4, right: 4, top: 3, bottom: 2),
            getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
              return touchedBarSpots.map((barSpot) {
                // final flSpot = barSpot;
                // debugPrint("flSpot.y: ${flSpot.y}");
                // String num = flSpot.y == 0
                //     ? widget.needTransformToBTC!
                //         ? "0.00000000"
                //         : "0.00"
                //     : DecimalUtils.formateNum(flSpot.y.toString(),
                //         isShowThous: true,
                //         digits: widget.needTransformToBTC! ? 8 : 2);
                // String ratio = widget.chartRightTitles![flSpot.spotIndex] == 0
                //     ? "0.00"
                //     : DecimalUtils.formateNum(
                //         (widget.chartRightTitles![flSpot.spotIndex]).toString(),
                //         isShowThous: true,
                //         digits: 2);

                return LineTooltipItem(
                  // '\$$num\n$ratio%',
                  "",
                  ExThemes.textstyle_hr_color2_10(context).copyWith(
                    // color: ExColors.main_1(context),
                    color: Colors.transparent,
                  ),
                );
              }).toList();
            },
          ),
          touchCallback:
              (FlTouchEvent touchEvent, LineTouchResponse? response) {
            if (response == null || response.lineBarSpots == null) {
              return;
            }
            // debugPrint("touchEvent: $touchEvent");
            if (touchEvent is FlLongPressMoveUpdate) {
              final spotIndex = response.lineBarSpots!.first.spotIndex;

              updateShowData(spotIndex);
            }
            if (touchEvent is FlLongPressEnd) {
              _startTimer();
            }
            if (touchEvent is FlTapDownEvent || touchEvent is FlPanDownEvent) {
              final spotIndex = response.lineBarSpots!.first.spotIndex;

              if (clickedSpotIndex != spotIndex) {
                _startTimer();

                clickedSpotIndex = spotIndex;

                updateShowData(spotIndex);
              } else {
                _stopTimer();
              }
            }

            if (touchEvent is FlPanUpdateEvent) {
              _stopTimer();
              final spotIndex = response.lineBarSpots!.first.spotIndex;
              clickedSpotIndex = spotIndex;

              updateShowData(spotIndex);
              _startTimer();
            }
          },
          handleBuiltInTouches: true,
          mouseCursorResolver:
              (FlTouchEvent event, LineTouchResponse? response) {
            if (response == null || response.lineBarSpots == null) {
              return SystemMouseCursors.basic;
            }
            return SystemMouseCursors.click;
          },
          getTouchLineEnd: (barData, spotIndex) {
            return -double.infinity;
          },
          getTouchLineStart: (barData, spotIndex) {
            return double.infinity;
          },
          getTouchedSpotIndicator: (barData, spotIndexes) {
            return spotIndexes.map((int index) {
              final flLine = FlLine(
                  color: ExColors.fill_4(context),
                  strokeWidth: 1.3,
                  dashArray: [3, 3]);

              final dotData =
                  FlDotData(getDotPainter: (spot, percent, bar, index) {
                return FlDotCirclePainter(
                  radius: 3,
                  color: Colors.transparent, //ExColors.main_1(context),
                  strokeColor: Colors.transparent, //ExColors.fill_4(context),
                );
              });

              return TouchedSpotIndicatorData(flLine, dotData);
            }).toList();
          },
        ),
      ),
    );
  }

  void updateShowData(int spotIndex) {
    clickedSpotIndex = spotIndex;
    // debugPrintStack();
    setState(() {
      if (isEmpty()) {
        initShowData();
      } else {
        try {
          UserAssetProfitLossDataLeverEntity data =
              widget.sourceDataList![spotIndex];
          double num = double.tryParse(widget.chartLeftTitles![spotIndex]) ?? 0;
          _profitNum = num == 0
              ? "0.00"
              : widget.needTransformToBTC!
                  ? TaskCenterCommon.truncateToSpecifiedDecimalPlaces(num, 8,
                      needAddZero: true)
                  : TaskCenterCommon.truncateToSpecifiedDecimalPlaces(num, 2,
                      needAddZero: true);
          double ratio = data.cumulativeProfitRatio ?? 0;
          _profitRatio = ratio == 0 ? "0.00" : ratio.toString();
          _profitTime = data.curDateStr ??
              EXDateUtils.formateDateTimeToString(EXDateUtils.getUtc8TimeNow(),
                  format: "yyyy-MM-dd");
        } catch (e) {
          debugPrint("$e");
        }
      }
    });
  }

  LineChartBarData _lineChartBarData1(BuildContext context) {
    LineChartBarData lineChartBarData = LineChartBarData(
      isCurved: true,
      curveSmoothness: 0,
      color: ExColors.main_1(context),
      barWidth: 1,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: (widget.sourceDataList != null &&
                widget.sourceDataList!.length > 30)
            ? false
            : true,
        getDotPainter: (p0, p1, p2, p3) {
          return FlDotCirclePainter(
            color: ExColors.fill_2(context),
            strokeColor: ExColors.main_1(context),
            strokeWidth: 1,
            radius: 2,
          );
        },
      ),
      spots: spotList1(),
    );

    return lineChartBarData;
  }

  List<FlSpot> spotList1() {
    int length =
        widget.chartLeftTitles != null ? widget.chartLeftTitles!.length : 0;

    List<FlSpot> list = [];
    for (int i = 0; i < length; i++) {
      double num = double.tryParse(widget.chartLeftTitles![i]) ?? 0;
      double x = i * 1.0;
      FlSpot spot = FlSpot(x, num);
      list.add(spot);
    }
    return list;
  }

  Widget _leftTitleWidgets(double value, TitleMeta meta, BuildContext context) {
    return Text(value.toString(),
        style: ExThemes.textstyle_hr_color2_12(context),
        textAlign: TextAlign.center);
  }

  Widget _rightTitleWidgets(
      double value, TitleMeta meta, BuildContext context) {
    // debugPrint("_leftTitleWidgets ==== $value == ${meta.max}");

    return Text(value.toString(),
        style: ExThemes.textstyle_hr_color2_12(context),
        textAlign: TextAlign.center);
  }

  Widget _bottomTitleWidgets(
    double value,
    TitleMeta meta,
    BuildContext context,
  ) {
    TextStyle style = ExThemes.textstyle_hr_color2_12(context)
        .copyWith(color: Colors.transparent);
    String text = "";

    // for (var i = 0; i < bottomTagIndexList.length; i++) {
    //   if (value == bottomTagIndexList[i]) {
    //     if (value == bottomTagIndexList.last) {
    //       text = widget.chartBottomTitles![i];
    //       text = "$text       ";
    //     } else if (value == bottomTagIndexList.first) {
    //       text = widget.chartBottomTitles![i];
    //       text = "        $text";
    //     } else {
    //       text = widget.chartBottomTitles![i];
    //     }
    //   }
    // }
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 8,
      child: Text(text, style: style),
    );
  }
}
