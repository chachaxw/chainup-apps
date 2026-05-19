package com.chainup.contract.eventbus;

import org.json.JSONObject;

public class CpMessageEvent {

    public static final int data_req_error = 1;   //Data request failed. It can be used for global processing

    public static final int collect_data_type = 2;   //selfSelectedOrFavoriteDataEvents

    public static final int hometab_switch_type = 3;   //homeTabSwitchingEvent

    public static final int color_rise_fall_type = 4;   //colorOfFluctuationRange

    public static final int symbol_switch_type = 5;   //switchCurrencyEvent

    public static final int TRANSFER_TYPE = 6;   //buyOrSellEventType

    public static final int assetTabType = 7;   //assetPageTabSwitch

    public static final int coinSearchType = 8;   //sidebarCoinPairSearch

    public static final int closeLeftCoinSearchType = 9;   //closeSidebarEvents

    public static final int login_operation_type = 10;   //loginOperationEvent

    public static final int coin_payment = 11; //currencyTransactionOrLegalCurrencyTransaction

    public static final int fait_trading = 12; //toTrade

    public static final int left_coin_contract_type = 13; //contractSidebar

    public static final int refresh_trans_type = 14; // assetPageRefresh

    public static final int refresh_local_trans_type = 15; // partialRefreshOfAssetPage

    public static final int refresh_local_b2c_trans_type = 16; // partialRefreshOfAssetPage

    public static final int refresh_local_coin_trans_type = 17; // partialRefreshOfAssetPage

    public static final int refresh_local_b2c_coin_trans_type = 18; // partialRefreshOfAssetPage


    public static final int refresh_local_contract_type = 19; // partialRefreshOfAssetPageContract

    public static final int refresh_local_lever_type = 20; // assetPageLeverage

    public static final int DEPTH_LEVEL_TYPE = 21; //depthScale
    public static final int DEPTH_DATA_TYPE = 22; //dataOfDepthMap
    public static final int DEPTH_CONTRACT_DATA_TYPE = 220; //dataOfContractDepthMap

    public static final int CREATE_ORDER_TYPE = 23; //orderPlacementNotice

    // currency or lever
    public static final int TAB_TYPE = 24;

    public static final int into_transfer_activity = 25; //enterTheTransferPage

    public static final int into_my_asset_activity = 26; //fullyOpenOrNot

    //public static final int live_contract_asset_beanList = 28; //homePageJump


    public static final int coinTrade_tab_type = 29; // currencyTransactionPage tab

    public static final int coinTrade_topTab_type = 30; //Currency at the top of the currency transaction page tab

    public static final int leverTrade_topTab_type = 31; //Top lever of currency transaction page tab

    public static final int assetsTab_type = 32; //Top lever of currency transaction page tab

    public static final int assets_activity_finish_event = 33; //Home page jump

    public static final int contract_switch_type = 37;   //Contract tab switching event
    public static final int market_switch_type = 38;   //Contract tab switching event
    public static final int login_bind_type = 40;   //Login operation event
    public static final int market_switch_curTime = 399;   //Contract tab switching event
    public static final int webview_refresh_type = 41;   //Jump to login and refresh from the h5 page
    public static final int market_event_page_symbol_type = 42;   // Currency to tab switch
    public static final int home_event_page_symbol_type = 43;   //
    public static final int home_event_page_market_type = 44;   //
    public static final int sl_contract_select_leverage_event = 400;   //Contract switching lever
    public static final int sl_contract_left_coin_type = 401;//Switch contract currency
    public static final int sl_contract_switch_time_type = 402;//Switch K line section

    public static final int hide_safety_advice = 403;//Hide security suggestions

