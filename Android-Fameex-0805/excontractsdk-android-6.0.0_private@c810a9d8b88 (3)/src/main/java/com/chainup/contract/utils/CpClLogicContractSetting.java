package com.chainup.contract.utils;

import android.content.Context;
import android.os.Build;
import android.os.Looper;
import android.text.TextUtils;
import android.util.Log;
import android.util.Pair;


import androidx.annotation.RequiresApi;
import androidx.appcompat.app.AppCompatDelegate;

import com.alibaba.fastjson.JSON;
import com.blankj.utilcode.util.LogUtils;
import com.chainup.contract.R;
import com.chainup.contract.api.CpApiConstants;
import com.chainup.contract.app.CpMyApp;
import com.chainup.contract.bean.ContractListBean;
import com.chainup.contract.bean.CpTabInfo;
import com.chainup.contract.net.CpHttpHelper;
import com.chainup.contract.net.CpJSONUtil;
import com.chainup.contract.net.CpNetUrl;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.reflect.TypeToken;
import com.yjkj.chainup.manager.CpLanguageUtil;

import org.jetbrains.annotations.NotNull;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.lang.ref.WeakReference;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import kotlin.jvm.Synchronized;
import java.util.Objects;

/**
 * Created by zhoujing on 2017/10/19.
 */

public class CpClLogicContractSetting {

    private static final String TAG = CpClLogicContractSetting.class.getSimpleName();
    public interface IContractSettingListener {
        void onContractSettingChange();
    }

    private static volatile CpClLogicContractSetting instance = null;

    private WeakReference<ICpUserDataBridge> userDataBridgeImplReference;

    private String repReViewData = "";

    public static CpClLogicContractSetting getInstance() {
        if (null == instance){
            synchronized (CpClLogicContractSetting.class){
                if (null == instance){
                    instance = new CpClLogicContractSetting();
                }
            }
        }
        return instance;
    }

    private List<IContractSettingListener> mListeners = new ArrayList<>();

    private CpClLogicContractSetting() {

    }

    public void registListener(IContractSettingListener listener) {

        if (listener == null) return;

        int iCount;
        for (iCount = 0; iCount < mListeners.size(); iCount++) {
            if (listener.equals(mListeners.get(iCount)))
                break;
        }

        if (iCount >= mListeners.size())
            mListeners.add(listener);
    }


    public void unregistListener(IContractSettingListener listener) {

        if (listener == null) return;

        int iCount;
        for (iCount = 0; iCount < mListeners.size(); iCount++) {
            if (listener.equals(mListeners.get(iCount))) {
                mListeners.remove(mListeners.get(iCount));
                return;
            }
        }
    }

    public void refresh() {
        for (int i = 0; i < mListeners.size(); i++) {
            if (mListeners.get(i) != null) {
                mListeners.get(i).onContractSettingChange();
            }
        }
    }


    private static int s_contract_unit = 0;
    private static boolean s_contract_unit_first = true;

    //0 pieces and 1 coin
    public static int getContractUint(Context context) {
        if (s_contract_unit_first) {
            s_contract_unit = CpPreferenceManager.getInstance(context).getSharedInt(CpPreferenceManager.PREF_CONTRACT_UNIT, 1);
            s_contract_unit_first = false;
        }
        return s_contract_unit;
    }

    public static void setContractUint(Context context, int unit) {
        s_contract_unit = unit;
        CpPreferenceManager.getInstance(context).putSharedInt(CpPreferenceManager.PREF_CONTRACT_UNIT, unit);
    }


    public static int getGuideFlag(Context context){
        return CpPreferenceManager.getInstance(context).getSharedInt(CpGuideUtil.CONTRACT_ORDER_VALUE_GUIDE, 0);
    }

    public static void setGuideFlag(Context context, int flag){
        CpPreferenceManager.getInstance(context).putSharedInt(CpGuideUtil.CONTRACT_ORDER_VALUE_GUIDE, flag);
    }


    /**
     *0 - Day mode
     */
    public static final int THEME_MODE_DAYTIME = 0;
    /**
     *1 - Night mode
     */
    public static final int THEME_MODE_NIGHT = 1;

    public static String userToken = "";

    public static int getThemeMode(Context context) {
        return CpPreferenceManager.getInstance(context).getSharedInt(CpPreferenceManager.PREF_THEMEMODE, CpApiConstants.CP_DEF_THEME_DAY);
    }

    /**
     *Display mode of app
     */
    public static void setThemeMode(int mode) {
        CpPreferenceManager.getInstance(CpMyApp.Companion.instance()).putSharedInt(CpPreferenceManager.PREF_THEMEMODE, mode);
        CpFlutterEngineCacheUtil.removeAllEngine();
        if (mode == THEME_MODE_NIGHT) {
            AppCompatDelegate.setDefaultNightMode(AppCompatDelegate.MODE_NIGHT_YES);
        } else {
            AppCompatDelegate.setDefaultNightMode(AppCompatDelegate.MODE_NIGHT_NO);
        }
    }


    public static void setKlineThemeMode(int mode) {
        CpPreferenceManager.getInstance(CpMyApp.Companion.instance()).putSharedInt(CpPreferenceManager.KLINETHEME_MODE, mode);
        CpFlutterEngineCacheUtil.removeAllEngine();
//        if (mode == THEME_MODE_NIGHT) {
//            AppCompatDelegate.setDefaultNightMode(AppCompatDelegate.MODE_NIGHT_YES);
//        } else {
//            AppCompatDelegate.setDefaultNightMode(AppCompatDelegate.MODE_NIGHT_NO);
//        }
    }

    public static int getKlineThemeMode() {
        return CpPreferenceManager.getInstance(CpMyApp.Companion.instance()).getSharedInt(CpPreferenceManager.KLINETHEME_MODE, CpApiConstants.CP_DEF_THEME_DAY);
    }

    /**
     *Language
     */
    public static void setLanguage(String currentLan) {
//        CpPreferenceManager.getInstance(CpMyApp.Companion.instance()).putSharedInt(CpPreferenceManager.PREF_LANGUAGE, currentLan);
//        CpLocalManageUtil.saveSelectLanguage();
    }

