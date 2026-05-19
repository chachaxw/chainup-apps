package com.yjkj.chainup.util

import android.graphics.Bitmap
import android.graphics.BitmapFactory

/**
 * @Author lianshangljl
 * @Date 2023/11/16-7:37 PM
 * @Email buptjinlong@163.com
 * @description
 */
class QRCodeUtils{
    /**
     *Convert local image files into Bitmaps that can decode QR codes. To avoid the image being too large, the image has been compressed here. Thank you https://github.com/devilsen PR raised
     *
     *@param picturePath Local image file path
     */
    companion object{
        fun getDecodeAbleBitmap(picturePath: String): Bitmap? {
            try {
                val options = BitmapFactory.Options()
                options.inJustDecodeBounds = true
                BitmapFactory.decodeFile(picturePath, options)
                var sampleSize = options.outHeight / 400
                if (sampleSize <= 0) {
                    sampleSize = 1
                }
                options.inSampleSize = sampleSize
                options.inJustDecodeBounds = false

                return BitmapFactory.decodeFile(picturePath, options)
            } catch (e: Exception) {
                e.printStackTrace()
                return null
            }

        }
    }

}
