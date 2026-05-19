package com.yjkj.chainup.util

import java.text.SimpleDateFormat
import java.util.Calendar
import java.util.Date
import java.util.Locale
import java.util.TimeZone

/**
 * @Author: Bertking
 * @Date 2023/3/6-10:56 AM
 *@description: Common Time Tool Class
 */
class TimeUtil private constructor() {
    private val formatDate: SimpleDateFormat = SimpleDateFormat("yyyy-MM-dd", Locale.getDefault())

    private val formatDateTime: SimpleDateFormat = SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.getDefault())

    companion object {
        @JvmStatic
        val instance: TimeUtil by lazy {
            TimeUtil()
        }
    }

    /**
     *@return Month Day
     */
    private fun formatDate(date: Date) = formatDate.format(date)

    /**
     *@return Month Day Hour Minute Second
     */
    private fun formatDateTime(date: Date) = formatDateTime.format(date)

    /**
     *@param millisecond milliseconds
     *@return Month Day
     */
    fun getFormatDate(millisecond: Long): String {
        val calendar = Calendar.getInstance()
        calendar.timeInMillis = millisecond
        return formatDate(calendar.time)
    }

    /**
     *@param millisecond milliseconds
     *@return Month Day Hour Minute Second
     */
    fun getFormatDateTime(millisecond: Long): String {
        val calendar = Calendar.getInstance()
        calendar.timeInMillis = millisecond
        return formatDateTime(calendar.time)
    }

    fun getTime(time: String?): String {
        return if (time == null) {
            ""
        } else {
            if (StringUtil.checkStr(time)) {
                when (time.length) {
                    10 -> {
                        getFormatDateTime(time?.toLong() * 1000L)
                    }
                    13 -> {
                        getFormatDateTime(time?.toLong())
                    }
                    else -> {
                        ""
                    }
                }
            } else {
                ""
            }
        }

    }

    fun getCurrentTimeZone(): TimeZone {
        val timeZone = TimeZone.getDefault()
        return timeZone
    }
    fun convertTimestampToTimezone(timestamp: Long, dateFormat: String = "yyyy-MM-dd HH:mm:ss"): String? {
        return try {
            val date = Date(timestamp)

            val timeZone = getCurrentTimeZone()

            val sdf = SimpleDateFormat(dateFormat)
            sdf.timeZone = timeZone

            sdf.format(date)
        } catch (e: Exception) {
            e.printStackTrace()
            null
        }
    }


}
