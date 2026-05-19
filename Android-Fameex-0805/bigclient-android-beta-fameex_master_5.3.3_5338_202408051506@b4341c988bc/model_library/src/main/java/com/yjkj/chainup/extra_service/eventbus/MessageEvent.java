package com.yjkj.chainup.extra_service.eventbus;

import org.json.JSONObject;

public class MessageEvent {

    public static final int data_req_error = 1;   //Data request failed, available for global processing

    public static final int collect_data_type = 2;   //Select or bookmark data events

    public static final int hometab_switch_type = 3;   //Home tab switching event

    public static final int color_rise_fall_type = 4;   //Color of fluctuation range

    public static final int symbol_switch_type = 5;   //Switch Currency Event

    public static final int TRANSFER_TYPE = 6;   //Buy or sell event type

    public static final int assetTabType = 7;   //Asset page tab switching

    public static final int coinSearchType = 8;   //Sidebar Coin Pair Search

    public static final int closeLeftCoinSearchType = 9;   //Close Sidebar Events

    public static final int login_operation_type = 10;   //Login Operation Event

    public static final int coin_payment = 11; //Spot trading or legal currency trading

    public static final int fait_trading = 12; //To trade

    public static final int left_coin_contract_type = 13; //Contract Sidebar

    public static final int refresh_trans_type = 14; //Asset page refresh

    public static final int refresh_local_trans_type = 15; //Partial refresh of asset page

    public static final int refresh_local_b2c_trans_type = 16; //Partial refresh of asset page

    public static final int refresh_local_coin_trans_type = 17; //Partial refresh of asset page

    public static final int refresh_local_b2c_coin_trans_type = 18; //Partial refresh of asset page


    public static final int refresh_local_contract_type = 19; //Partial refresh of asset page contract

    public static final int refresh_local_lever_type = 20; //Asset page leverage

    public static final int DEPTH_LEVEL_TYPE = 21; //Depth scale
    public static final int DEPTH_DATA_TYPE = 22; //Depth map data
    public static final int DEPTH_CONTRACT_DATA_TYPE = 220; //Data from contract depth maps

    public static final int CREATE_ORDER_TYPE = 23; //Order notification

    //Spot or lever
    public static final int TAB_TYPE = 24;

    public static final int into_transfer_activity = 25; //Enter the transfer page

    public static final int into_my_asset_activity = 26; //Is it fully open

    //Public static final int live_ Contract_ Asset_ BeanList=28// Home page jump


    public static final int coinTrade_tab_type = 29; //Spot trading page tab

    public static final int coinTrade_topTab_type = 30; //Spot trading page top spot tab

    public static final int leverTrade_topTab_type = 31; //Leverage tab at the top of the spot trading page

    public static final int assetsTab_type = 32; //Leverage tab at the top of the spot trading page

    public static final int assets_activity_finish_event = 33; //Home page jump

    public static final int contract_switch_type = 37;   //Contract tab switching event
    public static final int market_switch_type = 38;   //Contract tab switching event
    public static final int login_bind_type = 40;   //Login Operation Event
    public static final int market_switch_curTime = 399;   //Contract tab switching event
    public static final int webview_refresh_type = 41;   //Jump to login and refresh from the h5 page
    public static final int market_event_page_symbol_type = 42;   //Currency to tab switching
    public static final int home_event_page_symbol_type = 43;   //
    public static final int home_event_page_market_type = 44;   //
    public static final int sl_contract_select_leverage_event = 400;   //Contract switching leverage
    public static final int sl_contract_left_coin_type = 401;//Switch contract currency
    public static final int sl_contract_switch_time_type = 402;//Switching between K-line intervals

    public static final int hide_safety_advice = 403;//Hide security suggestions

