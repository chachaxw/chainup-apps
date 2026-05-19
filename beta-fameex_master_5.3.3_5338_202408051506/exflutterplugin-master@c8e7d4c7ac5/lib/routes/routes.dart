import 'package:chainup_flutter_ex/page/breakeven_analysis/breakeven_analysis_controller/coin_transaction_breakeven_analysis_binding.dart';
import 'package:chainup_flutter_ex/page/breakeven_analysis/breakeven_analysis_controller/margin_trade_breakeven_analysis_binding.dart';
import 'package:chainup_flutter_ex/home_page/home_page.dart';
import 'package:chainup_flutter_ex/page/breakeven_analysis/page/coin_transaction_breakeven_analysis_page.dart';
import 'package:chainup_flutter_ex/page/breakeven_analysis/page/margin_trade_breakeven_analysis_page.dart';
import 'package:chainup_flutter_ex/page/taskCenter/reward_center_index_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../controllers/debug_binding.dart';
import '../controllers/kline/kline_binding.dart';
import '../controllers/klineSetting/kline_indicators_setting_binding.dart';
import '../controllers/taskCenter/invalid_reward_voucher_binding.dart';
import '../controllers/taskCenter/task_center_index_binding.dart';
import '../home_page/home_binding.dart';
import '../page/debug/debug_page.dart';
import '../page/kline/kline_detail_page.dart';
import '../page/kline/kline_horizontal_page.dart';
import '../page/kline/kline_page.dart';
import '../page/klineSetting/kline_indicators_modify_page.dart';
import '../page/klineSetting/kline_indicators_setting_page.dart';
import '../page/taskCenter/invalid_reward_voucher_page.dart';
import '../page/taskCenter/task_center_index_page.dart';
import '../page/taskCenter/task_detail_page.dart';

class Routes {
  static const INITIAL = '/main';
  static const REWARD_CENTER = '/rewardCenterPage';
  static const TASK_DETAIL = '/taskDetailPage';
  static const KLINE = '/kline';
  static const KLINE_DETAIL = '/klineDetail';
  static const KLINE_HORIZONTAL = '/klineDetail_horizontal';
  static const DEBUG = '/debug';
  static const KLINE_INDICATORS_SETTING_PAGE =
      '/klineSetting/klineIndicatorsSettingPage';
  static const KLINE_INDICATORS_MODIFY_PAGE =
      '/klineSetting/klineIndicatorsModifyPage';
  static const INVALID_VOUCHER_PAGE = '/invalidVoucherPage';
  static const COIN_TRANSACTION_BREAKEVEN_ANALYSIS_PAGE =
      '/coinTransactionBreakevenAnalysisPage';
  static const HOME_PAGE = '/homePage';
  static const TASK_CENTER_INDEX_PAGE = '/taskCenterIndexPage';
  static const MARGIN_TRADE_BREAKEVEN_ANALYSIS_PAGE =
      '/marginTradeBreakevenAnalysisPage';

