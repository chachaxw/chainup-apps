package com.yjkj.chainup.app;

import android.app.Application;
import android.content.Context;

/**
 * @author：admin on 2017/4/15 15:26.
 *
 */

public class GlobalAppComponent {

    public static boolean hasEnterLogin = false;//Mark whether you have entered the login page
    public static boolean isAutoForwardLogin = true;//Mark whether you have entered the login page


    /**
     *Initialize Global AppComponent
     * @param context applicationContext
     */
    private static Application mContext;
    public static void init(Application context){
        mContext = context;
    }

    public static Context getContext(){
        return mContext;
    }

}
