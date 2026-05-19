package com.yjkj.chainup.util;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Canvas;
import android.graphics.Matrix;
import android.graphics.Paint;
import android.graphics.drawable.BitmapDrawable;
import android.net.Uri;
import android.os.Build;
import android.os.Environment;
import android.os.Handler;
import android.os.Message;
import android.provider.MediaStore;
import android.util.Log;
import android.view.PixelCopy;
import android.view.View;
import android.widget.ScrollView;
import android.widget.Toast;

import com.yjkj.chainup.app.ChainUpApp;
import com.yjkj.chainup.manager.LanguageUtil;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;

/**
 *Obtain a screenshot of the current page on the screen
 * Created by ykn on 2018/4/17.
 */

public class ScreenShotUtil {

    public interface OnPixelCopyListener {
        void onPixelCopySuccess(Bitmap bitmap);
        void onPixelCopyFailed();
    }

    /**
     *When it exceeds one screen, capture the scrollview screen
     *
     * @param scrollView
     * @return
     */
    public static Bitmap getBitmapByView(Context context, ScrollView scrollView, int resourceId) {
        int childHeight = 0;
        Paint paint = new Paint();
        Matrix matrix = new Matrix();
        //Obtain the actual height of scrollview
        for (int i = 0; i < scrollView.getChildCount(); i++) {
            childHeight += scrollView.getChildAt(i).getHeight();
        }
        //Create a bitmap of corresponding size
        Bitmap bitmap = Bitmap.createBitmap(scrollView.getWidth(), childHeight,
                Bitmap.Config.RGB_565);
        final Canvas canvas = new Canvas(bitmap);
        //Set Background
        BitmapDrawable bitmapDrawable = (BitmapDrawable) context.getResources().getDrawable(resourceId);
        Bitmap backgroundBitmap = bitmapDrawable.getBitmap();
        matrix.postScale(0.8f, 1f);
        canvas.drawBitmap(backgroundBitmap, matrix, paint);
        scrollView.draw(canvas);
        Log.d("yxy", "getBitmapByView: " + bitmap.getByteCount());
        return compressImage(bitmap, Bitmap.CompressFormat.JPEG);
    }

    /**
     *When there is no more than one screen, this method can be called to convert the content displayed on the current view into a bitmap
     *
     *@param view The view of the image that needs to be obtained
     *@return returns bitmap
     */
    public static Bitmap getScreenshotBitmap(View view) {
        view.setDrawingCacheEnabled(true);
        view.buildDrawingCache();  //Enable DrawingCache and create a bitmap
        Bitmap bitmap = Bitmap.createBitmap(view.getDrawingCache()); //Create a copy of DrawingCache because the bitmap obtained by DrawingCache will be recycled after it is disabled
        view.setDrawingCacheEnabled(false);  //Disable DrawingCahce, otherwise it will affect performance
        return bitmap;
    }

    /**
     *Compress images
     *
     * @param image
     * @return
     */
    private static Bitmap compressImage(Bitmap image, Bitmap.CompressFormat type) {
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        Log.d("yxy", "compressImage0: " + image.getByteCount());
        //Quality compression method, where 100 represents no compression and stores the compressed data in BIOS
        image.compress(type, 100, baos);
        Log.d("yxy", "compressImage1: " + baos.toByteArray().length);
        //Store the compressed data bao in ByteArrayInputStream
        ByteArrayInputStream isBm = new ByteArrayInputStream(baos.toByteArray());
        //Generate images from ByteArrayInputStream data
        Bitmap bitmap = BitmapFactory.decodeStream(isBm, null, null);
        return bitmap;
    }