    /**
     *Determine whether the user is logged in
     *
     * @return
     */
    public static boolean isLogin() {
        return !TextUtils.isEmpty(getToken());
    }

    /**
     *Obtain user login credentials
     *
     * @return
     */
    public static String getToken() {
        return userToken;
    }

    /**
     *Set user login credentials
     *
     * @param key
     */
    public static void setToken(String key) {
        if (TextUtils.isEmpty(key)) {
            ChainUpLogUtil.e("传入token为空");
            userToken = "";
            return;
        }
        userToken = key;
    }

    /**
     *Clear User Login Credentials
     */
    public static void cleanToken() {
        userToken = "";
    }

    public static void setInviteUrl(String key) {
        CpPreferenceManager.getInstance(CpMyApp.Companion.instance()).putSharedString(CpPreferenceManager.CONTRACT_INVITE_URL, key);
    }

    public static String getInviteUrl() {
        return CpPreferenceManager.getInstance(CpMyApp.Companion.instance()).getSharedString(CpPreferenceManager.CONTRACT_INVITE_URL, "");
    }


    /**
     *Set the API interface and the url used by ws
     *
     * @param context
     * @param mApiUrl
     * @param mWsUrl
     */
    public static void setApiWsUrl(Context context, String mApiUrl, String mWsUrl) {
        if (TextUtils.isEmpty(mApiUrl)) {
            ChainUpLogUtil.e("传入ApiUrl为空");
            return;
        }
        if (TextUtils.isEmpty(mWsUrl)) {
            ChainUpLogUtil.e("传入WsUrl为空");
            return;
        }
        Log.e("---------------------", "切换域名1" + mApiUrl);
        CpNetUrl.ContractNewUrl = mApiUrl;
        CpPreferenceManager.getInstance(context).putSharedString(CpPreferenceManager.CONTRACT_API_URL, mApiUrl);
        CpPreferenceManager.getInstance(context).putSharedString(CpPreferenceManager.CONTRACT_WS_URL, mWsUrl);
        CpHttpHelper.Companion.getInstance().clearServiceMap();
    }
    //Whether the K line displays orders
    public static void setKlineOrder(Context context, Boolean isKlineOrder ) {
        CpPreferenceManager.getInstance(context).putSharedBoolean(CpPreferenceManager.CONTRACT_KLINE_ORDER, isKlineOrder);
    }
    //Whether the K line displays orders
    public static Boolean getKlineOrder() {
        return CpPreferenceManager.getInstance(CpMyApp.Companion.instance()).getSharedBoolean(CpPreferenceManager.CONTRACT_KLINE_ORDER,false);
    }

    public static void setWsUrl(Context context, String mWsUrl) {
        if (TextUtils.isEmpty(mWsUrl)) {
            ChainUpLogUtil.e("传入WsUrl为空");
            return;
        }
        CpPreferenceManager.getInstance(context).putSharedString(CpPreferenceManager.CONTRACT_WS_URL, mWsUrl);
    }

    /**
     *Obtain contract apiurl
     */
    public static String getApiUrl() {
        LogUtils.e("获取合约apiurl", CpPreferenceManager.getInstance(CpMyApp.Companion.instance()).getSharedString(CpPreferenceManager.CONTRACT_API_URL, ""));
        return CpPreferenceManager.getInstance(CpMyApp.Companion.instance()).getSharedString(CpPreferenceManager.CONTRACT_API_URL, "");
    }

    /**
     *Get contract wsurl
     *
     * @param context
     */
    public static String getWsUrl(Context context) {
        return CpPreferenceManager.getInstance(context).getSharedString(CpPreferenceManager.CONTRACT_WS_URL, "");
    }


    private static int s_pnl_calculate = 0;
    private static boolean s_pnl_calculate_first = true;

    //0 Reasonable Price 1 Latest Transaction Price
    public static int getPnlCalculate(Context context) {
        if (s_pnl_calculate_first) {
            s_pnl_calculate = CpPreferenceManager.getInstance(context).getSharedInt(CpPreferenceManager.PREF_CONTRACT_PNL_CALCULATE, 1);
            s_pnl_calculate_first = false;
        }
        return s_pnl_calculate;
    }

    public static void setPnlCalculate(Context context, int unit) {
        s_pnl_calculate = unit;
        CpPreferenceManager.getInstance(context).putSharedInt(CpPreferenceManager.PREF_CONTRACT_PNL_CALCULATE, unit);
    }

    private static int s_trigger_price_type = 1;
    private static boolean s_trigger_price_type_first = true;

    //1 Market Price 2 Reasonable Price 4 Index Price
    public static int getTriggerPriceType(Context context) {
        if (s_trigger_price_type_first) {
            s_trigger_price_type = CpPreferenceManager.getInstance(context).getSharedInt(CpPreferenceManager.PREF_TRIGGER_PRICE_TYPE, 1);
            s_trigger_price_type_first = false;
        }
        //Field upgrade requires compatibility with the old version of 0
        if (s_trigger_price_type == 0) {
            s_trigger_price_type = 1;
        }
        return s_trigger_price_type;
    }

    public static void setTriggerPriceType(Context context, int unit) {
        s_trigger_price_type = unit;
        CpPreferenceManager.getInstance(context).putSharedInt(CpPreferenceManager.PREF_TRIGGER_PRICE_TYPE, unit);
    }

    private static int s_execution = 0;
    private static boolean s_execution_first = true;

    //0 Limit Price 1 Market Price
    public static int getExecution(Context context) {
        if (s_execution_first) {
            s_execution = CpPreferenceManager.getInstance(context).getSharedInt(CpPreferenceManager.PREF_EXECUTION, 0);
            s_execution_first = false;
        }
        return s_execution;
    }

    public static void setExecution(Context context, int unit) {
        s_execution = unit;
        CpPreferenceManager.getInstance(context).putSharedInt(CpPreferenceManager.PREF_EXECUTION, unit);
    }

    private static int s_strategy_effect_time = 0;
    private static boolean s_strategy_effect_time_first = true;

