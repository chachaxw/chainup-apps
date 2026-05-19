package com.yjkj.chainup.util;


import android.text.TextUtils;
import android.util.Log;

import com.yjkj.chainup.app.AppConfig;

//Logging tool
public class LogUtil {

    public static void v(String tag, String msg) {
        if (AppConfig.IS_DEBUG) {
            Log.v(tag, msg);
        }
    }

    public static void d(String tag, String msg) {
        if (AppConfig.IS_DEBUG) {
            if(!TextUtils.isEmpty(msg) && msg.length() > 1024){

            }else {

            }
        }
    }

    public static void i(String tag, String msg) {
        if (AppConfig.IS_DEBUG) {
            Log.i(tag, msg);
        }
    }

    public static void w(String tag, String msg) {
        if (AppConfig.IS_DEBUG) {
            Log.i(tag, msg);
        }
    }

    public static void e(String tag, String msg) {
        if (AppConfig.IS_DEBUG) {
            
        }
    }
}
