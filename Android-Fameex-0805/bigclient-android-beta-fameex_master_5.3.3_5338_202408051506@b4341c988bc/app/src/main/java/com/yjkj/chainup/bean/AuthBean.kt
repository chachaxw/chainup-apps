package com.yjkj.chainup.bean

import android.net.Uri
import com.google.gson.annotations.SerializedName
import com.yjkj.chainup.util.StringUtil
import com.yjkj.chainup.util.StringUtils
import java.net.URL

/**
 * @Author lianshangljl
 * @Date 2023-03-19-21:54
 * @Email buptjinlong@163.com
 * @description
 */
data class AuthBean(@SerializedName("applyTimeTime") val applyTimeTime: Long = 0, ///34324324.html
                    @SerializedName("amount") val amount: String? = "", //214
                    @SerializedName("coinSymbol") val coinSymbol: String? = "",//How to enable WeChat authorization
                    @SerializedName("address") val address: String? = "",//How to enable WeChat authorization
                    @SerializedName("isOpenCompanyCheck") val isOpenCompanyCheck: Boolean? = false,//How to enable WeChat authorization
                    @SerializedName("isOpenUserCheck") val isOpenUserCheck: Boolean? = false,//How to enable WeChat authorization
                    @SerializedName("label") val label: String? = "",//How to enable WeChat authorization
                    @SerializedName("withdrawId") val withdrawId: String? = "",//Withdrawal Order Id
                    @SerializedName("faceAuthUrl") val faceAuthUrl: String? = "",//Withdrawal Order Id
                    @SerializedName("faceToken") val faceToken: String? = "",//Withdrawal Order Id
                    @SerializedName("applyTime") val applyTime: String? = ""//How to enable WeChat authorization
) {
    fun faceUrl(): String {
        if (faceAuthUrl != null && faceToken != null) {
            val url = StringBuffer(faceAuthUrl)
            return url.append("?token=${faceToken}").toString()
        }
        return ""

    }

    private fun isFace(): Boolean {
        return (faceAuthUrl != null && faceAuthUrl.isNotEmpty() && faceToken != null && faceToken.isNotEmpty())
    }

    fun isUserCheckFace(): Boolean {
        return (isFace()) && isOpenCompanyCheck == true
    }

}
