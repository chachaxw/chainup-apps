package com.yjkj.chainup.db.service;

import com.yjkj.chainup.db.MMKVDb;
import com.yjkj.chainup.manager.NCoinManager;
import com.yjkj.chainup.util.LogUtil;
import com.yjkj.chainup.util.StringUtil;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.Iterator;

/**
 *@description: Search history data
 * @Author: wanghao
 * @CreateDate: 2019-08-09 12:26
 * @UpdateUser: wanghao
 * @UpdateDate 2023-08-09 12:26
 *@ UpdateRemark: Update Description
 */
public class SearchDataService {

    private static final String searchData = "searchData";
    private static final String TAG = "SearchDataService";


    private MMKVDb mMMKVDb;
    private SearchDataService(){
        mMMKVDb = new MMKVDb();
    }

    private static SearchDataService mLikeDataService;
    public static SearchDataService getInstance(){
        if(null==mLikeDataService){
            mLikeDataService = new SearchDataService();
        }
        return mLikeDataService;
    }

    /*
     *Search Records
     */
    public void saveSearchData(String symbol) {
        if (!StringUtil.checkStr(symbol))
            return;

        ArrayList<String> array = getSearchData();
        if (null == array)
            array = new ArrayList<>();
        boolean isSymbol = hasSearched(symbol);
        LogUtil.e(TAG, "saveSearchData " + isSymbol + array.toArray());
        if (isSymbol) {
            array.remove(symbol);
        }
        array.add(symbol);
        LogUtil.e(TAG, "saveSearchData " + array.toArray());
        mMMKVDb.saveHashData(searchData, array);
    }

    /*
     *Is there a historical search record
     */
    public boolean hasSearched(String symbol) {
        ArrayList<String> array = getSearchData();
        if (null == array || array.size() <= 0)
            return false;
        return array.contains(symbol);
    }

    /*
     *Remove History
     */
    public void removeSearchData(){
        mMMKVDb.removeValueForKey(searchData);
    }

    /*
     *Remove the last history record
     */
    public void removeLastSearchData() {
        ArrayList<String> array = getSearchData();
        if (null != array && array.size() > 5) {

        }
    }


//    public JSONArray getSearchData(){
//        String values = mMMKVDb.getData(searchData);
//        if(StringUtil.checkStr(values)){
//            try {
//                return new JSONArray(values);
//            } catch (JSONException e) {
//                e.printStackTrace();
//            }
//        }
//        return null;
//    }

    public ArrayList<String> getSearchData() {
        ArrayList<String> values = mMMKVDb.getHashData(searchData);
        if (values != null) {
            for (Iterator<String> it = values.iterator(); it.hasNext(); ) {
                String value = it.next();
            }
        }
        return values;
    }

}