    //0 24h 17day
    public static int getStrategyEffectTime(Context context) {
        if (s_strategy_effect_time_first) {
            s_strategy_effect_time = CpPreferenceManager.getInstance(context).getSharedInt(CpPreferenceManager.PREF_STRATEGY_EFFECTIVE_TIME, 1);
            s_strategy_effect_time_first = false;
        }
        return s_strategy_effect_time;
    }

    //The default value for obtaining the validity period is 14 days
    public static int getStrategyEffectTimeStr(Context context) {
        return CpPreferenceManager.getInstance(context).getSharedInt(CpPreferenceManager.PREF_STRATEGY_EFFECTIVE_TIME, 14);
    }


    public static void setStrategyEffectTime(Context context, int unit) {
        s_strategy_effect_time = unit;
        CpPreferenceManager.getInstance(context).putSharedInt(CpPreferenceManager.PREF_STRATEGY_EFFECTIVE_TIME, unit);
    }

    public static void setStrategyEffectTimeStr(Context context, int unit) {
        CpPreferenceManager.getInstance(context).putSharedInt(CpPreferenceManager.PREF_STRATEGY_EFFECTIVE_TIME, unit);
    }

    public static String getContractJsonListStr(Context context) {
        return CpPreferenceManager.getInstance(context).getSharedString(CpPreferenceManager.CONTRACT_JSON_LIST_STR, "");
    }

    public static String getContractJsonCollectListStr(Context context) {
        return CpPreferenceManager.getInstance(context).getSharedString(CpPreferenceManager.CONTRACT_COLLECT_COIN, "");
    }

    public static ArrayList<JSONObject> getContractJsonCollectListArr(Context context) {
       String str= CpPreferenceManager.getInstance(context).getSharedString(CpPreferenceManager.CONTRACT_COLLECT_COIN, "");
       ArrayList<JSONObject> sModelList = new ArrayList<JSONObject>();
       if (!TextUtils.isEmpty(str)){
           try {
               JSONArray jsonArray=new JSONArray(str);
               for (int i = 0; i < jsonArray.length(); i++) {
                   Object cObj = jsonArray.get(i);
                   if(cObj instanceof JSONObject){
                       sModelList.add((JSONObject) cObj);
                   }
               }
           } catch (JSONException e) {
               e.printStackTrace();
           }
       }
        return sModelList;
    }

    public static void setContractTabPositionByLeftCoinSearchDialog(Context context,int position){
        CpPreferenceManager.getInstance(context).putSharedInt(CpPreferenceManager.CONTRACT_LEFTCOIN_TAB,position);
    }

    public static int getContractTabPositionByLeftCoinSearchDialog(Context context){
        return CpPreferenceManager.getInstance(context).getSharedInt(CpPreferenceManager.CONTRACT_LEFTCOIN_TAB,-1);
    }

    public static void setContractJsonCollectListStr(Context context, String json) {
        CpPreferenceManager.getInstance(context).putSharedString(CpPreferenceManager.CONTRACT_COLLECT_COIN, json);
    }

    public static void setContractJsonRateStr(Context context, String json) {
        CpPreferenceManager.getInstance(context).putSharedString(CpPreferenceManager.CONTRACT_RATE, json);
    }

    public static void setContractChartPosition(Context context,int position){
        CpPreferenceManager.getInstance(context).putSharedInt(CpPreferenceManager.CONTEACT_KLINE_CHART_POSITIONSETTING,position);
    }
    public static int getContractChartPosition(Context context){
        return CpPreferenceManager.getInstance(context).getSharedInt(CpPreferenceManager.CONTEACT_KLINE_CHART_POSITIONSETTING,0);
    }

    public static void setContractChartOff(Context context,int flag){
        CpPreferenceManager.getInstance(context).putSharedInt(CpPreferenceManager.CONTEACT_KLINE_CHART_OFF,flag);
    }
    public static int getContractChartOff(Context context){
        return CpPreferenceManager.getInstance(context).getSharedInt(CpPreferenceManager.CONTEACT_KLINE_CHART_OFF,1);
    }

    public static JSONObject getContractJsonRateStr(Context context) {
        String contractRateJson= CpPreferenceManager.getInstance(context).getSharedString(CpPreferenceManager.CONTRACT_RATE,"");
        if (TextUtils.isEmpty(contractRateJson)){
            return new JSONObject();
        }
        try {
            return  new JSONObject(contractRateJson);
        } catch (JSONException e) {
            e.printStackTrace();
            return new JSONObject();
        }
    }

    public static JSONObject getContractJsonStrById(Context context, int contractId) {
        String contractJsonListStr = getContractJsonListStr(context);
        try {
            JSONArray jsonArray = new JSONArray(contractJsonListStr);
            for (int i = 0; i < jsonArray.length(); i++) {
                JSONObject mJSONObject = (JSONObject) jsonArray.get(i);
                int id = mJSONObject.getInt("id");
                if (contractId == id) {
                    return mJSONObject;
                }
            }
        } catch (JSONException e) {
            e.printStackTrace();
            return null;
        }
        return null;
    }

    /**
     *Obtain contract currency pair price precision based on ID
     *
     * @param context
     * @param contractId
     * @return
     */
    public static int getContractSymbolPricePrecisionById(Context context, int contractId) {
        String contractJsonListStr = getContractJsonListStr(context);
        try {
            JSONArray jsonArray = new JSONArray(contractJsonListStr);
            for (int i = 0; i < jsonArray.length(); i++) {
                JSONObject mJSONObject = (JSONObject) jsonArray.get(i);
                int id = mJSONObject.getInt("id");
                if (contractId == id) {
                    return mJSONObject.getJSONObject("coinResultVo").getInt("symbolPricePrecision");
                }
            }
        } catch (JSONException e) {
            e.printStackTrace();
            return 0;
        }
        return 0;
    }

