package com.yjkj.chainup.manager

import android.text.TextUtils
import android.util.Log
import android.widget.TextView
import com.chainup.contract.utils.CpClLogicContractSetting
import com.yjkj.chainup.app.ChainUpApp
import com.yjkj.chainup.bean.coin.CoinMapBean
import com.yjkj.chainup.db.service.PublicInfoDataService
import com.yjkj.chainup.db.service.RateDataService
import com.yjkj.chainup.util.*
import org.json.JSONObject
import java.math.BigDecimal

/**
 * @Author: Bertking
 * @Date 2023/12/8-2:56 PM
 *@description: Processing exchange rate storage&calculation and so on
 */
var TAG = RateManager::class.java.simpleName

class RateManager {

    companion object {
        /**
         *Obtain accuracy
         */
        const val coin_precision = "coin_precision"

        const val coin_fiat_precision = "coin_fiat_precision"

        /**
         *Currency symbol
         */
        const val lang_logo = "lang_logo"

        /**
         *Real currency
         */
        const val lang_coin = "lang_coin"

        /*
         *Default precision of fiat currency
         */
        const val default_precision = 2

        /**
         *Obtain accuracy based on fiat currency
         *@param isOTC is an off exchange fiat currency, true is the off exchange fiat currency, and false is the precision of the spot fiat currency
         */
        fun getFiat4Coin(coin: String?, isOTC: Boolean = true): Int {

            var rate = getRateBylang_coin(coin)
            if (null != rate) {
                var aa = ""
                if (isOTC) {
                    aa = rate?.optString("coin_fiat_precision") ?: ""
                    if (!StringUtil.checkStr(aa)) {
                        aa = rate?.optString("coin_precision") ?: ""
                    }
                } else {
                    aa = rate?.optString("coin_precision") ?: ""
                }
                if (StringUtil.isNumeric(aa)) {
                    return aa!!.toInt()
                }

            }
            /*var lang_logo = rate?.optString(lang_logo)
            var lang_coin = rate?.optString(lang_coin)
            LogUtil.d(TAG,"getFiat4Coin==coin is $coin,lang_logo is $lang_logo,lang_coin is $lang_coin,coin == lang_logo  is ${coin.equals(lang_logo,ignoreCase = true) },coin == lang_coin is ${coin.equals(lang_coin,ignoreCase = true)}")
            if (coin == lang_logo || coin == lang_coin) {
                LogUtil.d(TAG,"getFiat4Coin==coin is $coin,isOTC is $isOTC")
                var aa = ""
                if(isOTC){
                    aa = rate?.optString("coin_fiat_precision")?:""
                    if(!StringUtil.checkStr(aa)){
                        aa = rate?.optString("coin_precision")?:""
                    }
                }else{
                    aa = rate?.optString("coin_precision")?:""
                }
                LogUtil.d(TAG,"getFiat4Coin==coin is $coin,isOTC is $isOTC,aa is $aa")
                if (StringUtil.isNumeric(aa)) {
                    return aa!!.toInt()
                }
            }*/
            return default_precision
        }

        private fun getRateBylang_coin(lang_coin: String?): JSONObject? {
            var coin = lang_coin
            if (!StringUtil.checkStr(coin)) {
                coin = "CNY"
            }

            var rate = PublicInfoDataService.getInstance().getRate(null)
            if (null != rate) {
                var keys = rate.keys()
                while (keys.hasNext()) {
                    var key = keys.next()
                    var value = rate.optJSONObject(key)
                    if (null != value) {
                        var lang_coin = value.optString("lang_coin")
                        var lang_logo = value.optString("lang_logo")
                        if (coin == lang_coin || coin == lang_logo) {
                            return value
                        }
                    }
                }
            }
            return null
        }

        /**
         * @param "ko_KR" , "en_US" , "zh_CN"
         *@return Returns the currency exchange rate of the corresponding language
         *@ isFiatTrade true takes common/public_ Info_ Rate value of v4
         */

        private fun getRatesByLanguage(isFiatTrade: Boolean = false): JSONObject? {
            val language = LanguageUtil.getSelectLanguage()
            var jsonObject: JSONObject? = null
            LogUtil.e("RateManager", "getRatesByLanguage is $isFiatTrade ")
            if (isFiatTrade) {
                jsonObject = PublicInfoDataService.getInstance().getRate(null)
                jsonObject = jsonObject?.optJSONObject(language)
            } else {
                //What we get here is an en_ Us zh_ CN, this kind of damn thing
                val lankey = SymbolManager.instance.getOTCRate()
                LogUtil.e("RateManager", "getRatesByLanguage is $lankey ")
                LogUtil.e(
                    "RateManager",
                    "getRatesByLanguage rate ${RateDataService.getInstance().value} "
                )
                jsonObject = RateDataService.getInstance().getRate(lankey)
            }

            //LogUtil.d("RatesService","language is $language , jsonObject is $jsonObject")

            if (null == jsonObject || jsonObject.length() <= 0) {
                LogUtil.e("RateManager", "jsonObject is null ")
                jsonObject = RateDataService.getInstance().getRate("en_US")
            }
            return jsonObject
        }

        /**
         *Query exchange rates based on language
         */
        private fun getContractUsdtRatesByLanguage(coinLang:String): String {
//            val language = LanguageUtil.getSelectLanguage()
            var jsonObject: JSONObject? = null
            jsonObject = CpClLogicContractSetting.getContractJsonRateStr(ChainUpApp.appContext)
            var symbolRateArr = jsonObject?.optJSONArray("symbolRateList")
            symbolRateArr?.apply {
                for (i in 0 until this.length()) {
                    val mJSONObject = this.get(i) as JSONObject
                    val quoteSymbol = mJSONObject.getString("quoteSymbol")
                    val rate = mJSONObject.getString("rate")
                    val OTCRate = SymbolManager.instance.getOTCRate().toUpperCase()
                    if (quoteSymbol.equals(coinLang)) {
                        return rate
                    }
                }
            }
            return "0.0"
        }

        /**
         *Query exchange rates based on language
         */
        private fun getContractUsdRatesByLanguage(coinLang:String): String {
            val language = LanguageUtil.getSelectLanguage()
            var jsonObject: JSONObject? = null
            jsonObject = CpClLogicContractSetting.getContractJsonRateStr(ChainUpApp.appContext)
            var usdtToUsdRate = jsonObject?.optString("usdtToUsdRate")

            var symbolRateArr = jsonObject?.optJSONArray("symbolRateList")
            symbolRateArr?.apply {
                for(i in 0 until this.length()) {
                    val mJSONObject = this.get(i)
                    if(mJSONObject is JSONObject){
                        val quoteSymbol = mJSONObject.getString("quoteSymbol")
                        val rate = mJSONObject.getString("rate")
                        val OTCRate = SymbolManager.instance.getOTCRate().toUpperCase()
                        if (quoteSymbol.equals(coinLang)) {
                            return BigDecimalUtils.mul(usdtToUsdRate, rate).toPlainString()
                        }
                    }
                }
            }
            return "0.0"
        }


        /**
         *Return according to Currency symbol
         */
        fun getRatesByPayCoin(fiat: String?): Int {
            var jsonObject = RateDataService.getInstance().value
            var rate: JSONObject = jsonObject ?: return default_precision

            var it: Iterator<String> = rate.keys()
            var precision = default_precision
            while (it.hasNext()) {
                var key = it.next()
                var value = rate.optJSONObject(key)
                var lang_coin = value?.optString("lang_coin")
                if (lang_coin == fiat) {
                    var coin_precision = value?.optString("coin_precision")
                    if (StringUtil.isNumeric(coin_precision))
                        return coin_precision?.toInt() ?: default_precision
                }
            }
            return default_precision
        }


        /**
         *Obtain calculation results based on CoinMap
         */
        fun getCNYByCoinMap(coinMapBean: CoinMapBean?, param: String?): String {
            var split = coinMapBean?.name?.split("/")
            if (null == split || split.size <= 1) {
                return ""
            }
            return getCNYByCoinName(split[1], param)
        }


        /**
         *Obtain calculation results based on CoinMap
         */
        fun getCNYByCoinMap(coinMapBean: JSONObject?, param: String?): String {
            var name = coinMapBean?.optString("name")
            if (StringUtil.checkStr(name) && name!!.contains("/")) {
                var split = name.split("/")
                return getCNYByCoinName(split[1], param)
            }
            return ""
        }


        fun getRose(rose: Double): Double {
            return if (rose == 0.0) {
                0.00
            } else {
                return if (rose > 0) rose * 100 - 0.005 else rose * 100 + 0.005
            }
        }

        fun getRoseTrend(rose: String?): Int {
            if (!StringUtil.isNumeric(rose)) return 0
            return BigDecimalUtils.divForDown(
                BigDecimal(rose).multiply(BigDecimal("100")).toPlainString(), 2
            ).compareTo(BigDecimal("0"))
        }

        /**
         *Fluctuation range
         *The server will return the "0,78" data format
         */
        fun getRoseText(textView: TextView?, rose: String?) {
            if (!StringUtil.isNumeric(rose)) {
                textView?.text = "--"
                return
            }
            val roseValue = BigDecimalUtils.divForDown(
                BigDecimal(rose).multiply(BigDecimal("100")).toPlainString(), 2
            )
            val compareTo = roseValue.compareTo(BigDecimal("0"))
            when (compareTo) {
                -1 -> {
                    textView?.text = "${roseValue.toPlainString()}%"
                }

                0 -> {
                    textView?.text = roseValue.toPlainString() + "%"
                }

                1 -> {
                    textView?.text = "+${roseValue.toPlainString()}%"
                }
            }
        }

        fun getRoseText4Kline(rose: String?): String {
            if (!StringUtil.isNumeric(rose)) return ""
            var lines = rose ?: ""
            val roseValue = BigDecimalUtils.divForDown(
                BigDecimal(rose).multiply(BigDecimal("100")).toPlainString(), 2
            )
            val compareTo = BigDecimalUtils.compareTo(roseValue.toPlainString(), "0")
            when (compareTo) {
                -1 -> {
                    lines = "${roseValue.toPlainString()}%"
                }

                0 -> {
                    lines = roseValue.toPlainString() + "%"
                }

                1 -> {
                    lines = "+${roseValue.toPlainString()}%"
                }
            }
            return lines
        }

        fun getAbsoluteText4Kline(rose: String): String {
            if (!StringUtil.isNumeric(rose)) return ""
            var lines = rose
            val compareTo = BigDecimalUtils.compareTo(rose, "0")
            when (compareTo) {
                -1, 0 -> {
                    lines = rose
                }

                1 -> {
                    lines = "+${rose}"
                }
            }
            return lines
        }


        /**
         *Fluctuation range
         */
        fun getRoseText(rose: Double): String {
            return String.format("%.2f", getRose(rose)) + "%"
        }


        /**
         *@param Currency
         *@return The exchange rate corresponding to the currency
         * About 0~3ms
         */
        fun getRatesByCoinName(coinName: String?): String {
            val jsonObject = getRatesByLanguage()

            val value = jsonObject?.optString(coinName)

            if (StringUtil.checkStr(value)) {
                return value!!
            }
            return "0.0"
        }

        fun getContractRatesByClassification(quote: String,coinLang:String): String {
            if (quote.equals("USD")) {
                return getContractUsdRatesByLanguage(coinLang)
            } else {
                return getContractUsdtRatesByLanguage(coinLang)
            }
        }


        /**
         *Obtain the precision of fiat currency
         *@return Currency Precision
         * About 0~2ms
         */
        fun getCurrencyPrecision(): Int {
            var jsonObject = getRatesByLanguage()
            if (null != jsonObject) {
                var value = jsonObject.optString(coin_precision)
                if (StringUtil.checkStr(value)) {
                    return value.toInt()
                }
            }
            return default_precision
        }

        /**
         * @Defult $
         *Obtaining symbols for currency
         *@return Currency symbol
         */
        fun getCurrencySign(): String {

            var jsonObject = getRatesByLanguage()
            if (null != jsonObject) {
                var value = jsonObject.optString(lang_logo)
                if (StringUtil.checkStr(value)) {
                    return value
                }
            }
            return "$"
        }


        /**
         *Obtain currency name (not recommended)
         *@return Currency Name
         */
        fun getCurrencyLang(): String {
            var jsonObject = getRatesByLanguage()
            if (null != jsonObject) {
                var value = jsonObject.optString(lang_coin)
                if (StringUtil.checkStr(value)) {
                    return value
                }
            }
            return "USD"
        }


        /**
         *Calculate automatically based on coinName and exchange rate (recommended)
         *Param Param closing price
         *@param isLogo false returns the result as (≈ specific number CNY)
         *@return returns the calculated result (in the form of "≈ ¥ specific number")
         * About  5ms
         */
        fun getCNYByCoinName(
            coinName: String?,
            close: String?,
            isLogo: Boolean = true,
            isOnlyResult: Boolean = false,
            precision: Int = -1
        ): String {
            /**
             *Currency name
             */
            var coinLogo = getCurrencySign()

            /**
             *Monetary unit
             */
            var coinLang = getCurrencyLang()


            /**
             *Currency precision
             */
            var precision = if (precision == -1) getCurrencyPrecision() else precision

            /**
             *Exchange rate
             */
            val rate = getRatesByCoinName(coinName)

            Log.d(
                TAG,
                "precison is $precision,coinLogo is $coinLogo,rate is $rate,coinLang is $coinLang"
            )


            if (TextUtils.isEmpty(close) || close == "--") {
                return if (isOnlyResult) {
                    "--"
                } else {
                    if (isLogo) {
                        "≈ $coinLogo--"
                    } else {
                        "≈ --$coinLang"
                    }
                }
            } else {
                val string = BigDecimalUtils.mul(close, rate).toPlainString()
                val intercept = DecimalUtil.cutValueByPrecision(string, precision)


//                BigDecimalUtils.showSNormal(BigDecimalUtils.intercept(string, precision.toInt()).toString())
                return if (isOnlyResult) {
                    intercept
                } else {
                    if (isLogo) {
                        "≈ $coinLogo$intercept"
                    } else {
                        "≈ $intercept$coinLang"
                    }
                }
            }
        }

        fun getContractCNYByContractType(quote: String, close: String, name: String?): String {
            /**
             *Currency name
             */
            var coinLogo = getCurrencySign()

            /**
             *Monetary unit
             */
            var coinLang = getCurrencyLang()


            /**
             *Currency precision
             */
            var precision = getCurrencyPrecision()

            /**
             *Exchange rate
             */
            val rate = getContractRatesByClassification(quote,coinLang)

            Log.d(
                TAG,
                "precison is $precision,name is $name,rate is $rate,coinLang is $coinLang"
            )


            if (TextUtils.isEmpty(close) || close == "--") {
                return   "≈ --$coinLang"
            } else {
                if (BigDecimalUtils.compareTo(rate,"0")==0){
                    return ""
                }
                val string = BigDecimalUtils.mul(close, rate).toPlainString()
                val intercept = DecimalUtil.cutValueByPrecision(string, precision)


//                BigDecimalUtils.showSNormal(BigDecimalUtils.intercept(string, precision.toInt()).toString())
//                return   "≈ $intercept$coinLang"
                return       "≈ $coinLogo$intercept"
            }
        }

        fun getNumRose(rose: String): Boolean {
            if (!StringUtil.isNumeric(rose)) return false
            var lines = false
            val compareTo = BigDecimalUtils.compareTo(rose, "0")
            when (compareTo) {
                -1 -> {
                    lines = false
                }

                1 -> {
                    lines = true
                }
            }
            return lines
        }

        /**
         *Calculate automatically based on coinName and exchange rate (recommended)
         *Param Param closing price
         *@param isLogo false returns the result as (≈ specific number CNY)
         *@return returns the calculated result (in the form of "≈ ¥ specific number")
         * About  5ms
         */
        fun getHomeCNYByCoinName(
            coinName: String?,
            close: String?,
            isLogo: Boolean = true,
            isOnlyResult: Boolean = false,
            precision: Int = -1
        ): String {
            /**
             *Currency name
             */
            var coinLogo = getCurrencySign()

            /**
             *Monetary unit
             */
            var coinLang = getCurrencyLang()


            /**
             *Currency precision
             */
            var precision = if (precision == -1) getCurrencyPrecision() else precision

            /**
             *Exchange rate
             */
            val rate = getRatesByCoinName(coinName)

            Log.d(
                TAG,
                "precison is $precision,coinLogo is $coinLogo,rate is $rate,coinLang is $coinLang"
            )


            if (TextUtils.isEmpty(close) || close == "--") {
                return if (isOnlyResult) {
                    "--"
                } else {
                    if (isLogo) {
                        "$coinLogo--"
                    } else {
                        "--$coinLang"
                    }
                }
            } else {
                val string = BigDecimalUtils.mul(close, rate).toPlainString()
                val intercept = DecimalUtil.cutValueByPrecision(string, precision)


//                BigDecimalUtils.showSNormal(BigDecimalUtils.intercept(string, precision.toInt()).toString())
                return if (isOnlyResult) {
                    intercept
                } else {
                    if (isLogo) {
                        "$coinLogo$intercept"
                    } else {
                        "$intercept$coinLang"
                    }
                }
            }
        }


        /**
         *Calculate automatically based on coinName and exchange rate (recommended)
         *Param Param closing price
         *@param isLogo false returns the result as (≈ specific number CNY)
         *@return returns the calculated result (in the form of "≈ ¥ specific number")
         * About  5ms
         */
        fun getProfitCNYByCoinName(
            coinName: String?,
            close: String?,
            isLogo: Boolean = true,
            isOnlyResult: Boolean = false,
            precision: Int = -1,
            isAsset: Boolean = true
        ): String {
            /**
             *Currency name
             */
            var coinLogo = getCurrencySign()

            /**
             *Monetary unit
             */
            var coinLang = getCurrencyLang()


            /**
             *Currency precision
             */
            var precision = if (precision == -1) getCurrencyPrecision() else precision

            /**
             *Exchange rate
             */
            val rate = getRatesByCoinName(coinName)

            Log.d(
                TAG,
                "precison is $precision,coinLogo is $coinLogo,rate is $rate,coinLang is $coinLang"
            )


            if (TextUtils.isEmpty(close) || close == "--") {
                return if (isOnlyResult || !isAsset) {
                    "--"
                } else {
                    if (isLogo) {
                        "$coinLogo--"
                    } else {
                        "--$coinLang"
                    }
                }
            } else {
                val string = BigDecimalUtils.mul(close, rate).toPlainString()
                val intercept = DecimalUtil.cutValueByPrecision(string, precision)


//                BigDecimalUtils.showSNormal(BigDecimalUtils.intercept(string, precision.toInt()).toString())
                return if (isOnlyResult) {
                    intercept
                } else {
                    if (isLogo) {
                        if (BigDecimalUtils.compareTo(intercept, "0") == -1) {
                            val asb = Math.abs(intercept.toDouble())
                            "- $coinLogo$asb"
                        } else {
                            "$coinLogo$intercept"
                        }
                    } else {
                        "$intercept$coinLang"
                    }
                }
            }
        }

        fun getOtherCNYByCoinName(
            coinName: String?,
            close: String?,
            isLogo: Boolean = true,
            isOnlyResult: Boolean = false,
            precision: Int = -1,
            isAsset: Boolean = true
        ): String {
            /**
             *Currency name
             */
            var coinLogo = getCurrencySign()

            /**
             *Monetary unit
             */
            var coinLang = getCurrencyLang()


            /**
             *Currency precision
             */
            var precision = if (precision == -1) getCurrencyPrecision() else precision

            /**
             *Exchange rate
             */
            val rate = getRatesByCoinName(coinName)

            Log.d(
                TAG,
                "precison is $precision,coinLogo is $coinLogo,rate is $rate,coinLang is $coinLang"
            )


            val string = BigDecimalUtils.mul(close, rate).toPlainString()
            val intercept = DecimalUtil.cutValueByPrecision(string, precision)


//                BigDecimalUtils.showSNormal(BigDecimalUtils.intercept(string, precision.toInt()).toString())
            return if (isLogo) {
                if (BigDecimalUtils.compareTo(intercept, "0") == -1) {
                    val asb = Math.abs(intercept.toDouble())
                    "- $coinLogo$asb"
                } else {
                    "$coinLogo$intercept"
                }
            } else {
                "$intercept$coinLang"
            }
        }


    }


}


