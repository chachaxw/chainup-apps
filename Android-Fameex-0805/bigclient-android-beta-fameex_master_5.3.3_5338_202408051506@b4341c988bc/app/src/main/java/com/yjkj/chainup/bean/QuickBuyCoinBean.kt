package com.yjkj.chainup.bean

import com.google.gson.annotations.SerializedName
import java.io.Serializable

data class QuickBuyCoinBean(
        @SerializedName("coin_list") val coin_list: ArrayList<Coin>?,
        @SerializedName("fiat_list") val fiat_list: ArrayList<Coin>?,
        @SerializedName("status") val status: Int
) : Serializable

data class Coin(
        @SerializedName("ctime") val ctime: Long,
        @SerializedName("iconColor") val iconColor: String,
        @SerializedName("iconContent") val iconContent: String,
        @SerializedName("iconUrl") val iconUrl: String,
        @SerializedName("id") val id: Int,
        @SerializedName("isFiat") val isFiat: Int,
        @SerializedName("limitMax") val limitMax: String,
        @SerializedName("limitMin") val limitMin: String,
        @SerializedName("mtime") val mtime: Long,
        @SerializedName("alias") val alias: String,
        @SerializedName("name") val name: String,
        @SerializedName("mainChainSymbol") val mainChainSymbol: String?
) : Serializable

data class Fiat(
        @SerializedName("ctime") val ctime: Long,
        @SerializedName("iconColor") val iconColor: String,
        @SerializedName("iconContent") val iconContent: String,
        @SerializedName("iconUrl") val iconUrl: String,
        @SerializedName("id") val id: Int,
        @SerializedName("isFiat") val isFiat: Int,
        @SerializedName("limitMax") val limitMax: Int,
        @SerializedName("limitMin") val limitMin: Int,
        @SerializedName("mtime") val mtime: Long,
        @SerializedName("alias") val alias: String,
        @SerializedName("name") val name: String
) : Serializable

data class RateListBean(
        @SerializedName("rate_list") val rate_list: ArrayList<Rate>,
        @SerializedName("min") val min:String,
        @SerializedName("max") val max:String,
        @SerializedName("target_min") val targetMin:String,
        @SerializedName("target_max") val targetMax:String
) : Serializable

data class Rate(
        @SerializedName("amount") val amount: String,
        @SerializedName("base_amount") val base_amount: String,
        @SerializedName("name") val name: String,
        @SerializedName("payment_pic") val payment_pic: String,
        @SerializedName("quote_id") val quote_id: String,
        @SerializedName("rate") val rate: String,
        @SerializedName("service_pic") val service_pic: String,
        @SerializedName("total_amount") val total_amount: String,
        @SerializedName("valid_until") val valid_until: String
) : Serializable

data class PayCardBean(
        @SerializedName("paycard_list") val paycard_list: ArrayList<Paycard>
)

data class Paycard(
        @SerializedName("amount") val amount: String?,
        @SerializedName("base_amount") val base_amount: String?,
        @SerializedName("name") val name: String,
        @SerializedName("payment_pic") val payment_pic: String,
        @SerializedName("quote_id") val quote_id: String?,
        @SerializedName("rate") var rate: String?,
        @SerializedName("service_pic") val service_pic: String?,
        @SerializedName("total_amount") val total_amount: String?,
        @SerializedName("valid_until") val valid_until: String?,
        @SerializedName("coinName") var coinName: String?,
        @SerializedName("fiatName") var fiatName: String?,
        @SerializedName("target_amount") var targetAmount: String?,
        @SerializedName("source_amount") var sourceAmount: String?

)

data class PaymentSubmitBean(
        @SerializedName("data_map") val data_map: DataMap,
        @SerializedName("html") val html: String
)

data class DataMap(
        @SerializedName("api_version") val api_version: String,
        @SerializedName("partner_name") val partner_name: String,
        @SerializedName("payment_id") val payment_id: String,
        @SerializedName("payment_post_url") val payment_post_url: String,
        @SerializedName("return_url") val return_url: String,
        @SerializedName("simplex_url") val simplex_url: String
)
