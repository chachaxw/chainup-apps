package com.yjkj.chainup.wedegit.gesture;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Paint.Style;
import android.graphics.PorterDuff;
import android.os.Handler;
import android.text.TextUtils;
import android.util.Pair;
import android.view.MotionEvent;
import android.view.View;

import com.yjkj.chainup.app.AppConstant;
import com.yjkj.chainup.db.service.UserDataService;
import com.yjkj.chainup.util.MD5Util;
import com.yjkj.chainup.util.Utils;

import org.json.JSONObject;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 *Gesture password path drawing
 */
public class GestureDrawline extends View {
    private int mov_x;//Declare starting point coordinates
    private int mov_y;
    private Paint paint;//Declaration brush
    private Canvas canvas;//Canvas
    private Bitmap bitmap;//Bitmap
    private List<GesturePoint> list;//A set containing various view coordinates
    private List<Pair<GesturePoint, GesturePoint>> lineList;//Record the drawn lines
    private Map<String, GesturePoint> autoCheckPointMap;//Automatically selected situation points
    private boolean isDrawEnable = true; //Allow drawing

    /**
     *The width and height of the screen
     */
    private int[] screenDispaly;

    /**
     *Which point is the finger currently in
     */
    private GesturePoint currentPoint;
    /**
     *Callback for user drawing
     */
    private GestureCallBack callBack;

    /**
     *The password for the user's current drawing
     */
    private StringBuilder passWordSb;

    /**
     *Is it a verification
     */
    private boolean isVerify;

    /**
     *PassWord passed in by the user
     */
    private String passWord;

    public GestureDrawline(Context context, List<GesturePoint> list, boolean isVerify,
                           String passWord, GestureCallBack callBack) {
        super(context);
        screenDispaly = Utils.getScreenDispaly(context);
        paint = new Paint(Paint.DITHER_FLAG);//Create a brush
        bitmap = Bitmap.createBitmap(screenDispaly[0] - 250, screenDispaly[0] - 250, Bitmap.Config.ARGB_8888); // ����λͼ�Ŀ��
        canvas = new Canvas();
        canvas.setBitmap(bitmap);
        paint.setStyle(Style.STROKE);//Set non fill
        paint.setStrokeWidth(5);//Pen width 5 pixels
        paint.setColor(Color.parseColor("#21b9f0"));//Set default connection color
        paint.setAntiAlias(true);//Do not display aliasing

        this.list = list;
        this.lineList = new ArrayList<Pair<GesturePoint, GesturePoint>>();

        initAutoCheckPointMap();
        this.callBack = callBack;

        //Initialize password cache
        this.isVerify = isVerify;
        this.passWordSb = new StringBuilder();
        this.passWord = passWord;
    }

    private void initAutoCheckPointMap() {
        autoCheckPointMap = new HashMap<String, GesturePoint>();
        autoCheckPointMap.put("1,3", getGesturePointByNum(2));
        autoCheckPointMap.put("1,7", getGesturePointByNum(4));
        autoCheckPointMap.put("1,9", getGesturePointByNum(5));
        autoCheckPointMap.put("2,8", getGesturePointByNum(5));
        autoCheckPointMap.put("3,7", getGesturePointByNum(5));
        autoCheckPointMap.put("3,9", getGesturePointByNum(6));
        autoCheckPointMap.put("4,6", getGesturePointByNum(5));
        autoCheckPointMap.put("7,9", getGesturePointByNum(8));
    }

    private GesturePoint getGesturePointByNum(int num) {
        for (GesturePoint point : list) {
            if (point.getNum() == num) {
                return point;
            }
        }
        return null;
    }

    //Draw Bitmap
    @Override
    protected void onDraw(Canvas canvas) {
        // super.onDraw(canvas);
        canvas.drawBitmap(bitmap, 0, 0, null);
    }

