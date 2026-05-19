package com.chainup.contract.view;

import android.content.Context;
import android.util.AttributeSet;
import android.util.Log;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;

import androidx.swiperefreshlayout.widget.SwipeRefreshLayout;

import com.google.android.material.appbar.AppBarLayout;
import com.scwang.smart.refresh.layout.SmartRefreshLayout;

public class CustomSwipeRefreshLayout extends SmartRefreshLayout {
    final String TAG = this.getClass().getSimpleName();
    AppBarLayout appBarLayout;
    private int appBarLayoutVerticalOffset = 0;
    private float startY;
    private float startX;
    private boolean flag;

    public CustomSwipeRefreshLayout(Context context, AttributeSet attrs) {
        super(context, attrs);
    }

    @Override
    protected void onFinishInflate() {
        super.onFinishInflate();
        findAppBarLayout(this);
        if(appBarLayout != null){
            appBarLayout.addOnOffsetChangedListener(new AppBarLayout.OnOffsetChangedListener() {
                @Override
                public void onOffsetChanged(AppBarLayout appBarLayout, int verticalOffset) {
                    appBarLayoutVerticalOffset = verticalOffset;
                }
            });
        }
    }

    private void findAppBarLayout(ViewGroup pView){
        int childCount = pView.getChildCount();
        for (int i = 0; i < childCount; i++){
            View cView = pView.getChildAt(i);
            if(cView instanceof AppBarLayout){
                appBarLayout = (AppBarLayout)cView;
            }else{
                if(cView instanceof ViewGroup) findAppBarLayout((ViewGroup)cView);
            }
        }
    }

    @Override
    public boolean onInterceptTouchEvent(MotionEvent ev) {
        int action = ev.getAction();
        switch (action) {
            case MotionEvent.ACTION_DOWN:
                //Record the position of the finger press
                startY = ev.getY();
                startX = ev.getX();
                //Initialization Tag
                flag = false;
                break;
            case MotionEvent.ACTION_MOVE:
                //If flag=true, child needs to receive events without blocking them
                if(flag) {
                    return false;
                }

                //Get the current finger position
                float endY = ev.getY();
                float endX = ev.getX();
                float distanceX = Math.abs(endX - startX);
                float distanceY = Math.abs(endY - startY);
                //If the X-axis displacement is greater than the Y-axis displacement, it will be handed over to the child for processing without interception
                if(distanceX > distanceY || appBarLayoutVerticalOffset < 0) {
                    flag = true;
                    return false;
                }
                break;
            case MotionEvent.ACTION_UP:
            case MotionEvent.ACTION_CANCEL:
                //Initialization Tag
                flag = false;
                break;
        }
        //If the Y-axis displacement is greater than the X-axis, the event is handed over to swineRefreshLayout for processing.
        return super.onInterceptTouchEvent(ev);
    }
}
