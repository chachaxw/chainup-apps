package com.yjkj.chainup.wedegit.item;

import android.content.Context;
import android.content.res.Resources;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Rect;
import android.graphics.drawable.ColorDrawable;
import android.graphics.drawable.Drawable;
import android.util.TypedValue;
import android.view.View;

import androidx.annotation.ColorInt;
import androidx.annotation.ColorRes;
import androidx.annotation.DimenRes;
import androidx.core.content.ContextCompat;
import androidx.recyclerview.widget.GridLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import androidx.recyclerview.widget.StaggeredGridLayoutManager;

/**
 *Description: Custom Grid ItemDecoration
 *Author: LemZ
 */
public class GridItemDecoration extends RecyclerView.ItemDecoration {

    private Drawable mDivider;
    private boolean mShowLastLine;
    private int mHorizonSpan;
    private int mVerticalSpan;

    private GridItemDecoration(int horizonSpan,int verticalSpan,int color,boolean showLastLine) {
        this.mHorizonSpan = horizonSpan;
        this.mShowLastLine = showLastLine;
        this.mVerticalSpan = verticalSpan;
        mDivider = new ColorDrawable(color);
    }

    @Override
    public void onDrawOver(Canvas c, RecyclerView parent, RecyclerView.State state) {
        drawHorizontal(c, parent);
        drawVertical(c, parent);
    }

    private void drawHorizontal(Canvas c, RecyclerView parent) {
        int childCount = parent.getChildCount();

        for (int i = 0; i < childCount; i++) {
            View child = parent.getChildAt(i);

            //The bottom horizontal line of the last line is not drawn
            if (isLastRaw(parent,i,getSpanCount(parent),childCount) && !mShowLastLine){
                continue;
            }
            RecyclerView.LayoutParams params = (RecyclerView.LayoutParams) child.getLayoutParams();
            final int left = child.getLeft() - params.leftMargin;
            final int right = child.getRight() + params.rightMargin;
            final int top = child.getBottom() + params.bottomMargin;
            final int bottom = top + mHorizonSpan;

            mDivider.setBounds(left, top, right, bottom);
            mDivider.draw(c);
        }
    }

    private void drawVertical(Canvas c, RecyclerView parent) {
        int childCount = parent.getChildCount();
        for (int i = 0; i < childCount; i++) {
            final View child = parent.getChildAt(i);
            if((parent.getChildViewHolder(child).getAdapterPosition() + 1) % getSpanCount(parent) == 0){
                continue;
            }
            final RecyclerView.LayoutParams params = (RecyclerView.LayoutParams) child.getLayoutParams();
            final int top = child.getTop() - params.topMargin;
            final int bottom = child.getBottom() + params.bottomMargin + mHorizonSpan;
            final int left = child.getRight() + params.rightMargin;
            int right = left + mVerticalSpan;
////If the condition is met (the last line&&is not drawn), remove the excess part of the vertical;
            if (i==childCount-1) {
                right -= mVerticalSpan;
            }
            mDivider.setBounds(left, top, right, bottom);
            mDivider.draw(c);
        }
    }

    /**
     *Calculate offset
     * */
    @Override
    public void getItemOffsets(Rect outRect, View view, RecyclerView parent, RecyclerView.State state) {
        int spanCount = getSpanCount(parent);
        int childCount = parent.getAdapter().getItemCount();
        int itemPosition = ((RecyclerView.LayoutParams) view.getLayoutParams()).getViewLayoutPosition();

        if (itemPosition < 0){
            return;
        }

        int column = itemPosition % spanCount;
        int bottom;

        int left = column * mVerticalSpan / spanCount;
        int right = mVerticalSpan - (column + 1) * mVerticalSpan / spanCount;

        if (isLastRaw(parent, itemPosition, spanCount, childCount)){
            if (mShowLastLine){
                bottom = mHorizonSpan;
            }else{
                bottom = 0;
            }
        }else{
            bottom = mHorizonSpan;
        }
        outRect.set(left, 0, right, bottom);
    }

