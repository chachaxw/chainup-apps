package com.chainup.contract.utils;

import android.app.Activity;
import android.content.ComponentName;
import android.content.Intent;
import android.net.Uri;
import android.os.Build;
import android.provider.Settings;

public class GoPermissionManagement {

    private static final String TAG = "GoPermissionManagement";
    /**
     * Build.MANUFACTURER
     */
    private static final String MANUFACTURER_HUAWEI = "HUAWEI";//华为
    private static final String MANUFACTURER_MEIZU = "Meizu";//魅族
    private static final String MANUFACTURER_XIAOMI = "Xiaomi";//小米
    private static final String MANUFACTURER_SONY = "Sony";//索尼
    private static final String MANUFACTURER_OPPO = "OPPO";//oppo
    private static final String MANUFACTURER_LG = "LG";
    private static final String MANUFACTURER_VIVO = "vivo";//vivo

    /**
     * 此函数可以自己定义
     * @param activity
     */
    public static boolean GoToSetting(Activity activity){
        switch (Build.MANUFACTURER){
            case MANUFACTURER_HUAWEI:
                return Huawei(activity);
            case MANUFACTURER_MEIZU:
                return  Meizu(activity);
            case MANUFACTURER_XIAOMI:
                return  Xiaomi(activity);
            case MANUFACTURER_SONY:
                return Sony(activity);
            case MANUFACTURER_OPPO:
                return OPPO(activity);
            case MANUFACTURER_LG:
                return LG(activity);
            case MANUFACTURER_VIVO:
                return vivo(activity);
            default:
                System.out.println("目前暂不支持此系统");
                return goIntentSetting(activity);
        }
    }

    public static boolean Huawei(Activity activity) {
        try {
            Intent intent = new Intent();
            intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            intent.putExtra("packageName", activity.getApplicationInfo().packageName);
            ComponentName comp = new ComponentName("com.huawei.systemmanager", "com.huawei.permissionmanager.ui.MainActivity");
            intent.setComponent(comp);
            activity.startActivity(intent);
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return goIntentSetting(activity);
        }
    }

    public static boolean Meizu(Activity activity) {
        try {
            Intent intent = new Intent("com.meizu.safe.security.SHOW_APPSEC");
            intent.addCategory(Intent.CATEGORY_DEFAULT);
            intent.putExtra("packageName", activity.getPackageName());
            activity.startActivity(intent);
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return goIntentSetting(activity);
        }
    }

    public static boolean Xiaomi(Activity activity) {
        try {
            Intent intent = new Intent("miui.intent.action.APP_PERM_EDITOR");
            intent.putExtra("extra_pkgname", activity.getPackageName());
            ComponentName componentName = new ComponentName("com.miui.securitycenter", "com.miui.permcenter.permissions.PermissionsEditorActivity");
            intent.setComponent(componentName);
            activity.startActivity(intent);
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return goIntentSetting(activity);
        }
    }

    public static boolean Sony(Activity activity) {
        try {
            Intent intent = new Intent();
            intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            intent.putExtra("packageName", activity.getPackageName());
            ComponentName comp = new ComponentName("com.sonymobile.cta", "com.sonymobile.cta.SomcCTAMainActivity");
            intent.setComponent(comp);
            activity.startActivity(intent);
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return goIntentSetting(activity);
        }
    }

    public static boolean OPPO(Activity activity) {
        try {
            Intent intent = new Intent();
            intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            intent.putExtra("packageName", activity.getPackageName());
            //        ComponentName comp = new ComponentName("com.color.safecenter", "com.color.safecenter.permission.PermissionManagerActivity");
            ComponentName comp = new ComponentName("com.coloros.securitypermission", "com.coloros.securitypermission.permission.PermissionAppAllPermissionActivity");//R11t 7.1.1 os-v3.2
            intent.setComponent(comp);
            activity.startActivity(intent);
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return goIntentSetting(activity);
        }
    }

    public static boolean LG(Activity activity) {
        try {
            Intent intent = new Intent("android.intent.action.MAIN");
            intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            intent.putExtra("packageName", activity.getPackageName());
            ComponentName comp = new ComponentName("com.android.settings", "com.android.settings.Settings$AccessLockSummaryActivity");
            intent.setComponent(comp);
            activity.startActivity(intent);
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return goIntentSetting(activity);
        }
    }

    public static boolean vivo(Activity activity) {
        try {
            Intent intent = new Intent("android.intent.action.MAIN");
            intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            intent.putExtra("packageName", activity.getPackageName());
            ComponentName comp = new ComponentName("com.android.settings", "com.vivo.permissionmanager.activity.PurviewTabActivity");
            intent.setComponent(comp);
            activity.startActivity(intent);
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return goIntentSetting(activity);
        }
    }

    /**
     * 默认打开应用详细页
     */
    private static boolean goIntentSetting(Activity pActivity) {
        Intent intent = new Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS);
        Uri uri = Uri.fromParts("package", pActivity.getPackageName(), null);
        intent.setData(uri);
        try {
            pActivity.startActivity(intent);
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

}