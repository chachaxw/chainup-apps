package com.yjkj.chainup.manager;

import android.text.TextUtils;
import android.util.Pair;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.yjkj.chainup.db.service.OTCPublicInfoDataService;
import com.yjkj.chainup.db.service.PublicInfoDataService;
import com.yjkj.chainup.net_new.JSONUtil;
import com.yjkj.chainup.util.StringOfExtKt;
import com.yjkj.chainup.util.StringUtil;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;

/**
 *@description: Currency pair data formatting processing
 * @Author: wanghao
 * @CreateDate: 2019-09-09 10:56
 * @UpdateUser: wanghao
 * @UpdateDate 2023-09-09 10:56
 *@ UpdateRemark: Update Description
 */
public class NCoinManager {

    private static final String TAG = "NCoinManager";

    public static final int defaultPrescion = 4;//Default precision digits
    public static final String defaultCoin = "btcusdt";//Default currency pair

    public static JSONObject getMarketObj() {
        JSONObject market = PublicInfoDataService.getInstance().getMarket(null);
        return market;
    }

    public static JSONArray getMarketSort() {
        JSONArray marketSort = PublicInfoDataService.getInstance().getMarketSort(null);
        return marketSort;
    }

    public static ArrayList<String> getMarketSortList() {
        JSONArray array = getMarketSort();
        return JSONUtil.arrayToStringList(array);
    }

    /*
     *Obtain all transaction pairs without grouping
     *@param needAllCoin true returns all currency pair data, otherwise only isShow=1 data will be returned
     */
    public static JSONArray getMarketArray(boolean needAllCoin) {
        JSONObject market = getMarketObj();
        if (null == market || market.length() <= 0) {
            return null;
        }
        Iterator<String> it = market.keys();

        JSONArray array = new JSONArray();
        while (it.hasNext()) {
            String key = it.next();
            JSONObject value = market.optJSONObject(key);
            Iterator<String> valueIt = value.keys();
            while (valueIt.hasNext()) {
                JSONObject valueObj = value.optJSONObject(valueIt.next());
                if (valueObj != null) {
                    if (needAllCoin) {
                        array.put(valueObj);
                    } else {
                        String isShow = valueObj.optString("isShow", "");
                        if (StringUtil.checkStr(isShow)) {
                            if ("1".equals(isShow)) {
                                array.put(valueObj);
                            }
                        } else {
                            array.put(valueObj);
                        }
                    }
                }

            }
        }
        return array;
    }


    /**
     *Return name based on showSymbol
     *
     * @param symbol
     * @return
     */
    public static String getMarketName4Symbol(String symbol) {
        if (!StringUtil.checkStr(symbol))
            return "";
        JSONArray jsonArray = getMarketArray(true);
        if (null == jsonArray || jsonArray.length() == 0) {
            return "";
        }
        for (int i = 0; i < jsonArray.length(); i++) {
            JSONObject jsonObject = jsonArray.optJSONObject(i);
            if (null != jsonObject && jsonObject.length() > 0) {
                String symbol4Json = jsonObject.optString("symbol", "");
                if (symbol.equals(symbol4Json)) {
                    String showName = jsonObject.optString("showName", "");
                    if (StringUtil.checkStr(showName)) {
                        return showName;
                    } else {
                        return jsonObject.optString("name", "");
                    }
                }
            }
        }
        return symbol;
    }

    /**
     *Return JSON based on symbol
     *
     * @param symbol
     * @return
     */
    public static JSONObject getMarket4Name(String symbol) {
        if (!StringUtil.checkStr(symbol))
            return null;
        JSONArray jsonArray = getMarketArray(true);
        if (null == jsonArray || jsonArray.length() == 0) {
            return null;
        }
        for (int i = 0; i < jsonArray.length(); i++) {
            JSONObject jsonObject = jsonArray.optJSONObject(i);
            if (null != jsonObject && jsonObject.length() > 0) {
                String symbol4Json = jsonObject.optString("symbol", "");
                if (symbol.equals(symbol4Json)) {
                    return jsonObject;
                }
            }
        }
        return null;
    }


    /*
     *Retrieve market data based on symbol
     */
    public static JSONObject getSymbolObj(String symbol) {
        if (!StringUtil.checkStr(symbol)) {
            return null;
        }
        JSONObject market = getMarketObj();
        if (null == market || market.length() <= 0)
            return null;

        Iterator<String> it = market.keys();
        boolean hasFind = false;
        JSONObject symbolObj = null;
        while (it.hasNext() && !hasFind) {
            String key = it.next();
            JSONObject value = market.optJSONObject(key);
            if (value == null) {
                return null;
            }
            Iterator<String> valueKeys = value.keys();
            while (valueKeys.hasNext() && !hasFind) {
                String valueKey = valueKeys.next();
                if (valueKey.contains("/")) {
                    String replace = valueKey.replace("/", "");
                    if (symbol.equalsIgnoreCase(replace)) {
                        hasFind = true;
                        symbolObj = value.optJSONObject(valueKey);
                        int newcoinFlag = symbolObj.optInt("newcoinFlag");
                        if (!symbolObj.optBoolean("isEdited", false)) {
                            try {
                                switch (newcoinFlag) {
                                    case 0:
                                        symbolObj.put("newcoinFlag", 1);
                                        break;
                                    case 1:
                                        symbolObj.put("newcoinFlag", 2);
                                        break;
                                    case 2:
                                        symbolObj.put("newcoinFlag", 3);
                                        break;
                                    case 3:
                                        symbolObj.put("newcoinFlag", 0);
                                        break;
                                }
                                symbolObj.put("isEdited", true);
                            } catch (JSONException e) {
                                e.printStackTrace();
                            }
                        }
                    }
                }
            }
        }

        return symbolObj;
    }


