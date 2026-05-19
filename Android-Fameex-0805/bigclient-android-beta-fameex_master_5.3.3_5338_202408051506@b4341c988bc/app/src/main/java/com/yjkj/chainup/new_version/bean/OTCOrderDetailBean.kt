package com.yjkj.chainup.new_version.bean

import com.google.gson.annotations.SerializedName

data class OTCOrderDetailBean(
        @SerializedName("seller") val seller: Seller,
        @SerializedName("complainId") val complainId: Int, //0 Appeal ID
        @SerializedName("totalPrice") val totalPrice: String ?= "", //13.5600000000000000
        @SerializedName("payTime") val payTime: String = "0", //Paid time, the front-end determines whether to display the submit appeal button based on this time
        @SerializedName("complainCommand") val complainCommand: String = "", //Appeal Password
        @SerializedName("paycoin") val paycoin: String = "", //Payment Currency - CNY
        @SerializedName("description") val description: String = "", //
        @SerializedName("isTwoMin") val isTwoMin: Int = 0, //Is it more than two minutes? 0: Display for 2 minutes. Copy 1: Email and phone number will only be given (new for off-site optimization 0709)
        @SerializedName("buyer") val buyer: Buyer,
        @SerializedName("volume") val volume: Double = 0.0, //1.0000000000000000
        @SerializedName("limitTime") val limitTime: Int = 0, //719477
        @SerializedName("sendCoinTime") val sendCoinTime: String = "0", //Release time, completed display (new)
        @SerializedName("sequence") val sequence: String = "", //2018101811332 Order ID
        @SerializedName("isComplainUser") val isComplainUser: Int, //0. The current user is not the complainant. 1. The current user is the complainant (new)
        @SerializedName("price") val price: String ?= "", //13.5690930449890000
        @SerializedName("payment") val payment: ArrayList<Payment>,
        @SerializedName("coin") val coin: String = "", //Purchase Currency - USDT
        @SerializedName("payKey") val payKey: String = "", //Purchase Currency - USDT
        @SerializedName("showWarnTip") val showWarnTip: Boolean = false, //Purchase Currency - USDT
        @SerializedName("status") val status: Int, //Order status pending payment 1 Paid 2 Successful transaction 3 Cancelled 4 Appeal 5 Coining 6 Abnormal order 7 Appeal processing completed 8
        @SerializedName("isBlockTrade") val isBlockTrade: String = "",//0: Regular order, 1: Bulk order
        @SerializedName("otcAuthnameOpen") val otcAuthnameOpen: String = "0", //Display real name switch 0: Not on 1: On
        @SerializedName("cancelStatus") val cancelStatus: String = "0",//0: Default no cancellation status, 1: Buyer cancellation 2: Appeal judgment buyer unpaid cancellation 3: Overtime unpaid cancellation
        @SerializedName("ctime") val ctime: Long = 0L//Order creation time

) {
    data class Buyer(
            @SerializedName("uid") val uid: Int, //10609
            @SerializedName("otcNickName") val otcNickName: String = "", //186****6503
            @SerializedName("email") val email: String = "", //Email
            @SerializedName("realName") val realName: String = "", //Name
            @SerializedName("imageUrl") val imageUrl: String = "",
            @SerializedName("isOnline") val isOnline: Int, //1
            @SerializedName("mobileNumber") val mobileNumber: String = "",//Telephone
            @SerializedName("countryCode") val countryCode: String = "",
            @SerializedName("companyLevel") val companyLevel: Int,
            @SerializedName("completeOrders") val completeOrders: Int //0
    )


    data class Payment(
            @SerializedName("payment") val payment: String = "", //otc.payment.alipay
            @SerializedName("bankName") val bankName: String = "", //Bank name
            @SerializedName("bankOfDeposit") val bankOfDeposit: String = "", //Branch
            @SerializedName("qrcodeImg") val qrcodeImg: String = "", //Picture
            @SerializedName("userName") val userName: String = "", //User Name
            @SerializedName("ifscCode") val ifscCode: String = "",//null
            @SerializedName("account") val account: String = "",//null
            @SerializedName("icon") val icon: String = "", //otc.payment.alipay
            @SerializedName("title") val title: Any //null
    )

    data class Seller(
            @SerializedName("uid") val uid: Int, //10639
            @SerializedName("otcNickName") val otcNickName: String = "", //ja****98
            @SerializedName("email") val email: String = "", //Email
            @SerializedName("realName") val realName: String = "", //Name
            @SerializedName("imageUrl") val imageUrl: String = "",
            @SerializedName("isOnline") val isOnline: Int, //0
            @SerializedName("mobileNumber") val mobileNumber: String = "",//Telephone
            @SerializedName("countryCode") val countryCode: String = "",
            @SerializedName("companyLevel") val companyLevel: Int,
            @SerializedName("completeOrders") val completeOrders: Int //20
    )
}

