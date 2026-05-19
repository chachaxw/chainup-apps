package com.chainup.kit.dialog.base;

import android.content.DialogInterface;
import android.os.Parcel;
import android.os.Parcelable;
import android.view.Gravity;
import android.view.View;

import androidx.fragment.app.FragmentManager;
import androidx.recyclerview.widget.LinearLayoutManager;


import com.example.chainup_kit.R;
import com.chainup.kit.dialog.listener.OnKKBindViewListener;
import com.chainup.kit.dialog.listener.OnKKViewClickListener;

import java.io.Serializable;

/**
 *Container class for data storage encapsulation
 *
 * @author Timmy
 * @time 2018/1/24 14:40
 * @GitHub https://github.com/Timmy-zzh/TDialog
 **/
public class KKTController<A extends KKTBaseAdapter> implements Parcelable, Serializable {

    private FragmentManager fragmentManager;
    private int layoutRes;
    private int height;
    private int width;
    private float dimAmount;
    private boolean canSwipeCloseDialog = false;
    private int swipeClosePeekHeight = -1;
    private boolean swipeFoldEnabled = true;
    private int gravity;
    private String tag;
    private int[] ids;
    private boolean isCancelableOutside;
    private OnKKViewClickListener onViewClickListener;
    private OnKKBindViewListener onBindViewListener;
    private A adapter;
    private KKTBaseAdapter.OnAdapterItemClickListener adapterItemClickListener;
    private int orientation;
    private int dialogAnimationRes;
    private View dialogView;
    private DialogInterface.OnDismissListener onDismissListener;
    private DialogInterface.OnKeyListener onKeyListener;


    //////////////////////////////////////////Parcelable persistence//////////////////////////////////////////////////////
    public KKTController() {
    }

    protected KKTController(Parcel in) {
        layoutRes = in.readInt();
        height = in.readInt();
        width = in.readInt();
        dimAmount = in.readFloat();
        gravity = in.readInt();
        canSwipeCloseDialog = in.readByte() != 0;
        swipeClosePeekHeight = in.readInt();
        swipeFoldEnabled = in.readByte() != 0;
        tag = in.readString();
        ids = in.createIntArray();
        isCancelableOutside = in.readByte() != 0;
        orientation = in.readInt();
    }

    public static final Creator<KKTController> CREATOR = new Creator<KKTController>() {
        @Override
        public KKTController createFromParcel(Parcel in) {
            return new KKTController(in);
        }

        @Override
        public KKTController[] newArray(int size) {
            return new KKTController[size];
        }
    };

    //Content description interface, no need to worry
    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeInt(layoutRes);
        dest.writeInt(height);
        dest.writeInt(width);
        dest.writeFloat(dimAmount);
        dest.writeInt(gravity);
        dest.writeString(tag);
        dest.writeIntArray(ids);
        dest.writeByte((byte) (isCancelableOutside ? 1 : 0));
        dest.writeInt(orientation);
        dest.writeInt((byte) (canSwipeCloseDialog ? 1 : 0));
        dest.writeInt(swipeClosePeekHeight);
        dest.writeInt((byte) (swipeFoldEnabled ? 1 : 0));
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////

    //get
    public FragmentManager getFragmentManager() {
        return fragmentManager;
    }

    public int getLayoutRes() {
        return layoutRes;
    }

    public void setLayoutRes(int layoutRes) {
        this.layoutRes = layoutRes;
    }

    public int getHeight() {
        return height;
    }

    public int getWidth() {
        return width;
    }

    public void setWidth(int mWidth) {
        this.width = mWidth;
    }

    public float getDimAmount() {
        return dimAmount;
    }

    public int getGravity() {
        return gravity;
    }

    public String getTag() {
        return tag;
    }

    public int[] getIds() {
        return ids;
    }

    public boolean isCancelableOutside() {
        return isCancelableOutside;
    }

    public OnKKViewClickListener getOnViewClickListener() {
        return onViewClickListener;
    }

    public int getOrientation() {
        return orientation;
    }

    public OnKKBindViewListener getOnBindViewListener() {
        return onBindViewListener;
    }

