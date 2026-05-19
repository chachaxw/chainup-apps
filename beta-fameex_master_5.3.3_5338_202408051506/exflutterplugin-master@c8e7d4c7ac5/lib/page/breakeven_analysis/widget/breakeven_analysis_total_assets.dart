import 'dart:async';

import 'package:chainup_flutter_ex/page/breakeven_analysis/breakeven_analysis_controller/coin_transaction_breakeven_analysis_controller.dart';
import 'package:chainup_flutter_ex/page/breakeven_analysis/widget/chart_bottom_titles.dart';
import 'package:chainup_flutter_ex/page/breakeven_analysis/widget/gesture_capture.dart';
import 'package:chainup_flutter_ex/utils/decimal_utils.dart';
import 'package:chainup_flutter_ex/widgets/ex_loading_view.dart';
import 'package:decimal/decimal.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../constants/color_constant.dart';
import '../../../models/chart_data_entity.dart';
import '../../../themes/Themes.dart';
import '../../../utils/date_utils.dart';
import '../../../widgets/gaps.dart';
import 'chart_title.dart';

class BreakevenAnalysisTotalAssets extends StatefulWidget {
  final List<TotalAssetsChartDataEntity>? dataList;
  final List<String>? bottomDateList;
  final List<String>? chartBottomTitles;
  final List<int>? bottomTagIndexList;
  final String? totalAssets;
  final ExLoadingStatus? loadStatus;
  final VoidCallback? tryCallback;
  final double? minY;
  final double? maxY;
  final double? minAssetBalance;
  const BreakevenAnalysisTotalAssets({
    this.dataList,
    this.bottomDateList,
    this.chartBottomTitles,
    this.bottomTagIndexList,
    this.totalAssets,
    this.loadStatus,
    this.tryCallback,
    this.minY = 0,
    this.maxY = 10,
    this.minAssetBalance = 0,
    super.key,
  });

  @override
  State<BreakevenAnalysisTotalAssets> createState() =>
      _BreakevenAnalysisTotalAssetsState();
}

