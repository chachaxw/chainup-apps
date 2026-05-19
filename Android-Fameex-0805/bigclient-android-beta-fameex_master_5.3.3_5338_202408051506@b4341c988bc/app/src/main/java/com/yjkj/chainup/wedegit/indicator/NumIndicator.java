package com.yjkj.chainup.wedegit.indicator;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.util.AttributeSet;

import com.yjkj.chainup.util.SystemV2Utils;
import com.youth.banner.indicator.BaseIndicator;
import com.youth.banner.util.BannerUtils;

/**
 *Customize the digital indicator demo, which is relatively simple and can be used specifically by oneself
 *
 *There are no custom attribute parameters used here, you can consider adding them
 */
public class NumIndicator extends BaseIndicator {
    private int width;
    private int height;
    private int radius;

    public NumIndicator(Context context) {
        this(context, null);
    }

    public NumIndicator(Context context, AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public NumIndicator(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        mPaint.setTextSize(BannerUtils.dp2px(12));
        mPaint.setTextAlign(Paint.Align.CENTER);
        mPaint.setTypeface(SystemV2Utils.Companion.getFontRe());
        width = (int) BannerUtils.dp2px(24);
        height = (int) BannerUtils.dp2px(16);
        radius = (int) BannerUtils.dp2px(20);
    }

    @Override
    protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
        super.onMeasure(widthMeasureSpec, heightMeasureSpec);
        int count = config.getIndicatorSize();
        if (count <= 1) {
            return;
        }
        setMeasuredDimension(width, height);
    }

    @Override
    protected void onDraw(Canvas canvas) {
        super.onDraw(canvas);
        int count = config.getIndicatorSize();
        if (count <= 1) {
            return;
        }
        //Bottom Background
       /* RectF rectF = new RectF(0, 0, width, height);
        mPaint.setColor(Color.parseColor("#70000000"));
        canvas.drawRoundRect(rectF, radius, radius, mPaint);*/

        String text = config.getCurrentPosition() + 1 + "/" + count;
        mPaint.setColor(Color.WHITE);
        canvas.drawText(text, width / 2 , (float) (height * 0.7), mPaint);

    }

}
