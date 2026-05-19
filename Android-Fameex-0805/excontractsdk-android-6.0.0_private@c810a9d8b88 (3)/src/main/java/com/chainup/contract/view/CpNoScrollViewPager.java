package com.chainup.contract.view;

import android.content.Context;
import android.graphics.Rect;
import android.util.AttributeSet;
import android.util.Log;
import android.view.MotionEvent;
import android.view.View;
import androidx.viewpager.widget.ViewPager;
import com.chainup.contract.R;
import java.lang.reflect.Field;


public class CpNoScrollViewPager extends ViewPager {
    private float downPointX = 0f;
    private int direction = 0;//1 right -1 left
    private boolean noScroll = true;
    private static final String TAG = CpNoScrollViewPager.class.getSimpleName();
    public CpNoScrollViewPager(Context context, AttributeSet attrs) {
        super(context, attrs);
    }

    public CpNoScrollViewPager(Context context) {
        super(context);
    }

    public void setNoScroll(boolean noScroll) {
        this.noScroll = noScroll;
    }

    @Override
    public void scrollTo(int x, int y) {
        super.scrollTo(x, y);
    }

    @Override
    public boolean onTouchEvent(MotionEvent arg0) {
        if (noScroll)
            return false;
        else
            return super.onTouchEvent(arg0);
    }

    @Override
    public boolean onInterceptTouchEvent(MotionEvent arg0) {
        if (noScroll) return false;
        if(getChildCount()<=0) return super.onInterceptTouchEvent(arg0);
        View currentLayout = getCurrentView(this);
        if(currentLayout==null) return super.onInterceptTouchEvent(arg0);
        View lineChartView = currentLayout.findViewById(R.id.lineChart);
        Rect rect = new Rect();
        if(lineChartView instanceof CpLineChart){
            CpLineChart mlineChartView = ((CpLineChart) lineChartView);
            lineChartView.getGlobalVisibleRect(rect);
            Log.d(TAG,"rect>>>"+rect+",point positionX>>>"+arg0.getRawX()+",positionY>>>"+arg0.getRawY());
            if(rect.contains((int)arg0.getRawX(),(int)arg0.getRawY())){
                Log.d(TAG,"into chart>>>"+direction);
                if(direction == -1){
                    if(mlineChartView.canLeftScroll()){
                        return false;
                    }
                }
                if(direction == 1){
                    if(mlineChartView.canRightScroll()){
                        return false;
                    }
                }
            }
        }

        return super.onInterceptTouchEvent(arg0);
    }


    private View getCurrentView(ViewPager viewPager) {
        try {
            final int currentItem = viewPager.getCurrentItem();
            for (int i = 0; i < viewPager.getChildCount(); i++) {
                final View child = viewPager.getChildAt(i);
                final ViewPager.LayoutParams layoutParams = (ViewPager.LayoutParams) child.getLayoutParams();
                Field f = layoutParams.getClass().getDeclaredField("position"); //NoSuchFieldException
                f.setAccessible(true);
                int position = ((Integer) f.get(layoutParams)); //IllegalAccessException
                if (!layoutParams.isDecor && currentItem == position) {
                    return child;
                }
            }
        } catch (NoSuchFieldException e) {
        } catch (IllegalArgumentException e) {
        } catch (IllegalAccessException e) {
        }
        return null;
    }


    @Override
    public void setCurrentItem(int item, boolean smoothScroll) {
        super.setCurrentItem(item, smoothScroll);
    }

    @Override
    public void setCurrentItem(int item) {
        super.setCurrentItem(item);
    }

    @Override
    public boolean dispatchTouchEvent(MotionEvent ev) {
        switch (ev.getAction()){
            case MotionEvent.ACTION_DOWN:{
                downPointX = ev.getX();
                break;
            }

            case MotionEvent.ACTION_MOVE:{
                direction = (downPointX - ev.getX()) > 0 ? 1 : -1;
                break;
            }


            case MotionEvent.ACTION_UP:
            case MotionEvent.ACTION_CANCEL:{
                downPointX = 0f;
                direction = 0;
                break;
            }

            default:{

            }
        }
        return super.dispatchTouchEvent(ev);
    }
}
