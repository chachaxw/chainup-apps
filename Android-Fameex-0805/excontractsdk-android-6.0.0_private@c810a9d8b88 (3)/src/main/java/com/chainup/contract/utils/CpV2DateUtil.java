/*
 *Copyright (c) 2016. Jing'an Danling All Rights Reserved
 */
package com.chainup.contract.utils;

import android.text.TextUtils;


import java.text.DateFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.GregorianCalendar;
import java.util.Locale;
import java.util.TimeZone;

// TODO: Auto-generated Javadoc

/**
 * ====================================================================================================
 * <p/>
 *
 *@ Author: Li Bingbing
 *@ Date: 11:52, January 18, 2015
 *@ Description: Date processing class
 * <p/>
 * ====================================================================================================
 */
public class CpV2DateUtil {

    /**
     *Format the time and date to MM/DD/YYYY, HH/MM/SEC
     */
    public static final String dateFormatYMDHMS = "yyyy-MM-dd HH:mm:ss";

    public static final String dateFormatMDHMS = "MM-dd HH:mm:ss";

    /**
     *Format the time and date to MM/DD/YYYY
     */
    public static final String dateFormatYMD = "yyyy-MM-dd";

    /**
     *Format the time and date to the month and year
     */
    public static final String dateFormatYM = "yyyy-MM";

    /**
     *Format the time and date to MM/DD/YYYY/HHM
     */
    public static final String dateFormatYMDHM = "yyyy-MM-dd HH:mm";

    public static final String dateFormatYMDHM_ = "yyyyMMddHHmm";
    public static final String dateFormatYMDHM_2 = "yyyyMMddHHmmss";
    public static final String dateFormatYMDHM_1 = "yyyyMMdd";

    /**
     *Format the time and date to month and day
     */
    public static final String dateFormatMD = "MM/dd";

    /**
     *Hours, minutes, and seconds
     */
    public static final String dateFormatHMS = "HH:mm:ss";

    /**
     *Time division
     */
    public static final String dateFormatHM = "HH:mm";

    /**
     *Morning
     */
    public static final String AM = "AM";

    /**
     *Afternoon
     */
    public static final String PM = "PM";


    /**
     *Description: Date time of String type is converted to Date type
     *
     *Date time in the form of @param strDate String
     *@param format Formats a string, such as: "yyyy MM dd HH: mm: ss"
     *@return Date Date Type Date Time
     */
    public static Date getDateByFormat(String strDate, String format) {
        SimpleDateFormat mSimpleDateFormat = new SimpleDateFormat(format);
        Date date = null;
        try {
            date = mSimpleDateFormat.parse(strDate);
        } catch (ParseException e) {
            e.printStackTrace();
        }
        return date;
    }