    public static final int sl_contract_modify_margin_event = 50;//Modify margin
    public static final int sl_contract_modify_leverage_event = 52;//Modify lever
    public static final int sl_contract_change_tagPrice_event = 53;//Mark price changes, index price changes
    public static final int sl_contract_user_config_event = 54;//Contract user settings for submitting delegation
    public static final int sl_contract_cancel_order_event = 55;//Cancellation of orders
    public static final int sl_contract_rate_countdown_event = 56;//Countdown of fund rate
    public static final int sl_contract_position_num_event = 57;//Changes in the number of positions held
    public static final int sl_contract_cancel_last_price_event = 58;//Latest price changes
    public static final int sl_contract_change_coin_list_type = 59;//Latest price changes
    public static final int sl_contract_modify_position_margin_event = 60;//Adjust margin
    public static final int sl_contract_refresh_position_list_event = 61;//Refresh Position List
    public static final int sl_contract_create_account_event = 62;//Pop up the contract activation dialog box
    public static final int sl_contract_calc_switch_contract_event = 63;//Contract Calculator Switch Contract Notification
    public static final int sl_contract_sidebar_market_event = 64;//Sidebar Market
    public static final int sl_contract_first_show_info_event = 65;//First load contract information
    public static final int sl_contract_change_position_list_event = 66;//Change Bin List Data
    public static final int sl_contract_change_position_model_event = 67;//Change position mode
    public static final int sl_contract_change_unit_event = 68;//Change the display unit of the position
    public static final int sl_contract_login_status_event = 69;//Unregistered status change contract button
    public static final int sl_contract_first_input_last_price_event = 70;//Fill in the current price for the first time after switching contracts
    public static final int sl_contract_logout_event = 71;//After switching the contract, it was detected that the user was not logged in and cleared the data displayed on the original page
    public static final int sl_contract_new_status_event = 72;//New contract
    public static final int sl_contract_page_hide_event = 73;//Contract tab page hidden notification
    public static final int sl_contract_depth_level_event = 74;//Contract depth switching
    public static final int sl_contract_force_event = 75;//Compulsory use of new contracts
    public static final int sl_contract_receive_coupon = 76;//Receive simulation contract experience fee
    public static final int refresh_ws_error_change = 77;//Ws judgment
    public static final int grid_topTab_type = 78;//Receive simulation contract experience fee
    public static final int grid_data_update_type = 79;//Receive simulation contract experience fee
    public static final int refresh_ws_open_change = 90;//Ws Establish Link
    public static final int grid_changeHide_coin = 91;//Hide other currency pairs
    public static final int net_status_change = 92;//Network status monitoring
    public static final int sel_fiat_change = 93;//Quick coin purchase and selection of legal currency
    public static final int sel_coin_change = 94;//Quick coin buying and digital currency selection

    public static final int like_contract_optional_coin = 104;   //Contract currency pair optional
    public static final int like_coin_symbol_type = 102;   //Add Coin Pairs

    public static final int market_long_press = 105;   //Novice guidance [long press prompt]

    //Home Market Spot Contract Refresh
    public static final int market_updateList = 106;

    private boolean mBibi;//Is it a lever


    public static final int finish_page_event = 95;//Close all pages
    public static final int destroy_account_event = 96;//Logoff Event
    public static final int modify_account_pwd_event = 97;

    public static final int kline_loadmore_event = 107;
    public static final int kline_retry_event = 108;
    public static final int ws_backgroup_change_event = 109;
    public static final int login_success_event = 110;
    public static final int platform_auth_success_event = 111;

    public static final int refresh_reward_detail = 112;
    private MessageEvent() {
    }

    private Object msg_content;//Event content
    private Object msg_content_data;//Event content
    private int msg_type;//Event Type
    private boolean isLever;//Is it a lever
    private boolean isGrid;//Is it a lever
    private String coinFor;//From page

    public MessageEvent(int msg_type) {
        this.msg_type = msg_type;
    }


    public MessageEvent(int msg_type, Object msg_content) {
        this.msg_content = msg_content;
        this.msg_type = msg_type;
    }

    public MessageEvent(boolean isLever) {
        this.isLever = isLever;
    }

    public MessageEvent(int msg_type, Object msg_content, boolean isLever) {
        this.msg_type = msg_type;
        this.msg_content = msg_content;
        this.isLever = isLever;
    }
    public MessageEvent(int msg_type, Object msg_content, Object msg_content_data, boolean isBibi) {
        this.msg_type = msg_type;
        this.msg_content = msg_content;
        this.msg_content_data = msg_content_data;
        this.mBibi = isBibi;
    }
    public MessageEvent(int msg_type, Object msg_content, boolean isLever,boolean isGrid) {
        this.msg_type = msg_type;
        this.msg_content = msg_content;
        this.isLever = isLever;
        this.isGrid = isGrid;
    }

    public MessageEvent setMsg_content(Object msg_content) {
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

    public boolean isGrid() {
        return isGrid;
    }

    public void setGrid(boolean grid) {
        isGrid = grid;
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
                ", isGrid=" + isGrid +
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

    public String getCoinFor() {
        return coinFor;
    }

    public void setCoinFor(String coinFor) {
        this.coinFor = coinFor;
    }

    public boolean isBibi() {
        return !isLever && !isGrid;
    }

    public boolean ismBibi() {
        return mBibi;
    }

}
