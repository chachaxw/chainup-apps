package com.yjkj.chainup.util;

import android.content.Context;
import android.content.pm.PackageManager;
import android.os.Environment;
import android.util.Log;

import com.bumptech.glide.Glide;
import com.bumptech.glide.request.target.Target;
import com.yjkj.chainup.app.ChainUpApp;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;

import io.reactivex.Observable;
import io.reactivex.ObservableEmitter;
import io.reactivex.ObservableOnSubscribe;
import io.reactivex.functions.Consumer;
import io.reactivex.schedulers.Schedulers;

import static android.os.Environment.MEDIA_MOUNTED;

/**
 * @Author lianshangljl
 * @Date 2023-02-20-17:07
 * @Email buptjinlong@163.com
 * @description
 */
public class FileUtils {


    private static final String EXTERNAL_STORAGE_PERMISSION = "android.permission.WRITE_EXTERNAL_STORAGE";


    /**
     * sdcard
     */
    private static final String SD_ROOT = Environment.getExternalStorageDirectory().getPath();

    /**
     *App Root Directory
     */
    public static final String PICTURE_DIR = SD_ROOT + File.separator + ChainUpApp.appContext.getPackageName()
            + File.separator + "cer" + File.separator;

    private FileUtils() {
    }

    /**
     *Is there an SDCard present
     *
     *Does @return exist
     */
    public static boolean sdExist() {
        return Environment.getExternalStorageState().equals(Environment.MEDIA_MOUNTED);
    }

    public static boolean initPictureDir() {
        if (!sdExist()) {
            return false;
        }
        File picFile = new File(PICTURE_DIR);
        boolean exists = picFile.exists();
        boolean mkdirs = picFile.mkdirs();
        return exists || mkdirs;
    }

    //Get File Size
    public static void deDuplication(File file) {
        if (file.exists()) {
            Log.d("fileUtil", "存在了：" + file.getPath());
            boolean isDelete = file.delete();
            Log.d("fileUtil", "删除文件结果：" + isDelete);
        } else {
            Log.d("fileUtil", "文件不存在：" + file.getPath());
        }
    }

    public static String getDownloadApkCachePath(Context context) {
        String appCachePath;
        if (Environment.getExternalStorageState().equals(
                Environment.MEDIA_MOUNTED)) {
            appCachePath = context.getExternalFilesDir(Environment.DIRECTORY_DOWNLOADS).getAbsolutePath() + "/ChainUp/";
        } else {
            appCachePath = context.getFilesDir().getAbsolutePath() + "/ChainUp/";

        }
        File file = new File(appCachePath);
        if (!file.exists()) {
            file.mkdirs();
        }
        return appCachePath;
    }

    public static File getCacheDirectory(Context context) {
        File appCacheDir = null;
        if (MEDIA_MOUNTED.equals(Environment.getExternalStorageState()) && hasExternalStoragePermission(context)) {
            appCacheDir = getExternalCacheDir(context);
        }
        if (appCacheDir == null) {
            appCacheDir = context.getCacheDir();
        }
        if (appCacheDir == null) {
            Log.w("UpdateFun TAG", "Can't define system cache directory! The app should be re-installed.");
        }
        return appCacheDir;
    }

    private static File getExternalCacheDir(Context context) {
        File dataDir = new File(new File(Environment.getExternalStorageDirectory(), "Android"), "data");
        File appCacheDir = new File(new File(dataDir, context.getPackageName()), "cache");
        if (!appCacheDir.exists()) {
            if (!appCacheDir.mkdirs()) {
                Log.w("UpdateFun TAG", "Unable to create external cache directory");
                return null;
            }
            try {
                new File(appCacheDir, ".nomedia").createNewFile();
            } catch (IOException e) {
                Log.i("UpdateFun TAG", "Can't create \".nomedia\" file in application external cache directory");
            }
        }
        return appCacheDir;
    }

    private static boolean hasExternalStoragePermission(Context context) {
        int perm = context.checkCallingOrSelfPermission(EXTERNAL_STORAGE_PERMISSION);
        return perm == PackageManager.PERMISSION_GRANTED;
    }

    public static void downloadAdvert(Context mContext, String imageUrl) {
        LogUtil.e("LogUtils","开始下载图片 "+imageUrl);
        Observable.create(new ObservableOnSubscribe<File>() {
            @Override
            public void subscribe(ObservableEmitter<File> e) throws Exception {
                //Download the file through gilde, please note the android.permission.INTERNET permission here
                e.onNext(Glide.with(mContext)
                        .load(imageUrl)
                        .downloadOnly(Target.SIZE_ORIGINAL, Target.SIZE_ORIGINAL)
                        .get());
                e.onComplete();
            }
        }).subscribeOn(Schedulers.io())
                .observeOn(Schedulers.newThread())
                .subscribe(new Consumer<File>() {
                    @Override
                    public void accept(File file) throws Exception {
                        //Obtain the downloaded image and save it locally
                        File chche = mContext.getCacheDir();
                        //The second parameter is the name of the directory you want to save
                        File appDir = new File(chche, "advert");
                        if (!appDir.exists()) {
                            appDir.mkdirs();
                        }
                        String fileName = System.currentTimeMillis() + ".jpg";
                        File destFile = new File(appDir, fileName);
                        //Copy the images downloaded from Gilde to the defined directory
                        copy(file, destFile);
                        LogUtil.e("LogUtils","下载成功 "+destFile.getPath());

                    }

                });
    }

    /**
     *Copying Files
     *
     *@param source input file
     *@param target output file
     */
    public static void copy(File source, File target) {
        FileInputStream fileInputStream = null;
        FileOutputStream fileOutputStream = null;
        try {
            fileInputStream = new FileInputStream(source);
            fileOutputStream = new FileOutputStream(target);
            byte[] buffer = new byte[1024];
            while (fileInputStream.read(buffer) > 0) {
                fileOutputStream.write(buffer);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try {
                fileInputStream.close();
                fileOutputStream.close();
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }
}
