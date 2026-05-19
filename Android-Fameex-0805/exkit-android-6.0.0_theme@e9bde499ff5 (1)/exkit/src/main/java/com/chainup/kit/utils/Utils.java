package com.chainup.kit.utils;

public class Utils {

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
