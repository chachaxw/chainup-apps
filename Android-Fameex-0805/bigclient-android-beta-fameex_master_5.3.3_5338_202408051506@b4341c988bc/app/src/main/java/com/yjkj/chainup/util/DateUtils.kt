package com.yjkj.chainup.util

import android.annotation.SuppressLint
import java.text.SimpleDateFormat
import java.util.*

/**
 * @Author: Bertking
 * @Date 2023/12/14-5:21 PM
 *@description: Processing time
 */

class DateUtils {
    companion object {
        /**
         *MM-dd
         * yyyy-MM
         * HH:mm
         */
        const val FORMAT_MONTH_DAY = "MM-dd"

        /**
         *Year Month
         */
        const val FORMAT_YEAR_MONTH = "yyyy-MM"

        /**
         *Date:
         */
        const val FORMAT_YEAR_MONTH_DAY = "yyyy-MM-dd"

        /**
         *Time division
         */
        const val FORMAT_HOUR_MIN = "HH:mm"

        /**
         *Month day hour
         */
        const val FORMAT_MONTH_DAY_HOUR_MIN = "MM-dd HH:mm"
        const val FORMAT_KLINE_DATE_MDHM = "MM/dd HH:mm"
        const val FORMAT_KLINE_DATE_YMD = "yyyy/MM/dd"

        const val FORMAT_MONTH_DAY_HOUR_MIN_V2 = "MM/dd HH:mm"

        /**
         *Month, day, hour, minute, second
         */
        const val FORMAT_MONTH_DAY_HOUR_MIN_SECOND = "MM-dd HH:mm:ss"

        /**
         *Year, Month, Day, Hour, Minute, Second
         */
        const val FORMAT_YEAR_MONTH_DAY_HOUR_MIN_SECOND = "yyyy-MM-dd HH:mm:ss"

        const val FORMAT_YEAR_MONTH_DAY_HOUR_MIN_SECOND_SSS = "yyyy-MM-dd HH:mm:ss:SSS"


        fun dateToString(format: String, date: Date): String {
            val mFormat = SimpleDateFormat(format)
            return mFormat.format(date)
        }

        fun longToString(format: String, date: Long): String {
            return dateToString(format, Date(date * 1000L))
        }

        fun long2StringMS(format: String, ms: Long): String {
            return dateToString(format, Date(ms))
        }

        /**
         *Return: Month Day Hour Minute Second
         *Ms milliseconds
         */
        fun getYearMonthDayHourMinSecondMS(ms: Long): String {
            return long2StringMS(FORMAT_MONTH_DAY_HOUR_MIN_SECOND, ms)
        }


        /**
         *Return: Year Month Day
         *@param ms milliseconds
         */
        fun getYearMonthDayMS(ms: Long): String {
            return long2StringMS(FORMAT_YEAR_MONTH_DAY, ms)
        }


        /**
         *@return Month Day
         */
        fun getMonthDay(date: Long): String {
            return longToString(FORMAT_MONTH_DAY, date)
        }

        /**
         *@return time
         */
        fun getHourMin(date: Long): String {
            return longToString(FORMAT_HOUR_MIN, date)
        }

        fun getHourMinNew(date: Long): String {
            return long2StringMS(FORMAT_HOUR_MIN, date)
        }

        /**
         *Return: Year Month Day
         *Param seconds
         */
        fun getYearMonthDay(seconds: Long): String {
            return longToString(FORMAT_YEAR_MONTH_DAY, seconds)
        }


        /**
         *Return: Month Day Hour
         *Param seconds (the time returned by ws is calculated in seconds)
         */
        fun getYearMonthDayHourMin(seconds: Long): String {
            return longToString(FORMAT_MONTH_DAY_HOUR_MIN, seconds)
        }

        fun getYearMonthDayHourMinV2(seconds: Long): String {
            return longToString(FORMAT_MONTH_DAY_HOUR_MIN_V2, seconds)
        }

        fun getLogTimeMS(seconds: Long): String {
            return long2StringMS(FORMAT_YEAR_MONTH_DAY_HOUR_MIN_SECOND_SSS, seconds)
        }

        fun getYearLongDayMS(): String {
            return longToString(FORMAT_YEAR_MONTH_DAY_HOUR_MIN_SECOND, Date().time)
        }

        fun getLogTimeMS(): String {
            return long2StringMS(FORMAT_YEAR_MONTH_DAY_HOUR_MIN_SECOND_SSS, Date().time)
        }

        /**
         *Return: Year, Month, Day, Hour, Minute, Second
         *Ms milliseconds
         */
        fun getYearMonthDayHourMinSecond(ms: Long): String {
            return long2StringMS(FORMAT_YEAR_MONTH_DAY_HOUR_MIN_SECOND, ms)
        }

        fun formatLongToTimeStr(l: Long): String? {
            var hour = 0
            var minute = 0
            var second = 0
            second = l.toInt() / 1000
            if (second > 60) {
                minute = second / 60
                second = second % 60
            }
            if (minute > 60) {
                hour = minute / 60
                minute = minute % 60
            }
            return getTwoLength(hour) + ":" + getTwoLength(minute) + ":" + getTwoLength(second)
        }

        private fun getTwoLength(data: Int): String {
            return if (data < 10) {
                "0$data"
            } else {
                "" + data
            }
        }

        /**
         *Is it within the interval
         */
        fun dayIsRegion(start: Long, end: Long, day: Long): Boolean {
            return day in start..end
        }

        fun isSameDay(millis1: Long, millis2: Long, timeZone: TimeZone = TimeZone.getDefault()): Boolean {
            val interval = millis1 - millis2
            return interval < 86400000 && interval > -86400000 && millis2Days(millis1, timeZone) == millis2Days(millis2, timeZone)
        }

        private fun millis2Days(millis: Long, timeZone: TimeZone): Long {
            return (timeZone.getOffset(millis).toLong() + millis) / 86400000
        }

        fun getTimeToLong(time:String):String{
            val format = SimpleDateFormat(FORMAT_YEAR_MONTH_DAY_HOUR_MIN_SECOND)
            return format.parse(time)?.time.toString() ?: ""
        }

        fun millisPreMonth(day : Int = 1):Date{
            val today = Date()
            val next = Calendar.getInstance()
            next.time = today
            next.add(Calendar.MONTH,day)
            return next.time
        }
        fun millisNextDay(day : Int = 1):Date{
            val today = Date()
            val next = Calendar.getInstance()
            next.time = today
            next.add(Calendar.DAY_OF_MONTH,day)
            return next.time
        }
        fun get7DayTimeStart(timeType: String = "0"):Pair<String,String>{
            val time = when(timeType){
                "0" -> {
                    val date = millisNextDay(-7)
                    date.time
                }
                "1" -> {
                    val date = millisPreMonth(-1)
                    date.time
                }
                "2" -> {
                    val date = millisPreMonth(-3)
                    date.time
                }
                "3" -> {
                    val date = millisPreMonth(-6)
                    date.time
                }
                else -> 7
            }
            val tempTime = getYearMonthDayMS(time)
            val today = Date()
            val endTime = getYearMonthDayMS(today.time)
            return Pair(getTimeToLong(tempTime.coinAppendSymbol("00:00:00")),getTimeToLong(endTime.coinAppendSymbol("23:59:59")))
        }
        /**
         * true 第一个比第二个小 false  大
         */
        @SuppressLint("SimpleDateFormat")
        fun dayIsStop(start: String, end: String): Boolean {
            if(start.isEmpty() || end.isEmpty()){
                return false
            }
            val format = SimpleDateFormat(FORMAT_YEAR_MONTH_DAY)

            val startTemp = format.parse(start)
            val endTemp = format.parse(end)
            if (startTemp != null && endTemp != null) {
                if(startTemp > endTemp){
                    return false
                }
            }
            return true

        }

        fun getCurrentDate(format: String): String {
            var curDateTime = ""
            try {
                val mSimpleDateFormat = SimpleDateFormat(format)
                val c: Calendar = GregorianCalendar()
                curDateTime = mSimpleDateFormat.format(c.time)
            } catch (e: Exception) {
                e.printStackTrace()
            }
            return curDateTime
        }

        fun getCurrentDateByOffset(format: String, calendarField: Int, offset: Int): String {
            var mDateTime: String = ""
            try {
                val mSimpleDateFormat = SimpleDateFormat(format)
                val c: Calendar = GregorianCalendar()
                c.add(calendarField, offset)
                mDateTime = mSimpleDateFormat.format(c.time)
            } catch (e: java.lang.Exception) {
                e.printStackTrace()
            }
            return mDateTime
        }


    }
}
