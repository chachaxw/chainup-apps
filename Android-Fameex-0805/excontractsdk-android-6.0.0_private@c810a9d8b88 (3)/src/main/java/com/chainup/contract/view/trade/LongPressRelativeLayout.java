package com.chainup.contract.view.trade;

import android.content.Context;
import android.util.AttributeSet;
import android.util.Log;
import android.view.MotionEvent;
import android.view.View;
import android.widget.RelativeLayout;
import androidx.annotation.Nullable;

public class LongPressRelativeLayout extends RelativeLayout {
    private OnMyLongPressClickListener listener;
    public LongPressRelativeLayout(Context context) {
        super(context);
        init();
    }

    public LongPressRelativeLayout(Context context, AttributeSet attrs) {
        super(context, attrs);
        init();
    }

    public LongPressRelativeLayout(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init();
    }

    private int mLastMotionX, mLastMotionY;
    //Has it moved
    private boolean isMoved,isReleased;
    //Long press runnable
    private Runnable mLongPressRunnable;
    //Threshold for movement
    private static final int TOUCH_SLOP = 20;

    private static final long longPressTime = 500L;
    private long downTime = 0L;

    private void init(){
        mLongPressRunnable = new Runnable() {

            @Override
            public void run() {
                if(isMoved||isReleased) return;
                performLongClick();
            }
        };
    }

    public boolean dispatchTouchEvent(MotionEvent event) {
        int x = (int) event.getRawX();
        int y = (int) event.getRawY();

        Log.d("LongPressRelativeLayout",x+"---"+y);
        switch(event.getAction()) {
            case MotionEvent.ACTION_DOWN:
                mLastMotionX = x;
                mLastMotionY = y;
                isMoved = false;
                setPressed(true);
                isReleased = false;
                downTime = System.currentTimeMillis();
                listener.onDown();
                getParent().requestDisallowInterceptTouchEvent(true);
                postDelayed(mLongPressRunnable, longPressTime);
                break;
            case MotionEvent.ACTION_MOVE:
                if(isMoved) break;
                if(Math.abs(mLastMotionX-x) > TOUCH_SLOP || Math.abs(mLastMotionY-y) > TOUCH_SLOP) {
                    //Moving beyond the threshold indicates moving
                    isMoved = true;

                    setPressed(false);
                    removeCallbacks(mLongPressRunnable);
                    getParent().requestDisallowInterceptTouchEvent(false);
                }
                break;

            case MotionEvent.ACTION_UP:{
                doRealase();

                if(System.currentTimeMillis()-downTime<100){
                    //Click
                    performClick();
                }
                break;
            }
            case MotionEvent.ACTION_CANCEL:{
                doRealase();
                break;
            }

        }
        return true;
    }

    public void doRealase(){
        //Released
        listener.onUp();
        setPressed(false);
        isReleased = true;
        getParent().requestDisallowInterceptTouchEvent(false);
        removeCallbacks(mLongPressRunnable);
    }

    public interface OnMyLongPressClickListener extends View.OnLongClickListener{
        void onDown();
        void onUp();
    }

    @Override
    public void setOnLongClickListener(@Nullable OnLongClickListener l) {
        if(l instanceof OnMyLongPressClickListener){
            listener = (OnMyLongPressClickListener) l;
        }
        super.setOnLongClickListener(l);
    }
}
