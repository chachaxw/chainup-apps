package com.chainup.contract.utils;

import android.content.Context;
import android.content.Intent;
import android.graphics.drawable.Drawable;
import android.os.Build;
import android.os.SystemClock;

import androidx.core.content.ContextCompat;

import com.chainup.contract.app.CpGlobalAppComponent;
import com.chainup.contract.app.CpMyApp;


public class CpContextUtil {

    public static String getString(int stringId) {
        return CpMyApp.Companion.instance().getString(stringId);
    }

    public static int getColor(int colorId) {
        return ContextCompat.getColor(CpGlobalAppComponent.getContext(), colorId);
    }

    public static Drawable getResource(int drawableId) {
        return ContextCompat.getDrawable(CpGlobalAppComponent.getContext(), drawableId);
    }

    /**
     *Check whether the jump is repeated. If not, rewrite the method and return true
     */
    private String mActivityJumpTag;        //Activity jump tag
    private long mClickTime;                //Activity jump time
    protected boolean checkDoubleClick(Intent intent) {

        //Default check passed
        boolean result = true;
        //Tag Object
        String tag;
        if (intent.getComponent() != null) { //Explicit jump
            tag = intent.getComponent().getClassName();
        } else if (intent.getAction() != null) { //Implicit jump
            tag = intent.getAction();
        } else {
            return true;
        }

        if (tag.equals(mActivityJumpTag) && mClickTime >= SystemClock.uptimeMillis() - 500) {
            //Inspection failed
            result = false;
        }

        //Record start mark and time
        mActivityJumpTag = tag;
        mClickTime = SystemClock.uptimeMillis();
        return result;
    }

    public static void startService(Context context, Class<?> cls){

        //Enable the service for compatibility processing
        Intent intent = new Intent(context,cls);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
//            context.startForegroundService(intent);
            context.startService(intent);
        }else {
            context.startService(intent);
        }
    }
}
