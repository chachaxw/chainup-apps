package com.yjkj.chainup.new_version.bean

import com.google.gson.annotations.SerializedName

/**
 * @Author lianshangljl
 * @Date 2023/5/30-10:15 PM
 * @Email buptjinlong@163.com
 * @description
 */
data class ReadMessageCountBean(
        /**
         *New homepage logo night mode
         */
        @SerializedName("noReadMsgCount") val noReadMsgCount: String = "0"
)

data class PcBannerBean(
    val cmsAppDataListPcBanner: List<CmsAppDataPcBanner>,
    val is_open: String,
    val rate: String,
    val coin: String,
    val fee_trade_status: String
)

data class CmsAppDataPcBanner(
    val httpUrl: String,
    val id: Int,
    val imageUrl: String,
    val lang: String,
    val nativeUrl: String,
    val needLogin: Int,
    val optType: Int,
    val rnUrl: Any,
    val showOpen: Int,
    val sort: Int,
    val subhead: String,
    val symbol: Any,
    val title: String,
    val type: String
)




