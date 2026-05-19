package com.yjkj.chainup.bean;

/**
 * Created by Bertking on 2018/7/14.
 * <p>
 *This class mainly stores the information required for login and is used for gesture login
 */
public class LoginInfo {
    private String mobile = "";
    private String mobilePwd = "";

    private String email = "";
    private String emailPwd = "";

    private String handPwd = "";


    /**
     *Since login no longer distinguishes between email and phone
     *May not require differentiation
     */
    private String account = "";
    private String loginPwd = "";


    public String getMobile() {
        return mobile;
    }

    public void setMobile(String mobile) {
        this.mobile = mobile;
    }

    public String getMobilePwd() {
        return mobilePwd;
    }

    public void setMobilePwd(String mobilePwd) {
        this.mobilePwd = mobilePwd;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getEmailPwd() {
        return emailPwd;
    }

    public void setEmailPwd(String emailPwd) {
        this.emailPwd = emailPwd;
    }

    public String getHandPwd() {
        return handPwd;
    }

    public void setHandPwd(String handPwd) {
        this.handPwd = handPwd;
    }

    public String getAccount() {
        return account;
    }

    public void setAccount(String account) {
        this.account = account;
    }

    public String getLoginPwd() {
        return loginPwd;
    }

    public void setLoginPwd(String loginPwd) {
        this.loginPwd = loginPwd;
    }

    @Override
    public String toString() {
        return "LoginInfo{" +
                "mobile='" + mobile + '\'' +
                ", mobilePwd='" + mobilePwd + '\'' +
                ", email='" + email + '\'' +
                ", emailPwd='" + emailPwd + '\'' +
                ", handPwd='" + handPwd + '\'' +
                ", account='" + account + '\'' +
                ", loginPwd='" + loginPwd + '\'' +
                '}';
    }
}
