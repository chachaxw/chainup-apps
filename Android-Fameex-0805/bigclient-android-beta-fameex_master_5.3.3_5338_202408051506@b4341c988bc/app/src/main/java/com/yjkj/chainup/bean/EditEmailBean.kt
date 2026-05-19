package com.yjkj.chainup.bean

import com.google.gson.annotations.SerializedName

data class EditEmailBean(
    @SerializedName("currentEditEmailCodeVerifyPass") val currentEditEmailCodeVerifyPass: Int,
    @SerializedName("emailCodeVerifyPass") val emailCodeVerifyPass: Int,
    @SerializedName("googleCodeVerifyPass") val googleCodeVerifyPass: Int,
    @SerializedName("pass") val pass: Boolean,
    @SerializedName("smsCodeVerifyPass") val smsCodeVerifyPass: Int
)