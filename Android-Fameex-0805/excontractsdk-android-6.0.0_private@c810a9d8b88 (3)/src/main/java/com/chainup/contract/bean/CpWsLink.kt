package com.yjkj.chainup.bean.kline

import com.google.gson.annotations.SerializedName

/**
 *Transaction history: market_ btcusdt_ trade_ ticker
 */
class CpWsLink(
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
            var cbId: String, //Custom
            @SerializedName("channel")
            var channel: String // $oneDayQuotesChannel
    )
}
