package com.yjkj.chainup.wedegit.DataPickView;

import com.yjkj.chainup.util.Utils;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Calendar;
import java.util.Date;

/**
 * Created by codbking on 2016/8/10.
 */
class DatePickerHelper {

    //Starting year
    private int YEAR_START;
    //Starting Month
    private int MONTH_START;
    //Starting day
    private int DAY_START;
    //Start Week
    private int WEEK_START;
    //Starting hours
    private int HOUR_START;
    //Start minute
    private int MINUTE_START;
    //Start time
    private Date startDate = new Date();
    //Year limit, upper and lower 5 years
    private int yearLimt = 5;

    private Date beginTime,endTime;
    private int selectType;


    private ArrayList<Integer> tem = new ArrayList<>();
    private ArrayList<String> dispalyTem = new ArrayList<>();
    private String[] weeks = {"星期日", "星期一", "星期二", "星期三", "星期四", "星期五", "星期六"};


    public enum Type {
        YEAR,
        MOTH,
        DAY,
        WEEK,
        HOUR,
        MINUTE
    }

    public DatePickerHelper(Date beginTime,Date endTime,int selectType){
        this.beginTime = beginTime;
        this.endTime = endTime;
        this.selectType = selectType;
        init();
    }
    public DatePickerHelper(int selectType){
        this.selectType = selectType;
        init();
    }

    public DatePickerHelper(){
        init();
    }

    private void init(){
        Date date=startDate;
        //Obtain the time of year, month, day, and hour
        YEAR_START = Utils.getYear(date);
        MONTH_START = Utils.getMoth(date);
        DAY_START = Utils.getDay(date);
        WEEK_START = Utils.getWeek(date);
        HOUR_START = Utils.getHour(date);
        MINUTE_START = Utils.getMinute(date);
    }


    //Set initialization time
    public void setStartDate(Date date, int yearLimt) {

        this.startDate = date;
        this.yearLimt = yearLimt;

        if (this.startDate == null) {
            this.startDate = new Date();
        }
        init();
    }

    public int getToady(Type type) {
        switch (type) {
            case YEAR:
                return YEAR_START;
            case MOTH:
                return MONTH_START;
            case DAY:
                return DAY_START;
            case WEEK:
                return WEEK_START;
            case HOUR:
                return HOUR_START;
            case MINUTE:
                return MINUTE_START;
        }
        return 0;
    }

    public String[] getDisplayValue(Integer[] arr, String per) {
        dispalyTem.clear();
        for (Integer i : arr) {
            String value = i < 10 ? ("0" + i) : "" + i;
            dispalyTem.add(value + per);
        }
        return dispalyTem.toArray(new String[0]);
    }

    public Integer[] genMonth() {
        return new Integer[]{1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12};
    }

    public Integer[] genHour() {
        return genArr(24, true);
    }

    public Integer[] genMinut() {
        return genArr(60, true);
    }

    public Integer[] genArr(int size, boolean isZero) {
        tem.clear();
        for (int i = isZero ? 0 : 1; i < (isZero ? size : size + 1); i++) {
            tem.add(i);
        }
        return tem.toArray(new Integer[0]);
    }

    //Born into adulthood
    public Integer[] genYear() {
        tem.clear();
        for (int i = YEAR_START - yearLimt; i < YEAR_START; i++) {
            tem.add(i);
        }
        tem.add(YEAR_START);

        for (int i = YEAR_START + 1; i < YEAR_START + yearLimt; i++) {
            tem.add(i);
        }
        return tem.toArray(new Integer[0]);
    }


    public  Integer[] genDay(int year,int moth) {
        Calendar calendar = Calendar.getInstance();
        calendar.set(year,moth,1);
        calendar.add(Calendar.DATE, -1);
        int day = Integer.parseInt(new SimpleDateFormat("d").format(calendar.getTime()));
        return genArr(day, false);
    }

    public  Integer[] genDay() {
       return genDay(YEAR_START,MONTH_START);
    }


    public Integer[] getYearDataAry(){
        int dateVal;
        if(selectType==0){
            //Select Start
            if(endTime!=null){
                //Statistical year
                dateVal = Utils.getYear(endTime);
                tem.clear();
                for (int i = dateVal - yearLimt; i < dateVal; i++) {
                    tem.add(i);
                }
                tem.add(dateVal);

                return tem.toArray(new Integer[0]);
            }
        }else if(selectType==1){
            //Select End
            if(beginTime!=null){
                //Statistical year
                dateVal = Utils.getYear(beginTime);
                tem.clear();
                tem.add(dateVal);
                for (int i = dateVal + 1; i < dateVal + yearLimt; i++) {
                    tem.add(i);
                }
                return tem.toArray(new Integer[0]);
            }
        }
        return genYear();
    }

    public Integer[] getMothDataAry(){
        return genMonth();
    }

    public Integer[] getDayDataAry(){
        return genDay();
    }


    public int findIndextByValue(int value, Integer[] arr) {
        for (int i = 0; i < arr.length; i++) {
            if (value == arr[i]) {
                return i;
            }
        }
        return -1;
    }

    public String getDisplayWeek(int year, int moth, int day) {
        return weeks[ Utils.getWeek(year,moth,day) - 1];
    }

    public String getDisplayStartWeek(){
          return getDisplayWeek(YEAR_START,MONTH_START,DAY_START);
    }




}
