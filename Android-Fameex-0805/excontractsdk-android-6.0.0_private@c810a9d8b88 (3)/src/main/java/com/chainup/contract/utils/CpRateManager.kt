package com.chainup.contract.utils

import android.text.TextUtils
import android.util.Log
import android.widget.TextView
import java.lang.ref.WeakReference
import java.math.BigDecimal

/**
 * @Author: Bertking
 * @Date：2018/12/8-2:56 PM
 *Description: Process exchange rate storage&calculation and so on
 */
var TAG = RateManager::class.java.simpleName

class RateManager {

    private var rateRateBridgeImplReference:WeakReference<IRateBridge>? = null

    fun setRateRateBridgeImpl(impl:IRateBridge){
        rateRateBridgeImplReference = WeakReference(impl)
    }
    fun getRateRateBridgeImpl():IRateBridge?{
        return rateRateBridgeImplReference?.get()
    }
    fun getContractRate(contractId: Int):String?{
        return getRateRateBridgeImpl()?.getRate(contractId)
    }

    public interface IRateBridge{
        fun getRate(contractId:Int):String
        /**
         *Obtain the precision of legal currency
         *@return Currency Precision
         * About 0~2ms
         */
        fun getCurrencyPrecision(): Int
        /**
         *Currency Name
         */
        fun getCurrencySign():String
        /**
         *Monetary unit
         */
        fun getCurrencyLang():String
    }

    companion object {

        val instance : RateManager by lazy(LazyThreadSafetyMode.SYNCHRONIZED) {
            RateManager()
        }

        /**
         *Acquisition accuracy
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
         *Default precision of legal currency
         */
        const val default_precision = 2





        fun getRose(rose: Double): Double {
            return if (rose == 0.0) {
                0.00
            } else {
                return if (rose > 0) rose * 100 - 0.005 else rose * 100 + 0.005
            }
        }

        fun getRoseTrend(rose: String?): Int {
            if (!CpStringUtil.isNumeric(rose)) return 0
            return CpBigDecimalUtils.divForDown(BigDecimal(rose).multiply(BigDecimal("100")).toPlainString(), 2).compareTo(BigDecimal("0"))
        }

        /**
         *Fluctuation range
         *The server will return the "0,78" data format
         */
        fun getRoseText(textView: TextView?, rose: String?) {
            if (!CpStringUtil.isNumeric(rose)){
                textView?.text = "--"
                return
            }
            val roseValue = CpBigDecimalUtils.divForDown(BigDecimal(rose).multiply(BigDecimal("100")).toPlainString(), 2)
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
            if (!CpStringUtil.isNumeric(rose)) return ""
            var lines = rose ?: ""
            val roseValue = CpBigDecimalUtils.divForDown(BigDecimal(rose).multiply(BigDecimal("100")).toPlainString(), 2)
            val compareTo = CpBigDecimalUtils.compareTo(roseValue.toPlainString(), "0")
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
            if (!CpStringUtil.isNumeric(rose)) return ""
            var lines = rose
            val compareTo = CpBigDecimalUtils.compareTo(rose, "0")
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




        fun getNumRose(rose: String): Boolean {
            if (!CpStringUtil.isNumeric(rose)) return false
            var lines = false
            val compareTo = CpBigDecimalUtils.compareTo(rose, "0")
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

        fun getContractCNYByContractId(contractId: Int,close: String):String{
            val rate = this.instance.getContractRate(contractId)
            val precision = this.instance.getRateRateBridgeImpl()?.getCurrencyPrecision()?:2
            val coinLang = this.instance.getRateRateBridgeImpl()?.getCurrencyLang()
            val coinLogo = this.instance.getRateRateBridgeImpl()?.getCurrencySign()

            if (TextUtils.isEmpty(close) || close == "--") {
                return "≈ --$coinLang"
            } else {
                if (CpBigDecimalUtils.compareTo(rate,"0")==0){
                    return ""
                }
                val string = CpBigDecimalUtils.mul(close, rate).toPlainString()
                val intercept = CpBigDecimalUtils.cutValueByPrecision(string, precision)
                Log.d(TAG, "string is $string,intercept is $intercept")
                return "≈ $coinLogo$intercept"
            }
        }

    }


}


