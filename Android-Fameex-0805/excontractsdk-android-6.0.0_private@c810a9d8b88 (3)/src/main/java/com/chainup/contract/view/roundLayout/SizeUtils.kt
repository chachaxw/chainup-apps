package com.minminaya

import android.content.Context

/**
 *Density conversion pixels
 *@param dipValue dp value
 *@return Pixel
 */
fun dip2px(context: Context, dipValue: Float): Float {
    val displayMetrics = context.applicationContext.resources.displayMetrics
    return dipValue * displayMetrics.density + 0.5f
}