    /**
     *Description: Gets the date after the offset
     *
     *@param date Date Time
     *"The @param calendarField Calendar attribute corresponds to the offset value, such as (Calendar.DATE, representing+offset days, Calendar.HOUR_OF_DAY, representing+offset hours)"
     *@param offset offset (value greater than 0 indicates+, value less than 0 indicates -)
     *@return Date The date and time after the offset
     */
    public static Date getDateByOffset(Date date, int calendarField, int offset) {
        Calendar c = new GregorianCalendar();
        try {
            c.setTime(date);
            c.add(calendarField, offset);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return c.getTime();
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
    public static String getStringByOffset(String strDate, String format, int calendarField, int offset) {
        String mDateTime = null;
        try {
            Calendar c = new GregorianCalendar();
            SimpleDateFormat mSimpleDateFormat = new SimpleDateFormat(format);
            c.setTime(mSimpleDateFormat.parse(strDate));
            c.add(calendarField, offset);
            mDateTime = mSimpleDateFormat.format(c.getTime());
        } catch (ParseException e) {
            e.printStackTrace();
        }
        return mDateTime;
    }

    /**
     *Description: The Date type is converted to a String type (offset able)
     *
     * @param date          the date
     * @param format        the format
     * @param calendarField the calendar field
     * @param offset        the offset
     *@return String String Type Date Time
     */
    public static String getStringByOffset(Date date, String format, int calendarField, int offset) {
        String strDate = null;
        try {
            Calendar c = new GregorianCalendar();
            SimpleDateFormat mSimpleDateFormat = new SimpleDateFormat(format);
            c.setTime(date);
            c.add(calendarField, offset);
            strDate = mSimpleDateFormat.format(c.getTime());
        } catch (Exception e) {
            e.printStackTrace();
        }
        return strDate;
    }


    /**
     *Description: Date type is converted to String type
     *
     * @param date   the date
     * @param format the format
     *@return String String Type Date Time
     */
    public static String getStringByFormat(Date date, String format) {
        SimpleDateFormat mSimpleDateFormat = new SimpleDateFormat(format);
        String strDate = null;
        try {
            strDate = mSimpleDateFormat.format(date);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return strDate;
    }

    /**
     *Description: Gets a string specifying the date and time used to export the desired format
     * MMM dd,yyyy kk:mm:ss aa
     *
     * @param format the format
     *@return String String Type Date Time
     */
    public static String getStringByDateFormat(String strDate, String format) {
        String mDateTime = null;
        try {
            Calendar c = new GregorianCalendar();
            SimpleDateFormat mSimpleDateFormat = new SimpleDateFormat("MMM dd,yyyy kk:mm:ss aa", Locale.ENGLISH);
            c.setTime(mSimpleDateFormat.parse(strDate));
            SimpleDateFormat mSimpleDateFormat2 = new SimpleDateFormat(format);
            mDateTime = mSimpleDateFormat2.format(c.getTime());
        } catch (Exception e) {
            e.printStackTrace();
        }
        return mDateTime;
    }

    /**
     *Description: Gets a string specifying the date and time used to export the desired format
     *
     *Date time in the form of @param strDate String must be in the format yyyy-MM-dd HH: mm: ss
     *@param format Output a formatted string, such as: "yyyy MM dd HH: mm: ss"
     *@return The date and time of the converted String type
     */
    public static String getStringByFormat(String strDate, String format) {
        String mDateTime = null;
        try {
            Calendar c = new GregorianCalendar();
            SimpleDateFormat mSimpleDateFormat = new SimpleDateFormat(dateFormatYMDHMS);
            c.setTime(mSimpleDateFormat.parse(strDate));
            SimpleDateFormat mSimpleDateFormat2 = new SimpleDateFormat(format);
            mDateTime = mSimpleDateFormat2.format(c.getTime());
        } catch (Exception e) {
            e.printStackTrace();
        }
        return mDateTime;
    }

    /**
     *Description: Gets a string representing the date and time in milliseconds
     *
     * @param milliseconds the milliseconds
     *@param format Formats a string, such as: "yyyy MM dd HH: mm: ss"
     *@return String Date Time String
     */
    public static String getStringByFormat(long milliseconds, String format) {
        String thisDateTime = null;
        try {
            SimpleDateFormat mSimpleDateFormat = new SimpleDateFormat(format);
            thisDateTime = mSimpleDateFormat.format(milliseconds);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return thisDateTime;
    }

    private static SimpleDateFormat mSimpleDateFormat = new SimpleDateFormat("yyyyMMddHHmmss");
    private static Calendar c = new GregorianCalendar();

    /**
     *Description: Gets a string representing the current date and time
     *
     *@return String The current date and time of type String
     */
    public static String getCurrentDate() {
        String curDateTime = null;
        try {
            curDateTime = mSimpleDateFormat.format(c.getTime());
        } catch (Exception e) {
            e.printStackTrace();
        }
        return curDateTime;

    }

    public static String getCurrentDate(String format) {
        //Logutil.debug("getCurrentDate:" + format);
        String curDateTime = "";
        try {
            SimpleDateFormat mSimpleDateFormat = new SimpleDateFormat(format);
            Calendar c = new GregorianCalendar();
            curDateTime = mSimpleDateFormat.format(c.getTime());
        } catch (Exception e) {
            e.printStackTrace();
        }
        return curDateTime;

    }

    /**
     *Description: Gets a string representing the current date and time (offset)
     *
     *@param format Formats a string, such as: "yyyy MM dd HH: mm: ss"
     *"The @param calendarField Calendar attribute corresponds to the offset value, such as (Calendar.DATE, representing+offset days, Calendar.HOUR_OF_DAY, representing+offset hours)"
     *@param offset offset (value greater than 0 indicates+, value less than 0 indicates -)
     *@return String Date time of type String
     */
    public static String getCurrentDateByOffset(String format, int calendarField, int offset) {
        String mDateTime = null;
        try {
            SimpleDateFormat mSimpleDateFormat = new SimpleDateFormat(format);
            Calendar c = new GregorianCalendar();
            c.add(calendarField, offset);
            mDateTime = mSimpleDateFormat.format(c.getTime());
        } catch (Exception e) {
            e.printStackTrace();
        }
        return mDateTime;

    }

    /**
     *Description: Calculate the number of days between two dates
     *
     * @param milliseconds1 the milliseconds1
     * @param milliseconds2 the milliseconds2
     *@return int Number of days left
     */
    public static int getOffectDay(long milliseconds1, long milliseconds2) {
        Calendar calendar1 = Calendar.getInstance();
        calendar1.setTimeInMillis(milliseconds1);
        Calendar calendar2 = Calendar.getInstance();
        calendar2.setTimeInMillis(milliseconds2);
        //Determine whether it is the same year first
        int y1 = calendar1.get(Calendar.YEAR);
        int y2 = calendar2.get(Calendar.YEAR);
        int d1 = calendar1.get(Calendar.DAY_OF_YEAR);
        int d2 = calendar2.get(Calendar.DAY_OF_YEAR);
        int maxDays = 0;
        int day = 0;
        if (y1 - y2 > 0) {
            maxDays = calendar2.getActualMaximum(Calendar.DAY_OF_YEAR);
            day = d1 - d2 + maxDays;
        } else if (y1 - y2 < 0) {
            maxDays = calendar1.getActualMaximum(Calendar.DAY_OF_YEAR);
            day = d1 - d2 - maxDays;
        } else {
            day = d1 - d2;
        }
        return day;
    }

    /**
     *Description: Calculates the number of hours between two dates
     *
     *The millisecond representation of the first time of @param date1
     *@param date2 The millisecond representation of the second time
     *@return int Number of hours left
     */
    public static int getOffectHour(long date1, long date2) {
        Calendar calendar1 = Calendar.getInstance();
        calendar1.setTimeInMillis(date1);
        Calendar calendar2 = Calendar.getInstance();
        calendar2.setTimeInMillis(date2);
        int h1 = calendar1.get(Calendar.HOUR_OF_DAY);
        int h2 = calendar2.get(Calendar.HOUR_OF_DAY);
        int h = 0;
        int day = getOffectDay(date1, date2);
        h = h1 - h2 + day * 24;
        return h;
    }

    /**
     *Description: Counts the number of minutes between two dates
     *
     *The millisecond representation of the first time of @param date1
     *@param date2 The millisecond representation of the second time
     *@return int Number of minutes left
     */
    public static int getOffectMinutes(long date1, long date2) {
        Calendar calendar1 = Calendar.getInstance();
        calendar1.setTimeInMillis(date1);
        Calendar calendar2 = Calendar.getInstance();
        calendar2.setTimeInMillis(date2);
        int m1 = calendar1.get(Calendar.MINUTE);
        int m2 = calendar2.get(Calendar.MINUTE);
        int h = getOffectHour(date1, date2);
        int m = 0;
        m = m1 - m2 + h * 60;
        return m;
    }

    /**
     * @param date1
     * @param date2
     * @return
     *@ Author: Li Bingbing
     *@ Date: 2016/7/4 17:27
     *@ Description: Calculates the number of seconds between two dates
     */
    public static int getOffectSeconds(long date1, long date2) {
        Calendar calendar1 = Calendar.getInstance();
        calendar1.setTimeInMillis(date1);
        Calendar calendar2 = Calendar.getInstance();
        calendar2.setTimeInMillis(date2);
        int s1 = calendar1.get(Calendar.SECOND);
        int s2 = calendar2.get(Calendar.SECOND);
        int m = getOffectMinutes(date1, date2);
        int s = 0;
        s = s1 - s2 + m * 60;
        return s;
    }

    /**
     * @param date1
     * @param date2
     * @return
     *@ Author: Li Bingbing
     *@ Date: 2016/7/4 17:27
     *@ Description: Counts the number of seconds between two dates
     */
    public static int getOffectLongs(long date1, long date2) {
        Calendar calendar1 = Calendar.getInstance();
        calendar1.setTimeInMillis(date1);
        Calendar calendar2 = Calendar.getInstance();
        calendar2.setTimeInMillis(date2);
        int ms1 = calendar1.get(Calendar.MILLISECOND);
        int ms2 = calendar2.get(Calendar.MILLISECOND);
        int s = getOffectSeconds(date1, date2);
        int ms = 0;
        ms = ms1 - ms2 + s * 1000;
        return ms;
    }

    /**
     *Description: String to Long
     *
     * @param strTime
     * @param formatType
     * @return
     * @throws ParseException
     */
    public static long stringToLong(String strTime, String formatType)
            throws ParseException {
        Date date = getDateByFormat(strTime, formatType); //Convert String type to date type
        if (date == null) {
            return 0;
        } else {
            long currentTime = date.getTime(); //Convert date type to long type
            return currentTime;
        }
    }


    /**
     *Description: Get this Monday
     *
     * @param format the format
     *@return String String Type Date Time
     */
    public static String getFirstDayOfWeek(String format) {
        return getDayOfWeek(format, Calendar.MONDAY);
    }

    /**
     *Description: Get this Sunday
     *
     * @param format the format
     *@return String String Type Date Time
     */
    public static String getLastDayOfWeek(String format) {
        return getDayOfWeek(format, Calendar.SUNDAY);
    }

    /**
     *Description: Get a day of the week
     *
     * @param format        the format
     * @param calendarField the calendar field
     *@return String String Type Date Time
     */
    private static String getDayOfWeek(String format, int calendarField) {
        String strDate = null;
        try {
            Calendar c = new GregorianCalendar();
            SimpleDateFormat mSimpleDateFormat = new SimpleDateFormat(format);
            int week = c.get(Calendar.DAY_OF_WEEK);
            if (week == calendarField) {
                strDate = mSimpleDateFormat.format(c.getTime());
            } else {
                int offectDay = calendarField - week;
                if (calendarField == Calendar.SUNDAY) {
                    offectDay = 7 - Math.abs(offectDay);
                }
                c.add(Calendar.DATE, offectDay);
                strDate = mSimpleDateFormat.format(c.getTime());
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return strDate;
    }

    /**
     *Description: Get the first day of the month
     *
     * @param format the format
     *@return String String Type Date Time
     */
    public static String getFirstDayOfMonth(String format) {
        String strDate = null;
        try {
            Calendar c = new GregorianCalendar();
            SimpleDateFormat mSimpleDateFormat = new SimpleDateFormat(format);
            //The first day of the current month
            c.set(GregorianCalendar.DAY_OF_MONTH, 1);
            strDate = mSimpleDateFormat.format(c.getTime());
        } catch (Exception e) {
            e.printStackTrace();
        }
        return strDate;

    }

    /**
     *Description: Obtain the last day of the month
     *
     * @param format the format
     *@return String String Type Date Time
     */
    public static String getLastDayOfMonth(String format) {
        String strDate = null;
        try {
            Calendar c = new GregorianCalendar();
            SimpleDateFormat mSimpleDateFormat = new SimpleDateFormat(format);
            //The last day of the current month
            c.set(Calendar.DATE, 1);
            c.roll(Calendar.DATE, -1);
            strDate = mSimpleDateFormat.format(c.getTime());
        } catch (Exception e) {
            e.printStackTrace();
        }
        return strDate;
    }


    /**
     *Description: Gets the 0 o'clock time milliseconds representing the current date
     *
     * @return the first time of day
     */
    public static long getFirstTimeOfDay() {
        Date date = null;
        try {
            String currentDate = getCurrentDate(dateFormatYMD);
            date = getDateByFormat(currentDate + " 00:00:00", dateFormatYMDHMS);
            return date.getTime();
        } catch (Exception e) {
        }
        return -1;
    }

    /**
     *Description: Gets the millisecond value representing the current time
     *
     * @return the first time of day
     */
    public static long getCurrentTimeOfDay() {
        Date date = null;
        try {
            String currentDate = getCurrentDate(dateFormatYMDHMS);
            date = getDateByFormat(currentDate, dateFormatYMDHMS);
            return date.getTime() / 1000;
        } catch (Exception e) {
        }
        return -1;
    }

    /**
     *Description: Gets the number of milliseconds representing the current date at 24:00
     *
     * @return the last time of day
     */
    public static long getLastTimeOfDay() {
        Date date = null;
        try {
            String currentDate = getCurrentDate(dateFormatYMD);
            date = getDateByFormat(currentDate + " 24:00:00", dateFormatYMDHMS);
            return date.getTime();
        } catch (Exception e) {
        }
        return -1;
    }

    /**
     *Description: Determine whether it is a leap year ()
     *<p>(year can be divisible by 4 and cannot be divisible by 100) or year can be divisible by 400, then the year is a leap year
     *
     *@param year (such as 2012)
     *@return boolean Whether it is a leap year
     */
    public static boolean isLeapYear(int year) {
        if ((year % 4 == 0 && year % 400 != 0) || year % 400 == 0) {
            return true;
        } else {
            return false;
        }
    }

    /**
     *Description: Returns a formatted description of the time based on the time
     *Display how many minutes ago if it is less than 1 hour, display today+actual date if it is greater than 1 hour, and display actual time if it is greater than today
     *
     * @param strDate   the str date
     * @param outFormat the out format
     * @return the string
     */
    public static String formatDateStr2Desc(String strDate, String outFormat) {

        DateFormat df = new SimpleDateFormat(dateFormatYMDHMS);
        Calendar c1 = Calendar.getInstance();
        Calendar c2 = Calendar.getInstance();
        try {
            c2.setTime(df.parse(strDate));
            c1.setTime(new Date());
            int d = getOffectDay(c1.getTimeInMillis(), c2.getTimeInMillis());
            if (d == 0) {
                int h = getOffectHour(c1.getTimeInMillis(), c2.getTimeInMillis());
                if (h > 0) {
                    return "今天" + getStringByFormat(strDate, dateFormatHM);
                    //Return h+"Hours ago";
                } else if (h < 0) {
                    //Return Math.abs (h)+"After hours";
                } else if (h == 0) {
                    int m = getOffectMinutes(c1.getTimeInMillis(), c2.getTimeInMillis());
                    if (m > 0) {
                        return m + "分钟前";
                    } else if (m < 0) {
                        //Return Math.abs (m)+"In minutes";
                    } else {
                        return "刚刚";
                    }
                }

            } else if (d > 0) {
                if (d == 1) {
                    //Return "Yesterday"+getStringByFormat (strDate, outFormat);
                } else if (d == 2) {
                    //Return "The day before yesterday"+getStringByFormat (strDate, outFormat);
                }
            } else if (d < 0) {
                if (d == -1) {
                    //Return "Tomorrow"+getStringByFormat (strDate, outFormat);
                } else if (d == -2) {
                    //Return "The day after tomorrow"+getStringByFormat (strDate, outFormat);
                } else {
                    //Return Math.abs (d)+"days later"+getStringByFormat (strDate, outFormat);
                }
            }

            String out = getStringByFormat(strDate, outFormat);
            if (!TextUtils.isEmpty(out)) {
                return out;
            }
        } catch (Exception e) {
        }

        return strDate;
    }


    /**
     *Take the specified date as the day of the week
     *
     *@param strDate Specify a date
     *@param inFormat Specifies the date format
     *@return String Day of the week
     */
    public static String getWeekNumber(String strDate, String inFormat) {
        String week = "星期日";
        Calendar calendar = new GregorianCalendar();
        DateFormat df = new SimpleDateFormat(inFormat);
        try {
            calendar.setTime(df.parse(strDate));
        } catch (Exception e) {
            return "错误";
        }
        int intTemp = calendar.get(Calendar.DAY_OF_WEEK) - 1;
        switch (intTemp) {
            case 0:
                week = "星期日";
                break;
            case 1:
                week = "星期一";
                break;
            case 2:
                week = "星期二";
                break;
            case 3:
                week = "星期三";
                break;
            case 4:
                week = "星期四";
                break;
            case 5:
                week = "星期五";
                break;
            case 6:
                week = "星期六";
                break;
        }
        return week;
    }

    /**
     *Judge whether it is in the morning or afternoon based on the given date
     *
     * @param strDate the str date
     * @param format  the format
     * @return the time quantum
     */
    public static String getTimeQuantum(String strDate, String format) {
        Date mDate = getDateByFormat(strDate, format);
        int hour = mDate.getHours();
        if (hour >= 12)
            return "PM";
        else
            return "AM";
    }

    /**
     *A description of the time calculated from a given number of milliseconds
     *
     * @param milliseconds the milliseconds
     * @return the time description
     */
    public static String getTimeDescription(long milliseconds) {
        if (milliseconds > 1000) {
            //Greater than one point
            if (milliseconds / 1000 / 60 > 1) {
                long minute = milliseconds / 1000 / 60;
                long second = milliseconds / 1000 % 60;
                return minute + "分" + second + "秒";
            } else {
                //Display seconds
                return milliseconds / 1000 + "秒";
            }
        } else {
            return milliseconds + "毫秒";
        }
    }

    public static int getYear() {
        return Calendar.getInstance().get(Calendar.YEAR);
    }

    public static int getMonth() {
        return Calendar.getInstance().get(Calendar.MONTH) + 1;
    }

    public static int getCurrentMonthDay() {
        return Calendar.getInstance().get(Calendar.DAY_OF_MONTH);
    }


    @SuppressWarnings("deprecation")
//    public static int getTwoDay(String strStartDate, String strEndDate) {
//        Calendar mCalendar = Calendar.getInstance();
//        SimpleDateFormat df = new SimpleDateFormat("yyyyMMdd");
//        Date startDate = null;
//        Date endDate = null;
//        try {
//            startDate = df.parse(strStartDate);
//            endDate = df.parse(strEndDate);
//        } catch (ParseException e) {
//Logutil. error ("Illegal date format, unable to convert");
//            e.printStackTrace();
//        }
//        mCalendar.setTime(startDate);
//        int i1 = mCalendar.get(Calendar.DAY_OF_YEAR);
//
//        mCalendar.setTime(endDate);
//        int i2 = mCalendar.get(Calendar.DAY_OF_YEAR);
//
//        int result = i1 - i2;
//        return result;
//    }


    /**
     *Date2 has more days than date1
     *
     * @param strStartDate
     * @param strEndDate
     * @return
     */
    public static int getTwoDay(String strStartDate, String strEndDate) {
        SimpleDateFormat df = new SimpleDateFormat("yyyyMMdd");
        Date startDate = null;
        Date endDate = null;
        try {
            startDate = df.parse(strStartDate);
            endDate = df.parse(strEndDate);
        } catch (ParseException e) {
            e.printStackTrace();
        }

        Calendar cal1 = Calendar.getInstance();
        cal1.setTime(endDate);

        Calendar cal2 = Calendar.getInstance();
        cal2.setTime(startDate);
        int day1 = cal1.get(Calendar.DAY_OF_YEAR);
        int day2 = cal2.get(Calendar.DAY_OF_YEAR);

        int year1 = cal1.get(Calendar.YEAR);
        int year2 = cal2.get(Calendar.YEAR);
        if (year1 != year2)   //Same year
        {
            int timeDistance = 0;
            for (int i = year1; i < year2; i++) {
                if (i % 4 == 0 && i % 100 != 0 || i % 400 == 0)    //Leap year
                {
                    timeDistance += 366;
                } else    //Not a leap year
                {
                    timeDistance += 365;
                }
            }
            return timeDistance + (day2 - day1);
        } else    //Different years
        {
            System.out.println("判断day2 - day1 : " + (day2 - day1));
            return day2 - day1;
        }
    }

    /**
     *Convert Beijing time zone time to the selected time zone time
     *
     * @param timezone
     * @param strDate
     * @param formatType
     * @return
     */
    public static String BeiJ2TimeZoneConver(String timezone, String strDate, String formatType) {
        SimpleDateFormat mSimpleDateFormat = new SimpleDateFormat(formatType);
        Date Date_buff = null;
        try {
            Date_buff = mSimpleDateFormat.parse(strDate);
            mSimpleDateFormat.setTimeZone(TimeZone.getTimeZone(timezone));
            return mSimpleDateFormat.format(Date_buff);
        } catch (ParseException e) {
            e.printStackTrace();
            return mSimpleDateFormat.format("");
        }
    }

    static String[] times = new String[]{"9:00 AM", "9:30 AM", "10:00 AM", "10:30 AM", "11:00 AM", "11:30 AM", "02:00 PM", "02:30 PM", "03:00 PM", "03:30 PM", "04:00 PM", "04:30 PM", "05:00 PM"};

    public static void main(String[] args) {
        String str = "2018-09-01 11:36:00";
//        getBeiJTimeAndTimeZoneTime(times, "2018-08-31");
//        System.out.println(BeiJ2TimeZoneConver("America/New_York", str, "yyyy-MM-dd HH:mm"));
        System.out.println(TimeConverAmPm(str, "yyyy-MM-dd HH:mm:ss"));
    }



    /**
     * @param strdate 23:06
     * @return
     */
    public static String TimeConver12(String strdate) {
        String[] hhmm = strdate.split(":");
        int hh = Integer.parseInt(strdate.split(":")[0]);
        String mm = strdate.split(":")[1];
        if (hh <= 11) {
            return String.format("%02d", hh) + ":" + mm + " " + "AM";
        } else {
            return String.format("%02d", (24 - hh)) + ":" + mm + " " + "PM";
        }


    }

    //yyyy-MM-dd KK:mm aa
    public static String TimeConverAmPm(String strdate, String format) {
        SimpleDateFormat aa = new SimpleDateFormat("KK:mm aa", Locale.ENGLISH);
        String time = aa.format(getDateByFormat(strdate, format));
        return time;
    }

    /**
     *Compare two time sizes
     *
     * @param startDate
     * @param endDate
     * @param format
     *@return true The start time is greater than the end time False The reverse is true
     */
    public static boolean compareDate(String startDate, String endDate, String format) {
        DateFormat df = new SimpleDateFormat(format);
        try {
            Date dt1 = df.parse(startDate);
            Date dt2 = df.parse(endDate);
            if (dt1.getTime() > dt2.getTime()) {
//System. out. println ("dt1 before dt2");
                return true;
            } else if (dt1.getTime() < dt2.getTime()) {
//System. out. println ("dt1 after dt2");
                return false;
            } else {
                return false;
            }
        } catch (Exception exception) {
            exception.printStackTrace();
        }
        return false;
    }

}
