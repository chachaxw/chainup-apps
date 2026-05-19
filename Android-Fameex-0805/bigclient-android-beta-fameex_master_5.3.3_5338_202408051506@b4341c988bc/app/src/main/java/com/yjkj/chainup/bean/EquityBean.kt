package com.yjkj.chainup.bean

import com.google.gson.annotations.SerializedName

data class EquityBean(
    @SerializedName("withdrawAmount") val withdrawAmount:String,
    @SerializedName("canUseAmount") val canUseAmount:String,
    @SerializedName("c2cStatus") val c2cStatus:Int,
    @SerializedName("depositStatus") val depositStatus:Int,
    @SerializedName("currentSymbolAmount") val currentSymbolAmount:String,

)
