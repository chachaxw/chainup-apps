package com.yjkj.chainup.util;

import android.Manifest;
import android.app.Activity;
import android.app.AlertDialog;
import android.app.Dialog;
import android.content.Intent;
import android.net.Uri;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.LinearLayout;
import android.widget.ProgressBar;
import android.widget.RelativeLayout;
import android.widget.TextView;

import androidx.annotation.NonNull;

import com.azhon.appupdate.listener.OnDownloadListener;
import com.azhon.appupdate.manager.DownloadManager;
import com.chainup.kit.views.KKButtonKit;
import com.jakewharton.rxbinding2.view.RxView;
import com.tbruyelle.rxpermissions2.Permission;
import com.tbruyelle.rxpermissions2.RxPermissions;
import com.yjkj.chainup.R;
import com.yjkj.chainup.db.service.CheckUpdateDataService;
import com.yjkj.chainup.db.service.PublicInfoDataService;
import com.yjkj.chainup.manager.LanguageUtil;
import com.yjkj.chainup.model.model.MainModel;
import com.yjkj.chainup.net_new.NetUrl;
import com.yjkj.chainup.net_new.rxjava.NDisposableObserver;
import com.yjkj.chainup.new_version.dialog.NewDialogUtils;
import com.yjkj.chainup.new_version.home.GuideKt;
import com.yjkj.chainup.update.ApkDownloadListener;
import com.yjkj.chainup.update.ApkDownloadUtils;

import org.jetbrains.annotations.NotNull;
import org.jetbrains.annotations.Nullable;
import org.json.JSONObject;

import java.io.File;

import cn.ljuns.logcollector.util.FileUtils;
import io.reactivex.functions.Consumer;
import com.chainup.contract.utils.CpPermissionUtil;
public class CheckUpdateUtil {

    private static final String TAG = "CheckUpdateUtil";

    /**
     *Check for upgrades
     * AppUpdateBean(build = 0, downloadUrl = null, force = 0, title = null, version = null, content = null)
     * <p>
     *Force: 0- not mandatory; 1- Force upgrade
     *
     *@param isAutoUpdate true for automatic upgrade, false for manual click to check for updates
     */
    public static void update(final Activity activity, final boolean isAutoUpdate) {
        Activity loadingActivity = activity;
        if (isAutoUpdate) {
            loadingActivity = null;
        }
        LogUtil.d(TAG, "CheckUpdateUtil==");

        new MainModel().getAppVersion(new NDisposableObserver(loadingActivity, false) {
            @Override
            public void onResponseSuccess(@NotNull JSONObject jsonObject) {
                LogUtil.d(TAG, "CheckUpdateUtil==onResponseSuccess==jsonObject is " + jsonObject);

                String code = jsonObject.optString("code");
                if (!"0".equals(code)) {
                    String msg = jsonObject.optString("msg");
                    if (!isAutoUpdate) {
                        NToastUtil.showTopToastNet(activity, true, msg);
                    }
                    return;
                }

                JSONObject data = jsonObject.optJSONObject("data");
                if (null != data) {
                    int build = data.optInt("build");

                    int localVersionCode = UpdateHelper.getLocalVersion(activity);
                    if (localVersionCode < build) {
                        boolean isForce = (1 == data.optInt("forceUpdate"));

                        if(isAutoUpdate && PublicInfoDataService.getInstance().isShowUpdate()){
                            showUpdateDialog(activity, data);
                        }
                        if(!isAutoUpdate){
                            showUpdateDialog(activity, data);

                        }else if(isForce){

                            showUpdateDialog(activity, data);
                        }

                    } else {
                        if (!isAutoUpdate) {
                            NToastUtil.showTopToastNet(activity, true, LanguageUtil.getString(activity, "the_latest_version"));
                        }
                    }
                }
            }

            @Override
            public void onResponseFailure(int code, @Nullable String msg) {
                super.onResponseFailure(code, msg);
                LogUtil.d(TAG, "CheckUpdateUtil==onResponseFailure==code is " + code + ",msg is " + msg);
                if (!isAutoUpdate) {
                    NToastUtil.showTopToastNet(activity, false, msg);
                }
            }
        });

    }

