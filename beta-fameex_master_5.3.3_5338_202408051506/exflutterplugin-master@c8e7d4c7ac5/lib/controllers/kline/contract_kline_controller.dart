import 'dart:async';
import 'dart:convert' as convert;
import 'dart:convert';

import 'package:chainup_flutter_ex/ext/String_ext.dart';
import 'package:chainup_flutter_ex/page/kline/kline_introduction_page.dart';
import 'package:chainup_flutter_ex/utils/app_utils.dart';
import 'package:chainup_flutter_ex/utils/decimal_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:kumi_popup_window/kumi_popup_window.dart';
import 'package:library_kline/flutter_k_chart.dart';
import 'package:library_kline/kline_constant.dart';
import 'package:library_kline/models/entrust_order_entity.dart';
import 'package:library_kline/models/position_entity.dart';
import 'package:library_kline/my_custom_scale_recognizer.dart';
import 'package:library_kline/utils/klineCoinInfo.dart';
import 'package:library_kline/utils/number_util.dart';
import 'package:library_kline/utils/storage_utils.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../I10n/translation_service.dart';
import '../../base/controller/base_controller.dart';
import '../../caseview/showcase_widget.dart';
import '../../constants/app_constant.dart';
import '../../constants/color_constant.dart';
import '../../event/event.dart';
import '../../event/net_event.dart';
import '../../event/ws_event.dart';
import '../../models/bottom_sheet_entity.dart';
import '../../models/coin_json_entity.dart';
import '../../models/contract_market_entity.dart';
import '../../models/deal_record_entity.dart';
import '../../models/depth_map_entity.dart';
import '../../models/etf_net_value_entity.dart';
import '../../models/guide_item_entity.dart';
import '../../models/kline_buy_sell_entity.dart';
import '../../models/market_depth_entity.dart';
import '../../models/market_ticker_entity.dart';
import '../../net/http/apiservice/exchange_api.dart';
import '../../net/ws/ex_socket_util.dart';
import '../../page/kline/item_guide_manager.dart';
import '../../page/kline/item_guie_dialog.dart';
import '../../page/kline/kline_adjustment_page.dart';
import '../../page/kline/kline_disclosure_page.dart';
import '../../page/kline/kline_order_book_page.dart';
import '../../page/kline/kline_transaction_record_page.dart';
import '../../page/kline/main_state.dart';
import '../../routes/routes.dart';
import '../../utils/date_format_util.dart';
import '../../utils/num_utils.dart';
import '../../widgets/ex_kline_loading.dart';

class KlineController extends BaseController<ExchangeApi> {
  KlineController();
  Map<String, dynamic> coinInfoMap = {};
  Map<String, dynamic> dealMap = {};
  bool isFirst = true;
  bool isNoMore = false;
  var klineDatas = <KLineEntity>[].obs;
  var klineBuySellDatas = <KlineBuySellEntity>[];
  var wsChannel = "";
  var isLine = false.obs;
  var isSkinDay = true.obs;
  var isShowOrder = false.obs;
  var KlinePageState = KlineState.LOADING.obs;
  var klineMainCurState = MainState.MA.obs;
  var klineSubCurState = SecondaryState.MACD.obs;
  var klineVolCurState = VolState.VOL.obs;
  var klineBgColor = "".obs;

  var mFundRate = "--".obs;
  var mMarkPrice = "--".obs;
  var mNetValue = "--".obs;

  var mCoinName = "--".obs;
  var latestPrice = "0".obs;
  var latestRose = "0".obs;
  var latestRoseDou = "0".obs;
  var latestLegalPrice = "0".obs;
  var etfRisk = "".obs;
  var mCoinMarketTag = "".obs;
  var mCurrencyUnit = "¥".obs;
  var mCurrencyRates = "6.5".obs;
  var mCurrencyPrecision = 4;
  var marketTag = "".obs; // tag标签
  var leverMultiple = "".obs; // 杠杆倍数
  var klineType = 0; // k线类型 0- 币币 1-合约 2- 杠杆
  var isContractKline = false.obs; // 是否属于合约Kline
  List<String> mHighlightStr=[];
  var high24Price = "--".obs;
  var low24Price = "--".obs;
  var vol24 = "--".obs;
  var amount24 = "--".obs;
  var marketEntity = ContractMarketEntity().obs;
  var bidDatas = <DepthEntity>[].obs;
  var askDatas = <DepthEntity>[].obs;
  var marginCoinPrecision = 1;//保证金币种精度

  var isCollect = false.obs;
  var isShowDepth = false.obs;
  var isOpen = false.obs;
  var isMoreTimeOpen = false.obs;
  var isMoreTargetOpen = false.obs;

  var openTime = 0.obs;
  var timeDifference =Duration().obs;
  Timer? _OpenTimer;
  var klineTimeCurId = 3.obs;
  var klineTimeCurScale = "15min".obs;
  var klineTimeLastScale = "15min";
  KlineTimeEntity? mKlineTimeCurEntity = null;

  late TabController orderTypeTabController;
  final PageController orderTypePagerController = PageController();
  final GlobalKey moreTimeCtrlKey = GlobalKey();
  final GlobalKey moreTimeCtrlGuideKey = GlobalKey();
  final GlobalKey timeCtrlSettingGuideKey = GlobalKey();

  late AnimationController mAnimationController;
  late Animation<double> mAnimation;

  late AnimationController mMoreTimeAnimationController;
  late AnimationController mMoreTimeAnimationController2;
  late Animation<double> mMoreTimeAnimation;
  late Animation<double> mMoreTimeAnimation2;
  final mMoreTimeAnimationEndDefaultValue = 92.0;
  final mMoreTimeAnimation2EndDefaultValue = 176.0;

  late final AnimationController arrowController;
  late final Animation<double> arrowAnimation;


  late AnimationController klineAnimationController;
  late AnimationController opacityAnimationController;
  late Animation<double> klineAnimation;
  late Animation<double> opacityAnimation;

  var dealRecorddatas = <DealRecordData>[].obs;
  var buysDepthdatas = <DepthTick>[].obs;
  var buysDepthTotalVol = 0.0;
  var sellsDepthdatas = <DepthTick>[].obs;
  var sellsDepthTotalVol = 0.0;
  var isDoGuide = false;
  var mainChartHeight = 336.0;
  var itemChartHeight = 80.0;
  var klineHeight = 0.0.obs;
  var overOpacity = 0.0.obs;
  var waterLogoPath = AppConstant.waterPath.obs;
  Timer? _timer;
  Timer? secondGuideTimer;

  //  "委托挂单",
  //     "成交记录",
  //     "简介",
  //     "信息披露",
  //     "调仓信息",
  var orderTypeTabListData =
      ["kline_action_entrustMentOrder".tr, "kline_action_dealHistory".tr].obs;
  var orderTypeTabListPage =
      [KLineOrderBookPage(), KLineTransactionRecordPage()].obs;
  var orderDisplayTextList = <String>["cp_contract_order_history".tr,"kline_cost_position".tr,"kline_open_orders".tr].obs;
  var orderDisplayTextSelectors = <String>[].obs;
  List<KlineTimeEntity> klineTimeData = [];
  var klineDefaultTimeData = <KlineTimeEntity>[].obs;

  final List<String> infoNames = [
    "cp_marker_kline_text_dealTime".tr,
    "cp_marker_kline_text_open".tr,
    "cp_marker_kline_text_high".tr,
    "cp_marker_kline_text_low".tr,
    "cp_marker_kline_text_close".tr,
    "cp_kline_info1".tr,
    "cp_kline_info2".tr,
    "cp_marker_kline_text_volume".tr,
  ];

  RxList<KlineTimeEntity> klineMoreTimeData = <KlineTimeEntity>[].obs;
  var showKlineMoreTimeOtherData = <KlineTimeEntity>[].obs;
  var isShowOtherLayout = true.obs;
  List<String> klineMainIndexData = [
    "MA",
    "BOLL",
  ];

  List<String> klineSubMainIndexData = [
    "MACD",
    "KDJ",
    "RSI",
    "WR",
  ];

  //币种精度
  var mSymbolPricePrecision = 0.obs;

  //数量精度
  var mSymbolAmountPrecision=0.obs;

  //面值币种
  var mMultiplierCoin = "";

  // //面值精度
  // var mMultiplierPrecision = 0;

  //面值
  var mMultiplier = "1";

