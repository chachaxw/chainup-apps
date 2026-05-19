package com.chainup.kit.views.base;

import android.content.Context;
import android.util.AttributeSet;
import android.widget.ScrollView;

public class BaseMaxHeightScrollView extends ScrollView {
    public static final String TAG = "MaxHeightScrollView";
    private int maxHeight = -1;

    public BaseMaxHeightScrollView(Context context) {
        super(context);
    }

    public BaseMaxHeightScrollView(Context context, AttributeSet attrs) {
        super(context, attrs);
    }

    public BaseMaxHeightScrollView(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
    }

    public BaseMaxHeightScrollView(Context context, AttributeSet attrs, int defStyleAttr, int defStyleRes) {
        super(context, attrs, defStyleAttr, defStyleRes);
    }

    @Override
    protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
        super.onMeasure(widthMeasureSpec, heightMeasureSpec);
        int height = getMeasuredHeight();
        int width = getMeasuredWidth();
        if (maxHeight > 0 && height > maxHeight) {
            setMeasuredDimension(width, maxHeight);
        }
    }

    public void setMaxHeight(int height) {
        this.maxHeight = height;
    }
}
