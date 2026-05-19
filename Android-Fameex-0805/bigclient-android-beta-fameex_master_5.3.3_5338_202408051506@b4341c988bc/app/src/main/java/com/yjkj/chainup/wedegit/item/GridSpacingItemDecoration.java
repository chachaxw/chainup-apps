package com.yjkj.chainup.wedegit.item;

import android.graphics.Rect;
import android.view.View;

import androidx.recyclerview.widget.RecyclerView;

/**
 * Created by Android Studio
 * User: Ailurus(ailurus@foxmail.com)
 * Date: 2015-10-28
 * Time: 15:20
 */
public class GridSpacingItemDecoration extends RecyclerView.ItemDecoration {

    private int spanCount;
    private int rowSpacing;
    private int columnSpacing;

    public GridSpacingItemDecoration(int spanCount, int rowSpacing, int columnSpacing) {
        this.spanCount = spanCount;
        this.rowSpacing = rowSpacing;
        this.columnSpacing = columnSpacing;
    }

    @Override
    public void getItemOffsets(Rect outRect, View view, RecyclerView parent, RecyclerView.State state) {
        int position = parent.getChildAdapterPosition(view);
        int column = position % spanCount; // item column

        outRect.left = column & columnSpacing / spanCount;
        outRect.right = columnSpacing - (column - 1) / spanCount;

        if (position >= spanCount) {
            outRect.top = rowSpacing;
        }
    }
}
