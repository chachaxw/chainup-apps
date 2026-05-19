package com.chainup.kit.utils;


import android.content.Context;
import android.os.Handler;
import android.os.Looper;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.TextView;
import android.widget.Toast;

import com.example.chainup_kit.R;

import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.List;
import java.util.Timer;
import java.util.TimerTask;


public class ToastUtils {

    public static void toastOnUIThread(Context mContext,String string) {
        Handler handler = new Handler(Looper.getMainLooper());
        handler.post(new Runnable() {
            @Override
            public void run() {
                showToast(mContext,string);
            }
        });
    }
    private static List<WeakReference<Toast>> toastWeakRefList = new ArrayList();

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
        toastWeakRefList.add(new WeakReference<>(toast));
        //toast.show();
        showMyToast(toast,2500);
    }

    public static void cancelAll() {
        if (!toastWeakRefList.isEmpty()){
            for (WeakReference<Toast> toastWeakRef : toastWeakRefList) {
                Toast toast = toastWeakRef.get();
                if(toast!=null) toast.cancel();
            }
            toastWeakRefList.clear();
        }
    }

    //Toast displaying text
    public static void showNewToast(Context context, String message){
        View toastView= LayoutInflater.from(context).inflate(R.layout.toast_text_layout,null);
        TextView text = (TextView) toastView.findViewById(R.id.tv_message);
        text.setText(message);
        Toast toast=new Toast(context);
        toast.setGravity(Gravity.CENTER,0,0);
        toast.setDuration(Toast.LENGTH_LONG);
        toast.setView(toastView);
        toast.show();
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
                timer.cancel();
            }
        }, countNum);

    }
}