    /**
     *Obtain contract currency to price unit based on ID
     *
     * @param context
     * @param contractId
     * @return
     */
    public static String getContractQuoteById(Context context, int contractId) {
        String contractJsonListStr = getContractJsonListStr(context);
        try {
            JSONArray jsonArray = new JSONArray(contractJsonListStr);
            for (int i = 0; i < jsonArray.length(); i++) {
                JSONObject mJSONObject = (JSONObject) jsonArray.get(i);
                int id = mJSONObject.getInt("id");
                if (contractId == id) {
                    return mJSONObject.getString("quote");
                }
            }
        } catch (JSONException e) {
            e.printStackTrace();
            return "--";
        }
        return "--";
    }

    public static String getContractWsSymbolById(Context context, int contractId) {
        String contractJsonListStr = getContractJsonListStr(context);
        try {
            JSONArray jsonArray = new JSONArray(contractJsonListStr);
            for (int i = 0; i < jsonArray.length(); i++) {
                JSONObject mJSONObject = (JSONObject) jsonArray.get(i);
                int id = mJSONObject.getInt("id");
                if (contractId == id) {
                    return (mJSONObject.getString("contractType") + "_" + mJSONObject.getString("symbol").replace("-", "")).toLowerCase();
                }
            }
        } catch (JSONException e) {
            e.printStackTrace();
            return "";
        }
        return "";
    }

    /**
     *Obtain the contract according to the ID to ensure the display accuracy of gold coins
     *
     * @param context
     * @param contractId
     * @return
     */
    public static int getContractMarginCoinPrecisionById(Context context, int contractId) {
        String contractJsonListStr = getContractJsonListStr(context);
        try {
            JSONArray jsonArray = new JSONArray(contractJsonListStr);
            for (int i = 0; i < jsonArray.length(); i++) {
                JSONObject mJSONObject = (JSONObject) jsonArray.get(i);
                int id = mJSONObject.getInt("id");
                if (contractId == id) {
                    return mJSONObject.getJSONObject("coinResultVo").getInt("marginCoinPrecision");
                }
            }
        } catch (JSONException e) {
            e.printStackTrace();
            return 0;
        }
        return 0;
    }

    public static String getContractMarginRateById(Context context, int contractId) {
        String contractJsonListStr = getContractJsonListStr(context);
        try {
            JSONArray jsonArray = new JSONArray(contractJsonListStr);
            for (int i = 0; i < jsonArray.length(); i++) {
                JSONObject mJSONObject = (JSONObject) jsonArray.get(i);
                int id = mJSONObject.getInt("id");
                if (contractId == id) {
                    return mJSONObject.getString("marginRate");
                }
            }
        } catch (JSONException e) {
            e.printStackTrace();
            return "0";
        }
        return "0";
    }

    /**
     *Obtaining contract guaranteed gold currency display accuracy based on guaranteed gold currency
     *
     * @param context
     * @param marginCoin
     * @return
     */
    public static int getContractMarginCoinPrecisionByMarginCoin(Context context, String marginCoin) {
        String contractJsonListStr = getContractJsonListStr(context);
        try {
            JSONArray jsonArray = new JSONArray(contractJsonListStr);
            for (int i = 0; i < jsonArray.length(); i++) {
                JSONObject mJSONObject = (JSONObject) jsonArray.get(i);
                String mMarginCoin = mJSONObject.getString("marginCoin");
                if (mMarginCoin.equals(marginCoin)) {
                    return mJSONObject.getJSONObject("coinResultVo").getInt("marginCoinPrecision");
                }
            }
        } catch (JSONException e) {
            e.printStackTrace();
            return 0;
        }
        return 0;
    }

    public static int getContractMultiplierPrecisionById(Context context, int contractId) {
        String contractJsonListStr = getContractJsonListStr(context);
        try {
            JSONArray jsonArray = new JSONArray(contractJsonListStr);
            for (int i = 0; i < jsonArray.length(); i++) {
                JSONObject mJSONObject = (JSONObject) jsonArray.get(i);
                int id = mJSONObject.getInt("id");
                if (contractId == id) {
                    String multiplier = mJSONObject.getString("multiplier");
                    String multiplierBuff = new BigDecimal(multiplier).stripTrailingZeros().toPlainString();
                    if (multiplierBuff.contains(".")) {
                        ChainUpLogUtil.e("------------", multiplierBuff);
                        ChainUpLogUtil.e("------------", multiplierBuff.split(".").length + "");
                        int index = multiplierBuff.indexOf(".");
                        int num = index < 0 ? 0 : multiplierBuff.length() - index - 1;
                        ChainUpLogUtil.e("------------", num + "");
                        return num;
                    } else {
                        return 0;
                    }
                }
            }
        } catch (JSONException e) {
            e.printStackTrace();
            return 0;
        }
        return 0;
    }

    public static String getContractMultiplierById(Context context, int contractId) {
        String contractJsonListStr = getContractJsonListStr(context);
        try {
            JSONArray jsonArray = new JSONArray(contractJsonListStr);
            for (int i = 0; i < jsonArray.length(); i++) {
                Object cObj = jsonArray.get(i);
                if(cObj instanceof JSONObject){
                    JSONObject mJSONObject = (JSONObject) cObj;
                    int id = mJSONObject.getInt("id");
                    if (contractId == id) {
                        return mJSONObject.getString("multiplier");
                    }
                }

            }
        } catch (JSONException e) {
            e.printStackTrace();
            return "0";
        }
        return "0";
    }

    /**
     *Obtain contract face value units
     *
     * @param context
     * @param contractId
     * @return
     */
    public static String getContractMultiplierCoinById(Context context, int contractId) {
        String contractJsonListStr = getContractJsonListStr(context);
        try {
            JSONArray jsonArray = new JSONArray(contractJsonListStr);
            for (int i = 0; i < jsonArray.length(); i++) {
                JSONObject mJSONObject = (JSONObject) jsonArray.get(i);
                int id = mJSONObject.getInt("id");
                if (contractId == id) {
                    return mJSONObject.getString("multiplierCoin");
                }
            }
        } catch (JSONException e) {
            e.printStackTrace();
            return "--";
        }
        return "--";
    }

