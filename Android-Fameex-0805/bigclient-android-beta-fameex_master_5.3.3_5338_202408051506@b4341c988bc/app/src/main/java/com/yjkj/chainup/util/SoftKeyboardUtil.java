package com.yjkj.chainup.util;

import android.annotation.TargetApi;
import android.app.Activity;
import android.content.Context;
import android.graphics.Rect;
import android.os.Build;
import android.os.IBinder;
import android.util.DisplayMetrics;
import android.view.View;
import android.view.inputmethod.InputMethodManager;
import android.widget.TextView;

/**
 * @Author lianshangljl
 * @Date 2023/6/1-9:20 AM
 * @Email buptjinlong@163.com
 * @description
 */
public class SoftKeyboardUtil {
    /**
     *Hide or Show Soft Keyboard
     *If it is now displayed after calling, hide it; otherwise, display it
     *
     * @param activity
     */
    public static void showORhideSoftKeyboard(Activity activity) {
        InputMethodManager imm = (InputMethodManager) activity.getSystemService(Context.INPUT_METHOD_SERVICE);
        imm.toggleSoftInput(0, InputMethodManager.HIDE_NOT_ALWAYS);
    }

    /**
     *Force Hide Soft Keyboard
     *
     * @param view
     */
    public static void hideSoftKeyboard(View view) {

        if(null==view || !(view instanceof TextView)){
            return;
        }

        IBinder binder = view.getWindowToken();
        if(null==binder)
            return;

        InputMethodManager imm = (InputMethodManager) view.getContext().getSystemService(Context.INPUT_METHOD_SERVICE);
        imm.hideSoftInputFromWindow(binder, 0); //Force Hide Keyboard

    }

    /**
     *Method of determining whether the soft keyboard is displayed
     *
     * @param activity
     * @return
     */

    public static boolean isSoftShowing(Activity activity) {
        //Obtain the height of the current screen content
        int screenHeight = activity.getWindow().getDecorView().getHeight();
        //Obtain the bottom of the visible area of the View
        Rect rect = new Rect();
        //DecorView is the top-level view of the activity
        activity.getWindow().getDecorView().getWindowVisibleDisplayFrame(rect);
        //Considering the situation of virtual navigation bar (in the case of virtual navigation bar: screenHeight=rect. bottom+virtual navigation bar height)
        //Select screenHeight * 2/3 judgment
        return screenHeight * 2 / 3 > rect.bottom + getSoftButtonsBarHeight(activity);
    }

    /**
     *The height of the bottom virtual key bar
     *
     * @return
     */
    @TargetApi(Build.VERSION_CODES.JELLY_BEAN_MR1)
    private static int getSoftButtonsBarHeight(Activity activity) {
        DisplayMetrics metrics = new DisplayMetrics();
        //This method may not obtain the height of the real screen
        activity.getWindowManager().getDefaultDisplay().getMetrics(metrics);
        int usableHeight = metrics.heightPixels;
        //Obtain the true height of the current screen
        activity.getWindowManager().getDefaultDisplay().getRealMetrics(metrics);
        int realHeight = metrics.heightPixels;
        if (realHeight > usableHeight) {
            return realHeight - usableHeight;
        } else {
            return 0;
        }
    }
}

