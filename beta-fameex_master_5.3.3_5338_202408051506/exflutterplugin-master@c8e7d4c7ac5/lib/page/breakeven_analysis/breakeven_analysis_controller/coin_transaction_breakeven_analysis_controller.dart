import 'dart:convert';

import 'package:chainup_flutter_ex/base/controller/base_controller.dart';
import 'package:chainup_flutter_ex/event/event.dart';
import 'package:chainup_flutter_ex/ext/datetime_ext.dart';
import 'package:chainup_flutter_ex/models/daily_income_chart_data_entity.dart';
import 'package:chainup_flutter_ex/models/market_coin_entity.dart';
import 'package:chainup_flutter_ex/net/http/apiservice/exchange_api.dart';
import 'package:chainup_flutter_ex/net/http/request_params.dart';
import 'package:chainup_flutter_ex/utils/decimal_utils.dart';
import 'package:chainup_flutter_ex/widgets/ex_loading_view.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:library_kline/utils/storage_utils.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../models/account_balance_entity.dart';
import '../../../models/bottom_sheet_entity.dart';
import '../../../models/chart_data_entity.dart';
import '../../../models/coin_assets_chart_data_entity.dart';
import '../../../models/coin_assets_location_entity.dart';
import '../../../models/cumulative_income_chart_date_entity.dart';
import '../../../models/cumulative_profit_ratio_chart_data_entity.dart';
import '../../../models/query_profit_and_loss_entity.dart';
import '../../../net/http/result/base_result_vx.dart';
import '../../../routes/routes.dart';
import '../../../utils/date_utils.dart';
import '../../../utils/decimal.dart';
import '../../common/task_center_common.dart';
import '../util/breakeven_analysis_util.dart';