    /**
     * @return
     */

    public static String getDefaultThresholdForSort(String symbol) {
        if (TextUtils.isEmpty(symbol)) {
            return "0.1";
        }
        JSONObject marketAll = getMarketObj();
        if (null == marketAll || marketAll.length() == 0) {
            return "0.1";
        }
        Iterator<String> it = marketAll.keys();
        boolean hasFind = false;
        String threshold = "0.1";
        while (it.hasNext() && !hasFind) {
            String key = it.next();
            JSONObject value = marketAll.optJSONObject(key);
            Iterator<String> valueKeys = value.keys();
            while (valueKeys.hasNext() && !hasFind) {
                String valueKey = valueKeys.next();
                if (valueKey.contains("/")) {
                    String replace = valueKey.replace("/", "");
                    if (symbol.equalsIgnoreCase(replace)) {
                        hasFind = true;
                        threshold = value.optString("defaultThreshold", "0.1");
                        return threshold;
                    }
                }
            }
        }
        return "0.1";
    }


    /*
     *Display alias
     */
    public static @NonNull
    String showAnoterName(@Nullable JSONObject jsonObject) {
        if (null == jsonObject)
            return "";
        String name = jsonObject.optString("name", "");
        String showName = jsonObject.optString("showName");
        if (StringUtil.checkStr(showName))
            return showName;
        return name;
    }

    /*
     *Display alias
     */
    public static @NonNull
    String showAnoterName(@Nullable String name, @Nullable String showName) {
        if (StringUtil.checkStr(showName))
            return showName;
        return name != null ? name : "";
    }

    /*
     *
     *Obtain corresponding grouping data based on marketName
     */
    public synchronized static ArrayList<JSONObject> getMarketByName(String marketName) {
        if (!StringUtil.checkStr(marketName))
            return new ArrayList<JSONObject>();

        JSONObject jsonObject = getMarketObj();

        if (null == jsonObject)
            return new ArrayList<JSONObject>();
        jsonObject = jsonObject.optJSONObject(marketName);


        if (null == jsonObject) {
            return new ArrayList<JSONObject>();
        }

        ArrayList<JSONObject> list = new ArrayList<JSONObject>();
        Iterator<String> keys = jsonObject.keys();
        while (keys.hasNext()) {
            JSONObject jsonObj = jsonObject.optJSONObject(keys.next());


            if (null != jsonObj && jsonObj.length() > 0) {

                updateNewCoinFlag(jsonObj);
                String isShow = jsonObj.optString("isShow");

                if (getIsOverCharge(jsonObj.optString("name"))) {
                    try {
                        jsonObj.put("newcoinFlag", 4);
                        if (StringUtil.checkStr(isShow)) {
                            if ("1".equalsIgnoreCase(isShow)) {
                                list.add(jsonObj);
                            }
                        } else {
                            list.add(jsonObj);
                        }
                    } catch (JSONException e) {
                        e.printStackTrace();
                    }
                } else {
                    if (StringUtil.checkStr(isShow)) {
                        if ("1".equalsIgnoreCase(isShow)) {
                            list.add(jsonObj);
                        }
                    } else {
                        list.add(jsonObj);
                    }
                }
            }
        }


        Collections.sort(list, new Comparator<JSONObject>() {
            @Override
            public int compare(JSONObject o1, JSONObject o2) {
                int a = o1.optInt("newcoinFlag");
                int b = o2.optInt("newcoinFlag");
                return a - b;
            }
        });

        return list;
    }
public synchronized static ArrayList<JSONObject> getMarketByNameIsShow(String marketName ) {
        if (!StringUtil.checkStr(marketName))
            return new ArrayList<JSONObject>();

        JSONObject jsonObject = getMarketObj();

        if (null == jsonObject)
            return new ArrayList<JSONObject>();
        jsonObject = jsonObject.optJSONObject(marketName);


        if (null == jsonObject) {
            return new ArrayList<JSONObject>();
        }

        ArrayList<JSONObject> list = new ArrayList<JSONObject>();
        Iterator<String> keys = jsonObject.keys();
        while (keys.hasNext()) {
            JSONObject jsonObj = jsonObject.optJSONObject(keys.next());


            if (null != jsonObj && jsonObj.length() > 0) {

                updateNewCoinFlag(jsonObj);
                String isShow = jsonObj.optString("isShow");

                if (getIsOverCharge(jsonObj.optString("name"))) {
                    try {
                        jsonObj.put("newcoinFlag", 4);
                        list.add(jsonObj);
                    } catch (JSONException e) {
                        e.printStackTrace();
                    }
                } else {
                    list.add(jsonObj);
                }
            }
        }


        Collections.sort(list, new Comparator<JSONObject>() {
            @Override
            public int compare(JSONObject o1, JSONObject o2) {
                int a = o1.optInt("newcoinFlag");
                int b = o2.optInt("newcoinFlag");
                return a - b;
            }
        });

        return list;
    }