    public static String getContractMultiplierCoinPrecisionById(Context context, int contractId) {
        String contractJsonListStr = getContractJsonListStr(context);
        try {
            JSONArray jsonArray = new JSONArray(contractJsonListStr);
            for (int i = 0; i < jsonArray.length(); i++) {
                JSONObject mJSONObject = (JSONObject) jsonArray.get(i);
                int id = mJSONObject.getInt("id");
                if (contractId == id) {
                    return mJSONObject.getString("multiplierCoin");
                }
            }
        } catch (JSONException e) {
            e.printStackTrace();
            return "--";
        }
        return "--";
    }

    public static String getContractSymbolNameById(Context context, int contractId) {
        String contractJsonListStr = getContractJsonListStr(context);
        try {
            JSONArray jsonArray = new JSONArray(contractJsonListStr);
            for (int i = 0; i < jsonArray.length(); i++) {
                JSONObject mJSONObject = (JSONObject) jsonArray.get(i);
                int id = mJSONObject.getInt("id");
                if (contractId == id) {
                    String contractType = mJSONObject.getString("contractType");
                    String symbol = mJSONObject.getString("symbol");
                    String marginCoin = mJSONObject.getString("marginCoin");
                    if (!contractType.equals("H") && !contractType.equals("S"))
                        symbol = symbol + "-" + marginCoin;
                    return symbol;
                }
            }
        } catch (JSONException e) {
            e.printStackTrace();
            return "--";
        }
        return "--";
    }

    public static String getContractMarginCoinById(Context context, int contractId) {
        String contractJsonListStr = getContractJsonListStr(context);
        try {
            JSONArray jsonArray = new JSONArray(contractJsonListStr);
            for (int i = 0; i < jsonArray.length(); i++) {
                JSONObject mJSONObject = (JSONObject) jsonArray.get(i);
                int id = mJSONObject.getInt("id");
                if (contractId == id) {
                    return mJSONObject.getString("marginCoin");
                }
            }
        } catch (JSONException e) {
            e.printStackTrace();
            return "--";
        }
        return "--";
    }

    public static int getContractSideById(Context context, int contractId) {
        String contractJsonListStr = getContractJsonListStr(context);
        try {
            JSONArray jsonArray = new JSONArray(contractJsonListStr);
            for (int i = 0; i < jsonArray.length(); i++) {
                JSONObject mJSONObject = (JSONObject) jsonArray.get(i);
                int id = mJSONObject.getInt("id");
                if (contractId == id) {
                    return mJSONObject.getInt("contractSide");
                }
            }
        } catch (JSONException e) {
            e.printStackTrace();
            return 0;
        }
        return 0;
    }

    public static String getContractShowNameById(Context context, int contractId) {
        if (contractId == -2) {
            return CpLanguageUtil.getString(context, "OpenOrder_text1");
        }
        String contractJsonListStr = getContractJsonListStr(context);
        try {
            JSONArray jsonArray = new JSONArray(contractJsonListStr);
            for (int i = 0; i < jsonArray.length(); i++) {
                JSONObject mJSONObject = (JSONObject) jsonArray.get(i);
                int id = mJSONObject.getInt("id");
                if (contractId == id) {
                    if (mJSONObject.isNull("contractOtherName")) {
                        String contractType = mJSONObject.getString("contractType");
                        String marginCoin = mJSONObject.getString("marginCoin");
                        String symbol = mJSONObject.getString("symbol");
                        if (contractType.equals("E")) {
                            return symbol;
                        } else {
                            return symbol + "-" + marginCoin;
                        }
                    } else {
                        String contractOtherName = mJSONObject.getString("contractOtherName");
                        return contractOtherName;
                    }
                }
            }
        } catch (JSONException e) {
            e.printStackTrace();
            return "--";
        }
        return "--";
    }

    public static String getContractShowNameByIdTx(Context context, int contractId) {
        if (contractId == -2) {
            return CpLanguageUtil.getString(context, "cp_all_contract");
        }
        String contractJsonListStr = getContractJsonListStr(context);
        try {
            JSONArray jsonArray = new JSONArray(contractJsonListStr);
            for (int i = 0; i < jsonArray.length(); i++) {
                JSONObject mJSONObject = (JSONObject) jsonArray.get(i);
                int id = mJSONObject.getInt("id");
                if (contractId == id) {
                    if (mJSONObject.isNull("contractOtherName")) {
                        String contractType = mJSONObject.getString("contractType");
                        String marginCoin = mJSONObject.getString("marginCoin");
                        String symbol = mJSONObject.getString("symbol");
                        if (contractType.equals("E")) {
                            return symbol;
                        } else {
                            return symbol + "@" + marginCoin;
                        }
                    } else {
                        String contractOtherName = mJSONObject.getString("contractOtherName");
                        return contractOtherName;
                    }
                }
            }
        } catch (JSONException e) {
            e.printStackTrace();
            return "--";
        }
        return "--";
    }

    public static int getContractClassificationById(Context context, int contractId) {
        String contractJsonListStr = getContractJsonListStr(context);
        if (contractId == -2) {
            return -2;
        }
        try {
            JSONArray jsonArray = new JSONArray(contractJsonListStr);
            for (int i = 0; i < jsonArray.length(); i++) {
                JSONObject mJSONObject = (JSONObject) jsonArray.get(i);
                int id = mJSONObject.getInt("id");
                if (contractId == id) {
                    return mJSONObject.getInt("classification");
                }
            }
        } catch (JSONException e) {
            e.printStackTrace();
            return 0;
        }
        return 0;
    }

    public static ArrayList<JSONObject> getContractListByClassification(Context context, String classification) {
        ArrayList<JSONObject> mContractListJSONObject = new ArrayList<>();
        String contractJsonListStr = getContractJsonListStr(context);
        try {
            JSONArray jsonArray = new JSONArray(contractJsonListStr);
            for (int i = 0; i < jsonArray.length(); i++) {
                JSONObject mJSONObject = (JSONObject) jsonArray.get(i);
                String classification1 = mJSONObject.getString("classification");
                if (classification1.equals(classification)) {
                    mContractListJSONObject.add(mJSONObject);
                }
            }
            return mContractListJSONObject;
        } catch (JSONException e) {
            e.printStackTrace();
            return mContractListJSONObject;
        }
    }

