package com.yjkj.chainup.new_version.kline.base

/**
 * @Author: Bertking
 * @Date 2023/3/11-10:43 AM
 *@description: Format values on KLine
 */
interface IValueFormatter {
    /**
     *Format value
     *
     *The value value passed in by @param value
     *@return returns a string
     */
    fun format(value: Float): String
}
