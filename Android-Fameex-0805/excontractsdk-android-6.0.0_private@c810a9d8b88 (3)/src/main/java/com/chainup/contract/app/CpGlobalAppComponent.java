package com.chainup.contract.app;

import android.app.Application;
import android.content.Context;

/**
 * @author：admin on 2017/4/15 15:26.
 *
 */

public class CpGlobalAppComponent {

    public static boolean hasEnterLogin = false;//markWhetherYouHaveEnteredTheLoginPage
    public static boolean isAutoForwardLogin = true;//markWhetherYouHaveEnteredTheLoginPage


    /**
     * initializeGlobalAppComponent
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
