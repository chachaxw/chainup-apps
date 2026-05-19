package com.yjkj.chainup.util;

import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Color;
import androidx.annotation.ColorInt;
import androidx.annotation.Nullable;
import android.text.TextUtils;


import com.google.zxing.BarcodeFormat;
import com.google.zxing.EncodeHintType;
import com.google.zxing.WriterException;
import com.google.zxing.common.BitMatrix;
import com.google.zxing.qrcode.QRCodeWriter;

import java.util.Hashtable;

/**
 * @ClassName: QRCodeUtil
 *@description: QR code tool class
 * @Author Wangnan
 * @Date 2023/2/7
 */

public class QRCodeUtil {

    /**
     *Create a QR code bitmap
     *
     *@param content string content
     *@param size Bitmap width&height (in px)
     * @return
     */
    @Nullable
    public static Bitmap createQRCodeBitmap(@Nullable String content, int size){
        return createQRCodeBitmap(content, size, "UTF-8", "H", "4", Color.BLACK, Color.WHITE, null, null, 0F);
    }

    /**
     *Create a QR code bitmap
     *
     *@param content string content
     *@param size Bitmap width&height (in px)
     * @return
     */
    @Nullable
    public static Bitmap createQRCodeBitmapFull(@Nullable String content, int size){
        return createQRCodeBitmap(content, size, "UTF-8", "H", "0", Color.BLACK, Color.WHITE, null, null, 0F);
    }

    /**
     *Create a QR code bitmap (custom black and white block colors)
     *
     *@param content string content
     *@param size Bitmap width&height (in px)
     *@param color_ Custom color values for black color blocks
     *@param color_ Custom color values for white color blocks
     * @return
     */
    @Nullable
    public static Bitmap createQRCodeBitmap(@Nullable String content, int size, @ColorInt int color_black, @ColorInt int color_white){
        return createQRCodeBitmap(content, size, "UTF-8", "H", "4", color_black, color_white, null, null, 0F);
    }

    /**
     *Create a QR code bitmap (with logo small image)
     *
     *@param content string content
     *@param size Bitmap width&height (in px)
     *@param logoBitmap logo image
     *The proportion of the @param logoPercentage logo small image in the QR code image, with a range of [0F, 1F]. Out of range ->default to 0.2F
     * @return
     */
    @Nullable
    public static Bitmap createQRCodeBitmap(String content, int size, @Nullable Bitmap logoBitmap, float logoPercent){
        return createQRCodeBitmap(content, size, "UTF-8", "H", "4", Color.BLACK, Color.WHITE, null, logoBitmap, logoPercent);
    }

    /**
     *Create a QR code bitmap (Bitmap color instead of black) Attention!!! Attention!!! Attention!!! The selected Bitmap image must not have white color blocks, otherwise it will not be recognized!!!
     *
     *@param content string content
     *@param size Bitmap width&height (in px)
     *@param targetBitmap target image (if targetBitmap!=null, the black color block will be replaced by the pixel color value of the image)
     * @return
     */
    @Nullable
    public static Bitmap createQRCodeBitmap(String content, int size, Bitmap targetBitmap){
        return createQRCodeBitmap(content, size, "UTF-8", "H", "4", Color.BLACK, Color.WHITE, targetBitmap, null, 0F);
    }

