package com.yjkj.chainup.bean.kline

import com.google.gson.annotations.SerializedName

/**
 *Transaction history: market_ Btcusdt_ Trade_ Ticker
 */
class WsLink(
        @SerializedName("event")
        var event: String = "", // $event
        @SerializedName("params")
        var params: Params?

) {
    constructor(event: String) : this( "",Params("自定义","hhh")) {
        this.event = event
    }

    constructor() : this("")

    class Params(
            @SerializedName("cb_id")
            var cbId: String, //Customize
            @SerializedName("channel")
            var channel: String // $oneDayQuotesChannel
    )
}
