package com.yjkj.chainup.bean

import com.google.gson.annotations.SerializedName

/**
 * @Author lianshangljl
 *@ Date 2018/10/21-10:36 am
 * @Email buptjinlong@163.com
 * @description
 */
data class OTCGetCoinBean(
        @SerializedName("coinSymbol") val coinSymbol: String = "",//Currency
        @SerializedName("exNormal") val exNormal: String = "",//Normal balance of the exchange
        @SerializedName("otcLock") val otcLock: String = "",//Off site frozen balance
        @SerializedName("exLock") val exLock: String = "",//Exchange frozen balance
        @SerializedName("otcNormal") val otcNormal: String = ""//Off site normal balance
)
