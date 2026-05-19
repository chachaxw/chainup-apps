package com.yjkj.chainup.wedegit.DataPickView.bean;

/**
 * Created by wulang on 2016/9/22.
 */

public enum DateType {

    TYPE_ALL("yyyy-MM-dd E hh:mm"),//Year, month, day, week, hour, minute
    TYPE_YMDHM("yyyy-MM-dd hh:mm"),//Year, month, day, hour, minute
    TYPE_YMDH("yyyy-MM-dd hh"),//Year, month, day, hour
    TYPE_YMD("yyyy-MM-dd"),//Year, month, day
    TYPE_HM("hh:mm");//Hour and minute

    private String format;

    DateType(String format) {
        this.format = format;
    }

    public String getFormat() {
        return format;
    }
    
}
