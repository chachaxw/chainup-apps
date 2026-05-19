package com.yjkj.chainup.manager


import android.content.Context.MODE_PRIVATE
import android.content.SharedPreferences
import android.text.TextUtils
import com.yjkj.chainup.app.ChainUpApp
import com.yjkj.chainup.db.service.PublicInfoDataService
import org.json.JSONObject

class SymbolManager private constructor() {

    lateinit var sp: SharedPreferences

    companion object {
        const val OTC_RATE = "OTC_RATE"


        const val OTC_LANGUAGE = "OTC_LANGUAGE"

        /**
         *Value transfer on the funds interface
         */
        const val FUND_COINS = "fund_coins"
        /**
         *Buying and selling direction
         */
        const val BUY_OR_SELL = "buy_or_sell"

        /**
         *Currency of the transaction interface
         */
        const val TRADE_SYMBOL = "trade_symbol"

        private var mInstance: SymbolManager? = null

        val instance: SymbolManager
            get() {
                if (mInstance == null) {
                    mInstance = SymbolManager()
                }
                return mInstance!!
            }


    }


    init {
        sp = ChainUpApp.appContext.getSharedPreferences("symbols", MODE_PRIVATE)
    }


    /**************NEW ADD***************/

    /**
     *Obtain currency for the 'Transaction' page
     */
    fun getTradeSymbol(): String? {
        return sp.getString(TRADE_SYMBOL, "btcusdt")
    }

    /**
     *Save the currency for the 'Transaction' page
     *@param orientation Buying and selling direction
     */
    fun saveTradeSymbol(symbol: String?, orientation: Int = 0) {
        val edit = sp.edit()
        edit.putString(TRADE_SYMBOL, symbol)
        edit.putInt(BUY_OR_SELL, orientation)
        edit.apply()
    }


    fun saveOTCLanguage(string: String) {
        sp.edit().putString(OTC_LANGUAGE, string).commit()
    }

    fun getOTCLanguage(): String? {
        return sp.getString(OTC_LANGUAGE, "")
    }


    fun saveFundCoins(accountInfo: JSONObject?) {
        if(accountInfo == null) return
        sp.edit().putString(FUND_COINS, accountInfo.toString()).apply()
    }

    /**
     *@param specific currency
     *@return returns the corresponding currency
     */
    fun getFundCoinByName(coinName: String?): JSONObject {
        val info = sp.getString(FUND_COINS, "") ?: ""
        val json = JSONObject(info)
        val allCoinMap = json.optJSONObject("allCoinMap")
        return allCoinMap?.optJSONObject(coinName)?:JSONObject()
    }

    fun getOTCRate(): String {
        val otcLanguage = getLanguageForLocal()
        var rate = sp.getString(OTC_RATE, "") ?: ""
        if(rate.isEmpty() || rate != otcLanguage){
            rate = otcLanguage
            saveOTCRate(rate)
        }
        return rate
    }
    fun saveOTCRate(string: String) {
        sp.edit().putString(OTC_RATE, string).apply()
    }
    fun getLanguageForLocal(): String {
        val saveLanguage = getOTCLanguage().toString()
        val lauList = PublicInfoDataService.getInstance().lanList
        var rateType = ""
        if (TextUtils.isEmpty(saveLanguage)) {
            for (i in 0 until lauList.size) {
                if(LanguageUtil.getSelectLanguage() == lauList[i].optString("id")){
                    rateType = LanguageUtil.getSelectLanguage()
//                    rateType = lauList[i].optString("defaultFiat")
                    break
                }
            }
        } else {
            for (i in 0 until lauList?.size!!) {
                if(saveLanguage == lauList[i].optString("id")){
                    rateType = saveLanguage
//                    rateType = lauList[i].optString("defaultFiat")
                    break
                }
            }
        }
        return rateType;
    }

}