    public static boolean getIsOverCharge(String name) {
        boolean isOverstatus = false;
        String coinName = getMarketShowCoinName(name);
        JSONObject jsonObject = PublicInfoDataService.getInstance().getCoinList(null);
        if (jsonObject == null) {
            return isOverstatus;
        }
        JSONObject bean = jsonObject.optJSONObject(coinName);
        if (null != bean && bean.optInt("isOvercharge") == 1) {
            isOverstatus = true;
        }
        return isOverstatus;
    }


    /*
     *Find symbol based on currency name
     */
    public static String getSymbol(String coinName) {
        if (!StringUtil.checkStr(coinName))
            return defaultCoin;
        JSONObject market = getMarketObj();
        if (null == market || market.length() <= 0)
            return defaultCoin;

        JSONArray marketSort = getMarketSort();
        if (null == marketSort || marketSort.length() <= 0) {
            return defaultCoin;
        }

        for (int i = 0; i < marketSort.length(); i++) {
            String marketName = marketSort.optString(i);
            JSONObject obj = market.optJSONObject(marketName);
            if (null != obj && obj.length() > 0) {
                JSONArray coinLen = obj.names();
                for (int j = 0; j < coinLen.length(); j++) {
                    String coinSplit = coinLen.opt(j).toString();
                    boolean isCoin = coinSplit.split("/")[0].toUpperCase().equals(coinName);
                    if (isCoin) {
                        JSONObject coin = obj.optJSONObject(coinSplit);
                        return coin.optString("symbol");
                    }
                }
            }
        }
        return defaultCoin;
    }

    /*
     *Match transaction pairs to obtain the name value
     */
    public static synchronized ArrayList<JSONObject> getSymbols(JSONArray topSymbol) {


        if (null == topSymbol || topSymbol.length() <= 0)
            return null;

        JSONArray marketArray = getMarketArray(false);

        if (null == marketArray || marketArray.length() <= 0)
            return null;

        ArrayList<JSONObject> selectTopSymbol = new ArrayList<JSONObject>();


        for (int i = 0; i < topSymbol.length(); i++) {
            JSONObject topSymbolObj = topSymbol.optJSONObject(i);
            String topSymbolObjName = topSymbolObj.optString("symbol");

            for (int j = 0; j < marketArray.length(); j++) {
                JSONObject marketObj = marketArray.optJSONObject(j);

                String symbol = marketObj.optString("symbol");

                if (null != symbol) {
                    if (symbol.equalsIgnoreCase(topSymbolObjName)) {
                        try {
                            topSymbolObj.put("name", marketObj.optString("name"));
                            topSymbolObj.put("showName", showAnoterName(marketObj));
                            topSymbolObj.put("homeIndex", "" + (i + 1));
                            topSymbolObj.put("price", marketObj.optInt("price"));
                            selectTopSymbol.add(topSymbolObj);
                        } catch (JSONException e) {
                            e.printStackTrace();
                        }
                        break;
                    }
                }

            }
        }
        return selectTopSymbol;
    }

    /*
     *Search for local currency pair data
     */
    public static ArrayList<JSONObject> getSearchData(ArrayList<JSONObject> symbols, String keyWords) {
        if (!StringUtil.checkStr(keyWords) || null == symbols || symbols.size() <= 0)
            return null;

        ArrayList<JSONObject> searchData = new ArrayList<JSONObject>();
        for (int i = 0; i < symbols.size(); i++) {
            JSONObject jsonObject = symbols.get(i);
            String name = jsonObject.optString("name");
            if (null != name && name.contains("/")) {
                String[] split = name.split("/");
                if (split[0].contains(keyWords.toUpperCase())) {
                    searchData.add(jsonObject);
                }
            }
        }
        return searchData;
    }


    /*
     *Display corresponding aliases based on currency pair grouping names
     */
    public static String getCoinShowTitle(String marketSort) {
        if (!StringUtil.checkStr(marketSort)) {
            return null;
        }

        JSONObject jsonObject = PublicInfoDataService.getInstance().getMarket(null);

        if (null == jsonObject || jsonObject.length() <= 0)
            return marketSort;
        JSONObject data = jsonObject.optJSONObject(marketSort);
        if (null != data && data.length() > 0) {
            Iterator<String> it = data.keys();

            boolean hasFind = false;
            while (it.hasNext() && !hasFind) {
                JSONObject value = data.optJSONObject(it.next());
                if (null != value && value.length() > 0) {
                    String name = showAnoterName(value);
                    if (null != name && name.contains("/")) {
                        hasFind = true;
                        String aa = name.split("/")[1];
                        return aa;
                    }
                }
            }
        }
        return marketSort;
    }

