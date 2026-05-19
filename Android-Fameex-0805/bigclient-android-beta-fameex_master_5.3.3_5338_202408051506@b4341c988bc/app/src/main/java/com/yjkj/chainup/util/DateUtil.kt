package com.fengniao.news.util

import java.text.SimpleDateFormat
import java.util.*


object DateUtil {

    const val ymdFormat = "yyyy-MM-dd"
    const val ymdHmFormat = "yyyy-MM-dd HH:mm"
    const val ymdHmsFormat = "yyyy-MM-dd HH:mm:ss"
    const val hmsFormat = "HH:mm:ss"

    /**
     *Convert date to string
     *
     *@param format Date format, for example: yyyyMMdd
     *Param date
     * @return
     */
    fun dateToString(format: String, date: Date): String {
        val mFormat = SimpleDateFormat(format)
        return mFormat.format(date)
    }

    fun longToString(format: String, date: Long): String {
        return dateToString(format, Date(date))
    }

    fun NewTimeReturn(): String {
        var time = dateToString("HH:mm", Date(System.currentTimeMillis()))
        var min = time.split(":")
        return min[1]
    }


    fun timestampToString(format: String, date: Long): String {
        val mFormat = SimpleDateFormat(format)
        return mFormat.format(date)
    }


}
