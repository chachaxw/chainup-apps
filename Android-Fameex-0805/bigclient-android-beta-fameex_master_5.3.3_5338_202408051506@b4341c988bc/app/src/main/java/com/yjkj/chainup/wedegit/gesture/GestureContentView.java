package com.yjkj.chainup.wedegit.gesture;

import android.content.Context;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;


import com.yjkj.chainup.R;
import com.yjkj.chainup.util.Utils;

import java.util.ArrayList;
import java.util.List;

/**
 *Gesture Password Container Class
 */
public class GestureContentView extends ViewGroup {

    private int baseNum = 3;

    private int[] screenDispaly;

    /**
     *The width of each point area
     */
    private int blockWidth;

    /**
     *Click to
     */
    private int distance;
    /**
     *Declare a set to encapsulate the coordinate set
     */
    private List<GesturePoint> list;
    private Context context;
    private boolean isVerify;
    private GestureDrawline gestureDrawline;

    /**
     *Container containing 9 ImageViews, initialization
     *
     * @param context
     *Is @param isVerify a verification gesture password
     *@param passWord user passes in password
     *The callback after the @param callBack gesture is drawn
     */
    public GestureContentView(Context context, boolean isVerify, String passWord, GestureDrawline.GestureCallBack callBack) {
        super(context);
        screenDispaly = Utils.getScreenDispaly(context);
        blockWidth = (screenDispaly[0]-250) / 3;
//        blockWidth = 30;
        this.list = new ArrayList<GesturePoint>();
        this.context = context;
        this.isVerify = isVerify;
        //Add 9 icons
        addChild();
        //Initialize a view that can draw lines
        gestureDrawline = new GestureDrawline(context, list, isVerify, passWord, callBack);
    }

    private void addChild() {
        for (int i = 0; i < 9; i++) {
            ImageView image = new ImageView(context);
            image.setBackgroundResource(R.drawable.gesture_node_normal);
            this.addView(image);
            invalidate();
            //Which line
            int row = i / 3;
            //Which column
            int col = i % 3;
            //Define each attribute of a point
            int leftX = col * blockWidth + blockWidth / baseNum;
            int topY = row * blockWidth + blockWidth / baseNum;
            int rightX = col * blockWidth + blockWidth - blockWidth / baseNum;
            int bottomY = row * blockWidth + blockWidth - blockWidth / baseNum;
            GesturePoint p = new GesturePoint(leftX, rightX, topY, bottomY, image, i + 1);
            this.list.add(p);
        }
    }

    public void setParentView(ViewGroup parent) {
        //Obtain the width of the screen
        int width =  (screenDispaly[0]-250);
        LayoutParams layoutParams = new LayoutParams(width, width);
        this.setLayoutParams(layoutParams);
        gestureDrawline.setLayoutParams(layoutParams);
        parent.addView(gestureDrawline);
        parent.addView(this);
    }

    @Override
    protected void onLayout(boolean changed, int l, int t, int r, int b) {
        for (int i = 0; i < getChildCount(); i++) {
            //Which line
            int row = i / 3;
            //Which column
            int col = i % 3;
            View v = getChildAt(i);
            v.layout(col * blockWidth + blockWidth / baseNum, row * blockWidth + blockWidth / baseNum,
                    col * blockWidth + blockWidth - blockWidth / baseNum, row * blockWidth + blockWidth - blockWidth / baseNum);
        }
    }

    @Override
    protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
        super.onMeasure(widthMeasureSpec, heightMeasureSpec);
        //Traverse to set the size of each subview
//        for (int i = 0; i < getChildCount(); i++) {
//            View v = getChildAt(i);
//            v.measure(widthMeasureSpec, heightMeasureSpec);
//        }
    }

    /**
     *Retain path for a long delay time
     *
     * @param delayTime
     */
    public void clearDrawlineState(long delayTime) {
        gestureDrawline.clearDrawlineState(delayTime);
    }

}
