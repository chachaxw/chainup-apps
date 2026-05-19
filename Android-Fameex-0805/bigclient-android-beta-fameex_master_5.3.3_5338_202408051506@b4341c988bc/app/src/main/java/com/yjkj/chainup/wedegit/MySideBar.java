package com.yjkj.chainup.wedegit;

import android.app.Activity;
import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;

import androidx.core.content.ContextCompat;

import android.util.AttributeSet;
import android.view.MotionEvent;
import android.view.View;

import com.yjkj.chainup.R;

import java.util.ArrayList;


/**
 *ListVIew Right Navigation Panel
 *
 * @author wfs
 */
public class MySideBar extends View {

    //Do you want to click
    private boolean showBkg = false;
    //Does the monitoring panel click on the interface
    OnTouchingLetterChangedListener onTouchingLetterChangedListener;
    //26 letters
    public static String[] b = {"A", "B", "C", "D", "E", "F", "G", "H",
            "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U",
            "V", "W", "X", "Y", "Z"};
    //Selected values
    int choose = -1;
    private Context context;
    //Paintbrush
    Paint paint = new Paint();

    public MySideBar(Context context, AttributeSet attrs, int defStyle) {
        super(context, attrs, defStyle);
        this.context = context;
    }


    public MySideBar(Context context, AttributeSet attrs) {
        super(context, attrs);
        this.context = context;
    }

    public MySideBar(Context context) {
        super(context);
        this.context = context;
    }

    public void updateCoin(ArrayList<String> coins, Activity activity) {
        String[] list = coins.toArray(new String[coins.size()]);
//        b = list;
//        activity.runOnUiThread(new Runnable() {
//            @Override
//            public void run() {
//                invalidate();
//            }
//        });
    }

    /**
     *Rewrite this method
     */
    protected void onDraw(Canvas canvas) {
        super.onDraw(canvas);
        //If the panel is in a clicked state, draw the background color of the panel as gray
        if (showBkg) {
            canvas.drawColor(Color.TRANSPARENT);
        }
        //Obtain high view
        int height = getHeight();
        //Obtain the width of the View
        int width = getWidth();
        //Calculate the approximate height of each font
        if(b.length<=0){
            return ;
        }
        int singleHeight = height / 26;
        for (int i = 0; i < b.length; i++) {
            //Set sawtooth
            paint.setAntiAlias(true);
            //Set font size
            paint.setTextSize(context.getResources().getDimensionPixelSize(
                    R.dimen.sp_12));
            paint.setColor(ContextCompat.getColor(context, R.color.text_3));
            //If the font clicked is equal to any one of the 26 letters
            if (i == choose) {
                //Draw the color of the font clicked in blue
                paint.setColor(ContextCompat.getColor(context, R.color.text_color));
                paint.setFakeBoldText(true);
            }
            //Obtain the X coordinate of the font
            float xPos = width / 2 - paint.measureText(b[i]) / 2;
            //Obtain the Y coordinate of the font
            float yPos = singleHeight * i + singleHeight + DisplayUtils.px2dip(context, 5f);
            //Draw fonts on the panel
            canvas.drawText(b[i], xPos, yPos, paint);
            //Restore Canvas
            paint.reset();
        }

    }

    /**
     *Click Event
     */
    @Override
    public boolean dispatchTouchEvent(MotionEvent event) {
        //Get the status of the click
        final int action = event.getAction();
        //Y coordinate clicked
        final float y = event.getY();

        final int oldChoose = choose;
        //Monitoring
        final OnTouchingLetterChangedListener listener = onTouchingLetterChangedListener;
        //Get the current value
        final int c = (int) (y / getHeight() * b.length);
        //Make different processing based on the status of the click
        switch (action) {
            //Pressing has already started
            case MotionEvent.ACTION_DOWN:
                //Set the switch to true
                showBkg = true;
                if (oldChoose != c && listener != null) {
                    if (c >= 0 && c < b.length) {
                        //When the current clicked value is bound to listen
                        //This listener is designed as an interface on this page. The actual call is in MainActiv. That is to say, when we call this interface, we will execute the MainActivty method
                        listener.onTouchingLetterChanged(b[c]);
                        choose = c;
                        //Refresh interface
                        invalidate();
                    }
                }

                break;
            //Release to complete click
            case MotionEvent.ACTION_MOVE:
                if (oldChoose != c && listener != null) {
                    if (c >= 0 && c < b.length) {
                        listener.onTouchingLetterChanged(b[c]);
                        choose = c;
                        invalidate();
                    }
                }
                break;
            //Complete releasing the restored data and refreshing the interface
            case MotionEvent.ACTION_UP:
                showBkg = false;
                choose = -1;
                invalidate();
                break;
        }
        return true;
    }

    @Override
    public boolean onTouchEvent(MotionEvent event) {
        return super.onTouchEvent(event);
    }

    /**
     *Method of public disclosure
     *
     * @param onTouchingLetterChangedListener
     */
    public void setOnTouchingLetterChangedListener(
            OnTouchingLetterChangedListener onTouchingLetterChangedListener) {
        this.onTouchingLetterChangedListener = onTouchingLetterChangedListener;
    }

    /**
     *Interface
     *
     * @author coder
     */
    public interface OnTouchingLetterChangedListener {
        void onTouchingLetterChanged(String s);
    }

}
