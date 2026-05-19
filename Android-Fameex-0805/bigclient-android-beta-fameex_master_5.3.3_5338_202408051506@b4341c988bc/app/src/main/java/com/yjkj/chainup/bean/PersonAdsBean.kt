package com.yjkj.chainup.bean

import com.google.gson.annotations.SerializedName

/**
 * @Author lianshangljl
 * @Date 2023/4/22-9:32 PM
 * @Email buptjinlong@163.com
 * @description
 */
data class PersonAdsBean(
        @SerializedName("count") var count: String = "",//Total number
        @SerializedName("adList") var adList: ArrayList<AdList> = arrayListOf() //Maximum transaction volume
) {
    data class Payments(
            @SerializedName("key") var key: String = "",//
            @SerializedName("title") var title: String = "",//
            @SerializedName("icon") var icon: String = "",//
            @SerializedName("used") var used: String = ""//
    )

    data class AdList(
            @SerializedName("payCoin") var payCoin: String = "",//Payment currency
            @SerializedName("volume") var volume: String = "",//Total amount
            @SerializedName("side") var side: String = "",//Buying and selling direction
            @SerializedName("createTime") var createTime: String = "",//Creation time
            @SerializedName("price") var price: String = "",//Unit price
            @SerializedName("sell") var sell: String = "",//Turnover volume
            @SerializedName("minTrade") var minTrade: String = "",//Minimum transaction volume
            @SerializedName("maxTrade") var maxTrade: String = "",//Maximum transaction volume
            @SerializedName("advertId") var advertId: String = "",//Advertising ID
            @SerializedName("payments") var payments: ArrayList<Payments> = arrayListOf(),//Maximum transaction volume
            @SerializedName("status") var status: String = "",//Advertising status 1 in release 2 in transaction 3 expired 4 closed
            @SerializedName("coin") var coin: String = "",//Currency
            @SerializedName("isHaveOrder") var isHaveOrder: String = ""//Are there any unfinished orders? 1 Yes 0 No

    )

}
