package com.yjkj.chainup.new_version.bean

import com.google.gson.annotations.SerializedName

/**
 * @Author lianshangljl
 *@ Date 2018/10/22-2:24 PM
 * @Email buptjinlong@163.com
 * @description
 */
data class OTCChatBean(
        @SerializedName("message") val message: Message, //0
        @SerializedName("type") val type: String = "", //Type
        @SerializedName("chatId") val chatId: String = "" //Current Chat log id
) {
    data class Message(
            @SerializedName("from") val from: String = "", //0
            @SerializedName("to") val to: String = "", //0
            @SerializedName("content") val content: String = "", //Content
            @SerializedName("time") val time: String = "", //Timestamp
            @SerializedName("orderId") val orderId: String = "" //id
    )
}
