package com.yjkj.chainup.db.service;


import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatDelegate;

import android.net.Uri;
import android.text.TextUtils;
import android.util.Log;
import android.util.Pair;

import com.chainup.contract.utils.CpBigDecimalUtils;
import com.chainup.contract.utils.CpClLogicContractSetting;
import com.yjkj.chainup.R;
import com.yjkj.chainup.app.AppConfig;
import com.yjkj.chainup.app.ChainUpApp;
import com.yjkj.chainup.bean.coin.CoinMapBean;
import com.yjkj.chainup.db.MMKVDb;
import com.yjkj.chainup.db.constant.ParamConstant;
import com.yjkj.chainup.extra_service.eventbus.MessageEvent;
import com.yjkj.chainup.extra_service.eventbus.NLiveDataUtil;
import com.yjkj.chainup.manager.DataManager;
import com.yjkj.chainup.manager.NCoinManager;
import com.yjkj.chainup.net.api.ApiConstants;
import com.yjkj.chainup.net_new.JSONUtil;
import com.yjkj.chainup.util.DateUtils;
import com.yjkj.chainup.util.DecimalUtil;
import com.yjkj.chainup.util.LogUtil;
import com.yjkj.chainup.util.StringOfExtKt;
import com.yjkj.chainup.util.StringUtil;
import com.yjkj.chainup.util.SystemUtils;
import com.yjkj.chainup.util.Utils;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.net.URI;
import java.net.URL;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.Set;
import java.util.stream.Collectors;

/**
 * @Description:
 * @Author: wanghao
 * @CreateDate: 2019-08-09 12:26
 * @UpdateUser: wanghao
 * @UpdateDate 2023-08-09 12:26
 *@ UpdateRemark: Update Description
 */
public class PublicInfoDataService {

    private static final String TAG = "PublicInfoDataService";
    private static final String key = "publicInfoV4";
    private static final String publicInfoMarket = "publicInfoMarket";
    private static final String REQ_REVIEW = "req_review";
    private static final String CUR_COIN_MAP = "current_coin_map";
    private static final String CUR_COIN_MAP_LEVER = "current_coin_map_lever";
    private static final String CURRENT_COIN_MAP_GRID = "current_coin_map_grid";
    private static final String SHOW_ASSET_VIEW = "show_asset_view";
    private static final String DEPTH_TYPE = "depth_type";
    public static final String LEVEL_DEPTH_TYPE = "level_depth_type";

    public static final String CHANGE_HOST = "change_host";
    public static final String CHANGE_CP_HOST = "change_host";
    public static final String CHANGE_HOST_WS = "change_host_ws";
    public static final String CHANGE_HOST_CP_WS = "change_host_cp_ws";

    public static final String ONLINE_STRING_TEXT = "online_string_text";

    private static final String HOMEPAGE_SHOW_DIALOG_STATUS = "homepage_show_dialog_status";
    private static final String LEVER_SHOW_DIALOG_STATUS = "lever_show_dialog_status";
    private static final String ETF_STATE_DIALOG_STATUS = "etf_state_dialog_status";
    private static final String GRID_STATE_DIALOG_STATUS = "grid_state_dialog_status";
    private static final String PRIVATE_SHOW_DIALOG_STATUS = "private_show_dialog_status";

    private static final String BIND_CLIENT_ID = "client_id";

    private static final String HOME_TOP_SYMBOL = "header_symbol";

    private static JSONObject cachObj;

    private static JSONObject cachPublicObj;
    /**
     *Display mode of the app
     */
    private static final String SHOW_THEME_MODE = "theme_mode";
    private static final String SHOW_KLINETHEME_MODE = "theme_kline_mode";
    /**
     *Save it or not
     */
    private static final String SAVE_CET_DATA = "save_cet_data";

    /**
     *Save new contract or not
     */
    private static final String SAVE_CONTRACT_DATA = "save_new_contract";

    private static final String IS_SHOW_UPDATE_BOX = "is_show_update_box";

    /**
     *0- Day mode
     */
    public static final int THEME_MODE_DAYTIME = 0;
    /**
     *1- Light-on-dark color scheme
     */
    public static final int THEME_MODE_NIGHT = 1;

    //The contract mode defaults to -1 as the old version contract
    public static final int CONTRACT_MODE_DEFAULT = 1;

    /**
     *Save it or not
     */
    private static final String SAVE_CET_COMPANYID_DATA = "save_cet_companyID_data";

    private MMKVDb mMMKVDb;

    private PublicInfoDataService() {
        mMMKVDb = new MMKVDb();
    }

    private static PublicInfoDataService mPublicInfoDataService;

    public static PublicInfoDataService getInstance() {
        if (null == mPublicInfoDataService) {
            mPublicInfoDataService = new PublicInfoDataService();
        }
        return mPublicInfoDataService;
    }


    public void saveData(JSONObject data) {
        if (null != data) {
            cachObj = data;
            mMMKVDb.saveData(key, data.toString());
            boolean isForce = isNewForceContract();
            LogUtil.e("LogUtils", "saveData  重新配置新合约 " + isForce);
            if (isForce) {
                MessageEvent event = new MessageEvent(MessageEvent.sl_contract_force_event);
                NLiveDataUtil.postValue(event);
            }
            CpClLogicContractSetting.setInviteUrl(data.optString("sharingPage"));
        }
    }

    public JSONObject getData() {
        JSONObject data = null;
        String dataStr = mMMKVDb.getData(key);
        if (StringUtil.checkStr(dataStr)) {
            try {
                data = new JSONObject(dataStr);
            } catch (JSONException e) {
                e.printStackTrace();
                data = new JSONObject();
            }
        }
        return data;
    }

    public void saveCetData(String data) {
        if (null != data) {
            mMMKVDb.saveData(SAVE_CET_DATA, data);
        }
    }

    public JSONObject getCetData() {
        JSONObject data = null;
        String dataStr = mMMKVDb.getData(SAVE_CET_DATA);
        if (StringUtil.checkStr(dataStr)) {
            try {
                data = new JSONObject(dataStr);
            } catch (JSONException e) {
                e.printStackTrace();
                data = new JSONObject();
            }
        }
        return data;
    }

    /**
     *Obtain domain name
     *
     * @return
     */
    public String getDoMain() {
        JSONObject json = getCetData();
        if (null == json || json.length() == 0) {
            return "";
        }
        return json.optString("saas_domain", "");
    }

    public String getTextDoMain() {
        JSONObject jsonObject = getCetData();
        if (null == jsonObject || jsonObject.length() == 0) {
            return "";
        }
        return jsonObject.optString("test_list", "");
    }

    /**
     *Obtain whether to use local cet
     *
     * @return
     */
    public String getLinks() {
        JSONObject json = getCetData();
        if (null == json || json.length() == 0) {
            return "";
        }
        return json.optString("links", "");
    }


    /**
     *Obtain whether to use local cet
     *
     * @return
     */
    public boolean getAndroidOnline() {
        JSONObject json = getCetData();
        if (null == json || json.length() == 0) {
            return false;
        }
        return json.optBoolean("android_on", false);
    }


