package com.chainup.kit.dialog;

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

import com.chainup.kit.dialog.base.KKTController;
import com.chainup.kit.dialog.base.KKBaseDialogFragment;
import com.chainup.kit.dialog.base.KKBindViewHolder;
import com.chainup.kit.dialog.listener.OnKKBindViewListener;
import com.chainup.kit.dialog.listener.OnKKViewClickListener;


public class KKTDialog extends KKBaseDialogFragment {

    private static final String KEY_TCONTROLLER = "TController";
    protected KKTController tController;

    public KKTDialog() {
        tController = new KKTController();
    }

    /**
     *When the device rotates, onCreate will be called again for data recovery
     */
    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        if (savedInstanceState != null) {
            tController = (KKTController) savedInstanceState.getSerializable(KEY_TCONTROLLER);
        }
    }

    /**
     *Save data
     */
    @Override
    public void onSaveInstanceState(Bundle outState) {
        outState.putParcelable(KEY_TCONTROLLER, tController);
        super.onSaveInstanceState(outState);
    }

    /**
     *Callback method when pop-up disappears
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
     *Obtain the pop-up XML layout interface
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
        KKBindViewHolder viewHolder = new KKBindViewHolder(view, this);
        if (tController.getIds() != null && tController.getIds().length > 0) {
            for (int id : tController.getIds()) {
                viewHolder.addOnClickListener(id);
            }
        }
        //Callback method obtains layout for processing
        if (tController.getOnBindViewListener() != null) {
            tController.getOnBindViewListener().bindView(viewHolder,this);
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

    public OnKKViewClickListener getOnViewClickListener() {
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
    public boolean getCanSwipeCloseDialog() {
        return tController.getCanSwipeCloseDialog();
    }

    @Override
    public int getSwipeClosePeekHeight() {
        return tController.getSwipeClosePeekHeight();
    }

    @Override
    public boolean getSwipeFoldEnabled() {
        return tController.getSwipeFoldEnabled();
    }

    @Override
    protected DialogInterface.OnKeyListener getOnKeyListener() {
        return tController.getOnKeyListener();
    }

    public KKTDialog show() {
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
     *Implementing using the Builder pattern
     *
     */
    public static class Builder {

        KKTController.TParams params;

        public Builder(FragmentManager fragmentManager) {
            params = new KKTController.TParams();
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
        public Builder setCanSwipeClose(boolean canSwipeClose){
            params.canSwipeClose = canSwipeClose;
            return this;
        }
        public Builder setSwipePeekHeight(int height){
            params.swipeClosePeekHeight = height;
            return this;
        }

        /**
         * @param enabled is enable fold?
         * @return KKTDialog.Builder
         * Because this default contain fold, you can by set method setSwipeFoldEnabled make it not fold.
         * */
        public Builder setSwipeFoldEnabled(boolean enabled){
            params.swipeFoldEnabled = enabled;
            return this;
        }

        /**
         *Directly pass in the control
         *
         * @param view
         * @return
         */
        public Builder setDialogView(View view) {
            params.mDialogView = view;
            return this;
        }

        /**
         *Set the pop-up width in pixels
         *
         * @param widthPx
         * @return
         */
        public Builder setWidth(int widthPx) {
            params.mWidth = widthPx;
            return this;
        }

        /**
         *Set pop-up height (px)
         *
         * @param heightPx
         * @return
         */
        public Builder setHeight(int heightPx) {
            params.mHeight = heightPx;
            return this;
        }

        /**
         *Set the pop-up window width to a ratio of 0 to 1 of the screen width
         */
        public Builder setScreenWidthAspect(Context context, float widthAspect) {
            params.mWidth = (int) (getScreenWidth(context) * widthAspect);
            return this;
        }

        /**
         *Set the pop-up height to a ratio of 0 to 1 of the screen height
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
         *Can the pop-up window be cancelled outside the pop-up area
         *
         * @param cancel
         * @return
         */
        public Builder setCancelableOutside(boolean cancel) {
            params.mIsCancelableOutside = cancel;
            return this;
        }

        /**
         *Listen for callback method when displaying a pop-up message
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
         *Retrieve the pop-up layout control object through callback
         *
         * @param listener
         * @return
         */
        public Builder setOnBindViewListener(OnKKBindViewListener listener) {
            params.bindViewListener = listener;
            return this;
        }

        /**
         *Add click events for pop-up controls
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
        public Builder setOnViewClickListener(OnKKViewClickListener listener) {
            params.mOnViewClickListener = listener;
            return this;
        }

        /**
         *Animating pop-up windows
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
         *Truly creating TDialog object instances
         *
         * @return
         */
        public KKTDialog create() {
            KKTDialog dialog = new KKTDialog();
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