    /**
     *Upgraded Popup
     */
    private static Dialog showUpdateDialog(Activity activity, JSONObject data) {
        if (GuideKt.getDialogType() != 0) return null;
        boolean isForce = (1 == data.optInt("forceUpdate"));
        String downloadUrl = data.optString("downloadUrl");
        String title = data.optString("title");
        int version =  data.optInt("build");
        int systemType =  data.optInt("systemType");
        String content = data.optString("content");

        final AlertDialog dialog = new AlertDialog.Builder(activity).create();
        dialog.getWindow().setBackgroundDrawableResource(android.R.color.transparent);
        View view = LayoutInflater.from(activity).inflate(R.layout.dialog_update, null);
        TextView tv_title = view.findViewById(R.id.tv_title);
        TextView tv_content = view.findViewById(R.id.tv_content);
        KKButtonKit btn_cancel_download = view.findViewById(R.id.btn_cancel_download);
        KKButtonKit btn_cancel = view.findViewById(R.id.btn_cancel);
        KKButtonKit btn_confirm = view.findViewById(R.id.btn_confirm);
        LinearLayout ll_download_progress = view.findViewById(R.id.ll_download_progress);
        RelativeLayout rl_update_ctrl = view.findViewById(R.id.rl_update_ctrl);
        ProgressBar pb_progress = view.findViewById(R.id.pb_progress);
        TextView tv_progress = view.findViewById(R.id.tv_progress);
        TextView tv_update_downloading = view.findViewById(R.id.tv_update_downloading);

        tv_title.setText("" + title);
        tv_content.setText("" + content);

        tv_update_downloading.setText(LanguageUtil.INSTANCE.getString(activity,"update_downloading"));
        btn_confirm.setTextContent(LanguageUtil.INSTANCE.getString(activity,"update_now"));
        btn_cancel.setTextContent(LanguageUtil.INSTANCE.getString(activity,"delay_upgrade"));
        btn_cancel_download.setTextContent(LanguageUtil.INSTANCE.getString(activity,"cancel"));

        btn_cancel.setVisibility(isForce ? View.GONE : View.VISIBLE);

        DownloadManager mDownloadManager = new DownloadManager
                .Builder(activity)
                .apkUrl(downloadUrl)
                .apkName(AppUtils.INSTANCE.getAppName(activity)+".apk")
                .smallIcon(R.mipmap.ic_launcher)
                .showBgdToast(false)
                .onDownloadListener(new OnDownloadListener() {
                    @Override
                    public void start() {
                        ll_download_progress.setVisibility(View.VISIBLE);
                        rl_update_ctrl.setVisibility(View.GONE);
                    }

                    @Override
                    public void downloading(int max ,int progress) {
                        int curr = (int)(progress / Double.parseDouble(String.valueOf(max)) * 100.0);
                        pb_progress.setProgress(curr);
                        tv_progress.setText(curr + "%");
                    }

                    @Override
                    public void done(@NonNull File file) {

                    }

                    @Override
                    public void cancel() {
//                        NToastUtil.showTopToastNet(activity, false, "取消更新");
                    }

                    @Override
                    public void error(@NonNull Throwable throwable) {
                        NToastUtil.showTopToastNet(activity, false, throwable.getMessage());
                    }
                })
                .build();

        GuideKt.setDialogType(1);
        btn_cancel.setOnClickListener(new View.OnClickListener() {

            @Override
            public void onClick(View v) {
                GuideKt.setDialogType(0);
                CheckUpdateDataService.getInstance().saveUpdateData(CheckUpdateDataService.hideDialog,version);
                dialog.dismiss();
            }
        });
        btn_cancel_download.setOnClickListener(new View.OnClickListener() {

            @Override
            public void onClick(View v) {
                mDownloadManager.cancel();
                if(isForce){
                    ll_download_progress.setVisibility(View.GONE);
                    rl_update_ctrl.setVisibility(View.VISIBLE);
                }else {
                    GuideKt.setDialogType(0);
//                    mApkDownloadUtils.cancelInstall();
                    dialog.dismiss();
                }
            }
        });
        String storePath = FileUtils.getCacheFileDir(activity, "apks");
        File appDir = new File(storePath);
        if (!appDir.exists()) {
            appDir.mkdir();
        }
        RxPermissions mRxPermissions = new RxPermissions(activity);
        RxView.clicks(btn_confirm)
                .compose(mRxPermissions.ensureEach(StringOfExtKt.getAppSharePermission("share")))
                .subscribe(
                        new Consumer<Permission>() {
                            @Override
                            public void accept(Permission permission) throws Exception {
                                if (permission.granted) {
                                    if(systemType==2){
                                        String appPackageName = AppUtils.INSTANCE.getPackageName(activity);
                                        String marketUri = "market://details?id=" + appPackageName;
                                        String webUri = "https://play.google.com/store/apps/details?id=" + appPackageName;
                                        try {
                                            Intent webIntent = new Intent(Intent.ACTION_VIEW, Uri.parse(downloadUrl));
                                            activity.startActivity(webIntent);
                                        } catch (android.content.ActivityNotFoundException anfe) {
                                            ToastUtils.showToast("Jump link configuration error");
                                        }
                                    }else {
                                        mDownloadManager.download();
                                    }
                                } else {
                                    CpPermissionUtil.INSTANCE.showOpenPermission(activity, LanguageUtil.getString(activity, "warn_storage_permission"));
                                }
                            }
                        });

        dialog.setView(view);
        dialog.setCancelable(false);
        if (!activity.isFinishing()) {
            dialog.show();
        }
        return dialog;
    }

}
