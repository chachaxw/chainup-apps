package com.yjkj.chainup.new_version.view.depth

import android.util.Log
import com.github.mikephil.charting.formatter.ValueFormatter
import com.yjkj.chainup.util.BigDecimalUtils

/**
 * @Author: Bertking
 * @Date 2023-07-29-15:47
 *@description: Customized Y-axis display format
 */
class DepthYValueFormatter : ValueFormatter() {
    val TAG = DepthYValueFormatter::class.java.simpleName

    override fun getFormattedValue(value: Float): String {
        
        if (value == 0f) {
            return ""
        }
        return BigDecimalUtils.showDepthVolume(value.toString())
    }
}
