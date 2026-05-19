package com.yjkj.chainup.new_version.kline.formatter

import com.chainup.contract.utils.CpBigDecimalUtils
import com.yjkj.chainup.new_version.kline.base.CpIValueFormatter
import java.util.*

/**
 * @Author: Bertking
 * @Date：2019/3/12-4:16 PM
 * @Description:
 */
class CpBigValueFormatter(val mPricePrecision:Int) : CpIValueFormatter {
    private val values = intArrayOf(1000, 1000000, 1000000000)
    private val units = arrayOf("K", "M", "B")

    override fun format(value: Float): String {
        var value = value
        var unit = ""
        var i = values.size - 1
        while (i >= 0) {
            if (value > values[i]) {
                value /= values[i].toFloat()
                unit = units[i]
                break
            }
            i--
        }
        return CpBigDecimalUtils.showSNormal(value.toString(),mPricePrecision) + unit
    }


}
