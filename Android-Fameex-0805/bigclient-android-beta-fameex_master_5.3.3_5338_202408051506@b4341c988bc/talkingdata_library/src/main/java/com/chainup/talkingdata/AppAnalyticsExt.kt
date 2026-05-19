package com.chainup.talkingdata

import android.content.Context


class AppAnalyticsExt private constructor() {
    val TAG = AppAnalyticsExt::class.java.simpleName


    companion object {
        private var INSTANCE: AppAnalyticsExt? = null

        private var APP_EVENT: String = ""

        var APP_EVENT_SpotTransactionPage: String = "SpotTransactionPage"
        var APP_EVENT_LeveragePage: String = "LeveragePage"
        var APP_EVENT_MarketPage: String = "MarketPage"
        var APP_EVENT_HomePage: String = "HomePage"
        var APP_EVENT_FiatPage: String = "FiatPage"
        var APP_EVENT_ContractPage: String = "ContractPage"
        var APP_EVENT_AssetsPage: String = "AssetsPage"


        var APP_ACTION_OrderCreate: String = "OrderCreate"
        var APP_ACTION_OrderCancel: String = "OrderCancel"
        var APP_ACTION_LeverCreate: String = "LeverCreate"
        var APP_ACTION_LeverCancel: String = "LeverCancel"


        var APP_HTTP_httpTrack: String = "httpTrack"
        var APP_HTTP_httpTrackLow: String = "httpTrackLow"
        var APP_HTTP_httpError: String = "httpError"

        var APP_HTTP_wsTrack: String = "wsTrack"
        var APP_HTTP_wsTrackRetry: String = "wsTrackRetry"


        var APP_CLICK_HOMEPAGEVIEW: String = "HomePageview"
        var HOME_SEARCH_CLICK: String = "Home_Search_click"
        var HOME_TOPGAINERS_CLICK: String = "Home_TopGainers_click"
        var HOME_TOPLOSERS_CLICK: String = "Home_TopLosers_click"
        var HOME_VOLLEADERS_CLICK: String = "Home_VOLLeaders_click"



        var APP_CLICK_MARKETPAGEVIEW: String = "Marketpageview"
        var MARKET_FAVORITES_CLICK: String = "Market_Favorites_click"
        var MARKET_NAME_CLICK: String = "Market_Name_click"
        var MARKET_CHANGE_CLICK: String = "Market_Change_click"
        var MARKET_LASTPRICE_CLICK: String = "Market_Lastprice_click"


        var Tradepageview: String = "Tradepageview"

        var Trade_Exchange_click: String = "Trade_Exchange_click"
        var Trade_Grid_click: String = "Trade_Grid_click"
        var Trade_Margin_click: String = "Trade_Margin_click"
        var Trade_P2P_click: String = "Trade_P2P_click"
        var Trade_Kline_click: String = "Trade_Kline_click"



        var APP_USER_ACTION_register: String = "register"
        var APP_USER_ACTION_register_ok: String = "register_ok"
        var APP_USER_ACTION_register_fail: String = "register_fail"
        var APP_USER_ACTION_login: String = "login"
        var APP_USER_ACTION_login_ok: String = "login_ok"
        var APP_USER_ACTION_login_fail: String = "login_fail"

        var APP_HOME_ACTION_btn_homepage: String = "click_search_btn_homepage"
        var APP_HOME_ACTION_input_homepage: String = "search_input_homepage"
        var APP_HOME_ACTION_click_banner: String = "click_banner"
        var APP_HOME_ACTION_click_notice: String = "click_notice"
        var APP_HOME_ACTION_click_notice_list: String = "click_notice_list"
        var APP_HOME_ACTION_click_tab: String = "click_tab"

        var APP_TRADE_ACTION_click_spot_left: String = "search_input_spot_left"
        var APP_TRADE_ACTION_click_token_pair: String = "search_input_spot_left"
        var APP_TRADE_ACTION_click_buy_btn: String = "click_spot_buy_btn"
        var APP_TRADE_ACTION_click_buy_ok: String = "spot_buy_ok"
        var APP_TRADE_ACTION_click_buy_fail: String = "spot_buy_fail"
        var APP_TRADE_ACTION_click_sell_btn: String = "click_spot_sell_btn"
        var APP_TRADE_ACTION_click_sell_ok: String = "spot_sell_ok"
        var APP_TRADE_ACTION_click_sell_fail: String = "spot_sell_fail"


        var APP_TRADE_ACTION_click_left: String = "search_input_%s_left"
        var APP_TRADE_ACTION_click_pair: String = "click_token_pair_%s"

        var APP_TRADE_GRID_ACTION_click_grid_left: String = "search_input_grid_left"
        var APP_TRADE_GRID_ACTION_click_grid_pair: String = "click_token_pair_grid"
        var APP_TRADE_GRID_ACTION_click_grid_trade_btn: String = "click_grid_gridtrade_btn"
        var APP_TRADE_GRID_ACTION_click_grid_ok: String = "create_grid_ok"
        var APP_TRADE_GRID_ACTION_click_grid_fail: String = "create_grid_fail"
        var APP_TRADE_GRID_ACTION_click_close_grid_btn: String = "click_close_grid_btn"
        var APP_TRADE_GRID_ACTION_click_stop_grid_ok: String = "stop_grid_ok"
        var APP_TRADE_GRID_ACTION_click_stop_grid_fail: String = "stop_grid_fail"
        var APP_TRADE_GRID_ACTION_click_grid_ai_btn: String = "click_grid_grid_ai_btn"
        var APP_TRADE_GRID_ACTION_click_grid_ai_ok: String = "create_grid_ai_ok"
        var APP_TRADE_GRID_ACTION_click_grid_ai_fail: String = "create_grid_ai_fail"


        var APP_TRADE_LEVER_ACTION_click_lever_left: String = "search_input_lever_left"
        var APP_TRADE_LEVER_ACTION_click_buy_btn: String = "click_lever_buy_btn"
        var APP_TRADE_LEVER_ACTION_click_pair_lever: String = "click_token_pair_lever"
        var APP_TRADE_LEVER_ACTION_click_buy_ok: String = "lever_buy_ok"
        var APP_TRADE_LEVER_ACTION_click_buy_fail: String = "lever_buy_fail"
        var APP_TRADE_LEVER_ACTION_click_sell_btn: String = "click_lever_sell_btn"
        var APP_TRADE_LEVER_ACTION_click_sell_ok: String = "lever_sell_ok"
        var APP_TRADE_LEVER_ACTION_click_sell_fail: String = "lever_sell_fail"


        var APP_DEPOSIT_ACTION_click_deposit_btn: String = "click_deposit_btn"
        var APP_DEPOSIT_ACTION_click_recharge: String = "search_input_recharge"
        var APP_DEPOSIT_ACTION_click_token: String = "click_token_recharge"
        var APP_DEPOSIT_ACTION_click_deposit_ok: String = "deposit_ok"
        var APP_DEPOSIT_ACTION_click_deposit_fail: String = "deposit_fail"

        var APP_WITHDRAW_ACTION_click_withdraw_btn: String = "click_withdraw_btn"
        var APP_WITHDRAW_ACTION_click_input_withdraw: String = "search_input_withdraw"
        var APP_WITHDRAW_ACTION_click_withdraw_ok: String = "withdraw_ok"
        var APP_WITHDRAW_ACTION_click_withdraw_fail: String = "withdraw_fail"
        var APP_WITHDRAW_ACTION_click_token: String = "click_token_withdraw"



        var APP_TRANSFER_ACTION_click_tab: String = "click_transfer_btn"
        var APP_TRANSFER_ACTION_click_ok: String = "%s_%s_transfer_ok"
        var APP_TRANSFER_ACTION_click_fail: String = "%s_%s_transfer_fail"







        var CONTRACT_APP_ACTION_1: String = "合约-下单区-开仓"
        var CONTRACT_APP_ACTION_2: String = "合约-下单区-平仓"
        var CONTRACT_APP_ACTION_3: String = "合约-下单百分比-10%"
        var CONTRACT_APP_ACTION_4: String = "合约-下单百分比-20%"
        var CONTRACT_APP_ACTION_5: String = "合约-下单百分比-50%"
        var CONTRACT_APP_ACTION_6: String = "合约-下单百分比-100%"
        var CONTRACT_APP_ACTION_7: String = "合约-下单区-对手1档"
        var CONTRACT_APP_ACTION_8: String = "合约-下单区-对手5档"
        var CONTRACT_APP_ACTION_9: String = "合约-下单区-对手10档"
        var CONTRACT_APP_ACTION_10: String = "合约-下单区-划转"
        var CONTRACT_APP_ACTION_11: String = "合约-持仓-平仓"
        var CONTRACT_APP_ACTION_12: String = "合约-持仓-市价"
        var CONTRACT_APP_ACTION_13: String = "合约-持仓-对手方最优"
        var CONTRACT_APP_ACTION_14: String = "合约-持仓-本方最优"
        var CONTRACT_APP_ACTION_15: String = "合约-持仓-分享"
        var CONTRACT_APP_ACTION_16: String = "合约-盈亏分析"
        var CONTRACT_APP_ACTION_17: String = "合约-持仓-一键全平"
        var CONTRACT_APP_ACTION_18: String = "合约-持仓-闪电平仓"
        var CONTRACT_APP_ACTION_19: String = "合约-下单-限价-币"
        var CONTRACT_APP_ACTION_20: String = "合约-下单-限价-张"
        var CONTRACT_APP_ACTION_21: String = "合约-下单-限价-价值"

        var APP_FUTURES_SEARCH_CLICK: String = "app_futures_search_click"
        var APP_FUTURES_LIMIT_ORDER_PRICE_INPUT: String = "app_futures_limit_order_price_input"
        var APP_FUTURES_LIMIT_ORDER_PRICE_CLICK: String = "app_futures_limit_order_price_click"
        var APP_FUTURES_LIMIT_ORDER_QUANTITY_INPUT: String = "app_futures_limit_order_quantity_input"
        var APP_FUTURES_LIMIT_ORDER_QUANTITY_SLIDER: String = "app_futures_limit_order_quantity_slider"
        var APP_FUTURES_LIMIT_ORDER_PLACE_ORDER: String = "app_futures_limit_order_place_order"
        var APP_FUTURES_SWITCH_ORDER: String = "app_futures_switch_order"
        var APP_FUTURES_MARKET_ORDER_QUANTITY_INPUT: String = "app_futures_market_order_quantity_input"
        var APP_FUTURES_MARKET_ORDER_QUANTITY_SLIDER: String = "app_futures_market_order_quantity_slider"
        var APP_FUTURES_MARKET_ORDER_PLACE_ORDER: String = "app_futures_market_order_place_order"
        var APP_FUTURES_PLACE_ORDER_SUCCESS: String = "app_futures_place_order_success"
        var APP_FUTURES_PLACE_ORDER_FAIL: String = "app_futures_place_order_fail"
        var APP_FUTURES_POSITIONS_CLOSE_ALL: String = "app_futures_positions_close_all"
        var APP_FUTURES_POSITIONS_LIGHT_CLOSE: String = "app_futures_positions_light_close"
        var APP_FUTURES_POSITIONS_CLOSE: String = "app_futures_positions_close"
        var APP_FUTURES_POSITIONS_TPSL: String = "app_futures_positions_tpsl"
        var APP_FUTURES_ORDERS_CANCEL_ALL: String = "app_futures_orders_cancel_all"
        var APP_FUTURES_ORDERS_CANCEL: String = "app_futures_orders_cancel"

        var APP_FUTURES_MAIN_PAGE: String = "app_futures_main_page"
        var APP_FUTURES_KLINE_PAGE: String = "app_futures_kline_page"
        var CONTRACT_APP_PAGE_2: String = "合约-盈亏记录"
        var CONTRACT_APP_PAGE_3: String = "合约-资金划转"
        var CONTRACT_APP_PAGE_4: String = "合约-资金流水"
        var CONTRACT_APP_PAGE_5: String = "合约-合约信息"
        var CONTRACT_APP_PAGE_6: String = "合约-交易设置"
        var CONTRACT_APP_PAGE_7: String = "合约-计算器"
        var CONTRACT_APP_PAGE_8: String = "合约-全部委托"
        var CONTRACT_APP_PAGE_9: String = "合约-当前委托"
        var CONTRACT_APP_PAGE_10: String = "合约-历史委托"
        var CONTRACT_APP_PAGE_11: String = "合约-委托详情"
//        var APP_FUTURES_KLINE_PAGE: String = "app_futures_kline_page"


        val instance: AppAnalyticsExt
            get() {
                if (INSTANCE == null) {
                    synchronized(AppAnalyticsExt::class.java) {
                        if (INSTANCE == null) {
                            INSTANCE = AppAnalyticsExt()
                        }
                    }
                }
                return INSTANCE!!
            }
    }

    init {
        // params
    }

    private var mContext: Context? = null
    fun init(context: Context, array: HashMap<String, String>) {
        mContext = context


    }


    fun activityStart(name: String) {

    }

    fun activityStop(name: String) {

    }

    fun network(name: String, params: Map<String, Any>) {
    }

    fun clickAction(name: String, params: Map<String, Any>?) {

    }


    fun clickAction(name: String) {

    }

}