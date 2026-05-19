package com.chainup.kit.dialog.base;


import android.app.Dialog;
import android.content.Context;
import android.content.DialogInterface;
import android.os.Bundle;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.view.WindowManager;
import android.widget.FrameLayout;
import android.widget.ImageView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatDialog;
import androidx.coordinatorlayout.widget.CoordinatorLayout;
import androidx.core.content.ContextCompat;
import androidx.fragment.app.DialogFragment;
import androidx.fragment.app.FragmentManager;

import com.chainup.kit.utils.PublicSizeUtil;
import com.example.chainup_kit.R;
import com.google.android.material.bottomsheet.BottomSheetBehavior;
import com.google.android.material.bottomsheet.BottomSheetDialogFragment;


public abstract class KKBaseDialogFragment extends BottomSheetDialogFragment {

    public static final String TAG = "TDialog";
    private static final float DEFAULT_DIMAMOUNT = 0.2F;
    private int topLineHeight;
    private int topLineMargin;
    protected BottomSheetBehavior<FrameLayout> behavior;

    private boolean dialogCanConsumerStatus = true;

    protected abstract int getLayoutRes();

    protected abstract void bindView(View view);

    protected abstract View getDialogView();

    protected BottomSheetBehavior.BottomSheetCallback mBottomSheetBehaviorCallback = new BottomSheetBehavior.BottomSheetCallback() {
        @Override
        public void onStateChanged(@NonNull View view, int i) {
            if(!dialogCanConsumerStatus) {
                behavior.setState(BottomSheetBehavior.STATE_EXPANDED);
            }
//            if (i == BottomSheetBehavior.STATE_COLLAPSED) {
//                dismiss();
//            }
        }

        @Override
        public void onSlide(@NonNull View view, float v) {

        }
    };
    @NonNull
    @Override
    public Dialog onCreateDialog(Bundle savedInstanceState) {
        return getCanSwipeCloseDialog()? super.onCreateDialog(savedInstanceState) : new AppCompatDialog(getContext(), getTheme());
    }

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        topLineHeight = PublicSizeUtil.dp2px(getContext(),4.0f);
        topLineMargin = PublicSizeUtil.dp2px(getContext(),8.0f);
        if(getCanSwipeCloseDialog()){
            setStyle(DialogFragment.STYLE_NO_TITLE, R.style.SheetDialogTheme);
        }else{
            setStyle(DialogFragment.STYLE_NO_TITLE, R.style.CommonDialogTheme);
        }
    }

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        //Remove the default header from the dialog
        Dialog dialog = getDialog();
        dialog.requestWindowFeature(Window.FEATURE_NO_TITLE);
        dialog.setCanceledOnTouchOutside(isCancelableOutside());
        if (dialog.getWindow() != null && getDialogAnimationRes() > 0) {
            dialog.getWindow().setWindowAnimations(getDialogAnimationRes());
        }
        if (getOnKeyListener() !=null){
            dialog.setOnKeyListener(getOnKeyListener());
        }

        View view = null;
        if (getLayoutRes() > 0) {
            view = inflater.inflate(getLayoutRes(), container, false);
        }
        if (getDialogView() != null) {
            view = getDialogView();
        }
        bindView(view);
        return view;
    }

    @Override
    public void onViewCreated(View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);

    }

    protected DialogInterface.OnKeyListener getOnKeyListener() {
        return null;
    }

    @Override
    public void onStart() {
        super.onStart();
        Window window = getDialog().getWindow();
        if (window != null) {
            window.setNavigationBarColor(ContextCompat.getColor(getContext(),R.color.dialog_bg_color));
            //Set the form background color to be transparent
//            window.setBackgroundDrawable(new ColorDrawable(Color.TRANSPARENT));
            //Set width and height
            WindowManager.LayoutParams layoutParams = window.getAttributes();
            if (getDialogWidth() > 0) {
                layoutParams.width = getDialogWidth();
            } else {
                layoutParams.width = WindowManager.LayoutParams.WRAP_CONTENT;
            }
//            layoutParams.width = WindowManager.LayoutParams.MATCH_PARENT;
            if(getCanSwipeCloseDialog()){
                layoutParams.height = WindowManager.LayoutParams.MATCH_PARENT;
            }else{
                layoutParams.height = getDialogHeight() > 0 ? getDialogHeight() : WindowManager.LayoutParams.WRAP_CONTENT;
            }
            //Transparency
            layoutParams.dimAmount = getDimAmount();
            //Location
            layoutParams.gravity = getGravity();
            window.setAttributes(layoutParams);
            if(getCanSwipeCloseDialog()) {
                FrameLayout rootView = (FrameLayout)window.findViewById(R.id.design_bottom_sheet);
                if(getDialogHeight() > 0){
                    CoordinatorLayout.LayoutParams lParams = (CoordinatorLayout.LayoutParams) rootView.getLayoutParams();
                    lParams.height = getDialogHeight();
                    rootView.setLayoutParams(lParams);
                }

                //bottomSheet dialog 自适应不需要设置
//                else{
//                    int specW = View.MeasureSpec.makeMeasureSpec(0, View.MeasureSpec.UNSPECIFIED);
//                    int specH = View.MeasureSpec.makeMeasureSpec(0, View.MeasureSpec.UNSPECIFIED);
//                    rootView.measure(specW, specH);
//                    lParams.height = rootView.getMeasuredHeight();
//                }
//                rootView.setLayoutParams(lParams);
                if(getContext()==null) return;
                ImageView ivLine = new ImageView(getContext());
                ivLine.setImageResource(R.drawable.iv_swipe_dialog_topline);
                FrameLayout.LayoutParams topLineParams = new FrameLayout.LayoutParams(PublicSizeUtil.dp2px(getContext(),32.0f),topLineHeight);
                topLineParams.gravity = Gravity.CENTER_HORIZONTAL | Gravity.TOP;
                topLineParams.topMargin = topLineMargin;
                rootView.addView(ivLine,topLineParams);

                behavior = BottomSheetBehavior.from(rootView);//getSwipeClosePeekHeight()
                if(getSwipeFoldEnabled()){
                    behavior.setPeekHeight(getSwipeClosePeekHeight());
                }else{
                    rootView.post(new Runnable() {
                        @Override
                        public void run() {
                            behavior.setPeekHeight(rootView.getMeasuredHeight());
                        }
                    });
                    behavior.setState(BottomSheetBehavior.STATE_EXPANDED);
                }
                behavior.addBottomSheetCallback(mBottomSheetBehaviorCallback);
            }
        }
    }

    //The default pop up position is centered
    public int getGravity() {
        return Gravity.CENTER;
    }

    //Default width and height are the contents of the package
    public int getDialogHeight() {
        return WindowManager.LayoutParams.WRAP_CONTENT;
    }

    public int getDialogWidth() {
//        return WindowManager.LayoutParams.MATCH_PARENT;
        return WindowManager.LayoutParams.WRAP_CONTENT;
    }

    //Default transparency is 0.2
    public float getDimAmount() {
        return DEFAULT_DIMAMOUNT;
    }

    public String getFragmentTag() {
        return TAG;
    }

    public void show(FragmentManager fragmentManager) {
        show(fragmentManager, getFragmentTag());
    }

    protected boolean isCancelableOutside() {
        return true;
    }

    //Obtain pop-up display animation, subclass implementation
    protected int getDialogAnimationRes() {
        return 0;
    }

    //Obtain device screen width
    public static final int getScreenWidth(Context context) {
        return context.getResources().getDisplayMetrics().widthPixels;
    }

    //Obtain device screen height
    public static final int getScreenHeight(Context context) {
        return context.getResources().getDisplayMetrics().heightPixels;
    }

    @Override
    public void onDestroyView() {
        super.onDestroyView();
        if(mBottomSheetBehaviorCallback!=null && behavior!=null) behavior.removeBottomSheetCallback(mBottomSheetBehaviorCallback);
        mBottomSheetBehaviorCallback = null;
        behavior = null;
    }

    abstract public boolean getCanSwipeCloseDialog();

    abstract public int getSwipeClosePeekHeight();
    abstract public boolean getSwipeFoldEnabled();

    public int getSwipeDialogSafeInsetPixel() {
        return topLineMargin*2 + topLineHeight;
    }

    public void setDialogCanConsumerStatus(boolean consumerStatus) {
        this.dialogCanConsumerStatus = consumerStatus;
    }
}
