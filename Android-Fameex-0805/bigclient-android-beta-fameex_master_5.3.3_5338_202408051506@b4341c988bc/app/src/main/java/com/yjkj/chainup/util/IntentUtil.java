package com.yjkj.chainup.util;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;

/*
 *Page jump, setting of Intent constant
 */
public class IntentUtil {

	/*
	 *Callback free
	 */
	public static void activityForward(Context activity, Class clazz,
			Bundle bundle, boolean isFinish) {
		Intent intent = new Intent(activity, clazz);
		if (null != bundle)
			intent.putExtras(bundle);
		activity.startActivity(intent);
		if (isFinish && activity instanceof Activity)
			((Activity) activity).finish();
	}
	
	/*
	 *Page jump animation features above 5.0
	 */
	public static void avForwardAnima(Context activity, Class clazz,
			Bundle bundle, boolean isFinish) {
		Intent intent = new Intent(activity, clazz);  

		if (null != bundle)
			intent.putExtras(bundle);
		//activity.startActivity(intent,ActivityOptions.makeSceneTransitionAnimation(activity).toBundle());
		if (isFinish && activity instanceof Activity)
			((Activity) activity).finish();
	}

	/*
	 *Callable
	 */
	public static void startActivityForResult(Activity activity, Class clazz,
			int requestCode, Bundle bundle) {
		Intent intent = new Intent(activity, clazz);
		if (null != bundle) {
			intent.putExtras(bundle);
			activity.startActivityForResult(intent, requestCode);
		} else {
			activity.startActivityForResult(intent, requestCode);
		}
	}

	/*
	 *Start a service
	 */
	public static void serviceForward(Context activity, Class clazz,
			Bundle bundle, boolean isFinish) {
		Intent intent = new Intent(activity, clazz);
		if (null != bundle)
			intent.putExtras(bundle);
		activity.startService(intent);
		if (isFinish && activity instanceof Activity)
			((Activity) activity).finish();
	}

	/*
	 *Launch Android default browser
	 */
	public static void forwardBrowse(Context activity,String url){
		if(!StringUtil.isHttpUrl(url))
			return;
		Intent intent= new Intent(Intent.ACTION_VIEW,Uri.parse(url));
		activity.startActivity(intent);
	}

	/*
	 *If four activities have already been started: A, B, C, and D. In the D activity, we need to jump to the B activity and hope that the C finish will drop,
	 *Flags tags can be added to the int in startActivity (int)
	 */
	public static void activityForward(Context context, Class clazz) {
		Intent intent = new Intent(context, clazz);
		//Intent. addFlags (Intent. FLAG_ACTIVITY_SINGLE_TOP); Do not rebuild B, reuse B
		intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
		context.startActivity(intent);
	}
}