    /**
     *Create a QR code bitmap (supports custom configurations and styles)
     *
     *@param content string content
     *@param size Bitmap width&height (in px)
     *@param character_ Set character set/character transcoding format (supported format: {@ link CharacterSetECI}). When passing null, the zxing source code defaults to "ISO-8859-1"
     *@param error_ Correction fault tolerance level (support level: {@ link ErrorCorrectionLevel}). When passing null, the zxing source code defaults to "L"
     *@param margin: Blank margin (modifiable, requires integer and>=0). When passing null, the zxing source code defaults to "4".
     *@param color_ Custom color values for black color blocks
     *@param color_ Custom color values for white color blocks
     *@param targetBitmap target image (if targetBitmap!=null, the black color block will be replaced by the pixel color value of the image)
     *@param logoBitmap logo small image
     *The proportion size of the @param logoPercentage logo small image in the QR code image, within the range of [0F, 1F], outside the range ->default to 0.2F.
     * @return
     */
    @Nullable
    public static Bitmap createQRCodeBitmap(@Nullable String content, int size,
                                            @Nullable String character_set, @Nullable String error_correction, @Nullable String margin,
                                            @ColorInt int color_black, @ColorInt int color_white, @Nullable Bitmap targetBitmap,
                                            @Nullable Bitmap logoBitmap, float logoPercent){

        /**1. Parameter legality judgment*/
        if(TextUtils.isEmpty(content)){ //String content is null
            return null;
        }

        if(size <= 0){ //Both width and height need to be>0
            return null;
        }

        try {
            /**2. Set relevant configurations for QR codes and generate BitMatrix objects*/
            Hashtable hints = new Hashtable();

            if(!TextUtils.isEmpty(character_set)) {
                hints.put(EncodeHintType.CHARACTER_SET, character_set); //Character Transcoding Format Settings
            }

            if(!TextUtils.isEmpty(error_correction)){
                hints.put(EncodeHintType.ERROR_CORRECTION, error_correction); //Fault tolerance level setting
            }

            if(!TextUtils.isEmpty(margin)){
                hints.put(EncodeHintType.MARGIN, margin); //Blank margin settings
            }
            BitMatrix bitMatrix = new QRCodeWriter().encode(content, BarcodeFormat.QR_CODE, size, size, hints);

            /**3. Assign color values to array elements based on BitMatrix objects*/
            if(targetBitmap != null){
                targetBitmap = Bitmap.createScaledBitmap(targetBitmap, size, size, false);
            }
            int[] pixels = new int[size * size];
            for(int y = 0; y < size; y++){
                for(int x = 0; x < size; x++){
                    if(bitMatrix.get(x, y)){ //Black color block pixel settings
                        if(targetBitmap != null) {
                            pixels[y * size + x] = targetBitmap.getPixel(x, y);
                        } else {
                            pixels[y * size + x] = color_black;
                        }
                    } else { //White color block pixel settings
                        pixels[y * size + x] = color_white;
                    }
                }
            }

            /**4. Create a Bitmap object, set the color values of each pixel in the Bitmap based on the pixel array, and then return the Bitmap object*/
            Bitmap bitmap = Bitmap.createBitmap(size, size, Bitmap.Config.ARGB_8888);
            bitmap.setPixels(pixels, 0, size, 0, 0, size, size);

            /**5. Add a logo small icon to the QR code*/
            if(logoBitmap != null){
                return addLogo(bitmap, logoBitmap, logoPercent);
            }

            return bitmap;
        } catch (WriterException e) {
            e.printStackTrace();
        }

        return null;
    }

    /**
     *Add a logo small image to the middle of an image (image synthesis)
     *
     *@param srcBitmap original image
     *@param logoBitmap logo image
     *@param logoPercentage percentage (used to adjust the display size of the logo image in the original image, with a value range of [0,1]. If the value is illegal, use 0.2F)
     *When the original image is a QR code, it is recommended to use 0.2F. Excessive percentage may cause QR code scanning to fail.
     * @return
     */
    @Nullable
    private static Bitmap addLogo(@Nullable Bitmap srcBitmap, @Nullable Bitmap logoBitmap, float logoPercent){

        /**1 Parameter legality judgment*/
        if(srcBitmap == null){
            return null;
        }

        if(logoBitmap == null){
            return srcBitmap;
        }

        if(logoPercent < 0F || logoPercent > 1F){
            logoPercent = 0.2F;
        }

        /**2 Obtain the width and height values of the original image and logo image respectively*/
        int srcWidth = srcBitmap.getWidth();
        int srcHeight = srcBitmap.getHeight();
        int logoWidth = logoBitmap.getWidth();
        int logoHeight = logoBitmap.getHeight();

        /**3 Calculate the aspect ratio of canvas scaling*/
        float scaleWidth = srcWidth * logoPercent / logoWidth;
        float scaleHeight = srcHeight * logoPercent / logoHeight;

        /**4 Draw and composite images using Canvas*/
        Bitmap bitmap = Bitmap.createBitmap(srcWidth, srcHeight, Bitmap.Config.ARGB_8888);
        Canvas canvas = new Canvas(bitmap);
        canvas.drawBitmap(srcBitmap, 0, 0, null);
        canvas.scale(scaleWidth, scaleHeight, srcWidth/2, srcHeight/2);
        canvas.drawBitmap(logoBitmap, srcWidth/2 - logoWidth/2, srcHeight/2 - logoHeight/2, null);

        return bitmap;
    }
}
