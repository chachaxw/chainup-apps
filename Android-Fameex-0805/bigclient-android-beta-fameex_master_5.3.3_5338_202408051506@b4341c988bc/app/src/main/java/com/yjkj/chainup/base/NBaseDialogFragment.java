package com.yjkj.chainup.base;

import android.animation.ObjectAnimator;
import android.graphics.drawable.ColorDrawable;
import android.os.Bundle;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewParent;
import android.view.Window;
import android.view.WindowManager;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.DialogFragment;
import androidx.fragment.app.FragmentManager;

import com.yjkj.chainup.R;
import com.yjkj.chainup.extra_service.eventbus.EventBusUtil;
import com.yjkj.chainup.extra_service.eventbus.MessageEvent;
import com.yjkj.chainup.util.SoftKeyboardUtil;

import org.greenrobot.eventbus.Subscribe;
import org.greenrobot.eventbus.ThreadMode;

/**
 *@description: The usage of DialogFragment base class packaging is the same as NBaseFragment
 * @Author: wanghao
 * @CreateDate: 2019-11-04 12:13
 * @UpdateUser: wanghao
 * @UpdateDate 2023-11-04 12:13
 *@ UpdateRemark: Update Description
 */
public abstract class NBaseDialogFragment extends DialogFragment implements View.OnClickListener {

    protected View layoutView;
    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        if (null == layoutView) {
            //setTheme();
            layoutView = inflater.inflate(setContentView(), container,false);
            loadData();
        } else {
            ViewParent viewParent = layoutView.getParent();
            if(null!=viewParent && viewParent instanceof ViewGroup){
                ViewGroup vg = (ViewGroup)viewParent;
                vg.removeView(layoutView);
            }
        }
        return layoutView;
    }

    public void setTheme(){
        Window window = this.getDialog().getWindow();
        //Remove the default padding from the dialog
        window.getDecorView().setPadding(0, 0, 0, 0);
        WindowManager.LayoutParams lp = window.getAttributes();
        lp.width = WindowManager.LayoutParams.MATCH_PARENT;
        lp.height = WindowManager.LayoutParams.WRAP_CONTENT;
        //Set the position of the dialog at the bottom
        lp.gravity = Gravity.BOTTOM;
        //Animating the dialog
        lp.windowAnimations = R.style.leftin_rightout_DialogFg_animstyle;
        window.setAttributes(lp);
        window.setBackgroundDrawable(new ColorDrawable());
    }


    protected abstract int setContentView();

    protected <T extends View> T findViewById(int id){
        return layoutView.findViewById(id);
    }
    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        EventBusUtil.register(this);
        hideKeyboard();
        initView();

    }

    protected abstract void initView();

    protected abstract void loadData();

    /*@NonNull
    @Override
    public Dialog onCreateDialog(@Nullable Bundle savedInstanceState) {
        return super.onCreateDialog(savedInstanceState);
        Window window = getDialog().getWindow();
        //window.setGravity(Gravity.BOTTOM);
        window.setWindowAnimations(R.style.leftin_rightout_DialogFg_animstyle);
        //window.setBackgroundDrawable(new ColorDrawable(Color.TRANSPARENT));
        window.setLayout(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT);
    }*/

    @Override
    public void onStart() {
        super.onStart();

        //Window win = getDialog().getWindow();
       // win.setBackgroundDrawable( new ColorDrawable(Color.TRANSPARENT));
        /*DisplayMetrics dm = new DisplayMetrics();
        getActivity().getWindowManager().getDefaultDisplay().getMetrics( dm );
        WindowManager.LayoutParams params = win.getAttributes();
        params.gravity = Gravity.BOTTOM;
        params.width =  ViewGroup.LayoutParams.MATCH_PARENT;
        params.height = ViewGroup.LayoutParams.MATCH_PARENT;
        win.setAttributes(params);*/
        //win.getAttributes().windowAnimations = R.style.leftin_rightout_DialogFg_animstyle;
    }

    /*
     *The processing thread is consistent with the message sending thread
     *Subclass overload
     */
    @Subscribe(threadMode = ThreadMode.POSTING)
    public void onMessageEvent(MessageEvent event) {
    }

    /*
     *Viscous event handling
     *After subclass overloading and processing the event, EventBusUtil. removeStickyEvent (event) needs to be called;
     */
    @Subscribe(threadMode = ThreadMode.POSTING,sticky=true)
    public void  onMessageStickyEvent(MessageEvent event) {
    }

    @Override
    public void onDestroyView() {
        super.onDestroyView();
        EventBusUtil.unregister(this);
    }


    @Override
    public void onClick(View v) {
        dismissDialog();
    }

    protected void dismissDialog(){
        if(isVisible()){
            dismiss();
        }
    }

    @Override
    public void dismiss() {
        hideKeyboard();
        super.dismiss();
    }

    private void hideKeyboard(){
        View view = getDialog().getCurrentFocus();
        SoftKeyboardUtil.hideSoftKeyboard(view);
    }

    /*
     *Display dialog
     */
    protected void showDialog(FragmentManager manager, String tag){
        show(manager,tag);
    }

    /* access modifiers changed from: protected */
    public void doCoverViewShowAnimation(View view) {
        if (view != null) {
            ObjectAnimator.ofFloat(view, View.ALPHA, 0.0f, 1.0f).setDuration(getDuration()).start();
        }
    }

    /* access modifiers changed from: protected */
    public void doCoverViewHideAnimation(View view) {
        if (view != null) {
            ObjectAnimator.ofFloat(view, View.ALPHA, 1.0f, 0.0f).setDuration(getDuration()).start();
        }
    }

    /* access modifiers changed from: protected */
    public long getDuration() {
        return 300;
    }
}
