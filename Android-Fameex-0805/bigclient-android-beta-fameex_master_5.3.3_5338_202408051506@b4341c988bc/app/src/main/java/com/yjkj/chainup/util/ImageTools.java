package com.yjkj.chainup.util;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.ActivityNotFoundException;
import android.content.ContentValues;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.database.Cursor;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.net.Uri;
import android.os.Bundle;
import android.os.Environment;
import android.os.Handler;
import android.os.Message;
import android.provider.MediaStore;
import android.util.Base64;
import android.util.Log;
import android.widget.Toast;

import androidx.core.content.FileProvider;
import androidx.fragment.app.Fragment;

import com.blankj.utilcode.util.AppUtils;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.URL;
import java.net.URLConnection;

import cn.ljuns.logcollector.util.FileUtils;

public class ImageTools {
    private boolean fromFragment;
    private Fragment mFragment;
    private Context mContext;

    //Show selection dialog box
    private String[] mItems = new String[]{"相机", "图库"};

    //Default save path
    private String mFolderString = "/FNComman/";

    private String mPath;

    //Cropped or not
    private boolean isClip;

    //The camera tag can be switched in onActvityResult
    public static final int CAMERA = 300;

    //The library tag can be switched in the onActivityResult
    public static final int GALLERY = 301;

    //The clipping flag can be switched in onActivityResult
    public static final int BITMAP = 302;

    //Default image maximum height
    private int defaultHeight = 720;

    //Default image maximum width
    private int defaultWidth = 1280;


    /**
     *Default cropped width
     */
    private int defaultClipWidth = 320;
    /**
     *Default cropped height
     */
    private int defaultClipHeight = 190;

    private ImageTools() {
    }

    public ImageTools(Fragment fragment) {
        this.mFragment = fragment;
        this.mContext = fragment.getActivity();
        fromFragment = true;
        initFile();
    }

    public ImageTools(Activity activity) {
        this.mContext = activity;
        initFile();
    }

    private String getFileRoot(Context context) {
        if (Environment.getExternalStorageState().equals(
                Environment.MEDIA_MOUNTED)) {
            File external = context.getExternalCacheDir();
            if (external != null) {
                return external.getAbsolutePath();
            }
        }
        return context.getFilesDir().getAbsolutePath();
    }

    private void initFile() {
        File file = new File(getFileRoot(mContext) + mFolderString);
        if (!file.exists()) {
            try{
                boolean mkdirs = file.mkdirs();

                Log.d("ImageTools","文件夹创建mkdirs>>>"+mkdirs);
                Log.d("ImageTools","文件夹path>>>"+file.getAbsolutePath());
            }catch (Exception e){
                e.printStackTrace();
                Log.d("ImageTools","文件夹创建失败");
            }

        }
        file = new File(file + ".nomedia");
        if (!file.exists()) {
            try {
                file.createNewFile();
            } catch (IOException e) {
                try {
                    throw new IOException("无法创建" + file.toString() + "文件");
                } catch (IOException e1) {
                    e1.printStackTrace();
                }
            }
        }
    }


    private void getWriteFilePermission() {

    }

    //Set crop width and height
    public void setClipWidth(int width) {
        defaultClipWidth = width;
    }

    public void setClipHeight(int height) {
        defaultClipHeight = height;
    }


    public void enableClip(boolean isClip) {
        this.isClip = isClip;
    }


