package com.chainup.contract.utils;

import android.widget.TextView;

public class CpChainUtil {


    /*
     *Home page asset data display and hiding control
     */
    public static void assetsHideShow(boolean isShow, TextView textView, String content) {
        if (isShow) {
            if (CpStringUtil.checkStr(content)) {
                textView.setText(content + "");
            } else {
                textView.setText("0");
            }
        } else {
            textView.setText("*****");
        }
    }

    /**
     *Used to determine whether to click quickly
     *
     * @return
     */
    private static final int FAST_CLICK_DELAY_TIME = 1000;
    private static long lastClickTime;


    public synchronized static boolean isFastClick() {
        boolean flag = false;
        long currentClickTime = System.currentTimeMillis();
        if ((currentClickTime - lastClickTime) <= FAST_CLICK_DELAY_TIME) {
            return true;
        }
        lastClickTime = currentClickTime;
        return flag;
    }

}
