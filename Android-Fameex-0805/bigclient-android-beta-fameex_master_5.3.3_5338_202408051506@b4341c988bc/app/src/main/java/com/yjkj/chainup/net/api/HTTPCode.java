package com.yjkj.chainup.net.api;

public enum HTTPCode {
    VERIFY_CODE_ERROR(10022,"验证码错误"),
    PleaseDealnameVerify(10033, "请先进行实名认证");

    public final Integer code;
    public final String message;

    HTTPCode(Integer code,String message) {
        this.code = code;
        this.message = message;
    }

}