    //Touch Event
    @Override
    public boolean onTouchEvent(MotionEvent event) {
        if (isDrawEnable == false) {
            //Drawing not allowed for the current period
            return true;
        }
        paint.setColor(Color.parseColor("#21b9f0"));//Set default connection color
        switch (event.getAction()) {
            case MotionEvent.ACTION_DOWN:
                mov_x = (int) event.getX();
                mov_y = (int) event.getY();
                //Determine which point the current clicked position is within
                currentPoint = getPointAt(mov_x, mov_y);
                if (currentPoint != null) {
                    currentPoint.setPointState(AppConstant.Companion.getPOINT_STATE_SELECTED());
                    passWordSb.append(currentPoint.getNum());
                }
                //Canvas. drawPoint (mov_x, mov_y, paint)// Draw points
                invalidate();
                break;
            case MotionEvent.ACTION_MOVE:
                clearScreenAndDrawList();

                //Obtain which point the current moving position is within
                GesturePoint pointAt = getPointAt((int) event.getX(), (int) event.getY());
                //Represents that the current user's finger is in front of the point
                if (currentPoint == null && pointAt == null) {
                    return true;
                } else {//The finger representing the user has moved to a point
                    if (currentPoint == null) {//First, determine if the current point is null
                        //If it is empty, assign the point where the finger moves to the currentPoint
                        currentPoint = pointAt;
                        //Set the current point to true;
                        currentPoint.setPointState(AppConstant.Companion.getPOINT_STATE_SELECTED());
                        passWordSb.append(currentPoint.getNum());
                    }
                }
                if (pointAt == null || currentPoint.equals(pointAt) || AppConstant.Companion.getPOINT_STATE_SELECTED() == pointAt.getPointState()) {
                    //Click to move the area that is not in the circle, or the current clicked point is in the same position as the current moved point, or the current clicked point is in the selected state
                    //So draw a line starting from the center of the current point and ending at the position where the finger moves
                    canvas.drawLine(currentPoint.getCenterX(), currentPoint.getCenterY(), event.getX(), event.getY(), paint);// ����
                } else {
                    //If the position of the currently clicked point is different from that of the currently moved point
                    //So, starting from the center of the previous point, draw a line at the position of the point you moved your hand to
                    canvas.drawLine(currentPoint.getCenterX(), currentPoint.getCenterY(), pointAt.getCenterX(), pointAt.getCenterY(), paint);// ����
                    pointAt.setPointState(AppConstant.Companion.getPOINT_STATE_SELECTED());

                    //Determine if the middle point needs to be selected
                    GesturePoint betweenPoint = getBetweenCheckPoint(currentPoint, pointAt);
                    if (betweenPoint != null && AppConstant.Companion.getPOINT_STATE_SELECTED() != betweenPoint.getPointState()) {
                        //There is an intermediate point and it is not selected
                        Pair<GesturePoint, GesturePoint> pair1 = new Pair<GesturePoint, GesturePoint>(currentPoint, betweenPoint);
                        lineList.add(pair1);
                        passWordSb.append(betweenPoint.getNum());
                        Pair<GesturePoint, GesturePoint> pair2 = new Pair<GesturePoint, GesturePoint>(betweenPoint, pointAt);
                        lineList.add(pair2);
                        passWordSb.append(pointAt.getNum());
                        //Set middle point selection
                        betweenPoint.setPointState(AppConstant.Companion.getPOINT_STATE_SELECTED());
                        //Assign the current point;
                        currentPoint = pointAt;
                    } else {
                        Pair<GesturePoint, GesturePoint> pair = new Pair<GesturePoint, GesturePoint>(currentPoint, pointAt);
                        lineList.add(pair);
                        passWordSb.append(pointAt.getNum());
                        //Assign the current point;;
                        currentPoint = pointAt;
                    }
                }
                invalidate();
                break;
            case MotionEvent.ACTION_UP://When the fingers are raised
                JSONObject userInfoData = UserDataService.getInstance().getUserData();
                boolean isPass = false;
                if (userInfoData != null) {
                    int id = Integer.parseInt(UserDataService.getInstance().getUserInfo4UserId());
                    String gesturePwd = UserDataService.getInstance().getGesturePass();
                    String salt = MD5Util.salt;
                    if (!TextUtils.isEmpty(gesturePwd)) {
                        
                        
                        isPass = MD5Util.getMD5(salt + id + passWordSb).equals(gesturePwd);
                    }
                }

                if (isVerify) {
                    //Gesture password verification
                    //Clear all lines on the screen and only draw the lines saved in the collection
                    if (!TextUtils.isEmpty(passWord) && passWord.equals(passWordSb.toString())) {
                        //The password gesture drawn on behalf of the user is the same as the passed in password
                        callBack.checkedSuccess();
                    } else if (isPass) {
                        callBack.checkedSuccess();
                    } else {
                        //The password drawn by the user is different from the password passed in.
                        callBack.checkedFail();
                    }
                } else {
                    callBack.onGestureCodeInput(passWordSb.toString());
                }
                break;
            default:
                break;
        }
        return true;
    }