    /**
     *@return Returns the name of the currency in which OTC is enabled
     */
    public static ArrayList<String> getMarkets4OTC() {
        JSONObject jsonObject = PublicInfoDataService.getInstance().getCoinList(null);
        if (null != jsonObject && jsonObject.length() > 0) {

            ArrayList<String> coinList = new ArrayList<String>();
            Iterator<String> keys = jsonObject.keys();
            while (keys.hasNext()) {
                String key = keys.next();
                JSONObject value = jsonObject.optJSONObject(key);
                if (null != value && value.length() > 0) {
                    String otcOpen = value.optString("otcOpen", "0");
                    String name = value.optString("name", "");
                    if (otcOpen != null && "1".equalsIgnoreCase(otcOpen)) {
                        coinList.add(name);
                    }
                }
            }
            return coinList;
        }
        return null;
    }

    /**
     *@return Returns the name of the currency in which OTC is enabled
     */
    public static ArrayList<String> getMarketsShowName4OTC() {
        JSONObject jsonObject = PublicInfoDataService.getInstance().getCoinList(null);
        if (null != jsonObject && jsonObject.length() > 0) {

            ArrayList<String> coinList = new ArrayList<String>();
            Iterator<String> keys = jsonObject.keys();
            while (keys.hasNext()) {
                String key = keys.next();
                JSONObject value = jsonObject.optJSONObject(key);
                if (null != value && value.length() > 0) {
                    String otcOpen = value.optString("otcOpen", "0");
                    String name = value.optString("showName", "");
                    if (otcOpen != null && "1".equalsIgnoreCase(otcOpen)) {
                        coinList.add(name);
                    }
                }
            }
            return coinList;
        }
        return null;
    }


    /**
     *Get showName
     */
    public static String getShowMarket(String name) {
        if (!StringUtil.checkStr(name))
            return "";
        JSONObject jsonObject = PublicInfoDataService.getInstance().getCoinList(null);
        if (null != jsonObject && jsonObject.length() > 0) {
            Iterator<String> keys = jsonObject.keys();
            while (keys.hasNext()) {
                String key = keys.next();
                JSONObject value = jsonObject.optJSONObject(key);
                if (null != value && value.length() > 0) {
                    String name4Data = value.optString("name", "");
                    if (name != null && name.equals(name4Data)) {
                        return value.optString("showName", "");
                    }
                }
            }
        }
        return name;
    }

    /**
     *The main reason for handling this is because the historical commission filters the user's currency filling search. The user's filling in showName requires the backend to handle it themselves, but iOS handles it itself, which is why this is done locally......
     */
    public static String setShowNameGetName(String name) {
        if (!StringUtil.checkStr(name))
            return name;
        JSONObject jsonObject = PublicInfoDataService.getInstance().getCoinList(null);
        if (null != jsonObject && jsonObject.length() > 0) {
            Iterator<String> keys = jsonObject.keys();
            while (keys.hasNext()) {
                String key = keys.next();
                JSONObject value = jsonObject.optJSONObject(key);
                if (null != value && value.length() > 0) {
                    String name4Data = value.optString("showName", "");
                    if (name != null && name.equalsIgnoreCase(name4Data)) {
                        return value.optString("name", "");
                    }
                }
            }
        }
        return name;
    }


    /**
     *Obtaining CoinTag of Data
     *
     * @param coinName
     * @return
     */
    public static String getCoinTag4CoinName(String coinName) {
        if (!StringUtil.checkStr(coinName))
            return "";
        JSONObject jsonObject = PublicInfoDataService.getInstance().getCoinList(null);
        String coinTag = "";
        if (null != jsonObject && jsonObject.length() > 0) {
            Iterator<String> keys = jsonObject.keys();
            while (keys.hasNext()) {
                String key = keys.next();
                JSONObject value = jsonObject.optJSONObject(key);
                if (null != value && value.length() > 0) {
                    String name4Data = value.optString("name", "");
                    String showName = value.optString("showName", "");
                    if (coinName != null && (coinName.equals(name4Data) || coinName.equals(showName))) {
                        return value.optString("coinTag", "");
                    }
                }
            }
        }
        return coinTag;
    }


    /**
     *Get showName
     */
    public static String getName4Symbol(String name) {
        String showName = name;
        JSONObject jsonObject = PublicInfoDataService.getInstance().getMarket(null);
        if (null == jsonObject || jsonObject.length() <= 0)
            return showName;
        Iterator<String> its = jsonObject.keys();
        while (its.hasNext()) {
            JSONObject data = jsonObject.optJSONObject(its.next());
            JSONObject object = data.optJSONObject(name);
            if (null != object && object.length() > 0) {
                String name4Data = object.optString("symbol");
                if (StringUtil.checkStr(name4Data)) {
                    return name4Data;
                } else {
                    return showName;
                }
            }
        }
        return showName;
    }

    /**
     *Get name
     */
    public static String getNameForSymbol(String symbol) {
        JSONObject jsonObject = PublicInfoDataService.getInstance().getMarket(null);
        if (null == jsonObject || jsonObject.length() <= 0)
            return "";
        Iterator<String> its = jsonObject.keys();
        while (its.hasNext()) {
            JSONObject data = jsonObject.optJSONObject(its.next());
            Iterator<String> itsMarket = data.keys();
            while (itsMarket.hasNext()) {
                JSONObject dataMarket = data.optJSONObject(itsMarket.next());
                if (symbol.equals(dataMarket.optString("symbol"))) {
                    return dataMarket.optString("name");
                }
            }
        }
        return "";
    }