    public static String getContractNameById(Context context, int contractId) {
        String contractJsonListStr = getContractJsonListStr(context);
        try {
            JSONArray jsonArray = new JSONArray(contractJsonListStr);
            for (int i = 0; i < jsonArray.length(); i++) {
                JSONObject mJSONObject = (JSONObject) jsonArray.get(i);
                int id = mJSONObject.getInt("id");
                if (contractId == id) {
                    String symbol = mJSONObject.getString("symbol");
                    return symbol;
                }
            }
        } catch (JSONException e) {
            e.printStackTrace();
            return "--";
        }
        return "--";
    }

    public static void setContractJsonListStr(Context context, String data) {
        CpPreferenceManager.getInstance(context).putSharedString(CpPreferenceManager.CONTRACT_JSON_LIST_STR, data);
    }


    public static void setContractInfoUrlStr(Context context, String data) {
        CpPreferenceManager.getInstance(context).putSharedString(CpPreferenceManager.CONTRACT_INFO_URL_STR, data);
    }

    public static void setContractMarginCoinListStr(Context context, String data) {
        CpPreferenceManager.getInstance(context).putSharedString(CpPreferenceManager.CONTRACT_MARGIN_COIN_STR, data);
    }

    public static String getContractMarginCoinListStr(Context context) {
        return CpPreferenceManager.getInstance(context).getSharedString(CpPreferenceManager.CONTRACT_MARGIN_COIN_STR, "");
    }

    public static String getContractInfoUrlStr(Context context) {
        return CpPreferenceManager.getInstance(context).getSharedString(CpPreferenceManager.CONTRACT_INFO_URL_STR, "");
    }

    public static void setContractCurrentSelectedId(Context context, int ContractId) {
        CpPreferenceManager.getInstance(context).putSharedInt(CpPreferenceManager.CONTRACT_CURRENT_SELECTED_ID, ContractId);
    }

    public static int getContractCurrentSelectedId(Context context) {
        return CpPreferenceManager.getInstance(context).getSharedInt(CpPreferenceManager.CONTRACT_CURRENT_SELECTED_ID, -1);
    }


//"//1 has been activated, 0 has not been activated"
    public static Boolean isOpenContract() {
        return CpPreferenceManager.getInstance(CpMyApp.Companion.instance()).getSharedInt(CpPreferenceManager.PREF_CONTRACT_IS_OPEN, 0)==1;
    }
//
    public static void setContractIsOpen(Context context, int unit) {
        CpPreferenceManager.getInstance(context).putSharedInt(CpPreferenceManager.PREF_CONTRACT_IS_OPEN, unit);
    }

    //1 one-way, 2 two-way
    public static int getPositionModel(Context context) {
        return CpPreferenceManager.getInstance(context).getSharedInt(CpPreferenceManager.CONTRACT_POSITION_MODEL, 0);
    }

    public static void setPositionModel(Context context, int unit) {
        CpPreferenceManager.getInstance(context).putSharedInt(CpPreferenceManager.CONTRACT_POSITION_MODEL, unit);
    }

    public static String getShareInfo(Context context, String profitRate) {
        if (CpBigDecimalUtils.compareTo(profitRate, "0") >= 0 && CpBigDecimalUtils.compareTo(profitRate, "5") < 0) {
            return "“ " + CpLanguageUtil.getString(context, "cp_str_win_intro1") + " ” ";
        } else if (CpBigDecimalUtils.compareTo(profitRate, "5") >= 0 && CpBigDecimalUtils.compareTo(profitRate, "20") < 0) {
            return "“ " + CpLanguageUtil.getString(context, "cp_str_win_intro2") + " ” ";
        } else if (CpBigDecimalUtils.compareTo(profitRate, "20") >= 0 && CpBigDecimalUtils.compareTo(profitRate, "50") < 0) {
            return "“ " + CpLanguageUtil.getString(context, "cp_str_win_intro3") + " ” ";
        } else if (CpBigDecimalUtils.compareTo(profitRate, "50") >= 0 && CpBigDecimalUtils.compareTo(profitRate, "100") < 0) {
            return "“ " + CpLanguageUtil.getString(context, "cp_str_win_intro4") + " ” ";
        } else if (CpBigDecimalUtils.compareTo(profitRate, "100") >= 0) {
            return "“ " + CpLanguageUtil.getString(context, "cp_str_win_intro5") + " ” ";
        } else if (CpBigDecimalUtils.compareTo(profitRate, "0") < 0 && CpBigDecimalUtils.compareTo(profitRate, "-5") >= 0) {
            return "“ " + CpLanguageUtil.getString(context, "cp_str_lose_intro1") + " ” ";
        } else if (CpBigDecimalUtils.compareTo(profitRate, "-5") < 0 && CpBigDecimalUtils.compareTo(profitRate, "-20") >= 0) {
            return "“ " + CpLanguageUtil.getString(context, "cp_str_lose_intro2") + " ” ";
        } else if (CpBigDecimalUtils.compareTo(profitRate, "-20") < 0 && CpBigDecimalUtils.compareTo(profitRate, "-50") >= 0) {
            return "“ " + CpLanguageUtil.getString(context, "cp_str_lose_intro3") + " ” ";
        } else if (CpBigDecimalUtils.compareTo(profitRate, "-50") < 0 && CpBigDecimalUtils.compareTo(profitRate, "-100") >= 0) {
            return "“ " + CpLanguageUtil.getString(context, "cp_str_lose_intro4") + " ” ";
        } else {
            return "“ " + CpLanguageUtil.getString(context, "cp_str_lose_intro5") + " ” ";
        }
    }

