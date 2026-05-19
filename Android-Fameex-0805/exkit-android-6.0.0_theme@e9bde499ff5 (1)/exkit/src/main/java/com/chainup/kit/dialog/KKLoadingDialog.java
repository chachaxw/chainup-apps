package com.chainup.kit.dialog;

import android.app.Activity;
import android.app.Dialog;
import android.graphics.Color;
import android.graphics.ColorFilter;
import android.text.TextUtils;
import android.util.Log;
import android.view.Gravity;
import android.view.View;
import android.view.Window;
import android.widget.TextView;

import androidx.lifecycle.Lifecycle;
import androidx.lifecycle.LifecycleObserver;
import androidx.lifecycle.OnLifecycleEvent;

import androidx.core.content.ContextCompat;

import com.airbnb.lottie.LottieAnimationView;
import com.airbnb.lottie.LottieComposition;
import com.airbnb.lottie.LottieOnCompositionLoadedListener;
import com.airbnb.lottie.LottieProperty;
import com.airbnb.lottie.SimpleColorFilter;
import com.airbnb.lottie.model.KeyPath;
import com.airbnb.lottie.value.LottieFrameInfo;
import com.airbnb.lottie.value.LottieValueCallback;
import com.airbnb.lottie.value.SimpleLottieValueCallback;
import com.example.chainup_kit.R;

import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;


/**
 * @Description:
 * @Author: wanghao
 * @CreateDate: 2019-08-27 16:11
 * @UpdateUser: wanghao
 * @UpdateDate: 2019-08-27 16:11
 *@ UpdateRemark: Update Description
 */
public class KKLoadingDialog implements LifecycleObserver {

    String loadText = "";

    private KKLoadingDialog() {
    }

    private Activity mActivity;

    public KKLoadingDialog(Activity activity) {
        this.mActivity = activity;
    }

    public KKLoadingDialog(Activity mActivity, String loadText) {
        this.loadText = loadText;
        this.mActivity = mActivity;
    }

    private Dialog dialog;

    public void showLoadingDialog() {
        if (mActivity.isFinishing())
            return;
        if (dialog == null) {
            if (TextUtils.isEmpty(loadText)) {
                dialog = createLoadingDialog(mActivity,true);
            } else {
                dialog = createLoadingDialog(mActivity, loadText);
            }

        } else if (!dialog.isShowing()) {
            dialog.show();
        }
    }

    public void showLoadingDialog(Boolean isShow) {
        if (mActivity.isFinishing())
            return;
        if (dialog == null) {
            if (TextUtils.isEmpty(loadText)) {
                dialog = createLoadingDialog(mActivity,false);
            } else {
                dialog = createLoadingDialog(mActivity, loadText);
            }

        } else if (!dialog.isShowing()) {
            dialog.show();
        }
    }

    public void setLoadText(String loadText) {
        this.loadText = loadText;
        if (dialog != null) {
            TextView tv_load_text = dialog.findViewById(R.id.tv_load_text);
            tv_load_text.setVisibility(View.VISIBLE);
            tv_load_text.setText(loadText);
        }
    }

    public void closeLoadingDialog() {
        if (dialog != null && dialog.isShowing()) {
            dialog.dismiss();
//            dialog = null;
        }
    }

    /**
     *Progress dialog with cancel callback
     *
     * @param context
     * @return dialog
     */
    private static Dialog createLoadingDialog(Activity context,Boolean isShow) {
        if (context == null || context.isFinishing()) return null;
        try {
            final Dialog dialog = new Dialog(context, R.style.NoBackGroundDialog);
            dialog.setCancelable(isShow);
            dialog.setCanceledOnTouchOutside(isShow);
            dialog.show();
            Window window = dialog.getWindow();
            assert window != null;
            window.setGravity(Gravity.CENTER);
            window.setLayout(android.view.WindowManager.LayoutParams.WRAP_CONTENT,
                    android.view.WindowManager.LayoutParams.WRAP_CONTENT);
            View view = context.getLayoutInflater().inflate(
                    R.layout.kk_loading_dialog, null);
            LottieAnimationView lottieView = view.findViewById(R.id.lottie_view);
            lottieView.addLottieOnCompositionLoadedListener(new LottieOnCompositionLoadedListener() {
                @Override
                public void onCompositionLoaded(LottieComposition composition) {
                    List<KeyPath> list = lottieView.resolveKeyPath(new KeyPath("**"));
                    for (KeyPath path : list) {
                        Log.d("LottieKeyPath", path.keysToString());
                    }
                    KeyPath keyPath1 = new KeyPath("转动","椭圆 1","描边 1"," 椭圆路径1");
                    LottieValueCallback<ColorFilter> colorCallback = new LottieValueCallback<>();
                    colorCallback.setValue(new SimpleColorFilter(ContextCompat.getColor(context,R.color.text_1)));
                    lottieView.addValueCallback(new KeyPath("**"), LottieProperty.COLOR_FILTER, colorCallback);
                }
            });
            lottieView.cancelAnimation();
            lottieView.setAnimation("loading_btn_black.json");
            lottieView.setSpeed(1.4f);
            lottieView.playAnimation();

            window.setContentView(view);//
            return dialog;
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    private static Dialog createLoadingDialog(Activity context, String loadText) {
        Dialog dialog = createLoadingDialog(context,true);
        if (!TextUtils.isEmpty(loadText)) {
            TextView tv_load_text = dialog.findViewById(R.id.tv_load_text);
            tv_load_text.setVisibility(View.VISIBLE);
            tv_load_text.setText(loadText);
        }
        return dialog;
    }

    @OnLifecycleEvent(Lifecycle.Event.ON_DESTROY)
    private void onDestory() {
        this.closeLoadingDialog();
        this.dialog = null;
        this.mActivity = null;
    }
}
