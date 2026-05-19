package com.chainup.contract.base;

import android.annotation.TargetApi;
import android.app.Activity;
import android.os.Build;

import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.Map.Entry;
import java.util.Set;

/**
 * Author: jack
 *Description: Manage all activities in the stack
 */
public class CpActivityCollector {

    /**
     *Store the list of activities
     */
    public static HashMap<Class<?>, Activity> activities = new LinkedHashMap<>();

    /**
     *Add Activity
     *
     * @param activity
     */
    public static void addActivity(Activity activity, Class<?> clz) {
        activities.put(clz, activity);
    }

    /**
     *Determine whether an activity exists
     *
     * @param clz
     * @return
     */
    @TargetApi(Build.VERSION_CODES.JELLY_BEAN_MR1)
    public static <T extends Activity> boolean isActivityExist(Class<T> clz) {
        boolean res;
        Activity activity = getActivity(clz);
        if (activity == null) {
            res = false;
        } else {
            if (activity.isFinishing() || activity.isDestroyed()) {
                res = false;
            } else {
                res = true;
            }
        }

        return res;
    }

    /**
     *Obtain the specified activity instance
     *
     *Class object of @param clazz Activity
     * @return
     */
    public static <T extends Activity> T getActivity(Class<T> clazz) {
        return (T) activities.get(clazz);
    }

    /**
     *Remove the activity instead of finishing
     *
     * @param activity
     */
    public static void removeActivity(Activity activity) {
        if (activities.containsValue(activity)) {
            activities.remove(activity.getClass());
        }
    }

    /**
     *Remove all activities
     */
    public static void removeAllActivity() {
        if (activities != null && activities.size() > 0) {
            Set<Entry<Class<?>, Activity>> sets = activities.entrySet();
            for (Entry<Class<?>, Activity> s : sets) {
                if (!s.getValue().isFinishing()) {
                    s.getValue().finish();
                }
            }
        }
        activities.clear();
    }
}