    /**
     *@return Returns the currency data for opening OTC
     * otcOpen==1
     */
    public static ArrayList<JSONObject> getCoins4OTC() {
        JSONObject jsonObject = PublicInfoDataService.getInstance().getCoinList(null);
        if (null != jsonObject && jsonObject.length() > 0) {

            ArrayList<JSONObject> coinList = new ArrayList<JSONObject>();
            Iterator<String> keys = jsonObject.keys();
            while (keys.hasNext()) {
                String key = keys.next();
                JSONObject value = jsonObject.optJSONObject(key);
                if (null != value && value.length() > 0) {
                    String otcOpen = value.optString("otcOpen", "0");
                    if (otcOpen != null && "1".equalsIgnoreCase(otcOpen)) {
                        coinList.add(value);
                    }
                }
            }
            return coinList;
        }
        return null;
    }


    /*
     *Return precision value
     */
    public static int getCoinShowPrecision(String coinName) {
        JSONObject jsonObject = getCoinObj(coinName);
        if (null != jsonObject) {
            return jsonObject.optInt("showPrecision");
        }
        return defaultPrescion;
    }

    /*
     *Returns a JSONObject in the coinList based on the coinName
     */
    public static JSONObject getCoinObj(String coinName) {
        if (!StringUtil.checkStr(coinName)) {
            return null;
        }

        JSONObject jsonObject = PublicInfoDataService.getInstance().getCoinList(null);
        if (null != jsonObject) {
            return jsonObject.optJSONObject(coinName.toUpperCase());
        }
        return null;
    }

    /*
     *Determine whether the coinName has priority in the market and return the corresponding symbol based on it
     *Todo testing
     */
    public static String isExistMarket(String coinName) {
        if (!StringUtil.checkStr(coinName))
            return "";

        JSONObject market = getMarketObj();
        if (null == market || market.length() <= 0) {
            return "";
        }

        Iterator<String> keys = market.keys();
        boolean hasFind = false;
        while (keys.hasNext() && !hasFind) {
            String key = keys.next();
            JSONObject value = market.optJSONObject(key);

            Iterator<String> keys2 = value.keys();
            while (keys2.hasNext() && !hasFind) {
                String coinMarketName = keys2.next();
                JSONObject obj = value.optJSONObject(coinMarketName);
                if (null != obj && obj.length() > 0) {
                    hasFind = true;
                    return obj.optString("symbol");
                }
            }
        }
        return "";
    }

    /**
     *Determine whether the currency pair exists
     *
     * @param exchangeSymbol
     * @return
     */
    public static String returnExistMarket(String exchangeSymbol) {
        if (!StringUtil.checkStr(exchangeSymbol))
            return "";

        JSONObject market = getMarketObj();
        if (null == market || market.length() <= 0) {
            return "";
        }
        Iterator<String> keys = market.keys();
        while (keys.hasNext()) {
            String key = keys.next();
            JSONObject value = market.optJSONObject(key);

            Iterator<String> keys2 = value.keys();
            while (keys2.hasNext()) {
                String coinMarketName = keys2.next();
                if (coinMarketName.equals(exchangeSymbol)) {
                    JSONObject obj = value.optJSONObject(coinMarketName);
                    if (null != obj && obj.length() > 0) {
                        return obj.optString("symbol");
                    }
                }
            }
        }
        return "";
    }

    /*
     *Rewrite the original DataManager method
     */
    public static Pair<String, String> getShowName(String market, String second) {
        JSONArray array = getMarketArray(true);
        if (null != array && array.length() > 0) {
            String coin_market = market + "/" + second;
            for (int i = 0; i < array.length(); i++) {
                String name = array.optJSONObject(i).optString("name");
                if (coin_market.equals(name)) {
                    String showName = array.optJSONObject(i).optString("showName");
                    if (StringUtil.checkStr(showName) && showName.contains("/")) {
                        String[] split = showName.split("/");
                        Pair<String, String> p = new Pair<String, String>(split[0], split[1]);
                        return p;
                    }

                }
            }
        }
        return new Pair<String, String>(market, second);
    }


    /*
     *Obtain coinName based on market
     */
    public static String getMarketCoinName(String name) {
        if (StringUtil.checkStr(name) && name.contains("/")) {
            return name.split("/")[0];
        }
        return "";
    }

    /*
     *Obtain marketName based on market
     */
    public static String getMarketName(String name) {
        if (StringUtil.checkStr(name) && name.contains("/")) {
            return name.split("/")[1];
        }
        return "";
    }

    /*
     *Display the alias of CoinName based on showName
     */
    public static String getMarketShowCoinName(String showName) {
        if (StringUtil.checkStr(showName) && showName.contains("/")) {
            return showName.split("/")[0];
        }
        return "";
    }


    /**
     * @return
     */

    public static int getMarketForSort(String market) {
        JSONObject marketAll = getMarketObj();
        if (null == marketAll || marketAll.length() == 0) {
            return 0;
        }
        String coin = getMarketName(market);
        JSONObject json = marketAll.optJSONObject(coin);
        if (null != json && json.length() > 0) {
            JSONObject marketJson = json.optJSONObject(market);
            if (null != marketJson && marketJson.length() > 0) {
                int symbolInt = marketJson.optInt("sort", 0);
                return symbolInt;
            }
        }
        return 0;
    }


