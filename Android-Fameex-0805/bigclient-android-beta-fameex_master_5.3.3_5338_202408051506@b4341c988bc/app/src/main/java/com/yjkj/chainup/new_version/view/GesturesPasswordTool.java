package com.yjkj.chainup.new_version.view;

import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;

import com.chainup.contract.utils.CpSizeUtils;
import com.wangnan.library.model.Point;
import com.wangnan.library.painter.Painter;
import com.yjkj.chainup.R;

import java.util.List;

/**
 * @Author lianshangljl
 * @Date 2023/3/6-4:21 PM
 * @Email buptjinlong@163.com
 *@description Gesture password drawing style
 */
public class GesturesPasswordTool extends Painter {
    /**
     *Draw points in normal state
     *
     *@param point unit point
     *Param canvas
     *Param normalPaint Normal state brush
     */
    @Override
    public void drawNormalPoint(Point point, Canvas canvas, Paint normalPaint) {
        //1. Draw a circular contour boundary
//        normalPaint.setStyle(Paint.Style.STROKE);
//        normalPaint.setStrokeWidth(point.radius / 30.0F);
        normalPaint.setColor(Color.parseColor("#CBD2DF"));
        canvas.drawCircle(point.x, point.y, CpSizeUtils.dp2px(6f), normalPaint);
    }

    /**
     *Draw points in pressed state
     *
     *@param point unit point
     *Param canvas
     *@param pressPaint Press Status Brush
     */
    @Override
    public void drawPressPoint(Point point, Canvas canvas, Paint pressPaint) {
        //1. Draw solid points
        pressPaint.setStyle(Paint.Style.FILL);
        canvas.drawCircle(point.x, point.y, CpSizeUtils.dp2px(6f), pressPaint);
        //2. Draw a circular contour boundary
        pressPaint.setStyle(Paint.Style.STROKE);
        pressPaint.setStrokeWidth(CpSizeUtils.dp2px(1.0f));
        canvas.drawCircle(point.x, point.y, CpSizeUtils.dp2px(25.0f), pressPaint);
    }

    /**
     *Draw points in error state
     *
     *@param point unit point
     *Param canvas
     *@param errorPaint Error Status Brush
     */
    @Override
    public void drawErrorPoint(Point point, Canvas canvas, Paint errorPaint) {
        //1. Draw solid points
        errorPaint.setStyle(Paint.Style.FILL);
        canvas.drawCircle(point.x, point.y, CpSizeUtils.dp2px(6f), errorPaint);
        //2. Draw a circular contour boundary
        errorPaint.setStyle(Paint.Style.STROKE);
        errorPaint.setStrokeWidth(CpSizeUtils.dp2px(1.0f));
        canvas.drawCircle(point.x, point.y, CpSizeUtils.dp2px(25.0f), errorPaint);
    }

    /**
     *Draw Line
     *
     *@param points point set (points that have been pressed and recorded)
     *@param eventX event X coordinate (current touch position)
     *@param eventY event Y coordinate (current touch position)
     *The thickness value of the @param lineSize line
     *Param canvas
     */
    @Override
    public void drawLines(List<Point> points, float eventX, float eventY, int lineSize, Canvas canvas) {
        super.drawLines(points, eventX, eventY, lineSize, canvas);
        //Draw a triangular arrow (reviewed the Trigonometric functions again... ╮ (╭ system) ╭)
        //1. Trigonometric functions operation to determine the coordinates of three vertices
//        int radius = getGestureLockView().getRadius();
//        for (int i = 0; i < points.size() - 1; i++) {
//            Point prePoint = points.get(i);
//            Point nextPoint = points.get(i + 1);
//            int dx = nextPoint.x - prePoint.x;
//            int dy = nextPoint.y - prePoint.y;
//            int x1 = prePoint.x + (int) (2 * radius / 3 * dx / Math.sqrt(dx * dx + dy * dy));
//            int y1 = prePoint.y + (int) (2 * radius / 3 * dy / Math.sqrt(dx * dx + dy * dy));
//            int x2 = prePoint.x + (int) (radius / 2 * dx / Math.sqrt(dx * dx + dy * dy));
//            int y2 = prePoint.y + (int) (radius / 2 * dy / Math.sqrt(dx * dx + dy * dy));
//            int border = (int) Math.sqrt((x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2));
//            int distanceY = (int) (border * dx / Math.sqrt(dx * dx + dy * dy));
//            int distanceX = (int) (border * dy / Math.sqrt(dx * dx + dy * dy));
////2. Record the coordinates of the three vertices of the triangle (the third vertex is (x1, y1))
//            int top1_x = x2 + distanceX;
//            int top1_y = y2 - distanceY;
//            int top2_x = x2 - distanceX;
//            int top2_y = y2 + distanceY;
////3. Generate triangle paths
//            Path path = new Path();
//            path.moveTo(top1_x, top1_y);
//            path.lineTo(top2_x, top2_y);
//            path.lineTo(x1, y1);
//            path.close();
////4. Distinguishing point state drawing path
//If (pre Point. status==Point. POINT_PRESSS-STATUS) {//Press status
//                Paint.Style style = mPressPaint.getStyle();
//                mPressPaint.setStyle(Paint.Style.FILL);
//                canvas.drawPath(path, mPressPaint);
//                mPressPaint.setStyle(style);
//Else if (pre Point. status==Point. POINT-ERROR_STATUS) {//Error status
//                Paint.Style style = mErrorPaint.getStyle();
//                mErrorPaint.setStyle(Paint.Style.FILL);
//                canvas.drawPath(path, mErrorPaint);
//                mErrorPaint.setStyle(style);
//            }
//        }
    }
}
