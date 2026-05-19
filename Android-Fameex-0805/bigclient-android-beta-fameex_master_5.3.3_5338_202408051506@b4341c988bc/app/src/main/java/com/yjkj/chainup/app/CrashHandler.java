package com.yjkj.chainup.app;

import android.app.AlarmManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;

import com.yjkj.chainup.new_version.activity.NewMainActivity;
import com.yjkj.chainup.util.ToastUtils;

/**
 * Created by Bertking on 2018/7/14.
 */
public class CrashHandler implements Thread.UncaughtExceptionHandler {
    public static final String TAG = CrashHandler.class.getSimpleName();

    private static volatile CrashHandler instance = null;

    private Context mContext;

    /**
     *The system default UncaughtException processing class
     */
    private Thread.UncaughtExceptionHandler mDefaultHandler;


    private CrashHandler() {

    }


    public static CrashHandler getInstance() {
        if (instance == null) {
            instance = new CrashHandler();
        }
        return instance;
    }

    /**
     *Initialize
     *
     * @param context
     */
    public void init(Context context) {
        mContext = context;

        //Obtain the system's default UncaughtException processor
        mDefaultHandler = Thread.getDefaultUncaughtExceptionHandler();

        //Set this CrashHandler as the default processor for the program
        Thread.setDefaultUncaughtExceptionHandler(this);
    }

    /**
     *When UncaughtException occurs, it will be transferred to this function for processing
     */
    @Override
    public void uncaughtException(Thread t, Throwable e) {
        //Delay 2 seconds to kill process
        try {
            Thread.sleep(2000);
            ToastUtils.showToast("程序出错了~");
        } catch (InterruptedException e1) {
            e1.printStackTrace();
        }

        //Exit program
        android.os.Process.killProcess(android.os.Process.myPid());
        System.exit(0);

        Intent intent = new Intent(mContext, NewMainActivity.class);
        PendingIntent restartIntent = PendingIntent.getActivity(mContext, 0, intent, Intent.FLAG_ACTIVITY_NEW_TASK);
        //Exit program
        AlarmManager mgr = (AlarmManager) mContext.getSystemService(Context.ALARM_SERVICE);
        mgr.set(AlarmManager.RTC, System.currentTimeMillis() + 1000,
                restartIntent); //Restart the application in 1 second


    }

}