class CoinTransactionBreakevenAnalysisController
    extends BaseController<ExchangeApi> {
  final RefreshController refreshController = RefreshController();
  final ScrollController scrollController = ScrollController();
  List<BottomSheetEntity> tabData = [];
  var currentSelectTab = 0.obs;

  var loadStatus = ExLoadingStatus.idle.obs;

  late DateTime _startDateTime;

  late DateTime _endDateTime;

  DateTime? _customEndDateTime;
  DateTime? _customStartDateTime;
  var lastDateIndex = 0.obs;

  var currentDateIndex = 0.obs;
  var defaultCoin = "BTC".obs;
  var showCoinName = "".obs;
  var mCurrencyCoin = "".obs; //法币符号

  late DateTime _sevenDateTime;
  late DateTime _thirtyDateTime;
  var isLoad = true.obs;
  var currentDayProfitNum = 0.00.obs;
  var sevenDayProfitNum = 0.00.obs;
  var thirtyDayProfitNum = 0.00.obs;
  var currentDayProfitEntity = SingleCoinAssetsChartEntity().obs;
  var sevenDayProfitEntity = SingleCoinAssetsChartEntity().obs;
  var thirtyDayProfitEntity = SingleCoinAssetsChartEntity().obs;
  var isShowCustomDateBtn = false.obs;
  var accountBalanceEntity = AccountBalanceEntity().obs;
  var profitAndLossDataResListEntity = ProfitAndLossDataResListEntity().obs;
  var coinAssetsLocationEntity = CoinAssetsLocationEntity().obs;
  var chartBottomTitles = ["", "", "", ""].obs;
  var bottomDateList = <String>[].obs; //所选所有日期集合
  var chartEntityList = <CoinAssetsChartDataEntity>[].obs;

  // btc转外部传的币种汇率
  late String btcToDefaultCoinRate;
  late int btcToDefaultCoinPrecision;

  ///Btc转法币的汇率，精度
  var mBtcCurrencyRates = "6.5";
  var mBtcCurrencyPrecision = 4;

  ///Usdt转法币的汇率，精度
  var mUsdtCurrencyRates = "6.5";
  var mUsdtCurrencyPrecision = 2;

  var legalCoinAmount = "0.00".obs; //转成法币的数量

  var showAmount = true.obs;

  var totalAssetsList = <TotalAssetsChartDataEntity>[].obs; //资产总值集合
  var cumulativeReturnRateList =
      <CumulativeProfitRatioChartDataEntity>[].obs; //累积收益率
  var dailyProfitList = <DailyIncomeChartDataEntity>[].obs; //每日收益集合
  var cumulativeReturnList = <CumulativeIncomeChartDataEntity>[].obs; //累积收益
  var bottomTagIndexList = <int>[0, 2, 4, 6].obs;

  ///资产总值
  var totalAssets = "0.00".obs;

  ///累积盈亏率
  var cumulativeProfitAndLossRatio = "0.00".obs;

  ///累积btc趋势
  var btcCumulativeRate = "0.00".obs;

  ///每日收益
  var dailyIncome = "0.00".obs;

  ///累积收益
  var cumulativeIncome = "0.00".obs;

  var isEmpty = false.obs;

  var minAssetBalance = 0.0.obs;

  var minAssetY = 0.0.obs;
  var maxAssetY = 10.0.obs;

  var marketCoinInfo = MarketCoinInfo().obs;

  @override
  void onInit() {
    super.onInit();
    Map? arguments = Get.arguments;
    String type =
        ExStorageUtils.getString(ExStorageUtils.SHOW_OR_HIDE_ASSETS_AMOUNT);
    if (type.isNotEmpty) {
      showAmount.value = type == "1"; //“1” 展示 “0” 隐藏
    } else {
      if (arguments != null &&
          arguments[ExStorageUtils.SHOW_OR_HIDE_ASSETS_AMOUNT] != null) {
        String type =
            arguments[ExStorageUtils.SHOW_OR_HIDE_ASSETS_AMOUNT].toString();
        showAmount.value = type == "1"; //“1” 展示 “0” 隐藏
      } else {
        showAmount.value = true;
      }
    }

    String coin =
        ExStorageUtils.getString(ExStorageUtils.COIN_ANALYSIS_COIN_SYMBOLS);
    if (coin.isEmpty) {
      if (arguments != null &&
          arguments[ExStorageUtils.COIN_ANALYSIS_COIN_SYMBOLS] != null) {
        defaultCoin.value =
            arguments[ExStorageUtils.COIN_ANALYSIS_COIN_SYMBOLS];
      } else {
        defaultCoin.value = "BTC";
      }
    } else {
      defaultCoin.value = coin;
      ExStorageUtils.removeObject(ExStorageUtils.COIN_ANALYSIS_COIN_SYMBOLS);
    }
    showCoinName.value = defaultCoin.value;
    tabData.add(BottomSheetEntity(
        showName: "breakeven_analysis_text2".tr, extrasStr: "-1")); //7日
    tabData.add(BottomSheetEntity(
        showName: "breakeven_analysis_text3".tr, extrasStr: "1")); //30日
    tabData.add(BottomSheetEntity(
        showName: "breakeven_analysis_text4".tr, extrasStr: "0")); //自定义
    _sevenDateTime =
        EXDateUtils.getSomeDay(DateTime.now(), 6).transformToUtc8();
    _thirtyDateTime =
        EXDateUtils.getSomeDay(DateTime.now(), 29).transformToUtc8();
    _startDateTime =
        EXDateUtils.getSomeDay(DateTime.now(), 6).transformToUtc8(); //默认最近7天
    _endDateTime = EXDateUtils.getUtc8TimeNow();

    listenEvent();
  }

  @override
  void onClose() {
    refreshController.dispose();
    scrollController.dispose();
    ExStorageUtils.removeObject(ExStorageUtils.SHOW_OR_HIDE_ASSETS_AMOUNT);
    ExStorageUtils.removeObject(ExStorageUtils.COIN_ANALYSIS_COIN_SYMBOLS);
    super.onClose();
  }

  @override
  void onReady() {
    super.onReady();
    bool isLogin = ExStorageUtils.getString(ExStorageUtils.TOKEN).isNotEmpty;
    if (!isLogin) {
      Routes.pushNvEvent(ev: NvEvent.login);
      return;
    }
    loadStatus.value = ExLoadingStatus.loading;

    loadNet();
  }

  void refreshData() {
    isLoad.value = true;
    if (loadStatus.value == ExLoadingStatus.failed) {
      loadStatus.value = ExLoadingStatus.loading;
    }
    loadNet();
  }

  @override
  void loadNet() {
    getHeaderData();
    getData();
  }

  void getHeaderData() {
    getProfitAndLossDataList();
    getCanCustomDate();
    getAccountBalance();
  }

  void getData() {
    getChartData();
    getAssetDistribution();
    _handleLineChartBottomTitleData(_startDateTime, _endDateTime);
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
      _startDateTime = _sevenDateTime;
    }
    if (index == 1) {
      //近30天
      _startDateTime = _thirtyDateTime;
    }

    if (index < 2) {
      // getspecifiedProfitAndLossAnalysis(currentIndex);
      getData();
    }
  }

  void getProfitAndLossDataList() {
    var requestBody1 = RequestParams();
    requestBody1.put("profitBusiness", "20"); //币币账户盈亏
    requestBody1.put("beginTime1",
        BreakevenAnalysisUtil.getCurrentDate(EXDateUtils.getUtc8TimeNow()));
    requestBody1.put("endTime1",
        BreakevenAnalysisUtil.getCurrentDate(EXDateUtils.getUtc8TimeNow()));
    requestBody1.put(
        "beginTime2", BreakevenAnalysisUtil.getCurrentDate(_sevenDateTime));
    requestBody1.put("endTime2",
        BreakevenAnalysisUtil.getCurrentDate(EXDateUtils.getUtc8TimeNow()));
    requestBody1.put(
        "beginTime3", BreakevenAnalysisUtil.getCurrentDate(_thirtyDateTime));
    requestBody1.put("endTime3",
        BreakevenAnalysisUtil.getCurrentDate(EXDateUtils.getUtc8TimeNow()));

    httpRequest<BaseResultVx<ProfitAndLossDataResListEntity>>(
      api.getProfitAndLossDataList(requestBody1.getRequestBody()),
      (value) {
        refreshController.refreshCompleted();
        profitAndLossDataResListEntity.value = value.data!;
        if (profitAndLossDataResListEntity.value.profitAndLossDataResList !=
            null) {
          for (var i = 0;
              i <
                  profitAndLossDataResListEntity
                      .value.profitAndLossDataResList!.length;
              i++) {
            SingleCoinAssetsChartEntity chartEntity =
                profitAndLossDataResListEntity
                    .value.profitAndLossDataResList![i];
            switch (i) {
              case 0:
                currentDayProfitEntity.value = _formatProfitData(chartEntity);
                break;
              case 1:
                sevenDayProfitEntity.value = _formatProfitData(chartEntity);
                break;
              case 2:
                thirtyDayProfitEntity.value = _formatProfitData(chartEntity);
                break;
              default:
            }
          }
        }
      },
      errorV2: (code, msg) {
        refreshController.refreshCompleted();
      },
      error: (e) {
        refreshController.refreshCompleted();
      },
    );
  }

  SingleCoinAssetsChartEntity _formatProfitData(
      SingleCoinAssetsChartEntity? chartEntity) {
    if (chartEntity == null) {
      return SingleCoinAssetsChartEntity();
    }
    String amountOfProfitOrLoss = (chartEntity.amountOfProfitOrLoss != null
        ? DecimalUtils.showSMultiply(
            chartEntity.amountOfProfitOrLoss,
            mUsdtCurrencyRates,
            digits: mUsdtCurrencyPrecision,
            isShowThous: false,
          )
        : "0.00");

    chartEntity.amountOfProfitOrLoss =
        double.parse(DecimalUtils.showSNormal(amountOfProfitOrLoss, digits: 2));

    double profitAndLossRatioNum = chartEntity.profitAndLossRatio ?? 0;
    chartEntity.profitAndLossRatio = double.parse(
        DecimalUtils.formateNum(profitAndLossRatioNum * 100, digits: 2));
    return chartEntity;
  }

  void accordCustomDateGetData(DateTime starTime, DateTime endTime) {
    _startDateTime = starTime;
    _endDateTime = endTime;
    _customStartDateTime = _startDateTime;
    _customEndDateTime = _endDateTime;
    getData();
  }

  ///获取自定义按钮是否展示标识
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

  void getAccountBalance() {
    Map? rateData =
        ExStorageUtils.getObject(ExStorageUtils.LOCAL_ASSET_CONVERT_SYMBOL_RATE)
            as Map?;
    if (rateData != null) {
      ///先取一次缓存数据，防止汇率接口异常
      btcToDefaultCoinRate = getRate(rateData); //汇率
      btcToDefaultCoinPrecision = getPrecision(rateData);
    }

    var requestBody = RequestParams();

    multiHttpRequest([
      api.getAssetConvertSymbolRate(RequestParams().getRequestBody()),
      api.getAccountBalance(requestBody.getRequestBody()),
      api.getAppPublicInfoMarket(requestBody.getRequestBody()),
    ], (value) {
      Map coinRateData = value[0].data;
      ExStorageUtils.putObject(
          ExStorageUtils.LOCAL_ASSET_CONVERT_SYMBOL_RATE, coinRateData);
      btcToDefaultCoinRate = getRate(coinRateData); //汇率
      btcToDefaultCoinPrecision = getPrecision(coinRateData);
      AccountBalanceEntity balanceEntity = value[1].data!;

      if (double.tryParse(balanceEntity.totalBalance!) == 0) {
        legalCoinAmount.value = "0.00";
      } else {
        legalCoinAmount.value = DecimalUtils.showSMultiply(
            balanceEntity.totalBalance ?? 0, mBtcCurrencyRates,
            isShowThous: false, digits: mBtcCurrencyPrecision);

        legalCoinAmount.value =
            TaskCenterCommon.truncateToSpecifiedDecimalPlaces(
                legalCoinAmount.value, mBtcCurrencyPrecision,
                needAddZero: true);
      }
      balanceEntity.totalBalance = DecimalUtils.showSMultiply(
        balanceEntity.totalBalance,
        btcToDefaultCoinRate,
        digits: btcToDefaultCoinPrecision,
        isShowThous: false,
      );

      balanceEntity.totalBalance =
          TaskCenterCommon.truncateToSpecifiedDecimalPlaces(
              balanceEntity.totalBalance, btcToDefaultCoinPrecision,
              needAddZero: false);
      if (balanceEntity.totalBalance!.endsWith("0")) {
        double totalBalanceNum =
            double.tryParse(balanceEntity.totalBalance ?? "0") ?? 0;
        if (!totalBalanceNum.toString().contains("e")) {
          if (totalBalanceNum == totalBalanceNum.toInt()) {
            // 是整数
            balanceEntity.totalBalance =
                TaskCenterCommon.truncateToSpecifiedDecimalPlaces(
                    balanceEntity.totalBalance,
                    btcToDefaultCoinPrecision > 2
                        ? 2
                        : btcToDefaultCoinPrecision,
                    needAddZero: true);
          } else {
            // 去掉尾部多余的0
            balanceEntity.totalBalance = totalBalanceNum.toString();
          }
        }
      }

      accountBalanceEntity.value = balanceEntity;

      marketCoinInfo.value = value[2].data!;
      Map? coinData = marketCoinInfo.value.coinList;
      if (coinData != null && coinData[defaultCoin.value] != null) {
        Map coin = coinData[defaultCoin.value];
        showCoinName.value = coin["showName"];
      }
    });
  }

  int getPrecision(Map data) {
    int showPrecision = 2;
    List convertSymbolList = data["convertSymbolList"] ?? [];
    for (var i = 0; i < convertSymbolList.length; i++) {
      Map temp = convertSymbolList[i];
      if (temp["coinSymbol"] == defaultCoin.value) {
        showPrecision = temp["showPrecision"];
      }
    }
    return showPrecision;
  }

  String getRate(Map data) {
    String rate = "1.0";
    Map convertRate = data["convertRate"] ?? {};
    Map btcRateData = convertRate["BTC"] ?? {};
    rate = btcRateData[defaultCoin.value] ?? "1.0";
    return rate.toString();
  }

  void getChartData() {
    totalAssetsList.value = [];
    cumulativeReturnRateList.value = [];
    dailyProfitList.value = [];
    cumulativeReturnList.value = [];
    bottomTagIndexList.value = [];
    bottomDateList.value = [];

    var requestBody = RequestParams();

    requestBody.put(
        "startDate", BreakevenAnalysisUtil.getCurrentDate(_startDateTime));
    requestBody.put(
        "endDate", BreakevenAnalysisUtil.getCurrentDate(_endDateTime));
    httpRequest<BaseResultVx<CoinAssetsChartListEntity>>(
      api.getCoinAssetsChartData(requestBody.getRequestBody()),
      (value) {
        isLoad.value = false;
        loadStatus.value = ExLoadingStatus.success;

        List<TotalAssetsChartDataEntity> list1 = [];
        List<CumulativeProfitRatioChartDataEntity> list2 = [];
        List<DailyIncomeChartDataEntity> list3 = [];
        List<CumulativeIncomeChartDataEntity> list4 = [];

        CoinAssetsChartListEntity listEntity = value.data!;
        chartEntityList.value = listEntity.list ?? [];
        isEmpty.value = chartEntityList.isEmpty;
        DateTime tempStart = DateTime.parse(chartEntityList.first.date!);
        DateTime tempEnd = DateTime.parse(chartEntityList.last.date!);
        _handleLineChartBottomTitleData(tempStart, tempEnd);

        if (chartEntityList.isNotEmpty) {
          for (var i = 0; i < chartEntityList.length; i++) {
            CoinAssetsChartDataEntity entity = chartEntityList[i];
            String date = entity.date!.split(" ").first;

            ///资产总值换成法币
            String totalBalanceStr = DecimalUtils.showSMultiply(
                entity.totalBalance, mUsdtCurrencyRates,
                isShowThous: false, digits: mUsdtCurrencyPrecision);

            ///每日收益换成法币
            String profitStr = DecimalUtils.showSMultiply(
                entity.profit, mUsdtCurrencyRates,
                isShowThous: false, digits: mUsdtCurrencyPrecision);

            ///累积收益换成法币
            String cumulativeIncomeStr = DecimalUtils.showSMultiply(
                entity.cumulativeIncome, mUsdtCurrencyRates,
                isShowThous: false, digits: mUsdtCurrencyPrecision);

            try {
              ///产品要求，保留两位精度
              //资产总值
              String totalBalance =
                  TaskCenterCommon.truncateToSpecifiedDecimalPlaces(
                      totalBalanceStr, 2);

              ///每日收益
              String profit = TaskCenterCommon.truncateToSpecifiedDecimalPlaces(
                  profitStr, 2);

              //累积收益
              String cumulativeIncome =
                  TaskCenterCommon.truncateToSpecifiedDecimalPlaces(
                      cumulativeIncomeStr, 2);

              TotalAssetsChartDataEntity chartDataEntity =
                  TotalAssetsChartDataEntity(
                totalBalance: (double.tryParse(totalBalance) ?? 0),
                totalBalanceStr: (double.tryParse(totalBalance) ?? 0) == 0
                    ? "0.00"
                    : totalBalance,
                index: i,
                date: date,
                value: entity.totalBalance,
              );

              list1.add(chartDataEntity);

              Decimal _decimalCumulativeRageReturn =
                  Decimal.parse(entity.cumulativeRageReturn.toString()) *
                      Decimal.parse("100");
              double _tempCumulativeRageReturn =
                  _decimalCumulativeRageReturn.toDouble();

              Decimal _decimalbtcCumulativeRate =
                  Decimal.parse(entity.btcCumulativeRate.toString()) *
                      Decimal.parse("100");
              double _tempbtcCumulativeRate =
                  _decimalbtcCumulativeRate.toDouble();

              //累积收益率
              CumulativeProfitRatioChartDataEntity
                  cumulativeProfitRatioChartDataEntity =
                  CumulativeProfitRatioChartDataEntity(
                cumulativeRageReturn: _tempCumulativeRageReturn,
                btcCumulativeRate: _tempbtcCumulativeRate,
                index: i,
                date: date,
              );

              // Decimal aa = Decimal.parse(entity.cumulativeRageReturn.toString()) *
              //     Decimal.parse("100");
              // double bb = aa.toDouble();
              // debugPrint(
              //     " --- cumulativeRageReturn: ${entity.cumulativeRageReturn}   -- $aa  $bb -- $i \n  btcCumulativeRate: ${entity.btcCumulativeRate}");
              list2.add(cumulativeProfitRatioChartDataEntity);

              ///每日收益
              DailyIncomeChartDataEntity dailyIncomeChartDataEntity =
                  DailyIncomeChartDataEntity(
                profit: (double.tryParse(profit) ?? 0),
                profitStr:
                    (double.tryParse(profit) ?? 0) == 0 ? "0.00" : profit,
                index: i,
                date: date,
              );

              list3.add(dailyIncomeChartDataEntity);
              //累计收益
              CumulativeIncomeChartDataEntity cumulativeIncomeChartDataEntity =
                  CumulativeIncomeChartDataEntity(
                cumulativeIncome: (double.tryParse(cumulativeIncome) ?? 0),
                cumulativeIncomeStr:
                    (double.tryParse(cumulativeIncome) ?? 0) == 0
                        ? "0.00"
                        : cumulativeIncome,
                index: i,
                date: date,
              );

              list4.add(cumulativeIncomeChartDataEntity);
            } catch (e) {
              debugPrint("$e");
            }
          }
          TotalAssetsChartDataEntity totalAssetsChartDataEntity = list1.last;
          totalAssets.value = totalAssetsChartDataEntity.totalBalance == 0
              ? "0.00"
              : totalAssetsChartDataEntity.totalBalanceStr!;

          CumulativeProfitRatioChartDataEntity
              cumulativeProfitRatioChartDataEntity = list2.last;
          cumulativeProfitAndLossRatio.value =
              cumulativeProfitRatioChartDataEntity.cumulativeRageReturn!
                  .toString();
          btcCumulativeRate.value = cumulativeProfitRatioChartDataEntity
              .btcCumulativeRate!
              .toString();

          DailyIncomeChartDataEntity dailyIncomeChartDataEntity = list3.last;
          dailyIncome.value = dailyIncomeChartDataEntity.profit == 0
              ? "0.00"
              : dailyIncomeChartDataEntity.profitStr!;

          CumulativeIncomeChartDataEntity cumulativeIncomeChartDataEntity =
              list4.last;
          cumulativeIncome.value =
              cumulativeIncomeChartDataEntity.cumulativeIncome == 0
                  ? "0.00"
                  : cumulativeIncomeChartDataEntity.cumulativeIncomeStr!;

          minAssetBalance.value = list1.first.totalBalance ?? 0;
          for (var i = 0; i < list1.length; i++) {
            TotalAssetsChartDataEntity data = list1[i];
            double totalBalance = data.totalBalance!;
            if (totalBalance >= maxAssetY.value) {
              maxAssetY.value = totalBalance;
            }
            if (totalBalance <= minAssetY.value) {
              minAssetY.value = totalBalance;
            }
            if (totalBalance <= minAssetBalance.value) {
              minAssetBalance.value = totalBalance;
            }
          }

          totalAssetsList.value = list1;
          cumulativeReturnRateList.value = list2;
          dailyProfitList.value = list3;
          cumulativeReturnList.value = list4;
        }
      },
      error: (e) {
        loadStatus.value = ExLoadingStatus.failed;
      },
      errorV2: (code, msg) {
        loadStatus.value = ExLoadingStatus.failed;
      },
    );
  }

  ///资产币种分布
  void getAssetDistribution() {
    var requestBody = RequestParams();
    httpRequest<BaseResultVx<CoinAssetsLocationEntity>>(
      api.getAssetDistribution(requestBody.getRequestBody()),
      (value) {
        refreshController.refreshCompleted();
        coinAssetsLocationEntity.value = value.data!;
        if (coinAssetsLocationEntity.value.list != null) {
          for (var i = 0;
              i < coinAssetsLocationEntity.value.list!.length;
              i++) {
            SingleCoinAssetsLocationEntity chartEntity =
                coinAssetsLocationEntity.value.list![i];
          }
        }
      },
      errorV2: (code, msg) {
        refreshController.refreshCompleted();
      },
      error: (e) {
        refreshController.refreshCompleted();
      },
    );
  }

  void _handleLineChartBottomTitleData(DateTime startTime, DateTime endTime) {
    int difference = endTime.difference(startTime).inDays;
    int length = difference + 1 > 4 ? 4 : difference + 1;
    List<DateTime> list =
        EXDateUtils.getEquallySpacedDatePoints(startTime, endTime, length);
    List<String> timeStrList = [];
    for (int i = 0; i < list.length; i++) {
      DateTime dateTime = list[i];
      String timeStr =
          EXDateUtils.formateDateTimeToString(dateTime, format: "MM/dd");
      timeStrList.add(timeStr);
    }
    bottomDateList.value = EXDateUtils.getDatesBetween(startTime, endTime);
    bottomTagIndexList.value = BreakevenAnalysisUtil.getEquallySpacedIntNumbers(
        0, bottomDateList.length - 1, length);
    chartBottomTitles.value = timeStrList;
  }

  void listenEvent() {
    Routes.pushNvEvent(
        ev: NvEvent.get_legal_coin_info, param: {"coinName": "BTC"});
    Routes.pushNvEvent(
        ev: NvEvent.get_legal_coin_info, param: {"coinName": "USDT"});
    addStremSub(Event.eventBus.on<MessageEvent>().listen((event) {
      if (event.msg_type == MessageEvent.nativeNotifitionEvent) {
        nativeMethods(event.msg_content);
      }
    }));
  }

  void nativeMethods(dynamic data) {
    if (data is Map) {
      String method = data["method"];
      dynamic arguments = data["arguments"];
      Map<String, dynamic> params = json.decode(arguments);
      switch (method) {
        case "setCoinInfo":
          if (params.containsKey('coinName')) {
            String coinName = params['coinName'];
            if (coinName == "BTC") {
              if (params.containsKey('mCurrencyRates') &&
                  params["mCurrencyRates"] != null) {
                mBtcCurrencyRates =
                    (double.tryParse(params['mCurrencyRates'].toString()) ??
                            1.0)
                        .toString();
              } else {
                debugPrint("$coinName mCurrencyRates 获取失败");
              }
              if (params.containsKey('mCurrencyPrecision') &&
                  params["mCurrencyPrecision"] != null) {
                if (params["mCurrencyPrecision"] is num) {
                  mBtcCurrencyPrecision =
                      int.tryParse(params["mCurrencyPrecision"].toString()) ??
                          2;
                } else if (params["mCurrencyPrecision"] is String) {
                  mBtcCurrencyPrecision =
                      int.tryParse(params['mCurrencyPrecision']) ?? 2;
                } else {
                  debugPrint("$coinName mCurrencyPrecision 获取失败");
                }
              }
              if (params.containsKey('mCurrencyCoin') &&
                  params["mCurrencyCoin"] != null) {
                mCurrencyCoin.value = params["mCurrencyCoin"];
              }
            }
            if (coinName == "USDT") {
              if (params.containsKey('mCurrencyRates') &&
                  params["mCurrencyRates"] != null) {
                mUsdtCurrencyRates =
                    (double.tryParse(params['mCurrencyRates'].toString()) ??
                            1.0)
                        .toString();
              }
              if (params.containsKey('mCurrencyPrecision') &&
                  params["mCurrencyPrecision"] != null) {
                if (params["mCurrencyPrecision"] is num) {
                  mUsdtCurrencyPrecision =
                      int.tryParse(params["mCurrencyPrecision"].toString()) ??
                          2;
                } else if (params["mCurrencyPrecision"] is String) {
                  mUsdtCurrencyPrecision =
                      int.tryParse(params['mCurrencyPrecision']) ?? 2;
                } else {
                  debugPrint("$coinName mCurrencyPrecision 获取失败");
                }
                if (params.containsKey('mCurrencyCoin') &&
                    params["mCurrencyCoin"] != null) {
                  mCurrencyCoin.value = params["mCurrencyCoin"];
                }
              }
            }
          }
          break;
        default:
          break;
      }
    }
  }

  void cancelSelectTIme() {
    currentDateIndex.value = lastDateIndex.value;
    getData();
  }
}
