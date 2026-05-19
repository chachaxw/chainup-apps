package com.chainup.contract.app;

/**
 * @Description: uniformNamingOfParameterVariables
 * @Author: wanghao
 * @CreateDate: 2019-09-23 10:33
 * @UpdateUser: wanghao
 * @UpdateDate: 2019-09-23 10:33
 * @UpdateRemark: updateDescription
 */
public class CpParamConstant {

    public static final String ADD_COIN_MAP = "add_coin_map";

    public static final String TYPE = "type";

    public static final String SEARCH_COIN_MAP = "search_coin_map";

    public static final String SEARCH_COIN_MAP_FOR_LEVER = "search_coin_map_for_lever";
    public static final String SEARCH_COIN_MAP_FOR_LEVER_UNREFRESH = "search_coin_map_for_lever_unRefresh";
    public static final String SEARCH_COIN_MAP_FOR_LEVER_INTO_TRANSFER = "SEARCH_COIN_MAP_FOR_LEVER_INTO_TRANSFER";


    public static final String html_url = "html_url";
    public static final String is_notice = "is_notice";
    public static final String is_homepageBar = "is_homepageBar";
    public static final String title = "title";

    public static final String assetTabType = "assetTabType";
    public static final String IS_ANNOUNCEMENT = "is_announcement";
    public static final String ID = "html_url";
    public static final String TITLE = "title";
    public static final String IS_NOTICE = "is_notice";
    public static final String IS_HOMEPAGE = "is_homepageBar";

    public static final String transferType = "transferType";
    public static final String homeTabType = "homeTabType";
    public static final String symbol = "symbol";
    public static final String COIN_SYMBOL = "coin_symbol";
    public static final String advertID = "advertID";

    public static final String BIBI_INDEX = "bibi";
    public static final String FABI_INDEX = "fabi";
    public static final String B2C_INDEX = "b2c";
    public static final String LONA_INDEX = "lona_index";
    public static final String CONTRACT_INDEX = "contract";
    public static final String LEVER_INDEX = "lever";
    public static final String CHOOSE_INDEX = "choose_index";
    public static final String JSON_BEAN = "json_bean";

    /*
     * definitionOfTradingConstantValue
     */
    public static final int TYPE_BUY = 0;
    public static final int TYPE_SELL = 1;
    public static final int UNLOCK_THE_DEAL = 2;

    /**
     * currencyTransactionConstant
     */
    public static final int TYPE_COIN = 1001;
    public static final int TYPE_FAIT = 1002;
    /**
     * Debit/credit page jump to currency pair
     */
    public static final int BORROW_TYPE = 9323;


    /* limitTrading */
    public static final int TYPE_LIMIT = 0;
    /* marketPriceTransaction */
    public static final int TYPE_MARKET = 1;


    /*
     * webPageParameters
     */
    public static final String web_url = "web_url";
    public static final String head_title = "head_title";
    public static final String web_type = "web_type";
    public static final String URL_4_SERVICE = "url_4_service";
    public static final String DIALING_CODE = "dialingCode"; // +86
    public static final String NUMBER_CODE = "numberCode"; // 156
    public static final String COUNTRY_NAME = "country_name";
    public static final String SPEED_WEB_API = "ApiSpeed";
    public static final String SPEED_WS_API = "WsSpeed";



    /*
     *Set password page parameters
     */
    public static final String taskType = "taskType";
    public static final String taskFrom = "taskFrom";
    public static final String SET_PWD = "SET_PWD";
    public static final String RESET_PWD = "RESET_PWD";
    public static final String FROM_LOGIN = "FROM_LOGIN";
    public static final String FROM_OTC = "FROM_OTC";

    public static final String VERIFY_TYPE = "VERIFY_TYPE";
    public static final int GOOGLE_TYPE = 0;
    public static final int MOBILE_TYPE = 1;
    public static final int MAIL_TYPE = 2;

    public static final int CURRENT_TYPE = 0;
    public static final int HISTORY_TYPE = 1;
    public static final int TRANSFER_TYPE = 2;


    /**
     * recharge
     */
    public static final String TRANSFER_DEPOSIT_RECORD = "deposit";
    /**
     * cashWithdrawal
     */
    public static final String TRANSFER_WITHDRAW_RECORD = "withdraw";


    public static final String TRANSFER_RECHARGE_RECORD = "recharge";
    /**
     * transfer
     */
    public static final String OTC_TRANSFER_RECORD = "otc_transfer";
    /**
     * contractTransfer
     */
    public static final String CONTRACT_TRANSFER_RECORD = "cp_contract_transfer";
    /**
     * leverTransfer
     */
    public static final String OTC_LEVER_TRANSFER_RECORD = "otc_transfer";


    /**
     * b2CSAccountInformation
     */
    public static final int TYPE_ADD = 0;
    public static final int TYPE_SEE = 1;
    public static final int TYPE_EDIT = 2;
    public static final String BANK_ID = "bank_id";
    public static final String WITHDRAW_ID = "withdraw_id";
    public static final String BANK_NAME = "bank_name";
    public static final String B2C_SYMBOL = "b2c_symbol";
    public static final String POSITION = "position";
    public static final String BANK_JSON = "bank_json";

