package com.yjkj.chainup.new_version.kline.base

/**
 * @Author: Bertking
 * @Date：2019/3/11-10:43 AM
 *@ Description: Format the value on KLine
 */
interface CpIValueFormatter {
    /**
     *Format value
     *
     *@param value The value passed in
     *@return Returns a string
     */
    fun format(value: Float): String
}
