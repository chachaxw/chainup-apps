package com.yjkj.chainup.new_version.view;

import android.content.Context;
import androidx.viewpager.widget.ViewPager;
import android.util.AttributeSet;
import android.view.MotionEvent;

/**
 * @Author lianshangljl
 * @Date 2023-10-22-22:10
 * @Email buptjinlong@163.com
 * @description
 */
public class NoScrollViewPager extends ViewPager {
    private boolean enabled = false;

    public NoScrollViewPager(Context context) {
        super(context);
    }

    public NoScrollViewPager(Context context, AttributeSet attrs) {
        super(context, attrs);
    }

    @Override
    public boolean onTouchEvent(MotionEvent event) {
        //Touch event not triggered
        if (this.enabled) {
            return super.onTouchEvent(event);
        }
        return false;
    }

    @Override
    public boolean onInterceptTouchEvent(MotionEvent event) {
        //Do not handle touch interception events
        if (this.enabled) {
            return super.onInterceptTouchEvent(event);
        }
        return false;
    }

    @Override
    public boolean dispatchTouchEvent(MotionEvent event) {
        //Distribute events, which is necessary. If this method is overridden, the child views of ViewPager will not receive events
        if (this.enabled) {
            return super.dispatchTouchEvent(event);
        }
        return super.dispatchTouchEvent(event);
    }

    public void setPagingEnabled(boolean enabled) {
        this.enabled = enabled;
    }
}
