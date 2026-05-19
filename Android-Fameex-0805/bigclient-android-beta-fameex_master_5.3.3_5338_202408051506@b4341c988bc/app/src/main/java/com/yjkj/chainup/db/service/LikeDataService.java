package com.yjkj.chainup.db.service;

import androidx.annotation.Nullable;

import com.yjkj.chainup.db.MMKVDb;
import com.yjkj.chainup.manager.NCoinManager;
import com.yjkj.chainup.net_new.JSONUtil;
import com.yjkj.chainup.util.StringUtil;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;

/**
 *@description: Collect custom data
 * @Author: wanghao
 * @CreateDate: 2019-08-09 12:26
 * @UpdateUser: wanghao
 * @UpdateDate 2023-08-09 12:26
 *@ UpdateRemark: Update Description
 */
public class LikeDataService {

    private static final String TAG = "LikeDataService";

    private static final String collectData = "collectData";

    private MMKVDb mMMKVDb;

    private LikeDataService() {
        mMMKVDb = new MMKVDb();
    }

    private static LikeDataService mLikeDataService;

    public static LikeDataService getInstance() {
        if (null == mLikeDataService) {
            mLikeDataService = new LikeDataService();
        }
        return mLikeDataService;
    }

    /*
     *Save Favorite/Custom Data
     */
    public void saveCollecData(String symbol, @Nullable JSONObject symbolObj) {
        if (null == symbolObj || symbolObj.length() <= 0)
             symbolObj = NCoinManager.getSymbolObj(symbol);

        JSONArray array = getCollecArray();
        if (null != array) {
            for (int i = 0; i < array.length(); i++) {
                JSONObject obj = array.optJSONObject(i);
                if(obj==null) continue;
                if (symbol.equalsIgnoreCase(obj.optString("symbol"))) {
                    return;
                }
            }
        } else {
            array = new JSONArray();
        }
        array.put(symbolObj);
        mMMKVDb.saveData(collectData, array.toString());
    }

    /*
     *Has it been added to the self selection
     */
    public boolean hasCollect(String symbol) {
        JSONArray array = getCollecArray();
        if (null == array || array.length() <= 0)
            return false;
        for (int i = 0; i < array.length(); i++) {
            JSONObject jsonObject = array.optJSONObject(i);
            if(jsonObject==null) continue;
            if (jsonObject.optString("symbol").equalsIgnoreCase(symbol)) {
                return true;
            }
        }
        return false;
    }

    /*
     *Remove Selection
     */
    public ArrayList<JSONObject> removeCollect(String symbol) {
        JSONArray array = removeCollectArray(symbol);
        ArrayList<JSONObject> list = JSONUtil.arrayToList(array);
        if (null != list && list.size() > 0) {
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
        return null;
    }

    private JSONArray removeCollectArray(String symbol) {
        JSONArray array = getCollecArray();
        if (null == array || array.length() <= 0)
            return null;

        JSONArray newArray = new JSONArray();
        for (int i = 0; i < array.length(); i++) {
            JSONObject jsonObject = array.optJSONObject(i);
            if (!(jsonObject.optString("symbol").equalsIgnoreCase(symbol))) {
                newArray.put(jsonObject);
            }
        }
        mMMKVDb.saveData(collectData, newArray.toString());
        return newArray;
    }

    /*
     *Clear all local currency pair data void
     */
    public void clearAllCollect() {
        mMMKVDb.saveData(collectData, "");
    }

    /*
     *Local search for currency pair data and market currency pair, for the final display of locally selected data
     */
    public synchronized ArrayList<JSONObject> getCollecData(boolean isLever) {
        ArrayList<JSONObject> list = JSONUtil.arrayToList(getCollecArray());
        if (null != list && list.size() > 0) {

            for (int i = 0; i < list.size(); i++) {
                JSONObject jsonObj = list.get(i);
                int newcoinFlag = jsonObj.optInt("newcoinFlag");
                if (!jsonObj.optBoolean("isEdited", false)) {
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
            if (PublicInfoDataService.getInstance().isLeverOpen(null) && isLever) {
                ArrayList<JSONObject> newList = new ArrayList<>();
                if (list != null && list.size() > 0) {
                    for (int i = 0; i < list.size(); i++) {
                        JSONObject jsonObject = list.get(i);
                        boolean isOpenLever = jsonObject.has("isOpenLever") && !"0".equals(jsonObject.optString("isOpenLever"));
                        boolean multiple = jsonObject.has("multiple") && !"0".equals(jsonObject.optString("multiple"));
                        if (multiple && isOpenLever) {
                            newList.add(jsonObject);
                        }
                    }
                }
                return newList;
            } else {
                return list;
            }
        }
        return null;
    }

    private JSONArray getCollecArray() {
        String values = mMMKVDb.getData(collectData);
        if (StringUtil.checkStr(values)) {
            try {
                JSONArray array = new JSONArray(values);
                JSONArray marketArray = NCoinManager.getMarketArray(true);
                if (null == marketArray || marketArray.length() <= 0)
                    return array;

                JSONArray new_like_array = new JSONArray();
                for (int i = 0; i < array.length(); i++) {
                    JSONObject jsonItem = array.optJSONObject(i);
                    if(jsonItem==null) continue;
                    String symbol = jsonItem.optString("symbol");
                    for (int j = 0; j < marketArray.length(); j++) {
                        JSONObject jsonObj = marketArray.optJSONObject(j);
                        String market_symbol = jsonObj.optString("symbol");
                        if (StringUtil.checkStr(symbol) && symbol.equals(market_symbol)) {
                            new_like_array.put(jsonObj);
                            break;
                        }
                    }
                }
                return new_like_array.length() > 0 ? new_like_array : array;
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }
        return null;
    }

    public JSONArray getSymbols() {
        String values = mMMKVDb.getData(collectData);
        if (StringUtil.checkStr(values)) {
            try {
                JSONArray array = new JSONArray(values);
                JSONArray symbols = new JSONArray();
                for (int i = 0; i < array.length(); i++) {
                    String symbol = array.optJSONObject(i).optString("symbol");
                    symbols.put(symbol);
                }
                return symbols;
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }
        return null;
    }

    public void saveCollecData(ArrayList<JSONObject> symbols) {
        for (int i = 0; i < symbols.size(); i++) {
            String symbolObj = symbols.get(i).optString("symbol");
            LikeDataService.getInstance().saveCollecData(symbolObj,null);
        }
    }


}
