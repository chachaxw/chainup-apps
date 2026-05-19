package com.yjkj.chainup.new_version.view;

import android.graphics.Bitmap;
/**
 * @Author lianshangljl
 * @Date 2023/11/16-12:57 PM
 * @Email buptjinlong@163.com
 * @description
 */
public class BitmapDeleteNoUseSpaceUtil {
    /**
     *Grayscale Bitmap
     * @param imgTheWidth
     * @param imgTheHeight
     * @param imgThePixels
     * @return
     */
    private static Bitmap getGrayImg(int imgTheWidth, int imgTheHeight, int[] imgThePixels) {
        int alpha = 0xFF << 24; //Set Transparency
        for (int i = 0; i < imgTheHeight; i++) {
            for (int j = 0; j < imgTheWidth; j++) {
                int grey = imgThePixels[imgTheWidth * i + j];
                int red = ((grey & 0x00FF0000) >> 16); //Obtain red grayscale values
                int green = ((grey & 0x0000FF00) >> 8); //Obtain green grayscale values
                int blue = (grey & 0x000000FF);     //Obtain blue grayscale values
                grey = (int) ((float) red * 0.3 + (float) green * 0.59 + (float) blue * 0.11);
                grey = alpha | (grey << 16) | (grey << 8) | grey; //Add transparency
                imgThePixels[imgTheWidth * i + j] = grey;// Change pixel color value
            }
        }
        Bitmap result =
                Bitmap.createBitmap(imgTheWidth, imgTheHeight, Bitmap.Config.RGB_565);
        result.setPixels(imgThePixels, 0, imgTheWidth, 0, 0, imgTheWidth, imgTheHeight);
        return result;
    }
    /**
     *Remove excess white boxes
     * @param originBitmap
     * @return
     */
    public static Bitmap deleteNoUseWhiteSpace(Bitmap originBitmap) {
        int[] imgThePixels = new int[originBitmap.getWidth() * originBitmap.getHeight()];
        originBitmap.getPixels(
                imgThePixels,
                0,
                originBitmap.getWidth(),
                0,
                0,
                originBitmap.getWidth(),
                originBitmap.getHeight());
        //Grayscale Bitmap
        Bitmap bitmap = getGrayImg(
                originBitmap.getWidth(),
                originBitmap.getHeight(),
                imgThePixels);
        int top = 0; //Top Border White Height
        int left = 0; //Left border white height
        int right = 0; //Right Border White Height
        int bottom = 0; //Bottom border white height
        for (int h = 0; h < bitmap.getHeight(); h++) {
            boolean holdBlackPix = false;
            for (int w = 0; w < bitmap.getWidth(); w++) {
                if (bitmap.getPixel(w, h) != -1) { // -1 是白色
                    holdBlackPix = true; //If it is not -1, it is another color
                    break;
                }
            }
            if (holdBlackPix) {
                break;
            }
            top++;
        }
        for (int w = 0; w < bitmap.getWidth(); w++) {
            boolean holdBlackPix = false;
            for (int h = 0; h < bitmap.getHeight(); h++) {
                if (bitmap.getPixel(w, h) != -1) {
                    holdBlackPix = true;
                    break;
                }
            }
            if (holdBlackPix) {
                break;
            }
            left++;
        }
        for (int w = bitmap.getWidth() - 1; w >= 0; w--) {
            boolean holdBlackPix = false;
            for (int h = 0; h < bitmap.getHeight(); h++) {
                if (bitmap.getPixel(w, h) != -1) {
                    holdBlackPix = true;
                    break;
                }
            }
            if (holdBlackPix) {
                break;
            }
            right++;
        }
        for (int h = bitmap.getHeight() - 1; h >= 0; h--) {
            boolean holdBlackPix = false;
            for (int w = 0; w < bitmap.getWidth(); w++) {
                if (bitmap.getPixel(w, h) != -1) {
                    holdBlackPix = true;
                    break;
                }
            }
            if (holdBlackPix) {
                break;
            }
            bottom++;
        }
        //Obtain the width and height of the content area
        int cropHeight = bitmap.getHeight() - bottom - top;
        int cropWidth = bitmap.getWidth() - left - right;
        //Obtain pixels in the content area
        int[] newPix = new int[cropWidth * cropHeight];
        int i = 0;
        for (int h = top; h < top + cropHeight; h++) {
            for (int w = left; w < left + cropWidth; w++) {
                newPix[i++] = bitmap.getPixel(w, h);
            }
        }
        //Create a cut bitmap and replace newPix with the pixs of originBitmap for color images
        return Bitmap.createBitmap(newPix, cropWidth, cropHeight, Bitmap.Config.ARGB_8888);
    }
}
