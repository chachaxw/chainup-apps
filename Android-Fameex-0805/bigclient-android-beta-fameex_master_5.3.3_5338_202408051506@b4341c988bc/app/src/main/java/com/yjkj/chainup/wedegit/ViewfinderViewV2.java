package com.yjkj.chainup.wedegit;

import android.content.Context;
import android.content.res.Resources;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Point;
import android.graphics.Rect;
import android.graphics.Typeface;
import android.graphics.drawable.BitmapDrawable;
import android.text.Layout;
import android.text.StaticLayout;
import android.text.TextPaint;
import android.util.AttributeSet;
import android.view.View;

import androidx.core.content.ContextCompat;

import com.google.zxing.ResultPoint;
import com.yjkj.chainup.R;
import com.yjkj.chainup.app.CommonComponent;
import com.yjkj.chainup.manager.LanguageUtil;
import com.yjkj.chainup.util.ColorUtil;
import com.yjkj.chainup.zxing.camera.CameraManager;

import java.util.Collection;
import java.util.HashSet;


/**
 * This view is overlaid on top of the camera preview. It adds the viewfinder
 * <p>
 * rectangle and partial transparency outside it, as well as the laser scanner
 * <p>
 * animation and result points.
 */

public class ViewfinderViewV2 extends View {

    private static final String TAG = "log";

    /**
     *Time to refresh the interface
     */

    private static final long ANIMATION_DELAY = 10L;

    private static final int OPAQUE = 0xFF;


    /**
     *The length corresponding to the four green edges and corners
     */

    private int ScreenRate;


    /**
     *The width corresponding to the four green edges and corners
     */

    private static final int CORNER_WIDTH = 10;

    /**
     *The width of the middle line in the scan box
     */

    private static final int MIDDLE_LINE_WIDTH = 6;


    /**
     *The gap between the middle line in the scanning box and the left and right sides of the scanning box
     */

    private static final int MIDDLE_LINE_PADDING = 5;


    /**
     *The distance that the middle line moves each time it is refreshed
     */

    private static final int SPEEN_DISTANCE = 5;


    /**
     *Screen density of mobile phones
     */

    private static float density;

    /**
     *Font size
     */

    private static final int TEXT_SIZE = 14;

    /**
     *The distance from the font to the bottom of the scanning box
     */

    private static final int TEXT_PADDING_TOP = 40;


    /**
     *References to brush objects
     */

    private Paint paint;

    private TextPaint textPaint;


    /**
     *The topmost position of the middle sliding line
     */

    private int slideTop;


    /**
     *The bottom position of the middle sliding line
     */

    private int slideBottom;


    private Bitmap resultBitmap;

    private final int maskColor;

    private final int resultColor;


    private final int resultPointColor;
    private CameraManager cameraManager;

    private Collection<ResultPoint> possibleResultPoints;

    private Collection<ResultPoint> lastPossibleResultPoints;


    boolean isFirst;


    public ViewfinderViewV2(Context context, AttributeSet attrs) {

        super(context, attrs);


        density = context.getResources().getDisplayMetrics().density;

        //Convert pixels to dp

        ScreenRate = (int) (20 * density);


        paint = new Paint();
        textPaint = new TextPaint();
        Resources resources = getResources();

        maskColor = ContextCompat.getColor(context, R.color.barcode_viewfinder_mask);

        resultColor = ContextCompat.getColor(context, R.color.barcode_result_view);


        resultPointColor = ContextCompat.getColor(context, R.color.barcode_possible_result_points);

        possibleResultPoints = new HashSet<ResultPoint>(5);

    }

    public void setCameraManager(CameraManager cameraManager) {
        this.cameraManager = cameraManager;
    }

    @Override