    public DialogInterface.OnDismissListener getOnDismissListener() {
        return onDismissListener;
    }

    public DialogInterface.OnKeyListener getOnKeyListener() {
        return onKeyListener;
    }

    public View getDialogView() {
        return dialogView;
    }

    //List
    public A getAdapter() {
        return adapter;
    }

    public void setAdapter(A adapter) {
        this.adapter = adapter;
    }

    public int getSwipeClosePeekHeight() {
        return swipeClosePeekHeight;
    }
    public boolean getCanSwipeCloseDialog(){
        return canSwipeCloseDialog;
    }

    public boolean getSwipeFoldEnabled(){
        return swipeFoldEnabled;
    }

    public KKTBaseAdapter.OnAdapterItemClickListener getAdapterItemClickListener() {
        return adapterItemClickListener;
    }

    public void setAdapterItemClickListener(KKTBaseAdapter.OnAdapterItemClickListener adapterItemClickListener) {
        this.adapterItemClickListener = adapterItemClickListener;
    }

    public int getDialogAnimationRes() {
        return dialogAnimationRes;
    }

    /**************************************************************************
     */
    public static class TParams<A extends KKTBaseAdapter> {
        public FragmentManager mFragmentManager;
        public int mLayoutRes;
        public boolean canSwipeClose;
        public int swipeClosePeekHeight=-1;
        public boolean swipeFoldEnabled=true;
        public int mWidth;
        public int mHeight;
        public float mDimAmount = 0.2f;
        public int mGravity = Gravity.CENTER;
        public String mTag = "TDialog";
        public int[] ids;
        public boolean mIsCancelableOutside = true;
        public OnKKViewClickListener mOnViewClickListener;
        public OnKKBindViewListener bindViewListener;
        public int mDialogAnimationRes = 0;//Pop up animation
        //List
        public A adapter;
        public KKTBaseAdapter.OnAdapterItemClickListener adapterItemClickListener;
        public int listLayoutRes;
        public int orientation = LinearLayoutManager.VERTICAL;//The default list direction for RecyclerView is vertical
        public View mDialogView;//Directly use the incoming View without parsing Xml
        public DialogInterface.OnDismissListener mOnDismissListener;
        public DialogInterface.OnKeyListener mKeyListener;

        public void apply(KKTController tController) {
            tController.fragmentManager = mFragmentManager;
            if (mLayoutRes > 0) {
                tController.layoutRes = mLayoutRes;
            }
            if (mDialogView != null) {
                tController.dialogView = mDialogView;
            }
            if (mWidth > 0) {
                tController.width = mWidth;
            }
            if (mHeight > 0) {
                tController.height = mHeight;
            }
            tController.canSwipeCloseDialog = canSwipeClose;
            tController.swipeClosePeekHeight = swipeClosePeekHeight;
            tController.swipeFoldEnabled = swipeFoldEnabled;
            tController.dimAmount = mDimAmount;
            tController.gravity = mGravity;
            tController.tag = mTag;
            if (ids != null) {
                tController.ids = ids;
            }
            tController.isCancelableOutside = mIsCancelableOutside;
            tController.onViewClickListener = mOnViewClickListener;
            tController.onBindViewListener = bindViewListener;
            tController.onDismissListener = mOnDismissListener;
            tController.dialogAnimationRes = mDialogAnimationRes;
            tController.onKeyListener =mKeyListener;

            if (adapter != null) {
                tController.setAdapter(adapter);
                if (listLayoutRes <= 0) {//Use default layout
                    tController.setLayoutRes(R.layout.dialog_recycler);
                } else {
                    tController.setLayoutRes(listLayoutRes);
                }
                tController.orientation = orientation;
            } else {
                if (tController.getLayoutRes() <= 0 && tController.getDialogView() == null) {
                    throw new IllegalArgumentException("请先调用setLayoutRes()方法设置弹窗所需的xml布局!");
                }
            }
            if (adapterItemClickListener != null) {
                tController.setAdapterItemClickListener(adapterItemClickListener);
            }

            //If the width and height are not set, the default width provided for the pop-up window is 600
            if (tController.width <= 0 && tController.height <= 0) {
                tController.width = 600;
            }
        }
    }
}
