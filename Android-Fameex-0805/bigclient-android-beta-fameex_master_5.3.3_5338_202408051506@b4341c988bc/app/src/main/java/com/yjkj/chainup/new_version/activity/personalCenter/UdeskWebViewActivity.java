package com.yjkj.chainup.new_version.activity.personalCenter;

import android.annotation.SuppressLint;
import android.annotation.TargetApi;
import android.app.Activity;
import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.net.Uri;
import android.net.http.SslError;
import android.os.Build;
import android.os.Bundle;
import android.view.View;
import android.view.Window;
import android.webkit.DownloadListener;
import android.webkit.SslErrorHandler;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.ImageView;

import com.alibaba.android.arouter.facade.annotation.Route;
import com.yjkj.chainup.R;
import com.yjkj.chainup.db.constant.ParamConstant;
import com.yjkj.chainup.db.constant.RoutePath;
import com.yjkj.chainup.new_version.view.ICloseWindow;
import com.yjkj.chainup.new_version.view.UdeskWebChromeClient;

@Route(path = RoutePath.UdeskWebViewActivity)
public class UdeskWebViewActivity extends Activity {
    private WebView mwebView;
    UdeskWebChromeClient udeskWebChromeClient;
    String url = "";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        super.onCreate(savedInstanceState);
        setContentView(R.layout.udesk_webview);
        url = getIntent().getStringExtra(ParamConstant.URL_4_SERVICE);
        initViews();
    }

    private void initViews() {
        try {
            udeskWebChromeClient = new UdeskWebChromeClient(this, new ICloseWindow() {
                @Override
                public void closeActivty() {
                    finish();
                }
            });
            mwebView = (WebView) findViewById(R.id.webview);
            settingWebView(url);
        } catch (Exception e) {
            e.printStackTrace();
        }
        ImageView iv_back_tx= (ImageView)findViewById(R.id.iv_back_tx);
        iv_back_tx.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                finish();
            }
        });
    }

    @SuppressLint("NewApi")
    private void settingWebView(String url) {

        //Support for obtaining gesture focus, entering username, password, or other
        mwebView.requestFocusFromTouch();
        mwebView.setScrollBarStyle(WebView.SCROLLBARS_OUTSIDE_OVERLAY);
        mwebView.setScrollbarFadingEnabled(false);

        final WebSettings settings = mwebView.getSettings();
        settings.setJavaScriptEnabled(true);  //Support for JS
        //Set up an adaptive screen for both
        settings.setUseWideViewPort(true); //Resize the image to fit the webview
        settings.setLoadWithOverviewMode(true); //Zoom to screen size

        //If setSupportZoom is false, then the WebView is not scalable and cannot be scaled regardless of the setting.
        settings.setSupportZoom(true);  //Supports scaling, defaults to true. It is a prerequisite for setBuiltInZoomControls.
        settings.setBuiltInZoomControls(true); //Set built-in zoom controls.
        settings.supportMultipleWindows();  //Multiple Windows

        settings.setAllowFileAccess(true);  //Set up access to files
        settings.setNeedInitialFocus(true); //Set the node for webview when it calls requestFocus

        settings.setJavaScriptCanOpenWindowsAutomatically(true); //Support for opening new windows through JS
        //Set encoding format
        settings.setDefaultTextEncodingName("UTF-8");
        //About whether to scale or not
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.HONEYCOMB) {
            settings.setDisplayZoomControls(false);
        }
        /**
         *Webview allows it to load mixed network protocol content by default before Android 5.0
         *After Android 5.0, it is not allowed to load mixed HTTP and HTTPS content by default, and a webview needs to be set to allow it to load mixed network protocol content
         */
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            settings.setMixedContentMode(WebSettings.MIXED_CONTENT_ALWAYS_ALLOW);

        }
//        dealJavascriptLeak();
        settings.setLoadsImagesAutomatically(true);  //Support for automatic loading of images

        settings.setDomStorageEnabled(true); //Enable DOM Storage

        mwebView.setDownloadListener(new DownloadListener() {
            @Override
            public void onDownloadStart(String url, String userAgent, String contentDisposition, String mimetype, long contentLength) {
                //Monitor download function, when the user clicks on the download link, directly call the system's browser to download
                Uri uri = Uri.parse(url);
                Intent intent = new Intent(Intent.ACTION_VIEW, uri);
                startActivity(intent);
            }
        });

        mwebView.setWebChromeClient(udeskWebChromeClient);
        mwebView.setWebViewClient(new WebViewClient() {
            @Override
            public void onPageFinished(WebView view, String url) {
                super.onPageFinished(view, url);
            }

            @Override
            public void onReceivedError(WebView view, int errorCode, String description, String failingUrl) {
                UdeskWebViewActivity.this.finish();
            }

            @Override
            public void onReceivedSslError(WebView view, SslErrorHandler handler, SslError error) {
                AlertDialog.Builder builder = new AlertDialog.Builder(view.getContext());
                builder.setMessage(getString(R.string.base_error_prompt5));
                builder.setPositiveButton(getString(R.string.common_text_btnConfirm), new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        handler.proceed();
                    }
                });

                builder.setNegativeButton(getString(R.string.common_text_btnCancel), new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        handler.cancel();
                    }
                });

                AlertDialog dialog = builder.create();
                dialog.show();
            }

            @Override
            public boolean shouldOverrideUrlLoading(WebView view, String url) {

                view.loadUrl(url);
                return true;
            }
        });
        mwebView.loadUrl(url);
    }

//    @TargetApi(Build.VERSION_CODES.HONEYCOMB)
//    private void dealJavascriptLeak() {
//        try {
//            mwebView.removeJavascriptInterface("searchBoxJavaBridge_");
//            mwebView.removeJavascriptInterface("accessibility");
//            mwebView.removeJavascriptInterface("accessibilityTraversal");
//        } catch (Exception e) {
//            e.printStackTrace();
//        }
//    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        udeskWebChromeClient.onActivityResult(requestCode, resultCode, data);
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        try {
            mwebView.removeAllViews();
            mwebView.destroy();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

}
