package com.chainup.contract.utils;

import android.content.Context;
import android.os.Build;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;

import com.chainup.contract.view.CpSnackLayout;

public class CpDisplayUtils {

    public static int[] getWidthHeight(Context context) {
        WindowManager wm = (WindowManager) context
                .getSystemService(Context.WINDOW_SERVICE);

        int width = wm.getDefaultDisplay().getWidth();
        int height = wm.getDefaultDisplay().getHeight();

        return new int[]{width, height};
    }

    public static int dip2px(Context context, float dipValue) {
        final float scale = context.getResources().getDisplayMetrics().density;
        return (int) (dipValue * scale + 0.5f);
    }

    public static int px2dip(Context context, float pxValue) {
        final float scale = context.getResources().getDisplayMetrics().density;
        return (int) (pxValue / scale + 0.5f);
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

    public static void showSnackBar(View mView, String  text,  Boolean isSuc) {
        CpSnackLayout.showSnackBar(mView, text, isSuc,null);
    }

    /**
     *Get Status Bar Height
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
    public static void requestDisplayBar(Window window,OnResponseDisplayBar displayBar){
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
