package com.chainup.kit.utils;

import android.content.Context;
import android.os.Build;
import android.view.Window;

public class PublicSizeUtil {
    /**
     * Value of dp to value of px.
     *
     * @param dpValue The value of dp.
     * @return value of px
     */
    public static int dp2px(Context context,final float dpValue) {
        final float scale = context.getResources().getDisplayMetrics().density;
        return (int) (dpValue * scale + 0.5f);
    }

    /**
     * Value of px to value of dp.
     *
     * @param pxValue The value of px.
     * @return value of dp
     */
    public static int px2dp(Context context,final float pxValue) {
        final float scale = context.getResources().getDisplayMetrics().density;
        return (int) (pxValue / scale + 0.5f);
    }

    public static float sp2px(Context context,float sp) {
        float scaledDensity = context.getResources().getSystem().getDisplayMetrics().scaledDensity;
        return sp * scaledDensity + 0.5f;
    }

    /**
     *@return Screen width
     */
    public static int getScreenWidth(Context context) {
        return context.getResources().getDisplayMetrics().widthPixels;
    }

    /**
     *@return Screen height
     */
    public static int getScreenHeight(Context context){
        return context.getResources().getDisplayMetrics().heightPixels;

    }


    /**
     *Obtain status bar height
     *
     * @param context context
     *@return Status bar height
     */
    public static int getStatusBarHeight(Context context) {
        //Obtain status bar height
        int resourceId = context.getResources().getIdentifier("status_bar_height", "dimen", "android");
        return context.getResources().getDimensionPixelSize(resourceId);
    }

    public static int getNavigationBarHeight(Context context) {
        int result = 0;
        int resourceId = context.getResources().getIdentifier("navigation_bar_height", "dimen", "android");
        if (resourceId > 0) {
            result = context.getResources().getDimensionPixelSize(resourceId);
        }
        return result;
    }

    //You can obtain the height of the status bar navigation bar
    public static void requestDisplayBar(Window window, OnResponseDisplayBar displayBar){
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            window.getDecorView().setOnApplyWindowInsetsListener((v, insets) -> {
                int navigationBarHeight = insets.getStableInsetBottom();
                int statusBarHeight = insets.getStableInsetTop();
                displayBar.doSomeThing(statusBarHeight,navigationBarHeight);
                return insets;
            });
        }else{
            displayBar.doSomeThing(getStatusBarHeight(window.getContext()),getNavigationBarHeight(window.getContext()));
        }
    }

    public interface OnResponseDisplayBar{
        void doSomeThing(int statusBar,int navigationBar);
    }

}