    public static final int sl_contract_modify_margin_event = 50;//Modify margin
    public static final int sl_contract_modify_leverage_event = 52;//Modify lever
    public static final int sl_contract_change_tagPrice_event = 53;//Mark price change, index price change
    public static final int sl_contract_user_config_event = 54;//Contract user settings are used to submit delegation
    public static final int sl_contract_cancel_order_event = 55;//CancelTheOrder
    public static final int sl_contract_rate_countdown_event = 56;//Countdown of capital rate
    public static final int sl_contract_position_num_event = 57;//Change in the number of positions
    public static final int sl_contract_cancel_last_price_event = 58;//Latest price changes
    public static final int sl_contract_change_coin_list_type = 59;//Latest price changes
    public static final int sl_contract_modify_position_margin_event = 60;//Adjustment margin
    public static final int sl_contract_refresh_position_list_event = 61;//Refresh position list
    public static final int sl_contract_create_account_event = 62;//Open the contract dialog box
    public static final int sl_contract_calc_switch_contract_event = 63;//Contract Calculator Switch Contract Notification
    public static final int sl_contract_sidebar_market_event = 64;//Sidebar market
    public static final int sl_contract_first_show_info_event = 65;//Load contract information for the first time
    public static final int sl_contract_refresh_assets_position_event = 66;//Change bin list data
    public static final int sl_contract_change_position_model_event = 67;//Change position mode
    public static final int sl_contract_change_unit_event = 68;//Change the position display unit
    public static final int sl_contract_login_status_event = 69;//Change contract button without login status
    public static final int sl_contract_first_input_last_price_event = 70;//Fill in the current price for the first time after switching the contract
    public static final int sl_contract_logout_event = 71;//After switching the contract, it is detected that you are not logged in. Clear the data displayed on the original page
    public static final int sl_contract_new_status_event = 72;//newContract (This option will not exist in the future)
    public static final int sl_contract_page_hide_event = 73;//Contract tab page hidden notification
    public static final int sl_contract_depth_level_event = 74;//Contract depth switching
    public static final int sl_contract_force_event = 75;//Enforce the use of new contracts
    public static final int sl_contract_receive_coupon = 76;//Receive simulation contract experience fee
    public static final int sl_contract_go_login_page = 77;//Jump to login
    public static final int sl_contract_go_fundsTransfer_page = 78;//Skip capital flow
    public static final int sl_contract_refresh_current_entrust_list_event = 79;//Refresh the current delegation list
    public static final int sl_contract_refresh_plan_entrust_list_event = 80;//Refresh the schedule delegation list
    public static final int sl_contract_record_switch_contract_event = 81;
    public static final int sl_contract_record_switch_entrust_type_event = 82;
    public static final int sl_contract_record_switch_order_type_event = 83;
    public static final int sl_contract_record_switch_tab_event = 84;
    public static final int sl_contract_open_contract_event = 85;
    public static final int sl_contract_switch_lever_event = 86;
    public static final int sl_contract_create_order_event = 87;
    public static final int sl_contract_req_current_entrust_list_event = 88;
    public static final int sl_contract_req_plan_entrust_list_event = 89;
    public static final int sl_contract_req_position_list_event = 90;
    public static final int sl_contract_req_modify_leverage_event = 91;
    public static final int sl_contract_record_switch_contract_side_event = 92;
    public static final int sl_contract_modify_depth_event = 93;
    public static final int sl_contract_go_kyc_page = 94;
    public static final int sl_contract_calc_switch_margin_coin_event = 95;//Contract margin switching
    public static final int sl_contract_refresh_price_list_event = 96;//Batch marking price and batch latest price
    public static final int sl_contract_priceBasis_event = 97;//Switch profit and loss calculation basis
    public static final int sl_contract_change_contract_event = 98;//Switch position of comparison notice
    public static final int sl_contract_market_event = 99;//Contract quotation list
    public static final int sl_contract_optional_market_event = 100;//Favorite currency pair refresh
    public static final int sl_contract_trade_chart_kline_config_update = 101;//Homepage K line configuration change
    public static final int sl_contract_balance_insufficient_event = 102;//Prompt for insufficient balance

    //contract ws relink finished
    public static final int sl_contract_ws_reLink_finish = 103;

    public static final int sl_contract_capitalRate_event = 104;

    //Home page market spot contract refresh
    public static final int market_updateList = 106;

    //Current contract only
    public static final int sl_contract_hold_position_isonly = 107;

    public static final int cp_net_status_change = 108;//网络状态监听

    public static final int close_kline_vpage = 109;
    public static final int kline_coin_sidebar = 110;
    public static final int kline_coin_share = 111;
    public static final int kline_coin_collect = 112;
    public static final int kline_trading_sell = 113;
    public static final int kline_trading_buy = 114;
    public static final int more_history_kline = 115;
    public static final int reload_kline = 116;
    public static final int kline_order_switch_visible = 117;
    public static final int kline_scroll= 118;

    public static final int kline_etf_position_record= 119;

    public static final int kline_coin_intro= 120;

    public static final int kline_etf_coin_intro= 121;

    public static final int kline_transaction_record= 122;

    public static final int kline_coin_info= 123;
    public static final int sl_contract_margin_coin_select = 124;
    private CpMessageEvent() {
    }

    private Object msg_content;//Event content
    private Object msg_content_data;//Event content
    private int msg_type;//Event type
    private boolean isLever;//Whether it is a lever

    public CpMessageEvent(int msg_type) {
        this.msg_type = msg_type;
    }


    public CpMessageEvent(int msg_type, Object msg_content) {
        this.msg_content = msg_content;
        this.msg_type = msg_type;
    }

    public CpMessageEvent(boolean isLever) {
        this.isLever = isLever;
    }

    public CpMessageEvent(int msg_type, Object msg_content, boolean isLever) {
        this.msg_type = msg_type;
        this.msg_content = msg_content;
        this.isLever = isLever;
    }

    public CpMessageEvent setMsg_content(Object msg_content) {
        this.msg_content = msg_content;
        return this;
    }

    public Object getMsg_content() {
        return msg_content;
    }

    public int getMsg_type() {
        return msg_type;
    }

    public boolean isLever() {
        return isLever;
    }

    public void setLever(boolean lever) {
        isLever = lever;
    }

    @Override
    public String toString() {
        return "MessageEvent{" +
                "msg_content=" + msg_content +
                ", msg_type=" + msg_type +
                ", isLever=" + isLever +
                '}';
    }

    public Object getMsg_content_data() {
        return msg_content_data;
    }

    public void setMsg_content_data(Object msg_content_data) {
        this.msg_content_data = msg_content_data;
    }

    public boolean dataIsNotNull() {
        return msg_content_data != null;
    }

    public JSONObject getDataJson() {
        return (JSONObject) msg_content_data;
    }
}
