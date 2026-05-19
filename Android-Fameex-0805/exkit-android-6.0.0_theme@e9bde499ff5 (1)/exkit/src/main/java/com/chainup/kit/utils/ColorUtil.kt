package com.chainup.kit.utils

import android.content.Context
import androidx.core.content.ContextCompat

object ColorUtil {

     lateinit   var appContext: Context
    fun getColor(context: Context, colorId: Int) =
        ContextCompat.getColor(context, colorId)

    fun getColor(colorId: Int) = getColor(appContext, colorId)
}