    //Save bitmap objects to a local specified folder using IO streams
    public static void saveMyBitmap(final Bitmap bitmap,Activity activity) {
        new Thread(new Runnable() {
            @Override
            public void run() {
                String filePath = Environment.getExternalStorageDirectory().getPath();
                File file = new File(filePath + "/DCIM/Camera/" + System.currentTimeMillis() + ".png");
                try {
                    file.createNewFile();

                    FileOutputStream fOut = null;
                    fOut = new FileOutputStream(file);
                    bitmap.compress(Bitmap.CompressFormat.PNG, 100, fOut);


                    Message msg = Message.obtain();
                    msg.obj = file.getPath();
                    handler.sendMessage(msg);
                    //Toast. makeText (PayCodeActivity. this, "saved successfully", Toast. LENGTH_LONG). show();

                    NToastUtil.showTopToastNet(activity,true, LanguageUtil.getString(activity, "common_tip_saveImgSuccess"));
                    fOut.flush();
                    fOut.close();
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
        }).start();
    }


    static Handler handler = new Handler() {
        @Override
        public void handleMessage(Message msg) {
            super.handleMessage(msg);
            String picFile = (String) msg.obj;
            String[] split = picFile.split("/");
            String fileName = split[split.length - 1];
            try {
                MediaStore.Images.Media.insertImage(ChainUpApp.appContext
                        .getContentResolver(), picFile, fileName, null);
            } catch (FileNotFoundException e) {
                e.printStackTrace();
            }
            //Final notification of library updates
            ChainUpApp.appContext.sendBroadcast(new Intent(
                    Intent.ACTION_MEDIA_SCANNER_SCAN_FILE, Uri.parse("file://"
                    + picFile)));
            Toast.makeText(ChainUpApp.appContext, "图片保存图库成功", Toast.LENGTH_LONG).show();

        }
    };


//Transfer the view to be saved as an image to generate a bitmap object

    public static Bitmap createViewBitmap(View v, int color) {
        Bitmap bitmap = Bitmap.createBitmap(v.getWidth(), v.getHeight(),
                Bitmap.Config.ARGB_8888);
        bitmap = setBitmapBGColor(bitmap, color);
        Canvas canvas = new Canvas(bitmap);
        v.draw(canvas);
        return bitmap;
    }

    /**
     *Set the background color of the bitmap
     *
     *@param bitmap The bitmap that needs to be set
     *@param color Background color
     */
    public static Bitmap setBitmapBGColor(Bitmap bitmap, int color) {
        for (int i = 0; i < bitmap.getWidth(); i++) {
            for (int j = 0; j < bitmap.getHeight(); j++) {
                bitmap.setPixel(i, j, color);//Set each pixel of the bitmap to its corresponding color
            }
        }
        return bitmap;
    }


    /**
     *Splicing Two Images
     *
     * @param first
     * @param second
     * @return
     */
    public static Bitmap spliceBitmap(Context context, Bitmap first, Bitmap second) {
        int width = first.getWidth();
        int height = first.getHeight();
        Bitmap newSecond = compressImage(second, Bitmap.CompressFormat.PNG);
        Bitmap result = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_4444);
        Canvas canvas = new Canvas(result);
        canvas.drawBitmap(first, 0, 0, null);
        canvas.drawBitmap(newSecond, 0, first.getHeight() - second.getHeight(), null);
        return result;
    }


    /**
     *Make a call (jump to the dialing interface, user manually clicks to make a call)
     *
     *@param phoneNum phone number
     */
    public static void diallPhone(Context context, String phoneNum) {
        Intent intent = new Intent(Intent.ACTION_DIAL);
        Uri data = Uri.parse("tel:" + phoneNum);
        intent.setData(data);
        context.startActivity(intent);
    }


    public static Bitmap capture(Activity activity) {
        activity.getWindow().getDecorView().setDrawingCacheEnabled(true);
        Bitmap bmp = activity.getWindow().getDecorView().getDrawingCache();
        return bmp;
    }

    public static void captureV2(Activity activity, OnPixelCopyListener listener) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            View view = activity.getWindow().getDecorView();
            Bitmap bitmap = Bitmap.createBitmap(view.getWidth(), view.getHeight(), Bitmap.Config.ARGB_8888);
            PixelCopy.request(activity.getWindow(), bitmap, (copyResult) -> {
                if (copyResult == PixelCopy.SUCCESS) {
                    if (listener != null) {
                        listener.onPixelCopySuccess(bitmap);
                    }
                } else {
                    if (listener != null) {
                        listener.onPixelCopyFailed();
                    }
                }
            }, new Handler());
        } else {
            listener.onPixelCopySuccess(capture(activity));
        }
    }
}
