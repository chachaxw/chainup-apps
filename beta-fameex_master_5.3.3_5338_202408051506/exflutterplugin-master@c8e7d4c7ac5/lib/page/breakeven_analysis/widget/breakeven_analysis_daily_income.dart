import 'dart:async';

import 'package:chainup_flutter_ex/page/breakeven_analysis/breakeven_analysis_controller/coin_transaction_breakeven_analysis_controller.dart';
import 'package:chainup_flutter_ex/page/breakeven_analysis/widget/chart_bottom_titles.dart';
import 'package:chainup_flutter_ex/page/breakeven_analysis/widget/chart_title.dart';
import 'package:chainup_flutter_ex/page/breakeven_analysis/widget/gesture_capture.dart';
import 'package:chainup_flutter_ex/utils/decimal_utils.dart';
import 'package:chainup_flutter_ex/widgets/ex_loading_view.dart';
import 'package:decimal/decimal.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:library_kline/renderer/base_chart_renderer.dart';

import '../../../constants/color_constant.dart';
import '../../../models/daily_income_chart_data_entity.dart';
import '../../../themes/Themes.dart';
import '../../../utils/date_utils.dart';
import '../../../widgets/gaps.dart';
import 'dart:math' as math;

class BreakevenAnalysisDailyIncome extends StatefulWidget {
  final List<DailyIncomeChartDataEntity>? dataList;
  final List<String>? bottomDateList;
  final List<String>? chartBottomTitles;
  final List<int>? bottomTagIndexList;
  final String? dailyIncome;
  final ExLoadingStatus? loadStatus;
  final VoidCallback? tryCallback;

  const BreakevenAnalysisDailyIncome({
    this.dataList,
    this.bottomDateList,
    this.bottomTagIndexList,
    this.chartBottomTitles,
    this.dailyIncome,
    this.loadStatus,
    this.tryCallback,
    super.key,
  });

  @override
  State<BreakevenAnalysisDailyIncome> createState() =>
      _BreakevenAnalysisDailyIncomeState();
}

