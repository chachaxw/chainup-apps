package com.chainup.contract.utils;

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
import android.os.Environment;
import android.os.Handler;
import android.os.Message;
import android.provider.MediaStore;
import android.util.Log;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ScrollView;
import android.widget.Toast;

import com.chainup.contract.app.CpMyApp;
import com.yjkj.chainup.manager.CpLanguageUtil;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;

import io.flutter.embedding.android.FlutterView;
import io.flutter.embedding.engine.renderer.FlutterRenderer;

/**
 *Get a screenshot of the current page of the screen
 * Created by ykn on 2018/4/17.
 */

public class CpScreenShotUtil {

    /**
     *Capture the scrollview screen when it exceeds one screen
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
     *@param view The view of the image you want to obtain
     *@return Return to bitmap
     */
    public static Bitmap getScreenshotBitmap(View view) {
        view.setDrawingCacheEnabled(true);
        view.buildDrawingCache();  //Enable DrawingCache and create a bitmap
        Bitmap bitmap = Bitmap.createBitmap(view.getDrawingCache()); //Create a copy of DrawingCache because the bitmap obtained by DrawingCache will be recycled after it is disabled
        view.setDrawingCacheEnabled(false);  //Disabling DrawingCahce will affect performance
        return bitmap;
    }
    public static Bitmap getScreenShotFlutterBitmap(Object renderer, View view) {
        try {

            view.setDrawingCacheEnabled(true);

            Bitmap bitmap = null;
            if (renderer.getClass() == FlutterView.class) {
                bitmap = ((FlutterView) renderer).getDrawingCache();
            } else if (renderer.getClass() == FlutterRenderer.class) {
                bitmap = ((FlutterRenderer) renderer).getBitmap();
            }

            view.setDrawingCacheEnabled(false);
            return bitmap;
        } catch (Exception ex) {
            Log.e("screenshot", "Error taking screenshot: " + ex.getMessage());
            return null;
        }
    }

    public static FlutterView getFlutterViewByView(View view){
        if(view instanceof ViewGroup){
            ViewGroup vg = (ViewGroup) view;
            int childCount = ((ViewGroup) view).getChildCount();
            for(int i=0;i<childCount;i++){
                View childView = vg.getChildAt(i);
                if(childView instanceof FlutterView){
                    return (FlutterView) childView;
                }else{
                    if(childView instanceof ViewGroup) getFlutterViewByView(childView);
                }
            }
        }
        return null;
    }

    /**
     *Compress Pictures
     *
     * @param image
     * @return
     */
    private static Bitmap compressImage(Bitmap image, Bitmap.CompressFormat type) {
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        Log.d("yxy", "compressImage0: " + image.getByteCount());
        //Quality compression method, where 100 means no compression and stores the compressed data in the BIOS
        image.compress(type, 100, baos);
        Log.d("yxy", "compressImage1: " + baos.toByteArray().length);
        //Store the compressed data into ByteArrayInputStream
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
                    //Toast. makeText (PayCodeActivity. this, "Saved successfully", Toast. LENGTH_LONG). show();

                    CpNToastUtil.showTopToastNet(activity,true, CpLanguageUtil.getString(activity, "common_tip_saveImgSuccess"));
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
                MediaStore.Images.Media.insertImage(CpMyApp.Companion.instance()
                        .getContentResolver(), picFile, fileName, null);
            } catch (FileNotFoundException e) {
                e.printStackTrace();
            }
            //Last notification gallery update
            CpMyApp.Companion.instance().sendBroadcast(new Intent(
                    Intent.ACTION_MEDIA_SCANNER_SCAN_FILE, Uri.parse("file://"
                    + picFile)));
            Toast.makeText(CpMyApp.Companion.instance(), "图片保存图库成功", Toast.LENGTH_LONG).show();

        }
    };


//Transfer in the view to be saved as a picture to generate a bitmap object

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
                bitmap.setPixel(i, j, color);//Set each pixel of the bitmap to a corresponding color
            }
        }
        return bitmap;
    }


    /**
     *Splice two pictures
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
     *Make a call (jump to the dialing interface, and the user manually clicks to make a call)
     *
     *@param phoneNum Phone Number
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
}