    /**
     * Recharge, withdrawal, transfer and other related types
     */
    public static final String OPTION_TYPE = "option_type";
    public static final int RECHARGE = 0;
    public static final int WITHDRAW = 1;

    public static final int THE_CURRENT_LENDING = 0;
    public static final int APPLY_FOR_LOAN = 1;
    public static final int RETURN_THE_BORROWING = 2;
    public static final int RETURN_THE_INTEREST = 3;

    /**
     * loginPage
     */
    public static final int LOGIN_GOOOGLE = 0;
    public static final int LOGIN_PHONE = 1;
    public static final int LOGIN_EMAIL = 2;

    /**
     * fundAccountType
     */
    public static final String ASSET_ACCOUNT_TYPE = "asset_account_type";
    public static final String BIBI_ACCOUNT = "1"; //Currency account
    public static final String OTC_ACCOUNT = "2";
    public static final String CONTRACT_ACCOUNT = "3";
    public static final String LEVERAGE_ACCOUNT = "2";
    public static final String B2C_ACCOUNT = "5";


    /**
     * transferPage
     */
    public static final String TRANSFERSTATUS = "TRANSFERSTATUS";
    public static final String TRANSFERSYMBOL = "TRANSFERSYMBOL";
    public static final String TRANSFERCURRENCY = "TRANSFERCURRENCY";
    public static final String FROMBORROW = "FROMBORROW";
    public static final String BIBIACCOUNT = "1";
    public static final String OTCACCOUNT = "2";
    public static final String CONTRACTACCOUNT = "3";
    public static final String LEVERAGEACCOUNT = "2";

    public static final String TRANSFER_BIBI = "transfer_bibi";
    public static final String TRANSFER_OTC = "transfer_otc";
    public static final String TRANSFER_CONTRACT = "transfer_contract";
    public static final String TRANSFER_LEVER = "transfer_lever";


    public static final String TYPE_DEPOSIT = "deposit";
    public static final String TYPE_OTC_TRANSFER = "otc_transfer";
    public static final String TYPE_OTC_B2C = "type_otc_b2c";
    public static final String TYPE_OTC_LOAN = "type_otc_loan";

    /*
     * firstPageParameterNameDefinition
     */
    public static final String MARKET_NAME = "market_name";
    public static final String CUR_INDEX = "cur_index";

    /**
     * selectCurrency
     */
    public static final String COIN_TYPE = "COIN_TYPE";
    public static final String COIN_FROM = "COIN_FROM";

    /*
     * whetherTheLeverIsOpen
     */
    // public static final String isOpenLever = "isOpenLever";
    public static final String ORDER_ID = "order_id";


    public static final String ASSET_OPEN = "open";


    public static final String COIN_TRADE_TAB_INDEX = "coin_trade_tab_index";   //Currency tab
    public static final int CVC_INDEX_TAB = 0;  //Currency tab
    public static final int LEVER_INDEX_TAB = 1; //Lever tab

    /*
     * realNameAuthentication
     */
    public static final String AREA_NUMBER = "AREA_NUMBER";
    public static final String AREA_COUNTRY = "AREA_COUNTRY";
    public static final String AREA_CODE = "AREA_CODE";
    /**
     * accuracy
     */
    public static final int NORMAL_PRECISION = 8;
    public static final int NORMAL_EDITTEXT = 3;


    /**
     * homePageConfiguration
     */

    public static final String DEFAULT_HOME_PAGE = "1";
    public static final String INTERNATIONAL_HOME_PAGE = "2";
    public static final String JAPAN_HOME_PAGE = "3";
    public static final String CONTRACT_HOME_PAGE = "4";


    /**
     * Market page judges whether the recycleView is sliding
     */
    public static final int ONSCROLLSTATECHANGED = 0;

    /**
     * fastLoginExpiresAndNeedsToLogInAgain
     */
    public static final int QUICK_LOGIN_FAILURE = 104008;

    public static final String INDEX_NAME = "INDEX_NAME";


    /**
     * detailsOfHistoricalEntrustment
     */
    public static final String DEAL_VOLUME ="deal_volume";
    public static final String HISTORY_SIDE ="side";
    public static final String AVG_PRICE ="avg_price";
    public static final String DEAL_MONEY ="deal_money";
    public static final String HISTORY_ENTURST="2";
    public static final String CURRENT_ENTURST="1";

    public static final String ENTRUST_ID ="entrust_id";


    public static final String BASE_COIN ="baseCoin";
    public static final String COUNT_COIN ="countCoin";




    public static final String AUTHENTICATION_STATUS = "authentication_status";

    /**
     * realNameAuthentication
     */
    public static final String AUTH_SUCCESS = "0";
    public static final String DEFAULT_NAME_ERROR = "1";
    public static final String DEFAULT_ID_NUMBER_ERROR = "2";
    public static final String NUMBER_OUT_ERROR = "3";
    public static final String MFILENAME = "cert.cer";

    public static final String MY_INVITATION = "my_invitation";
    public static final String INVITE_REWARDS = "invite_rewards";
    public static final String CUR_HOME_COINS = "cur_home_coins";
}