    /**
     *Specify a time to clear the drawn state
     *
     *Param delayTime Delay execution time
     */
    public void clearDrawlineState(long delayTime) {
        if (delayTime > 0) {
            //Draw red prompt route
            isDrawEnable = false;
            drawErrorPathTip();
        }
        new Handler().postDelayed(new clearStateRunnable(), delayTime);
    }

    /**
     *Thread clearing drawing state
     */
    final class clearStateRunnable implements Runnable {
        public void run() {
            //Reset passWordSb
            passWordSb = new StringBuilder();
            //Clear the collection of save points
            lineList.clear();
            //Redraw interface
            clearScreenAndDrawList();
            for (GesturePoint p : list) {
                p.setPointState(AppConstant.Companion.getPOINT_STATE_NORMAL());
            }
            invalidate();
            isDrawEnable = true;
        }
    }

    /**
     *Find which Point this point is included in the set by its position
     *
     * @param x
     * @param y
     *@return If not found, returns null, indicating that the user is currently moving between points
     */
    private GesturePoint getPointAt(int x, int y) {

        for (GesturePoint point : list) {
            //Determine x first
            int leftX = point.getLeftX();
            int rightX = point.getRightX();
            if (!(x >= leftX && x < rightX)) {
                //If false, skip to the next comparison
                continue;
            }

            int topY = point.getTopY();
            int bottomY = point.getBottomY();
            if (!(y >= topY && y < bottomY)) {
                //If false, skip to the next comparison
                continue;
            }

            //If executed here, it indicates that the position of the currently clicked point is at the position of the traversed point
            return point;
        }

        return null;
    }

    private GesturePoint getBetweenCheckPoint(GesturePoint pointStart, GesturePoint pointEnd) {
        int startNum = pointStart.getNum();
        int endNum = pointEnd.getNum();
        String key = null;
        if (startNum < endNum) {
            key = startNum + "," + endNum;
        } else {
            key = endNum + "," + startNum;
        }
        return autoCheckPointMap.get(key);
    }

    /**
     *Clear all the lines on the screen and draw the lines inside the collection
     */
    private void clearScreenAndDrawList() {
        canvas.drawColor(Color.TRANSPARENT, PorterDuff.Mode.CLEAR);
        for (Pair<GesturePoint, GesturePoint> pair : lineList) {
            canvas.drawLine(pair.first.getCenterX(), pair.first.getCenterY(),
                    pair.second.getCenterX(), pair.second.getCenterY(), paint);// ����
        }
    }

    /**
     *Verification error/inconsistent drawing prompt
     */
    private void drawErrorPathTip() {
        canvas.drawColor(Color.TRANSPARENT, PorterDuff.Mode.CLEAR);
        paint.setColor(Color.parseColor("#ffd400"));// ����Ĭ����·��ɫ
        for (Pair<GesturePoint, GesturePoint> pair : lineList) {
            pair.first.setPointState(AppConstant.Companion.getPOINT_STATE_WRONG());
            pair.second.setPointState(AppConstant.Companion.getPOINT_STATE_WRONG());
            canvas.drawLine(pair.first.getCenterX(), pair.first.getCenterY(),
                    pair.second.getCenterX(), pair.second.getCenterY(), paint);// ����
        }
        invalidate();
    }


    public interface GestureCallBack {

        /**
         *User set/entered gesture password
         */
        void onGestureCodeInput(String inputCode);

        /**
         *The password drawn on behalf of the user is the same as the password passed in
         */
        void checkedSuccess();

        /**
         *The password drawn on behalf of the user is different from the password passed in
         */
        void checkedFail();
    }

}
