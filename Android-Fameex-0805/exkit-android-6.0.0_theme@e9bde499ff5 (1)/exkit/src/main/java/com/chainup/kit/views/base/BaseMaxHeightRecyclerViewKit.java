package com.chainup.kit.views.base;

import android.content.Context;
import android.content.res.TypedArray;
import android.util.AttributeSet;
import androidx.recyclerview.widget.RecyclerView;
import com.example.chainup_kit.R;

public class BaseMaxHeightRecyclerViewKit extends RecyclerView {
    private int mMaxHeight;

    public BaseMaxHeightRecyclerViewKit(Context context) {
        super(context);
    }

    public BaseMaxHeightRecyclerViewKit(Context context, AttributeSet attrs) {
        super(context, attrs);
        initialize(context, attrs);
    }

    public BaseMaxHeightRecyclerViewKit(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        initialize(context, attrs);
    }

    private void initialize(Context context, AttributeSet attrs) {
        TypedArray arr = context.obtainStyledAttributes(attrs, R.styleable.BaseMaxHeightRecyclerView);
        mMaxHeight = arr.getLayoutDimension(R.styleable.BaseMaxHeightRecyclerView_kk_maxHeight, mMaxHeight);
        arr.recycle();
    }

    @Override
    protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
        if (mMaxHeight > 0) {
            heightMeasureSpec = MeasureSpec.makeMeasureSpec(mMaxHeight, MeasureSpec.AT_MOST);
        }
        super.onMeasure(widthMeasureSpec, heightMeasureSpec);
    }

    public void setMaxHeight(int mMaxHeight) {
        this.mMaxHeight = mMaxHeight;
    }
}