    /*
     *Display the alias of CoinName based on the symbol
     */
    public static String getMarketShowCoinName2(String symbol) {
        String showName = showAnoterName(getSymbolObj(symbol));
        if (StringUtil.checkStr(showName) && showName.contains("/")) {
            return showName.split("/")[0];
        }
        return symbol;

    }

    /**
     *Get showName
     */
    public static String getShowMarketName(String name) {
        String showName = name;
        JSONObject jsonObject = PublicInfoDataService.getInstance().getMarket(null);
        if (null == jsonObject || jsonObject.length() <= 0)
            return showName;
        Iterator<String> its = jsonObject.keys();
        while (its.hasNext()) {
            JSONObject data = jsonObject.optJSONObject(its.next());
            JSONObject object = data.optJSONObject(name);
            if (null != object && object.length() > 0) {
                String name4Data = object.optString("showName");
                if (StringUtil.checkStr(name4Data)) {
                    return name4Data;
                } else {
                    return showName;
                }
            }
        }
        return showName;
    }

    public static ArrayList<JSONObject> getLeverMapList(JSONObject data) {
        if (null != data) {
            Iterator<String> keys = data.keys();
            ArrayList<JSONObject> arrayList = new ArrayList<>();
            try {
                while (keys.hasNext()) {
                    String key = keys.next();
                    JSONObject volume = data.optJSONObject(key);
                    if (null != volume && volume.length() > 0) {
                        volume.put("sort", getMarketForSort(volume.optString("name")));
                        arrayList.add(volume);
                    }
                }
            } catch (JSONException e) {
                e.printStackTrace();
            }
            return arrayList;
        }
        return new ArrayList<JSONObject>();
    }


    /**
     *Obtain key based on data
     */
    public static ArrayList<String> getKeyList(JSONObject jsonObject) {
        if (null != jsonObject) {
            return new ArrayList<String>();
        }
        Iterator<String> keys = jsonObject.keys();
        ArrayList<String> arrayList = new ArrayList<>();

        while (keys.hasNext()) {
            String key = keys.next();
            arrayList.add(key);
        }
        return arrayList;
    }

    /**
     *Get Grid List
     *
     * @param market
     * @return
     */
    public static ArrayList<JSONObject> getGridCroupList(String market) {
        JSONObject marketObj = getMarketObj();
        if (null == marketObj || marketObj.length() <= 0)
            return null;
        ArrayList<JSONObject> list = new ArrayList<JSONObject>();
        Iterator<String> keys = marketObj.keys();
        while (keys.hasNext()) {
            String key = keys.next();
            JSONObject value = marketObj.optJSONObject(key);
            if (null != value) {
                Iterator<String> keys2 = value.keys();
                while (keys2.hasNext()) {
                    String key2 = keys2.next();
                    JSONObject value2 = value.optJSONObject(key2);
                    if (null != value2) {
                        String isOpenLever = value2.optString("is_grid_open");
                        if ("1".equals(isOpenLever)) {
                            try {
                                value2.put("marketSortType", key);
                            } catch (Exception e) {
                                e.printStackTrace();
                            }
                            updateNewCoinFlag(value2);
                            if (StringUtil.checkStr(market)) {
                                if(key.equals(market)){
                                    list.add(value2);
                                }
                            }else{
                                list.add(value2);
                            }
                        }
                    }
                }
            }
        }
        if (list.size() > 0) {
            Collections.sort(list, new Comparator<JSONObject>() {
                @Override
                public int compare(JSONObject o1, JSONObject o2) {
                    return o1.optInt("newcoinFlag") - o2.optInt("newcoinFlag");
                }
            });
        }
        return list;
    }


    /*
     *Obtain the coin pair grouping title of the grid sidebar
     */
    public static ArrayList<String> getGridGroup() {
        ArrayList<JSONObject> list = getGridCroupList(null);
        if (null != list && list.size() > 0) {
            ArrayList<String> titles = new ArrayList<String>();
            String lastMarketName = "";
            for (int i = 0; i < list.size(); i++) {
                JSONObject value = list.get(i);
                if (null != value) {
                    String marketName = value.optString("marketSortType", "");
                    if (!lastMarketName.equals(marketName)) {
                        lastMarketName = marketName;
                        if (!titles.contains(marketName)) {
                            titles.add(marketName);
                        }
                    }
                }
            }
            return titles;
        }
        return null;
    }

    /*
     *Obtain currency pair grouping data from the leverage sidebar
     *If @param is empty, return all data with isOpenLevel=1
     */
    public static ArrayList<JSONObject> getLeverGroupList(String market) {
        JSONObject marketObj = getMarketObj();
        if (null == marketObj || marketObj.length() <= 0)
            return null;

        ArrayList<JSONObject> list = new ArrayList<JSONObject>();
        Iterator<String> keys = marketObj.keys();
        while (keys.hasNext()) {
            String key = keys.next();
            JSONObject value = marketObj.optJSONObject(key);
            if (null != value) {
                Iterator<String> keys2 = value.keys();
                while (keys2.hasNext()) {
                    String key2 = keys2.next();
                    JSONObject value2 = value.optJSONObject(key2);
                    if (null != value2) {
                        String isOpenLever = value2.optString("isOpenLever");
                        if ("1".equals(isOpenLever)) {
                            updateNewCoinFlag(value2);
                            if (StringUtil.checkStr(market)) {
                                String name = showAnoterName(value2);
                                if (null != name && name.contains("/")) {
                                    if (market.equals(name.split("/")[1])) {
                                        list.add(value2);
                                    }
                                }
                            } else {
                                list.add(value2);
                            }
                        }
                    }
                }
            }
        }
        if (list.size() > 0) {
            Collections.sort(list, new Comparator<JSONObject>() {
                @Override
                public int compare(JSONObject o1, JSONObject o2) {
                    return o1.optInt("newcoinFlag") - o2.optInt("newcoinFlag");
                }
            });
        }
        return list;
    }

