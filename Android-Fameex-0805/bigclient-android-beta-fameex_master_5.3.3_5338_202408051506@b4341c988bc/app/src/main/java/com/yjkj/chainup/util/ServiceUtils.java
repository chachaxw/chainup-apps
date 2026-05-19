package com.yjkj.chainup.util;

import android.app.ActivityManager;
import android.content.Context;

import java.util.ArrayList;

/**
 * @Author lianshangljl
 *@ Date 2018/10/18-3:59 PM
 * @Email buptjinlong@163.com
 * @description
 */
public class ServiceUtils {
    /**
     *Determine whether the service is enabled
     *
     * @return
     */
    public static boolean isServiceRunning(Context context, String ServiceName) {
        if (!StringUtil.checkStr(ServiceName))
            return false;
        ActivityManager myManager = (ActivityManager) context
                .getSystemService(Context.ACTIVITY_SERVICE);
        ArrayList<ActivityManager.RunningServiceInfo> runningService = (ArrayList<ActivityManager.RunningServiceInfo>) myManager
                .getRunningServices(30);
        for (int i = 0; i < runningService.size(); i++) {
            if (runningService.get(i).service.getClassName()
                    .equals(ServiceName)) {
                return true;
            }
        }
        return false;
    }

}
