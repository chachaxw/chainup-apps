package com.chainup.contract.utils

import java.text.ParseException
import java.text.SimpleDateFormat
import java.util.*

/**
 * @Author: Bertking
 * @Date：2018/12/14-5:21 PM
 *@ Description: Processing time
 */

class CpDateUtils {
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
         *Month Day Hour
         */
        const val FORMAT_MONTH_DAY_HOUR_MIN = "MM-dd HH:mm"
        /**
         *Month Day Hour Minute Second
         */
        const val FORMAT_MONTH_DAY_HOUR_MIN_SECOND = "MM-dd HH:mm:ss"

        /**
         *MM DD YY HHM
         */
        const val FORMAT_YEAR_MONTH_DAY_HOUR_MIN_SECOND = "yyyy-MM-dd HH:mm:ss"

        const val DAY_HOUR_MIN_SECOND = "HH:mm:ss"

        const val FORMAT_YEAR_MONTH_DAY_HOUR_MIN_SECOND_SSS = "yyyy-MM-dd HH:mm:ss:SSS"

        const val FORMAT_KLINE_DATE_MDHM = "MM/dd HH:mm"
        const val FORMAT_KLINE_DATE_YMD = "yyyy/MM/dd"


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
         *Return: MM/DD/YY
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
         *@return Time
         */
        fun getHourMin(date: Long): String {
            return longToString(FORMAT_HOUR_MIN, date)
        }

        /**
         *Return: MM/DD/YY
         *@param seconds seconds
         */
        fun getYearMonthDay(seconds: Long): String {
            return longToString(FORMAT_YEAR_MONTH_DAY, seconds)
        }


        fun getKlineDateToYMD(seconds: Long):String{
            try{
                return longToString(FORMAT_KLINE_DATE_YMD,seconds)
            }catch (e:Exception){
                e.printStackTrace()
                return ""
            }

        }

        fun getKlineDateToMDHM(seconds: Long):String{
            return longToString(FORMAT_KLINE_DATE_MDHM,seconds)
        }

        /**
         *Return: Month Day Hour
         *@param seconds seconds (The time returned by ws is calculated in seconds)
         */
        fun getYearMonthDayHourMin(seconds: Long): String {
            return longToString(FORMAT_MONTH_DAY_HOUR_MIN, seconds)
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
         *Return: Month, Month, Day, Hour, Minute, Second
         *Ms milliseconds
         */
        fun getYearMonthDayHourMinSecond(ms: Long): String {
            return long2StringMS(FORMAT_YEAR_MONTH_DAY_HOUR_MIN_SECOND, ms)
        }
        fun formatLongToTimeStr(l: Long): String {
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
         *Description: Gets a string of specified date and time (offset)
         *
         *Date time in the form of @param strDate String
         *@param format Formats a string, such as: "yyyy MM dd HH: mm: ss"
         *"The @param calendarField Calendar attribute corresponds to the offset value, such as (Calendar.DATE, representing+offset days, Calendar.HOUR_OF_DAY, representing+offset hours)"
         *@param offset offset (value greater than 0 indicates+, value less than 0 indicates -)
         *@return String Date time of type String
         */

        fun getLongByOffset(
            longDate: Long,
            calendarField: Int,
            offset: Int
        ): String? {
            var mDateTime: String? = null
            try {

                val c: Calendar = GregorianCalendar()
                val mSimpleDateFormat = SimpleDateFormat(FORMAT_YEAR_MONTH_DAY_HOUR_MIN_SECOND)
                c.time =  Date(longDate);
                c.add(calendarField, offset)
                mDateTime = mSimpleDateFormat.format(c.time)
            } catch (e: ParseException) {
                e.printStackTrace()
            }
            return mDateTime
        }

        fun getLongStrByOffset(
            longDate: Long,
            calendarField: Int,
            offset: Int
        ): Long? {
            try {

                val c: Calendar = GregorianCalendar()
                c.time =  Date(longDate);
                c.add(calendarField, offset)
                 return c.timeInMillis;
            } catch (e: ParseException) {
                e.printStackTrace()
            }
            return 0
        }


        fun getAgoTimeByAmountDays(days: Int): Long {
            val sdf = SimpleDateFormat("yyyy-MM-dd")
            val cTimeString = sdf.format(System.currentTimeMillis())
            val calc = Calendar.getInstance()
            try {
                calc.time = sdf.parse(cTimeString)
                calc.add(Calendar.DATE, days)
                return calc.timeInMillis
            } catch (e1: ParseException) {
                e1.printStackTrace()
                return 0L
            }
        }

        /**
         * 返回：日时分秒
         * ms 毫秒数
         */
        fun getDayHourMinSecond(ms: Long): String {
            return long2StringMS(DAY_HOUR_MIN_SECOND, ms)
        }

    }
}