class _BreakevenAnalysisDailyIncomeState
    extends State<BreakevenAnalysisDailyIncome> {
  Timer? _timer;

  double minX = 0;
  double maxX = 0;
  double minY = 0;
  double maxY = 0;
  int touchedIndex = -1;

  String totalProfit = "0.00";

  String showValue = "0.00";
  String showTime = "";

  // static const maxY = 10.0;
  // static const minY = -10.0;
  double chartLineWidth = 0.0;

  @override
  void initState() {
    super.initState();
    showValue = widget.dailyIncome!;
    showTime = EXDateUtils.formateDateTimeToString(EXDateUtils.getUtc8TimeNow(),
        format: "yyyy-MM-dd");
  }

  @override
  void didUpdateWidget(covariant BreakevenAnalysisDailyIncome oldWidget) {
    super.didUpdateWidget(oldWidget);
    showValue = widget.dailyIncome!;
  }

  void _onTimerFinished() {
    setState(() {
      touchedIndex = -1;
      showValue = widget.dailyIncome!;
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
      touchedIndex = -1;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void handleInitData() {
    if (isEmpty()) {
      minX = 0;
      maxX = 6;
      minY = 0;
      maxY = 10;
    } else {
      maxY = widget.dataList!.first.profit ?? 0;
      minY = widget.dataList!.first.profit ?? 0;
      for (var i = 0; i < widget.dataList!.length; i++) {
        DailyIncomeChartDataEntity data = widget.dataList![i];
        double profit = data.profit ?? 0;
        if (profit >= maxY) {
          maxY = profit;
        }
        if (profit <= minY) {
          minY = profit;
        }
      }
      if (minY < 0) {
        var _minYabs = minY.abs();
        var _maxYabs = maxY.abs();

        if (minY < 0 && maxY > 0) {
          if (_minYabs > _maxYabs) {
            maxY = _minYabs;
          } else {
            minY = -_maxYabs;
          }
        }
      }

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

  bool isShadowBar(int rodIndex) => rodIndex == 1;

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
            title: "breakeven_analysis_text19".tr,
          ),
          Gaps.vGap4,
          Text(
            showTime,
            style: ExThemes.textstyle_hr_color2_12((context)),
          ),
          Gaps.vGap20,
          GetBuilder<CoinTransactionBreakevenAnalysisController>(
            builder: (controller) {
              return Obx(
                () => Text(
                  controller.showAmount.value ? getValue(controller) : "******",
                  style: ExThemes.textstyle_hm_color1_14((context)).copyWith(
                      color: controller.showAmount.value
                          ? getValueColor()
                          : ExColors.text_2(context)),
                ),
              );
            },
          ),
          Gaps.vGap15,
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
          // Gaps.vGa
        ],
      ),
    );
  }

  Widget _chartView() {
    return Stack(
      children: [
        Positioned(
          top: 2.5,
          left: 0,
          height: 191,
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
                    // _gapLine(),
                    // _gapLine(),
                  ],
                ),
              );
            },
          ),
        ),
        SizedBox(
          height: 191,
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
                    double barsSpace = 4.0;
                    double barsWidth = 8.0;
                    if (widget.dataList == null ||
                        (widget.dataList != null &&
                            widget.dataList!.length == 7)) {
                      barsWidth = 10.0 * constraints.maxWidth / 150;
                      barsSpace = (constraints.maxWidth - barsWidth * 7) / 6;
                    } else {
                      barsWidth = 8.0 * constraints.maxWidth / 400;

                      barsSpace = (constraints.maxWidth -
                              barsWidth * widget.dataList!.length) /
                          (widget.dataList!.length - 1);
                    }
                    return BaseGestureCapture(
                        onPointerCancel: (event) {
                          _onTimerFinished();
                        },
                        onPointerUp: (event) {
                          _onTimerFinished();
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: _kline(context, barsWidth, barsSpace),
                        ));
                  },
                ),
              )
            ],
          ),
        ),
        _chartBottomTitles(),
      ],
    );
  }

  Widget _chartBottomTitles() {
    return Positioned(
      right: 0,
      bottom: 10,
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
          height: 191 / 5,
        ),
      ],
    );
  }

  List<Widget> _leftTitles() {
    List<Widget> list = [];
    List titles = [];
    if (!isEmpty()) {
      List<Decimal> calculateMidpointsList = DecimalUtils.calculateMidpoints(
          Decimal.parse(minY.toString()), Decimal.parse(maxY.toString()), 4);

      for (var i = 0; i < calculateMidpointsList.length; i++) {
        String title = DecimalUtils.formateNum(calculateMidpointsList[i],
            digits: 2, isShowThous: true);
        titles.add(title);
      }
      titles = titles.reversed.toList();
    } else {
      titles = ["0", "2", "4", "6", "8"];
      titles = titles.reversed.toList();
    }
    for (var i = 0; i < titles.length; i++) {
      list.add(
        Container(
          height: 191 / 5 - 1.4,
          alignment: Alignment.topCenter,
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

  String getValue(CoinTransactionBreakevenAnalysisController controller) {
    String value = double.parse(showValue) == 0
        ? "0.00"
        : DecimalUtils.formateNum(showValue, digits: 2, isShowThous: true);
    String result = double.parse(showValue) == 0
        ? "${controller.mCurrencyCoin.value}0.00"
        : double.parse(showValue) > 0
            ? "+${controller.mCurrencyCoin.value}$value"
            : "${controller.mCurrencyCoin.value}$value";
    if (double.parse(showValue) == 0) {
      result = "${controller.mCurrencyCoin.value}0.00";
    } else if (double.parse(showValue) > 0) {
      result = "+${controller.mCurrencyCoin.value}$value";
    } else {
      value = value.replaceFirst(RegExp(r'-'), '');
      result = "-${controller.mCurrencyCoin.value}$value";
    }

    return result;
  }

  Color getValueColor() {
    Color color1 = ExColors.setRiseFallTextColor(
        showValue, ExColors.text_2(context), context);
    return color1;
  }

  Widget _kline(BuildContext context, double barsWidth, double barsSpace) {
    return BarChart(
      swapAnimationDuration: const Duration(milliseconds: 50),
      BarChartData(
        alignment: BarChartAlignment.start,
        maxY: maxY,
        minY: minY,
        groupsSpace: barsSpace,
        backgroundColor: Colors.transparent,
        barTouchData: BarTouchData(
          handleBuiltInTouches: false, //点击是否展示指示文字
          allowTouchBarBackDraw: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: ExColors.main_3(context),
            tooltipPadding: const EdgeInsets.only(left: 8, right: 8, top: 4),
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              //指示框文字设置
              return BarTooltipItem(
                rod.toY.toString(),
                ExThemes.textstyle_hr_color1_10(context).copyWith(
                  color: ExColors.main_1(context),
                ),
              );
            },
          ),
          touchCallback: (FlTouchEvent touchEvent, barTouchResponse) {
            if (barTouchResponse == null || barTouchResponse.spot == null) {
              setState(() {
                touchedIndex = -1;
                // showValue = widget.dailyIncome!;
                // showTime = EXDateUtils.formateDateTimeToString(
                //     EXDateUtils.getUtc8TimeNow(),
                //     format: "yyyy-MM-dd");
              });
              _startTimer();
              debugPrint("touchedIndex: $touchedIndex");

              return;
            }

            int rodIndex = barTouchResponse.spot!.touchedRodDataIndex;
            if (isShadowBar(rodIndex)) {
              debugPrint("==+++++ ");
              setState(() {
                touchedIndex = -1;
              });
              return;
            }
            // debugPrint(
            //     "|||  === ++++ isShadowBar(rodIndex):${isShadowBar(rodIndex)} -- touchedStackItemIndex:$rodIndex");
            touchedIndex = barTouchResponse.spot!.touchedBarGroupIndex;
            DailyIncomeChartDataEntity data = widget.dataList![touchedIndex];
            debugPrint(
                "touchEvent : ${touchEvent.runtimeType}-- touchedIndex:$touchedIndex --- rodIndex: $rodIndex  -- data.profitStr!:${data.profitStr!} isShadowBar(rodIndex):${isShadowBar(rodIndex)}");

            // if (isShadowBar(rodIndex)) {
            //   touchedIndex = -1;
            // }

            setState(() {
              updateShowData(touchedIndex);
            });

            if (touchEvent is FlLongPressMoveUpdate) {
              setState(() {
                updateShowData(touchedIndex);
              });
              return;
            }
            if (touchEvent is FlLongPressEnd) {
              _startTimer();
            }
            if (touchEvent is FlTapDownEvent) {
              if (touchedIndex != rodIndex) {
                _startTimer();
                setState(() {
                  updateShowData(touchedIndex);
                });
              } else {
                _stopTimer();
              }
              return;
            }
            if (touchEvent is FlPanUpdateEvent) {
              _stopTimer();
              setState(() {
                updateShowData(touchedIndex);
              });
              _startTimer();
              return;
            }
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          topTitles: const AxisTitles(
            sideTitles: SideTitles(
              showTitles: false,
              reservedSize: 32,
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              getTitlesWidget: bottomTitles,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: false,
              getTitlesWidget: leftTitles,
              interval: 5,
              reservedSize: 32,
            ),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: false,
              getTitlesWidget: rightTitles,
              interval: 5,
              reservedSize: 42,
            ),
          ),
        ),
        gridData: FlGridData(
          //边框线
          show: false,
          drawHorizontalLine: true,
          drawVerticalLine: false,
          horizontalInterval: 10, //(maxY - minY) / 5,
          checkToShowHorizontalLine: (value) {
            return true;
          },
          getDrawingHorizontalLine: (value) {
            //间隔线设置
            return FlLine(
              color: ExColors.fill_4(context),
              strokeWidth: 1,
            );
          },
        ),
        borderData: FlBorderData(
          show: true,
          border: Border(
            top: const BorderSide(
              color: Colors.transparent, //ExColors.fill_4(context),
            ),
            bottom: BorderSide(
              color: ExColors.fill_4(context),
              width: 0.5,
            ),
          ),
        ),
        barGroups: getMainItems(barsWidth, barsSpace),
        // barGroups: mainItems.entries.map(
        //   (e) {
        //     return generateGroup(
        //       e.key,
        //       e.value[0],
        //       // e.value[1],
        //       // e.value[2],
        //       // e.value[3],
        //     );
        //   },
        // ).toList(),
      ),
    );
  }

  void updateShowData(int spotIndex) {
    if (isEmpty()) {
      showValue = "0.00";
    } else {
      if (spotIndex < 0 || spotIndex >= widget.dataList!.length) {
        return;
      }
      DailyIncomeChartDataEntity data = widget.dataList![spotIndex];
      showValue = data.profitStr!;
    }
    showTime = widget.bottomDateList![spotIndex];
  }

  List<BarChartGroupData>? getMainItems(double barsWidth, double barsSpace) {
    if (isEmpty()) {
      return [];
    } else {
      List<BarChartGroupData> list = [];
      for (var i = 0; i < widget.dataList!.length; i++) {
        DailyIncomeChartDataEntity entity = widget.dataList![i];
        double value1 = entity.profit ?? 0;

        final isTop = value1 > 0;
        final sum = value1;
        final isTouched = touchedIndex == i && touchedIndex != -1;
        BarChartGroupData barChartGroupData = BarChartGroupData(
          x: i,
          barsSpace: barsSpace,
          groupVertically: true,
          showingTooltipIndicators: [], //isTouched ? [0] : [],
          barRods: [
            BarChartRodData(
              toY: sum,
              // width: isTouched ? barsWidth + 10 : barsWidth,
              width: barsWidth,
              borderSide: BorderSide(
                color: isTouched
                    ? ExColors.fill_4(context)
                    : ExColors.fill_2(context),
                width: 0.5,
              ),
              borderRadius: isTop
                  ? const BorderRadius.only(
                      topLeft: Radius.circular(0),
                      topRight: Radius.circular(0),
                    )
                  : const BorderRadius.only(
                      bottomLeft: Radius.circular(0),
                      bottomRight: Radius.circular(0),
                    ),
              color:
                  // isTop ?  ExColors.rise_1(context) : ExColors.fall_1(context),
                  isTop ? ChartColors.upColor : ChartColors.dnColor,
              rodStackItems: [
                BarChartRodStackItem(
                  minY,
                  maxY, //value1,
                  Colors.transparent,
                  BorderSide(
                    color: ExColors.fill_4(context),
                    // width: isTouched ? 8 : 0,
                    width: isTouched ? 1 : 0,
                  ),
                ),
              ],
              backDrawRodData: BackgroundBarChartRodData(
                fromY: value1 > 0 ? minY : maxY,
                toY: value1 > 0 ? maxY : minY,
                show: true,
                color:
                    isTouched ? ExColors.fill_4(context) : Colors.transparent,
                // gradient: isTouched
                //     ? LinearGradient(
                //         colors: [
                //           ExColors.fill_4(context),
                //           ExColors.fill_4(context),
                //         ],
                //       )
                //     : null,
              ),
            ),
          ],
        );
        list.add(barChartGroupData);
      }
      return list;
    }
  }

  /*
static const mainItems = <int, List<double>>{
    0: [20000],
    1: [8],
    2: [643523232, 2, 3.5, 6],
    3: [123, 1.5, 4, 6.5],
    4: [2221241, -2, -5, -9],
    5: [42, -1.5, -4.3, -10],
    6: [323232, 4.8, 5, 5],
  };
  BarChartGroupData generateGroup(
    int x,
    double value1,
  ) {
    final isTop = value1 > 0;
    final sum = value1;
    final isTouched = clickedSpotIndex == x;
    return BarChartGroupData(
      x: x,
      groupVertically: false,
      showingTooltipIndicators: [], //isTouched ? [0] : [],
      barRods: [
        BarChartRodData(
          toY: sum,
          width: barWidth,
          borderSide: BorderSide(
            color:
                isTouched ? ExColors.fill_4(context) : ExColors.fill_2(context),
            width: 0,
          ),
          borderRadius: isTop
              ? const BorderRadius.only(
                  topLeft: Radius.circular(0),
                  topRight: Radius.circular(0),
                )
              : const BorderRadius.only(
                  bottomLeft: Radius.circular(0),
                  bottomRight: Radius.circular(0),
                ),
          color: isTop ? ExColors.rise_1(context) : ExColors.fall_1(context),
          rodStackItems: [
            BarChartRodStackItem(
              minY,
              maxY, //value1,
              Colors.transparent,
              BorderSide(
                color: ExColors.fill_4(context),
                width: isTouched ? 2 : 0,
              ),
            ),
          ],
          // backDrawRodData: BackgroundBarChartRodData(
          //   fromY: minY,
          //   toY: maxY, //value1,
          //   show: true,
          //   color: isTouched ? ExColors.fill_4(context) : Colors.transparent,
          //   gradient: isTouched
          //       ? LinearGradient(
          //           colors: [
          //             ExColors.fill_4(context),
          //             ExColors.fill_4(context)
          //           ],
          //         )
          //       : const LinearGradient(
          //           colors: [
          //             Colors.transparent,
          //             Colors.transparent,
          //           ],
          //         ),
          // ),
        ),
      ],
    );
  }
*/
  Widget bottomTitles(double value, TitleMeta meta) {
    TextStyle style = ExThemes.textstyle_hr_color2_12(context)
        .copyWith(color: Colors.transparent);
    String text = "";

    for (var i = 0; i < widget.bottomTagIndexList!.length; i++) {
      if (value == widget.bottomTagIndexList![i]) {
        if (value == widget.bottomTagIndexList!.last) {
          text = widget.chartBottomTitles![i] ?? "";
          text = "$text      ";
        } else if (value == widget.bottomTagIndexList!.first) {
          text = widget.chartBottomTitles![i] ?? "";
          text = "    $text";
        } else {
          text = widget.chartBottomTitles![i] ?? "";
        }
      }
    }
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 9,
      child: Text(text, style: style),
    );
  }

  Widget leftTitles(double value, TitleMeta meta) {
    TextStyle style = ExThemes.textstyle_hr_color2_12(context);
    String text;
    if (value == 0) {
      text = '0';
    } else {
      text = '${value.toInt()}0k';
    }
    return SideTitleWidget(
      // angle: degreeToRadian(value < 0 ? -45 : 45),
      axisSide: meta.axisSide,
      space: 4,
      child: Text(
        text,
        style: style,
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget rightTitles(double value, TitleMeta meta) {
    const style = TextStyle(color: Colors.red, fontSize: 10);
    String text;
    if (value == 0) {
      text = '0';
    } else {
      text = '${value.toInt()}0k';
    }
    return SideTitleWidget(
      angle: degreeToRadian(90),
      axisSide: meta.axisSide,
      space: 0,
      child: Text(
        text,
        style: style,
        textAlign: TextAlign.center,
      ),
    );
  }

  double degreeToRadian(double degree) {
    return degree * math.pi / 180;
  }

  double radianToDegree(double radian) {
    return radian * 180 / math.pi;
  }
}
