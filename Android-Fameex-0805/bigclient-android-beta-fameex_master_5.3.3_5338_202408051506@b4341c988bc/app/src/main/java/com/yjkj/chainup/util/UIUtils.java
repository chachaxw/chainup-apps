package com.yjkj.chainup.util;


import android.app.Activity;
import android.content.Context;
import android.os.Build;
import androidx.annotation.RequiresApi;
import android.view.View;
import android.view.WindowManager;

import static com.yjkj.chainup.app.ChainUpApp.appContext;


public class UIUtils {


    public static void showToast(String msg) {
        ToastUtils.showToast(appContext, msg);
    }


    //Obtain status bar height
    public static int getStatusBarHeight(Context context) {
        int result = 0;
        int resourceId = context.getResources().getIdentifier("status_bar_height", "dimen", "android");
        if (resourceId > 0) {
            result = context.getResources().getDimensionPixelSize(resourceId);
        }
        return result;
    }

    //Immersive Status Bar
    public static void translucentBar(Activity activity, int statusColor) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT &&
                Build.VERSION.SDK_INT < Build.VERSION_CODES.LOLLIPOP) {
            WindowManager.LayoutParams localLayoutParams = activity.getWindow().getAttributes();
            //Set the status bar to be transparent and the activity to be displayed in full screen
            localLayoutParams.flags = (WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS | localLayoutParams.flags);
        } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            activity.getWindow().getDecorView().setSystemUiVisibility(
                    //SYSTEM_ UI_ FLAG_ LAYOUT_ FULLSCREEN: The activity is displayed in full screen, but the status bar will not be hidden or overwritten. The status bar will still be visible, and the top layout of the activity will be covered by the status.
                    View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN |
                            //SYSTEM_ UI_ FLAG_ LAYOUT_ TABLE: Prevent changes in the size of the content area when the system bar is hidden
                            View.SYSTEM_UI_FLAG_LAYOUT_STABLE);
            setStatusBarColor(activity, statusColor);
        }
    }


    @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
    public static void setStatusBarColor(Activity activity, int statusColor) {
        activity.getWindow().setStatusBarColor(statusColor);
    }

    //Set virtual button transparency
    public static void translucentNavigation(Activity activity) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT &&
                Build.VERSION.SDK_INT < Build.VERSION_CODES.LOLLIPOP) {
            WindowManager.LayoutParams localLayoutParams = activity.getWindow().getAttributes();
            localLayoutParams.flags = (WindowManager.LayoutParams.FLAG_TRANSLUCENT_NAVIGATION | localLayoutParams.flags);
        }
    }


    //Show or hide the status bar
    public static void isShowStatusBar(Activity activity, boolean show) {
//It is best to use corresponding display and hide methods. These methods are used in different versions and periods, and their priority may vary. Using them incorrectly may not have any effect
        if (show) {
//If it is a dynamic and frequent operation of the status bar, it is recommended to use method 1, SYSTEM_ UI_ FLAG_ LAYOUT_ The TABLE tag can prevent changes in the size of the content area from causing image shaking
            activity.getWindow().getDecorView().setSystemUiVisibility(View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN |
                    View.SYSTEM_UI_FLAG_LAYOUT_STABLE);
//Method 2
//            WindowManager.LayoutParams attr = activity.getWindow().getAttributes();
//            attr.flags &= (~WindowManager.LayoutParams.FLAG_FULLSCREEN);
//            activity.getWindow().setAttributes(attr);
            //If the following sentence is not annotated, the status bar will push the interface down
            /*getWindow().clearFlags(
                    WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS);*/
//Method 3
            //The following methods can also achieve the effect of displaying the status bar, but excessive use is not very natural
//            activity.getWindow().setFlags(WindowManager.LayoutParams.FLAG_FORCE_NOT_FULLSCREEN,
//                    WindowManager.LayoutParams.FLAG_FORCE_NOT_FULLSCREEN);
        } else {
            activity.getWindow().getDecorView().setSystemUiVisibility(View.SYSTEM_UI_FLAG_LAYOUT_STABLE
                    | View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
                    | View.SYSTEM_UI_FLAG_FULLSCREEN
                    //This attribute can achieve an immersive status bar. Clicking on the status bar will automatically disappear after a period of time, and is commonly used in videos and games
                    | View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY);
//Method 2: This method will also make the virtual buttons transparent
//            WindowManager.LayoutParams lp = activity.getWindow().getAttributes();
////Hide status bar
//            lp.flags |= WindowManager.LayoutParams.FLAG_FULLSCREEN;
//            activity.getWindow().setAttributes(lp);
//            activity.getWindow().addFlags(
//                    WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS);

            //Method 3
            //The following methods can also achieve the effect of displaying the status bar, but excessive use is not very natural
//            activity.getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN,
//                    WindowManager.LayoutParams.FLAG_FULLSCREEN);
        }
    }

    /*
      **
      *Modify the NavigationBar button color
      *@params type 0//Black 1//White
    */
    public static void setLightNavigationBar (Activity activity,int type) {
        int vis = activity.getWindow().getDecorView().getSystemUiVisibility();
        if(type==0){
            vis |= View.SYSTEM_UI_FLAG_LIGHT_NAVIGATION_BAR;  //Black
        }else{
            vis &= ~ View.SYSTEM_UI_FLAG_LIGHT_NAVIGATION_BAR; //White
        }
        activity.getWindow().getDecorView().setSystemUiVisibility(vis);
    }


    //Obtain the height of the bottom system navigation bar
    public static int getNavigationBarHeight(Context context) {
        int resourceId=0;
        int rid = context.getResources().getIdentifier("config_showNavigationBar", "bool", "android");
        if (rid!=0){
            resourceId = context.getResources().getIdentifier("navigation_bar_height", "dimen", "android");
            return context.getResources().getDimensionPixelSize(resourceId);
        }else
            return 0;
    }

}
