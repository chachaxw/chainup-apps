package com.chainup.contract.utils;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.pm.ApplicationInfo;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.PointF;
import android.net.Uri;
import android.os.Build;
import android.os.Environment;
import android.view.Gravity;
import android.view.View;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.google.zxing.BarcodeFormat;
import com.google.zxing.EncodeHintType;
import com.google.zxing.MultiFormatWriter;
import com.google.zxing.WriterException;
import com.google.zxing.common.BitMatrix;
import com.google.zxing.qrcode.QRCodeWriter;
import com.google.zxing.qrcode.decoder.ErrorCorrectionLevel;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Hashtable;

/**
 * @Author lianshangljl
 * @Date 2020-02-28-16:51
 * @Email buptjinlong@163.com
 *@ description Tool for generating barcode and QR code
 */
public class CpZXingUtils {

    public final static int SHARE_CODE = 0x000111;
    /**
     *The address or string to convert when generating the QR code can be in Chinese
     *
     * @param url
     * @param width
     * @param height
     * @return
     */
    public static Bitmap createQRImage(String url, final int width, final int height) {
        try {
            //Determining the legality of a URL
            if (url == null || "".equals(url) || url.length() < 1) {
                return null;
            }
            Hashtable hints = new Hashtable();
            hints.put(EncodeHintType.CHARACTER_SET, "utf-8");
            hints.put(EncodeHintType.MARGIN, 0); //Blank margin settings
            hints.put(EncodeHintType.ERROR_CORRECTION, ErrorCorrectionLevel.H);
            //Image data conversion using matrix conversion
            BitMatrix bitMatrix = new QRCodeWriter().encode(url,
                    BarcodeFormat.QR_CODE, width, height, hints);
            int[] pixels = new int[width * height];
            //Here, we generate two-dimensional code images one by one according to the two-dimensional code algorithm,
            //The two for loops are the result of a horizontal scan of the image
            for (int y = 0; y < height; y++) {
                for (int x = 0; x < width; x++) {
                    if (bitMatrix.get(x, y)) {
                        pixels[y * width + x] = 0xff000000;
                    } else {
                        pixels[y * width + x] = 0xffffffff;
                    }
                }
            }
            //Generate the format of the QR code image using ARGB_ eight thousand eight hundred and eighty-eight
            Bitmap bitmap = Bitmap.createBitmap(width, height,
                    Bitmap.Config.ARGB_8888);
            bitmap.setPixels(pixels, 0, width, 0, 0, width, height);
            return bitmap;
        } catch (WriterException e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     *Generate barcode
     *
     * @param context
     *@param contents Contents to be generated
     *@param desiredWidth Generates the broadband of the barcode
     *@param desiredHeight The height at which the barcode is generated
     *@param displayCode Whether the content is displayed below the barcode
     * @return
     */
    public static Bitmap creatBarcode(Context context, String contents,
                                      int desiredWidth, int desiredHeight, boolean displayCode) {
        Bitmap ruseltBitmap = null;
        /**
         *The width of the blank space left at both ends of the image
         */
        int marginW = 20;
        /**
         *Encoding type of barcode
         */
        BarcodeFormat barcodeFormat = BarcodeFormat.CODE_128;

        if (displayCode) {
            Bitmap barcodeBitmap = encodeAsBitmap(contents, barcodeFormat,
                    desiredWidth, desiredHeight);
            Bitmap codeBitmap = creatCodeBitmap(contents, desiredWidth + 2
                    * marginW, desiredHeight, context);
            ruseltBitmap = mixtureBitmap(barcodeBitmap, codeBitmap, new PointF(
                    0, desiredHeight));
        } else {
            ruseltBitmap = encodeAsBitmap(contents, barcodeFormat,
                    desiredWidth, desiredHeight);
        }

        return ruseltBitmap;
    }

    /**
     *Bitmap for generating barcodes
     *
     *@param contents Contents to be generated
     *@param format encoding format
     * @param desiredWidth
     * @param desiredHeight
     * @return
     * @throws WriterException
     */
    protected static Bitmap encodeAsBitmap(String contents,
                                           BarcodeFormat format, int desiredWidth, int desiredHeight) {
        final int WHITE = 0xFFFFFFFF;
        final int BLACK = 0xFF000000;

        MultiFormatWriter writer = new MultiFormatWriter();
        BitMatrix result = null;
        try {
            result = writer.encode(contents, format, desiredWidth,
                    desiredHeight, null);
        } catch (WriterException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }

        int width = result.getWidth();
        int height = result.getHeight();
        int[] pixels = new int[width * height];
        // All are 0, or black, by default
        for (int y = 0; y < height; y++) {
            int offset = y * width;
            for (int x = 0; x < width; x++) {
                pixels[offset + x] = result.get(x, y) ? BLACK : WHITE;
            }
        }

        Bitmap bitmap = Bitmap.createBitmap(width, height,
                Bitmap.Config.ARGB_8888);
        bitmap.setPixels(pixels, 0, width, 0, 0, width, height);
        return bitmap;
    }

    /**
     *Generate display encoded Bitmap
     *
     * @param contents
     * @param width
     * @param height
     * @param context
     * @return
     */
    protected static Bitmap creatCodeBitmap(String contents, int width,
                                            int height, Context context) {
        TextView tv = new TextView(context);
        LinearLayout.LayoutParams layoutParams = new LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT, LinearLayout.LayoutParams.WRAP_CONTENT);
        tv.setLayoutParams(layoutParams);
        tv.setText(contents);
        tv.setHeight(height);
        tv.setGravity(Gravity.CENTER_HORIZONTAL);
        tv.setWidth(width);
        tv.setDrawingCacheEnabled(true);
        tv.setTextColor(Color.BLACK);
        tv.measure(View.MeasureSpec.makeMeasureSpec(0, View.MeasureSpec.UNSPECIFIED),
                View.MeasureSpec.makeMeasureSpec(0, View.MeasureSpec.UNSPECIFIED));
        tv.layout(0, 0, tv.getMeasuredWidth(), tv.getMeasuredHeight());

        tv.buildDrawingCache();
        Bitmap bitmapCode = tv.getDrawingCache();
        return bitmapCode;
    }

    /**
     *Merge two Bitmaps into one
     *
     * @param first
     * @param second
     *@param fromPoint The starting position of the second bitmap to start drawing (relative to the first bitmap)
     * @return
     */
    protected static Bitmap mixtureBitmap(Bitmap first, Bitmap second,
                                          PointF fromPoint) {
        if (first == null || second == null || fromPoint == null) {
            return null;
        }
        int marginW = 20;
        Bitmap newBitmap = Bitmap.createBitmap(
                first.getWidth() + second.getWidth() + marginW,
                first.getHeight() + second.getHeight(), Bitmap.Config.ARGB_4444);
        Canvas cv = new Canvas(newBitmap);
        cv.drawBitmap(first, marginW, 0, null);
        cv.drawBitmap(second, fromPoint.x, fromPoint.y, null);
        cv.save();
        cv.restore();

        return newBitmap;
    }


    /**
     *Share pictures to WeChat circle of friends
     *
     *@param bmp Bitmap object for shared images
     *@param content Share content
     */
    public static void shareImageToWechat(Bitmap bmp, String content, Context mContext) {
        /**
         *WeChat version 7.0 is compatible with handling the issue of sharing multiple images in WeChat version 7.0 with friends' circle
         */
        final int VERSION_CODE_FOR_WEI_XIN_VER7 = 1380;
        /**
         *WeChat package name
         */
        final String PACKAGE_NAME_WEI_XIN = "com.tencent.mm";
        File file = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_PICTURES).getAbsoluteFile();
        String fileName = "share";
        File appDir = new File(file, fileName);
        if (!appDir.exists()) {
            appDir.mkdirs();
        }
        fileName = System.currentTimeMillis() + ".jpg";
        File currentFile = new File(appDir, fileName);
        FileOutputStream fos = null;
        try {
            fos = new FileOutputStream(currentFile);
            bmp.compress(Bitmap.CompressFormat.PNG, 100, fos);
            fos.flush();
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        } finally {
            try {
                if (fos != null) {
                    fos.close();
                }
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
        ArrayList<Uri> uris = new ArrayList<>();
        Uri uri = null;
        try {
            ApplicationInfo applicationInfo = mContext.getApplicationInfo();
            int targetSDK = applicationInfo.targetSdkVersion;
            if (targetSDK >= Build.VERSION_CODES.N && Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                uri = Uri.parse(android.provider.MediaStore.Images.Media.insertImage(mContext.getContentResolver(), currentFile.getAbsolutePath(), fileName, null));
            } else {
                uri = Uri.fromFile(new File(currentFile.getPath()));
            }
            uris.add(uri);
        } catch (Exception ex) {

        }
        Intent intent = new Intent();
        intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION | Intent.FLAG_GRANT_WRITE_URI_PERMISSION);
//        ComponentName comp = new ComponentName(PACKAGE_NAME_WEI_XIN, "com.tencent.mm.ui.tools.ShareToTimeLineUI");
//        intent.setComponent(comp);
        intent.setType("image/*");
        if (CpVersionUtil.getVersionCode(mContext, PACKAGE_NAME_WEI_XIN) < VERSION_CODE_FOR_WEI_XIN_VER7) {
            //WeChat version below 7.0
            intent.setAction(Intent.ACTION_SEND_MULTIPLE);
            intent.putParcelableArrayListExtra(Intent.EXTRA_STREAM, uris);
        } else {
            //WeChat 7.0 and above
            intent.setAction(Intent.ACTION_SEND);
            intent.putExtra(Intent.EXTRA_STREAM, uri);
        }
        if(mContext instanceof Activity){
            ((Activity) mContext).startActivityForResult(Intent.createChooser(intent, content),SHARE_CODE);
        }else{
            mContext.startActivity(Intent.createChooser(intent, content));
        }

    }





}