    public static int getShareBg(String profitRate) {
        if (CpBigDecimalUtils.compareTo(profitRate, "0") >= 0 && CpBigDecimalUtils.compareTo(profitRate, "5") < 0) {
            return R.drawable.contract_smallcompany;
        } else if (CpBigDecimalUtils.compareTo(profitRate, "5") >= 0 && CpBigDecimalUtils.compareTo(profitRate, "20") < 0) {
            return R.drawable.contract_smallcompany;
        } else if (CpBigDecimalUtils.compareTo(profitRate, "20") >= 0 && CpBigDecimalUtils.compareTo(profitRate, "50") < 0) {
            return R.drawable.contract_smallcompany;
        } else if (CpBigDecimalUtils.compareTo(profitRate, "50") >= 0 && CpBigDecimalUtils.compareTo(profitRate, "100") < 0) {
            return R.drawable.contract_profit;
        } else if (CpBigDecimalUtils.compareTo(profitRate, "100") >= 0) {
            return R.drawable.contract_profit;
        } else if (CpBigDecimalUtils.compareTo(profitRate, "0") < 0 && CpBigDecimalUtils.compareTo(profitRate, "-5") >= 0) {
            return R.drawable.contract_profit_smallloss;
        } else if (CpBigDecimalUtils.compareTo(profitRate, "-5") < 0 && CpBigDecimalUtils.compareTo(profitRate, "-20") >= 0) {
            return R.drawable.contract_profit_smallloss;
        } else if (CpBigDecimalUtils.compareTo(profitRate, "-20") < 0 && CpBigDecimalUtils.compareTo(profitRate, "-50") >= 0) {
            return R.drawable.contract_profit_smallloss;
        } else if (CpBigDecimalUtils.compareTo(profitRate, "-50") < 0 && CpBigDecimalUtils.compareTo(profitRate, "-100") >= 0) {
            return R.drawable.contract_bigloss;
        } else {
            return R.drawable.contract_bigloss;
        }
    }


    /**
     *Store the currency pairs of the contract collection
     * <p>
     *Cancel the collection if the current currency pair exists, or collect if it does not exist
     *Return 0 Collection cancelled successfully 1 Collection added successfully
     */
    public static int collectContractCoin(Context mContext, int mContarctId) {
        String contractJsonListStr = getContractJsonCollectListStr(mContext);
        try {
            boolean isExist = false;
            JSONArray jsonArray = null;
            if (!TextUtils.isEmpty(contractJsonListStr)){
                jsonArray = new JSONArray(contractJsonListStr);
                for (int i = 0; i < jsonArray.length(); i++) {
                    Object obj = jsonArray.get(i);
                    if(obj instanceof JSONObject){
                        JSONObject mJSONObject = (JSONObject) obj;
                        int id = mJSONObject.getInt("id");
                        if (mContarctId == id) {
                            isExist = true;
                            break;
                        }
                    }
                }
            }
            if (!isExist) {
                addCollectCoin(mContext, getContractJsonStrById(mContext, mContarctId));
                return 1;
            } else {
                delCollectCoin(mContext, mContarctId, jsonArray);
                return 0;
            }
        } catch (JSONException e) {
            e.printStackTrace();
            return -1;
        }
    }
    public static int collectContractCoinTx(Context mContext, int mContarctId) {
        String contractJsonListStr = getContractJsonCollectListStr(mContext);
        try {
            boolean isExist = false;
            JSONArray jsonArray = null;
            if (!TextUtils.isEmpty(contractJsonListStr)){
                 jsonArray = new JSONArray(contractJsonListStr);
                for (int i = 0; i < jsonArray.length(); i++) {
                    Object cObj = jsonArray.get(i);
                    if(cObj instanceof JSONObject){
                        JSONObject mJSONObject = (JSONObject) cObj;
                        int id = mJSONObject.getInt("id");
                        if (mContarctId == id) {
                            isExist = true;
                            break;
                        }
                    }

                }
            }
            if (!isExist) {
                addCollectCoin(mContext, getContractJsonStrById(mContext, mContarctId));
                return 1;
            }
            return 1;
        } catch (JSONException e) {
            e.printStackTrace();
            return -1;
        }
    }

    /*
     *Cancel Collection
     */
    @RequiresApi(api = Build.VERSION_CODES.KITKAT)
    private static void delCollectCoin(Context mContext, int mContarctId, JSONArray mJSONArray) {
        try {
            JSONArray newArray = new JSONArray();
            for (int i = 0; i < mJSONArray.length(); i++) {
                JSONObject mJSONObject = (JSONObject) mJSONArray.get(i);
                int id = mJSONObject.getInt("id");
                if (mContarctId == id) {
//                    newArray.put(mJSONObject);
                    mJSONArray.remove(i);
                }
            }
            LogUtils.e("-----------delCollectCoin",mJSONArray.toString());
            setContractJsonCollectListStr(mContext, mJSONArray.toString());
        } catch (Exception e) {

        }
    }