    //Display dialog boxes for cameras or libraries
    public void showGetImageDialog(String title) {
        AlertDialog.Builder builder = new AlertDialog.Builder(mContext);
        builder.setTitle(title);
        builder.setItems(mItems, new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                switch (which) {
                    case 0:
                        openCamera("");
                        break;
                    case 1:
                        openGallery("");
                        break;
                    default:
                        break;
                }
            }
        });
        builder.show();
    }


    //

    /**
     *Turn on the camera
     * <p>
     *OPPO 5.1 mobile report ActivityNotFoundException
     *Need to try Catch processing
     */
    public void openCamera(String index) {
        //Obtain System Version
        int currentapiVersion = android.os.Build.VERSION.SDK_INT;
        //Determine if the storage card is usable and can be used for storage
        if (Environment.getExternalStorageState().equals(Environment.MEDIA_MOUNTED)) {
            mPath = getFileRoot(mContext) + mFolderString;
            mPath += System.currentTimeMillis() + ".jpg";
            Intent intent = new Intent(MediaStore.ACTION_IMAGE_CAPTURE);
            intent.putExtra("INDEX_NAME", index);
            if (currentapiVersion < 24) {
                File file = new File(mPath);
                if(!file.exists()){
                    try {
                        file.createNewFile();
                    } catch (IOException e) {
                        throw new RuntimeException(e);
                    }
                }
                //Create uri from file
                Uri uri = Uri.fromFile(file);
                intent.putExtra(MediaStore.EXTRA_OUTPUT, uri);
            } else {
                //Compatible with Android 7.0 using shared file format
//                ContentValues contentValues = new ContentValues(1);
                File saveFile = new File(mPath);
                if(!saveFile.exists()){
                    try {
                        saveFile.createNewFile();
                    } catch (IOException e) {
                        throw new RuntimeException(e);
                    }
                }

//                contentValues.put(MediaStore.Images.Media.DATA, saveFile.getAbsolutePath());
//                Uri uri = mContext.getContentResolver().insert(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, contentValues);
                Uri uri = FileProvider.getUriForFile(mContext, mContext.getPackageName() + ".fileProvider",saveFile);
                intent.putExtra(MediaStore.EXTRA_OUTPUT, uri);
            }
            try {
                if (fromFragment) {
                    mFragment.startActivityForResult(intent, CAMERA);
                } else {
                    ((Activity) mContext).startActivityForResult(intent, CAMERA);
                }
            } catch (ActivityNotFoundException e) {
                e.printStackTrace();
            }
        } else {
            Toast.makeText(mContext, "未检测到CDcard，拍照不可用!",
                    Toast.LENGTH_SHORT).show();
        }

    }

    /**
     *Take photos
     */
    public void takePhoto() {
        //Obtain System Version
        int currentapiVersion = android.os.Build.VERSION.SDK_INT;
        //Determine if the storage card is usable and can be used for storage
        if (Environment.getExternalStorageState().equals(Environment.MEDIA_MOUNTED)) {
            mPath = Environment.getExternalStorageDirectory().getAbsolutePath() + mFolderString;
            mPath += System.currentTimeMillis() + ".jpg";
            Intent intent = new Intent(MediaStore.ACTION_IMAGE_CAPTURE);
            if (currentapiVersion < 24) {
                //Create uri from file
                Uri uri = Uri.fromFile(new File(mPath));
                intent.putExtra(MediaStore.EXTRA_OUTPUT, uri);
            } else {
                //Compatible with Android 7.0 using shared file format
                ContentValues contentValues = new ContentValues(1);
                File saveFile = new File(mPath);
                contentValues.put(MediaStore.Images.Media.DATA, saveFile.getAbsolutePath());
                Uri uri = mContext.getContentResolver().insert(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, contentValues);
                intent.putExtra(MediaStore.EXTRA_OUTPUT, uri);
            }
            try {
                if (fromFragment) {
                    mFragment.startActivityForResult(intent, CAMERA);
                } else {
                    ((Activity) mContext).startActivityForResult(intent, CAMERA);
                }
            } catch (ActivityNotFoundException e) {
                e.printStackTrace();
            }
        } else {
            Toast.makeText(mContext, "未检测到CDcard，拍照不可用!",
                    Toast.LENGTH_SHORT).show();
        }

    }

    public void setmPath(String path) {
        mPath = path;
    }


    //Open Album
    public void openGallery(String index) {
        Intent intent = new Intent(Intent.ACTION_PICK);
        intent.setDataAndType(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, "image/*");
        intent.putExtra("INDEX_NAME", index);
        if (fromFragment) {
            mFragment.startActivityForResult(intent, GALLERY);
        } else {
            ((Activity) mContext).startActivityForResult(intent, GALLERY);
        }
    }


    public boolean onAcitvityResult(int requestCode, int resultCode,
                                    Intent data, OnBitmapCreateListener listener) {
        if (resultCode != Activity.RESULT_OK) return false;
        switch (requestCode) {
            case CAMERA:
                if (isClip) {
                    getBitmapFromCamera(new OnBitmapCreateListener() {
                        @Override
                        public void onBitmapCreate(Bitmap bitmap, String path) {
                            startZoomPhoto(Uri.fromFile(new File(path)),
                                    defaultClipWidth, defaultClipHeight);
                        }
                    });
                } else {
                    getBitmapFromCamera(listener);
                }
                break;
            case GALLERY:
                Uri selectedImage = data.getData();
                String[] filePathColum = {MediaStore.Images.Media.DATA};
                Cursor cursor = mContext.getContentResolver().query(selectedImage, filePathColum, null, null, null);
                cursor.moveToFirst();
                int columnIndex = cursor.getColumnIndex(filePathColum[0]);
                String filePath = cursor.getString(columnIndex);
                if (isClip) {
                    startZoomPhoto(Uri.fromFile(new File(filePath)),
                            defaultClipWidth, defaultClipHeight);
                } else {
                    listener.onBitmapCreate(getBitmapFromGallery(data), filePath);
                }
                cursor.close();
                break;
            case BITMAP:
                Bitmap bitmap = getBitmapFromZoomPhoto(data);
                String path = newFile();
                File file = new File(path);
                FileOutputStream fileOutputStream = null;
                try {
                    file.createNewFile();
                    fileOutputStream = new FileOutputStream(path);
                    bitmap.compress(Bitmap.CompressFormat.PNG, 80, fileOutputStream);
                    fileOutputStream.flush();
                } catch (IOException e) {
                    e.printStackTrace();
                } finally {
                    if (fileOutputStream != null) {
                        try {
                            fileOutputStream.close();
                        } catch (IOException e) {
                            e.printStackTrace();
                        }
                    }
                }
                listener.onBitmapCreate(bitmap, path);
        }
        return true;
    }


    //Obtain Bitmap from Camera
    public void getBitmapFromCamera(final OnBitmapCreateListener listener) {
        final Handler handler = new Handler() {
            @Override
            public void handleMessage(Message msg) {
                listener.onBitmapCreate((Bitmap) msg.obj, mPath);
            }
        };
        new Thread() {
            @Override
            public void run() {
                BitmapFactory.Options options = new BitmapFactory.Options();
                options.inJustDecodeBounds = true;
                BitmapFactory.decodeFile(mPath, options);
                int size = calculateInSampleSize(options, defaultWidth, defaultHeight);
                options = new BitmapFactory.Options();
                options.inJustDecodeBounds = false;
                options.inSampleSize = size;
                Bitmap bitmap = BitmapFactory.decodeFile(mPath, options);
                Message message = handler.obtainMessage();
                message.obj = bitmap;
                message.what = 0;
                handler.sendMessage(message);
            }
        }.start();
    }

    //Obtain Bitmap from Library
    public Bitmap getBitmapFromGallery(Intent data) {
        Uri selectedImage = data.getData();
        String[] filePathColumn = {MediaStore.Images.Media.DATA};
        Cursor cursor = null;
        try {
            cursor = mContext.getContentResolver().query(selectedImage,
                    filePathColumn, null, null, null);
            if (cursor != null && cursor.moveToFirst()) {
                int columnIndex = cursor.getColumnIndex(filePathColumn[0]);
                String filePath = cursor.getString(columnIndex);
                cursor.close();
                BitmapFactory.Options options = new BitmapFactory.Options();
                options.inJustDecodeBounds = true;
                BitmapFactory.decodeFile(filePath, options);
                int size = calculateInSampleSize(options, defaultWidth, defaultHeight);
                options = new BitmapFactory.Options();
                options.inJustDecodeBounds = false;
                options.inSampleSize = size;
                return BitmapFactory.decodeFile(filePath, options);
            }

        } finally {
            if (cursor != null) {
                cursor.close();
            }
        }
        return null;
    }


    //Calculate the scaling value of the image
    public int calculateInSampleSize(BitmapFactory.Options options,
                                     int reqWidth, int reqHeight) {

        int width = options.outWidth;     //Obtain the width of the image
        int height = options.outHeight;   //Obtain the height of the image
        int inSampleSize = 4;
        if (height > reqHeight || width > reqWidth) {
            int heightRatio = Math.round(height / reqHeight);
            int widthRatio = Math.round(width / reqHeight);
            inSampleSize = heightRatio < widthRatio ? heightRatio : widthRatio;
        }
        return inSampleSize;
    }


    /**
     *Crop Picture
     *
     *The @param uri image path URL can be obtained using uri. FromFile (File)
     *@param outputX Cropped width
     *@param outputY Cropping height
     */
    public void startZoomPhoto(Uri uri, int outputX, int outputY) {
        Intent intent = new Intent("com.android.camera.action.CROP");
        intent.setDataAndType(uri, "image/*");
        //Set Cropping
        intent.putExtra("crop", "true");
        //AspectX aspectY is the ratio of width to height
        intent.putExtra("aspectX", 1);
        intent.putExtra("aspectY", 1);
        //OutputX outputY is the width and height of the crop
        intent.putExtra("outputX", outputX);
        intent.putExtra("outputY", outputY);
        intent.putExtra("return-data", true);
        try {
            if (fromFragment) {
                mFragment.startActivityForResult(intent, BITMAP);
            } else {
                ((Activity) mContext).startActivityForResult(intent, BITMAP);
            }
        } catch (ActivityNotFoundException e) {
            e.printStackTrace();
            Toast.makeText(mContext, "未找到可以剪裁图片的程序", Toast.LENGTH_SHORT).show();
        }
    }

    //Obtain cropped images
    public Bitmap getBitmapFromZoomPhoto(Intent data) {
        Bundle extras = data.getExtras();
        if (extras != null) {
            return extras.getParcelable("data");
        }
        return null;
    }

    public String newFile() {
        File file = new File(mContext.getExternalFilesDir(Environment.MEDIA_MOUNTED), "common");
        if (!file.exists()) {
            file.mkdirs();
        }
        return file.getAbsolutePath() + "/" + System.currentTimeMillis() + ".jpg";
    }


    //After processing the bitmap callback
    public interface OnBitmapCreateListener {
        void onBitmapCreate(Bitmap bitmap, String path);
    }

    //Bitmap to String
    public String bitmap2Base64(Bitmap bitmap) {
        if (bitmap != null && !bitmap.isRecycled()) {
            ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
            bitmap.compress(Bitmap.CompressFormat.PNG, 100, byteArrayOutputStream);
            byte[] bytes = byteArrayOutputStream.toByteArray();
            return Base64.encodeToString(bytes, Base64.DEFAULT);
        }
        return null;
    }

    /**
     *Save files to system album
     *
     * @param context
     * @param bmp
     * @return
     */
    public static boolean saveImageToGallery4ContractAgent(Context context, Bitmap bmp) {
        //First, save the image
        String fileLog = FileUtils.getShareFileDir(AppUtils.getAppName());
        File appDir = new File(fileLog);
        String fileName = System.currentTimeMillis() + ".png";
        File file = new File(appDir, fileName);
        try {
            FileOutputStream fos = new FileOutputStream(file);
            //Compress and save images through IO streaming
            boolean isSuccess = bmp.compress(Bitmap.CompressFormat.PNG, 60, fos);
            fos.flush();
            fos.close();

            //Insert files into the system library
//            try {
//                MediaStore.Images.Media.insertImage(context.getContentResolver(), file.getAbsolutePath(), fileName, null);
//            } catch (Exception e) {
//                e.printStackTrace();
//            }
            //Send a broadcast notification to update the database after saving the image
            Uri uri = Uri.fromFile(file);
            context.sendBroadcast(new Intent(Intent.ACTION_MEDIA_SCANNER_SCAN_FILE, uri));
            return isSuccess;
        } catch (IOException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     *Save files to system album
     *
     * @param context
     * @param bmp
     * @return
     */
    public static boolean saveImageToGallery4Contract(Context context, Bitmap bmp) {
        //First, save the image
        String storePath = Environment.getExternalStorageDirectory().getAbsolutePath() + File.separator;
        File appDir = new File(storePath);
        if (!appDir.exists()) {
            appDir.mkdir();
        }
        String fileName = System.currentTimeMillis() + ".png";
        File file = new File(appDir, fileName);
        try {
            FileOutputStream fos = new FileOutputStream(file);
            //Compress and save images through IO streaming
            boolean isSuccess = bmp.compress(Bitmap.CompressFormat.PNG, 60, fos);
            fos.flush();
            fos.close();

            //Insert files into the system library
            //MediaStore.Images.Media.insertImage(context.getContentResolver(), file.getAbsolutePath(), fileName, null);

            //Send a broadcast notification to update the database after saving the image
            Uri uri = Uri.fromFile(file);
            context.sendBroadcast(new Intent(Intent.ACTION_MEDIA_SCANNER_SCAN_FILE, uri));
            return isSuccess;
        } catch (IOException e) {
            e.printStackTrace();
        }
        return false;
    }


    /**
     *Save files to system album
     *
     * @param context
     * @param bmp
     * @return
     */
    public static boolean saveImageToGallery(Context context, Bitmap bmp) {
        //First, save the image
        String fileLog = FileUtils.getShareFileDir(AppUtils.getAppName());
        File appDir = new File(fileLog);
        String fileName = System.currentTimeMillis() + ".png";
        File file = new File(appDir, fileName);
        try {
            FileOutputStream fos = new FileOutputStream(file);
            //Compress and save images through IO streaming
            boolean isSuccess = bmp.compress(Bitmap.CompressFormat.PNG, 60, fos);
            fos.flush();
            fos.close();
            //Insert files into the system library
            try {
                MediaStore.Images.Media.insertImage(context.getContentResolver(), file.getAbsolutePath(), fileName, null);
            } catch (Exception e) {
                e.printStackTrace();
            }
            //Send a broadcast notification to update the database after saving the image
            Uri uri = Uri.fromFile(file);
            context.sendBroadcast(new Intent(Intent.ACTION_MEDIA_SCANNER_SCAN_FILE, uri));
            return isSuccess;
        } catch (IOException e) {
            e.printStackTrace();
        }
        return false;
    }


    /**
     *Save files to system album
     *
     * @param context
     * @param bmp
     * @return
     */
    public static Uri saveImage2Gallery(Context context, String imageSign, Bitmap bmp) {
        //First, save the image
        try {
            String storePath = Environment.getExternalStorageDirectory().getAbsolutePath() + File.separator + imageSign + ".jpg";
            File file = new File(storePath);
            ContentValues contentValues = new ContentValues(1);
            File saveFile = new File(file.getAbsolutePath());
            contentValues.put(MediaStore.Images.Media.DATA, saveFile.getAbsolutePath());
            if (!file.exists()) {
                file.getParentFile().mkdirs();
                file.createNewFile();
            } else {
                Uri uri = context.getContentResolver().insert(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, contentValues);
                return uri;
            }

            FileOutputStream fos = new FileOutputStream(file);
            //Compress and save images through IO streaming
            bmp.compress(Bitmap.CompressFormat.PNG, 60, fos);
            fos.flush();
            fos.close();
            //Insert files into the system library
            //MediaStore.Images.Media.insertImage(context.getContentResolver(), file.getAbsolutePath(), fileName, null);
            //Send a broadcast notification to update the database after saving the image
//            Uri uri = FileProvider.getUriForFile(context, context.getApplicationContext().getPackageName() + ".fileProvider", file);

            //Compatible with Android 7.0 using shared file format

            Uri uri = context.getContentResolver().insert(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, contentValues);

            Log.d("XXXXXX", "=======URI:==========" + uri);
            context.sendBroadcast(new Intent(Intent.ACTION_MEDIA_SCANNER_SCAN_FILE, uri));
            return uri;
        } catch (IOException e) {
            e.printStackTrace();
        }
        return null;
    }


    /**
     *Here are ways to share images
     **/

    //Save Picture
    public static String saveBitmap(Bitmap bitmap, String fileName) {
        String storePath = Environment.getExternalStorageDirectory().getAbsolutePath() + File.separator + "分享" + File.separator;

        File headDir = new File(storePath);
        if (!headDir.exists()) {
            headDir.mkdirs();
        }
        FileOutputStream headFos = null;
        File headFile = null;
        try {
            //Rename and Save
            headFile = new File(storePath, fileName);
            headFile.createNewFile();
            headFos = new FileOutputStream(headFile);
            bitmap.compress(Bitmap.CompressFormat.JPEG, 100, headFos);
            headFos.flush();
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (headFos != null) {
                try {
                    headFos.close();
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
        }
        return storePath + fileName;
    }

    //Convert network images into bigmap objects
    public static Bitmap getBitMBitmap(String urlpath) {
        Bitmap map = null;
        try {
            URL url = new URL(urlpath);
            URLConnection conn = url.openConnection();
            conn.connect();
            InputStream in;
            in = conn.getInputStream();
            map = BitmapFactory.decodeStream(in);
        } catch (IOException e) {
            e.printStackTrace();
        }
        return map;
    }

    /**
     *This parameter is the absolute path you want to save to the local image (including the file name. jpg)
     */
    public static String insertImageToSystem(Context context, String imagePath, String imgName) {
        String url = "";
        try {
            url = MediaStore.Images.Media.insertImage(context.getContentResolver(), imagePath, imgName, "分享");
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        }
        return url;
    }


}
