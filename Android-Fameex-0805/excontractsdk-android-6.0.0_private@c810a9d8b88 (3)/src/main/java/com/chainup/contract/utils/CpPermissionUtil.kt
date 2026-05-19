package com.chainup.contract.utils

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.provider.Settings
import com.chainup.kit.KKDialogUtils
import com.yjkj.chainup.manager.CpLanguageUtil

object CpPermissionUtil {
    fun showOpenPermission(mActivity: Activity,message:String = CpLanguageUtil.getString(mActivity,"cp_extra_text128")){
        KKDialogUtils.showCommonDialog(mActivity,"",
            message,
            listener = object: KKDialogUtils.DialogDoubleBottomListener{
                override fun sendConfirm() {
                    GoPermissionManagement.GoToSetting(mActivity)
                }
                override fun sendCancel() {
                }
            },
            style = 1,
            confrimTitle = CpLanguageUtil.getString(mActivity,"cp_common_text_btnsetting")
        )
    }
}