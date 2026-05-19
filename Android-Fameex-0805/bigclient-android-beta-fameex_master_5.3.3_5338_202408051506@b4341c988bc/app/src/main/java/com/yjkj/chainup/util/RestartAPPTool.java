package com.yjkj.chainup.util;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.app.ActivityManager;
import android.app.AlarmManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;

import com.yjkj.chainup.new_version.activity.SplashActivity;


public class RestartAPPTool {
//
//    /**
//     *Restart the entire app
//     *
//     * @param context the context
//     *Param Delayed How many milliseconds is the delay
//     */
//    public static void restartAPP(Context context, long Delayed){
//
//        /**Start a new service to restart this app*/
//        Intent intent1=new Intent(context,killSelfService.class);
//        intent1.putExtra("PackageName",context.getPackageName());
//        intent1.putExtra("Delayed",Delayed);
//        intent1.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK|Intent.FLAG_ACTIVITY_CLEAR_TASK);
//        context.startService(intent1);
//
//        /**Kill the entire process**/
//        android.os.Process.killProcess(android.os.Process.myPid());
//        System.exit(0);
//    }

    /***Restart the entire app @param context the context*/
    public static void restartAPP(Context context){
        /*  restartAPP(context,1);*/
        Intent intent = new Intent(context, SplashActivity.class);
        @SuppressLint("WrongConstant") PendingIntent restartIntent = PendingIntent.getActivity(context, 0, intent,
                Intent.FLAG_ACTIVITY_NEW_TASK);
        //Exit program
        AlarmManager mgr = (AlarmManager)context.getSystemService(Context.ALARM_SERVICE);
        assert mgr != null;
        mgr.set(AlarmManager.RTC, System.currentTimeMillis() + 500,
                restartIntent);
        //Exit program
        android.os.Process.killProcess(android.os.Process.myPid());
        System.exit(1);
    }
}