    /*
     *Obtain the coin pair grouping title in the lever sidebar
     */
    public static ArrayList<String> getLeverGroup() {
        ArrayList<JSONObject> list = getLeverGroupList(null);
        if (null != list && list.size() > 0) {
            ArrayList<String> titles = new ArrayList<String>();
            String lastMarketName = "";
            for (int i = 0; i < list.size(); i++) {
                JSONObject value = list.get(i);
                if (null != value) {
                    String name = showAnoterName(value);
                    String marketName = getMarketName(name);
                    if (!lastMarketName.equals(marketName)) {
                        lastMarketName = marketName;
                        if (!titles.contains(marketName)) {
                            titles.add(marketName);
                        }
                    }
                }
            }
            return titles;
        }
        return null;
    }

    public static String setsymbolNameGetShowName(String name) {
        if (!StringUtil.checkStr(name))
            return name;
        JSONObject jsonObject = PublicInfoDataService.getInstance().getCoinList(null);
        if (null != jsonObject && jsonObject.length() > 0) {
            Iterator<String> keys = jsonObject.keys();
            while (keys.hasNext()) {
                String key = keys.next();
                JSONObject value = jsonObject.optJSONObject(key);
                if (null != value && value.length() > 0) {
                    String name4Data = value.optString("showName", "");
                    String nameGet = value.optString("name", "");
                    if (name != null && (name.equalsIgnoreCase(name4Data) || name.equalsIgnoreCase(nameGet))) {
                        return name4Data;
                    }
                }
            }
        }
        return name;
    }


    public static double getFeeOtc4Advertising(String symbol) {
        if (!StringUtil.checkStr(symbol))
            return 0;
        double rate = 0;
        ArrayList<JSONObject> jsonObjectArrayList = OTCPublicInfoDataService.getInstance().getFeeOtcList();
        if (jsonObjectArrayList == null) return 0f;

        for (int i = 0; i < jsonObjectArrayList.size(); i++) {
            if (symbol.equals(jsonObjectArrayList.get(i).optString("symbol"))) {
                rate = jsonObjectArrayList.get(i).optDouble("rate");
                break;
            }
        }
        return rate;
    }

    /*
     *Find symbol based on currency name
     */
    public static String getSymbolV2(String coinName) {
        if (!StringUtil.checkStr(coinName))
            return "";

        JSONArray marketArray = getMarketArray(false);
        for (int i = 0; i < marketArray.length(); i++) {
            JSONObject obj = marketArray.optJSONObject(i);
            if (null != obj && obj.length() > 0) {
                String coin = obj.optString("name");
                if (coin.contains(coinName)) {
                    String symbol = obj.optString("symbol");
                    return symbol;
                }
            }
        }

        return coinName;
    }