  //显示数量单位
  var mQuantityUnit = "--".obs;

  //显示价格单位
  var mPriceUnit = "--".obs;

  //是否为张
  // var isCont = false;

  // 是否含有币对简介
  var isSymbolProfile = false.obs;

  // 是否是EFT币对
  var isSymbolEtf = false.obs;

  // 是否是普通比对
  var isNormalCoin = true.obs;

  var indexDialogHeight = 0.0.obs;
  var moreTimeDialogHeight = 0.0.obs;

  final GlobalKey<KChartWidgetState> mKChartKey =
  GlobalKey<KChartWidgetState>();
  final GlobalKey<KlineLoadingDialogState> mKLoadingKey =
  GlobalKey<KlineLoadingDialogState>();
  final ScrollController scrollViewControl = ScrollController();
  final RefreshController refreshController = RefreshController();
  var symbol = "e_btcusdt";
  var isInitRefresh = false;

  List<ItemGuideModel> guideList = [];

  final klineTimeList = <String>[
    "line",
    "1min",
    "5min",
    "15min",
    "30min",
    "60min",
    "4h",
    "1day",
    "1week",
    "1month"
  ];
  final showKlineTimeList = <String>["15min", "60min", "4h", "1day", "1week"];

  final selectShowKTimeList = <String>[].obs;
  var positionList = <PositionOrder>[].obs;
  var entrustList = <EntrustOrder>[].obs;
  //
  // var buydata = {"KlineBuySellData":[{"isBuy":true,"vol":"2","price":"26830","ctime":1697685861000},{"isBuy":false,"vol":"2","price":"26820","ctime":1697685264000},{"isBuy":true,"vol":"2","price":"26830","ctime":1697685224000},{"isBuy":true,"vol":"2","price":"26830","ctime":1697685028000},{"isBuy":false,"vol":"2","price":"26820","ctime":1697684893000},{"isBuy":false,"vol":"2","price":"26820","ctime":1697684823000},{"isBuy":true,"vol":"2","price":"26830","ctime":1697684761000},{"isBuy":true,"vol":"2","price":"26820","ctime":1697613194000},{"isBuy":true,"vol":"2","price":"26820","ctime":1697613084000},{"isBuy":true,"vol":"2","price":"26820","ctime":1697613066000},{"isBuy":true,"vol":"2","price":"26820","ctime":1697612977000},{"isBuy":true,"vol":"10","price":"26800","ctime":1697609382000},{"isBuy":true,"vol":"5","price":"26812","ctime":1697609307000},{"isBuy":false,"vol":"36","price":"26812","ctime":1697609352000},{"isBuy":true,"vol":"5","price":"26820","ctime":1697609323000},{"isBuy":true,"vol":"5","price":"26820","ctime":1697609315000},{"isBuy":true,"vol":"12","price":"27021.4","ctime":1697011668000},{"isBuy":true,"vol":"2","price":"27183.9","ctime":1697011716000},{"isBuy":false,"vol":"2","price":"27027.1","ctime":1697011604000},{"isBuy":false,"vol":"10","price":"26992.7","ctime":1697011553000},{"isBuy":false,"vol":"10","price":"20000","ctime":1695375076000},{"isBuy":false,"vol":"10","price":"20000","ctime":1695375066000},{"isBuy":true,"vol":"2","price":"20000","ctime":1695375100000},{"isBuy":false,"vol":"50","price":"21000","ctime":1695287186000},{"isBuy":false,"vol":"50","price":"21000","ctime":1695287180000},{"isBuy":false,"vol":"50","price":"21000","ctime":1695287172000},{"isBuy":true,"vol":"99","price":"0","ctime":1695287092000}]};

  // final String orderDataStr = "{\"orderList\":[{\"symbol\":\"BTC-USDT\",\"orderType\":1,\"contractOtherName\":\"BTCUSDT\",\"positionType\":2,\"orderId\":\"2108801557774401709\",\"avgPrice\":0E-8,\"tradeFee\":0E-16,\"memo\":0,\"source\":2,\"type\":1,\"quote\":\"USDT\",\"liqPositionMsg\":\"\",\"dealVolume\":0,\"price\":65700.0000000000000000,\"ctime\":1710470444000,\"contractName\":127,\"id\":\"2108801557774401709\",\"contractSide\":1,\"pricePrecision\":3,\"side\":\"SELL\",\"multiplier\":0.0001000000000000,\"volume\":200000.0000000000000000,\"contractId\":127,\"orderBalance\":1220.04000000000000000000000000000000000000000000000000000000,\"open\":\"OPEN\",\"status\":0,\"base\":\"BTC\"},"
  //     "{\"symbol\":\"BTC-USDT\",\"orderType\":1,\"contractOtherName\":\"BTCUSDT\",\"positionType\":2,\"orderId\":\"2108801557774401613\",\"avgPrice\":0E-8,\"tradeFee\":0E-16,\"memo\":0,\"source\":2,\"type\":2,\"quote\":\"USDT\",\"liqPositionMsg\":\"\",\"dealVolume\":0,\"price\":62500.0000000000000000,\"ctime\":1710470432000,\"contractName\":127,\"id\":\"2108801557774401613\",\"contractSide\":1,\"pricePrecision\":3,\"side\":\"BUY\",\"multiplier\":0.0001000000000000,\"volume\":3001233.0000000000000000,\"contractId\":127,\"orderBalance\":1830.06000000000000000000000000000000000000000000000000000000,\"open\":\"OPEN\",\"status\":0,\"base\":\"BTC\",\"triggerType\":1,\"isTriggerOrder\":true,\"triggerPrice\":62500.000}]}";
  // final String positionDataStr = "{\n" +
  //     "  \"positionList\": [\n" +
  //     "    {\n" +
  //     "      \"id\": 8274380,\n" +
  //     "      \"contractId\": 127,\n" +
  //     "      \"positionVolume\": 161233,\n" +
  //     "      \"orderSide\": \"SELL\",\n" +
  //     "      \"openAvgPrice\": 62000,\n" +
  //     "      \"unRealizedAmount\": 322312\n" +
  //     "    },\n" +
  //     "    {\n" +
  //     "      \"id\": 8274382,\n" +
  //     "      \"contractId\": 122,\n" +
  //     "      \"positionVolume\": 161233,\n" +
  //     "      \"orderSide\": \"BUY\",\n" +
  //     "      \"openAvgPrice\": 55000,\n" +
  //     "      \"unRealizedAmount\": -0.002\n" +
  //     "    }\n" +
  //     "  ]\n" +
  //     "}";

  @override
  bool useEventBus() => true;

  @override
  void onResumed() {
    super.onResumed();
    print("onResumed>>>");
    onResumeHandler();
    isDoGuide = true;
  }

  @override
  void onDetached() {
    super.onDetached();
    secondGuideTimer?.cancel();
    _OpenTimer?.cancel();
  }

  void onResumeHandler() {
    print("onResumeHandler>>>");
    mKChartKey.currentState?.initKlineConf();
    var curTime = ExStorageUtils.getKlineTimeScale();
    // if (klineTimeCurScale.value != curTime ||
    //     (curTime == "line" && klineTimeCurScale.value != "1min")) {
    klineTimeCurScale.value = curTime == "line" ? "1min" : curTime;
    isLine.value = curTime == "line";
    Routes.pushNvEvent(
        ev: NvEvent.kline_switch_time_index,
        param: {"mklineScale": isLine.value ? "line" : curTime,"isTap":false});
    // }
  }

  void makeScroll(){
    // print("当前滚动位置:${scrollViewControl.offset}");
    if(mKChartKey.currentState!=null){
      if(mKChartKey.currentState!.recofnizer.getPointers()>1){
        scrollViewControl.jumpTo(scrollViewControl.offset);
      }
    }
  }

