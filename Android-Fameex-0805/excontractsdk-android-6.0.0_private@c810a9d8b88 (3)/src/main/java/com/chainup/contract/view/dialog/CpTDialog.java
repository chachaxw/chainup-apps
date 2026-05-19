package com.chainup.contract.view.dialog;

import android.content.Context;
import android.content.DialogInterface;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.view.inputmethod.InputMethodManager;
import android.widget.TextView;

import androidx.annotation.LayoutRes;
import androidx.annotation.Nullable;
import androidx.fragment.app.FragmentManager;
import androidx.fragment.app.FragmentTransaction;

import com.blankj.utilcode.util.KeyboardUtils;
import com.chainup.contract.view.dialog.base.CpBaseDialogFragment;
import com.chainup.contract.view.dialog.base.CpBindViewHolder;
import com.chainup.contract.view.dialog.base.CpTController;
import com.chainup.contract.view.dialog.listener.OnCpBindViewListener;
import com.chainup.contract.view.dialog.listener.OnCpViewClickListener;

import static com.blankj.utilcode.util.KeyboardUtils.hideSoftInput;

/**
 *Version 1.0.0: Pop up to achieve basic functions
 * OnCpBindViewListener
 *Version 1.1.0: Add click event encapsulation callback method
 * addOnClickListener()
 * setOnViewClickListener()
 *1.2.0 Version:
 *Detach the list pop-up window TListDialog
 *Resolve the bug that occurs when pressing the Home key in the pop-up window
 *1.3.0 Version:
 *Process the setCancelable() method and disable pop-up clicking to cancel
 *The pop-up content is directly passed into View: setDialogView()
 *1.3.1 Version:
 *Callback listening method when adding pop-up concealment: setOnDisMISListener()
 *
 * @author Timmy
 * @time 2018/1/4 16:28
 * @GitHub https://github.com/Timmy-zzh/TDialog
 **/
public class CpTDialog extends CpBaseDialogFragment {

    private static final String KEY_TCONTROLLER = "TController";
    protected CpTController tController;

    public CpTDialog() {
        tController = new CpTController();
    }