    public void onDraw(Canvas canvas) {

        //The middle scanning box, if you want to modify the size of the scanning box, go to the CameraManager to modify it
        if (cameraManager == null) {
            return; // not ready yet, early draw before done configuring
        }
        cameraManager.setFramingViewSize(new Point(this.getWidth(), this.getHeight()));
        Rect frame = cameraManager.getFramingRect();
        if (frame == null) {
            return;
        }

        //Initialize the top and bottom edges of the middle line sliding

        if (!isFirst) {

            isFirst = true;

            slideTop = frame.top;

            slideBottom = frame.bottom;

        }


        //Obtain the width and height of the screen

        int width = canvas.getWidth();

        int height = canvas.getHeight();


        paint.setColor(resultBitmap != null ? resultColor : maskColor);


        //Draw the shaded area outside the scanning box, consisting of four parts: from the top of the scanning box to the top of the screen, and from the bottom of the scanning box to the bottom of the screen

        //From the left side of the scanning box to the left side of the screen, and from the right side of the scanning box to the right side of the screen

        canvas.drawRect(0, 0, width, frame.top, paint);

        canvas.drawRect(0, frame.top, frame.left, frame.bottom + 1, paint);

        canvas.drawRect(frame.right + 1, frame.top, width, frame.bottom + 1,

                paint);

        canvas.drawRect(0, frame.bottom + 1, width, height, paint);


        if (resultBitmap != null) {

            // Draw the opaque result bitmap over the scanning rectangle

            paint.setAlpha(OPAQUE);

            canvas.drawBitmap(resultBitmap, frame.left, frame.top, paint);

        } else {


            //Draw the corners on the edge of the scanning box, totaling 8 parts

            paint.setColor(Color.GREEN);

            canvas.drawRect(frame.left, frame.top, frame.left + ScreenRate,

                    frame.top + CORNER_WIDTH, paint);

            canvas.drawRect(frame.left, frame.top, frame.left + CORNER_WIDTH, frame.top

                    + ScreenRate, paint);

            canvas.drawRect(frame.right - ScreenRate, frame.top, frame.right,

                    frame.top + CORNER_WIDTH, paint);

            canvas.drawRect(frame.right - CORNER_WIDTH, frame.top, frame.right, frame.top

                    + ScreenRate, paint);

            canvas.drawRect(frame.left, frame.bottom - CORNER_WIDTH, frame.left

                    + ScreenRate, frame.bottom, paint);

            canvas.drawRect(frame.left, frame.bottom - ScreenRate,

                    frame.left + CORNER_WIDTH, frame.bottom, paint);

            canvas.drawRect(frame.right - ScreenRate, frame.bottom - CORNER_WIDTH,

                    frame.right, frame.bottom, paint);

            canvas.drawRect(frame.right - CORNER_WIDTH, frame.bottom - ScreenRate,

                    frame.right, frame.bottom, paint);


            //Draw the middle line, and each time the interface is refreshed, the middle line moves down SPEEN_ DISTANCE

            slideTop += SPEEN_DISTANCE;

            if (slideTop >= frame.bottom) {

                slideTop = frame.top;

            }

//            canvas.drawRect(frame.left + MIDDLE_LINE_PADDING, slideTop - MIDDLE_LINE_WIDTH / 2, frame.right - MIDDLE_LINE_PADDING, slideTop + MIDDLE_LINE_WIDTH / 2, paint);
            Rect lineRect = new Rect();

            lineRect.left = frame.left;

            lineRect.right = frame.right;

            lineRect.top = slideTop;

            lineRect.bottom = slideTop + 18;

            canvas.drawBitmap(((BitmapDrawable) (getResources().getDrawable(R.drawable.line_scan))).getBitmap(), null, lineRect, paint);

            //Draw the words below the scanning box

            paint.setColor(ColorUtil.INSTANCE.getColor(R.color.bg_card_color));

            paint.setTextSize(TEXT_SIZE * density);


            paint.setTypeface(Typeface.create("System", Typeface.NORMAL));

            int leftTo = (frame.right - frame.left) / 2;
            paint.setTextAlign(Paint.Align.CENTER);

            textPaint.setColor(ContextCompat.getColor(getContext(),R.color.white));
            textPaint.setTextSize(TEXT_SIZE * density);
            textPaint.setTypeface(Typeface.create("System", Typeface.NORMAL));
            textPaint.setTextAlign(Paint.Align.CENTER);

            StaticLayout layout = new StaticLayout(LanguageUtil.getString(getContext(),"scan_tip_aimToScan"), textPaint, lineRect.right - lineRect.left,
                    Layout.Alignment.ALIGN_NORMAL, 1.0F, 0.0F, true);
//            canvas.drawText(getResources().getString(R.string.scan_text), frame.centerX(), (float) (frame.bottom + (float) TEXT_PADDING_TOP * density), paint);
            canvas.save();
            canvas.translate(frame.centerX(), (float) (frame.bottom + (float) TEXT_PADDING_TOP * density));
            layout.draw(canvas);
            canvas.restore();



            //Only refresh the content of the scan box, do not refresh elsewhere

            postInvalidateDelayed(ANIMATION_DELAY, frame.left, frame.top,

                    frame.right, frame.bottom);


        }

    }


    public void drawViewfinder() {

        resultBitmap = null;

        invalidate();

    }


    /**
     * Draw a bitmap with the result points highlighted instead of the live
     * <p>
     * scanning display.
     *
     * @param barcode An image of the decoded barcode.
     */

    public void drawResultBitmap(Bitmap barcode) {

        resultBitmap = barcode;

        invalidate();

    }


    public void addPossibleResultPoint(ResultPoint point) {

        possibleResultPoints.add(point);

    }


}
