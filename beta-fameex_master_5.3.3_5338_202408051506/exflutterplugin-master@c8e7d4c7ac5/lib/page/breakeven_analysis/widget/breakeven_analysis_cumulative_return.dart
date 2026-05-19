import 'dart:async';

import 'package:chainup_flutter_ex/constants/color_constant.dart';
import 'package:chainup_flutter_ex/page/breakeven_analysis/breakeven_analysis_controller/coin_transaction_breakeven_analysis_controller.dart';
import 'package:chainup_flutter_ex/page/breakeven_analysis/widget/chart_bottom_titles.dart';
import 'package:chainup_flutter_ex/page/breakeven_analysis/widget/gesture_capture.dart';
import 'package:chainup_flutter_ex/page/common/task_center_common.dart';
import 'package:chainup_flutter_ex/utils/date_utils.dart';
import 'package:chainup_flutter_ex/utils/decimal_utils.dart';
import 'package:chainup_flutter_ex/widgets/ex_loading_view.dart';
import 'package:decimal/decimal.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../models/cumulative_profit_ratio_chart_data_entity.dart';
import '../../../themes/Themes.dart';
import '../../../widgets/gaps.dart';
import 'chart_title.dart';

class BreakevenAnalysisCumulativeReturn extends StatefulWidget {
  final String? btcCumulativeRate;
  final String? cumulativeProfitAndLossRatio;
  final List<CumulativeProfitRatioChartDataEntity>? dataList;
  final List<String>? bottomDateList;
  final List<String>? chartBottomTitles;
  final List<int>? bottomTagIndexList;
  final ExLoadingStatus? loadStatus;
  final VoidCallback? tryCallback;

  BreakevenAnalysisCumulativeReturn({
    this.btcCumulativeRate,
    this.cumulativeProfitAndLossRatio,
    this.dataList,
    this.bottomDateList,
    this.chartBottomTitles,
    this.bottomTagIndexList,
    this.loadStatus,
    this.tryCallback,
    super.key,
  });

  @override
  State<BreakevenAnalysisCumulativeReturn> createState() =>
      _BreakevenAnalysisCumulativeReturnState();
}

