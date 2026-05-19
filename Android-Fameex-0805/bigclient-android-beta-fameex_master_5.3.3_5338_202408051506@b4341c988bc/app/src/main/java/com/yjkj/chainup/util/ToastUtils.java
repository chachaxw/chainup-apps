package com.yjkj.chainup.util;


import android.content.Context;
import android.os.Handler;
import android.os.Looper;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;

import com.yjkj.chainup.R;
import com.yjkj.chainup.app.ChainUpApp;

import java.util.ArrayList;
import java.util.List;
import java.util.Timer;
import java.util.TimerTask;


public class ToastUtils {

    private static String oldMsg;
    private static long time;

//    public static void showToast(Context context, String msg) {
//If (! Msg. equals (oldMsg)) {//When the displayed content is different, it is determined that it is not the same toast
//            Toast.makeText(context, msg, Toast.LENGTH_SHORT).show();
//            time = System.currentTimeMillis();
//        } else {
////When the display content is the same, it will only be displayed when the interval time is greater than 2 seconds
//            if (System.currentTimeMillis() - time > 2000) {
//                Toast.makeText(context, msg, Toast.LENGTH_SHORT).show();
//                time = System.currentTimeMillis();
//            }
//        }
//        oldMsg = msg;
//    }


    public static void showToast(String msg) {
        showToast(ChainUpApp.appContext, msg);
    }

    /**
     * @param string
     */
    public static void toastOnUIThread(String string) {
        Handler handler = new Handler(Looper.getMainLooper());
        handler.post(new Runnable() {
            @Override
            public void run() {
                showToast(string);
            }
        });
    }


    /**
     *Customized toast with pictures
     *
     * @param context
     * @param msg
     * @param resId
     */
    public static void showCusToast(Context context, String msg, int resId) {
        Toast toast = new Toast(context);
        toast.setGravity(Gravity.CENTER, 0, 0);
        View view = LayoutInflater.from(context).inflate(R.layout.layout_customize_toast, null);
        ImageView ivIcon = view.findViewById(R.id.iv_icon);
        ivIcon.setImageResource(resId);
        TextView tvText = view.findViewById(R.id.tv_text);
        tvText.setText(msg);
        toast.setView(view);
        toast.setDuration(Toast.LENGTH_SHORT);
        toast.show();
    }


    private static List<Toast> toastList = new ArrayList();

    //Toast displaying text
    public static void showToast(Context context, String message){
        cancelAll();
        View toastView= LayoutInflater.from(context).inflate(R.layout.toast_text_layout,null);
        TextView text = (TextView) toastView.findViewById(R.id.tv_message);
        text.setText(message);
        Toast toast=new Toast(context);
        toast.setGravity(Gravity.CENTER,0,0);
        toast.setDuration(Toast.LENGTH_LONG);
        toast.setView(toastView);
        toastList.add(toast);
        toast.show();
        //toast.show();
//        showMyToast(toast,2500);
    }

    public static void cancelAll() {
        if (!toastList.isEmpty()){
            for (Toast toast : toastList) {
                toast.cancel();
            }
            toastList.clear();
        }
    }

    public static void showMyToast(final Toast toast, final int countNum) {
        final Timer timer = new Timer();
        timer.schedule(new TimerTask() {
            @Override
            public void run() {
                toast.show();
            }
        }, 0);
        new Timer().schedule(new TimerTask() {
            @Override
            public void run() {
                toast.cancel();
                timer.cancel();
            }
        }, countNum);

    }
}
