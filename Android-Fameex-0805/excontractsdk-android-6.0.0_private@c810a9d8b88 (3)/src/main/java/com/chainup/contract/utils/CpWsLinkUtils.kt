package com.chainup.contract.utils

import android.text.TextUtils
import com.google.gson.Gson
import com.yjkj.chainup.bean.kline.CpWsLink
import com.yjkj.chainup.bean.kline.CpWsLinkBean
import java.util.*
import java.util.regex.Pattern

/**
 * @Author: Bertking
 * @Date：2018/12/12-4:07 PM
 *@ Description: Unified processing of links required by WS
 *
 * WARN ：
 *Reason for method returning WsLinkBean:
 * 1.  Channel (The reason is that the Java version of WS has a bug, and unsubscribing will still return the data from the previous subscription, so a filter is required)
 * 2.  Requests for json WS links
 */
class CpWsLinkUtils {

    companion object {
        /**
         *Request --- Historical data of K line
         *The @param symbol is similar to btcusdt
         * @param time （1min , 5min, 15min,30min,1h,1week,1month）
         */
        @JvmStatic
        fun getKLineHistoryLink(symbol: String?, time: String?): CpWsLinkBean {

            var klineHistoryChannel = "market_${symbol}_kline_$time"
            var wsLink = CpWsLink()
            wsLink.event = "req"
            wsLink.params?.channel = klineHistoryChannel
            val bean = CpWsLinkBean(klineHistoryChannel, toJson(wsLink))
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
         *Subscription - K Line Latest Market
         *The @param symbol is similar to btcusdt
         *@param isSub Subscription OR Cancel
         * @param time （1min , 5min, 15min,30min,1h,1week,1month）
         */
        @JvmStatic
        fun getKlineNewLink(symbol: String, time: String?, isSub: Boolean = true): CpWsLinkBean {
            val event = if (isSub)
                "sub"
            else
                "unsub"
            var newKLineChannel = "market_${symbol}_kline_$time"

            var wsLink = CpWsLink()
            wsLink.event = event
            wsLink.params?.channel = newKLineChannel

            return CpWsLinkBean(newKLineChannel, toJson(wsLink))


        }

        /**
         *It is recommended to use tickerFor24HLink()
         *Subscription - 24H market
         *The @param symbol is similar to btcusdt
         *@param isSub Subscription OR Cancel
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
         *Subscription - 24H market
         *The @param symbol is similar to btcusdt
         *@param isSub Subscription OR Cancel
         */
        @JvmStatic
        fun tickerFor24HLink(symbol: String, isSub: Boolean = true, isChannel: Boolean = false): String {
            //The toLowerCase() here is for contract compatibility
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
         *Subscription - 24H market
         *The @param symbol is similar to btcusdt
         *@param isSub Subscription OR Cancel
         */
        @JvmStatic
        fun tickerFor24HLinkBean(symbol: String, isSub: Boolean = true): CpWsLinkBean {
            //The toLowerCase() here is for contract compatibility
            val channel = "market_${symbol.toLowerCase()}_ticker"
            val event = if (isSub)
                "sub"
            else
                "unsub"
            val bean = CpWsLinkBean(channel, "{\"event\":\"$event\",\"params\":{\"channel\":\"$channel\",\"cb_id\":\"自定义\"}}")
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
         *The @param symbol is similar to btcusdt
         */
        fun getDealHistoryLink(symbol: String): CpWsLinkBean {
            var dealHistoryChannel = "market_${symbol}_trade_ticker"

            var wsLink = CpWsLink()
            wsLink.event = "req"
            wsLink.params?.channel = dealHistoryChannel
            return CpWsLinkBean(dealHistoryChannel, toJson(wsLink))
        }

        /**
         *Subscription - Latest Transaction Information
         *The @param symbol is similar to btcusdt
         *@param isSub Subscription OR Cancel
         */
        fun getDealNewLink(symbol: String, isSub: Boolean = true): CpWsLinkBean {
            val event = if (isSub)
                "sub"
            else
                "unsub"

            var newDealChannel = "market_${symbol}_trade_ticker"

            var wsLink = CpWsLink()
            wsLink.event = event
            wsLink.params?.channel = newDealChannel

            return CpWsLinkBean(newDealChannel, toJson(wsLink))

        }


        /**
         *Subscription - Deep Disk Opening
         *The @param symbol is similar to btcusdt
         *@param isSub Subscription OR Cancel
         *@param step depth (default 0)
         */
        fun getDepthLink(symbol: String, isSub: Boolean = true, step: String = "0"): CpWsLinkBean {
            val name = symbol
            val event = if (isSub)
                "sub"
            else
                "unsub"
            var depthChannel = "market_${name}_depth_step${step}"
            var json = "{\"event\":\"$event\",\"params\":{\"channel\":\"$depthChannel\",\"cb_id\":\"自定义\",\"asks\":150,\"bids\":150}}"
            val bean = CpWsLinkBean(depthChannel, json)
            bean.symbol = symbol
            bean.step = step
            return bean

        }

        @JvmStatic
        fun pongBean(): CpWsLinkBean {
            var json = "{\"pong\":${Date().time / 1000}}"
            val bean = CpWsLinkBean("", json)
            return bean
        }

        fun toJson(bean: Any): String {
            return Gson().toJson(bean)
        }

        /**
         *Subscription - 24H market
         *The @param symbol is similar to btcusdt
         *@param isSub Subscription OR Cancel
         */
        @JvmStatic
        fun tickerFor24HLinkBatchBean(symbols: String, isSub: Boolean = true): CpWsLinkBean {
            //The toLowerCase() here is for contract compatibility

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
            val bean = CpWsLinkBean(params, "{\"event\":\"$event\",\"params\":{\"channel\":\"$params\",\"cb_id\":\"1\"}}")
            bean.event = event
            bean.symbol = symbols
            bean.symbols = params
            return bean

        }

        /**
         *Subscription - All currency pairs of the 24H market
         */
        @JvmStatic
        fun tickerFor24HLinkReqBean(cid: Int = 1): CpWsLinkBean {
            //The toLowerCase() here is for contract compatibility
            val params = "review"
            val paramsV2 = "reviewV2"
            val event = "req"
            var paramsJson = when (cid) {
                1 -> "{\"event\":\"$event\",\"params\":{\"channel\":\"$params\"}}"
                else -> "{\"event\":\"$event\",\"params\":{\"channel\":\"$params\",\"cid\":\"${cid}\"}}"
            }
            val bean = CpWsLinkBean(params, paramsJson)
            return bean

        }

        @JvmStatic
        fun is24HLinkTicker(channel:String) :Boolean{
            if("".equals(channel)) return false
            val pattern = Pattern.compile("market_.+_ticker")
            val is24HLinkTicker = pattern.matcher(channel).matches()
            return is24HLinkTicker && !channel.contains("trade")
        }

    }
}

object JsonWSUtils {
    lateinit var gson: Gson

    init {
        gson = Gson()
    }
}
