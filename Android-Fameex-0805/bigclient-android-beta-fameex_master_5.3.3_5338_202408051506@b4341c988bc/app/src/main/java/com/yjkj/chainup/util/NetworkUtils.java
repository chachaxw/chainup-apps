package com.yjkj.chainup.util;


import android.content.Context;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;

import com.yjkj.chainup.app.GlobalAppComponent;

public class NetworkUtils {

    /**
     *Check if there is a network
     */
    public static boolean isNetworkAvailable(Context context) {
        if (context == null) return false;
        NetworkInfo info = getNetworkInfo(context);
        return info != null && info.isAvailable();
    }


    /**
     *Check if it is WIFI
     */
    public static boolean isWifi(Context context) {
        NetworkInfo info = getNetworkInfo(context);
        if (info != null) {
            return info.getType() == ConnectivityManager.TYPE_WIFI;
        }
        return false;
    }


    /**
     *Check if it is a mobile network
     */
    public static boolean isMobile(Context context) {
        NetworkInfo info = getNetworkInfo(context);
        if (info != null) {
            return info.getType() == ConnectivityManager.TYPE_MOBILE;
        }
        return false;
    }


    private static NetworkInfo getNetworkInfo(Context context) {
        ConnectivityManager cm = (ConnectivityManager) context.getSystemService(Context.CONNECTIVITY_SERVICE);
        return cm.getActiveNetworkInfo();
    }


    public static String getNetType() {
        Context context = GlobalAppComponent.getContext();
        if (isMobile(context)) return "4G";
        if (isWifi(context)) return "wifi";
        return "";
    }


}
