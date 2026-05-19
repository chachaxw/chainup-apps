package com.yjkj.chainup.util;


import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.net.Uri;
import android.os.Environment;

import com.yjkj.chainup.R;
import com.yjkj.chainup.bean.VersionData;
import com.yjkj.chainup.net.HttpClient;
import com.yjkj.chainup.net.retrofit.NetObserver;

import java.io.File;

import io.reactivex.android.schedulers.AndroidSchedulers;
import io.reactivex.schedulers.Schedulers;

public class UpdateHelper {

    private Context mContext;

    private boolean isShowDialog = false;


    /**
     *The folder path where the target file is stored
     */
    private String  destFileDir = Environment.getExternalStorageDirectory().getAbsolutePath() + File
            .separator + "M_DEFAULT_DIR";
    /**
     *The file name of the target file storage
     */
    private String destFileName = "exchange.apk";


    public boolean isShowDialog() {
        return isShowDialog;
    }

    public void setShowDialog(boolean showDialog) {
        isShowDialog = showDialog;
    }

    //    public interface onUpdateReturn
    public UpdateHelper(Context context) {
        this.mContext = context;
    }

    public void checkVersion() {
        HttpClient.Companion.getInstance()
                .checkVersion(System.currentTimeMillis() + "")
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(new NetObserver<VersionData>() {
                    @Override
                    protected void onHandleSuccess(VersionData versionData) {
                        if (versionData.getBuild() > getLocalVersion(mContext)) {
                            update(versionData);
                        } else {
                            if (!isShowDialog) return;
                            AlertDialog.Builder builder = new AlertDialog.Builder(mContext);
                            builder.setTitle(mContext.getString(R.string.update))
                                    .setMessage("已经是最新版本")
                                    .setPositiveButton(mContext.getString(R.string.common_text_btnConfirm), new DialogInterface.OnClickListener() {
                                        @Override
                                        public void onClick(DialogInterface dialog, int which) {
                                            dialog.dismiss();
                                        }
                                    }).show();
                        }
                    }
                });
    }


    public void update(VersionData versionData) {
        if (versionData == null) return;
        boolean isMustUp = versionData.getForce() == 1;
        AlertDialog.Builder builder = new AlertDialog.Builder(mContext);
        builder.setTitle(versionData.getTitle())
                .setMessage(versionData.getContent())
                .setPositiveButton(mContext.getString(R.string.update), new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        openApplicationMarket(mContext.getPackageName());
                    }
                });
        if (isMustUp) {
            builder.setCancelable(false);
        } else {
            builder.setNegativeButton(mContext.getString(R.string.ignore), new DialogInterface.OnClickListener() {
                @Override
                public void onClick(DialogInterface dialog, int which) {
                    dialog.dismiss();
                }
            });
        }
        builder.show();
    }

    /**
     *Open the app in the app store through the package name
     *
     *@param packageName Package name
     */
    private void openApplicationMarket(String packageName) {
        try {
            String str = "market://details?id=" + packageName;
            Intent localIntent = new Intent(Intent.ACTION_VIEW);
            localIntent.setData(Uri.parse(str));
            mContext.startActivity(localIntent);
        } catch (Exception e) {
            //Failed to open the app store, possibly due to no phone or app market installed
            e.printStackTrace();
//Toast. makeText (getAppContext()), "Failed to open App Store", Toast. LENGTH_ SHORT). show();
            //Call the system browser to enter the mall
            String url = "http://www.chainup.com";
            openLinkBySystem(url);
        }
    }

    /**
     *Call the system browser to open a webpage
     *
     *@param URL address
     */
    private void openLinkBySystem(String url) {
        Intent intent = new Intent(Intent.ACTION_VIEW);
        intent.setData(Uri.parse(url));
        mContext.startActivity(intent);
    }

    /**
     *Obtain the local Software versioning
     */
    public static int getLocalVersion(Context ctx) {
        int localVersion = 0;
        try {
            PackageInfo packageInfo = ctx.getApplicationContext()
                    .getPackageManager()
                    .getPackageInfo(ctx.getPackageName(), 0);
            localVersion = packageInfo.versionCode;
        } catch (PackageManager.NameNotFoundException e) {
            e.printStackTrace();
        }
        return localVersion;
    }


    /**
     *Get the name of the local Software versioning
     */
    public static String getLocalVersionName(Context ctx) {
        String localVersion = "";
        try {
            PackageInfo packageInfo = ctx.getApplicationContext()
                    .getPackageManager()
                    .getPackageInfo(ctx.getPackageName(), 0);
            localVersion = packageInfo.versionName;
        } catch (PackageManager.NameNotFoundException e) {
            e.printStackTrace();
        }
        return localVersion;
    }


    /**
     *Install software
     *
     * @param file
     */
    private void installApk(File file) {
        Uri uri = Uri.fromFile(file);
        Intent install = new Intent(Intent.ACTION_VIEW);
        install.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        install.setDataAndType(uri, "application/vnd.android.package-archive");
        //Execute intention for installation
        mContext.startActivity(install);
    }

}