    /**
     *Get the number of columns
     * */
    private int getSpanCount(RecyclerView parent) {
        //Number of columns
        int mSpanCount = -1;
        RecyclerView.LayoutManager layoutManager = parent.getLayoutManager();
        if (layoutManager instanceof GridLayoutManager) {
            mSpanCount = ((GridLayoutManager) layoutManager).getSpanCount();
        } else if (layoutManager instanceof StaggeredGridLayoutManager) {
            mSpanCount = ((StaggeredGridLayoutManager) layoutManager).getSpanCount();
        }
        return mSpanCount;
    }

    /**
     *Is it the last line
     * @param parent     RecyclerView
     *@param pos The location of the current item
     *@param spanCount The number of items displayed per line
     *@param childCount Number of children
     * */
    private boolean isLastRaw(RecyclerView parent, int pos, int spanCount, int childCount) {
        RecyclerView.LayoutManager layoutManager = parent.getLayoutManager();

        if (layoutManager instanceof GridLayoutManager) {
            return getResult(pos,spanCount,childCount);
        } else if (layoutManager instanceof StaggeredGridLayoutManager) {
            int orientation = ((StaggeredGridLayoutManager) layoutManager).getOrientation();
            if (orientation == StaggeredGridLayoutManager.VERTICAL) {
                //StaggeredGridLayoutManager with vertical scrolling
                return getResult(pos,spanCount,childCount);
            } else {
                //StaggeredGridLayoutManager with horizontal scrolling
                if ((pos + 1) % spanCount == 0) {
                    return true;
                }
            }
        }
        return false;
    }

    private boolean getResult(int pos,int spanCount,int childCount){
        int remainCount = childCount % spanCount;//Obtain Remainder
        //If the last line happens to be complete;
        if (remainCount == 0){
            if(pos >= childCount - spanCount){
                return true; //The last line is not drawn at all;
            }
        }else{
            if (pos >= childCount - childCount % spanCount){
                return true;
            }
        }
        return false;
    }

    /**
     *Using Builder to construct
     * */
    public static class Builder {
        private Context mContext;
        private Resources mResources;
        private boolean mShowLastLine;
        private int mHorizonSpan;
        private int mVerticalSpan;
        private int mColor;

        public Builder(Context context) {
            mContext = context;
            mResources = context.getResources();
            mShowLastLine = true;
            mHorizonSpan = 0;
            mVerticalSpan = 0;
            mColor = Color.WHITE;
        }

        /**
         *Setting the color of separator lines through resource files
         */
        public Builder setColorResource(@ColorRes int resource) {
            setColor(ContextCompat.getColor(mContext, resource));
            return this;
        }

        /**
         *Set Color
         */
        public Builder setColor(@ColorInt int color) {
            mColor = color;
            return this;
        }

        /**
         *Set vertical spacing through dp
         * */
        public Builder setVerticalSpan(@DimenRes int vertical) {
            this.mVerticalSpan = mResources.getDimensionPixelSize(vertical);
            return this;
        }

        /**
         *Set vertical spacing through px
         * */
        public Builder setVerticalSpan(float mVertical) {
            this.mVerticalSpan = (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_PX, mVertical, mResources.getDisplayMetrics());
            return this;
        }

        /**
         *Set horizontal spacing through dp
         * */
        public Builder setHorizontalSpan(@DimenRes int horizontal) {
            this.mHorizonSpan = mResources.getDimensionPixelSize(horizontal);
            return this;
        }

        /**
         *Set horizontal spacing through px
         * */
        public Builder setHorizontalSpan(float horizontal) {
            this.mHorizonSpan = (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_PX, horizontal, mResources.getDisplayMetrics());
            return this;
        }

        /**
         *Is the last split line displayed
         * */
        public GridItemDecoration.Builder setShowLastLine(boolean show){
            mShowLastLine = show;
            return this;
        }

        public GridItemDecoration build() {
            return new GridItemDecoration(mHorizonSpan, mVerticalSpan, mColor,mShowLastLine);
        }
    }
}
