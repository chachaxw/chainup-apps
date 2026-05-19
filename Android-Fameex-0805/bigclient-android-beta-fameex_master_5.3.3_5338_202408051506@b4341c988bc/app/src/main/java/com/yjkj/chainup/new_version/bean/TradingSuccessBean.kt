package com.yjkj.chainup.new_version.bean

import com.google.gson.annotations.SerializedName

/**
 * @Author lianshangljl
 * @Date 2023/4/28-2:43 PM
 * @Email buptjinlong@163.com
 *@description is used for passing values
 */
data class TradingSuccessBean(
        @SerializedName("coinName") val coinName: String? = "" //Purchase Currency

)