    /*
     *Add Collection
     */
    private static void addCollectCoin(Context mContext, JSONObject mJSONObject) {
        String contractJsonListStr = getContractJsonCollectListStr(mContext);
        try {
            JSONArray jsonArray =null;
            if (TextUtils.isEmpty(contractJsonListStr)){
                jsonArray = new JSONArray();
                jsonArray.put(mJSONObject);
            }else {
                jsonArray = new JSONArray(contractJsonListStr);
                jsonArray.put(mJSONObject);
            }
            LogUtils.e("-----------addCollectCoin",jsonArray.toString());
            setContractJsonCollectListStr(mContext, jsonArray.toString());
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    public static boolean hasCollect(Context mContext, int mContarctId) {
        String contractJsonListStr = getContractJsonCollectListStr(mContext);
        try {
            if (TextUtils.isEmpty(contractJsonListStr)){
                return false;
            }
            JSONArray jsonArray = new JSONArray(contractJsonListStr);
            boolean isExist = false;
            for (int i = 0; i < jsonArray.length(); i++) {
                Object cObj = jsonArray.get(i);
                if(cObj instanceof JSONObject){
                    JSONObject mJSONObject = (JSONObject) cObj;
                    int id = mJSONObject.getInt("id");
                    if (mContarctId == id) {
                        isExist = true;
                        break;
                    }
                }
            }
            return isExist;
        } catch (JSONException e) {
            e.printStackTrace();
            return false;
        }
    }

    public static int getContractMultiplierPrecisionByMultiplier( String multiplier) {
        String multiplierBuff = new BigDecimal(multiplier).stripTrailingZeros().toPlainString();
        if (multiplierBuff.contains(".")) {
            int index = multiplierBuff.indexOf(".");
            int num = index < 0 ? 0 : multiplierBuff.length() - index - 1;
            return num;
        } else {
            return 0;
        }
    }

    //Obtain currency selection data for selecting vp+searchBar at the bottom
    public static Pair<ArrayList<CpTabInfo>,ArrayList<ContractListBean>> getDataBottomSearchVpDialog(Context context,int classificationBuff){
        final ArrayList<ContractListBean> mContractList = new ArrayList<>();
        final ArrayList<CpTabInfo> sideLeftList = new ArrayList<>();
        //Is it a pnlRecord
//        if (viewPagePosition==2){
//            mContractList.add(ContractListBean(contractShowType = CpLanguageUtil.getString(this,"cl_all_contract"),classification = -2,id = -2))
//        }
        mContractList.addAll( new Gson().fromJson(CpClLogicContractSetting.getContractJsonListStr(context), new TypeToken<List<ContractListBean>>() {}.getType()));
        for (ContractListBean obj : mContractList) {
            String contractShowType = obj.getContractShowType();
            int classification = obj.getClassification();
            boolean isExist = false;
            for (CpTabInfo buff : sideLeftList) {
                if (buff.getIndex() == classification) {
                    isExist = true;
                }
            }
            if (!isExist) {
                sideLeftList.add(new CpTabInfo(contractShowType, classification, classificationBuff==classification));
            }
        }
        return new Pair(sideLeftList,mContractList);
    }


    public interface ICpUserDataBridge{
        String getToken();
        void clearToken();
        String getDefLan();
        String getKlineWaterPath();
    }

    public void setCpUserDataBridge(ICpUserDataBridge userDataBridge){
        userDataBridgeImplReference = new WeakReference<>(userDataBridge);
    }

    public ICpUserDataBridge getUserDataBridgeImpl() {
        if(userDataBridgeImplReference==null){
            return null;
        }
        return userDataBridgeImplReference.get();
    }

    public static void setReqReviewData(String reviewData){
        getInstance().repReViewData = reviewData;
    }

    public static String getReqReviewData(){
        return getInstance().repReViewData;
    }

    public static HashMap<String,JSONObject> getConvertMapFromRepData(ArrayList<JSONObject> contractCollect) {
        String data = getReqReviewData();
        if("".equals(data)) return null;
        JSONObject rdata;
        try {
            rdata = new JSONObject(data);
            if (!rdata.isNull("data")) {
                JSONObject array = rdata.optJSONObject("data");
                if (null != array && array.length() > 0) {
                    Map<String, JSONObject> wsArrayMap = new HashMap<>();
                    for(JSONObject item : contractCollect) {
                        String key = item.getString("subSymbol");
                        JSONObject tick = array.optJSONObject(key);
                        if (tick != null) {
                            JSONObject itemObj = new JSONObject();
                            String channel = "market_"+key+"_ticker";
                            itemObj.put("tick", tick);
                            itemObj.put("channel", channel);
                            wsArrayMap.put(channel, itemObj);
                        }
                    }
                    return (HashMap)wsArrayMap;
                }
            }
        } catch (JSONException e) {
            e.printStackTrace();
            return null;
        }
        return null;
    }

    public static synchronized void updateReqReviewData(final HashMap<String, JSONObject> wsDataMap){
        ChainUpLogUtil.d(TAG,"updateReqReviewData running at >>>" + Thread.currentThread());
        if(Looper.getMainLooper().getThread() == Thread.currentThread()) return;
        String reqReviewData = getReqReviewData();
        if("".equals(reqReviewData)) return ;
        try {
            JSONObject jsonObject = new JSONObject(reqReviewData);
            if(!jsonObject.isNull("data")){
                HashMap<String, JSONObject> maps = new HashMap<>();
                JSONObject data = jsonObject.getJSONObject("data");
                Iterator<String> keys = data.keys();

                while (keys.hasNext()){
                    String key = keys.next();
                    String cChannel = "market_"+key+"_ticker";
                    if(wsDataMap.containsKey(cChannel)){
                        JSONObject jObject = wsDataMap.get(cChannel);
                        JSONObject tick = jObject.optJSONObject("tick");
                        maps.put(key,tick);
                        ChainUpLogUtil.v(TAG,"updateReqReviewData update at cChannel >>>" + cChannel);
                    }else{
                        maps.put(key,data.optJSONObject(key));
                    }
                }


                JSONObject newData = CpJSONUtil.mapToJson((Map)maps);
                jsonObject.put("data",newData);
                String uData = jsonObject.toString();
                ChainUpLogUtil.v(TAG,"updateReqReviewData update data >>>\n" + uData);
                setReqReviewData(uData);
            }

        } catch (JSONException e) {
            e.printStackTrace();
            ChainUpLogUtil.e(TAG,"updateReqReviewData update failed.");
        }

    }

    public static void setContractLanguageJsonListStr(Context context, String data) {
        CpPreferenceManager.getInstance(context).putSharedString(CpPreferenceManager.CONTRACT_LANGUAGE_JSON_LIST_STR, data);
    }

    public static String getContractLanguageJsonListStr(Context context) {
        return CpPreferenceManager.getInstance(context).getSharedString(CpPreferenceManager.CONTRACT_LANGUAGE_JSON_LIST_STR, "");
    }

    public static String getContractOriginalMarginCoinListStr(Context context) {
        return CpPreferenceManager.getInstance(context).getSharedString(CpPreferenceManager.CONTRACT_ORIGINAL_MARGIN_COIN_STR, "");
    }

    public static void setContractOriginalMarginCoinListStr(Context context, String data) {
        CpPreferenceManager.getInstance(context).putSharedString(CpPreferenceManager.CONTRACT_ORIGINAL_MARGIN_COIN_STR, data);
    }
}
