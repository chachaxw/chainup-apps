package com.chainup.contract.view

import android.content.Context
import android.icu.number.Precision
import android.util.Log
import com.chainup.contract.utils.CpBigDecimalUtils
import com.github.mikephil.charting.formatter.ValueFormatter

/**
 * @Author: Bertking
 * @Date：2019-07-29-15:47
 *@ Description: Customized Y-axis display format
 */
class CpDepthYValueFormatter(val context: Context, val symbolPrecision:Int) : ValueFormatter() {
    val TAG = CpDepthYValueFormatter::class.java.simpleName

    override fun getFormattedValue(value: Float): String {
        Log.d(TAG, "======value:$value===")
        if (value == 0f) {
            return ""
        }
        return CpBigDecimalUtils.showDepthVolume(context,value.toString(),symbolPrecision)
    }
}