    /**
     *Return to homepage advertising space for new
     */
    public JSONObject getCustomConfig(JSONObject data) {
        data = getData(data);
        if (null != data) {
            return data.optJSONObject("custom_config");
        }
        return null;
    }

    /**
     *Obtain cet download address
     *
     * @return
     */
    public String getCetUrl() {
        return "https://chainup-ui.oss-cn-beijing.aliyuncs.com/ioscer.cer";
    }

    /**
     *Obtain which cet to use
     *
     * @return
     */
    public String getCet() {
        JSONObject json = getCetData();
        if (null == json || json.length() == 0) {
            return "";
        }
        return json.optString("saas_cer_fileName", "");
    }

    /**
     *Get Special List
     *
     * @return
     */
    public ArrayList<JSONObject> getSpecialList() {
        JSONObject json = getCetData();
        if (null == json || json.length() == 0) {
            return null;
        }
        JSONArray jsonArray = json.optJSONArray("special_list");
        if (null == jsonArray || jsonArray.length() == 0) {
            return null;
        }
        return JSONUtil.arrayToList(jsonArray);
    }

    /**
     *Get Special List
     *
     * @return
     */
    public ArrayList<JSONObject> getTextList() {
        JSONObject json = getCetData();
        if (null == json || json.length() == 0) {
            return null;
        }
        JSONArray jsonArray = json.optJSONArray("test_list");
        if (null == jsonArray || jsonArray.length() == 0) {
            return null;
        }
        return JSONUtil.arrayToList(jsonArray);
    }


    public String getCerName() {
        ArrayList<JSONObject> textList = getTextList();
        for (JSONObject json : textList) {
            if (null != json && json.length() > 0) {
                if (json.optString("host").equals(Utils.getAPIHostInsideString(ChainUpApp.appContext.getApplicationContext().getString(R.string.baseUrl)))) {
                    return json.optString("saas_cer_fileName");
                }
            }
        }
        return "";
    }

    public String getTestDomain() {
        ArrayList<JSONObject> textList = getTextList();
        if (null == textList) return "";
        for (JSONObject json : textList) {
            if (null != json && json.length() > 0) {
                if (json.optString("host").equals(Utils.getAPIHostInsideString(ChainUpApp.appContext.getApplicationContext().getString(R.string.baseUrl)))) {
                    return json.optString("saas_domain");
                }
            }
        }
        return "";
    }