class _BreakevenAnalysisTotalAssetsState
    extends State<BreakevenAnalysisTotalAssets> {
  Timer? _timer;

  double minX = 0;
  double maxX = 0;

  var clickedSpotIndex = -1;

  List<int> keepShowTooltipOnSpots = [];
  List<int> showingTooltipOnSpots = [];
  String totalProfit = "0.00";

  String showValue = "0.00";
  String showTime = "";
  double chartLineWidth = 0;

  bool isTouch = false;

  @override
  void initState() {
    super.initState();
    showValue = widget.totalAssets!;
    showTime = EXDateUtils.formateDateTimeToString(EXDateUtils.getUtc8TimeNow(),
        format: "yyyy-MM-dd");
  }

  void _onTimerFinished() {
    setState(() {
      clickedSpotIndex = -1;
      showValue = widget.totalAssets!;
      showTime = EXDateUtils.formateDateTimeToString(
          EXDateUtils.getUtc8TimeNow(),
          format: "yyyy-MM-dd");
    });
  }

  @override
  void didUpdateWidget(covariant BreakevenAnalysisTotalAssets oldWidget) {
    super.didUpdateWidget(oldWidget);
    showValue = widget.totalAssets!;
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

      keepShowTooltipOnSpots = [0, 6];
      showingTooltipOnSpots = [0, 6];
      maxX = double.parse(widget.bottomTagIndexList!.last.toString());
    } else {
      List minIndexList = [];
      List maxIndexList = [];

      for (var i = 0; i < widget.dataList!.length; i++) {
        TotalAssetsChartDataEntity data = widget.dataList![i];
        double totalBalance = data.totalBalance!;
        debugPrint("+++ $totalBalance");
        if (totalBalance == widget.minAssetBalance) {
          minIndexList.add(i);
        }
        if (totalBalance == widget.maxY) {
          maxIndexList.add(i);
        }
      }
      keepShowTooltipOnSpots = [
        minIndexList.isEmpty ? 0 : minIndexList.first,
        maxIndexList.isNotEmpty
            ? maxIndexList.first
            : widget.dataList!.length - 1,
      ];
      showingTooltipOnSpots = keepShowTooltipOnSpots;
      minX = double.parse(widget.bottomTagIndexList!.first.toString());
      maxX = double.parse(widget.bottomTagIndexList!.last.toString());
    }
  }

  bool isEmpty() {
    return widget.dataList == null || widget.dataList!.isEmpty;
  }

  List<FlSpot> spotList() {
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
        TotalAssetsChartDataEntity data = widget.dataList![i];
        double y = data.totalBalance!;
        double x = i * 1.0;
        FlSpot spot = FlSpot(x, y);
        list.add(spot);
      }
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    handleInitData();
    String _value =
        DecimalUtils.formateNum(showValue, digits: 2, isShowThous: true);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Gaps.vGap28,
          ChartTitle(
            title: "breakeven_analysis_text8".tr,
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
                  controller.showAmount.value
                      ? "${controller.mCurrencyCoin.value}$_value"
                      : "******",
                  style: ExThemes.textstyle_hm_color1_14((context)).copyWith(
                    color: (double.tryParse(showValue) ?? 0) == 0
                        ? ExColors.text_2(context)
                        : ExColors.text_1(context),
                  ),
                ),
              );
            },
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
                      onPointerDown: (event) {
                        isTouch = true;
                        setState(() {});
                      },
                      onPointerCancel: (event) {
                        isTouch = false;
                        _onTimerFinished();
                      },
                      onPointerUp: (event) {
                        isTouch = false;
                        _onTimerFinished();
                      },
                      child: Container(
                        height: 197,
                        child: GetBuilder<
                            CoinTransactionBreakevenAnalysisController>(
                          builder: (controller) {
                            return _kline(context, controller);
                          },
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
          Decimal.parse(widget.minY.toString()),
          Decimal.parse(widget.maxY.toString()),
          5);
      for (var i = 0; i < calculateMidpointsList.length; i++) {
        String title = DecimalUtils.formateNum(calculateMidpointsList[i],
            digits: 2, isShowThous: true);
        titles.add(title);
      }
      titles = titles.reversed.toList();
    } else {
      titles = ["0", "2", "4", "6", "8", "10"];
      titles = titles.reversed.toList();
    }
    for (var i = 0; i < titles.length; i++) {
      list.add(
        Container(
          height: 197 / 6,
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

  Widget _kline(BuildContext context,
      CoinTransactionBreakevenAnalysisController controller) {
    final lineBarsData = [_lineChartBarData(context)];
    final tooltipsOnBar = lineBarsData[0];

    return LineChart(
      LineChartData(
        minX: minX,
        maxX: maxX,
        minY: widget.minY,
        maxY: widget.maxY,
        backgroundColor: Colors.transparent, //ExColors.fill_2(context),
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
        gridData: const FlGridData(
          show: false,
          drawVerticalLine: false,
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
        lineBarsData: lineBarsData,
        showingTooltipIndicators:
            widget.dataList == null || tooltipsOnBar.spots.isEmpty
                ? []
                : keepShowTooltipOnSpots.map((index) {
                    return tooltipsOnBar.spots.length <= index
                        ? ShowingTooltipIndicators([])
                        : ShowingTooltipIndicators(
                            [
                              LineBarSpot(
                                tooltipsOnBar,
                                lineBarsData.indexOf(tooltipsOnBar),
                                tooltipsOnBar.spots[index],
                              ),
                            ],
                          );
                  }).toList(),

        lineTouchData: LineTouchData(
          enabled: true,
          handleBuiltInTouches: isTouch,
          touchTooltipData: LineTouchTooltipData(
            fitInsideHorizontally: true,
            fitInsideVertically: true,
            tooltipMargin: 8,
            tooltipBgColor:
                isTouch ? Colors.transparent : ExColors.main_3(context),
            tooltipRoundedRadius: 2,
            tooltipPadding:
                const EdgeInsets.only(left: 4, right: 4, top: 3, bottom: 2),
            getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
              return touchedBarSpots.map((barSpot) {
                String value = DecimalUtils.formateNum(barSpot.y,
                    digits: 2, isShowThous: true);
                if (barSpot.y == widget.minAssetBalance ||
                    barSpot.y == widget.maxY) {
                  return LineTooltipItem(
                    controller.showAmount.value
                        ? '${controller.mCurrencyCoin.value}$value'
                        : "******",
                    ExThemes.textstyle_hr_color2_10(context).copyWith(
                      color: isTouch
                          ? Colors.transparent
                          : ExColors.main_1(context),
                    ),
                  );
                }
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
                if (showingTooltipOnSpots.contains(spotIndex)) {
                  showingTooltipOnSpots.remove(spotIndex);
                }
                if (!showingTooltipOnSpots.contains(spotIndex)) {
                  showingTooltipOnSpots.add(spotIndex);
                } else {
                  showingTooltipOnSpots.clear();
                  showingTooltipOnSpots.addAll(keepShowTooltipOnSpots);
                }

                if (showingTooltipOnSpots.contains(spotIndex)) {
                  showingTooltipOnSpots.remove(spotIndex);
                }
                if (!showingTooltipOnSpots.contains(spotIndex)) {
                  showingTooltipOnSpots.add(spotIndex);
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
          getTouchedSpotIndicator: (barData, spotIndexes) {
            return spotIndexes.map((int index) {
              final flLine = FlLine(
                  color:
                      isTouch ? ExColors.fill_4(context) : Colors.transparent,
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
        showValue = "0.00";
      } else {
        TotalAssetsChartDataEntity data = widget.dataList![spotIndex];
        showValue = data.totalBalanceStr!;
      }
      showTime = widget.bottomDateList![spotIndex];
    });
  }

  LineChartBarData _lineChartBarData(BuildContext context) {
    LineChartBarData lineChartBarData = LineChartBarData(
        showingIndicators: showingTooltipOnSpots,
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
            if (p3 == keepShowTooltipOnSpots.first ||
                p3 == keepShowTooltipOnSpots.last) {
              return FlDotCirclePainter(
                color: isTouch
                    ? ExColors.fill_2(context)
                    : ExColors.main_1(context),
                strokeColor: ExColors.main_1(context),
                strokeWidth: 1,
                radius: 2,
              );
            }

            return FlDotCirclePainter(
              color: ExColors.fill_2(context),
              strokeColor: ExColors.main_1(context),
              strokeWidth: 1,
              radius: 2,
            );
          },
        ),
        belowBarData: BarAreaData(
          show: true,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              ExColors.main_1(context).withOpacity(0.2),
              ExColors.main_1(context).withOpacity(0.0),
            ],
          ),
        ),
        spots: spotList());

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
      case 10:
        text = '10';
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
          text = "$text          ";
        } else if (value == widget.bottomTagIndexList!.first) {
          text = widget.chartBottomTitles![i] ?? "";
          text = "         $text";
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
