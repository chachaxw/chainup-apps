package com.yjkj.chainup.util

import com.tencent.mmkv.MMKV
import org.json.JSONObject
import java.util.*

/**
 * @Author: Bertking
 * @Date 2023-07-18-18:59
 * @Description:
 */
object MarketUtil {

    private val TAG = MarketUtil::class.java.simpleName

    private val mmkv = MMKV.mmkvWithID("all_market")

    private val coin_market = "coin_market"

    fun saveAllMarketData(all: String) {
        mmkv.encode(coin_market, all)
    }

    @JvmStatic
    fun getAllMarketData(): String {
        return  mmkv.decodeString(coin_market, "") ?: "";
     }
    @JvmStatic
    fun setMarket2List(first: java.util.ArrayList<JSONObject>?) {
        var mAllMarketStr=  MarketUtil.getAllMarketData();
        if(mAllMarketStr.isNotEmpty()){
            val mAllMarketJson = JSONObject(mAllMarketStr)
            first?.forEach {
                var symbolBuff= it.optString("symbol")
                if( !mAllMarketJson.isNull(symbolBuff)){
                    var symbolJson=mAllMarketJson.optJSONObject(symbolBuff)
                    it.put("rose",symbolJson.optString("rose"))
                    it.put("close",symbolJson.optString("close"))
                    it.put("vol",symbolJson.optString("vol"))
                }
            }
        }
    }

}
