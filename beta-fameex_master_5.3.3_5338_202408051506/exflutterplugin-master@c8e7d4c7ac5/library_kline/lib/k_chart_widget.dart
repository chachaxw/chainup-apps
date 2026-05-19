import 'dart:async';

import 'package:chainup_flutter_ex/constants/color_constant.dart';
import 'package:chainup_flutter_ex/event/event.dart';
import 'package:chainup_flutter_ex/page/kline/main_state.dart';
import 'package:chainup_flutter_ex/routes/routes.dart';
import 'package:chainup_flutter_ex/themes/Themes.dart';
import 'package:chainup_flutter_ex/widgets/gaps.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:library_kline/utils/storage_utils.dart';

import 'chart_style.dart';
import 'entity/info_window_entity.dart';
import 'entity/k_line_entity.dart';
import 'models/entrust_order_entity.dart';
import 'models/position_entity.dart';
import 'my_custom_horizontal_recognizer.dart';
import 'my_custom_scale_recognizer.dart';
import 'renderer/chart_painter.dart';
import 'utils/date_format_util.dart' hide S;
import 'utils/number_util.dart';

enum VolState { VOL, NONE }

enum SecondaryState { MACD, KDJ, RSI, WR, NONE }

enum KlineState {
  LOADING("0"),
  CONTENT("1"),
  RELOAD("2"),
  NONE("3"),
  unknow("");
  const KlineState(this.type);
  final String type;
  static KlineState getStateByType(String type) =>
      KlineState.values.firstWhere((it) => it.type == type,
          orElse: () => KlineState.unknow);
}

class KChartWidget extends StatefulWidget {
  final List<KLineEntity> datas;
  final MainState mainState;
  final SecondaryState secondaryState;
  final bool isLine;
  final bool isDay;
  bool isShowOrder;
  bool isSmallKline;
  String? waterLogoPath;
  final VoidCallback? onMore;
  final ValueChanged<bool>? onScroll;
  final bool isShowBottomIndex;
  final List<String> infoNames;
  final Orientation orientation;
  final bool isOnlyMainChart;
  final List<PositionOrder> positionList;
  final List<EntrustOrder> entrustList;
  // final List<String> infoNames = [
  //   "Date",
  //   "Open",
  //   "High",
  //   "Low",
  //   "Close",
  //   "Change",
  //   "Change%",
  //   "Executed",
  // ];
  //
  KChartWidget(this.datas, this.infoNames,
      {
        Key? key,
        this.mainState = MainState.MA,
        this.secondaryState = SecondaryState.MACD,
        this.isLine = false,
        this.isDay = false,
        this.isShowOrder = false,
        this.isSmallKline = false,
        this.onMore,
        this.onScroll,
        this.isShowBottomIndex = true,
        int fractionDigits = 2,
        this.waterLogoPath,
        this.orientation = Orientation.portrait,
        this.isOnlyMainChart = false,
        required this.entrustList,
        required this.positionList
      })
      : super(key: key) {
    NumberUtil.fractionDigits = fractionDigits;
  }

  @override
  KChartWidgetState createState() => KChartWidgetState();
}