    private static void updateNewCoinFlag(JSONObject jsonObj) {
        if (!jsonObj.optBoolean("isEdited", false)) {
            int newcoinFlag = jsonObj.optInt("newcoinFlag");
            try {
                switch (newcoinFlag) {
                    case 0:
                        jsonObj.put("newcoinFlag", 1);
                        break;
                    case 1:
                        jsonObj.put("newcoinFlag", 2);
                        break;
                    case 2:
                        jsonObj.put("newcoinFlag", 3);
                        break;
                    case 3:
                        jsonObj.put("newcoinFlag", 0);
                        break;
                }
                jsonObj.put("isEdited", true);
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }
    }

    /*
     *Find all currency pairs based on their names
     */
    public static ArrayList<JSONObject> getSymbolByMarket(String coinName, Boolean isLever) {
        if (!StringUtil.checkStr(coinName))
            return null;
        JSONObject market = getMarketObj();
        if (null == market || market.length() <= 0)
            return null;

        JSONArray marketSort = getMarketSort();
        if (null == marketSort || marketSort.length() <= 0) {
            return null;
        }
        ArrayList<JSONObject> coinList = new ArrayList<>();
        for (int i = 0; i < marketSort.length(); i++) {
            String marketName = marketSort.optString(i);
            JSONObject obj = market.optJSONObject(marketName);
            if (null != obj && obj.length() > 0) {
                JSONArray coinLen = obj.names();
                if (coinLen == null) {
                    continue;
                }
                for (int j = 0; j < coinLen.length(); j++) {
                    String coinSplit = coinLen.opt(j).toString();
                    boolean isCoin = coinSplit.split("/")[0].toUpperCase().equals(coinName);
                    if (isCoin) {
                        JSONObject coin = obj.optJSONObject(coinSplit);
                        if (coin != null) {
                            if (!isLever) {
                                coinList.add(coin);
                            } else {
                                boolean isOpenLever = coin.has("isOpenLever") && !coin.optString("isOpenLever").equals("0");
                                if (isOpenLever) {
                                    coinList.add(coin);
                                }
                            }
                        }
                    }
                }
            }
        }
        return coinList;
    }

    /*
     *Return precision value
     */
    public static int getMarketCoinShowPrecision(String coinName) {
        JSONObject jsonObject = getMarketCoinObj(coinName);
        if (null != jsonObject) {
            return jsonObject.optInt("price");
        }
        return defaultPrescion;
    }

    /*
     *Returns a JSONObject in the coinList based on the coinName
     */
    public static JSONObject getMarketCoinObj(String coinName) {
        if (!StringUtil.checkStr(coinName)) {
            return null;
        }

        JSONObject jsonObject = PublicInfoDataService.getInstance().getMarket(null);

        Iterator<String> its = jsonObject.keys();
        while (its.hasNext()) {
            JSONObject data = jsonObject.optJSONObject(its.next());
            if (data == null) {
                return data;
            }
            Iterator<String> itsMarket = data.keys();
            while (itsMarket.hasNext()) {
                JSONObject dataMarket = data.optJSONObject(itsMarket.next());
                if (dataMarket != null && coinName.equals(dataMarket.optString("symbol"))) {
                    return dataMarket;
                }
            }
        }
        return null;
    }

    public static boolean getMarketIsHeader() {
        boolean otcOpen = PublicInfoDataService.getInstance().otcOpen(null);
        return otcOpen || getMarketLeverOpen() || getMarketGridOpen();
    }

    public static boolean getMarketLeverOpen() {
        boolean isLever = PublicInfoDataService.getInstance().isLeverOpen(null);
        if (isLever) {
            ArrayList<String> leverGroup = NCoinManager.getLeverGroup();
            if (leverGroup != null && leverGroup.size() > 0) {
                return true;
            }
        }
        return false;
    }

    public static boolean getMarketGridOpen() {
        boolean isLever = PublicInfoDataService.getInstance().isGridTradSwitch(null);
        if (isLever) {
            ArrayList<String> gridGroup = NCoinManager.getGridGroup();
            if (gridGroup != null && gridGroup.size() > 0) {
                return true;
            }
        }
        return false;
    }

    /*
     *
     *Obtain corresponding grouping data based on marketName
     */
    public synchronized static Pair<ArrayList<JSONObject>, HashMap<Integer,String>> getMarketByNameNew(String marketName) {
        Pair pair = new Pair(new ArrayList<JSONObject>(),new HashMap<Integer,String>());
        if (!StringUtil.checkStr(marketName))
            return pair;

        JSONObject jsonObject = getMarketObj();

        if (null == jsonObject)
            return pair;
        jsonObject = jsonObject.optJSONObject(marketName);


        if (null == jsonObject) {
            return pair;
        }
        HashMap<Integer,String> mapType = new  HashMap<Integer,String>();
        ArrayList<JSONObject> list = new ArrayList<JSONObject>();
        Iterator<String> keys = jsonObject.keys();
        while (keys.hasNext()) {
            JSONObject jsonObj = jsonObject.optJSONObject(keys.next());


            if (null != jsonObj && jsonObj.length() > 0) {

                updateNewCoinFlag(jsonObj);
                String isShow = jsonObj.optString("isShow");

                if (getIsOverCharge(jsonObj.optString("name"))) {
                    try {
                        jsonObj.put("newcoinFlag", 4);
                        mapType.put(4,"4");
                        if (StringUtil.checkStr(isShow)) {
                            if ("1".equalsIgnoreCase(isShow)) {
                                list.add(jsonObj);
                            }
                        } else {
                            list.add(jsonObj);
                        }
                    } catch (JSONException e) {
                        e.printStackTrace();
                    }
                } else {
                    int key = jsonObj.optInt("newcoinFlag",-1);
                    mapType.put(key,key +"");
                    if (StringUtil.checkStr(isShow)) {
                        if ("1".equalsIgnoreCase(isShow)) {
                            list.add(jsonObj);
                        }
                    } else {
                        list.add(jsonObj);
                    }
                }
            }
        }


        Collections.sort(list, new Comparator<JSONObject>() {
            @Override
            public int compare(JSONObject o1, JSONObject o2) {
                int a = o1.optInt("newcoinFlag");
                int b = o2.optInt("newcoinFlag");
                return a - b;
            }
        });

        return new Pair(list,mapType);
    }

    public synchronized static List<JSONObject> getMarketByLikeDefault() {
        JSONArray array = PublicInfoDataService.getInstance().getMarketSort(null);
        if(array != null && array.length() !=0){
            ArrayList<JSONObject> coins = new ArrayList<JSONObject>();
            for (int i = 0; i < array.length(); i++){
                String market = array.optString(i);
                Pair<ArrayList<JSONObject>, HashMap<Integer,String>> arrays =  NCoinManager.getMarketByNameNew(market);
                coins.addAll(StringOfExtKt.getBySortDefault(arrays.first));
            }
            return StringOfExtKt.getBySortTop6Default(coins);
        }
        return new ArrayList<JSONObject>();
    }

}
