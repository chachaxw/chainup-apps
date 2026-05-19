package com.chainup.contract.view.trade;

import android.content.Context;
import android.content.res.TypedArray;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.RectF;
import android.util.AttributeSet;
import android.view.View;

import androidx.annotation.Nullable;
import androidx.core.content.ContextCompat;

import com.chainup.contract.R;
import com.chainup.contract.utils.CpSizeUtils;

/**
 *Circular progress bar
 */
public class CircleProgressView extends View {
    private int mCurrent;//Current Progress
    private Paint mBgPaint;//Background arc paint
    private Paint mProgressPaint;//Progress Paint
    private float mProgressWidth;//Progress bar width

    private Paint mTextPaint;//Progress word
    private int mProgressColor = Color.RED;//Progress Bar Color
    private int locationStart;//Start position
    private float startAngle;//Start angle

    public CircleProgressView(Context context) {
        this(context, null);
    }

    public CircleProgressView(Context context, @Nullable AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public CircleProgressView(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init(context, attrs);
    }

    private void init(Context context, AttributeSet attrs) {
        TypedArray typedArray = context.obtainStyledAttributes(attrs, R.styleable.CircleProgressView);
        locationStart = typedArray.getInt(R.styleable.CircleProgressView_location_start, 1);
        mProgressWidth = typedArray.getDimension(R.styleable.CircleProgressView_progress_width, CpSizeUtils.dp2px(4.4f));
        mProgressColor = typedArray.getColor(R.styleable.CircleProgressView_progress_color, mProgressColor);
        typedArray.recycle();

        //Background arc
        mBgPaint = new Paint();
        mBgPaint.setAntiAlias(true);
        mBgPaint.setStrokeWidth(mProgressWidth);
        mBgPaint.setStyle(Paint.Style.STROKE);
        mBgPaint.setColor(ContextCompat.getColor(context,R.color.card_bg_color_2));
        mBgPaint.setStrokeCap(Paint.Cap.ROUND);

        mTextPaint = new Paint();
        mTextPaint.setAntiAlias(true);
        mTextPaint.setTextSize(CpSizeUtils.dp2px(12f));
        mTextPaint.setColor(ContextCompat.getColor(context,R.color.text_color_1));

        //Progress arc
        mProgressPaint = new Paint();
        mProgressPaint.setAntiAlias(true);
        mProgressPaint.setStyle(Paint.Style.STROKE);
        mProgressPaint.setStrokeWidth(mProgressWidth);
        mProgressPaint.setColor(mProgressColor);
        mProgressPaint.setStrokeCap(Paint.Cap.ROUND);

        //Start angle of progress bar
        if (locationStart == 1) {//Left
            startAngle = -180;
        } else if (locationStart == 2) {//Upper
            startAngle = -90;
        } else if (locationStart == 3) {//Right
            startAngle = 0;
        } else if (locationStart == 4) {//Lower
            startAngle = 90;
        }
    }

    @Override
    protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
        int width = MeasureSpec.getSize(widthMeasureSpec);
        int height = MeasureSpec.getSize(heightMeasureSpec);
        int size = width < height ? width : height;
        setMeasuredDimension(size, size);
    }

    /**
     *Oval//Draw range
     *StartAngle//Start angle
     *SweepAngle//Sweep angle
     *UseCenter//Whether to use the center
     */
    @Override
    protected void onDraw(Canvas canvas) {
        //Draw a background arc
        RectF rectF = new RectF(mProgressWidth / 2, mProgressWidth / 2, getWidth() - mProgressWidth / 2, getHeight() - mProgressWidth / 2);
        canvas.drawArc(rectF, 0, 360, false, mBgPaint);

        //Draw current progress
        float sweepAngle = 360 * mCurrent / 100;
        canvas.drawArc(rectF, startAngle, sweepAngle, false, mProgressPaint);
        String text = mCurrent+"%";
        float txtsize = mTextPaint.measureText(text);
        canvas.drawText(text,getMeasuredWidth()/2-txtsize/2,getMeasuredHeight()/2+txtsize/4,mTextPaint);
    }

    public int getCurrent() {
        return mCurrent;
    }


    //Dynamically set the color of the ring
    public void setColor(int color){
        mProgressColor = color;
        mTextPaint.setColor(color);
        mProgressPaint.setColor(mProgressColor);
    }
    /**
     *Set Progress
     *
     * @param current
     */
    public void setCurrent(int current) {
        mCurrent = current;
        invalidate();
    }

    /**
     *Animation Effects
     *
     *@param current Precision bar progress: 0-100
     */
    public void setProgress(int current) {
        setCurrent(current);
    }

}
