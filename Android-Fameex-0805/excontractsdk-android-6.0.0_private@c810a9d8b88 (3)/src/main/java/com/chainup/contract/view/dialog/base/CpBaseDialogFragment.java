package com.chainup.contract.view.dialog.base;

import android.app.Dialog;
import android.content.Context;
import android.content.DialogInterface;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.os.Bundle;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.view.WindowManager;
import android.widget.FrameLayout;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.content.ContextCompat;
import androidx.fragment.app.DialogFragment;
import androidx.fragment.app.FragmentManager;

import com.chainup.contract.R;
import com.chainup.contract.utils.CpDisplayUtils;


/**
 *Base class for DialogFragment
 *The system default onCreateDialog method returns a Dialog object without processing it
 *2. Main Operation onCreateView Method
 *Because DialogFragment inherits from Fragment, you can return the xml layout in the onCreateView() method,
 *This layout is set in the onActivityCreated() method to the Dialog object previously created by the system
 * //           @Override
 * //            public void onActivityCreated(Bundle savedInstanceState) {
 * //                super.onActivityCreated(savedInstanceState);
 * //
 * //                if (!mShowsDialog) {
 * //                return;
 * //                }
 * //
 * //                View view = getView();
 * //                if (view != null) {
 * //                if (view.getParent() != null) {
 * //                throw new IllegalStateException(
 * //                "DialogFragment can not be attached to a container view");
 * //                }
 * //                mDialog.setContentView(view);
 * //                }
 * //           }
 *The different parts of the corresponding dialog include
 *A.xml layout
 *B. Width and height
 *C. Location
 *D. Background color
 *E. Transparency
 *F. Can I click on the blank space to hide it
 *The control method is processed at onStart,
 *4. Exposure method: control processing and click event processing in the interface
 *5. Listen for callbacks. Many pop-up windows need to input information, and then return the input information through the callback method
 *6. Data saving and recovery processing when the device Configure attribute changes
 **/
public abstract class CpBaseDialogFragment extends DialogFragment {

    public static final String TAG = "TDialog";
    private static final float DEFAULT_DIMAMOUNT = 0.2F;

    protected abstract int getLayoutRes();

    protected abstract void bindView(View view);

    protected abstract View getDialogView();

    @NonNull
    @Override
    public Dialog onCreateDialog(Bundle savedInstanceState) {
        return super.onCreateDialog(savedInstanceState);
    }

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
//        setStyle(STYLE_NORMAL, R.style.ContractDialogStyle);
    }

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        //Remove Dialog default header
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

        //If there is a height in the navigation bar at the bottom of the system, set padding
//        int navBarHeight = CpDisplayUtils.getNavigationBarHeight(requireContext());
//        boolean isHas = CpDisplayUtils.checkDeviceHasNavigationBar(requireContext());
//        if(navBarHeight>0 && getGravity()==Gravity.BOTTOM && isHas){
//            FrameLayout layout = new FrameLayout(requireContext());
//            FrameLayout.LayoutParams params = new FrameLayout.LayoutParams(FrameLayout.LayoutParams.MATCH_PARENT,FrameLayout.LayoutParams.WRAP_CONTENT);
//            layout.setLayoutParams(params);
//            layout.addView(view);
//            layout.setPadding(0,0,0,navBarHeight);
//            layout.setBackground(ContextCompat.getDrawable(requireContext(),R.drawable.cp_bg_item_new_dialog));
////            view.setPadding(0,0,0,navBarHeight);
//            return layout;
//        }
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
            //Set the form background color to be transparent
            window.setBackgroundDrawable(new ColorDrawable(Color.TRANSPARENT));
            //Set width and height
            WindowManager.LayoutParams layoutParams = window.getAttributes();
            if (getDialogWidth() > 0) {
                layoutParams.width = getDialogWidth();
            } else {
                layoutParams.width = WindowManager.LayoutParams.WRAP_CONTENT;
            }
            if (getDialogHeight() > 0) {
                layoutParams.height = getDialogHeight();
            } else {
                layoutParams.height = WindowManager.LayoutParams.WRAP_CONTENT;
            }
            //Transparency
            layoutParams.dimAmount = getDimAmount();
            //Location
            layoutParams.gravity = getGravity();
            window.setAttributes(layoutParams);

        }
    }

    //The default pop-up position is centered
    public int getGravity() {
        return Gravity.CENTER;
    }

    //The default width and height is the package content
    public int getDialogHeight() {
        return WindowManager.LayoutParams.WRAP_CONTENT;
    }

    public int getDialogWidth() {
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

    //Get device screen width
    public static final int getScreenWidth(Context context) {
        return context.getResources().getDisplayMetrics().widthPixels;
    }

    //Get device screen height
    public static final int getScreenHeight(Context context) {
        return context.getResources().getDisplayMetrics().heightPixels;
    }
}