    /*
     *Return the outermost data object
     */
    public JSONObject getData(JSONObject data) {
        if (null == data) {
            if (null != cachObj && cachObj.length() > 0)
                return cachObj;
            String dataStr = mMMKVDb.getData(key);
            if (StringUtil.checkStr(dataStr)) {
                try {
                    return cachObj = new JSONObject(dataStr);
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        } else {
            cachObj = data;
        }
        return data;
    }


    /**
     *Store network data data
     *
     * @param
     * @return
     */
    public void saveOnlineText(String data) {
        if (null != data) {
            mMMKVDb.saveData(ONLINE_STRING_TEXT, data);
        }
    }

    /**
     *Obtain network data
     *
     * @param
     * @return
     */
    public JSONObject getOnlineText() {
        String onlineText = mMMKVDb.getData(ONLINE_STRING_TEXT);
        if (StringUtil.checkStr(onlineText)) {
            try {
                return new JSONObject(onlineText);
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }
        return null;
    }


    /*
     *Transfer outermost data object C
     * return coinList
     */
    public @Nullable
    JSONObject getCoinList(JSONObject data) {
        data = getMarketData(data);
        if (null != data) {
            return data.optJSONObject("coinList");
        }
        return null;
    }

    /**
     *From coin list
     *
     * @param data
     * @return
     */
    public JSONObject getFollowCoinList(JSONObject data) {
        data = getMarketData(data);
        if (null != data) {
            return data.optJSONObject("followCoinList");
        }
        return null;
    }

    public JSONObject getAppPersonalIcon(JSONObject data) {
        data = getData(data);
        if (null != data) {
            JSONObject obj = data.optJSONObject("app_personal_icon");
            if(obj!=null){
                return obj;
            }
        }
        return new JSONObject();
    }

    //1 displayed, 0 not displayed
    public Boolean getUsdtOmniIsOpen(JSONObject data) {
        data = getData(data);
        if (null != data) {
            return data.optString("usdt_open_omni").equals("1");
        }
        return false;
    }

    public String getfuturesType(JSONObject data) {
        data = getData(data);
        if (null != data) {
            return data.optString("futuresType");
        }
        return "0";
    }

    /**
     *Find the slave currency object under the corresponding {name} based on ${name}
     *
     *@param name Principal currency name
     * @return
     */
    public JSONObject getFollowCoinJSONObjectByMainCoinName(String name) {
        JSONObject json = getFollowCoinList(null);
        if (null != json) {
            return json.optJSONObject(name);
        }
        return new JSONObject();
    }

    /**
     *Return the corresponding slave currency list based on the main chain currency
     *
     * @param name
     * @return
     */
    public ArrayList<JSONObject> getFollowCoinsByMainCoinName(String name,String type) {
        JSONObject followCoinListJSONObject = getFollowCoinJSONObjectByMainCoinName(name);
        ArrayList<JSONObject> objs = new ArrayList<>();
        if (followCoinListJSONObject != null) {
            Iterator<String> keys = followCoinListJSONObject.keys();
            
            while (keys.hasNext()) {
                String next = keys.next();
                JSONObject followCoinJson = followCoinListJSONObject.optJSONObject(next);
                if (followCoinJson.optString("mainChainName").equals("OMNI")){
                    if (getUsdtOmniIsOpen(null)){
                        //Determine whether to enable charging and lifting
                        if (type.equals("withdraw")){
                            //withdraw
                            if (followCoinJson.optString("withdrawOpen").equals("1")){
                                objs.add(followCoinListJSONObject.optJSONObject(next));
                            }
                        }else  if (type.equals("deposit")){
                            //deposit
                            if (followCoinJson.optString("depositOpen").equals("1")){
                                objs.add(followCoinListJSONObject.optJSONObject(next));
                            }
                        }else {
                            //Add Address
                            objs.add(followCoinListJSONObject.optJSONObject(next));
                        }
                    }
                }else {
                    if (type.equals("withdraw")){
                        //withdraw
                        if (followCoinJson.optString("withdrawOpen").equals("1")){
                            objs.add(followCoinListJSONObject.optJSONObject(next));
                        }
                    }else  if (type.equals("deposit")){
                        //deposit
                        if (followCoinJson.optString("depositOpen").equals("1")){
                            objs.add(followCoinListJSONObject.optJSONObject(next));
                        }
                    }else {
                        //Add Address
                        objs.add(followCoinListJSONObject.optJSONObject(next));
                    }
                }
            }
        }
        return DecimalUtil.sortByMultiOptions(objs, "sort", "mainChainName", false);

    }


    public JSONObject getCoinByName(String name) {
        JSONObject json = getCoinList(getMarketData(null));
        if (null != json) {
            return json.optJSONObject(name);
        }
        return new JSONObject();
    }


    /*
     * emailOptCode
     */
    public @Nullable
    JSONObject getEmailOptCode(JSONObject data) {
        data = getData(data);
        if (null != data) {
            return data.optJSONObject("emailOptCode");
        }
        return null;
    }

    /*
     * smsOptCode
     */
    public @Nullable
    JSONObject getSmsOptCode(JSONObject data) {
        data = getData(data);
        if (null != data) {
            return data.optJSONObject("smsOptCode");
        }
        return null;
    }

    /*
     *  klineColor
     */
    public @Nullable
    JSONObject getKlineColor(JSONObject data) {
        data = getData(data);
        if (null != data) {
            return data.optJSONObject("klineColor");
        }
        return null;
    }

    /*
     *  rate
     */
    public @Nullable
    JSONObject getRate(JSONObject data) {
        data = getData(data);
        if (null != data) {
            return data.optJSONObject("rate");
        }
        return null;
    }


    /*
     *lan
     */
    public @Nullable
    JSONObject getLan(JSONObject data) {
        data = getData(data);
        if (null != data) {
            return data.optJSONObject("lan");
        }
        return null;
    }

    public String getDefLan(){
        JSONObject jsonObject = getLan(null);
        if (null == jsonObject) return "";
        return jsonObject.optString("defLan");
    }

    public ArrayList<JSONObject> getLanList() {
        JSONObject jsonObject = getLan(null);

        if (null == jsonObject)
            return new ArrayList<JSONObject>();

        JSONArray jsonArray = jsonObject.optJSONArray("lanList");

        if (null == jsonArray) {
            return new ArrayList<JSONObject>();
        }
        ArrayList<JSONObject> lanlist = new ArrayList<>();
        for (int i = 0; i < jsonArray.length(); i++) {
            lanlist.add(jsonArray.optJSONObject(i));
        }
        return lanlist;
    }

    /*
     * klineScale
     */
    public @Nullable
    JSONArray getKlineScale(@Nullable JSONObject data) {
        data = getData(data);
        if (null != data) {
            return data.optJSONArray("klineScale");
        }
        return null;
    }

    /*
     *  marketSort
     */
    public @Nullable
    JSONArray getMarketSort(@Nullable JSONObject data) {
        data = getMarketData(data);
        if (null != data) {
            return data.optJSONArray("marketSort");
        }
        return null;
    }

    public ArrayList<String> getMarketSortList(@Nullable JSONObject data) {
        data = getMarketData(data);
        JSONArray sortList = new JSONArray();
        ArrayList<String> marketSortList = new ArrayList<>();
        if (null != data) {
            sortList = data.optJSONArray("marketSort");
        }
        if (null == sortList) {
            return marketSortList;
        }
        if (sortList.length() > 0) {
            for (int i = 0; i < sortList.length(); i++) {
                marketSortList.add(sortList.optString(i));
            }
        }
        return marketSortList;
    }

    public @Nullable
    JSONObject getSafeWithdraw(@Nullable JSONObject data) {
        data = getData(data);
        if (null != data) {
            return data.optJSONObject("update_safe_withdraw");
        }
        return null;
    }

    public @Nullable
    String getSafeWithdrawHour(@Nullable JSONObject data) {
        data = getData(data);
        if (null != data) {
          JSONObject sateConfig=  data.optJSONObject("update_safe_withdraw");
            if (!sateConfig.optString("is_open").equals("1")) {
                return "48";
            }
            String hour = sateConfig.optString("hour");
            if (CpBigDecimalUtils.greaterThan(hour,"0") && CpBigDecimalUtils.compareTo(hour,"100")<=0){
                return sateConfig.optString("hour");
            }
            return "48";
        }
        return "48";
    }

    /*
     *  market
     */
    public @Nullable
    JSONObject getMarket(@Nullable JSONObject data) {
        data = getMarketData(data);
        if (null != data) {
            return data.optJSONObject("market");
        }
        return null;
    }

    /*
     *Coin Pairs by Group
     *
     *@param isShow true returns the currency pair corresponding to isShow
     */
    public @Nullable
    ArrayList<JSONObject> getSymbols(@Nullable String marketName) {
        if (null == marketName)
            return null;
        JSONObject market = getMarket(null);
        if (null != market && market.length() > 0) {
            ArrayList<JSONObject> list = JSONUtil.jsonObjtoList(market.optJSONObject(marketName));
            ArrayList<JSONObject> newList = new ArrayList<JSONObject>();
            if (null == list) {
                return newList;
            }
            for (JSONObject it : list) {
                try {
                    it.put("isFirst", false);
                    newList.add(it);
                } catch (JSONException e) {
                    e.printStackTrace();
                }
            }
            return newList;
        }
        return null;
    }

    /*
     * app_logo_list
     */
    public @Nullable
    JSONObject getApp_logo_list(@Nullable JSONObject data) {
        data = getData(data);
        if (null != data) {
            return data.optJSONObject("app_logo_list");
        }
        return null;
    }

    /*
     * app_logo_list_new
     *
     * return string[0]=logo_black
     */
    public @Nullable
    String[] getApp_logo_list_new(@Nullable JSONObject data) {
        data = getData(data);
        if (null != data) {
            data = data.optJSONObject("app_logo_list_new");
            if (null != data) {
                String logo_black = data.optString("logo_black", "");
                String logo_white = data.optString("logo_white", "");
                return new String[]{logo_black, logo_white};
            }
        }
        return null;
    }

    /**
     *Whether to enable currency introduction
     */
    public boolean isSymbolProfile(@Nullable JSONObject data) {
        data = getData(data);
        if (null != data)
            return "1".equals(data.optString("symbol_profile"));
        return false;
    }

    /**
     *Enable grid or not
     */
    public boolean isGridTradSwitch(@Nullable JSONObject data) {
        data = getData(data);
        if (null != data)
            return "1".equals(data.optString("grid_trade_switch"));
        return false;
    }

    /**
     * coinsymbol_introduce_names
     *Currency Introduction
     */
    public ArrayList<String> getCoinsymbolIntroduceNames(@Nullable JSONObject data) {
        ArrayList<String> list = new ArrayList<>();
        data = getData(data);
        if (null != data) {
            JSONArray introduceNames = data.optJSONArray("coinsymbol_introduce_names");
            if (introduceNames != null && introduceNames.length() > 0) {
                for (int i = 0; i < introduceNames.length(); i++) {
                    list.add(introduceNames.optString(i));
                }
            }
        }
        return list;
    }


    /*
     * kline_background_logo_img
     */
    public String getKline_background_logo_img(JSONObject data, Boolean isDaytime) {
        data = getData(data);
        if (null != data) {
            JSONObject jsonObject = data.optJSONObject("kline_background_logo_img");
            if (jsonObject != null) {
                if (isDaytime) {
                    return jsonObject.optString("app_img", "");
                } else {
                    return jsonObject.optString("app_img_night", "");
                }
            }
        }
        return "";
    }

    public String getKline_background_logo_img(JSONObject data, Integer theme, Boolean iskline) {
        data = getData(data);
        if (null != data) {
            JSONObject jsonObject = data.optJSONObject("kline_background_logo_img");
            if (jsonObject != null) {
                if (theme == 0) {
                    return jsonObject.optString("app_img", "");
                } else if (theme == 1) {
                    return jsonObject.optString("app_img_night", "");
                } else {
                    if (iskline) {
                        return jsonObject.optString("app_img_night", "");
                    } else {
                        return jsonObject.optString("app_img", "");
                    }
                }
            }
        }
        return "";
    }


    /**
     *Obtain logo
     */
    public String getLogo4Service(Boolean isDaytime) {
        if (isDaytime) {
            return "https://saas-oss.oss-cn-hongkong.aliyuncs.com/upload/20200225201410334.png";
        } else {
            return "https://saas-oss.oss-cn-hongkong.aliyuncs.com/upload/20200225201425685.png";
        }
    }

    /**
     *Obtain if there are any off-site activities
     */
    public boolean otcOpen(@Nullable JSONObject data) {
        data = getData(data);
        if (null != data)
            return "1".equals(data.optString("otcOpen"));
        return false;
    }

    /**
     * @return is ? all account is close status,only has spot account
     * */
    public boolean isOnlySpot(){
        boolean otcOpen = otcOpen(null);
        boolean leverOpen = isLeverOpen(null);
        boolean contractOpen = contractOpen(null);
        return !otcOpen && !leverOpen && !contractOpen;
    }

    /**
     * @return is open scan qrcode to login?
     * */
    public boolean isScanQRLoginOpen(@Nullable JSONObject data){
        data = getData(data);
        if (null != data)
            return "1".equals(data.optString("QRLogin"));
        return false;
    }

    /**
     *Is the transaction restriction enabled
     */
    public boolean isHasTradeLimitOpen(@Nullable JSONObject data) {
        data = getData(data);
        if (null != data)
            return "1".equals(data.optString("has_trade_limit_open"));
        return false;
    }

    /**
     *Online customer service
     */
    public String getOnlineService(@Nullable JSONObject data) {
        data = getData(data);
        if (null != data)
            return data.optString("online_service_url");
        return "";
    }

    /**
     *Which method is used to upload images
     */
    public String getUploadImgType(@Nullable JSONObject data) {
        data = getData(data);
        if (null != data)
            return data.optString("app_upload_img_type");
        return "";
    }

    /**
     *Configured International Code
     */
    public String getDefaultCountryCodeReal(@Nullable JSONObject data) {
        data = getData(data);
        if (null != data)
            return data.optString("default_country_code_real");
        return "";
    }

    /**
     *Minimum assets
     */
    public String getMinHoldAccount(@Nullable JSONObject data) {
        data = getData(data);
        if (null != data)
            if(data.isNull("minHoldAccount")){
                return "0";
            }else {
                return String.valueOf(data.optDouble("minHoldAccount"));
            }
        return "0";
    }


    /**
     *Obtain countries that need to be blocked
     *
     * @param data
     * @return
     */
    public ArrayList<String> getLimitCountryList(@Nullable JSONObject data) {
        data = getData(data);
        ArrayList<String> limitCountry = new ArrayList<>();
        if (null != data) {
            JSONArray jsonArray = data.optJSONArray("limitCountryList");
            if (null != jsonArray) {
                for (int i = 0; i < jsonArray.length(); i++) {
                    limitCountry.add(jsonArray.optString(i));
                }
            }
        }
        return limitCountry;
    }

    /**
     *Get default country
     */
    public String getDefaultCountryCode(@Nullable JSONObject data) {
        data = getData(data);
        if (null != data) {
            return data.optString("default_country_code");
        }
        return "";
    }

    /**
     *Obtain contract broker instructions
     */
    public String getAgentUrl(@Nullable JSONObject data) {
        data = getData(data);
        if (null != data) {
            return data.optString("co_agent_noticeUrl");
        }
        return "";
    }


    /**
     *Obtain B2C switch
     */
    public boolean getB2CSwitchOpen(JSONObject data) {
        data = getData(data);
        if (null != data) {
            return data.optString("fiat_trade_open", "") == "1";
        }
        return true;
    }

    /**
     *Obtain registration SMS
     */
    public String getUserRegType(JSONObject data) {
        data = getData(data);
        if (null != data) {
            return data.optString("user_reg_type", "");
        }
        return "";
    }


    /**
     *Obtain whether to enable polar verification
     *0- None
     *1- Alibaba (APP not currently available)
     *2- Pole test
     */
    public int getVerifyType(@Nullable JSONObject data) {
        data = getData(data);
        if (null != data)
            return data.optInt("verificationType");
        return 0;
    }

    /**
     *Obtain and enable third-party identity verification
     */
    public boolean isInterfaceSwitchOpen(@Nullable JSONObject data) {
        data = getData(data);
        if (null != data)
            return "1".equals(data.optString("interfaceSwitch"));
        return false;
    }


    /**
     *Obtain if there is a contract
     */
    public boolean contractOpen(@Nullable JSONObject data) {
        data = getData(data);
        if (null != data)
            return "1".equals(data.optString("contractOpen"));
        return false;
    }

    /**
     *Obtain whether there is a contract gift
     */
    public boolean contractCouponOpen(@Nullable JSONObject data) {
        data = getData(data);
        if (null != data) {
            JSONObject coCouponSwitchObject = data.optJSONObject("coCouponSwitch");
            if (coCouponSwitchObject != null) {
                return "1".equals(coCouponSwitchObject.optString("status"));
            }
        }
        return false;
    }

    /**
     *Obtain contract bonus configuration
     */
    public String getContractCouponUrl(@Nullable JSONObject data) {
        data = getData(data);
        if (null != data) {
            JSONObject coCouponSwitchObject = data.optJSONObject("coCouponSwitch");
            if (coCouponSwitchObject != null) {
                return coCouponSwitchObject.optString("url");
            }
        }
        return "";
    }

    /**
     *Get Red Packet Switch
     */
    public boolean isRedPacketOpen(@Nullable JSONObject data) {
        data = getData(data);
        if (null != data)
            return "1".equals(data.optString("red_packet_open"));
        return false;
    }

    public boolean isEnforceGoogleAuth(@Nullable JSONObject data) {
        data = getData(data);
        if (null != data)
            return "1".equals(data.optString("is_enforce_google_auth"));
        return false;
    }

    public boolean appIndexAssetsOpen(JSONObject data) {
        data = getData(data);
        if (null != data)
            return "0".equals(data.optString("appIndex_assets_open"));
        return false;
    }


    /**
     *Obtain KYC configuration
     * <p>
     *Limit enumeration of switches for each module
     *
     * @param data
     * @return
     */
    public String getkycLimitConfig(JSONObject data) {
        data = getData(data);
        if (null != data) {
            return data.optString("kycLimitConfig", "");
        }
        return null;
    }

    /**
     *Spot withdrawal switch
     *
     * @return
     */
    public Boolean getWithdrawKycOpen() {
        String keyLimit = getkycLimitConfig(null);
        if (null == keyLimit || keyLimit.length() <= 0) return false;
        try {
            JSONObject json = new JSONObject(keyLimit);
            if (json != null) {
                return "1".equals(json.optString("withdraw_kyc_open"));
            } else {
                return false;
            }
        } catch (JSONException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     *Spot trading switch
     *
     * @return
     */
    public Boolean getExchangeTradeKycOpen() {
        String keyLimit = getkycLimitConfig(null);
        if (null == keyLimit || keyLimit.length() <= 0) return false;
        try {
            JSONObject json = new JSONObject(keyLimit);
            if (json != null) {
                return "1".equals(json.optString("exchange_trade_kyc_open"));
            } else {
                return false;
            }
        } catch (JSONException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     *Leveraged trading switch
     *
     * @return
     */
    public Boolean getLeverTradeKycOpen() {
        String keyLimit = getkycLimitConfig(null);
        if (null == keyLimit || keyLimit.length() <= 0) return false;
        try {
            JSONObject json = new JSONObject(keyLimit);
            if (json != null) {
                return "1".equals(json.optString("lever_trade_kyc_open"));
            } else {
                return false;
            }
        } catch (JSONException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     *Spot recharge switch
     *
     * @return
     */
    public Boolean getDepositeKycOpen() {
        String keyLimit = getkycLimitConfig(null);
        if (null == keyLimit || keyLimit.length() <= 0) return false;
        try {
            JSONObject json = new JSONObject(keyLimit);
            if (json != null) {
                return "1".equals(json.optString("deposite_kyc_open"));
            } else {
                return false;
            }
        } catch (JSONException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     *Contract transfer
     *
     * @return
     */
    public Boolean getContractTransferKycOpen() {
        String keyLimit = getkycLimitConfig(null);
        if (null == keyLimit || keyLimit.length() <= 0) return false;
        try {
            JSONObject json = new JSONObject(keyLimit);
            if (json != null) {
                return "1".equals(json.optString("contract_transfer_kyc_open"));
            } else {
                return false;
            }
        } catch (JSONException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     *Optional currency pair switch
     */
    public boolean isOptionalSymbolServerOpen(@Nullable JSONObject data) {
        data = getData(data);
        if (null != data)
            return "1".equals(data.optString("optional_symbol_server_open"));
        return false;
    }


    public void setCurrentCoinMapName(@Nullable String coinMap) {
        if (!TextUtils.isEmpty(coinMap)) {
            mMMKVDb.saveData(CUR_COIN_MAP, coinMap);
        }
    }

    /**
     *TODO needs to be modified by Cheng Ge here
     *Corresponding publicInfo
     *
     * @return
     */
    public CoinMapBean getCurrentCoinMap() {
        String coinMapName = mMMKVDb.getData(CUR_COIN_MAP);
        return DataManager.Companion.getCoinMapBySymbol(coinMapName);
    }

    public void setShowAssetStatus(Boolean status) {
        mMMKVDb.saveBooleanData(SHOW_ASSET_VIEW, status);
    }

    public Boolean getShowAssetStatus() {
        return mMMKVDb.getBooleanData(SHOW_ASSET_VIEW, false);
    }


    /**
     *Store all currency pair information for the first time
     *
     * @param data
     */
    public void saveReqData(String data) {
        mMMKVDb.saveData(REQ_REVIEW, data);
    }

    public JSONObject getReqData() {
        String data = mMMKVDb.getData(REQ_REVIEW);
        if (!TextUtils.isEmpty(data)) {
            try {
                return new JSONObject(data);
            } catch (JSONException e) {
                e.printStackTrace();
                return new JSONObject();
            }
        } else {
            return new JSONObject();
        }
    }


    /**
     *Direction of buying and selling orders
     */
    public void setDepthType(Boolean isHorizontal) {
        mMMKVDb.saveBooleanData(DEPTH_TYPE, isHorizontal);
    }

    public Boolean isHorizontalDepth() {
        return mMMKVDb.getBooleanData(DEPTH_TYPE, true);
    }


    /**
     *Direction of buying and selling orders
     */
    public void saveNewWorkURL(String isHorizontal) {
        mMMKVDb.saveData(CHANGE_HOST, isHorizontal);
    }

    public String getNewWorkURL() {
        String getNewWorkURL = mMMKVDb.getData(CHANGE_HOST);
        return getNewWorkURL;
    }
    public void saveCpNewWorkURL(String isHorizontal) {
        mMMKVDb.saveData(CHANGE_CP_HOST, isHorizontal);
    }

    public String getCpNewWorkURL() {
        String getNewWorkURL = mMMKVDb.getData(CHANGE_CP_HOST);
        return getNewWorkURL;
    }


    /**
     *Leveraged buying and selling direction
     *
     * @param isHorizontal
     */
    public void setDepthType4Lever(boolean isHorizontal) {
        mMMKVDb.saveBooleanData(LEVEL_DEPTH_TYPE, isHorizontal);

    }

    public boolean isHorizontalDepth4Lever() {
        return mMMKVDb.getBooleanData(LEVEL_DEPTH_TYPE, true);
    }


    /**
     *Display mode of the app
     */
    public void setThemeMode(int mode) {
        mMMKVDb.saveIntData(SHOW_THEME_MODE, mode);
        CpClLogicContractSetting.setThemeMode(mode);
        if (mode == THEME_MODE_NIGHT) {
            AppCompatDelegate.setDefaultNightMode(AppCompatDelegate.MODE_NIGHT_YES);
        } else {
            AppCompatDelegate.setDefaultNightMode(AppCompatDelegate.MODE_NIGHT_NO);
        }
    }

    public int getThemeMode() {
        int theme = mMMKVDb.getIntData(SHOW_THEME_MODE, -1);
        if (theme == -1) {
            return ApiConstants.themeDay();
        }
        return theme;
    }

    /**
     *Display mode of the app
     */
    public void setKlineThemeMode(int mode) {
        mMMKVDb.saveIntData(SHOW_KLINETHEME_MODE, mode);
    }

    public int getKlineThemeMode() {
//        int theme = mMMKVDb.getIntData(SHOW_KLINETHEME_MODE, -1);
//        if (theme == -1) {
//            return ApiConstants.themeDay();
//        }
//        return theme;
        return getThemeMode();
    }

    public void setCurrentSymbol(String symbol) {
        mMMKVDb.saveData(CUR_COIN_MAP, symbol);
    }


    public String getCurrentSymbol() {
        String data = mMMKVDb.getData(CUR_COIN_MAP);
        if (!StringUtil.checkStr(data)) {
            ArrayList<String> sortList = NCoinManager.getMarketSortList();
            if (sortList != null && sortList.size() != 0) {
                ArrayList<JSONObject> coinList = StringOfExtKt.getCoinGroupSort(NCoinManager.getMarketByName(sortList.get(0)));
                if (coinList.size() != 0) {
                    return coinList.get(0).optString("symbol");
                }
            }
            return "btcusdt";
        } else {
            return data;
        }
    }


    public void setCurrentSymbol4Lever(String symbol) {
        mMMKVDb.saveData(CUR_COIN_MAP_LEVER, symbol);
    }

    public String getCurrentSymbol4Lever() {
        String data = mMMKVDb.getData(CUR_COIN_MAP_LEVER);
        if (!StringUtil.checkStr(data)) {
            return "";
        } else {
            return data;
        }
    }

    public void setCurrentSymbol4Grid(String symbol) {
        mMMKVDb.saveData(CURRENT_COIN_MAP_GRID, symbol);
    }

    public String getCurrentSymbol4Grid() {
        String data = mMMKVDb.getData(CURRENT_COIN_MAP_GRID);
        if (!StringUtil.checkStr(data)) {
            return "";
        } else {
            return data;
        }
    }


    /**
     *All coin pairs opened off site
     */
    /*
     *Obtain all transaction pairs without grouping
     */
    public ArrayList<String> getCoinArray() {
        JSONObject market = getCoinList(null);
        if (null == market) {
            return new ArrayList<String>();
        }

        Iterator<String> it = market.keys();
        ArrayList<String> array = new ArrayList<>();
        while (it.hasNext()) {
            String key = it.next();
            JSONObject value = market.optJSONObject(key);
            if (value.optInt("otcOpen") == 1) {
                array.add(value.optString("name"));
            }
        }
        return array;
    }

    /**
     *Do you want to use a new version
     */
    public boolean getOpenOrderCollect(@Nullable JSONObject data) {
        data = getData(data);
        if (null != data)
            return "1".equals(data.optString("open_order_collect"));
        return false;
    }


    /**
     *User Role Switch
     *'0': Off, '1': On
     */
    public boolean isUserRoleLevel(@Nullable JSONObject data) {
        /*data = getData(data);
        if (null != data)
            return "1".equals(data.optString("user_role_level_open"));*/
        return false;
    }

    public String getThemeModeNew() {
        String theme = "day";
        if (getThemeMode() == 1) {
            theme = "night";
        }
        return theme;
    }


    /**
     *Copy of homepage pop-up window
     */
    public String getHomePageDialogTitle(@Nullable JSONObject data) {
        data = getData(data);
        if (null != data)
            return data.optString("popWindow_txt", "");
        return "";
    }


    public void saveHomePageDialogStatus(boolean isShow) {
        mMMKVDb.saveBooleanData(HOMEPAGE_SHOW_DIALOG_STATUS, isShow);
    }

    public boolean getHomePageDialogStatus() {
        return mMMKVDb.getBooleanData(HOMEPAGE_SHOW_DIALOG_STATUS, false);
    }

    public String getLeverDialogURL(@Nullable JSONObject data) {
        data = getData(data);
        if (null != data) {
            JSONObject protocol_url_list = data.optJSONObject("protocol_url_list");
            if (protocol_url_list != null) {
                String el_gr = protocol_url_list.optString("el_GR", "");
                String ko_KR = protocol_url_list.optString("ko_KR", "");
                String en_US = protocol_url_list.optString("en_US", "");
                String zh_CN = protocol_url_list.optString("zh_CN", "");
                String ja_JP = protocol_url_list.optString("ja_JP", "");

                if (SystemUtils.isZh()) {
                    return zh_CN;
                } else if (SystemUtils.isKorea()) {
                    return ko_KR;
                } else if (SystemUtils.isTW()) {
                    return el_gr;
                } else if (SystemUtils.isJapanese()) {
                    return ja_JP;
                } else {
                    return en_US;
                }
            }

        }
        return "";
    }

    public void saveLeverDialogStatus(boolean isShow) {
        mMMKVDb.saveBooleanData(LEVER_SHOW_DIALOG_STATUS, isShow);
    }

    public boolean getLeverDialogStatus() {
        return mMMKVDb.getBooleanData(LEVER_SHOW_DIALOG_STATUS, false);
    }

    /**
     *Show pop-up
     */
    public boolean hasShownLeverStatusDialog() {
        String leverDialogURL = PublicInfoDataService.getInstance().getLeverDialogURL(null);
        if (StringUtil.checkStr(leverDialogURL)) {
            return getLeverDialogStatus();
        } else {
            return true;
        }
    }


    /**
     *Lever switch
     *'0': Off, '1': On
     */
    public boolean isLeverOpen(@Nullable JSONObject data) {
        data = getData(data);
        if (null != data)
            return "1".equals(data.optString("lever_open"));
        return true;
    }

    public void saveCoinInfo4B2C(String symbol) {
        mMMKVDb.saveData(ParamConstant.B2C_SYMBOL, symbol);
    }

    public String getCoinInfo4B2c() {
        return mMMKVDb.getData(ParamConstant.B2C_SYMBOL);
    }

    /**
     *Do you want to use a network language pack
     */
    public boolean isGetLanguageFromNet() {
        return false;
    }

    /**
     *The status of whether to display the ETF declaration when saving locally
     *
     * @param isShow
     */
    public void saveETFStateDialogStatus(boolean isShow) {
        mMMKVDb.saveBooleanData(ETF_STATE_DIALOG_STATUS, isShow);
    }

    public boolean getETFStateDialogStatus() {
        return mMMKVDb.getBooleanData(ETF_STATE_DIALOG_STATUS, false);
    }

    /**
     *Share QR code link
     *
     * @param data
     * @return
     */
    public String getSharingPage(@Nullable JSONObject data) {
        data = getData(data);
        if (null != data)
            return data.optString("sharingPage", "");
        return "";
    }

    /**
     *Switch between new and old contracts
     */
    public boolean isNewContract(@Nullable JSONObject data) {
        data = getData(data);
        if (null != data)
            return "1".equals(data.optString("isNewContract", "1"));
        return true;
    }

    /**
     *Display homepage assets
     *
     * @return
     */
    public boolean getAppIndexAssetsOpen(JSONObject data) {
        data = getData(data);
        if (null != data)
            return "0".equals(data.optString("appIndex_assets_open", ""));
        return true;
    }

    /**
     *Get Language
     */
    public JSONArray getLocalesList(JSONObject data) {
        data = getData(data);
        if (null != data) {
            return data.optJSONArray("langList");
        }
        return new JSONArray();
    }

    public JSONObject getLocalesListNew(JSONObject data) {
        data = getData(data);
        if (null != data) {
            return data.optJSONObject("langList");
        }
        return null;
    }


    /**
     *Obtain Customer Id
     */
    public String getCompanyId(JSONObject data) {
        data = getData(data);
        if (null != data)
            return data.optString("companyId", "");
        return "";
    }

    /**
     *Obtain funding rates
     */
    public String getfundRate(JSONObject data) {
        data = getData(data);
        if (null != data)
            return data.optString("fundRate", "");
        return "";
    }

    public void saveClientID(String data) {
        if (null != data) {
            mMMKVDb.saveData(BIND_CLIENT_ID, data);
        }
    }

    public String getClientID() {
        return mMMKVDb.getData(BIND_CLIENT_ID);
    }

    /**
     *Obtain whether to enable polar verification
     *0- Off
     *1- On
     */
    public Boolean getPushStatus(@Nullable JSONObject data) {
        data = getData(data);
        if (null != data)
            return data.optInt("appPushSwitch") == 1;
        return false;
    }

    public void setHeaderSymbol(String data) {
        if (null != data) {
            mMMKVDb.saveData(HOME_TOP_SYMBOL, data);
        }
    }

    public String getHeaderSymbol() {
        return mMMKVDb.getData(HOME_TOP_SYMBOL);
    }

    /**
     *Share QR code link
     *
     * @param data
     * @return
     */
    public String getDomainPage(@Nullable JSONObject data) {
        data = getData(data);
        if (null != data)
            return data.optString("companyDomain", "");
        return "";
    }


    /**
     *Do you want to open a spot broker
     *
     * @param data
     * @return
     */
    public boolean getAgentUserOpen(@Nullable JSONObject data) {
        data = getData(data);
        if (null != data)
            return data.optInt("agentUserOpen") == 1;
        return false;
    }

    public void saveMarketData(JSONObject data) {
        if (null != data) {
            cachPublicObj = data;
            try {
                mMMKVDb.saveData(publicInfoMarket, data.toString());
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }

    /*
     *Return the outermost data object
     */
    public JSONObject getMarketData(JSONObject data) {
        if (null == data) {
            if (null != cachPublicObj && cachPublicObj.length() > 0)
                return cachPublicObj;
            String dataStr = mMMKVDb.getData(publicInfoMarket);
            if (StringUtil.checkStr(dataStr)) {
                try {
                    return cachPublicObj = new JSONObject(dataStr);
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        } else {
            cachPublicObj = data;
        }
        return data;
    }

    /**
     *All coin pairs opened off site
     */
    /*
     *Obtain all transaction pairs without grouping
     */
    public String getCoinFundRate(String symbol) {
        JSONObject market = getCoinList(null);
        if (null == market) {
            return "";
        }
        if (null != market) {
            boolean coin = market.isNull(symbol);
            if (!coin) {
                JSONObject item = market.optJSONObject(symbol);
                return market.optJSONObject(symbol).optString("fundRate");
            }
        }
        return "";
    }

    /**
     *Get name
     */
    public String getFundRateForSymbol(String symbol) {
        JSONObject jsonObject = getMarket(null);
        if (null == jsonObject || jsonObject.length() <= 0)
            return "";
        Iterator<String> its = jsonObject.keys();
        while (its.hasNext()) {
            JSONObject data = jsonObject.optJSONObject(its.next());
            if (data == null) {
                return "";
            }
            Iterator<String> itsMarket = data.keys();
            while (itsMarket.hasNext()) {
                JSONObject dataMarket = data.optJSONObject(itsMarket.next());
                if (dataMarket != null && symbol.equals(dataMarket.optString("symbol"))) {
                    return dataMarket.optString("fundRate");
                }
            }
        }
        return "";
    }


    /**
     *Display mode of co
     */
    public void setContractMode(int mode) {
        mMMKVDb.saveIntData(SAVE_CONTRACT_DATA, mode);
    }

    public int getContractModeCode() {
        return mMMKVDb.getIntData(SAVE_CONTRACT_DATA, -1);
    }

    public int getContractMode() {
        return mMMKVDb.getIntData(SAVE_CONTRACT_DATA, CONTRACT_MODE_DEFAULT);
    }

    /**
     *Chain up contract version new contract
     *
     * @return
     */
    public boolean isNewOldContract() {
        return getContractMode() == 1;
    }

    public String getOldContractUrl(boolean isSplit) {
        String webSplit = "";
        if (isSplit) {
            webSplit = "&";
        }
        return webSplit + "cover=" + (isNewOldContract() ? "2" : "1");
    }

    /**
     *Contract default value
     *
     * @param data
     * @return
     */
    public String getContractDefault(@Nullable JSONObject data) {
        data = getData(data);
        if (null != data)
            return data.optString("contract_version_settings", "");
        return "";
    }

    /**
     *Share QR code link
     *
     * @param data
     * @return
     */
    public boolean getContractSwitchDefault(@Nullable JSONObject data) {
        data = getData(data);
        if (null != data)
            return data.optString("contract_change_switch", "").equals("1");
        return false;
    }


    public boolean isNewForceContract() {
        JSONObject data = getData(null);
        if (null != data) {
            return data.optString("contract_change_switch", "").equals("0") && !isNewOldContract();
        }
        return false;
    }

    public void saveGridStateDialogStatus(boolean isShow) {
        mMMKVDb.saveBooleanData(GRID_STATE_DIALOG_STATUS, isShow);
    }

    public boolean getGridStateDialogStatus() {
        return mMMKVDb.getBooleanData(GRID_STATE_DIALOG_STATUS, false);
    }

    public void saveCompanyIDData(String data) {
        if (null != data) {
            mMMKVDb.saveData(SAVE_CET_COMPANYID_DATA, data);
        } else {
            mMMKVDb.removeValueForKey(SAVE_CET_COMPANYID_DATA);
        }
    }

    public JSONObject getCompanyIDData() {
        JSONObject data = null;
        String dataStr = mMMKVDb.getData(SAVE_CET_COMPANYID_DATA);
        if (StringUtil.checkStr(dataStr)) {
            try {
                data = new JSONObject(dataStr);
            } catch (JSONException e) {
                e.printStackTrace();
                data = new JSONObject();
            }
        }
        return data;
    }

    public ArrayList<JSONObject> getLinkData(boolean isHttpUrl) {
        //Default route
        JSONObject link = getCetData();
        //Custom circuit
        JSONObject companyIDLink = getCompanyIDData();
        ArrayList<JSONObject> linkArrays = new ArrayList<JSONObject>(getLinkDataByJSONArray(link, isHttpUrl, true));
        if (companyIDLink != null) {
            if (!companyIDLink.isNull("merge_open")) {
                int open = companyIDLink.optInt("merge_open");
                ArrayList<JSONObject> linkArrayCompanyID = getLinkDataByJSONArray(companyIDLink, isHttpUrl, false);
                if (open == 1) {
                    return StringOfExtKt.getLinksByCompany(linkArrays, linkArrayCompanyID);
                }
                return linkArrayCompanyID;
            }
        }
        return linkArrays;
    }

    public ArrayList<JSONObject> getLinkDataByJSONArray(JSONObject link, boolean isHttpUrl, boolean isMain) {
        ArrayList<JSONObject> linkArrays = new ArrayList<JSONObject>();
        if (link != null) {
            JSONArray cetString = null;
            if (isHttpUrl || !isMain) {
                cetString = link.optJSONArray("links");
            } else {
                cetString = link.optJSONArray("ws_links");
            }
            if (cetString != null && cetString.length() != 0) {
                ArrayList<JSONObject> linkDefaults = JSONUtil.arrayToList(cetString);
                linkArrays.addAll(linkDefaults);
            }
        }
        return linkArrays;
    }

    /**
     *1 pop-up prompt 0 does not play
     */
    public boolean isOpenETFSwitch() {
        JSONObject data = getData(null);
        if (null != data) {
            return data.optInt("registerLocalLimitSwitch", 0) == 1;
        }
        return false;
    }

    /**
     *Direction of buying and selling orders
     */
    public void saveNewWorkWSURL(String isHorizontal) {
        mMMKVDb.saveData(CHANGE_HOST_WS, isHorizontal);
    }

    public String getNewWorkWSURL() {
        return mMMKVDb.getData(CHANGE_HOST_WS);
    }

    public void saveCpNewWorkWSURL(String isHorizontal) {
        mMMKVDb.saveData(CHANGE_HOST_CP_WS, isHorizontal);
    }

    public String getCpNewWorkWSURL() {
        return mMMKVDb.getData(CHANGE_HOST_CP_WS);
    }

    public String getAliYunAccess() {
        JSONObject data = getData(null);
        if (null != data) {
            return data.optString("nc_appkey");
        }
        return "";
    }

    public String getNcUrl() {
        JSONObject data = getData(null);
        if (null != data) {
            return data.optString("nc_url");
        }
        return "";
    }

    /**
     *Obtain Alibaba Slide Verification Module Configuration
     *
     * @return
     */
    public String getAliYunNcUrl() {
        Uri.Builder url = Uri.parse(getNcUrl()).buildUpon();
        if (url != null) {
            return url.appendQueryParameter("appkey", getAliYunAccess()).toString();
        }
        return getNcUrl() + "?appkey=" + getAliYunAccess();
    }

    public boolean isOpenVoiceSms() {
        JSONObject data = getData(null);
        if (null != data) {
            return data.optInt("voice_sms_open", 0) == 1;
        }
        return false;
    }

    /**
     *Obtaining whether there is financial management
     */
    public boolean financeOpen(@Nullable JSONObject data) {
        data = getData(data);
        if (null != data)
            return "1".equals(data.optString("savings_open"));
        return false;
    }

    /**
     *Return the corresponding slave currency list based on the main chain currency
     *
     * @param name
     * @return
     */
    public ArrayList<JSONObject> getCoinsByMainCoinName(String name) {
        JSONObject followCoinListJSONObject = getCoinByName(name);
        ArrayList<JSONObject> coinList = new ArrayList<>();
        if (followCoinListJSONObject != null) {
            coinList.add(followCoinListJSONObject);
        }
        return DecimalUtil.sortByMultiOptions(coinList, "sort", "tokenBase", false);

    }

    /**
     *Return the corresponding slave currency list based on the main chain currency
     *
     * @param name
     * @return
     */
    public ArrayList<JSONObject> getCoinsByMainCoinName(String name, String pageType) {
        JSONObject item = getCoinByName(name);
        ArrayList<JSONObject> coinList = new ArrayList<>();
        if (item != null) {
            coinList.add(item);
        }
        return DecimalUtil.sortByMultiOptions(coinList, "sort", "tokenBase", false);

    }


    /**
     *Financial management
     *
     * @param data
     * @return
     */
    public boolean isShowFiat(@Nullable JSONObject data) {
        data = getData(data);
        if (null != data)
            return data.optString("fiatIncomeOpen", "0").equals("1");
        return false;
    }


    /**
     * New Kyc
     *
     * @param data
     * @return
     */
    public boolean isKYCSumSubOpen(@Nullable JSONObject data) {
        data = getData(data);
        if (null != data)
            return data.optString("sumsub_open", "0").equals("1");
        return false;
    }

    public void savePrivatePageDialogStatus(boolean isShow) {
        mMMKVDb.saveBooleanData(PRIVATE_SHOW_DIALOG_STATUS, isShow);
    }

    public boolean getPrivatePageDialogStatus() {
        return mMMKVDb.getBooleanData(PRIVATE_SHOW_DIALOG_STATUS, false);
    }

    /**
     *Obtain contract broker instructions
     */
    public String getPrivateUrl() {
        String pageUrl = getSharingPage(null);
        if(pageUrl!=null && pageUrl.contains("http")){
            String webPage = StringOfExtKt.getDoMainByUrl(pageUrl);
            return StringOfExtKt.getPrivateUrl(webPage);
        }
        return "";
    }

    /**
     *Share QR code link
     *
     * @param data
     * @return
     */
    public String getProfitPage(@Nullable JSONObject data) {
        data = getData(data);
        if (null != data)
            return data.optString("sharingPage", "");
        return "";
    }

    /**
     *Earnings page
     */
    public String getProfitUrl() {
        String domain = getDomainPage(null);
        if(domain.isEmpty()){
            String pageUrl = getSharingPage(null);
            if(pageUrl!=null && pageUrl.contains("http")) {
                domain = StringOfExtKt.getDoMainByUrl(pageUrl);
            }
        } else {
            domain = "m."+ domain;
        }
        return StringOfExtKt.getProfitUrl(domain);
    }

    public String getProfitLossUrl(@Nullable JSONObject data) {
        data = getData(data);
        if (null != data)
            return data.optString("profitLossUrl", "");
        return "";
    }

    /**
     *Enterprise certification switch
     *
     * @param data
     * @return
     */
    public boolean isKYCToBOpen(@Nullable JSONObject data) {
        data = getData(data);
        if (null != data)
            return data.optString("enterprise_certification_open", "0").equals("1");
        return false;
    }

    /**
     *Enterprise Sumsub authentication switch
     *
     * @return
     */
    public boolean isCompanySumsubOpen() {
        JSONObject data = getData();
        if (null != data)
            return data.optString("companySumsubOpen", "0").equals("1");
        return false;
    }

    public String getThemeModeByApi() {
        if(getThemeMode() == 0){
            return "1";
        }
        return "2";
    }


    /**
     *Online customer service configuration
     */
    public String getOnlineServiceConfig(@Nullable JSONObject data) {
        data = getData(data);
        if (null != data)
            return data.optString("online_service_config");
        return "";
    }


    public boolean isCoAgent() {
        JSONObject data = getData(null);
        if (null != data) {
            return data.optInt("coAgentStatus", 0)==1;
        }
        return false;
    }

    public boolean isShowUpdate() {
        String loca=mMMKVDb.getData(IS_SHOW_UPDATE_BOX);
        String curr= DateUtils.Companion.getCurrentDate(DateUtils.FORMAT_KLINE_DATE_YMD);
        if(loca.isEmpty()){
            mMMKVDb.saveData(IS_SHOW_UPDATE_BOX,curr );
            return true;
        }
        if(!loca.equals(curr)){
            mMMKVDb.saveData(IS_SHOW_UPDATE_BOX,curr );
            return true;
        }
        return false;
    }

    public String getServiceTimeZone() {
        JSONObject data = getData(null);
        if (null != data) {
            return data.optString("timeZone");
        }
        return "";
    }

    public Pair<String,String> getSymbolWithIcon(String symbol){
        Pair<String,String> defPair = new Pair<>("","");
        if("".equals(symbol)) return defPair;
        JSONObject data = getData(null);
        JSONObject coinList = data.optJSONObject("coinList");
        if(coinList==null) return defPair;
        if(coinList.isNull(symbol)){
            return defPair;
        }else{
            JSONObject jsonObject = coinList.optJSONObject(symbol);
            String icon = jsonObject.optString("icon");
            String longName = jsonObject.optString("longName");
            String showName = jsonObject.optString("showName");
            String name = "".equals(longName) ? showName : longName;
            return new Pair<>(icon,name);
        }
    }

    public boolean rateMy(@Nullable JSONObject data) {
        data = getData(data);
        if (null != data)
            return "1".equals(data.optString("membership_level_open"));
        return false;
    }

    public String membershipUrl(@Nullable JSONObject data) {
        data = getData(data);
        if (null != data)
            return data.optString("membership_level_url");
        return "";
    }
}
