package com.chainup.contract.utils;

import android.view.View;


public final class CpClickUtil {

    /**
     *Last click time
     */
    private static long mLastClickTime;
    /**
     *Last clicked control ID
     */
    private static int mLastClickViewId;

    /**
     *Is it a quick click
     *
     *@return true: Yes, false: No
     */
    public static boolean isFastDoubleClick() {
        long intervalMillis=1500;
        long time = System.currentTimeMillis();
        long timeInterval = Math.abs(time - mLastClickTime);
        if (timeInterval < intervalMillis ) {
            return true;
        } else {
            mLastClickTime = time;
            return false;
        }
    }
}
