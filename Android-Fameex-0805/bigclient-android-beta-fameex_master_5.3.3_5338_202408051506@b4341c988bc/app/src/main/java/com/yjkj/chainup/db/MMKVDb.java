package com.yjkj.chainup.db;

import com.blankj.utilcode.util.EncodeUtils;
import com.tencent.mmkv.MMKV;
import com.yjkj.chainup.app.AppConstant;
import com.yjkj.chainup.util.JsonUtils;

import java.util.ArrayList;

import kotlin.text.StringsKt;

/**
 * @Description:
 * @Author: wanghao
 * @CreateDate: 2019-08-09 15:56
 * @UpdateUser: wanghao
 * @UpdateDate 2023-08-09 15:56
 *@ UpdateRemark: Update Description
 */
public class MMKVDb {

    private MMKV mMMKV;
    public MMKVDb(){
        byte  [] base = EncodeUtils.base64Decode(AppConstant.Companion.getSECRET_MMKV_KEY());
        mMMKV = MMKV.mmkvWithID("exchange_x",1, StringsKt.decodeToString(base));
    }

    public void saveData(String key,String value){
        mMMKV.encode(key,value);  //Write Cache
        //MMMKV.putString (key, value)// Write to SD card
    }

    public String getData(String key){
        //return mMMKV.getString(key,"");
        return mMMKV.decodeString(key,"");
    }

    public void saveBooleanData(String key,boolean value){
        mMMKV.encode(key,value);
    }

    public void saveIntData(String key,int value){
        mMMKV.encode(key,value);
    }

    public int getIntData(String key,int defValue){
        return mMMKV.getInt(key,defValue);
    }

    public boolean getBooleanData(String key,boolean defValue){
        return mMMKV.getBoolean(key,defValue);
    }

    public void removeValueForKey(String key){
        mMMKV.removeValueForKey(key);
    }

    public void removeValuesForKeys(String[] keys){
        mMMKV.removeValuesForKeys(keys);
    }


    public void clearMemoryCache(){
        mMMKV.clearMemoryCache();
    }

    public void saveLongData(String key,long value){
        mMMKV.encode(key,value);
    }

    public long getLongData(String key,long defValue){
        return mMMKV.getLong(key,defValue);
    }

    public ArrayList<String> getHashData(String key){
        String array = mMMKV.decodeString(key,"");
        if(array.equals("")){
            return  new ArrayList<>();
        }
        return (ArrayList<String>) JsonUtils.INSTANCE.jsonToList(array,String.class);
    }

    public void saveHashData(String key, ArrayList<String> value){
        mMMKV.encode(key, JsonUtils.gson.toJson(value));  //Write Cache
    }

    public void saveEnData(String key,String value){
        mMMKV.encode(key,value);  //Write Cache
        //MMMKV.putString (key, value)// Write to SD card
    }

}
