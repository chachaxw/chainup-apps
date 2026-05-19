package com.yjkj.chainup.new_version.view;

import android.animation.ValueAnimator;
import android.content.Context;
import android.content.res.TypedArray;
import android.graphics.Color;
import android.graphics.drawable.ClipDrawable;
import android.graphics.drawable.Drawable;
import android.graphics.drawable.LayerDrawable;
import android.graphics.drawable.ShapeDrawable;
import android.graphics.drawable.shapes.RoundRectShape;
import android.util.AttributeSet;
import android.view.Gravity;
import android.widget.ProgressBar;

import com.yjkj.chainup.R;

public class ZProgressBar extends ProgressBar {

    private final Context mContext;

    /**Background color (default to gray)*/
    private int mBackgroundColor  = Color.LTGRAY;
    /**Color of Progress bar (red by default)*/
    private int mProgressColor = Color.RED;
    /**Background radian (default to 0)*/
    private float mRadius = 0f;
    /**Animation duration (default 500 milliseconds)*/
    private int mDuration = 500;

    public ZProgressBar(Context context) {
        this(context, null);
    }

    public ZProgressBar(Context context, AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public ZProgressBar(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        mContext = context;
        initAttrs(attrs);
        createDrawable();
    }

    private void initAttrs(AttributeSet attrs) {
        TypedArray a = mContext.obtainStyledAttributes(attrs, R.styleable.ZProgressBar);
        mBackgroundColor = a.getColor(R.styleable.ZProgressBar_zpb_backgroundColor, mBackgroundColor);
        mProgressColor = a.getColor(R.styleable.ZProgressBar_zpb_progressColor, mProgressColor);
        mRadius = a.getDimension(R.styleable.ZProgressBar_zpb_radius, mRadius);
        mDuration = a.getInt(R.styleable.ZProgressBar_zpb_duration, mDuration);
        a.recycle();
    }

    private void createDrawable(){
        Drawable[] layers = new Drawable[2];
        Drawable background = makeBackground();
        Drawable progress = makeProgress();
        ClipDrawable clip = new ClipDrawable(progress
                , Gravity.LEFT, ClipDrawable.HORIZONTAL);
        layers[0] = background;
        layers[1] = clip;
        LayerDrawable layer = new LayerDrawable(layers);
        layer.setId(0, android.R.id.background);
        layer.setId(1, android.R.id.progress);
        setProgressDrawable(layer);
    }

    /**
     *Set animated progress
     *@param progress progress
     */
    public void setAnimProgress(int progress){
        startAnimator(progress);
    }

    private void startAnimator(int progress){
        ValueAnimator animator = ValueAnimator.ofInt(0, progress);
        animator.setDuration(mDuration);
        animator.start();
        animator.addUpdateListener(new ValueAnimator.AnimatorUpdateListener() {
            @Override
            public void onAnimationUpdate(ValueAnimator valueAnimator) {
                int value = (int) valueAnimator.getAnimatedValue();
                setProgress(value);
            }
        });
    }

    /**
     *Set default background color
     *Param color color value
     */
    public void setDefBackgroundColor(int color){
        this.mBackgroundColor = color;
        createDrawable();
    }

    /**
     *Set the color of the Progress bar
     *Param color color value
     */
    public void setProgressColor(int color){
        this.mProgressColor = color;
        createDrawable();
    }

    /**
     *Set background radian
     *Param radius
     */
    public void setRadius(float radius){
        this.mRadius = radius;
        createDrawable();
    }

    /**
     *Set animation duration
     *@param duration duration
     */
    public void setDuration(int duration){
        this.mDuration = duration;
    }

    /**
     *Generate background style drawable
     * @return drawable
     */
    private Drawable makeBackground(){
        return createShape(mRadius, mBackgroundColor);
    }

    /**
     *Generate Progress style drawable
     * @return drawable
     */
    private Drawable makeProgress(){
        return createShape(mRadius, mProgressColor);
    }

    /**
     *Create ShapeDrawable based on radius and color
     *Param radius
     *@param color color
     * @return drawable
     */
    private Drawable createShape(float radius, int color){
        ShapeDrawable shape = new ShapeDrawable();
        //Set radian
        radius = dp2px(radius);
        float[] outerRadii = new float[]{radius, radius, radius, radius, radius, radius, radius, radius};
        RoundRectShape roundShape = new RoundRectShape(outerRadii, null, null);
        shape.setShape(roundShape);
        //Set Color
        shape.getPaint().setColor(color);
        return shape;
    }

    private int dp2px(float dpValue){
        return (int)(dpValue * (mContext.getResources().getDisplayMetrics().density) + 0.5f);
    }
}
