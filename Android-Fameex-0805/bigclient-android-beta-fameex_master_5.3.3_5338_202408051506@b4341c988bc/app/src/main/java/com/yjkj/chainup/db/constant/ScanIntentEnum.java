package com.yjkj.chainup.db.constant;

public enum ScanIntentEnum {
    LOGIN(0,"用于扫码登录"),
    ADDRESS_ADD(1,"地址扫描");


    private String msg;
    private int value;
    ScanIntentEnum(int value,String msg){
        this.msg = msg;
        this.value = value;
    }

    public int getValue() {
        return value;
    }

    public String getMsg() {
        return msg;
    }
}

