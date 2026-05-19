import 'package:chainup_flutter_ex/ext/datetime_ext.dart';
import 'package:chainup_flutter_ex/page/common/task_center_common.dart';
import 'package:chainup_flutter_ex/utils/decimal_utils.dart';
import 'package:chainup_flutter_ex/widgets/ex_loading_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:library_kline/utils/storage_utils.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../base/controller/base_controller.dart';
import '../../../models/bottom_sheet_entity.dart';
import '../../../models/market_coin_entity.dart';
import '../../../models/query_profit_and_loss_entity.dart';
import '../../../models/user_asset_profit_loss_data_lever_entity.dart';
import '../../../net/http/apiservice/exchange_api.dart';
import '../../../net/http/request_params.dart';
import '../../../net/http/result/base_result_vx.dart';
import '../../../routes/routes.dart';
import '../../../utils/date_utils.dart';
import '../util/breakeven_analysis_util.dart';

class MarginTradeBreakevenAnalysisTabController
    extends BaseController<ExchangeApi> {
  final String? type; //3全仓  2逐仓
  final RefreshController refreshController = RefreshController();
  final ScrollController scrollController = ScrollController();

  MarginTradeBreakevenAnalysisTabController(this.type);
  List<BottomSheetEntity> tabData = [];
  var userAssetProfitLossDataLeverList =
      <UserAssetProfitLossDataLeverEntity>[].obs;
  var listViewData = <UserAssetProfitLossDataLeverEntity>[].obs;
  late DateTime _startDateTime;
  late DateTime _endDateTime;

  DateTime? _customEndDateTime;
  DateTime? _customStartDateTime;

  var currentDateIndex = 0.obs;

  var lastDateIndex = 0.obs;

  int page = 0;
  bool isLoadMore = false;
  var currentCoin = "BTC".obs; //默认BTC
  var isEmpty = false.obs;
  var isLoad = true.obs;
  var chartBottomTitles = ["", "", "", ""].obs;
  var chartLeftTitles = <String>[].obs;
  var chartRightTitles = <double>[].obs;
  List<String> chartLeftBTCTitles = [];
  List<String> chartLeftUSDTTitles = [];
  var bottomDateList = <String>[].obs; //所选所有日期集合
  var isShowCustomDateBtn = true.obs;

  var profitNum = "0.00".obs;
  var profitRatio = "0.00".obs;
  var profitTime = "".obs;
  RxBool needTransformToBTC = false.obs;
  // USDT转BTC汇率
  late String usdtToBTCrate;

  /// BTC的小数精度
  var btcPrecision = 8.obs;

  ///usdt的小数精度
  final int usdtPrecision = 2;

  late String btcProfitAndLoss; //以btc为单位的盈亏 ,暂定8位精度
  late String usdtProfitAndLoss; //以USDT为单位的盈亏
  ///币种精度等信息
  Map? _coinData;

  var loadStatus = ExLoadingStatus.idle.obs;

  var showAmount = true.obs;

  @override
  void onInit() {
    super.onInit();
    tabData.add(BottomSheetEntity(
        showName: "breakeven_analysis_text2".tr, extrasStr: "-1")); //7日
    tabData.add(BottomSheetEntity(
        showName: "breakeven_analysis_text3".tr, extrasStr: "1")); //30日
    tabData.add(BottomSheetEntity(
        showName: "breakeven_analysis_text4".tr, extrasStr: "0")); //自定义
    _startDateTime =
        EXDateUtils.getSomeDay(DateTime.now(), 6).transformToUtc8(); //默认最近7天

    _endDateTime = EXDateUtils.getUtc8TimeNow();
    needTransformToBTC.value = currentCoin.value == "BTC";

    String type =
        ExStorageUtils.getString(ExStorageUtils.SHOW_OR_HIDE_ASSETS_AMOUNT);
    if (type.isNotEmpty) {
      showAmount.value = type == "1"; //“1” 展示 “0” 隐藏
    } else {
      Map? arguments = Get.arguments;
      if (arguments != null &&
          arguments[ExStorageUtils.SHOW_OR_HIDE_ASSETS_AMOUNT] != null) {
        String type =
            arguments[ExStorageUtils.SHOW_OR_HIDE_ASSETS_AMOUNT].toString();
        showAmount.value = type == "1"; //“1” 展示 “0” 隐藏
      } else {
        showAmount.value = true;
      }
    }
  }

  @override
  void onReady() {
    super.onReady();
    loadNet();
  }

  @override
  void loadNet() {
    bool isLogin = ExStorageUtils.getString(ExStorageUtils.TOKEN).isNotEmpty;
    if (!isLogin) {
      Routes.pushNvEvent(ev: NvEvent.login);
      return;
    }
    loadStatus.value = ExLoadingStatus.loading;
    getData();
  }

  @override
  void onClose() {
    refreshController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  void onRefreshData() {
    page = 0;
    getData();
  }

  void loadMore() {
    getData();
  }

  void getData() {
    Map? coinRateData =
        ExStorageUtils.getObject(ExStorageUtils.LOCAL_ASSET_CONVERT_SYMBOL_RATE)
            as Map?;
    if (coinRateData != null) {
      ///先取一次缓存数据，防止汇率接口异常
      usdtToBTCrate = getRate(coinRateData); //汇率
      btcPrecision.value = getPrecision(coinRateData) < 8 //产品需求文档要求BTC8位精度
          ? 8
          : getPrecision(coinRateData); //精度
    }

    getAppPublicInfoMarket();
    getCanCustomDate();

    _handleLineChartBottomTitleData(_startDateTime, _endDateTime);

    var requestBody2 = RequestParams();
    requestBody2.put("leverType", type.toString());
    requestBody2.put(
        "endDate", BreakevenAnalysisUtil.getCurrentDate(_endDateTime));
    requestBody2.put(
        "beginDate", BreakevenAnalysisUtil.getCurrentDate(_startDateTime));

    multiHttpRequest(
      [
        api.getAssetConvertSymbolRate(RequestParams().getRequestBody()),
        api.profitAndLossAnalysis(requestBody2.getRequestBody()),
      ],
      (value) {
        loadStatus.value = ExLoadingStatus.success;
        refreshController.refreshCompleted();
        isLoad.value = false;

        if (value != null && value is List && value.isNotEmpty) {
          if (value[0] != null) {
            Map coinRateData = value[0].data;
            ExStorageUtils.putObject(
                ExStorageUtils.LOCAL_ASSET_CONVERT_SYMBOL_RATE, coinRateData);
            usdtToBTCrate = getRate(coinRateData); //汇率
            btcPrecision.value =
                getPrecision(coinRateData) < 8 //产品需求文档要求BTC8位精度
                    ? 8
                    : getPrecision(coinRateData); //精度
          }

          if (value[1] != null) {
            handleProfitAndLossAnalysis(value);
          }
        }
      },
      error: (e) {
        isLoad.value = false;
        refreshController.refreshCompleted();
        loadStatus.value = ExLoadingStatus.failed;
      },
    );
  }

/**
 * 折线和列表数据
 */
  void handleProfitAndLossAnalysis(dynamic value) {
    UserAssetProfitLossDataListEntity? entity = value[1].data;
    if (entity != null && entity.userAssetProfitLossDataLeverList != null) {
      List<UserAssetProfitLossDataLeverEntity> tempList =
          entity.userAssetProfitLossDataLeverList ?? [];
      chartLeftBTCTitles = [];
      chartLeftUSDTTitles = [];
      chartRightTitles.value = [];

      int length = EXDateUtils.calculateDays(_startDateTime, _endDateTime) - 1;

      if (tempList.isEmpty) {
        if (!isLoadMore) {
          for (var i = 0; i < length; i++) {
            ///数据为空时便于折线图展示
            chartLeftBTCTitles.add("0.0");
            chartLeftUSDTTitles.add("0.0");
            chartRightTitles.add(0.0);
          }
          chartLeftTitles.value = chartLeftBTCTitles;

          refreshController.refreshCompleted();
          isEmpty.value = true;
        } else {
          refreshController.loadComplete();
        }
      } else {
        for (UserAssetProfitLossDataLeverEntity entity in tempList) {
          entity.cumulativeProfitRatio =
              (entity.cumulativeProfitRatio ?? 0) * 100; //百分比先乘以100
          entity.curProfitBTC = DecimalUtils.showSMultiply(
            entity.curProfit,
            usdtToBTCrate,
            digits: btcPrecision.value,
          );
          entity.cumulativeProfitBTC = DecimalUtils.showSMultiply(
              entity.cumulativeProfit, usdtToBTCrate,
              digits: btcPrecision.value);
          entity.pureComeBTC = DecimalUtils.showSMultiply(
              entity.pureCome, usdtToBTCrate,
              digits: btcPrecision.value);
          entity.accountEquityBTC = DecimalUtils.showSMultiply(
              entity.accountEquity, usdtToBTCrate,
              digits: btcPrecision.value);

          ///btc精度为8位；
          entity.curProfitBTC =
              TaskCenterCommon.truncateToSpecifiedDecimalPlaces(
                  entity.curProfitBTC, btcPrecision.value,
                  needAddZero: true);

          ///usdt精度为2位；
          entity.curProfitUSDT =
              TaskCenterCommon.truncateToSpecifiedDecimalPlaces(
                  entity.curProfit, usdtPrecision,
                  needAddZero: true);

          entity.cumulativeProfitBTC =
              TaskCenterCommon.truncateToSpecifiedDecimalPlaces(
                  entity.cumulativeProfitBTC, btcPrecision.value,
                  needAddZero: true);

          entity.cumulativeProfitUSDT =
              TaskCenterCommon.truncateToSpecifiedDecimalPlaces(
                  entity.cumulativeProfit, usdtPrecision,
                  needAddZero: true);

          entity.pureComeBTC =
              TaskCenterCommon.truncateToSpecifiedDecimalPlaces(
                  entity.pureComeBTC, btcPrecision.value,
                  needAddZero: true);
          entity.pureComeUSDT =
              TaskCenterCommon.truncateToSpecifiedDecimalPlaces(
                  entity.pureCome, usdtPrecision,
                  needAddZero: true);

          entity.accountEquityBTC =
              TaskCenterCommon.truncateToSpecifiedDecimalPlaces(
                  entity.accountEquityBTC, btcPrecision.value,
                  needAddZero: true);
          entity.accountEquityUSDT =
              TaskCenterCommon.truncateToSpecifiedDecimalPlaces(
                  entity.accountEquity, usdtPrecision,
                  needAddZero: true);

          chartLeftBTCTitles.add(entity.cumulativeProfitBTC ?? "0");
          chartLeftUSDTTitles.add(entity.cumulativeProfitUSDT ?? "0");
          chartRightTitles.add(entity.cumulativeProfitRatio ?? 0);
        }

        ///将数据进行排序
        // bubbleSort(chartLeftBTCTitles);
        // bubbleSort(chartLeftUSDTTitles);
        // bubbleSort(chartRightTitles);

        chartLeftTitles.value =
            needTransformToBTC.value ? chartLeftBTCTitles : chartLeftUSDTTitles;
        userAssetProfitLossDataLeverList.value = tempList;
        listViewData.value = tempList.reversed.toList();
        handleTotalProfitData(userAssetProfitLossDataLeverList.last);

        DateTime tempStart = DateTime.fromMillisecondsSinceEpoch(
            userAssetProfitLossDataLeverList.first.curDate!);
        DateTime tempEnd = DateTime.fromMillisecondsSinceEpoch(
            userAssetProfitLossDataLeverList.last.curDate!);

        _handleLineChartBottomTitleData(tempStart, tempEnd);

        isEmpty.value = false;
        refreshController.loadComplete();
        page = page + 1;
      }
    } else {
      refreshController.loadFailed();
    }
  }

  void handleTotalProfitData(
      UserAssetProfitLossDataLeverEntity assetProfitLossDataLeverEntity) {
    btcProfitAndLoss = assetProfitLossDataLeverEntity.cumulativeProfitBTC!;
    usdtProfitAndLoss = assetProfitLossDataLeverEntity.cumulativeProfitUSDT!;

    profitNum.value =
        needTransformToBTC.value ? btcProfitAndLoss : usdtProfitAndLoss;

    profitRatio.value = TaskCenterCommon.truncateToSpecifiedDecimalPlaces(
        assetProfitLossDataLeverEntity.cumulativeProfitRatio, 2,
        needAddZero: true);

    if (assetProfitLossDataLeverEntity.curDateStr != null) {
      profitTime.value = assetProfitLossDataLeverEntity.curDateStr!;
    } else {
      profitTime.value = EXDateUtils.formateDateTimeToString(
          EXDateUtils.getUtc8TimeNow(),
          format: "yyyy-MM-dd");
    }
  }

  void getCanCustomDate() {
    var requestBody = RequestParams();

    httpRequest<BaseResultVx>(
        api.getCanCustomDate(requestBody.getRequestBody()), (value) {
      Map data = value.data ?? {};
      if (data["res"] != null && data["res"] is bool) {
        isShowCustomDateBtn.value = data["res"];
      }
    });
  }

  void getAppPublicInfoMarket() {
    var requestBody = RequestParams();
    httpRequest<BaseResultVx<MarketCoinInfo>>(
        api.getAppPublicInfoMarket(requestBody.getRequestBody()), (value) {
      MarketCoinInfo data = value.data!;
      _coinData = data.coinList;
    });
  }

  void bubbleSort(List<double> arr) {
    int n = arr.length;
    for (int i = 0; i < n - 1; i++) {
      for (int j = 0; j < n - i - 1; j++) {
        if (arr[j] > arr[j + 1]) {
          // 交换 arr[j] 和 arr[j + 1]
          double temp = arr[j];
          arr[j] = arr[j + 1];
          arr[j + 1] = temp;
        }
      }
    }
  }

  ///获取小数精度长度
  int getPrecision(Map data) {
    int showPrecision = 2;
    List convertSymbolList = data["convertSymbolList"] ?? [];
    for (var i = 0; i < convertSymbolList.length; i++) {
      Map temp = convertSymbolList[i];
      if (temp["coinSymbol"] == "BTC") {
        showPrecision = temp["showPrecision"];
      }
    }
    return showPrecision;
  }

  String getRate(Map data) {
    String rate = "1.0";
    Map convertRate = data["convertRate"] ?? {};
    Map btcRateData = convertRate["USDT"] ?? {};
    rate = btcRateData["BTC"] ?? "1.0";
    return rate.toString();
  }

  void selectedCoin(String selectedCoin) {
    currentCoin.value = selectedCoin;
    needTransformToBTC.value = currentCoin.value == "BTC";
    profitNum.value =
        needTransformToBTC.value ? btcProfitAndLoss : usdtProfitAndLoss;

    chartLeftTitles.value =
        needTransformToBTC.value ? chartLeftBTCTitles : chartLeftUSDTTitles;
  }

  void accordCustomDateGetData(DateTime starTime, DateTime endTime) {
    _startDateTime = starTime;
    _endDateTime = endTime;
    _customStartDateTime = _startDateTime;
    _customEndDateTime = _endDateTime;
    // getProfitAndLossAnalysis(_startDateTime, _endDateTime);
    getData();
  }

  void updateCurrentTabIndex(int index) {
    lastDateIndex.value = currentDateIndex.value;
    if (index < 2) {
      lastDateIndex.value = currentDateIndex.value;
    }
    currentDateIndex.value = index;
    _endDateTime = EXDateUtils.getUtc8TimeNow();
    if (index == 0) {
      //近7天
      _startDateTime =
          EXDateUtils.getSomeDay(DateTime.now(), 6).transformToUtc8();
    }
    if (index == 1) {
      //近30天
      _startDateTime =
          EXDateUtils.getSomeDay(DateTime.now(), 29).transformToUtc8();
    }

    if (index < 2) {
      // getspecifiedProfitAndLossAnalysis(currentIndex);
      getData();
    }
  }

  void cancelSelectTIme() {
    currentDateIndex.value = lastDateIndex.value;
    getData();
  }

  void _handleLineChartBottomTitleData(DateTime startTime, DateTime endDate) {
    int difference = endDate.difference(startTime).inDays;
    int length = difference + 1 > 4 ? 4 : difference + 1;
    List<DateTime> list =
        EXDateUtils.getEquallySpacedDatePoints(startTime, endDate, length);
    List<String> timeStrList = [];
    for (int i = 0; i < list.length; i++) {
      DateTime dateTime = list[i];
      String timeStr =
          EXDateUtils.formateDateTimeToString(dateTime, format: "MM/dd");
      timeStrList.add(timeStr);
    }
    bottomDateList.value = EXDateUtils.getDatesBetween(startTime, endDate);
    chartBottomTitles.value = timeStrList;
  }

  void changeShowAmountStatus() {
    showAmount.value = !showAmount.value;
    Routes.pushNvEvent(ev: NvEvent.showOrHideAssetsAmountEvent, param: {
      "showOrHideAssetsAmount": showAmount.value ? "1" : "0",
      "pageType": "2"
    });
  }
}
