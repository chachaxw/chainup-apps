package com.chainup.contract.utils;

import android.app.Activity;
import android.content.Context;
import android.graphics.Rect;
import android.util.DisplayMetrics;
import android.view.View;
import android.view.Window;


import com.chainup.contract.app.CpGlobalAppComponent;

import java.lang.reflect.Field;

/*
 *Tools related to screen information, such as width and height, density, conversion, etc
 */
public class CpScreenUtil {

	private static DisplayMetrics initScreen() {
		return CpGlobalAppComponent.getContext().getResources().getDisplayMetrics();
	}

	public static int getWidth(Context context) {
		return context.getResources().getDisplayMetrics().widthPixels;
	}

	public static int getHeight() {
		return initScreen().heightPixels;
	}

	public static int dip2px(Context context, float dipValue) {
		if(null==context)
			 context = CpGlobalAppComponent.getContext();
		final float scale = context.getResources().getDisplayMetrics().density;
		return (int) (dipValue * scale + 0.5f);
	}

	/*
	 *Get Status Bar Height
	 */
	public static int getStatusBarHeight(Activity activity) {
		Rect frame = new Rect();
		activity.getWindow().getDecorView().getWindowVisibleDisplayFrame(frame);
		int statusBarHeight = frame.top;
		if(statusBarHeight<=0){
			statusBarHeight = CpScreenUtil.dip2px(activity,20.0f);
		}
		return statusBarHeight;
	}

	/*
	 *Obtain status bar height by reflection
	 */
	public static int getStatusBarHeightByReflact(Activity activity) {
		try {
			Class<?> c = Class.forName("com.android.internal.R$dimen");
			Object obj = c.newInstance();
			Field field = c.getField("status_bar_height");
			int x = Integer.parseInt(field.get(obj).toString());
			int sbar = activity.getResources().getDimensionPixelSize(x);
			return sbar;
		} catch (Exception e) {
			e.printStackTrace();
		}
		return 0;
	}

	/*
	 *Get Title Bar Height
	 */
	public static int gettitleBarHeight(Activity activity, int statusBarHeight) {
		int contentTop = activity.getWindow()
				.findViewById(Window.ID_ANDROID_CONTENT).getTop();
		if (statusBarHeight <= 0)
			statusBarHeight = getStatusBarHeight(activity);
		//StatusBarHeight is the height of the status bar requested above
		int titleBarHeight = contentTop - statusBarHeight;
		return titleBarHeight;
	}

	/*
	 *Get the width and height of the view
	 */
	public static int[] getViewWH(Activity activity, View view) {
		int width = View.MeasureSpec.makeMeasureSpec(0,
				View.MeasureSpec.UNSPECIFIED);

		int height = View.MeasureSpec.makeMeasureSpec(0,
				View.MeasureSpec.UNSPECIFIED);

		view.measure(width, height);
		int w = view.getMeasuredWidth();
		int h = view.getMeasuredHeight();
		return new int[] { w, h };
	}

	/**
	 *Convert the px value to an sp value, ensuring that the text size remains the same
	 *
	 * @param pxValue
	 *(Attribute scaledDensity in DisplayMetrics class)
	 * @return
	 */
	public static float px2sp(Context context, float pxValue) {
		final float fontScale = context.getResources().getDisplayMetrics().scaledDensity;
		return (pxValue / fontScale + 0.5f);
	}

	/**
	 *Convert the sp value to a px value, ensuring that the text size remains the same
	 *
	 * @param spValue
	 *(Attribute scaledDensity in DisplayMetrics class)
	 * @return
	 */
	public static float sp2px(Context context, float spValue) {
		final float fontScale = context.getResources().getDisplayMetrics().scaledDensity;
		return (spValue * fontScale + 0.5f);
	}
}