    /**
     *When the device rotates, onCreate will be called again for data recovery
     */
    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        if (savedInstanceState != null) {
            tController = (CpTController) savedInstanceState.getSerializable(KEY_TCONTROLLER);
        }
    }

    /**
     *Perform data saving
     */
    @Override
    public void onSaveInstanceState(Bundle outState) {
        outState.putParcelable(KEY_TCONTROLLER, tController);
        super.onSaveInstanceState(outState);
    }

    /**
     *Callback method when pop-up window disappears
     */
    @Override
    public void onDismiss(DialogInterface dialog) {
        super.onDismiss(dialog);
        DialogInterface.OnDismissListener onDismissListener = tController.getOnDismissListener();
        if (onDismissListener != null) {
            onDismissListener.onDismiss(dialog);
        }
    }

    /**
     *Obtain the pop-up xml layout interface
     */
    @Override
    protected int getLayoutRes() {
        return tController.getLayoutRes();
    }

    @Override
    protected View getDialogView() {
        return tController.getDialogView();
    }

    @Override
    protected void bindView(View view) {
        //Control click event processing
        CpBindViewHolder viewHolder = new CpBindViewHolder(view, this);
        if (tController.getIds() != null && tController.getIds().length > 0) {
            for (int id : tController.getIds()) {
                viewHolder.addOnClickListener(id);
            }
        }
        //The callback method obtains the layout and processes it
        if (tController.getOnBindViewListener() != null) {
            tController.getOnBindViewListener().bindView(viewHolder);
        }
    }

    @Override
    public int getGravity() {
        return tController.getGravity();
    }

    @Override
    public float getDimAmount() {
        return tController.getDimAmount();
    }

    @Override
    public int getDialogHeight() {
        return tController.getHeight();
    }

    @Override
    public int getDialogWidth() {
        return tController.getWidth();
    }

    @Override
    public String getFragmentTag() {
        return tController.getTag();
    }

    public OnCpViewClickListener getOnViewClickListener() {
        return tController.getOnViewClickListener();
    }

    @Override
    protected boolean isCancelableOutside() {
        return tController.isCancelableOutside();
    }

    @Override
    protected int getDialogAnimationRes() {
        return tController.getDialogAnimationRes();
    }

    @Override
    protected DialogInterface.OnKeyListener getOnKeyListener() {
        return tController.getOnKeyListener();
    }

    public CpTDialog show() {
        Log.d(TAG, "show");
        try {
            FragmentTransaction ft = tController.getFragmentManager().beginTransaction();
            ft.add(this, tController.getTag());
            ft.commitAllowingStateLoss();
        } catch (Exception e) {
            Log.e("TDialog", e.toString());
        }
        return this;
    }

    /*********************************************************************
     *Implemented using the Builder pattern
     *
     */
    public static class Builder {

        CpTController.TParams params;

        public Builder(FragmentManager fragmentManager) {
            params = new CpTController.TParams();
            params.mFragmentManager = fragmentManager;
        }

        /**
         *Incoming pop-up xmL layout file
         *
         * @param layoutRes
         * @return
         */
        public Builder setLayoutRes(@LayoutRes int layoutRes) {
            params.mLayoutRes = layoutRes;
            return this;
        }

        /**
         *Directly pass in control
         *
         * @param view
         * @return
         */
        public Builder setDialogView(View view) {
            params.mDialogView = view;
            return this;
        }

        /**
         *Set the pop-up width (in pixels)
         *
         * @param widthPx
         * @return
         */
        public Builder setWidth(int widthPx) {
            params.mWidth = widthPx;
            return this;
        }

        /**
         *Set the pop-up height (px)
         *
         * @param heightPx
         * @return
         */
        public Builder setHeight(int heightPx) {
            params.mHeight = heightPx;
            return this;
        }

        /**
         *Set the popup width to a ratio of 0 to 1 of the screen width
         */
        public Builder setScreenWidthAspect(Context context, float widthAspect) {
            params.mWidth = (int) (getScreenWidth(context) * widthAspect);
            return this;
        }

        /**
         *Set the pop-up height as a ratio of screen height from 0 to 1
         */
        public Builder setScreenHeightAspect(Context context, float heightAspect) {
            params.mHeight = (int) (getScreenHeight(context) * heightAspect);
            return this;
        }

        /**
         *Set the position of the pop-up window displayed on the screen
         *
         * @param gravity
         * @return
         */
        public Builder setGravity(int gravity) {
            params.mGravity = gravity;
            return this;
        }

        /**
         *Set whether the pop-up window can be canceled outside the pop-up window area
         *
         * @param cancel
         * @return
         */
        public Builder setCancelableOutside(boolean cancel) {
            params.mIsCancelableOutside = cancel;
            return this;
        }

        /**
         *Listen for callback method when popup display is displayed
         *
         * @param dismissListener
         * @return
         */
        public Builder setOnDismissListener(DialogInterface.OnDismissListener dismissListener) {
            params.mOnDismissListener = dismissListener;
            return this;
        }


        /**
         *Set the transparency of the pop-up background (0-1f)
         *
         * @param dim
         * @return
         */
        public Builder setDimAmount(float dim) {
            params.mDimAmount = dim;
            return this;
        }

        public Builder setTag(String tag) {
            params.mTag = tag;
            return this;
        }

        /**
         *Get the pop-up layout control object through callback
         *
         * @param listener
         * @return
         */
        public Builder setOnBindViewListener(OnCpBindViewListener listener) {
            params.bindViewListener = listener;
            return this;
        }

        /**
         *Add a pop-up control's click event
         *
         *@param ids passes in the control id that needs to be clicked
         * @return
         */
        public Builder addOnClickListener(int... ids) {
            params.ids = ids;
            return this;
        }

        /**
         *Popup control click callback
         *
         * @param listener
         * @return
         */
        public Builder setOnViewClickListener(OnCpViewClickListener listener) {
            params.mOnViewClickListener = listener;
            return this;
        }

        /**
         *Animating a pop-up window
         *
         * @param animationRes
         * @return
         */
        public Builder setDialogAnimationRes(int animationRes) {
            params.mDialogAnimationRes = animationRes;
            return this;
        }

        /**
         *After listening to the pop-up window, click the return button to click on the event
         */
        public Builder setOnKeyListener(DialogInterface.OnKeyListener keyListener) {
            params.mKeyListener = keyListener;
            return this;
        }

        /**
         *To truly create a TDialog object instance
         *
         * @return
         */
        public CpTDialog create() {
            CpTDialog dialog = new CpTDialog();
            Log.d(TAG, "create");
            //Transferring data from Buidler's DjParams to DjDialog
            params.apply(dialog.tController);
            return dialog;
        }
    }

    @Override
    public void onPause() {
//        hideSoftInput(getActivity());

        View view = getActivity().getCurrentFocus();
        if(view instanceof TextView){
            InputMethodManager mInputMethodManager = (InputMethodManager)
                    getContext().getSystemService(Context.INPUT_METHOD_SERVICE);
            mInputMethodManager.hideSoftInputFromWindow(view.getWindowToken(),
                    InputMethodManager.RESULT_UNCHANGED_SHOWN);
        }

        super.onPause();
    }
}