  static final routes = [
    GetPage(
      name: HOME_PAGE,
      page: () => HomePage(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: KLINE_DETAIL,
      page: () => KLineDetailPage(),
      binding: klineBinding(),
    ),
    GetPage(
      name: INITIAL,
      page: () => TaskCenterIndexPage(),
      binding: TaskCenterIndexBinding(),
    ),
    GetPage(
      name: REWARD_CENTER,
      page: () => RewardCenterIndexPage(),
      binding: TaskCenterIndexBinding(),
    ),
    GetPage(
      name: TASK_DETAIL,
      page: () => TaskDetailPage(),
      binding: TaskCenterIndexBinding(),
    ),
    GetPage(
      name: DEBUG,
      page: () => DebugPage(),
      binding: DebugBinding(),
    ),
    GetPage(
      name: KLINE,
      page: () => KLinePage(),
      binding: klineBinding(),
    ),
    GetPage(
      name: KLINE_HORIZONTAL,
      page: () => const KLineHorizontalPage(),
      binding: HorzonalKlineBinding(),
    ),
    // GetPage(
    //   name: KLINE_DETAIL,
    //   page: () => KLineDetailPage(),
    //   binding: klineBinding(),
    // ),
    GetPage(
      name: KLINE_INDICATORS_SETTING_PAGE,
      page: () => const KlineIndicatorsSettingPage(),
      binding: klineIndicatorsSettingBinding(),
    ),
    GetPage(
      name: KLINE_INDICATORS_MODIFY_PAGE,
      page: () => const KlineIndicatorsModifyPage(),
      binding: klineIndicatorsSettingBinding(),
    ),
    GetPage(
      name: INVALID_VOUCHER_PAGE,
      page: () => InvalidRewardVoucherPage(),
      binding: InvalidRewardVoucherBinding(),
    ),
    GetPage(
      name: COIN_TRANSACTION_BREAKEVEN_ANALYSIS_PAGE,
      page: () => const CoinTransactionBreakevenAnalysisPage(),
      binding: CoinTransactionBreakevenAnalysisBinding(),
    ),
    GetPage(
      name: MARGIN_TRADE_BREAKEVEN_ANALYSIS_PAGE,
      page: () => const MarginTradeBreakevenAnalysisPage(),
      binding: MaiginTradeBreakevenAnalysisBinding(),
    ),
  ];

  /**
   *
   *  【跳转】
   *  routeName 路由名称
   *  params 传递参数 map 形式
   *  isFinish 是否关闭当前页面
   *
   *  【接收参数】
   *  Map<String, dynami·c> params = Get.arguments;  接收参数
   */
  static pushPage(
      {required String routeName,
      Map<String, dynamic>? params,
      bool? isFinish = false}) {
    debugPrint("isFinish ==== $isFinish");
    if (isFinish == true) {
      Get.offNamed(routeName, arguments: params);
    } else {
      Get.toNamed(routeName, arguments: params);
    }
  }

/**
 * 关闭当前页面
 */
  static popPage<T>({
    T? result,
    bool closeOverlays = false,
    bool canPop = true,
    int? id,
  }) {
    try {
      Get.back(
          result: result, closeOverlays: closeOverlays, canPop: canPop, id: id);
    } catch (e) {
      debugPrint("返回页面报错：\n  $e \n\n\n");
    }
  }

  static Future<Map<String, dynamic>?> pushPageBackParams(
      {required String routeName, Map<String, dynamic>? params}) async {
    var result = await Get.toNamed(routeName, arguments: params);
    return result;
  }

  static pushNvEvent({required NvEvent ev, Map? param}) {
    const MethodChannel("ex.chainup.app").invokeMethod(ev.name, param);
  }
  static Future pushNvEventFuture({required NvEvent ev, Map? param}) {
    return const MethodChannel("ex.chainup.app").invokeMethod(ev.name, param);
  }
}

enum NvEvent {
  closePage,
  login,
  bindGoogle,
  bindPhone,
  kyccomplete,
  personal,
  safe_set,
  idAuth, //实名认证
  coinmap_depositing, // 充值
  quick_money, // 买币
  lever_trading, //杠杆交易
  spot_trading, //现货交易
  etf_trading, //ETF交易
  futures_trading, //合约交易
  more_history_kline, //获取历史更多Kline数据
  kline_scroll, //Kline滑动事件
  reload_kline, //Kline重新加载
  close_kline_vpage, //关闭竖屏kline
  close_kline_hpage, //关闭横屏kline
  kline_coin_info, //获取币种信息
  kline_etf_coin_intro, //获取币种ETF信息
  kline_etf_position_record, //获取ETF调仓列表
  kline_order_book, //获取订单薄
  kline_transaction_record, //获取成交记录
  kline_coin_intro, //获取币种简介
  kline_switch_time_index, //切换时间指标
  kline_guide_flag, //保存k线guide
  kline_coin_share, //K线分享
  kline_coin_collect, //K线币对收藏
  kline_coin_sidebar, //K线侧边栏
  kline_enlarge, //K线横版
  kline_go_webview, //进入webview
  kline_trading_buy, //交易买
  kline_trading_sell, //交易卖
  kline_order_switch_visible, //k线切换订单显示隐藏
  kline_detail_clickMainIndex,
  flutter_canPop,
  show_native_toast,
  task_center_share, //任务中心分享
  balance_page, //资产页面
  get_legal_coin_info, //获取法币的汇率，精度等
  showOrHideAssetsAmountEvent, //展示或隐藏资产金额
  setBarColor, //通知更改状态栏颜色
  kline_detail_page_refreshing,//kline detail refresh
  //参数 visible 1 显示 0隐藏
  kline_entrust_visible_event,//委托显示隐藏 事件
  kline_position_visible_event,//仓位显示隐藏事件
}
