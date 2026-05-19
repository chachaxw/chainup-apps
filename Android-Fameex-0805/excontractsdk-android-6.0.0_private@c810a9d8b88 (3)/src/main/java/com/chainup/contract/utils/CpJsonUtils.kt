package com.chainup.contract.utils


import android.text.TextUtils
import com.chainup.contract.bean.CpQuotesBeanTypeAdapter
import com.chainup.contract.bean.CpQuotesData
import com.chainup.contract.bean.KlineQuotesData
import com.google.gson.Gson
import com.google.gson.GsonBuilder
import com.google.gson.JsonObject
import com.google.gson.JsonParser
import com.google.gson.reflect.TypeToken
import org.json.JSONArray
import org.json.JSONException
import org.json.JSONObject
import java.util.*
import kotlin.collections.ArrayList

object CpJsonUtils {
    lateinit var gson: Gson

    fun <T> jsonToList(data: String, tClass: Class<T>): List<T> {
        val mList = ArrayList<T>()
        if (TextUtils.isEmpty(data)) return mList
        try {
            val mArray = JSONArray(data)
            (0 until mArray.length()).mapTo(mList) { jsonToBean(mArray.get(it).toString(), tClass) }
        } catch (e: JSONException) {
            e.printStackTrace()
        }

        return mList
    }

    fun <T> jsonToBean(data: String, tClass: Class<T>): T = Gson().fromJson(data, tClass)


    init {
        val gsonBuilder = GsonBuilder()
        gsonBuilder.registerTypeAdapter(CpQuotesData::class.java, CpQuotesBeanTypeAdapter())
        gsonBuilder.setPrettyPrinting()
        gson = gsonBuilder.create()
    }


    fun convert2Quote(json: String): KlineQuotesData {
//        return gson.fromJson(json, CpQuotesData::class.java)
        return gson.fromJson(json, KlineQuotesData::class.java)
    }

    fun getLanguage(): String {
        val language = if (CpSystemUtils.isZh()) {
            "zh_CN"
        } else if (CpSystemUtils.isMn()) {
            "mn_MN"
        } else if (CpSystemUtils.isRussia()) {
            "ru_RU"
        } else if (CpSystemUtils.isKorea()) {
            "ko_KR"
        } else if (CpSystemUtils.isJapanese()) {
            "ja_JP"
        } else if (CpSystemUtils.isTW()) {
            "el_GR"
        } else  if (CpSystemUtils.isTC()) {
            "zh_TC"
        } else if (CpSystemUtils.isVietNam()) {
            "vi_VN"
        } else if (CpSystemUtils.isSpanish()) {
            "es_ES"
        } else {
            "en_US"
        }
        return language
    }


    fun <T> listToJson(data:ArrayList<T>):String{
        if(data.size>0){
            //If it is a JSONObject type
            if(data[0] is JSONObject){
                val jsonArrays = ArrayList<JsonObject>()
                for(itemObj in data){
                    //The key for processing namePair is first converted to JsonObject
                    val jsonParser = JsonParser()
                    val jsonObject = jsonParser.parse(itemObj.toString()) as JsonObject

                    jsonArrays.add(jsonObject)
                }

                return gson.toJson(jsonArrays)

            } else {
                return gson.toJson(data)
            }
        }else{
            return ""
        }
    }

    fun cloneDataByArrayListJSONObject(jsonStr:String):ArrayList<JSONObject>{
        val type = object : TypeToken<ArrayList<JsonObject?>?>() {}.type
        val jsonObjects = Gson().fromJson<ArrayList<JsonObject>>(jsonStr, type)
        val arrayList = ArrayList<JSONObject>()
        for (jsonObject in jsonObjects) {
            arrayList.add(Gson().fromJson(jsonObject, JSONObject::class.java))
        }
        return arrayList
    }

}
