package com.yjkj.chainup.util

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.provider.Settings

object PermissionUtil {
    fun toSettingActivity(context: Context){
        val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
            val uri: Uri = Uri.fromParts("package", context.packageName, null)
            data = uri
            flags = Intent.FLAG_ACTIVITY_NEW_TASK
        }
        try {
            context.startActivity(intent)
        } catch (e: java.lang.Exception) {
            e.printStackTrace()
        }
    }

}
