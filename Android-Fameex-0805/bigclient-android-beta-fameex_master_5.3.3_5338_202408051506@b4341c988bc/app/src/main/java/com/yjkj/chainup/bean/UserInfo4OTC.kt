package com.yjkj.chainup.bean

import com.google.gson.annotations.SerializedName

/**
 * @Author lianshangljl
 *@ Date 2018/10/18-11:56 AM
 * @Email buptjinlong@163.com
 * @description
 */
data class UserInfo4OTC(
        @SerializedName("imageUrl") var imageUrl: String = "",//User profile
        @SerializedName("lastLoginTime") var lastLoginTime: Long = 0L,//Last login time
        @SerializedName("authLevel") var authLevel: Int,//Certification status 0. Unaudited, 1. Passed, 2. Not Passed, 3. Not Certified
        @SerializedName("mobileAuthStatus") var mobileAuthStatus: Int,//Has mobile authentication been enabled: 0- not enabled, 1- enabled
        @SerializedName("otcNickName") var otcNickName: String = "",//User nickname
        @SerializedName("completeOrders") var completeOrders: Int,//Number of user order transactions (number of transactions)
        @SerializedName("complainNum") var complainNum: Int,//Total appeal volume
        /**
         *Determine the access status of this page (as follows):
        0：未登录用户查看他人的主页和登录用户查看自己的主页；
        1：登录用户查看他人的主页，并且当前显示用户在登录用户黑名单中；
        2：登录用户查看他人的主页，并且当前显示用户不在登录用户黑名单中
         */
        @SerializedName("identity") var identity: Int,//Whether to block or not
        @SerializedName("otcLast30DaysComOrders") var otcLast30DaysComOrders: Long = 0L,//30 day order completion
        @SerializedName("trustScore") var trustScore: Double = 0.0,//Credit rating
        @SerializedName("otcOrderAvePaidTime") var otcOrderAvePaidTime: Double = 0.0,//Average Off site Coin Release Time
        @SerializedName("sucComplainNum") var sucComplainNum: Int,//Number of successful lawsuits
        @SerializedName("loginStatus") var loginStatus: Int,//Online status (1 online, 0 offline)
        @SerializedName("registerTime") var registerTime: Long = 0L//Registration time
)
