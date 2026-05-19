package com.chainup.kit.dialog.security;

import android.content.Context;

import androidx.annotation.StringRes;

import com.example.chainup_kit.R;

public enum KKSecurityEnum {
    EMAIL(R.string.security_email,"邮箱验证"),
    PHONE(R.string.security_phone,"手机验证"),
    GA(R.string.security_google,"Google验证"),
    LOGINPWD(R.string.security_login_pwd,"登录密码验证"),
    CAPITALPWD(R.string.security_capital_pwd,"资金密码验证");

    @StringRes
    final int flag;
    final String decription;
    KKSecurityEnum(int flag,String decription) {
        this.flag = flag;
        this.decription = decription;
    }

    public String getDecription() {
        return decription;
    }

    public String getFlag(Context context) {
        return context.getString(flag);
    }
}
