package com.chainup.contract.utils;

import android.app.Activity;
import android.content.Context;
import android.os.Looper;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.Nullable;


import com.chainup.contract.R;
import com.chainup.contract.app.CpGlobalAppComponent;
import com.chainup.contract.view.CpSnackLayout;

import org.json.JSONObject;

/**
 * @Description:
 * @Author: wanghao
 * @CreateDate: 2019-08-26 20:05
 * @UpdateUser: wanghao
 * @UpdateDate: 2019-08-26 20:05
 * @UpdateRemark: updateDescription
 */
public class CpNToastUtil {

    private static Toast toast = null;
    /**
     *Last Time
     */
    private static long lastTime = 0;
    /**
     *Current Time
     */
    private static long curTime = 0;
    /**
     *Previously displayed content
     */
    private static String oldMsg;

    /**
     *Prompt information
     */
    public static void showToast(final String text, final boolean isLongTime) {
        final Context context = CpGlobalAppComponent.getContext();
        final int y = CpScreenUtil.getHeight() / 7;//ScreenUtil.getHeight(context)/8;
        if (Looper.myLooper() == Looper.getMainLooper()) {
            show(context, text, isLongTime, y);
        } else {
            Looper.prepare();
            show(context, text, isLongTime, y);
            Looper.loop();
        }

    }

    private static void show(Context context, String text, final boolean isLongTime, final int y) {
        curTime = System.currentTimeMillis();
        int duration = isLongTime ? Toast.LENGTH_LONG : Toast.LENGTH_SHORT;
        JSONObject jsonObject = null;//MessageUtil.getMessage();
        if (null != jsonObject) {
            text = jsonObject.optString(text, text);
        }
        if (toast == null) {
            toast = Toast.makeText(context, text, duration);
            oldMsg = text;
        } else {
            if (text.equals(oldMsg)) {
                if (curTime - lastTime < duration) {
                    lastTime = System.currentTimeMillis();
                    return;
                }
            }

            toast.setText(text);
            toast.setDuration(duration);
        }
        toast.setGravity(Gravity.BOTTOM, 0, y);
        lastTime = System.currentTimeMillis();
        toast.show();
    }

    /*
     *Customize the toast of the view
     */
    public static void showTopToast(boolean isSuccess, String content) {
        if (!CpStringUtil.checkStr(content) || "网络异常".equalsIgnoreCase(content))
            return;
        CpSnackLayout.INSTANCE.showSnackBar(null, content, isSuccess, null);
    }

    /*
     *Customize the toast of the view
     */
    public static void showTopToastNet(@Nullable Activity activity, boolean isSuccess, String content) {
        if (!CpStringUtil.checkStr(content) || "网络异常".equalsIgnoreCase(content))
            return;
        View view = null;
        if (activity != null) view = activity.getWindow().getDecorView();
        CpSnackLayout.INSTANCE.showSnackBar(view, content, isSuccess, null);
    }

    /*
     *Toast centered display
     */
    public static void showCenterToast(String content) {
        if (!CpStringUtil.checkStr(content))
            return;

        final Context context = CpGlobalAppComponent.getContext();
        Toast centerToast = new Toast(context);
        View view = LayoutInflater.from(context).inflate(R.layout.cp_center_toast, null);
        TextView text = view.findViewById(R.id.text);

        text.setText(content);
        centerToast.setView(view);
        centerToast.setGravity(Gravity.CENTER, 0, 0);
        centerToast.setDuration(Toast.LENGTH_LONG);
        centerToast.show();
    }
}
