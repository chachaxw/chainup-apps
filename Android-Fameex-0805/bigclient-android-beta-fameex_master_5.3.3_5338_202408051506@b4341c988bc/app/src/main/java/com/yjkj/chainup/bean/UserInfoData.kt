package com.yjkj.chainup.bean

import com.google.gson.annotations.SerializedName
/**
 * @Author lianshangljl
 * @Date 2023/10/22-4:04 PM
 * @Email buptjinlong@163.com
 * @description
 */



data class UserInfoData(
        @SerializedName("googleStatus") var googleStatus: Int,//Do you want to enable googel verification
        @SerializedName("nickName") var nickName: String = "",
        @SerializedName("mobileNumber") var mobileNumber: String = "",
        @SerializedName("isCapitalPwordSet") var isCapitalPwordSet: Int,//Enable fund password verification
        @SerializedName("myMarket") var myMarket: List<Any> = listOf(),
        @SerializedName("feeCoinRate") var feeCoinRate: String = "",
        @SerializedName("useFeeCoinOpen") var useFeeCoinOpen: Int,
        @SerializedName("lastLoginIp") var lastLoginIp: String = "",
        @SerializedName("accountStatus") var accountStatus: Int,//Account status 0. Normal 1. Frozen transactions, frozen withdrawals 2. Frozen transactions 3. Frozen withdrawals
        @SerializedName("isOpenMobileCheck") var isOpenMobileCheck: Int,//Do you want to enable mobile verification
        @SerializedName("lastLoginTime") var lastLoginTime: String="",
        @SerializedName("realName") var realName: String = "",//Authenticated Name
        @SerializedName("feeCoin") var feeCoin: String="",
        @SerializedName("countryCode") var countryCode: String="",
        @SerializedName("gesturePwd") var gesturePwd: String="",
        @SerializedName("inviteUrl") var inviteUrl: String="",//Invitation Link
        @SerializedName("userAccount") var userAccount: String="",
        @SerializedName("inviteCode") var inviteCode: String="",//Invitation code
        @SerializedName("id") var id: Int,
        @SerializedName("notPassReason") var notPassReason: String = "",
        @SerializedName("authLevel") var authLevel: Int,//Certification status 0. Unaudited, 1. Passed, 2. Not Passed, 3. Not Certified
        @SerializedName("email") var email: String = "",
        @SerializedName("creditGrade") var creditGrade: Double = 0.0//Credit rating
) {
    override fun toString(): String {
        return "UserInfoData(googleStatus=$googleStatus, nickName='$nickName', mobileNumber='$mobileNumber', isCapitalPwordSet=$isCapitalPwordSet, myMarket=$myMarket, feeCoinRate='$feeCoinRate', useFeeCoinOpen=$useFeeCoinOpen, lastLoginIp='$lastLoginIp', accountStatus=$accountStatus, isOpenMobileCheck=$isOpenMobileCheck, lastLoginTime='$lastLoginTime', realName='$realName', feeCoin='$feeCoin', countryCode='$countryCode', gesturePwd='$gesturePwd', inviteUrl='$inviteUrl', userAccount='$userAccount', inviteCode='$inviteCode', id=$id, notPassReason='$notPassReason', authLevel=$authLevel, email='$email', creditGrade=$creditGrade)"
    }
}
