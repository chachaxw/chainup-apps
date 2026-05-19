package com.yjkj.chainup.util;

import android.content.Context;
import android.content.Intent;
import android.graphics.drawable.Drawable;
import android.os.Build;
import android.os.SystemClock;
import androidx.core.content.ContextCompat;

import com.yjkj.chainup.app.GlobalAppComponent;


public class ContextUtil {

    public static String getString(int stringId) {
        return GlobalAppComponent.getContext().getString(stringId);
    }

    public static int getColor(int colorId) {
        return ContextCompat.getColor(GlobalAppComponent.getContext(), colorId);
    }

    public static Drawable getResource(int drawableId) {
        return ContextCompat.getDrawable(GlobalAppComponent.getContext(), drawableId);
    }

    /**
     *Check if there are duplicate jumps, override the method and return true if not needed
     */
    private String mActivityJumpTag;        //Activity Jump Tag
    private long mClickTime;                //Activity jump time
    protected boolean checkDoubleClick(Intent intent) {

        //Default check passed
        boolean result = true;
        //Mark Object
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

        //Record startup flag and time
        mActivityJumpTag = tag;
        mClickTime = SystemClock.uptimeMillis();
        return result;
    }

    public static void startService(Context context, Class<?> cls){

        //Enable service for compatibility processing
        Intent intent = new Intent(context,cls);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
//            context.startForegroundService(intent);
            context.startService(intent);
        }else {
            context.startService(intent);
        }
    }
}
