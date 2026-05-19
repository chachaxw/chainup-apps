package com.chainup.contract.view.dialog.list;

import android.app.Activity;
import android.content.DialogInterface;
import android.util.Log;
import android.view.View;

import androidx.annotation.LayoutRes;
import androidx.fragment.app.FragmentManager;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.chainup.contract.R;
import com.chainup.contract.view.dialog.CpTDialog;
import com.chainup.contract.view.dialog.base.CpTBaseAdapter;
import com.chainup.contract.view.dialog.base.CpTController;
import com.chainup.contract.view.dialog.listener.OnCpBindViewListener;
import com.chainup.contract.view.dialog.listener.OnCpViewClickListener;

/**
 *List pop-up and TDialog implementation are handled separately
 *
 * @author Timmy
 * @time 2018/1/11 14:38
 **/
public class CpTListDialog extends CpTDialog {


    @Override
    protected void bindView(View view) {
        super.bindView(view);
        if (tController.getAdapter() != null) {//There is a list of settings
            //List
            RecyclerView recyclerView = view.findViewById(R.id.recycler_view);
            if (recyclerView == null) {
                throw new IllegalArgumentException("自定义列表xml布局,请设置RecyclerView的控件id为recycler_view");
            }
            tController.getAdapter().setTDialog(this);

            RecyclerView.LayoutManager layoutManager = new LinearLayoutManager(view.getContext(),tController.getOrientation(),false);
            recyclerView.setLayoutManager(layoutManager);
            recyclerView.setAdapter(tController.getAdapter());
            tController.getAdapter().notifyDataSetChanged();
            if (tController.getAdapterItemClickListener() != null) {
                tController.getAdapter().setOnAdapterItemClickListener(tController.getAdapterItemClickListener());
            }
        }else{
            Log.d("TDialog","列表弹窗需要先调用setAdapter()方法!");
        }
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

        //Various setXXX () methods to set data
        public Builder setLayoutRes(@LayoutRes int layoutRes) {
            params.mLayoutRes = layoutRes;
            return this;
        }

        //Set custom list layout and orientation
        public Builder setListLayoutRes(@LayoutRes int layoutRes,int orientation) {
            params.listLayoutRes = layoutRes;
            params.orientation = orientation;
            return this;
        }

        /**
         *Set the popup width to a ratio of 0 to 1 of the screen width
         */
        public Builder setScreenWidthAspect(Activity activity, float widthAspect) {
            params.mWidth = (int) (getScreenWidth(activity) * widthAspect);
            return this;
        }

        public Builder setWidth(int widthPx) {
            params.mWidth = widthPx;
            return this;
        }

        /**
         *Set screen height scale 0 - 1
         */
        public Builder setScreenHeightAspect(Activity activity, float heightAspect) {
            params.mHeight = (int) (getScreenHeight(activity) * heightAspect);
            return this;
        }

        public Builder setHeight(int heightPx) {
            params.mHeight = heightPx;
            return this;
        }

        public Builder setGravity(int gravity) {
            params.mGravity = gravity;
            return this;
        }

        public Builder setCancelOutside(boolean cancel) {
            params.mIsCancelableOutside = cancel;
            return this;
        }

        public Builder setDimAmount(float dim) {
            params.mDimAmount = dim;
            return this;
        }

        public Builder setTag(String tag) {
            params.mTag = tag;
            return this;
        }

        public Builder setOnBindViewListener(OnCpBindViewListener listener) {
            params.bindViewListener = listener;
            return this;
        }

        public Builder addOnClickListener(int... ids) {
            params.ids = ids;
            return this;
        }

        public Builder setOnViewClickListener(OnCpViewClickListener listener) {
            params.mOnViewClickListener = listener;
            return this;
        }

        //List data, need to pass in data, adapter, and item click data
        public <A extends CpTBaseAdapter> Builder setAdapter(A adapter) {
            params.adapter = adapter;
            return this;
        }

        public Builder setOnAdapterItemClickListener(CpTBaseAdapter.OnAdapterItemClickListener listener) {
            params.adapterItemClickListener = listener;
            return this;
        }

        public Builder setOnDismissListener(DialogInterface.OnDismissListener dismissListener) {
            params.mOnDismissListener = dismissListener;
            return this;
        }

        public CpTListDialog create() {
            CpTListDialog dialog = new CpTListDialog();
            //Transferring data from Buidler's DjParams to DjDialog
            params.apply(dialog.tController);
            return dialog;
        }
    }
}
