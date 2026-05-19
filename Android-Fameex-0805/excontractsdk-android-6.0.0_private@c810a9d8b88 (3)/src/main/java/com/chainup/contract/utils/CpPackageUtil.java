package com.chainup.contract.utils;

import android.content.Context;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;

import com.chainup.contract.app.CpGlobalAppComponent;
import com.chainup.contract.app.CpMyApp;


public class CpPackageUtil {

	/*
	 *Obtain the installation package path for this program
	 */
	public static String getPackagePath(Context context) {
		// PackageManager pm = context.getPackageManager();
		return context.getPackageResourcePath();
	}

	/*
	 *Get current program path
	 */
	public static String getCurApplicationPath(Context context) {
		// PackageManager pm = context.getPackageManager();
		return context.getFilesDir().getAbsolutePath();
	}

	/*
	 *Get the version number of the application
	 */
	public static String getVersionName() {
		try {
			Context context = CpGlobalAppComponent.getContext();
			PackageManager manager = context.getPackageManager();
			if(null!=manager){
				PackageInfo info = manager.getPackageInfo(context.getPackageName(),
						0);
				if(null!=info){
					return info.versionName;
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return "";
	}
	
	/*
	 *Get the version number of the application
	 */
	public static int getVersionCode() {
		try {
			Context context = CpMyApp.Companion.instance();
			PackageManager manager = context.getPackageManager();
			PackageInfo info = manager.getPackageInfo(context.getPackageName(),
					0);
			return info.versionCode;
		} catch (Exception e) {
			e.printStackTrace();
		}
		return 0;
	}

	/*
	 *Get the channel name of the application
	 */
	public static String getChannelName(Context context) {
		try {
			PackageManager packageManager = context.getPackageManager();
			if(null!=packageManager){
				ApplicationInfo applicationInfo = packageManager.getApplicationInfo(context.getPackageName(), PackageManager.GET_META_DATA);
				if (applicationInfo != null) {
					if (applicationInfo.metaData != null) {
						return applicationInfo.metaData.getString("UMENG_CHANNEL");
					}
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return "";
	}
	/*
	 *Get the channel name of the application
	 */
	public static String getApplicationName(Context context) {
		try {
			PackageManager packageManager = context.getPackageManager();
			if(null!=packageManager){
				ApplicationInfo applicationInfo = packageManager.getApplicationInfo(context.getPackageName(), PackageManager.GET_META_DATA);
				if (applicationInfo != null) {
					return (String) packageManager.getApplicationLabel(applicationInfo);
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return "";
	}

}
