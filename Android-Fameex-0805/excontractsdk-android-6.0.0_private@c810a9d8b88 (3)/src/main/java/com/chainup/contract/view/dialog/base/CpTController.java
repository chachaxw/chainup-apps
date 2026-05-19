package com.chainup.contract.view.dialog.base;

import android.content.DialogInterface;
import android.os.Parcel;
import android.os.Parcelable;
import android.view.Gravity;
import android.view.View;

import androidx.fragment.app.FragmentManager;
import androidx.recyclerview.widget.LinearLayoutManager;

import com.chainup.contract.R;
import com.chainup.contract.view.dialog.listener.OnCpBindViewListener;
import com.chainup.contract.view.dialog.listener.OnCpViewClickListener;

import java.io.Serializable;

/**
 *Container class for data storage encapsulation
 *
 * @author Timmy
 * @time 2018/1/24 14:40
 * @GitHub https://github.com/Timmy-zzh/TDialog
 **/
public class CpTController<A extends CpTBaseAdapter> implements Parcelable, Serializable {

    private FragmentManager fragmentManager;
    private int layoutRes;
    private int height;
    private int width;
    private float dimAmount;
    private int gravity;
    private String tag;
    private int[] ids;
    private boolean isCancelableOutside;
    private OnCpViewClickListener onViewClickListener;
    private OnCpBindViewListener onBindViewListener;
    private A adapter;
    private CpTBaseAdapter.OnAdapterItemClickListener adapterItemClickListener;
    private int orientation;
    private int dialogAnimationRes;
    private View dialogView;
    private DialogInterface.OnDismissListener onDismissListener;
    private DialogInterface.OnKeyListener onKeyListener;


    //////////////////////////////////////////Parcelable Persistence//////////////////////////////////////////////////////
    public CpTController() {
    }

    protected CpTController(Parcel in) {
        layoutRes = in.readInt();
        height = in.readInt();
        width = in.readInt();
        dimAmount = in.readFloat();
        gravity = in.readInt();
        tag = in.readString();
        ids = in.createIntArray();
        isCancelableOutside = in.readByte() != 0;
        orientation = in.readInt();
    }

    public static final Creator<CpTController> CREATOR = new Creator<CpTController>() {
        @Override
        public CpTController createFromParcel(Parcel in) {
            return new CpTController(in);
        }

        @Override
        public CpTController[] newArray(int size) {
            return new CpTController[size];
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

    public OnCpViewClickListener getOnViewClickListener() {
        return onViewClickListener;
    }

    public int getOrientation() {
        return orientation;
    }

    public OnCpBindViewListener getOnBindViewListener() {
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

    public CpTBaseAdapter.OnAdapterItemClickListener getAdapterItemClickListener() {
        return adapterItemClickListener;
    }

    public void setAdapterItemClickListener(CpTBaseAdapter.OnAdapterItemClickListener adapterItemClickListener) {
        this.adapterItemClickListener = adapterItemClickListener;
    }

    public int getDialogAnimationRes() {
        return dialogAnimationRes;
    }

    /**************************************************************************
     */
    public static class TParams<A extends CpTBaseAdapter> {
        public FragmentManager mFragmentManager;
        public int mLayoutRes;
        public int mWidth;
        public int mHeight;
        public float mDimAmount = 0.2f;
        public int mGravity = Gravity.CENTER;
        public String mTag = "TDialog";
        public int[] ids;
        public boolean mIsCancelableOutside = true;
        public OnCpViewClickListener mOnViewClickListener;
        public OnCpBindViewListener bindViewListener;
        public int mDialogAnimationRes = 0;//Pop-up animation
        //List
        public A adapter;
        public CpTBaseAdapter.OnAdapterItemClickListener adapterItemClickListener;
        public int listLayoutRes;
        public int orientation = LinearLayoutManager.VERTICAL;//The default RecyclerView list direction is vertical
        public View mDialogView;//Directly use the incoming View without parsing the Xml
        public DialogInterface.OnDismissListener mOnDismissListener;
        public DialogInterface.OnKeyListener mKeyListener;

        public void apply(CpTController tController) {
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
