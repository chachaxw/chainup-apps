package com.chainup.kit.utils

import com.chainup.kit.AppConstant
//import com.chainup.kit.views.KKComVerifyView
//
//fun String.verifitionType(): Int {
//    return when (this) {
//        "1" -> KKComVerifyView.GOOGLE
//        "2" -> KKComVerifyView.MOBILE
//        "3" -> KKComVerifyView.EMAIL
//        "4" -> KKComVerifyView.IDCard
//        else -> KKComVerifyView.GOOGLE
//    }
//}

fun String.verfitionTypeForPhone(): Int {
    return when (this) {
        "1" -> AppConstant.MOBILE_LOGIN
        "2" -> AppConstant.MOBILE_LOGIN
        "3" -> AppConstant.EMAIL_LOGIN
        else -> AppConstant.MOBILE_LOGIN
    }
}

fun String.verfitionTypeCheck(): String {
    return when (this) {
        "1" -> "googleCode"
        "2" -> "smsCode"
        "3" -> "emailCode"
        "4" -> "idCardCode"
        else -> ""
    }
}

fun String.verfitionTypeHint(): String {
    return when (this) {
        "1" -> "common_tip_googleAuth"
        "2" -> "personal_tip_inputPhoneCode"
        "3" -> "personal_tip_inputMailCode"
        "4" -> "personal_tip_inputIdnumber"
        else -> ""
    }
}
