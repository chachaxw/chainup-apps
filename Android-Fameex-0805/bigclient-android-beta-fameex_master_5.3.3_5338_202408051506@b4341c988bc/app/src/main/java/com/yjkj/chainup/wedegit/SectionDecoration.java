package com.yjkj.chainup.wedegit;


import android.content.Context;
import android.content.res.Resources;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.graphics.Rect;
import android.graphics.Typeface;
import androidx.core.content.ContextCompat;
import androidx.recyclerview.widget.RecyclerView;
import android.text.TextPaint;
import android.text.TextUtils;
import android.view.View;

import com.yjkj.chainup.R;
import com.yjkj.chainup.util.DisplayUtil;


public class SectionDecoration extends RecyclerView.ItemDecoration {
    private DecorationCallback mCallback;

    private TextPaint mTextPaint;

    private Paint mPaint;

    private int topGap;

    private Paint.FontMetrics mFontMetrics;

    private Resources mRes;
    private Context context;

    public SectionDecoration(Context context, DecorationCallback decorationCallback) {
        this.context = context;
        mRes = context.getResources();
        mCallback = decorationCallback;


        mPaint = new Paint();
        mPaint.setColor(ContextCompat.getColor(context, R.color.fill_3));
        mTextPaint = new TextPaint();
        mTextPaint.setTypeface(Typeface.DEFAULT_BOLD);
        mTextPaint.setAntiAlias(true);
        mTextPaint.setTextSize(DisplayUtil.INSTANCE.sp2px(16f));
        mTextPaint.setColor(ContextCompat.getColor(context, R.color.text_color));

        mFontMetrics = new Paint.FontMetrics();
        mTextPaint.getFontMetrics(mFontMetrics);
        //Set Origin Position
        mTextPaint.setTextAlign(Paint.Align.LEFT);
        topGap = DisplayUtils.dip2px(context, 32);
    }


    @Override
    public void getItemOffsets(Rect outRect, View view, RecyclerView parent, RecyclerView.State state) {
        super.getItemOffsets(outRect, view, parent, state);
        int pos = parent.getChildAdapterPosition(view);
        long groupId = mCallback.getGroupId(pos);
        if (groupId < 0) return;
        //Add padding first in the same group
        if (isFirstInGroup(pos)) {
            outRect.top = topGap;
        } else {
            outRect.top = 0;
        }
    }


    @Override
    public void onDrawOver(Canvas c, RecyclerView parent, RecyclerView.State state) {
        super.onDrawOver(c, parent, state);
        //The total number of sub views in the list
        int itemCount = state.getItemCount();
        //Number of sub views displayed on the current screen
        int childCount = parent.getChildCount();
        int left = parent.getPaddingLeft();
//        int right = parent.getWidth() - DisplayUtils.dip2px(context, 15);
        int right = parent.getWidth() ;
        float lineHeight = mTextPaint.getTextSize();
        long preGroupId, groupId = -1;
        for (int i = 0; i < childCount; i++) {
            View view = parent.getChildAt(i);
            int position = parent.getChildAdapterPosition(view);

            preGroupId = groupId;
            groupId = mCallback.getGroupId(position);
            if (groupId < 0 || groupId == preGroupId) continue;

            String textLine = mCallback.getGroupFirstLine(position).toUpperCase();
            if (TextUtils.isEmpty(textLine)) continue;

            int viewBottom = view.getBottom();
            float textY = Math.max(topGap, view.getTop());
            if (position + 1 < itemCount) {
                //The next one is different from the current one Move the current one
                long nextGroupId = mCallback.getGroupId(position + 1);
                if (nextGroupId != groupId && viewBottom < textY) {
                    //The last view in the group entered the header
                    textY = viewBottom;
                }
            }
            c.drawRect(left, textY - topGap, right, textY, mPaint);
            c.drawText(textLine, mRes.getDimension(R.dimen.dp_15), textY - (topGap - lineHeight) / 2, mTextPaint);
        }
    }

    private boolean isFirstInGroup(int pos) {
        if (pos == 0) {
            return true;
        } else {
            long preGroupId = mCallback.getGroupId(pos - 1);
            long groupId = mCallback.getGroupId(pos);
            return preGroupId != groupId;
        }
    }


    public interface DecorationCallback {

        long getGroupId(int position);

        String getGroupFirstLine(int position);
    }
}