class KChartWidgetState extends State<KChartWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  List<String> secondaryUIList = [];
  List<String> mainUIList = [];
  VolState volState = VolState.VOL;
  double mScaleX = 1.0, mScrollX = 0.0, mSelectX = 0.0, mSelectY = 0.0;
  late StreamController<InfoWindowEntity?> mInfoWindowStream;
  double mWidth = 0;
  late AnimationController _scrollXController;
  List<String> mFormats = [yyyy, '-', mm, '-', dd, ' ', HH, ':', nn]; //格式化时间
  int numberOfFingers = 0;
  int repaintNum = 0;
  double getMinScrollX() {
    return mScaleX;
  }

  double _lastScale = 1.0;
  bool isScale = false, isDrag = false, isLongPress = false;

  final subplotIndexs = <String>["VOL", "MACD", "RSI", "KDJ", "WR"];
  final mainImgIndexs = <String>["MA", "EMA", "BOLL"];
  MyCustomScaleRecognizer recofnizer = MyCustomScaleRecognizer();
  @override
  void initState() {
    super.initState();
    initKlineConf();
    mInfoWindowStream = StreamController();
    _controller = AnimationController(
        duration: const Duration(milliseconds: 850), vsync: this);
    _animation = Tween(begin: 0.9, end: 0.1).animate(_controller)
      ..addListener(() => setState(() {}));
    _scrollXController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 500),
        lowerBound: double.negativeInfinity,
        upperBound: double.infinity);
    _scrollListener();
  }

  void initKlineConf({bool isFirstGuide = true}) {
    var mainUIStr = ExStorageUtils.getString(
        ExStorageUtils.KLINE_MAIN_INDICATOS_SELECT_LIST);
    // Routes.pushNvEvent(ev: NvEvent.kline_detail_clickMainIndex,param: {ExStorageUtils.KLINE_MAIN_INDICATOS_SELECT_LIST:mainUIStr});
    var secUIStr = ExStorageUtils.getString(
        ExStorageUtils.KLINE_SEC_INDICATOS_SELECT_LIST);
    bool volStatus = ExStorageUtils.getBoolean(
        key: ExStorageUtils.KLINE_VOL_INDICATOS_SELECT_STATUS);
    List<String> mainUIList = mainUIStr.split(",");
    mainUIList = mainUIList.where((element) => element != "").toList();
    List<String> secUIList = secUIStr.split(",");
    secUIList = secUIList.where((element) => element != "").toList();

    var isFirstOrHasGuide = ExStorageUtils.getObject(ExStorageUtils.KLINE_V_GUIDE1_STATUS,def: "0") == "0";
    if(isFirstOrHasGuide && isFirstGuide){
      mainUIList.clear();
      mainUIList.add("MA");
      secUIList.clear();
      secUIList.add("VOL");
      volStatus = true;
      ExStorageUtils.putObject(ExStorageUtils.KLINE_MAIN_INDICATOS_SELECT_LIST,"MA");
      ExStorageUtils.putObject(ExStorageUtils.KLINE_VOL_INDICATOS_SELECT_STATUS,true);
      ExStorageUtils.putObject(ExStorageUtils.KLINE_SEC_INDICATOS_SELECT_LIST,"VOL");
    }

    this.mainUIList.clear();
    this.secondaryUIList.clear();
    this.setState(() {
      this.mainUIList.addAll(mainUIList);
      print("initKlineConf>>>${mainUIStr}");
      if(!widget.isOnlyMainChart){
        this.secondaryUIList.addAll(secUIList);
        this.volState = volStatus ? VolState.VOL : VolState.NONE;
        Event.eventBus.fire(MessageEvent(MessageEvent.klineIndexChange,
            msg_content: {
              "volState": volState,
              "secondaryUIListCount": secondaryUIList.length
            }));
      }else{
        this.volState = VolState.NONE;
        this.secondaryUIList.clear();
      }
    });
  }

  void _scrollListener() {
    _scrollXController.addListener(() {
      mScrollX = _scrollXController.value;
      if (mScrollX <= 0) {
        mScrollX = 0;
        _stopAnimation();
      } else if (mScrollX >= ChartPainter.maxScrollX) {
        mScrollX = ChartPainter.maxScrollX;
        _stopAnimation();
        widget.onMore!();
      } else {
        notifyChanged();
      }
    });
    _scrollXController.addStatusListener((status) {
      if (status == AnimationStatus.completed ||
          status == AnimationStatus.dismissed) {
        isDrag = false;
        notifyChanged();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    mWidth = MediaQuery.of(context).size.width;
  }

  @override
  void didUpdateWidget(KChartWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.datas != widget.datas) mScrollX = mSelectX = 0.0;
  }

  @override
  void dispose() {
    mInfoWindowStream.close();
    _controller.dispose();
    _scrollXController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    initFormats();
    if (widget.datas.isEmpty) {
      mScrollX = mSelectX = 0.0;
      mScaleX = 1.0;
    }
    return Container(
      child: Column(
        children: [
          Expanded(
              flex: 1,
              child: RawGestureDetector(
                behavior: HitTestBehavior.opaque,
                gestures: <Type, GestureRecognizerFactory>{
                  MyCustomScaleRecognizer: GestureRecognizerFactoryWithHandlers<MyCustomScaleRecognizer>(() => recofnizer,
                    (MyCustomScaleRecognizer instance) {
                        instance
                          ..onStart = (ScaleStartDetails details){
                            print("MyCustomScaleRecognizer>>>onStart");
                            isScale = true;
                            isDrag = false;
                          }
                          ..onUpdate = (ScaleUpdateDetails details){
                            print("MyCustomScaleRecognizer>>>onUpdate :isDrag=$isDrag,isLongPress=$isLongPress");
                            if (isDrag || isLongPress) return;
                            mScaleX = (_lastScale * details.scale).clamp(0.15, 3.5);
                            notifyChanged();
                          }
                          ..onEnd = (ScaleEndDetails details){
                            print("MyCustomScaleRecognizer>>>onEnd");
                            recofnizer.clearPointers();
                            isScale = false;
                            _lastScale = mScaleX;
                          };
                      },
                    ),
                  MyCustomHorizontalRecognizer:GestureRecognizerFactoryWithHandlers<MyCustomHorizontalRecognizer>(() => MyCustomHorizontalRecognizer(),
                        (MyCustomHorizontalRecognizer instance) {
                      instance
                        ..onStart = (DragStartDetails details){
                          isLongPress = false;
                          print("HorizontalDragGestureRecognizer>>>onStart");
                          widget.onScroll!(true);
                        }
                        ..onDown = (DragDownDetails details){
                          print("HorizontalDragGestureRecognizer>>>onDown");
                          recofnizer.clearPointers();
                          _stopAnimation();
                          isDrag = true;
                          // widget.onScroll!(true);
                        }
                        ..onUpdate = (DragUpdateDetails details){
                          print("HorizontalDragGestureRecognizer>>>onUpdate");
                          recofnizer.clearPointers();
                          if (isScale || isLongPress || details.primaryDelta == null) return;
                          mScrollX = (details.primaryDelta! / mScaleX + mScrollX)
                              .clamp(0.0, ChartPainter.maxScrollX)
                              .toDouble();
                          notifyChanged();
                        }
                        ..onEnd = (DragEndDetails details){
                          print("HorizontalDragGestureRecognizer>>>onEnd");
                          recofnizer.clearPointers();

                          widget.onScroll!(false);
                          // isDrag = false;
                          final Tolerance tolerance = Tolerance(
                            velocity: 1.0 /
                                (0.050 *
                                    WidgetsBinding.instance!.window.devicePixelRatio),
                            // logical pixels per second
                            distance: 1.0 /
                                WidgetsBinding.instance!.window
                                    .devicePixelRatio, // logical pixels
                          );
                          if (details.primaryVelocity == null) return;
                          ClampingScrollSimulation simulation =
                          ClampingScrollSimulation(
                            position: mScrollX,
                            velocity: details.primaryVelocity!,
                            tolerance: tolerance,
                          );
                          _scrollXController.animateWith(simulation);
                        }
                        ..onCancel = (){
                          print("HorizontalDragGestureRecognizer>>>onCancel");
                          isDrag = false;
                        };
                    },
                  ),
                  LongPressGestureRecognizer:GestureRecognizerFactoryWithHandlers<LongPressGestureRecognizer>(
                        () => LongPressGestureRecognizer(),
                        (LongPressGestureRecognizer instance) {
                      instance
                        ..onLongPressStart=(LongPressStartDetails details){
                          isLongPress = true;
                          if (mSelectX != details.localPosition.dx) {
                            mSelectX = details.localPosition.dx;
                            notifyChanged();
                          }
                          if (mSelectY != details.localPosition.dy) {
                            mSelectY = details.localPosition.dy;
                            notifyChanged();
                          }
                          widget.onScroll!(true);
                        }
                        ..onLongPress = (){

                        }
                        ..onLongPressEnd=(LongPressEndDetails details){
                          // isLongPress = false;
                          // mInfoWindowStream.add(null);
                          notifyChanged();
                          widget.onScroll!(false);
                        }
                        ..onLongPressDown = (LongPressDownDetails details){

                        }
                        ..onLongPressCancel = (){

                        }
                        ..onLongPressMoveUpdate=(LongPressMoveUpdateDetails details){
                          if (mSelectX != details.localPosition.dx) {
                            mSelectX = details.localPosition.dx;
                            notifyChanged();
                          }
                          if (mSelectY != details.localPosition.dy) {
                            mSelectY = details.localPosition.dy;
                            notifyChanged();
                          }
                        };
                    },
                  ),
                  TapGestureRecognizer: GestureRecognizerFactoryWithHandlers<TapGestureRecognizer>(() => TapGestureRecognizer(),
                      (TapGestureRecognizer instance){
                        instance
                        ..onTapDown = (TapDownDetails details) {
                          print("3333333" + "onTapDown");
                          isLongPress = false;
                          final tapPosition = details.localPosition;
                          if (ChartPainter.rectRealTimePrice.contains(tapPosition)) {
                            scrollRight();
                          }
                          notifyChanged();
                        }
                        ..onTapUp = (TapUpDetails details) {
                          recofnizer.clearPointers();
                          print("3333333" + "onTapUp");
                        };
                      }
                  )
                },
                child: Stack(
                  children: <Widget>[
                    CustomPaint(
                      size: const Size(double.infinity, double.infinity),
                      painter: ChartPainter(
                          datas: widget.datas,
                          scaleX: mScaleX,
                          scrollX: mScrollX,
                          selectX: mSelectX,
                          selectY: mSelectY,
                          isLongPass: isLongPress,
                          mainState: widget.mainState,
                          volState: volState,
                          secondaryState: widget.secondaryState,
                          isLine: widget.isLine,
                          isShowOrder: widget.isShowOrder,
                          sink: mInfoWindowStream.sink,
                          opacity: _animation.value,
                          controller: _controller,
                          mBuildContext: context,
                          secondaryUIList: secondaryUIList,
                          mainUIList: mainUIList,
                          orientation: widget.orientation,
                          waterLogoPath: widget.waterLogoPath,
                          isSmallKline: widget.isSmallKline,
                          repaintNum: repaintNum,
                          positionList: widget.positionList,
                          entrustList: widget.entrustList
                      ),
                    ),
                    _buildInfoDialog()
                  ],
              ),
          )),
          Visibility(
              visible: widget.isShowBottomIndex,
              child: Container(
                width: double.infinity,
                height: 22.0.w,
                child: ListView(
                  scrollDirection:Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: getMainBottomIndex(),
                      ),
                      const Padding(padding: EdgeInsets.symmetric(vertical: 3.0),child: Gaps.vLine12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: getSubBottomIndex(),
                      )
                  ]
                ),
              )
          )
        ],
      ),
    );
  }

  void initFormats() {
    final datas = widget.datas;
    if (datas.length <= 1) return;
    int firstTime = datas.first.id ?? 0;
    int secondTime = datas[1].id ?? 0;
    int time = secondTime - firstTime;
    //月线
    if (time >= 24 * 60 * 60 * 28)
      mFormats = [yyyy, '-', mm, '-', dd];
    //日线等
    else if (time >= 24 * 60 * 60)
      mFormats = [yyyy, '-', mm, '-', dd];
    //小时线等
    else
      mFormats = [mm, '-', dd, ' ', HH, ':', nn];
  }

  List<Widget> getMainBottomIndex() {
    var list = <Widget>[];
    for (var i = 0; i < mainImgIndexs.length; i++) {
      var current = mainImgIndexs[i];
      list.add(GestureDetector(
          onTap: () => clickMainIndex(current),
          child: Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: Text(current,
                style: mainUIList.contains(current)
                    ? ExThemes.textstyle_hm_color1_12(context)
                    : ExThemes.textstyle_hm_color3_12(context)),
          )));
    }

    return list;
  }

  List<Widget> getSubBottomIndex() {
    var list = <Widget>[];
    for (var i = 0; i < subplotIndexs.length; i++) {
      var current = subplotIndexs[i];
      list.add(GestureDetector(
          onTap: () => clickSecondaryIndex(current),
          child: Padding(
            padding: const EdgeInsets.only(left: 18.0),
            child: Text(current,
                style: ExThemes.textstyle_hm_color2_12(context).copyWith(
                    color: ("VOL" == current)
                        ? (volState == VolState.VOL
                            ? ExColors.text_1(context)
                            : ExColors.text_3(context))
                        : (secondaryUIList.contains(current)
                            ? ExColors.text_1(context)
                            : ExColors.text_3(context)))),
          )));
    }

    return list;
  }

  void clickSecondaryIndex(String index) {
    if(widget.isOnlyMainChart) return;
    if ("VOL" == index) {
      setState(() {
        // if(volState == VolState.NONE && secondaryUIList.length>3){
        //   secondaryUIList.removeAt(0);
        // }
        if(volState == VolState.NONE){
          //show
          if(secondaryUIList.length>=4){
            if(secondaryUIList[0]=="VOL"){
              volState = VolState.NONE;
            }
            secondaryUIList.removeAt(0);
          }
          secondaryUIList.add("VOL");

        }else{
          //hide
          secondaryUIList.remove("VOL");
        }
        volState = volState == VolState.NONE ? VolState.VOL : VolState.NONE;
        asyncToStorage();
        Event.eventBus.fire(MessageEvent(MessageEvent.klineIndexChange,
            msg_content: {
              "volState": volState,
              "secondaryUIListCount": secondaryUIList.length
            }));
      });
      return;
    }
    if (secondaryUIList.contains(index)) {
      secondaryUIList.remove(index);
    } else {
      if(secondaryUIList.length>=4){
        if(secondaryUIList[0]=="VOL"){
          volState = VolState.NONE;
        }
        secondaryUIList.removeAt(0);
      }
      secondaryUIList.add(index);
    }
    Event.eventBus.fire(MessageEvent(MessageEvent.klineIndexChange,
        msg_content: {
          "volState": volState,
          "secondaryUIListCount": secondaryUIList.length
        }));
    asyncToStorage();
    notifyChanged();
  }

  void clickMainIndex(String index) {
    if (mainUIList.contains(index)) {
      mainUIList.remove(index);
    } else {
      mainUIList.add(index);
    }
    asyncToStorage();
    notifyChanged();
  }

  void saveNativeSelectIndexToStorage(String nativeMainUIList,
      String nativeSecondaryUIList, VolState volState) {
    ExStorageUtils.putObject(
        ExStorageUtils.KLINE_MAIN_INDICATOS_SELECT_LIST, nativeMainUIList);
    ExStorageUtils.putObject(
        ExStorageUtils.KLINE_SEC_INDICATOS_SELECT_LIST, nativeSecondaryUIList);
    ExStorageUtils.putObject(ExStorageUtils.KLINE_VOL_INDICATOS_SELECT_STATUS,
        volState == VolState.VOL);
    notifyChanged();
  }

  void asyncToStorage() {
    var mainUIStr = mainUIList.join(",");
    var secondaryUIStr = secondaryUIList.join(",");
    ExStorageUtils.putObject(
        ExStorageUtils.KLINE_MAIN_INDICATOS_SELECT_LIST, mainUIStr);
    ExStorageUtils.putObject(
        ExStorageUtils.KLINE_SEC_INDICATOS_SELECT_LIST, secondaryUIStr);
    ExStorageUtils.putObject(ExStorageUtils.KLINE_VOL_INDICATOS_SELECT_STATUS,
        volState == VolState.VOL);

    Routes.pushNvEvent(ev: NvEvent.kline_detail_clickMainIndex,param: {
      ExStorageUtils.KLINE_MAIN_INDICATOS_SELECT_LIST:mainUIStr,
      ExStorageUtils.KLINE_SEC_INDICATOS_SELECT_LIST:secondaryUIStr,
      ExStorageUtils.KLINE_VOL_INDICATOS_SELECT_STATUS:volState == VolState.VOL,
    });
  }

  void _stopAnimation() {
    if (_scrollXController.isAnimating) {
      _scrollXController.stop();
      isDrag = false;
      notifyChanged();
    }
  }

  void notifyChanged(){
    setState(() {
      repaintNum++;
    });
  }

  late List infos;

  Widget _buildInfoDialog() {
    return StreamBuilder<InfoWindowEntity?>(
        stream: mInfoWindowStream.stream,
        builder: (context, snapshot) {
          if (!isLongPress ||
              widget.isLine == true ||
              !snapshot.hasData ||
              snapshot.data?.kLineEntity == null) return const SizedBox();
          KLineEntity entity = snapshot.data!.kLineEntity;
          double upDown = entity.close - entity.open;
          double upDownPercent = upDown / entity.open * 100;
          infos = [
            getDate(entity.id!),
            NumberUtil.format(entity.open),
            NumberUtil.format(entity.high),
            NumberUtil.format(entity.low),
            NumberUtil.format(entity.close),
            "${upDown > 0 ? "+" : ""}${NumberUtil.format(upDown)}",
            "${upDownPercent > 0 ? "+" : ''}${upDownPercent.toStringAsFixed(2)}%",
            NumberUtil.volFormat(entity.vol)
          ];
          return Align(
            alignment: snapshot.data!.isLeft ? Alignment.topLeft : Alignment.topRight,
            child: Container(
              margin: EdgeInsets.only(left: 19.0, right: 19.0, top: widget.isOnlyMainChart ? 8.0 : 40.0),
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              decoration: BoxDecoration(
                  color: widget.isOnlyMainChart ? ChartColors.smallKlineMarkerBgColor:ChartColors.klineMarkerBgColor,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: ExColors.fill_5(context), width: 0.5)
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                    widget.infoNames.length,
                    (i) =>
                        _buildItem(infos[i].toString(), widget.infoNames[i])),
              ),
            ),
          );
        });
  }

  Widget _buildItem(String info, String infoName) {
    Color color = Colors.white;
    if (info.startsWith("+"))
      color = ChartColors.upColor;
    else if (info.startsWith("-"))
      color = ChartColors.dnColor;
    else
      color = ChartColors.markerTextColor;
    return Container(
      constraints: const BoxConstraints(
          minWidth: 95, maxWidth: 110, maxHeight: 14.0, minHeight: 14.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text("$infoName",
              style: TextStyle(
                  color: ChartColors.markerLabelColor,
                  fontSize: ChartStyle.defaultTextSize,
                  fontFamily: "HarmonyOS_Sans_SC_Regular")),
          const SizedBox(width: 5),
          Text(info,
              style: TextStyle(
                  color: color,
                  fontSize: ChartStyle.defaultTextSize,
                  fontFamily: "HarmonyOS_Sans_SC_Regular")),
        ],
      ),
    );
  }

  String getDate(int date) {
    return dateFormat(
        DateTime.fromMillisecondsSinceEpoch(date * 1000), mFormats);
  }

  void scrollRight({double? value}) {
    mScrollX = value??0;
    notifyChanged();
    print("scrollRight");
  }

  void setOrderShow(bool isShow) {
    widget.isShowOrder = isShow;
    print("widget.isShowOrder${widget.isShowOrder}");
    notifyChanged();
  }
  void setWaterLogoPath(String path) {
    widget.waterLogoPath = path;
    notifyChanged();
  }
}
