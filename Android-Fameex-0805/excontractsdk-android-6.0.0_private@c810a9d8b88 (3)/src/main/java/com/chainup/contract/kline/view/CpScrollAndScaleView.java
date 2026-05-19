package com.chainup.contract.kline.view;

import android.content.Context;
import androidx.core.view.GestureDetectorCompat;
import android.util.AttributeSet;
import android.util.Log;
import android.view.GestureDetector;
import android.view.MotionEvent;
import android.view.ScaleGestureDetector;
import android.widget.OverScroller;
import android.widget.RelativeLayout;

/**
 * @author bertking
 * @date 2019-3-15
 *@ description A view that can be slid and zoomed in
 */

public abstract class CpScrollAndScaleView extends RelativeLayout implements
        GestureDetector.OnGestureListener,
        ScaleGestureDetector.OnScaleGestureListener {

    public static final String TAG = CpScrollAndScaleView.class.getSimpleName();

    protected float longPressPositionY = 0f;

    protected int mScrollX = 0;
    protected GestureDetectorCompat mDetector;
    protected ScaleGestureDetector mScaleDetector;

    protected boolean isLongPress = false;

    private OverScroller mScroller;

    protected boolean touch = false;

    protected float mScaleX = 1f;

    protected float mScaleXMax = 3f;

    protected float mScaleXMin = 0.5f;

    private boolean mMultipleTouch = false;

    private boolean isScrollEnable = true;

    private boolean isScaleEnable = true;

    public CpScrollAndScaleView(Context context) {
        super(context);
        init();
    }

    public CpScrollAndScaleView(Context context, AttributeSet attrs) {
        super(context, attrs);
        init();
    }

    public CpScrollAndScaleView(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init();
    }

    private void init() {
        setWillNotDraw(false);
        mDetector = new GestureDetectorCompat(getContext(), this);
        mScaleDetector = new ScaleGestureDetector(getContext(), this);
        mScroller = new OverScroller(getContext());
    }

    @Override
    public boolean onDown(MotionEvent e) {
        return false;
    }

    @Override
    public void onShowPress(MotionEvent e) {

    }

    @Override
    public boolean onSingleTapUp(MotionEvent e) {
        return false;
    }

    @Override
    public boolean onScroll(MotionEvent e1, MotionEvent e2, float distanceX, float distanceY) {
        if (!isLongPress && !isMultipleTouch()) {
            scrollBy(Math.round(distanceX), 0);
            return true;
        }
        return false;
    }

    @Override
    public void onLongPress(MotionEvent e) {
        isLongPress = true;
    }


    @Override
    public boolean onFling(MotionEvent e1, MotionEvent e2, float velocityX, float velocityY) {
        if (!isTouch() && isScrollEnable()) {
            mScroller.fling(mScrollX, 0
                    , Math.round(velocityX / mScaleX), 0,
                    Integer.MIN_VALUE, Integer.MAX_VALUE,
                    0, 0);
        }
        return true;
    }

    @Override
    public void computeScroll() {
        if (mScroller.computeScrollOffset()) {
            if (!isTouch()) {
                scrollTo(mScroller.getCurrX(), mScroller.getCurrY());
            } else {
                mScroller.forceFinished(true);
            }
        }
    }

    @Override
    public void scrollBy(int x, int y) {
        scrollTo(mScrollX - Math.round(x / mScaleX), 0);
    }

    @Override
    public void scrollTo(int x, int y) {
        if (!isScrollEnable()) {
            mScroller.forceFinished(true);
            return;
        }
        int oldX = mScrollX;
        mScrollX = x;
        if (mScrollX < getMinScrollX()) {
            mScrollX = getMinScrollX();
            onRightSide();
            mScroller.forceFinished(true);
        } else if (mScrollX > getMaxScrollX()) {
            mScrollX = getMaxScrollX();
            onLeftSide();
            mScroller.forceFinished(true);
        }

        Log.d(TAG,"==============");
        onScrollChanged(mScrollX, 0, oldX, 0);
        invalidate();
    }

    @Override
    public boolean onScale(ScaleGestureDetector detector) {
        if (!isScaleEnable()) {
            return false;
        }
        float oldScale = mScaleX;
        mScaleX *= detector.getScaleFactor();
        if (mScaleX < mScaleXMin) {
            mScaleX = mScaleXMin;
        } else if (mScaleX > mScaleXMax) {
            mScaleX = mScaleXMax;
        } else {
            onScaleChanged(mScaleX, oldScale);
        }
        return true;
    }

    protected void onScaleChanged(float scale, float oldScale) {
        invalidate();
    }


    float startX = 0f;





    @Override
    public boolean onTouchEvent(MotionEvent event) {
        //Press more than 1 finger
        if (event.getPointerCount() > 1) {
            isLongPress = false;
        }
        switch (event.getAction() & MotionEvent.ACTION_MASK) {
            case MotionEvent.ACTION_DOWN:
                touch = true;
                startX = event.getX();
                longPressPositionY = event.getY();
                break;
            case MotionEvent.ACTION_MOVE:
                //Long press and move
                if (isLongPress) {
                    onLongPress(event);
                    longPressPositionY = event.getY();
                }
                break;
            case MotionEvent.ACTION_POINTER_UP:
                invalidate();
                break;
            case MotionEvent.ACTION_UP:
//                if (startX == event.getX()) {
//                    if (isLongPress) {
//                        isLongPress = false;
//                    }
//                }
                touch = false;
//                invalidate();
                break;
            case MotionEvent.ACTION_CANCEL:
                isLongPress = false;
                touch = false;
                invalidate();
                break;
            default:
                break;
        }
        mMultipleTouch = event.getPointerCount() > 1;
        this.mDetector.onTouchEvent(event);
        this.mScaleDetector.onTouchEvent(event);
        return true;
    }


    /**
     *Slid to the far left
     */
    abstract public void onLeftSide();

    /**
     *Slide to the far right
     */
    abstract public void onRightSide();

    /**
     *Is it in touch
     *
     * @return
     */
    public boolean isTouch() {
        return touch;
    }

    /**
     *Obtain the minimum value of displacement
     *
     * @return
     */
    public abstract int getMinScrollX();

    /**
     *Obtain the maximum value of displacement
     *
     * @return
     */
    public abstract int getMaxScrollX();

    /**
     *Set ScrollX
     *
     * @param scrollX
     */
    @Override
    public void setScrollX(int scrollX) {
        this.mScrollX = scrollX;
        scrollTo(scrollX, 0);
    }

    /**
     *Is it multi finger touch
     *
     * @return
     */
    public boolean isMultipleTouch() {
        return mMultipleTouch;
    }

    protected void checkAndFixScrollX() {
        if (mScrollX < getMinScrollX()) {
            mScrollX = getMinScrollX();
            mScroller.forceFinished(true);
        } else if (mScrollX > getMaxScrollX()) {
            mScrollX = getMaxScrollX();
            mScroller.forceFinished(true);
        }
    }


    @Override
    public boolean onScaleBegin(ScaleGestureDetector detector) {
        return true;
    }


    @Override
    public void onScaleEnd(ScaleGestureDetector detector) {

    }

    public float getScaleXMax() {
        return mScaleXMax;
    }

    public float getScaleXMin() {
        return mScaleXMin;
    }

    public boolean isScrollEnable() {
        return isScrollEnable;
    }

    public boolean isScaleEnable() {
        return isScaleEnable;
    }

    /**
     *Set the maximum zoom value
     */
    public void setScaleXMax(float scaleXMax) {
        mScaleXMax = scaleXMax;
    }

    /**
     *Set the minimum zoom value
     */
    public void setScaleXMin(float scaleXMin) {
        mScaleXMin = scaleXMin;
    }

    /**
     *Set whether it can slide
     */
    public void setScrollEnable(boolean scrollEnable) {
        isScrollEnable = scrollEnable;
    }

    /**
     *Set whether zoom is possible
     */
    public void setScaleEnable(boolean scaleEnable) {
        isScaleEnable = scaleEnable;
    }

    @Override
    public float getScaleX() {
        return mScaleX;
    }
}
