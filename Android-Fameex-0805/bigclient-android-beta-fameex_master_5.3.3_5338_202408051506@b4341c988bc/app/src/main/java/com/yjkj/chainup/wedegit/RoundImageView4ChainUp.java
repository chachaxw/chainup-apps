package com.yjkj.chainup.wedegit;

import android.content.Context;
import android.content.res.TypedArray;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Canvas;
import android.graphics.Matrix;
import android.graphics.Paint;
import android.graphics.PorterDuff;
import android.graphics.PorterDuffXfermode;
import android.graphics.RectF;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;
import android.util.AttributeSet;
import android.widget.ImageView;

import com.yjkj.chainup.R;


/**
 * @Author lianshangljl
 * @Date 2023/11/13-4:30 PM
 * @Email buptjinlong@163.com
 * @description
 */
public class RoundImageView4ChainUp extends ImageView {
    private Paint paint;
    private Paint paintBorder;
    private Bitmap mSrcBitmap;
    /**
     *The radian of the fillet
     */
    private float mRadius;
    private boolean mIsCircle;

    public RoundImageView4ChainUp(final Context context) {
        this(context, null);
    }

    public RoundImageView4ChainUp(Context context, AttributeSet attrs) {
        super(context, attrs);
        TypedArray ta = context.obtainStyledAttributes(attrs, R.styleable.RoundImageView);
        mRadius = ta.getDimension(R.styleable.RoundImageView_radius4Homepage, 0);
        mIsCircle = ta.getBoolean(R.styleable.RoundImageView_circle, false);
        int srcResource = attrs.getAttributeResourceValue(
                "http://schemas.android.com/apk/res/android", "src", 0);
        if (srcResource != 0) {
            mSrcBitmap = BitmapFactory.decodeResource(getResources(),
                    srcResource);
        }

        ta.recycle();
        paint = new Paint();
        paint.setAntiAlias(true);
        paintBorder = new Paint();
        paintBorder.setAntiAlias(true);
    }

    @Override
    public void onDraw(Canvas canvas) {
        int width = canvas.getWidth() - getPaddingLeft() - getPaddingRight();
        int height = canvas.getHeight() - getPaddingTop() - getPaddingBottom();
        Bitmap image = drawableToBitmap(getDrawable());
        if (mIsCircle) {
            Bitmap reSizeImage = reSizeImageC(image, width, height);
            canvas.drawBitmap(createCircleImage(reSizeImage, width, height),
                    getPaddingLeft(), getPaddingTop(), null);

        } else {

            Bitmap reSizeImage = reSizeImage(image, width, height);
            if (reSizeImage == null) {
                return;
            }
            canvas.drawBitmap(createRoundImage(reSizeImage, width, height),
                    getPaddingLeft(), getPaddingTop(), null);
        }
    }

    /**
     *Draw rounded corners
     *
     * @param source
     * @param width
     * @param height
     * @return
     */
    private Bitmap createRoundImage(Bitmap source, int width, int height) {
        Paint paint = new Paint();
        paint.setAntiAlias(true);
        Bitmap target = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888);
        Canvas canvas = new Canvas(target);
        RectF rect = new RectF(0, 0, width, height);
        canvas.drawRoundRect(rect, mRadius, mRadius, paint);
        //The core code takes the intersection part of two images
        paint.setXfermode(new PorterDuffXfermode(PorterDuff.Mode.SRC_IN));
        canvas.drawBitmap(source, 0, 0, paint);
        return target;
    }

    /**
     *Draw a circle
     *
     * @param source
     * @param width
     * @param height
     * @return
     */
    private Bitmap createCircleImage(Bitmap source, int width, int height) {

        Paint paint = new Paint();
        paint.setAntiAlias(true);
        Bitmap target = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888);
        Canvas canvas = new Canvas(target);
        canvas.drawCircle(width / 2, height / 2, Math.min(width, height) / 2,
                paint);
        //The core code takes the intersection part of two images
        paint.setXfermode(new PorterDuffXfermode(PorterDuff.Mode.SRC_IN));
        canvas.drawBitmap(source, (width - source.getWidth()) / 2,
                (height - source.getHeight()) / 2, paint);
        return target;

    }

    @Override
    protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
        int width = MeasureSpec.getSize(widthMeasureSpec);
        int height = MeasureSpec.getSize(heightMeasureSpec);
        setMeasuredDimension(width, height);
    }

    /**
     *Drawable to Bitmap
     *
     * @param drawable
     * @return
     */
    private Bitmap drawableToBitmap(Drawable drawable) {
        if (drawable == null) {
            if (mSrcBitmap != null) {
                return mSrcBitmap;
            } else {
                return null;
            }
        } else if (drawable instanceof BitmapDrawable) {
            return ((BitmapDrawable) drawable).getBitmap();
        }
        Bitmap bitmap = Bitmap.createBitmap(drawable.getIntrinsicWidth(),
                drawable.getIntrinsicHeight(), Bitmap.Config.ARGB_8888);
        Canvas canvas = new Canvas(bitmap);
        drawable.setBounds(0, 0, canvas.getWidth(), canvas.getHeight());
        drawable.draw(canvas);
        return bitmap;
    }

    /**
     *Reset the width and height of Bitmap
     *
     * @param bitmap
     * @param newWidth
     * @param newHeight
     * @return
     */
    private Bitmap reSizeImage(Bitmap bitmap, int newWidth, int newHeight) {
        if (bitmap == null) {
            return null;
        }
        int width = bitmap.getWidth();
        int height = bitmap.getHeight();
        //Calculate the zoom ratio
        float scaleWidth = ((float) newWidth) / width;
        float scaleHeight = ((float) newHeight) / height;
        //Matrix scaling bitmap
        Matrix matrix = new Matrix();

        matrix.postScale(scaleWidth, scaleHeight);
        return Bitmap.createBitmap(bitmap, 0, 0, width, height, matrix, true);
    }

    /**
     *Reset the width and height of Bitmap
     *
     * @param bitmap
     * @param newWidth
     * @param newHeight
     * @return
     */
    private Bitmap reSizeImageC(Bitmap bitmap, int newWidth, int newHeight) {
        int width = bitmap.getWidth();
        int height = bitmap.getHeight();
        int x = (newWidth - width) / 2;
        int y = (newHeight - height) / 2;
        if (x > 0 && y > 0) {
            return Bitmap.createBitmap(bitmap, 0, 0, width, height, null, true);
        }

        float scale = 1;

        if (width > height) {
            //Scale proportionally by width
            scale = ((float) newWidth) / width;

        } else {
            //Scale proportionally according to height
            //Calculate the zoom ratio
            scale = ((float) newHeight) / height;
        }
        Matrix matrix = new Matrix();
        matrix.postScale(scale, scale);
        return Bitmap.createBitmap(bitmap, 0, 0, width, height, matrix, true);
    }
}