class _BreakevenAnalysisCumulativeReturnState
    extends State<BreakevenAnalysisCumulativeReturn> {
  Timer? _timer;

  double minX = 0;
  double maxX = 0;
  double minY = 0;
  double maxY = 0;
  var clickedSpotIndex = -1;

  List<int> keepShowTooltipOnSpots = [];
  List<int> showingTooltipOnSpots = [];

  String _cumulativeProfitAndLossRatio = "0.00";
  String _btcCumulativeRate = "0.00";

  String showTime = "";

  double chartLineWidth = 0.0;

  @override
  void initState() {
    super.initState();
    _cumulativeProfitAndLossRatio = widget.cumulativeProfitAndLossRatio!;
    _btcCumulativeRate = widget.btcCumulativeRate!;

    showTime = EXDateUtils.formateDateTimeToString(EXDateUtils.getUtc8TimeNow(),
        format: "yyyy-MM-dd");
  }

  @override
  void didUpdateWidget(covariant BreakevenAnalysisCumulativeReturn oldWidget) {
    super.didUpdateWidget(oldWidget);
    _cumulativeProfitAndLossRatio = widget.cumulativeProfitAndLossRatio!;
    _btcCumulativeRate = widget.btcCumulativeRate!;
  }

  void _onTimerFinished() {
    setState(() {
      clickedSpotIndex = -1;

      _cumulativeProfitAndLossRatio = widget.cumulativeProfitAndLossRatio!;
      _btcCumulativeRate = widget.btcCumulativeRate!;
      showTime = EXDateUtils.formateDateTimeToString(
          EXDateUtils.getUtc8TimeNow(),
          format: "yyyy-MM-dd");
    });
  }

  void _startTimer() {
    _timer?.cancel();
    // 启动定时器
    _timer = Timer(const Duration(seconds: 2), _onTimerFinished);
  }

  void _stopTimer() {
    // 停止定时器
    _timer?.cancel();
    setState(() {
      clickedSpotIndex = -1;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void handleInitData() {
    keepShowTooltipOnSpots = [];
    showingTooltipOnSpots = [];
    if (isEmpty()) {
      minX = 0;
      maxX = 6;
      minY = 0;
      maxY = 10;
      keepShowTooltipOnSpots = [0, 6];
      showingTooltipOnSpots = [0, 6];
      maxX = double.parse(widget.bottomTagIndexList!.last.toString());
    } else {
      int maxIndex = 0;
      int minIndex = 0;
      minY = widget.dataList!.first.cumulativeRageReturn ?? 0;
      maxY = widget.dataList!.first.cumulativeRageReturn ?? 0;
      for (var i = 0; i < widget.dataList!.length; i++) {
        CumulativeProfitRatioChartDataEntity data = widget.dataList![i];
        double cumulativeRageReturn = data.cumulativeRageReturn!;
        double btcCumulativeRate = data.btcCumulativeRate!;
        // debugPrint(
        //     "cumulativeRageReturn: $cumulativeRageReturn  -- $i \n  btcCumulativeRate: $btcCumulativeRate");
        if (cumulativeRageReturn >= maxY) {
          maxIndex = i;
          maxY = cumulativeRageReturn;
        }
        if (cumulativeRageReturn <= minY) {
          minIndex = i;
          minY = cumulativeRageReturn;
        }
        if (btcCumulativeRate >= maxY) {
          maxIndex = i;
          maxY = btcCumulativeRate;
        }
        if (btcCumulativeRate <= minY) {
          minIndex = i;
          minY = btcCumulativeRate;
        }
      }

      keepShowTooltipOnSpots = [minIndex, maxIndex];
      showingTooltipOnSpots = [minIndex, maxIndex];
      minX = double.parse(widget.bottomTagIndexList!.first.toString());
      maxX = double.parse(widget.bottomTagIndexList!.last.toString());

      if (minY == 0 && maxY == 0) {
        maxY = 10;
      }
    }
  }

  bool isEmpty() {
    return widget.dataList == null || widget.dataList!.isEmpty;
  }

  @override
  Widget build(BuildContext context) {
    handleInitData();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Gaps.vGap28,
          ChartTitle(
            title: "breakeven_analysis_text9".tr,
          ),
          Gaps.vGap4,
          Text(
            showTime,
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
                  padding: const EdgeInsets.only(top: 20, bottom: 0),
                  child: LoadingView(
                    loadingStatus: widget.loadStatus,
                    tryCallback: () {
                      widget.tryCallback?.call();
                    },
                  ),
                )
              : _chartView(),
          // Gaps.vGap20,
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
                      child: Container(
                        height: 197,
                        child: _kline(context),
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

  Widget _chartBottomTitles() {
    return Positioned(
      right: 0,
      bottom: 25,
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

  List<Widget> _leftTitles() {
    List<Widget> list = [];
    List titles = [];
    if (!isEmpty()) {
      List<Decimal> calculateMidpointsList = DecimalUtils.calculateMidpoints(
          Decimal.parse(minY.toString()), Decimal.parse(maxY.toString()), 5);

      for (var i = 0; i < calculateMidpointsList.length; i++) {
        String title = DecimalUtils.formateNum(calculateMidpointsList[i],
            digits: 2, isShowThous: true);
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
            titles[i] + "%",
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: ExThemes.textstyle_hr_color2_12(context),
          ),
        ),
      );
    }
    return list;
  }

  Widget _item(int index, BuildContext context) {
    String leftStr = double.parse(_cumulativeProfitAndLossRatio) == 0
        ? "0.00%"
        : double.parse(_cumulativeProfitAndLossRatio) > 0
            ? "+${DecimalUtils.formateNum(_cumulativeProfitAndLossRatio, digits: 2, isShowThous: true)}%"
            : "${DecimalUtils.formateNum(_cumulativeProfitAndLossRatio, digits: 2, isShowThous: true)}%";

    String tempRight = DecimalUtils.showSNormal(_btcCumulativeRate,
        digits: 2, isShowThous: true);
    String rightStr = double.parse(_btcCumulativeRate) == 0
        ? "0.00%"
        : double.parse(_btcCumulativeRate) > 0
            ? "+${DecimalUtils.formateNum(_btcCumulativeRate, digits: 2, isShowThous: true)}%"
            : "${DecimalUtils.formateNum(_btcCumulativeRate, digits: 2, isShowThous: true)}%";

    Color color1 = ExColors.setRiseFallTextColor(
        _cumulativeProfitAndLossRatio, ExColors.text_1(context), context);
    Color color2 = ExColors.setRiseFallTextColor(
        _btcCumulativeRate, ExColors.text_1(context), context);

    return Flexible(
      flex: 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GetBuilder<CoinTransactionBreakevenAnalysisController>(
            builder: (controller) {
              return Obx(
                () => Text(
                  controller.showAmount.value
                      ? index == 0
                          ? leftStr
                          : rightStr
                      : "******",
                  style: ExThemes.textstyle_hm_color1_14(context).copyWith(
                    color: controller.showAmount.value
                        ? index == 0
                            ? color1
                            : color2
                        : ExColors.text_1(context),
                  ),
                ),
              );
            },
          ),
          Row(
            children: [
              Container(
                height: 6,
                width: 6,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(1)),
                  color: index == 0
                      ? ExColors.warning_1(context)
                      : ExColors.main_1(context),
                ),
              ),
              Gaps.hGap4,
              Text(
                index == 0
                    ? "breakeven_analysis_text27".tr
                    : "breakeven_analysis_text28".tr,
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
        baselineY: 0,
        backgroundColor: Colors.transparent, //ExColors.fill_2(context),
        borderData: FlBorderData(
          show: true,
          border: Border(
            ///顶部横线不展示
            top: const BorderSide(
              color: Colors.transparent, // ExColors.fill_4(context),
            ),
            bottom: BorderSide(
              color: ExColors.fill_4(context),
              width: 0.5,
            ),
          ),
        ),
        gridData: FlGridData(
          show: false,
          horizontalInterval: 10, //(maxY - minY) / 5,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) {
            // debugPrint(
            //     "maxY: $maxY  -- minY:$minY  ====value $value --- ${(maxY - minY) / 5}");

            return FlLine(
              color: ExColors.fill_4(context),
              strokeWidth: 1,
            );
          },
          checkToShowHorizontalLine: (value) {
            // debugPrint("checkToShowHorizontalLine ++++  $value");
            return true;
          },
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: false,
              reservedSize: 29,
              interval: 1,
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
          _lineChartBarData2(context),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: Colors.transparent, //ExColors.main_3(context),
            tooltipRoundedRadius: 2,
            tooltipPadding:
                const EdgeInsets.only(left: 4, right: 4, top: 3, bottom: 2),
            getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
              return touchedBarSpots.map((barSpot) {
                final flSpot = barSpot;
                return LineTooltipItem(
                  flSpot.y == 0
                      ? "0.00%"
                      : "${DecimalUtils.formateNum(flSpot.y, digits: 2, isShowThous: true)}%",
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

            if (touchEvent is FlLongPressMoveUpdate) {
              final spotIndex = response.lineBarSpots!.first.spotIndex;
              updateShowData(spotIndex);
            }
            if (touchEvent is FlLongPressEnd) {
              _startTimer();
            }
            if (touchEvent is FlTapDownEvent) {
              final spotIndex = response.lineBarSpots!.first.spotIndex;

              if (clickedSpotIndex != spotIndex) {
                _startTimer();

                clickedSpotIndex = spotIndex;

                if (showingTooltipOnSpots.contains(spotIndex)) {
                  showingTooltipOnSpots.remove(spotIndex);
                }
                if (!showingTooltipOnSpots.contains(spotIndex)) {
                  showingTooltipOnSpots.add(spotIndex);
                } else {
                  showingTooltipOnSpots.clear();
                  showingTooltipOnSpots.addAll(keepShowTooltipOnSpots);
                }
                updateShowData(spotIndex);
              } else {
                _stopTimer();
              }
            }
            if (touchEvent is FlPanUpdateEvent) {
              _stopTimer();
              final spotIndex = response.lineBarSpots!.first.spotIndex;
              clickedSpotIndex = spotIndex;

              if (showingTooltipOnSpots.contains(spotIndex)) {
                showingTooltipOnSpots.remove(spotIndex);
              }
              if (!showingTooltipOnSpots.contains(spotIndex)) {
                showingTooltipOnSpots.add(spotIndex);
              }
              updateShowData(spotIndex);
              _startTimer();
            }
          },
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
          handleBuiltInTouches: true,
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
      duration: const Duration(milliseconds: 250),
    );
  }

  void updateShowData(int spotIndex) {
    setState(() {
      if (isEmpty()) {
        _cumulativeProfitAndLossRatio = "0.00";
        _btcCumulativeRate = "0.00";
      } else {
        CumulativeProfitRatioChartDataEntity data = widget.dataList![spotIndex];
        _cumulativeProfitAndLossRatio =
            TaskCenterCommon.truncateToSpecifiedDecimalPlaces(
                data.cumulativeRageReturn, 2);
        _btcCumulativeRate = TaskCenterCommon.truncateToSpecifiedDecimalPlaces(
            data.btcCumulativeRate, 2);
      }

      showTime = widget.bottomDateList![spotIndex];
    });
  }

  List<FlSpot> spotList1() {
    int length = isEmpty() ? 0 : widget.dataList!.length;

    List<FlSpot> list = [];
    if (length == 0 && widget.bottomDateList != null) {
      for (var i = 0; i < widget.bottomDateList!.length; i++) {
        double y = 0;
        double x = i * 1.0;
        FlSpot spot = FlSpot(x, y);
        list.add(spot);
      }
    } else {
      for (int i = 0; i < length; i++) {
        CumulativeProfitRatioChartDataEntity data = widget.dataList![i];
        double y = data.cumulativeRageReturn!;
        double x = i * 1.0;
        FlSpot spot = FlSpot(x, y);
        list.add(spot);
      }
    }

    return list;
  }

  List<FlSpot> spotList2() {
    int length = isEmpty() ? 0 : widget.dataList!.length;

    List<FlSpot> list = [];
    if (length == 0 && widget.bottomDateList != null) {
      for (var i = 0; i < widget.bottomDateList!.length; i++) {
        double y = 0;
        double x = i * 1.0;
        FlSpot spot = FlSpot(x, y);
        list.add(spot);
      }
    } else {
      for (int i = 0; i < length; i++) {
        CumulativeProfitRatioChartDataEntity data = widget.dataList![i];
        double y = data.btcCumulativeRate!;
        double x = i * 1.0;
        FlSpot spot = FlSpot(x, y);
        list.add(spot);
      }
    }

    return list;
  }

  LineChartBarData _lineChartBarData1(BuildContext context) {
    LineChartBarData lineChartBarData = LineChartBarData(
      isCurved: true,
      curveSmoothness: 0,
      color: ExColors.warning_1(context),
      barWidth: 1,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: (widget.dataList != null && widget.dataList!.length > 30)
            ? false
            : true,
        getDotPainter: (p0, p1, p2, p3) {
          return FlDotCirclePainter(
            color: ExColors.fill_2(context),
            strokeColor: ExColors.warning_1(context),
            strokeWidth: 1,
            radius: 2,
          );
        },
      ),
      spots: spotList1(),
    );

    return lineChartBarData;
  }

  LineChartBarData _lineChartBarData2(BuildContext context) {
    LineChartBarData lineChartBarData = LineChartBarData(
        isCurved: true,
        curveSmoothness: 0,
        color: ExColors.main_1(context),
        barWidth: 1,
        isStrokeCapRound: true,
        dotData: FlDotData(
          show: (widget.dataList != null && widget.dataList!.length > 30)
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
        spots: spotList2());

    return lineChartBarData;
  }

  Widget _leftTitleWidgets(double value, TitleMeta meta, BuildContext context) {
    String text;
    switch (value.toInt()) {
      case 0:
        text = '0';
        break;
      case 2:
        text = '2';
        break;
      case 4:
        text = '4';
        break;
      case 6:
        text = '6';
        break;
      case 8:
        text = '8';
        break;
      default:
        text = '';
    }

    return Text(text,
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

    for (var i = 0; i < widget.bottomTagIndexList!.length; i++) {
      if (value == widget.bottomTagIndexList![i]) {
        if (value == widget.bottomTagIndexList!.last) {
          text = widget.chartBottomTitles![i] ?? "";
          text = "$text       ";
        } else if (value == widget.bottomTagIndexList!.first) {
          text = widget.chartBottomTitles![i] ?? "";
          text = "        $text";
        } else {
          text = widget.chartBottomTitles![i] ?? "";
        }
      }
    }
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 8,
      child: Text(text, style: style),
    );
  }
}