  @override
  void onInit() {
    super.onInit();
    print("onInit>>>");
    // startOpenTimer();
    startGuide();
    scrollViewControl.addListener(makeScroll);
    isDoGuide = false;
    var curTime = ExStorageUtils.getKlineTimeScale();
    klineTimeCurScale.value = curTime == "line" ? "1min" : curTime;
    isLine.value = curTime == "line";
    Routes.pushNvEvent(
        ev: NvEvent.kline_switch_time_index,
        param: {"mklineScale": isLine.value ? "line" : curTime,"isTap":false});
    klineHeight.value = mainChartHeight + (1 * itemChartHeight);
    if (isLandscape) setPortrait();
    if (AppUtil.needSubWs) SocketUtils().initSocket("");
    // ExStorageUtils.putObject(ExStorageUtils.KLINE_TIME_SHOW_LIST, "");
    var listTimeStr =
    ExStorageUtils.getString(ExStorageUtils.KLINE_TIME_SHOW_LIST);
    print("KLINE_TIME_SHOW_LIST>>>" + listTimeStr);
    List<String> listTime = listTimeStr.split(",");
    listTime = listTime.where((element) => element != "").toList();
    if (listTime.length > 0) {
      showKlineTimeList.clear();
      showKlineTimeList.addAll(listTime);
    }
    // Map<String, dynamic> params = Get.arguments;
    orderTypeTabController =
        TabController(length: orderTypeTabListData.length, vsync: this);
    mAnimationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    mAnimation = Tween<double>(
      begin: 0.0,
      end: 164.0.h,
    ).animate(mAnimationController)
      ..addListener(() {
        print("mAnimation addListener>>> " + mAnimation.value.toString());
        indexDialogHeight.value = mAnimation.value;
      });

    mMoreTimeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    mMoreTimeAnimationController2 = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    mMoreTimeAnimation = Tween<double>(
      begin: 0.0,
      end: mMoreTimeAnimationEndDefaultValue,
    ).animate(mMoreTimeAnimationController)
      ..addListener(() {
        print("mMoreTimeAnimation addListener>>> " +
            mMoreTimeAnimation.value.toString());
        moreTimeDialogHeight.value = mMoreTimeAnimation.value;
      });
    mMoreTimeAnimation2 = Tween<double>(
      begin: 0.0,
      end: mMoreTimeAnimation2EndDefaultValue,
    ).animate(mMoreTimeAnimationController2)
      ..addListener(() {
        print("mMoreTimeAnimation2 addListener>>> " +
            mMoreTimeAnimation2.value.toString());
        moreTimeDialogHeight.value = mMoreTimeAnimation2.value;
      });
    arrowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    arrowAnimation = Tween<double>(begin: 0, end: 1).animate(arrowController);

    klineAnimationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    opacityAnimationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 0.5,
    ).animate(opacityAnimationController)
      ..addListener(() {
        overOpacity.value = opacityAnimation.value;
      });

    klineMoreTimeData.clear();
    klineTimeData.clear();
    for (var i = 0; i < klineTimeList.length; i++) {
      var element = klineTimeList[i];
      klineTimeData.add(KlineTimeEntity(
          id: i,
          showTime: subTime2ShowTime(element),
          subTime: element,
          isLine: (element == "line" || element == "Line")));
    }
    klineMoreTimeData.clear();
    klineMoreTimeData.addAll(klineTimeData);

    changeMoreOtherKlineTime();

    changeShowKlineTimeVisible();

    orderDisplayTextSelectors.clear();
    var isVisible =
    ExStorageUtils.getInt(key: ExStorageUtils.KLINE_ORDER_VISIBLE_STATUS);
    isShowOrder.value = isVisible == 1;
    if(isShowOrder.value) orderDisplayTextSelectors.add(orderDisplayTextList[0]);
    var isHoldCostLineVisible = ExStorageUtils.getInt(key: ExStorageUtils.KLINE_HOLD_COST_VISIBLE_STATUS) == 1;
    if(isHoldCostLineVisible) orderDisplayTextSelectors.add(orderDisplayTextList[1]);
    Routes.pushNvEvent(ev: NvEvent.kline_position_visible_event, param: {
      "visible": isHoldCostLineVisible ? 1 : 0
    });
    var isHISTORICAL_COMMISSIONVisible = ExStorageUtils.getInt(key: ExStorageUtils.KLINE_HISTORICAL_COMMISSION_VISIBLE_STATUS) == 1;
    if(isHISTORICAL_COMMISSIONVisible) orderDisplayTextSelectors.add(orderDisplayTextList[2]);
    Routes.pushNvEvent(ev: NvEvent.kline_entrust_visible_event, param: {
      "visible": isHISTORICAL_COMMISSIONVisible ? 1 : 0
    });
    for (int i = 0; i < 20; i++) {
      sellsDepthdatas.add(DepthTick(0, 0));
    }
    for (int i = 0; i < 20; i++) {
      buysDepthdatas.add(DepthTick(0, 0));
    }
    listenEvent();

