package com.yjkj.chainup.util;

import android.app.ActivityManager;
import android.content.Context;
import android.content.pm.PackageManager;
import android.os.Process;

import java.util.List;

public class SystemUtil {

    /**
     *Get all processes of the current app
     */
    public List<ActivityManager.RunningAppProcessInfo> getRunningAppProcessInfos(Context context) {
        ActivityManager am = (ActivityManager) context.getSystemService(Context.ACTIVITY_SERVICE);
        return am.getRunningAppProcesses();
    }

    /**
     *Judge whether the Process identifier belongs to the process name
     *
     * @param context
     *@param pid Process identifier
     *@param p_ Name Process name
     *@return true belongs to the process name
     */
    public boolean isPidOfProcessName(Context context, int pid, String p_name) {
        if (p_name == null)
            return false;
        boolean isMain = false;
        ActivityManager am = (ActivityManager) context.getSystemService(Context.ACTIVITY_SERVICE);
        //Traverse all processes
        for (ActivityManager.RunningAppProcessInfo process : am.getRunningAppProcesses()) {
            if (process.pid == pid) {
                //When the Process identifier is the same, judge whether the process name is the same
                if (process.processName.equals(p_name)) {
                    isMain = true;
                }
                break;
            }
        }
        return isMain;
    }

    /**
     *Obtain the name of the main process
     *
     *@param context context
     *@return Main process name
     */
    public String getMainProcessName(Context context) throws PackageManager.NameNotFoundException {
        return context.getPackageManager().getApplicationInfo(context.getPackageName(), 0).processName;
    }

    /**
     *Determine whether it is the main process
     *
     *@param context context
     *@return true is the main process
     */
    public boolean isMainProcess(Context context) throws PackageManager.NameNotFoundException {
        return isPidOfProcessName(context, Process.myPid(), getMainProcessName(context));
    }

    public boolean isMainProcessFun(Context context) {
        try {
           return  isMainProcess(context);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return true;
    }


}
