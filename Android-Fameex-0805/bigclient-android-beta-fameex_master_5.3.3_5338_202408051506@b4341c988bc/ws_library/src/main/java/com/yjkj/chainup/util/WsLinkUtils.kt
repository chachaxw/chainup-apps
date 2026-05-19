package com.yjkj.chainup.util

import android.text.TextUtils
import com.google.gson.Gson
import com.google.gson.JsonObject
import com.google.gson.reflect.TypeToken
import com.yjkj.chainup.bean.kline.WsLink
import com.yjkj.chainup.bean.kline.WsLinkBean
import org.json.JSONArray
import org.json.JSONStringer
import java.util.*
import java.util.regex.Pattern

/**
 * @Author: Bertking
 * @Date 2023/12/12-4:07 PM
 *@description: Unified processing of links required for WS
 *
 * WARN ：
 *Reason for method returning WsLinkBean:
 *1 Channel (the reason is that there is a bug in the Java version of WS, and unsubscribing will still return the data from the previous subscription, so a filter is required)
 *2 Request for JSON WS Link
 */
class WsLinkUtils {

    companion object {
        /**
         *Request - K line historical data
         *@param symbol is similar to btcusdt
         * @param time （1min , 5min, 15min,30min,1h,1week,1month）
         */
        @JvmStatic
        fun getKLineHistoryLink(symbol: String?, time: String?): WsLinkBean {

            var klineHistoryChannel = "market_${symbol}_kline_$time"
            var wsLink = WsLink()
            wsLink.event = "req"
            wsLink.params?.channel = klineHistoryChannel
            val bean = WsLinkBean(klineHistoryChannel, toJson(wsLink))
            bean.symbol = symbol!!
            bean.time = time!!
            return bean

        }

        @JvmStatic
        fun getKlineHistoryOther(symbol: String?, time: String?, endId: String): String {
            return "{\"event\":\"req\",\"params\":{\"channel\":\"market_${symbol}_kline_${time}\",\"cb_id\":\"$symbol\",\"endIdx\":$endId,\"pageSize\":300}}"
        }

        fun getKLineHistoryKey(symbol: String): String {
            return "market_${symbol}_kline_1min"
        }

        /**
         *Subscription - Latest K-line Market
         *@param symbol is similar to btcusdt
         *@param isSub subscription OR cancellation
         * @param time （1min , 5min, 15min,30min,1h,1week,1month）
         */
        @JvmStatic
        fun getKlineNewLink(symbol: String, time: String?, isSub: Boolean = true): WsLinkBean {
            val event = if (isSub)
                "sub"
            else
                "unsub"
            var newKLineChannel = "market_${symbol}_kline_$time"

            var wsLink = WsLink()
            wsLink.event = event
            wsLink.params?.channel = newKLineChannel

            return WsLinkBean(newKLineChannel, toJson(wsLink))


        }

        /**
         *Recommend using tickerFor24HLink()
         *Subscription -24H Market
         *@param symbol is similar to btcusdt
         *@param isSub subscription OR cancellation
         */
//        @Deprecated("多余的序列化&反序列化过程")
//        fun getTickerFor24HLink(symbol: String, isSub: Boolean = true): WsLinkBean {
//            val event = if (isSub)
//                "sub"
//            else
//                "unsub"
//            var dayTickerChannel = "market_${symbol}_ticker"
//
//            var wsLink = WsLink()
//            wsLink.event = event
//            wsLink.params?.channel = dayTickerChannel
//            return WsLinkBean(dayTickerChannel, toJson(wsLink))
//        }

        /**
         *Subscription -24H Market
         *@param symbol is similar to btcusdt
         *@param isSub subscription OR cancellation
         */
        @JvmStatic
        fun tickerFor24HLink(symbol: String, isSub: Boolean = true, isChannel: Boolean = false): String {
            //The toLowerCase() here is for compatibility with the contract
            val channel = "market_${symbol.toLowerCase()}_ticker"
            return if (isChannel) {
                channel
            } else {
                val event = if (isSub)
                    "sub"
                else
                    "unsub"
                "{\"event\":\"$event\",\"params\":{\"channel\":\"$channel\",\"cb_id\":\"自定义\"}}"
            }
        }

        /**
         *Subscription -24H Market
         *@param symbol is similar to btcusdt
         *@param isSub subscription OR cancellation
         */
        @JvmStatic
        fun tickerFor24HLinkBean(symbol: String, isSub: Boolean = true): WsLinkBean {
            //The toLowerCase() here is for compatibility with the contract
            val channel = "market_${symbol.toLowerCase()}_ticker"
            val event = if (isSub)
                "sub"
            else
                "unsub"
            val bean = WsLinkBean(channel, "{\"event\":\"$event\",\"params\":{\"channel\":\"$channel\",\"cb_id\":\"自定义\"}}")
            bean.symbol = symbol
            return bean

        }


        @JvmStatic
        fun tickerReqReview(cid: String): String {
            if (TextUtils.isEmpty(cid)) {
                return "{\"event\":\"req\",\"params\":{\"channel\":\"review\"}}"
            } else {
                return "{\"event\":\"req\",\"params\":{\"channel\":\"review2\",\"cid\":\"$cid\"}}"
            }

        }


        /**
         *Request - Transaction History
         *@param symbol is similar to btcusdt
         */
        fun getDealHistoryLink(symbol: String): WsLinkBean {
            var dealHistoryChannel = "market_${symbol}_trade_ticker"

            var wsLink = WsLink()
            wsLink.event = "req"
            wsLink.params?.channel = dealHistoryChannel
            return WsLinkBean(dealHistoryChannel, toJson(wsLink))
        }

        /**
         *Subscription - Latest Transaction Information
         *@param symbol is similar to btcusdt
         *@param isSub subscription OR cancellation
         */
        fun getDealNewLink(symbol: String, isSub: Boolean = true): WsLinkBean {
            val event = if (isSub)
                "sub"
            else
                "unsub"

            var newDealChannel = "market_${symbol}_trade_ticker"

            var wsLink = WsLink()
            wsLink.event = event
            wsLink.params?.channel = newDealChannel

            return WsLinkBean(newDealChannel, toJson(wsLink))

        }


        /**
         *Subscription - Deep Disk Opening
         *@param symbol is similar to btcusdt
         *@param isSub subscription OR cancellation
         *@param step depth (default 0)
         */
        fun getDepthLink(symbol: String, isSub: Boolean = true, step: String = "0"): WsLinkBean {
            val name = symbol
            val event = if (isSub)
                "sub"
            else
                "unsub"
            var depthChannel = "market_${name}_depth_step${step}"
            var json = "{\"event\":\"$event\",\"params\":{\"channel\":\"$depthChannel\",\"cb_id\":\"自定义\",\"asks\":150,\"bids\":150}}"
            val bean = WsLinkBean(depthChannel, json)
            bean.symbol = symbol
            bean.step = step
            return bean

        }

        @JvmStatic
        fun pongBean(): WsLinkBean {
            var json = "{\"pong\":${Date().time / 1000}}"
            val bean = WsLinkBean("", json)
            return bean
        }

        fun toJson(bean: Any): String {
            return Gson().toJson(bean)
        }

        /**
         *Subscription -24H Market
         *@param symbol is similar to btcusdt
         *@param isSub subscription OR cancellation
         */
        @JvmStatic
        fun tickerFor24HLinkBatchBean(symbols: String, isSub: Boolean = true): WsLinkBean {
            //The toLowerCase() here is for compatibility with the contract

            val arrays = symbols.split(",")
            val channel = StringBuffer()
            for (item in arrays) {
                channel.append("market_${item.toLowerCase()}_ticker" + ",")
            }
            val params = channel.substring(0, channel.length - 1)
            val event = if (isSub)
                "sub_batch"
            else
                "unsub_batch"
            val bean = WsLinkBean(params, "{\"event\":\"$event\",\"params\":{\"channel\":\"$params\",\"cb_id\":\"1\"}}")
            bean.event = event
            bean.symbol = symbols
            bean.symbols = params
            return bean

        }

        @JvmStatic
        fun is24HLinkTicker(channel:String) :Boolean{
            if("".equals(channel)) return false
            val pattern = Pattern.compile("market_.+_ticker")
            val is24HLinkTicker = pattern.matcher(channel).matches()
            return is24HLinkTicker && !channel.contains("trade")
        }

        /**
         *Subscription - All Currency Pairs for 24H Market
         */
        @JvmStatic
        fun tickerFor24HLinkReqBean(cid: Int = 1): WsLinkBean {
            //The toLowerCase() here is for compatibility with the contract
            val params = "review"
            val paramsV2 = "reviewV2"
            val event = "req"
            var paramsJson = when (cid) {
                1 -> "{\"event\":\"$event\",\"params\":{\"channel\":\"$params\"}}"
                else -> "{\"event\":\"$event\",\"params\":{\"channel\":\"$params\",\"cid\":\"${cid}\"}}"
            }
            val bean = WsLinkBean(params, paramsJson)
            return bean

        }

    }
}

object JsonWSUtils {
    lateinit var gson: Gson

    init {
        gson = Gson()
    }
    @JvmStatic
    fun toJsonArray(string:String):Array<String>{
        val type = gson.fromJson<Array<String>>(string, object : TypeToken<Array<String>>() {}.type) as Array
        return type
    }

}

fun Array<String>.splicAppend(string: String):String{
    val strings = StringBuffer()
    for (i in 0 until this.count()) {
        if (i == this.count() - 1){
            strings.append(this[i])
        }else{
            strings.append(this[i] + string)
        }
    }
    return strings.toString()
}