    // nativeMethods({
    //   "method":"updateEntrust",
    //   "arguments":orderDataStr
    // });
    // nativeMethods({
    //   "method":"updatePosition",
    //   "arguments":positionDataStr
    // });
  }

  void changeMoreOtherKlineTime() {
    showKlineMoreTimeOtherData.clear();
    var newMoreList = klineTimeList
        .where((element) => !showKlineTimeList.contains(element))
        .toList();
    for (var i = 0; i < newMoreList.length; i++) {
      var element = newMoreList[i];
      showKlineMoreTimeOtherData.add(KlineTimeEntity(
          id: i,
          showTime: subTime2ShowTime(element),
          subTime: element,
          isLine: (element == "line" || element == "Line")));
    }
  }

  void changeShowKlineTimeVisible() {
    klineDefaultTimeData.clear();
    showKlineTimeList.sort((a, b) {
      var firstEn = getIdBykTimeStr(a);
      var secEn = getIdBykTimeStr(b);
      return firstEn.compareTo(secEn);
    });
    for (var i = 0; i < showKlineTimeList.length; i++) {
      final currentTime = showKlineTimeList[i];
      klineDefaultTimeData.add(KlineTimeEntity(
          id: i,
          showTime: subTime2ShowTime(currentTime),
          subTime: currentTime,
          isLine: "line" == currentTime));
    }
  }

  /**
   * 切换K线时间
   */
  void switchKlineTimeScale(KlineTimeEntity value) {
    value.isLine = value.isLine ?? false;
    if (klineTimeCurScale.value != value.subTime ||
        (isLine.value != value.isLine)) {
      // SocketUtils().unSubKlineLast(symbol, getKlineTimeScale());
      mKlineTimeCurEntity = value;
      klineTimeCurScale.value = value.subTime;
      isLine.value = value.isLine ?? false;
      klineTimeCurId.value = value.id;
      ExStorageUtils.setKlineTimeScale(
          (value.isLine ?? false) ? "line" : value.subTime);
      ExStorageUtils.setKlineTimeId(value.id);
      var buff = getKlineTimeScale();
      klineTimeLastScale = buff;
      isShowDepth.value = false;
      Routes.pushNvEvent(
          ev: NvEvent.kline_switch_time_index,
          param: {"mklineScale": (value.isLine ?? false) ? "line" : buff,"isTap":true});
      setKlinePageState(KlineState.LOADING);
      mKChartKey.currentState?.isLongPress = false;
      mKChartKey.currentState?.notifyChanged();
      if (AppUtil.needSubWs) {
        SocketUtils().subKlineHistory(symbol, getKlineTimeScale());
        SocketUtils().subKlineLast(symbol, getKlineTimeScale());
      }
    }
  }

  /**
   * 获取订阅的时间名称
   */
  String getKlineTimeScale() {
    var buff = klineTimeCurScale.value;
    if (buff == "Line" || buff == "line") {
      buff = "1min";
    }
    return buff;
  }

  String getKlineTimeScaleTX() {
    var buff = klineTimeCurScale.value;
    if (buff == "Line") {
      buff = "line";
    }
    if (isLine.value) buff = "line";
    return buff;
  }

  String getKlineTimeMoreScaleStr() {
    String showStr = "common_action_showMore".tr;
    klineMoreTimeData.forEach((element) {
      if (klineTimeCurScale == element.subTime) {
        showStr = element.showTime;
      }
    });
    return showStr;
  }

  Color getKlineTimeMoreScaleColor(BuildContext context) {
    Color showColor = ExColors.text_color_2(context);
    if (isShowDepth.value) {
      return showColor;
    }
    klineMoreTimeData.forEach((element) {
      if (klineTimeCurScale == element.subTime) {
        showColor = ExColors.text_color_1(context);
      }
    });
    return showColor;
  }

  Color getKlineTimeScaleColor(BuildContext context,
      KlineTimeEntity mKlineTimeEntity) {
    Color showColor = ExColors.special_4(context);
    if (isShowDepth.value) {
      return showColor;
    }
    if (isLine.value && mKlineTimeEntity.isLine == true) {
      showColor = ExColors.text_color_1(context);
    } else if (klineTimeCurScale == mKlineTimeEntity.subTime &&
        isLine.value == false) {
      showColor = ExColors.text_color_1(context);
    }
    return showColor;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void onClose() {
    super.onClose();
    scrollViewControl.removeListener(makeScroll);
    refreshController.dispose();
    scrollViewControl.dispose();
  }

  @override
  void onReady() {
    super.onReady();
    print("onReady>>>");
    showSuccess();
    loadNet();

    var guideFlag = ExStorageUtils.getObject(ExStorageUtils.KLINE_V_GUIDE1_STATUS,def: "0");
    print("guideFlag = $guideFlag");
    if("1"==guideFlag) return;
    Future.delayed(const Duration(milliseconds: 300),(){
      ShowCaseWidget.of(moreTimeCtrlGuideKey!.currentContext!).startShowCase([moreTimeCtrlGuideKey]);
    });

  }

  void startGuide() {
    final item1 = ItemGuideModel(
        key: moreTimeCtrlGuideKey,
        title: "kline_IntervalsGuide1".tr + ":",
        message: "kline_IntervalsGuide2".tr,
        renderObject: null
    );

    final item2 = ItemGuideModel(
        key: timeCtrlSettingGuideKey,
        title: "kline_IndicatorsGuide1".tr + ":",
        message: "kline_IndicatorsGuide2".tr,
        renderObject: null
    );
    guideList = [item1, item2];
  }

  int getIdBykTimeStr(String kTimeStr) {
    var entity = klineTimeData.singleWhere((element) => element.subTime == kTimeStr);
    return entity.id;
  }

  @override
  void loadNet() {}

  getMoreHistoryKlineData() {
    if (isNoMore) return;
    if (KlinePageState.value == KlineState.LOADING) return;
    if (klineDatas.length > 0) {
      setKlinePageState(KlineState.LOADING);
      Routes.pushNvEvent(
          ev: NvEvent.more_history_kline,
          param: {"endIdx": klineDatas.first.id});
    }
  }

  reloadKlineData() {
    setKlinePageState(KlineState.LOADING);
    Routes.pushNvEvent(ev: NvEvent.reload_kline);
  }


  setHistoryKlineData(String klineStr, bool isMore) {
    if (!isMore) isNoMore = false;
    Map<String, dynamic> result = convert.jsonDecode(klineStr);
    MarketTickerEntity quoteWs = MarketTickerEntity.fromJson(result);
    wsChannel = quoteWs.channel ?? "";
    List<MarketTickerData>? wsResult = quoteWs.data;

    //第一次 并且没数据
    if((wsResult == null || wsResult.isEmpty) && !isMore){
      isNoMore = true;
      setKlinePageState(KlineState.NONE);
      klineDatas.clear();
      DataUtil.calculate(klineDatas.value);
      klineDatas.refresh();
      return;
    }

    //加载更多 并且没数据
    if((wsResult == null || wsResult.isEmpty) && isMore){
      isNoMore = true;
      setKlinePageState(KlineState.NONE);
      return;
    }
    List<KLineEntity> listEx = [];
    for (var item in wsResult!) {
      listEx.add(KLineEntity(
          item.open ?? 0,
          item.high ?? 0,
          item.low ?? 0,
          item.close ?? 0,
          item.vol ?? 0,
          item.open,
          item.id));
    }
    if (!isMore) {
      klineDatas.clear();
      klineDatas.value.addAll(listEx);
      mKChartKey.currentState?.scrollRight();
    } else {
      klineDatas.value.insertAll(0, listEx);
    }
    DataUtil.calculate(klineDatas.value);

    syncKlineBuySellData();
  }

  setNewKlineData(String klineStr) {
    // print("flutterklineStr:" + klineStr.toString());
    Map<String, dynamic> result = convert.jsonDecode(klineStr);
    MarketTickerEntity quoteWs = MarketTickerEntity.fromJson(result);
    // print("flutterklinequoteWs:" + quoteWs.data.toString());
    var lastKLineEntity = KLineEntity(
        double.parse(quoteWs?.tick?.open.toString() ?? "0"),
        double.parse(quoteWs?.tick?.high.toString() ?? "0"),
        double.parse(quoteWs?.tick?.low.toString() ?? "0"),
        double.parse(quoteWs?.tick?.close.toString() ?? "0"),
        double.parse(quoteWs?.tick?.vol.toString() ?? "0"),
        double.parse(quoteWs?.tick?.amount.toString() ?? "0"),
        int.parse(quoteWs?.tick?.id.toString() ?? "0"));
    if (!klineDatas.value.isEmpty) {
      var position = -1;
      for (int i = 0; i < klineDatas.length; i++) {
        if (klineDatas[i].id == lastKLineEntity.id) {
          position = i;
          break;
        }
      }
      if (position != -1) {
        klineDatas[position].open = lastKLineEntity.open;
        klineDatas[position].high = lastKLineEntity.high;
        klineDatas[position].low = lastKLineEntity.low;
        klineDatas[position].close = lastKLineEntity.close;
        klineDatas[position].vol = lastKLineEntity.vol;
        klineDatas[position].amount = lastKLineEntity.amount;
        klineDatas[position].id = lastKLineEntity.id;
        DataUtil.updateLastData(klineDatas);
        syncSigleKlineBuySellData(klineDatas[position]);
        klineDatas.refresh();
      } else {
        syncSigleKlineBuySellData(lastKLineEntity);
        DataUtil.addLastData(klineDatas, lastKLineEntity);
      }
    } else {
      syncSigleKlineBuySellData(lastKLineEntity);
      DataUtil.addLastData(klineDatas, lastKLineEntity);
    }
  }


  void syncSigleKlineBuySellData(KLineEntity element){
      var KStartTime = (element.id ?? 0) * 1000;
      var KEndTime = 0;
      var timeTargetStr = "1h";
      var timeTargetInt = 1;
      if (wsChannel.contains("_")) {
        timeTargetStr = wsChannel.split("_").last;
        timeTargetInt =
            int.parse(timeTargetStr.replaceAll(RegExp(r'[^0-9]'), ''));
      }
      if (timeTargetStr.contains("min")) {
        KEndTime = DateTime.fromMillisecondsSinceEpoch(KStartTime)
            .add(Duration(minutes: timeTargetInt))
            .millisecondsSinceEpoch;
      } else if (timeTargetStr.contains("h")) {
        KEndTime = DateTime.fromMillisecondsSinceEpoch(KStartTime)
            .add(Duration(hours: timeTargetInt))
            .millisecondsSinceEpoch;
      } else if (timeTargetStr.contains("day")) {
        var newDateStr = long2dateYmd(KStartTime);
        KStartTime = dateToTimestamp(newDateStr);
        KEndTime = DateTime.fromMillisecondsSinceEpoch(KStartTime)
            .add(Duration(days: timeTargetInt))
            .millisecondsSinceEpoch;
      } else if (timeTargetStr.contains("week")) {
        var newDateStr = long2dateYmd(KStartTime);
        KStartTime = dateToTimestamp(newDateStr);
        KEndTime = DateTime.fromMillisecondsSinceEpoch(KStartTime)
            .add(Duration(days: 7))
            .millisecondsSinceEpoch;
      } else if (timeTargetStr.contains("month")) {
        var newDateStr = long2dateYmd(KStartTime);
        KStartTime = dateToTimestamp(newDateStr);
        KEndTime = DateTime(
            DateTime.fromMillisecondsSinceEpoch(KStartTime).year,
            DateTime.fromMillisecondsSinceEpoch(KStartTime).month + 1,
            DateTime.fromMillisecondsSinceEpoch(KStartTime).day)
            .millisecondsSinceEpoch;
      }
      klineBuySellDatas.forEach((it) {
        var orderCtime = it.ctime ?? 0;
        if (KStartTime <= orderCtime && orderCtime < KEndTime) {
          element.orderPrice = it.price;
          element.orderVol = it.vol;
          if (it.isBuy ?? true) {
            element.orderIsBuy = true;
          } else {
            element.orderIsSell = true;
          }
        }
      });
  }

  void syncKlineBuySellData() {
    if (klineDatas.length != 0 && klineBuySellDatas.length != 0) {
      klineDatas.forEach((element) {
        var KStartTime = (element.id ?? 0) * 1000;
        var KEndTime = 0;
        var timeTargetStr = "1h";
        var timeTargetInt = 1;
        if (wsChannel.contains("_")) {
          timeTargetStr = wsChannel
              .split("_")
              .last;
          timeTargetInt =
              int.parse(timeTargetStr.replaceAll(RegExp(r'[^0-9]'), ''));
        }
        if (timeTargetStr.contains("min")) {
          KEndTime = DateTime
              .fromMillisecondsSinceEpoch(KStartTime)
              .add(Duration(minutes: timeTargetInt))
              .millisecondsSinceEpoch;
        } else if (timeTargetStr.contains("h")) {
          KEndTime = DateTime
              .fromMillisecondsSinceEpoch(KStartTime)
              .add(Duration(hours: timeTargetInt))
              .millisecondsSinceEpoch;
        } else if (timeTargetStr.contains("day")) {
          var newDateStr = long2dateYmd(KStartTime);
          KStartTime = dateToTimestamp(newDateStr);
          KEndTime = DateTime.fromMillisecondsSinceEpoch(KStartTime)
              .add(Duration(days: timeTargetInt))
              .millisecondsSinceEpoch;
        } else if (timeTargetStr.contains("week")) {
          var newDateStr = long2dateYmd(KStartTime);
          KStartTime = dateToTimestamp(newDateStr);
          KEndTime = DateTime.fromMillisecondsSinceEpoch(KStartTime)
              .add(Duration(days: 7))
              .millisecondsSinceEpoch;
        } else if (timeTargetStr.contains("month")) {
          var newDateStr = long2dateYmd(KStartTime);
          KStartTime = dateToTimestamp(newDateStr);
          KEndTime = DateTime(
              DateTime.fromMillisecondsSinceEpoch(KStartTime).year,
              DateTime.fromMillisecondsSinceEpoch(KStartTime).month + 1,
              DateTime.fromMillisecondsSinceEpoch(KStartTime).day)
              .millisecondsSinceEpoch;
        }
        klineBuySellDatas.forEach((it) {
          var orderCtime = it.ctime ?? 0;
          if (KStartTime <= orderCtime && orderCtime < KEndTime) {
            element.orderPrice = it.price;
            element.orderVol = it.vol;
            if (it.isBuy ?? true) {
              element.orderIsBuy = true;
            } else {
              element.orderIsSell = true;
            }
          }
        });
      });
      klineDatas.refresh();
      Future.delayed(const Duration(milliseconds: 300),(){
        mKChartKey.currentState?.notifyChanged();
      });
    }
  }

  /**
   * 获取深度显示宽度
   * 当前 数量
   * 类型 0 买 1卖
   */
  double getDepthWidthTx(List<DepthTick> data, int index,
      BuildContext context) {
    var width = 0.0;
    var curVol = 0.0;
    for (int a = 0; a <= index; a++) {
      curVol += data[a].vol;
    }
    if (curVol == 0) {
      return MediaQuery
          .of(context)
          .size
          .width * 0.5;
    }
    width = (curVol / (index == 0 ? buysDepthTotalVol : sellsDepthTotalVol)) *
        MediaQuery
            .of(context)
            .size
            .width *
        0.5;
    return width;
  }

  void setKlinePageState(KlineState loading) {
    KlinePageState.value = loading;
    if (KlinePageState.value == KlineState.LOADING) {
      startTimer();
    }
    if (KlinePageState.value == KlineState.CONTENT) {
      stopTimer();
    }
  }

  void startTimer() {
    stopTimer();
    _timer = Timer(const Duration(seconds: 10), () {
      if (KlinePageState.value == KlineState.LOADING) {
        KlinePageState.value = KlineState.RELOAD;
      }
    });
  }

  void stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void show24HTicker(String tickerStr) {
    Map<String, dynamic> result = convert.jsonDecode(tickerStr);
    // print("show24HTicker>>>$result");
    MarketTickerEntity quoteWs = MarketTickerEntity.fromJson(result);
    // low24Price.value=NumUtils.showSNormal(quoteWs.tick?.low, mSymbolPricePrecision.value);
    low24Price.value = DecimalUtils.showSNormal(quoteWs.tick?.low,
        digits: mSymbolPricePrecision.value, isShowThous: true);

    // high24Price.value=NumUtils.showSNormal(quoteWs.tick?.high, mSymbolPricePrecision.value);
    high24Price.value = DecimalUtils.showSNormal(quoteWs.tick?.high,
        digits: mSymbolPricePrecision.value, isShowThous: true);

    // vol24.value = DecimalUtils.showSNormal(quoteWs.tick?.vol, isShowThous: true);
    final vol24Precision = isContractKline.value ? NumberUtil.getContractMultiplierPrecisionByMultiplier(KLineCoinInfo.mMultiplier) : mSymbolAmountPrecision.value;
    vol24.value = NumUtils.numberFormat(quoteWs.tick?.vol,vol24Precision,isAmount: false, isContract: isContractKline.value);//量的精度

    // amount24.value = DecimalUtils.showSNormal(quoteWs.tick?.amount);//
    final amount24Precision = isContractKline.value ? KLineCoinInfo.marginCoinPrecision : mSymbolAmountPrecision.value;
    amount24.value = NumUtils.numberFormat(quoteWs.tick?.amount, amount24Precision, isAmount: true, isContract: isContractKline.value);//量的精度
    // latestPrice.value = NumUtils.showSNormal(quoteWs.tick?.close, mSymbolPricePrecision.value,isShowThous: false);
    latestPrice.value = DecimalUtils.showSNormal(quoteWs.tick?.close,
        digits: mSymbolPricePrecision.value, isShowThous: true);

    latestRose.value =
    ("${NumUtils.mulStr(
        quoteWs.tick?.rose.toString() ?? "0", "100", 2, isShowPrefix: true)}%");

    latestRoseDou.value = quoteWs.tick?.rose.toString() ?? "0";

    // latestLegalPrice.value = ("≈${mCurrencyUnit.value}${NumUtils.mulStr(quoteWs.tick?.close.toString() ?? "0", mCurrencyRates.value, mCurrencyPrecision)}");
    latestLegalPrice.value =
    ("≈${mCurrencyUnit.value}${DecimalUtils.showSMultiply(
        quoteWs.tick?.close, mCurrencyRates.value, isShowThous: true,
        digits: mCurrencyPrecision)}");
  }

  void closePage() {
    Routes.pushNvEvent(ev: NvEvent.close_kline_vpage);
  }

  void switchPageView(int index) {
    if (!isFirst) return;
    // orderTypeTabController.index = index;
    Timer(const Duration(milliseconds: 300), () {
      isFirst = false;
      Event.eventBus.fire(WsMsgEvent(coinInfoMap, WsMsgState.coinInfo));
      Event.eventBus.fire(WsMsgEvent(dealMap, WsMsgState.transactionRecord));
    });
  }

  //  //  "委托挂单",
  //   //     "成交记录",
  //   //     "简介",
  //   //     "信息披露",
  //   //     "调仓信息",

  // KLineDisclosurePage(),KLineAdjustmentPage()
  void setTabBar(Map<String, dynamic> params) {
    if (params.containsKey("isContractKline")) {
      isContractKline.value = params['isContractKline'];
      if(!isContractKline.value) {
        mAnimation = Tween<double>(
          begin: 0.0,
          end: 130.0,
        ).animate(mAnimationController)
          ..addListener(() {
            print("mAnimation addListener>>> " + mAnimation.value.toString());
            indexDialogHeight.value = mAnimation.value;
          });
      }
    }
    if(params.containsKey("etfOpen")){
      if (params['etfOpen']) {
        if (isSymbolEtf.value == params['etfOpen']) {
          return;
        }
        isSymbolEtf.value = params['etfOpen'];
        isSymbolProfile.value = false;
        isNormalCoin.value = false;

        orderTypeTabListData.clear();
        orderTypeTabListPage.clear();

        orderTypeTabListData.add("kline_action_entrustMentOrder".tr);
        orderTypeTabListData.add("kline_action_dealHistory".tr);
        orderTypeTabListData.add("market_text_tab_etf_info".tr);
        orderTypeTabListData.add("market_text_tab_etf_rule".tr);

        orderTypeTabListPage.add(const KLineOrderBookPage());
        orderTypeTabListPage.add(const KLineTransactionRecordPage());
        orderTypeTabListPage.add(KLineDisclosurePage());
        orderTypeTabListPage.add(const KLineAdjustmentPage());

        orderTypeTabController = TabController(
            initialIndex: 0, length: orderTypeTabListData.length, vsync: this);
        orderTypePagerController.jumpToPage(0);

        orderTypeTabListData.refresh();
        orderTypeTabListPage.refresh();
      }
      return;
    }
    if(params.containsKey("symbol_profile")){
      if (params['symbol_profile']) {
        if (isSymbolProfile.value == params['symbol_profile']) {
          return;
        }
        isSymbolProfile.value = params['symbol_profile'];
        isSymbolEtf.value = false;
        isNormalCoin.value = false;

        orderTypeTabListData.clear();
        orderTypeTabListPage.clear();

        orderTypeTabListData.add("kline_action_entrustMentOrder".tr);
        orderTypeTabListData.add("kline_action_dealHistory".tr);
        orderTypeTabListData.add("market_text_coinInfo".tr);

        orderTypeTabListPage.add(const KLineOrderBookPage());
        orderTypeTabListPage.add(const KLineTransactionRecordPage());
        orderTypeTabListPage.add(KLineIntroductionPage());

        orderTypeTabController = TabController(
            initialIndex: 0, length: orderTypeTabListData.length, vsync: this);
        orderTypePagerController.jumpToPage(0);

        orderTypeTabListData.refresh();
        orderTypeTabListPage.refresh();
        return;
      }
    }
    if (isNormalCoin.value) {
      return;
    }
    isNormalCoin.value = true;
    isSymbolEtf.value = false;
    isSymbolProfile.value = false;

    orderTypeTabListData.clear();
    orderTypeTabListPage.clear();

    orderTypeTabListData.add("kline_action_entrustMentOrder".tr);
    orderTypeTabListData.add("kline_action_dealHistory".tr);

    orderTypeTabController = TabController(
        initialIndex: 0, length: orderTypeTabListData.length, vsync: this);
    orderTypePagerController.jumpToPage(0);

    orderTypeTabListPage.add(const KLineOrderBookPage());
    orderTypeTabListPage.add(const KLineTransactionRecordPage());

    orderTypeTabListData.refresh();

    // if(params['etfOpen']!=isSymbolEtf.value){
    //   isSymbolEtf.value= params['etfOpen'];
    //   if(isSymbolEtf.value){
    //     orderTypeTabListData.clear();
    //     orderTypeTabListData.add("kline_action_entrustMentOrder".tr);
    //     orderTypeTabListData.add("kline_action_dealHistory".tr);
    //     orderTypeTabListData.add("market_text_tab_etf_info".tr);
    //     orderTypeTabListData.add("market_text_tab_etf_rule".tr);
    //   }
    //   orderTypeTabController =TabController(initialIndex: 0,length: orderTypeTabListData.length, vsync: this);
    //   orderTypePagerController.jumpToPage(0);
    // }
    // if(params['symbol_profile']!=isSymbolProfile.value){
    //   isSymbolProfile.value= params['symbol_profile'];
    //   if(isSymbolProfile.value&& !isSymbolEtf.value){
    //     orderTypeTabListData.clear();
    //     orderTypeTabListData.add("kline_action_entrustMentOrder".tr);
    //     orderTypeTabListData.add("kline_action_dealHistory".tr);
    //     orderTypeTabListData.add("market_text_coinInfo".tr);
    //   }
    //   orderTypeTabController =TabController(initialIndex: 0,length: orderTypeTabListData.length, vsync: this);
    //   orderTypePagerController.jumpToPage(0);
    // }
    //
    // orderTypeTabListData.refresh();
  }

  void showDepthMap(DepthMapEntity mDepthMapEntity) {
    List<List>? asks = mDepthMapEntity.asks;
    askDatas.clear();
    List<DepthEntity> _bids = [],
        _asks = [];
    List<DepthEntity> __bids = [],
        __asks = [];
    asks?.forEach((v) {
      __asks.add(DepthEntity(
          double.parse(v[0].toString()), double.parse(v[2].toString())));
    });

    List<List>? buys = mDepthMapEntity.buys;
    bidDatas.clear();
    buys?.forEach((v) {
      __bids.add(DepthEntity(
          double.parse(v[0].toString()), double.parse(v[2].toString())));
    });
    if (__bids == null || __asks == null || __bids.isEmpty || __asks.isEmpty)
      return;
    _bids = [];
    _asks = [];
    double amount = 0.0;
    __bids.sort((left, right) => left.price.compareTo(right.price));
    //倒序循环 //累加买入委托量
    __bids.reversed.forEach((item) {
      _bids.insert(0, item);
    });

    amount = 0.0;
    __asks.sort((left, right) => left.price.compareTo(right.price));
    //循环 //累加买入委托量
    __asks.forEach((item) {
      _asks.add(item);
    });
    askDatas.value = _asks;
    bidDatas.value = _bids;
  }

  subTime2ShowTime(String value) {
    var showTime = "";
    switch (value) {
      case "line":
        showTime = "kline_Line".tr;
        break;
      case "1min":
        showTime = "kline_1min".tr;
        break;
      case "5min":
        showTime = "kline_5min".tr;
        break;
      case "15min":
        showTime = "kline_15min".tr;
        break;
      case "30min":
        showTime = "kline_30min".tr;
        break;
      case "60min":
        showTime = "kline_60min".tr;
        break;
      case "4h":
        showTime = "kline_4h".tr;
        break;
      case "1day":
        showTime = "kline_1day".tr;
        break;
      case "1week":
        showTime = "kline_1week".tr;
        break;
      case "1month":
        showTime = "kline_1month".tr;
        break;
    }
    return showTime;
  }

  void changeKlineHeight(Map<String, dynamic> messageMap) {
    VolState volState = messageMap["volState"] as VolState;
    int secondaryCount = messageMap["secondaryUIListCount"] as int;
    double chartHeight = mainChartHeight;
    // if (volState != VolState.NONE) {
    //   chartHeight += itemChartHeight;
    // }



    chartHeight += (secondaryCount * itemChartHeight);
    klineHeight.value = chartHeight;
  }

  void listenEvent() {
    addStremSub(Event.eventBus.on<MessageEvent>().listen((event) {
      if (event.msg_type == MessageEvent.klineIndexChange) {
        changeKlineHeight(event.msg_content);
      } else if (event.msg_type == MessageEvent.klineIndicatorUpdated) {
        // var klineW =  mKChartKey?.currentWidget as KChartWidget;
        DataUtil.calculate(klineDatas.value);
        // klineDatas.refresh();
        mKChartKey.currentState?.notifyChanged();
      } else if (event.msg_type == MessageEvent.nativeNotifitionEvent) {
        nativeMethods(event.msg_content);
      } else if (event.msg_type == MessageEvent.navigationChange) {
        secondGuideTimer?.cancel();
      }
    }));
    if (AppUtil.needSubWs) {
      addWsSub();
    }
  }

  void addWsSub() {
    addStremSub(Event.eventBus.on<WsEvent>().listen((event) {
      MarketTickerEntity quoteWs = event.quoteWs;
      if (quoteWs == null) {
        return;
      }
      if (quoteWs.tick != null) {
        if (quoteWs.channel.toString().contains("_ticker")) {
          var channelBuff = "market_${symbol}_ticker";
          if (channelBuff == quoteWs.channel) {
            show24HTicker(convert.jsonEncode(quoteWs));
          }
        }
        if (quoteWs.channel.toString().contains("_kline_")) {
          mSymbolPricePrecision.value = 2;
          // isLine.value=false;
          setNewKlineData(convert.jsonEncode(quoteWs));
        }
      }
      if (quoteWs.data != null) {
        //历史K线数据
        setKlinePageState(KlineState.CONTENT);
        mSymbolPricePrecision.value = 2;
        // isLine.value=false;
        setHistoryKlineData(convert.jsonEncode(quoteWs), false);
        stopTimer();
      }
    }));
    addStremSub(Event.eventBus.on<WsNetEvent>().listen((event) {
      if (event.state == WsNetEventState.connect) {
        subWsData();
      }
    }));
  }

  void switchOrderVisible(bool? visible) {
    // Routes.pushNvEvent(ev: NvEvent.kline_order_switch_visible,param: {
    //   "visible":visible
    // });
    isShowOrder.value = visible ?? false;
    mKChartKey.currentState?.setOrderShow(isShowOrder.value);
    ExStorageUtils.putObject(
        ExStorageUtils.KLINE_ORDER_VISIBLE_STATUS, isShowOrder.isTrue ? 1 : 0);
    Routes.pushNvEvent(ev: NvEvent.kline_detail_clickMainIndex, param: {
      ExStorageUtils.KLINE_ORDER_VISIBLE_STATUS: isShowOrder.isTrue ? 1 : 0
    });
  }

  void switchOrderDisplay(String text,bool visible) {
    if(text==orderDisplayTextList[0]) {
      switchOrderVisible(visible);
    }else if(text==orderDisplayTextList[1]) {
      ExStorageUtils.putObject(ExStorageUtils.KLINE_HOLD_COST_VISIBLE_STATUS, visible ? 1 : 0);
      Routes.pushNvEvent(ev: NvEvent.kline_detail_clickMainIndex, param: {
        ExStorageUtils.KLINE_HOLD_COST_VISIBLE_STATUS: visible ? 1 : 0
      });
      Routes.pushNvEvent(ev: NvEvent.kline_position_visible_event, param: {
        "visible": visible ? 1 : 0
      });
    }else if(text==orderDisplayTextList[2]){
      ExStorageUtils.putObject(ExStorageUtils.KLINE_HISTORICAL_COMMISSION_VISIBLE_STATUS, visible ? 1 : 0);
      Routes.pushNvEvent(ev: NvEvent.kline_detail_clickMainIndex, param: {
        ExStorageUtils.KLINE_HISTORICAL_COMMISSION_VISIBLE_STATUS: visible ? 1 : 0
      });
      Routes.pushNvEvent(ev: NvEvent.kline_entrust_visible_event, param: {
        "visible": visible ? 1 : 0
      });
    }
  }

  void nativeMethods(dynamic data) {
    if (data is Map) {
      String method = data["method"];
      dynamic arguments = data["arguments"];
      Map<String, dynamic> params = {};
      if(arguments!=null) {
        params = json.decode(arguments);
      }
      switch (method) {
        case "updateEntrust":
          List<dynamic> list = params["orderList"];
          List<EntrustOrder> dataList = list.map((e) => EntrustOrder.fromJson(e)).toList();
          entrustList.clear();
          entrustList.addAll(dataList);
          entrustList.sort((a,b) => int.parse(a.ctime!).compareTo(int.parse(b.ctime!)));
          entrustList.refresh();
          klineDatas.refresh();
          Future.delayed(const Duration(milliseconds: 300),(){
            mKChartKey.currentState?.notifyChanged();
          });
          break;
        case "updatePosition":
          List<dynamic> list = params["positionList"];
          List<PositionOrder> dataList = list.map((e) => PositionOrder.fromJson(e)).toList();
          positionList.clear();
          positionList.addAll(dataList);
          positionList.refresh();
          klineDatas.refresh();
          Future.delayed(const Duration(milliseconds: 300),(){
            mKChartKey.currentState?.notifyChanged();
          });
          break;
        case "initRefresh":
          isInitRefresh = true;
          break;
        case "clearDealHistory":
          Event.eventBus.fire(WsMsgEvent(params, WsMsgState.clearTransactionRecord));
          break;
        case "changeKlineState":
          String type = params["type"];
          final state = KlineState.getStateByType(type);
          if (state != KlineState.unknow) {
            KlinePageState.value = state;
          }
          break;
        case "router":
          String destion = params["routerName"];
          // Get.toNamed(destion);
          Get.offNamed(destion);
          // Get.offAll(destion);
          break;

        case "setIndexSelectEvent":
          String secondaryUIListStr =
          params["secondaryUIList"]; //json string "MACD,RSI"
          String mainUIListStr = params["mainUIList"]; //json string "MA,EMA"
          VolState volState =
          params["volState"] == 0 ? VolState.NONE : VolState.VOL; //int
          mKChartKey.currentState?.saveNativeSelectIndexToStorage(
              mainUIListStr, secondaryUIListStr, volState);
          changeKlineHeight({
            "secondaryUIListCount": secondaryUIListStr
                .split(",")
                .length,
            "volState": volState
          });
          break;
        case "setNewKlineData":
          mSymbolPricePrecision.value = params["mSymbolPricePrecision"];
          isLine.value = params["isLine"];
          setNewKlineData(params["mKlineData"]);
          break;
        case "setHistoryKlineData":
          print("get History Kline Data>>>");
          setKlinePageState(KlineState.CONTENT);
          mSymbolPricePrecision.value = params["mSymbolPricePrecision"];
          isLine.value = params["isLine"];
          setHistoryKlineData(params["mKlineData"], params["isMore"]);
          stopTimer();
          break;
        case "setKlineMainState":
          klineMainCurState.value = MainState.values[params['MainStateIndex']];
          break;
        case "setKlineSecondaryState":
          klineSubCurState.value =
          SecondaryState.values[params['SubStateIndex']];
          break;
        case "setKlineVolState":
          klineVolCurState.value = VolState.values[params['VolStateIndex']];
          break;
        case "setKlineBuySellData":
          KlineBuySellListEntity mKlineBuySellList =
          KlineBuySellListEntity.fromJson(params);
          klineBuySellDatas = mKlineBuySellList.klineBuySellData ?? [];
          syncKlineBuySellData();
          break;
        case "setKlineOrderShow":
          isShowOrder.value = params['isShowKlineOrder'];
          print("isShowOrder.value${isShowOrder.value}");
          mKChartKey.currentState?.setOrderShow(isShowOrder.value);
          break;
        case "setKlineState":
          setKlinePageState(KlineState.values[params['KlineStateIndex']]);
          break;
        case "setKlineBgColor":
          klineBgColor.value = params['KlineBgColor'];
          break;
        case "setCoinInfo":
          coinInfoMap = params;
          if (params.containsKey('leverMultiple')){
            leverMultiple.value = params['leverMultiple'];
          }
          if (params.containsKey('klineType')){
            klineType = params['klineType'];
          }
          if (params.containsKey('openTime')&&klineType==0){
            openTime.value = params['openTime'];
            startOpenTimer();
            if(openTime.value==0){
              isOpen.value=false;
            }
          }else{
            isOpen.value=false;
          }

          if (params.containsKey('coinName')){
            mCoinName.value = params['coinName'];
          }
          if (params.containsKey('mSymbolPricePrecision')){
            mSymbolPricePrecision.value = params['mSymbolPricePrecision'];
            KLineCoinInfo.mSymbolPricePrecision = params['mSymbolPricePrecision'];
          }
          if (params.containsKey("mSymbolAmountPrecision")) {
            mSymbolAmountPrecision.value = params["mSymbolAmountPrecision"];
          }
          if (params.containsKey('FundRate')){
            mFundRate.value = params['FundRate'];
          }
          if (params.containsKey('isCollect')){
            isCollect.value = params['isCollect'];
          }
          if (params.containsKey('mklineScale')){
            klineTimeCurScale.value = params['mklineScale'];
          }
          if (params.containsKey('mAmountUnit')){
            mQuantityUnit.value = params['mAmountUnit'];
          }
          if (params.containsKey('mPriceUnit')){
            mPriceUnit.value = params['mPriceUnit'];
          }
          if (params.containsKey('etfRisk')){
            etfRisk.value = params['etfRisk'];
          }
          if (params.containsKey('mCurrencyUnit')){
            mCurrencyUnit.value = params['mCurrencyUnit'];
          }
          if (params.containsKey('mCurrencyRates')){
            mCurrencyRates.value = params['mCurrencyRates'];
          }
          if (params.containsKey('mCurrencyPrecision')){
             mCurrencyPrecision = params['mCurrencyPrecision'];
          }
          if (params.containsKey('marketTag')){
            marketTag.value = params['marketTag'];
          }
          if (params.containsKey('isCoin')){
            KLineCoinInfo.isCoin = params["isCoin"];
          }

          if (params.containsKey('mMultiplier')){
            KLineCoinInfo.mMultiplier = params["mMultiplier"];
          }
          if (params.containsKey('marginCoinPrecision')){
            KLineCoinInfo.marginCoinPrecision = params["marginCoinPrecision"];
          }
          if (params.containsKey('coinJson')){
            String coinJsonStr = params["coinJson"];
            Map<String, dynamic> result = convert.jsonDecode(coinJsonStr);
            CoinJsonEntity mCoinJsonEntity = CoinJsonEntity.fromJson(result);
            mHighlightStr.clear();
            mHighlightStr.add((mCoinJsonEntity.etfBase??"")+(mCoinJsonEntity.etfMultiple??"")+(mCoinJsonEntity.etfSide??""));
            mHighlightStr.add((mCoinJsonEntity.etfBase??""));
            mHighlightStr.add("etf_notes_multipleL".trParams({"number": mCoinJsonEntity.etfMultiple??""}));
            mHighlightStr.add("etf_notes_multipleS".trParams({"number": mCoinJsonEntity.etfMultiple??""}));
          }
          Event.eventBus.fire(WsMsgEvent(params, WsMsgState.coinInfo));
          setTabBar(params);
          break;
        case "set24HTickerData":
          show24HTicker(params['mTickerData']);
          break;
        case "setOrderBookData":
          Event.eventBus.fire(WsMsgEvent(params, WsMsgState.orderBook));
          break;
        case "setTransactionRecordData":
          bool isHistory = params["isHistory"];
          if (isHistory) dealMap = params;
          Event.eventBus.fire(WsMsgEvent(params, WsMsgState.transactionRecord));
          break;
        case "setCoinIntroData":
          Event.eventBus.fire(WsMsgEvent(params, WsMsgState.coinIntroData));
          break;
        case "setCoinETFData":
          Event.eventBus.fire(WsMsgEvent(params, WsMsgState.ETFIntroData));
          Map<String, dynamic> result =
          convert.jsonDecode(params['mCoinETFData']);
          mNetValue.value = EtfNetValueEntity
              .fromJson(result)
              .price ?? "--";
          break;
        case "setCoinETFRuleData":
          Event.eventBus.fire(WsMsgEvent(params, WsMsgState.ETFRuleData));
          break;
        case "setDepthMapData":
          Map<String, dynamic> result =
          convert.jsonDecode(params['mDepthMapData']);
          DepthMapEntity mDepthMapEntity = DepthMapEntity.fromJson(result);
          showDepthMap(mDepthMapEntity);
          break;
        case "updatePriceInfo":
          print("updatePriceInfo>>>" + params.toString());
          mMarkPrice.value =
              params["markPrice"]!=null&&params["markPrice"]!="" ?
              DecimalUtils.showSNormal(params["markPrice"], digits: mSymbolPricePrecision.value, isShowThous: true)
              : "--";
          mFundRate.value = params["fundRate"] ?? "--";
          break;
        case "updateWaterLogoPath":
          // waterLogoPath.value = params["waterLogoPath"];
          // mKChartKey.currentState?.setWaterLogoPath(params["waterLogoPath"]);
          break;
        case "nativeClickKTimeChange":
          print("nativeClickKTimeChange>>>$params");
          mKChartKey.currentState?.isLongPress = false;
          var scale = params["scale"];
          if ("line" == scale) {
            klineTimeCurScale.value = "1min";
            isLine.value = true;
          } else {
            klineTimeCurScale.value = scale;
          }
          ExStorageUtils.setKlineTimeScale(scale);
          break;
        case "updateMainIndexVisible":
        // print("nativeMethods>>>void updateMainIndexVisible");
          var mainIndexCacheMap = params;
          var iterator = mainIndexCacheMap.entries.iterator;
          while (iterator.moveNext()) {
            var entry = iterator.current;
            ExStorageUtils.putObject(entry.key, entry.value);
          }
          // var mainUIStr = ExStorageUtils.getString(
          //     ExStorageUtils.KLINE_MAIN_INDICATOS_SELECT_LIST);
          mKChartKey.currentState?.initKlineConf(isFirstGuide: false);
          mKChartKey.currentState?.notifyChanged();
          break;
        case "resetConfig":
          scrollViewControl.jumpTo(0.0);
          orderTypeTabController.index = 0;
          switchPageView(0);
          break;
        // case "updateConfig":
        //   updateAppconfig(params);
        //   break;
      }
    }
  }

  void coinChangeClearLastData(){
     //最高价,最低价
      high24Price.value = "0";
      low24Price.value = "0";
      amount24.value = "0";
      vol24.value = "0";
      mMarkPrice.value = "0";
      mFundRate.value = "0";
      latestLegalPrice.value = "0";
      latestPrice.value = "0";
      latestRose.value = "0";
      bidDatas.clear();
      askDatas.clear();
  }
  void startOpenTimer() {
    _OpenTimer?.cancel();
    if(openTime.value>0){
      DateTime openDateTime = DateTime.fromMillisecondsSinceEpoch(openTime.value);
      DateTime now = DateTime.now();
      isOpen.value=now.isBefore(openDateTime);
      calculateTimeDifference(openTime.value);
      _OpenTimer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
        calculateTimeDifference(openTime.value);
      });
    }else{
      isOpen.value=true;
    }
  }


  void calculateTimeDifference(int timestamp) {
    DateTime now = DateTime.now();
    DateTime targetTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    Duration difference = targetTime.difference(now);
    if(difference.isNegative){
      _OpenTimer?.cancel();
      isOpen.value=false;
    }
    timeDifference.value=difference;
  }

  // //更新语言 / 涨跌色 /皮肤
  // void updateAppconfig(Map<String, dynamic> params) {
  //   print("parse json: ${params}");
  //   if (params.containsKey("lan")) {
  //     final old = ExStorageUtils.getObject(ExStorageUtils.LAN);
  //     final newLan = params["lan"];
  //     if (old != newLan) {
  //       ExStorageUtils.putObject(ExStorageUtils.LAN, params["lan"]);
  //       final locale = TranslationService.locale;
  //       Get.updateLocale(locale!);
  //       Get.appUpdate();
  //       AppConstant.isZh = params["lan"].toString().contains("zh");
  //       orderTypeTabListData.value = [
  //         "kline_action_entrustMentOrder".tr,
  //         "kline_action_dealHistory".tr
  //       ];
  //       orderTypeTabListData.refresh();
  //
  //       klineMoreTimeData.clear();
  //       klineTimeData.clear();
  //       for (var i = 0; i < klineTimeList.length; i++) {
  //         var element = klineTimeList[i];
  //         klineTimeData.add(KlineTimeEntity(
  //             id: i,
  //             showTime: subTime2ShowTime(element),
  //             subTime: element,
  //             isLine: (element == "line" || element == "Line")));
  //       }
  //       klineMoreTimeData.clear();
  //       klineMoreTimeData.addAll(klineTimeData);
  //       klineMoreTimeData.refresh();
  //       changeShowKlineTimeVisible();
  //       klineDefaultTimeData.refresh();
  //       changeMoreOtherKlineTime();
  //       showKlineMoreTimeOtherData.refresh();
  //     }
  //   }
    // if (params.containsKey("theme")) {
    //   final theme = params["theme"];
    //   final old = ExStorageUtils.getObject(ExStorageUtils.THEME);
    //   if (theme != old){
    //     if (theme == "dark"){
    //       Get.changeTheme(ExThemes.darkTheme);
    //     }else{
    //       Get.changeTheme(ExThemes.lightTheme);
    //     }
    //     ExStorageUtils.putObject(ExStorageUtils.THEME, params["theme"]);
    //     rebuild.value+=1;
    //     rebuild.refresh();
    //   }
    // }

    // if (params.containsKey("riseFallTrend")) {
    //   final riseFallTrend = params["riseFallTrend"];
    //   final old = ExStorageUtils.getObject(ExStorageUtils.RISE_FALL_COLOR);
    //   if (riseFallTrend != old) {
    //     ExStorageUtils.putObject(ExStorageUtils.RISE_FALL_COLOR, riseFallTrend);
    //     KlineConstant.COLOR_TYPE =
    //     riseFallTrend == 1 || riseFallTrend == "1" ? 1 : 0;
    //     rebuild.value += 1;
    //     rebuild.refresh();
    //   }
    // }


    // Navigator.pushReplacement(
    //   moreTimeCtrlKey.currentContext!,
    //   MaterialPageRoute(builder: (context) => KLineDetailPage()),
    // );
  // }

  void subWsData() {
    SocketUtils().subKlineHistory(symbol, getKlineTimeScale());
    SocketUtils().subKlineLast(symbol, getKlineTimeScale());
    SocketUtils().sub24HTicker(symbol);
    SocketUtils().subTradeTicker(symbol);
    SocketUtils().subTradeDepth(symbol, 0);
  }
}
