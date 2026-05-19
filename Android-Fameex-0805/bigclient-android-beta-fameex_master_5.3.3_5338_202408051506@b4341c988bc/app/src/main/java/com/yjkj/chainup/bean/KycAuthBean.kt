package com.yjkj.chainup.bean

import com.google.gson.annotations.SerializedName

data class KycAuthBean(
    @SerializedName("authConfigName") val authConfigName:AuthConfig,
    @SerializedName("depositStatus") val depositStatus:Int,
    @SerializedName("c2cStatus") val c2cStatus:Int,
    @SerializedName("withdrawAmount") val withdrawAmount:String?,
    @SerializedName("sumsubLevel") val sumsubLevel:String,
    @SerializedName("showName") val showName:String,
    @SerializedName("current") val current:Int,
    @SerializedName("requirementsReference") val requirementsReference:String,
    @SerializedName("status") val status:Int,
    @SerializedName("preLevelName") val preLevelName:String?,
    @SerializedName("authConfigId") val authConfigId:Int
)

enum class AuthConfig {
    PLATFORM,
    SUMSUB;
}
