package com.yjkj.chainup.util;


import android.app.Activity;
import android.content.ClipData;
import android.content.ClipboardManager;
import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Color;
import android.graphics.Typeface;
import android.os.AsyncTask;
import android.os.Environment;
import android.renderscript.Allocation;
import android.renderscript.Element;
import android.renderscript.RenderScript;
import android.renderscript.ScriptIntrinsicBlur;
import android.text.InputType;
import android.text.SpannableString;
import android.text.Spanned;
import android.text.TextUtils;
import android.text.style.AbsoluteSizeSpan;
import android.text.style.ForegroundColorSpan;
import android.text.style.StyleSpan;
import android.util.Base64;
import android.util.DisplayMetrics;
import android.util.Log;
import android.view.KeyCharacterMap;
import android.view.KeyEvent;
import android.view.View;
import android.view.ViewConfiguration;
import android.view.WindowManager;
import android.webkit.WebView;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.Nullable;

import com.blankj.utilcode.util.GsonUtils;
import com.chainup.contract.app.CpMyApp;
import com.geetest.sdk.GT3ConfigBean;
import com.geetest.sdk.GT3ErrorBean;
import com.geetest.sdk.GT3GeetestUtils;
import com.geetest.sdk.GT3Listener;
import com.google.gson.Gson;
import com.google.gson.JsonObject;
import com.google.gson.reflect.TypeToken;
import com.yjkj.chainup.BuildConfig;
import com.yjkj.chainup.R;
import com.yjkj.chainup.app.AppConfig;
import com.yjkj.chainup.app.ChainUpApp;
import com.yjkj.chainup.bean.GeetestBean;
import com.yjkj.chainup.db.service.PublicInfoDataService;
import com.yjkj.chainup.manager.CpLanguageUtil;
import com.yjkj.chainup.manager.LanguageUtil;
import com.yjkj.chainup.net_new.JSONUtil;
import com.yjkj.chainup.net_new.NetUrl;
import com.yjkj.chainup.new_version.view.Gt3GeeListener;
import com.yjkj.chainup.new_version.view.OnSaveSuccessListener;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.lang.reflect.Type;
import java.net.HttpURLConnection;
import java.net.URI;
import java.net.URL;
import java.text.DateFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.List;
import java.util.Locale;

import javax.net.ssl.HttpsURLConnection;

public class Utils {


    public static void copyString(TextView textView) {
        if (textView == null) {
            return;
        }
        ClipboardManager cm = (ClipboardManager) textView.getContext().getSystemService(Context.CLIPBOARD_SERVICE);
        if (cm != null) {
            cm.setPrimaryClip(ClipData.newPlainText(null, textView.getText()));
//UIUtils. showToast ("Copy successful");
        }
    }


    public static int getScreemWidth(Activity context) {
        DisplayMetrics metric = new DisplayMetrics();
        context.getWindowManager().getDefaultDisplay().getMetrics(metric);
        return metric.widthPixels;     //Screen width (pixels)
    }

    public static String getOrderType(Context context, int num) {
        String type = "";
        switch (num) {
            case 1:
                type = LanguageUtil.getString(context, "otc_text_orderWaitPay");
                break;
            case 2:
            case 6:
                type = LanguageUtil.getString(context, "otc_text_waitReceiveCoin");
                break;
            case 3:
            case 8:
                type = LanguageUtil.getString(context, "otc_text_orderComplete");
                break;
            case 4:
            case 9:
                type = LanguageUtil.getString(context, "filter_otc_cancel");
                break;
            case 5:
                type = LanguageUtil.getString(context, "otc_text_orderAppeal");
                break;
            case 7:
                type = LanguageUtil.getString(context, "otc_abnormal_orders");
                break;
            default:
                break;

        }
        return type;
    }


    public static String getOrderTypeSell(Context context, int num) {
        String type = "";
        switch (num) {
            case 1:
                type = LanguageUtil.getString(context, "otc_text_orderWaitMoney");
                break;
            case 2:
            case 6:
                type = LanguageUtil.getString(context, "otc_text_waitSendCoin");
                break;
            case 3:
            case 8:
                type = LanguageUtil.getString(context, "otc_text_orderComplete");
                break;
            case 4:
                type = LanguageUtil.getString(context, "filter_otc_cancel");
                break;
            case 5:
                type = LanguageUtil.getString(context, "otc_text_orderAppeal");
                break;
            case 7:
                type = LanguageUtil.getString(context, "otc_abnormal_orders");
                break;
            case 9:
                type = LanguageUtil.getString(context, "filter_otc_appealCancel");
                break;
            default:
                break;
        }
        return type;
    }

    /**
     *Copy Text
     *
     * @param string
     */
    public static void copyString(String string) {
        ClipboardManager cm = (ClipboardManager) ChainUpApp.appContext.getSystemService(Context.CLIPBOARD_SERVICE);
        if (cm != null) {
            cm.setPrimaryClip(ClipData.newPlainText(null, string));
        }
    }


    //Gaussian blur background
    public static Bitmap blurBitmap(Bitmap bitmap, Context context) {
        Bitmap outBitmap = Bitmap.createBitmap(bitmap.getWidth(),
                bitmap.getHeight(), Bitmap.Config.ARGB_8888);

        RenderScript rs = RenderScript.create(context);

        ScriptIntrinsicBlur blurScript = ScriptIntrinsicBlur.create(rs,
                Element.U8_4(rs));

        Allocation allIn = Allocation.createFromBitmap(rs, bitmap);
        Allocation allOut = Allocation.createFromBitmap(rs, outBitmap);

        blurScript.setRadius(20.f);

        // Perform the Renderscript
        blurScript.setInput(allIn);
        blurScript.forEach(allOut);

        // Copy the final bitmap created by the out Allocation to the outBitmap
        allOut.copyTo(outBitmap);

        // recycle the original bitmap
        bitmap.recycle();

        // After finishing everything, we destroy the Renderscript.
        rs.destroy();

        return outBitmap;
    }

    public static Bitmap createBlurBitmap(Bitmap sentBitmap, int radius) {
        Bitmap bitmap = sentBitmap.copy(sentBitmap.getConfig(), true);
        if (radius < 1) {
            return (null);
        }
        int w = bitmap.getWidth();
        int h = bitmap.getHeight();
        int[] pix = new int[w * h];
        bitmap.getPixels(pix, 0, w, 0, 0, w, h);
        int wm = w - 1;
        int hm = h - 1;
        int wh = w * h;
        int div = radius + radius + 1;
        int[] r = new int[wh];
        int[] g = new int[wh];
        int[] b = new int[wh];
        int rsum, gsum, bsum, x, y, i, p, yp, yi, yw;
        int[] vmin = new int[Math.max(w, h)];
        int divsum = (div + 1) >> 1;
        divsum *= divsum;
        int[] dv = new int[256 * divsum];
        for (i = 0; i < 256 * divsum; i++) {
            dv[i] = (i / divsum);
        }
        yw = yi = 0;
        int[][] stack = new int[div][3];
        int stackpointer;
        int stackstart;
        int[] sir;
        int rbs;
        int r1 = radius + 1;
        int routsum, goutsum, boutsum;
        int rinsum, ginsum, binsum;
        for (y = 0; y < h; y++) {
            rinsum = ginsum = binsum = routsum = goutsum = boutsum = rsum = gsum = bsum = 0;
            for (i = -radius; i <= radius; i++) {
                p = pix[yi + Math.min(wm, Math.max(i, 0))];
                sir = stack[i + radius];
                sir[0] = (p & 0xff0000) >> 16;
                sir[1] = (p & 0x00ff00) >> 8;
                sir[2] = (p & 0x0000ff);
                rbs = r1 - Math.abs(i);
                rsum += sir[0] * rbs;
                gsum += sir[1] * rbs;
                bsum += sir[2] * rbs;
                if (i > 0) {
                    rinsum += sir[0];
                    ginsum += sir[1];
                    binsum += sir[2];
                } else {
                    routsum += sir[0];
                    goutsum += sir[1];
                    boutsum += sir[2];
                }
            }
            stackpointer = radius;
            for (x = 0; x < w; x++) {
                r[yi] = dv[rsum];
                g[yi] = dv[gsum];
                b[yi] = dv[bsum];
                rsum -= routsum;
                gsum -= goutsum;
                bsum -= boutsum;
                stackstart = stackpointer - radius + div;
                sir = stack[stackstart % div];
                routsum -= sir[0];
                goutsum -= sir[1];
                boutsum -= sir[2];
                if (y == 0) {
                    vmin[x] = Math.min(x + radius + 1, wm);
                }
                p = pix[yw + vmin[x]];
                sir[0] = (p & 0xff0000) >> 16;
                sir[1] = (p & 0x00ff00) >> 8;
                sir[2] = (p & 0x0000ff);
                rinsum += sir[0];
                ginsum += sir[1];
                binsum += sir[2];
                rsum += rinsum;
                gsum += ginsum;
                bsum += binsum;
                stackpointer = (stackpointer + 1) % div;
                sir = stack[(stackpointer) % div];
                routsum += sir[0];
                goutsum += sir[1];
                boutsum += sir[2];
                rinsum -= sir[0];
                ginsum -= sir[1];
                binsum -= sir[2];
                yi++;
            }
            yw += w;
        }
        for (x = 0; x < w; x++) {
            rinsum = ginsum = binsum = routsum = goutsum = boutsum = rsum = gsum = bsum = 0;
            yp = -radius * w;
            for (i = -radius; i <= radius; i++) {
                yi = Math.max(0, yp) + x;
                sir = stack[i + radius];
                sir[0] = r[yi];
                sir[1] = g[yi];
                sir[2] = b[yi];
                rbs = r1 - Math.abs(i);
                rsum += r[yi] * rbs;
                gsum += g[yi] * rbs;
                bsum += b[yi] * rbs;
                if (i > 0) {
                    rinsum += sir[0];
                    ginsum += sir[1];
                    binsum += sir[2];
                } else {
                    routsum += sir[0];
                    goutsum += sir[1];
                    boutsum += sir[2];
                }
                if (i < hm) {
                    yp += w;
                }
            }
            yi = x;
            stackpointer = radius;
            for (y = 0; y < h; y++) {
                pix[yi] = (0xff000000 & pix[yi]) | (dv[rsum] << 16)
                        | (dv[gsum] << 8) | dv[bsum];
                rsum -= routsum;
                gsum -= goutsum;
                bsum -= boutsum;
                stackstart = stackpointer - radius + div;
                sir = stack[stackstart % div];
                routsum -= sir[0];
                goutsum -= sir[1];
                boutsum -= sir[2];
                if (x == 0) {
                    vmin[y] = Math.min(y + r1, hm) * w;
                }
                p = x + vmin[y];
                sir[0] = r[p];
                sir[1] = g[p];
                sir[2] = b[p];
                rinsum += sir[0];
                ginsum += sir[1];
                binsum += sir[2];
                rsum += rinsum;
                gsum += ginsum;
                bsum += binsum;
                stackpointer = (stackpointer + 1) % div;
                sir = stack[stackpointer];
                routsum += sir[0];
                goutsum += sir[1];
                boutsum += sir[2];
                rinsum -= sir[0];
                ginsum -= sir[1];
                binsum -= sir[2];
                yi += w;
            }
        }
        bitmap.setPixels(pix, 0, w, 0, 0, w, h);
        return (bitmap);
    }


    public static Bitmap stringtoBitmap(String string) {
        //Convert string to Bitmap type
        Bitmap bitmap = null;
        try {
            byte[] bitmapArray;
            bitmapArray = Base64.decode(string, Base64.DEFAULT);
            bitmap = BitmapFactory.decodeByteArray(bitmapArray, 0, bitmapArray.length);
        } catch (Exception e) {
            e.printStackTrace();
        }

        return bitmap;
    }

    public static byte[] String2Byte(String string) {
        byte[] bytes = string.getBytes();
        return bytes;
    }


    /**
     *Obtain screen resolution
     *
     * @param context
     * @return
     */
    public static int[] getScreenDispaly(Context context) {
        WindowManager windowManager = (WindowManager) context.getSystemService(Context.WINDOW_SERVICE);
        int width = windowManager.getDefaultDisplay().getWidth();//The width of the phone screen
        int height = windowManager.getDefaultDisplay().getHeight();//The height of the phone screen
        int[] result = {width, height};
        return result;
    }


//    public static void isShowPass(boolean isShow, ImageView imageView, EditText editText) {
//        if (isShow) {
//            imageView.setImageResource(R.drawable.visible);
////Two types need to be used together, plus TYPE_ Class_ TEXT is to prevent Chinese input
//            editText.setInputType(InputType.TYPE_TEXT_VARIATION_VISIBLE_PASSWORD);
//        } else {
//            imageView.setImageResource(R.drawable.hide);
//            editText.setInputType(InputType.TYPE_TEXT_VARIATION_PASSWORD);
//        }
////Cursor placed last
//        editText.setSelection(editText.length());
//    }


    public static void isShowPass(boolean isShow, ImageView imageView, EditText editText) {
        if (isShow) {
            imageView.setImageResource(R.mipmap.login_eyeon);
            //Two types need to be used together, plus TYPE_ Class_ TEXT is to prevent Chinese input
            editText.setInputType(InputType.TYPE_CLASS_TEXT |InputType.TYPE_TEXT_VARIATION_VISIBLE_PASSWORD);
        } else {
            imageView.setImageResource(R.mipmap.login_eyeoff);
            editText.setInputType(InputType.TYPE_CLASS_TEXT |InputType.TYPE_TEXT_VARIATION_PASSWORD);
        }
        editText.setTypeface(Typeface.SANS_SERIF);
        //Cursor placed last
        editText.setSelection(editText.length());
    }

    /*
     *Display and Hide Control of Asset Data on Home Page
     */
    public static void assetsHideShow(boolean isShow, TextView textView, String content) {
        if (isShow) {
            if (StringUtil.checkStr(content)) {
                textView.setText(content + "");
            } else {
                textView.setText("0");
            }
        } else {
            textView.setText("*****");
        }
    }


    /*
     *Display and hide control of asset data on the homepage, compatible with ultra long data versions
     */
    public static void assetsHideShowJrLongData(boolean isShow, TextView textView, String content1, String content2) {
        if (isShow) {
            StringBuilder builder = new StringBuilder();
            builder.append(content1).append(content2);
            if (StringUtil.checkStr(content1) && StringUtil.checkStr(content2)) {
                SpannableString spannableString = new SpannableString(builder.toString());

                ForegroundColorSpan span = new ForegroundColorSpan(Color.WHITE);
                spannableString.setSpan(span, 0, content1.length(), Spanned.SPAN_EXCLUSIVE_INCLUSIVE);

                AbsoluteSizeSpan relativeSizeSpanleft = new AbsoluteSizeSpan(28, true);


                spannableString.setSpan(relativeSizeSpanleft, 0, content1.length(), Spanned.SPAN_EXCLUSIVE_INCLUSIVE);

                StyleSpan styleSpan = new StyleSpan(Typeface.BOLD);

                spannableString.setSpan(styleSpan, 0, content1.length(), Spanned.SPAN_EXCLUSIVE_INCLUSIVE);

                AbsoluteSizeSpan relativeSizeSpanRight = new AbsoluteSizeSpan(12, true);

                spannableString.setSpan(relativeSizeSpanRight, content1.length(), builder.length(), Spanned.SPAN_EXCLUSIVE_INCLUSIVE);


                textView.setText(spannableString);
            } else {
                textView.setText("0");
            }
        } else {
            textView.setText("*****");
        }
    }

    public static void showAssetsSwitch(boolean isShow, ImageView imageView) {
        if (imageView == null) return;
        if (isShow) {
            imageView.setImageResource(R.drawable.visible);
        } else {
            imageView.setImageResource(R.drawable.hide);
        }
    }

    public static void showAssetsNewSwitch(boolean isShow, ImageView imageView) {
        if (imageView == null) return;
        if (isShow) {
            imageView.setImageResource(R.drawable.assets_visible);
        } else {
            imageView.setImageResource(R.drawable.assets_invisible);
        }
    }

    /*
     *Home page asset data visible and invisible
     */
    public static void assetsVisible(boolean isShow, View view) {
        view.setVisibility(isShow ? View.VISIBLE : View.INVISIBLE);
    }

    public static String deleteHeader(String code) {
        int start = code.indexOf("<header>");
        int end = code.indexOf("</header>");
        if (start != 0 && end != 0 && start < end) {
            //From the starting position to the ending position, excluding the ending position
            String content = code.substring(start, end + 9);
            code = code.replace(content, "");
        }
        return code;
    }


    public static String getVolUnit(float num) {

        int e = (int) Math.floor(Math.log10(num));

        if (e >= 8) {
            return "亿手";
        } else if (e >= 4) {
            return "万手";
        } else {
            return "手";
        }
    }


    /**
     *Reading files from the assets directory
     *
     * @param context
     * @param fileName
     * @return
     */
    private String getCert(Context context, String fileName) {
        InputStream inputStream = null;
        String string = null;
        try {
            inputStream = context.getAssets().open(fileName);
            int size = inputStream.available();
            byte[] byteArray = new byte[size];
            inputStream.read(byteArray);
            string = new String(byteArray);
        } catch (IOException e) {
            e.printStackTrace();
        } finally {
            try {
                inputStream.close();
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
        return string;
    }

    /**
     *Time conversion
     */
    public static String formatDate(long time, String format) {
        DateFormat dateFormat2 = new SimpleDateFormat(format, Locale.getDefault());
        String formatDate = dateFormat2.format(time);
        return formatDate;
    }


    public static String formatDate(long time) {
        DateFormat dateFormat2 = new SimpleDateFormat("yyyy-MM-dd", Locale.getDefault());
        String formatDate = dateFormat2.format(time);
        return formatDate;
    }


    public static String formatDateTime(long date) {
        DateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm", Locale.getDefault());
        String formatDate = dateFormat.format(date);
        return formatDate;
    }


    public static String formatTime(long millis) {
        DateFormat dateFormat = new SimpleDateFormat("HH:mm", Locale.getDefault());
        String formatDate = dateFormat.format(millis);
        return formatDate;
    }

    /**
     *Used to determine whether to quickly click
     *
     * @return
     */
    private static final int FAST_CLICK_DELAY_TIME = 1000;
    private static long lastClickTime;


    public synchronized static boolean isFastClick() {
        boolean flag = false;
        long currentClickTime = System.currentTimeMillis();
        if ((currentClickTime - lastClickTime) <= FAST_CLICK_DELAY_TIME) {
            return true;
        }
        lastClickTime = currentClickTime;
        return flag;
    }

    public static GT3GeetestUtils gt3GeetestUtils;
    public static GT3ConfigBean gt3ConfigBean;

    /**
     *Extreme test
     *
     * @param context
     * @return
     */
    public static ArrayList<String> gee3test(Context context,GeetestBean paramBean, Gt3GeeListener listener) {
        new WebView(context).destroy();
        ArrayList<String> validateParams = new ArrayList<>(3);

        gt3GeetestUtils = new GT3GeetestUtils(context);
        gt3ConfigBean = new GT3ConfigBean();
        //Set validation mode, 1: bind, 2: unbind
        gt3ConfigBean.setPattern(1);
        gt3ConfigBean.setReleaseLog(true);
        //Set whether clicking on the gray area will disappear, default not to disappear
        gt3ConfigBean.setCanceledOnTouchOutside(false);
        //Set the language, if null, use the system default language
        gt3ConfigBean.setLang(NLanguageUtil.getLanguage().split("_")[0]);
        //Set the timeout for loading the webview. The unit is milliseconds. The default is 10000. Only the timeout for loading the static file of the webview, excluding previous http requests
        gt3ConfigBean.setTimeout(10000);
        //Set webview request timeout (user clicks or swipes complete, front-end requests backend interface), in milliseconds, default to 10000
        gt3ConfigBean.setWebviewTimeout(10000);
        //Set callback listening
        gt3ConfigBean.setListener(new GT3Listener() {
            String validateResult = "";
            /**
             *Verification code loading completed
             *@param duration loading time and version information, in JSON format
             */
            @Override
            public void onDialogReady(String duration) {
                Log.e("gee3test", "GT3BaseListener-->onDialogReady-->" + duration);
            }

            @Override
            public void onReceiveCaptchaCode(int i) {

            }

            /**
             *Verification results
             * @param result
             */
            @Override
            public void onDialogResult(String result) {
                validateResult = result;
                Log.e("gee3test", "GT3BaseListener-->onDialogResult-->" + result);
                //Enable api2 logic
                new RequestAPI2().execute(result);
            }



            /**
             *Statistical information, refer to access documentation
             * @param result
             */
            @Override
            public void onStatistics(String result) {
                Log.e("gee3test", "GT3BaseListener-->onStatistics-->" + result);
            }

            /**
             *Verification code turned off
             *@param num 1. Click on the close button of the verification code to close the verification code, 2. Click on the screen to close the verification code, 3. Click on the return button to close the verification code
             */
            @Override
            public void onClosed(int num) {
                Log.e("gee3test", "GT3BaseListener-->onClosed-->" + num);
            }

            /**
             *Verification successful callback
             * @param result
             */
            @Override
            public void onSuccess(String result) {
                Log.e("gee3test", "GT3BaseListener-->onSuccess-->" + result + ",validateResult is " + validateResult);

                if (!StringUtil.checkStr(validateResult))
                    return;

                if (!validateParams.isEmpty()) {
                    validateParams.clear();
                }

                try {
                    //1. Extract the three parameters returned by the interface for custom secondary validation
                    JSONObject jsonObject = new JSONObject(validateResult);
                    validateParams.add(jsonObject.optString("geetest_challenge"));
                    validateParams.add(jsonObject.optString("geetest_validate"));
                    validateParams.add(jsonObject.optString("geetest_seccode"));

                    if (listener != null) {
                        listener.onSuccess(validateParams);
                    }
                } catch (JSONException e) {
                    e.printStackTrace();
                }
            }

            /**
             *Verification failure callback
             *@param errorBean version number, error code, error description, and other information
             */
            @Override
            public void onFailed(GT3ErrorBean errorBean) {
                Log.e("gee3test", "GT3BaseListener-->onFailed-->" + errorBean.toString());
              String errorDesc=  errorBean.errorDesc;
                if (errorBean.errorCode.equals("205")){
                    errorDesc= CpLanguageUtil.getString(CpMyApp.Companion.instance(),"cp_extra_text10");
                }
                NToastUtil.showTopToastNet((Activity) context, false, errorDesc);
            }

            /**
             *Api1 callback
             */
            @Override
            public void onButtonClick() {
                new RequestAPI1(paramBean).execute();
            }
        });
        gt3GeetestUtils.init(gt3ConfigBean);
        //Enable verification
        gt3GeetestUtils.startCustomFlow();

        return validateParams;
    }

    public static void setGeetestDeatroy() {
        if (gt3GeetestUtils!=null){
            gt3GeetestUtils.destory();
        }
        gt3GeetestUtils=null;
        gt3ConfigBean=null;
    }

    /**
     *Request api1
     */
    static class RequestAPI1 extends AsyncTask<Void, Void, JSONObject> {
        private GeetestBean dataParams;
        public RequestAPI1(GeetestBean dataParams){
            this.dataParams = dataParams;
        }
        @Override
        protected JSONObject doInBackground(Void... params) {
//            String string = HttpUtils.requsetUrl(NetUrl.baseUrl() + "common/tartCaptcha");
//            HttpClient.Companion.getInstance().getTartCaptcha()
//                    .subscribeOn(Schedulers.io())
//                    .observeOn(AndroidSchedulers.mainThread())
//                    .subscribe(new NetObserver<String>() {
//
//                        @Override
//                        protected void onHandleSuccess(String s) {
//
//                        }
//
//
//                    });

            JSONObject jsonObject = null;
//            JSONObject jsonObject2;
//            JSONObject jsonObject3 = null;

            try {
                jsonObject = new JSONObject(GsonUtils.toJson(dataParams));
//                jsonObject2 = jsonObject.getJSONObject("data");
//                jsonObject3 = jsonObject2.getJSONObject("captcha");
            } catch (Exception e) {
                e.printStackTrace();
            }
            return jsonObject;
        }

        @Override
        protected void onPostExecute(JSONObject parmas) {
            //Continue verification

            Log.e("gee3test", "RequestAPI1-->onPostExecute: " + parmas);
            //SDK recognizable format is
            // {"success":1,"challenge":"06fbb267def3c3c9530d62aa2d56d018","gt":"019924a82c70bb123aae90d483087f94","new_captcha":true}
            //TODO setting returns api1 data, even if it is null, it must be set. The SDK has already processed it internally
            try {
                gt3ConfigBean.setApi1Json(parmas);
                //Continue API validation
                gt3GeetestUtils.getGeetest();
            } catch (Exception e) {
                e.printStackTrace();
            }

        }
    }


    /**
     *Request api2
     */
    static class RequestAPI2 extends AsyncTask<String, Void, String> {

        @Override
        protected String doInBackground(String... params) {
            return params[0];
        }

        @Override
        protected void onPostExecute(String result) {
            Log.i("gee3test", "RequestAPI2-->onPostExecute: " + result);

            gt3GeetestUtils.showSuccessDialog();
        }
    }


    //Get hours
    public static int getHour(Date date) {
        Calendar calendar = Calendar.getInstance();
        calendar.setTime(date);
        return calendar.get(Calendar.HOUR_OF_DAY);
    }

    //Get minutes
    public static int getMinute(Date date) {
        Calendar calendar = Calendar.getInstance();
        calendar.setTime(date);
        return calendar.get(Calendar.MINUTE);
    }

    //Get Week
    public static int getWeek(Date date) {
        Calendar calendar = Calendar.getInstance();
        calendar.setTime(date);
        return calendar.get(Calendar.DAY_OF_WEEK);
    }

    //Get Week
    public static int getWeek(int year, int moth, int day) {
        Calendar calendar = Calendar.getInstance();
        calendar.set(year, moth - 1, day);
        return calendar.get(Calendar.DAY_OF_WEEK);
    }

    //Obtain Year
    public static int getYear(Date date) {
        Calendar calendar = Calendar.getInstance();
        calendar.setTime(date);
        return calendar.get(Calendar.YEAR);
    }

    //Get Month
    public static int getMoth(Date date) {
        Calendar calendar = Calendar.getInstance();
        calendar.setTime(date);
        return calendar.get(Calendar.MONTH) + 1;
    }

    //Get Day
    public static int getDay(Date date) {
        Calendar calendar = Calendar.getInstance();
        calendar.setTime(date);
        return calendar.get(Calendar.DATE);
    }

    public static Date getDate(int year, int moth, int day, int hour, int minute) {
        Calendar calendar = Calendar.getInstance();
        calendar.set(year, moth - 1, day, hour, minute);
        return calendar.getTime();
    }

    public static Date getDate(int year, int moth, int day) {
        Calendar calendar = Calendar.getInstance();
        calendar.set(year, moth - 1, day,0,0,0);
        return calendar.getTime();
    }

    public static int getScreenWidth(Context context) {
        WindowManager wm = (WindowManager) context.getSystemService(Context.WINDOW_SERVICE);
        DisplayMetrics outMetrics = new DisplayMetrics();
        wm.getDefaultDisplay().getMetrics(outMetrics);
        return outMetrics.widthPixels;
    }


    public static void main(String[] args) {
        SimpleDateFormat format = new SimpleDateFormat("yyyy-MM-dd HH");
        try {
            Date date = format.parse("2016-12-15 12");
            
        } catch (ParseException e) {
            e.printStackTrace();
        }
    }

    /**
     *Get the date of the past few days
     *
     * @return
     */
    public static String getPastDate() {
        Calendar calendar = Calendar.getInstance();
        calendar.set(Calendar.DAY_OF_YEAR, calendar.get(Calendar.DAY_OF_YEAR) - 7);
        Date today = calendar.getTime();
        SimpleDateFormat format = new SimpleDateFormat("yyyy-MM-dd");
        String result = format.format(today);
        
        return result;
    }

    public static String getTodayDate() {
        Calendar calendar = Calendar.getInstance();
        Date today = calendar.getTime();
        SimpleDateFormat format = new SimpleDateFormat("yyyy-MM-dd");
        String result = format.format(today);
        
        return result;
    }

    public static Date parseServerTime(String serverTime) {
        String format = "yyyy-MM-dd";
        SimpleDateFormat sdf = new SimpleDateFormat(format, Locale.CHINESE);
        Date date = null;
        try {
            date = sdf.parse(serverTime);
        } catch (Exception e) {
            date = new Date();
        }
        return date;
    }

    /**
     *Obtain bitmap from local path, compress and save small image to local location
     *
     *@param path Path for storing images
     *@return Returns the storage path of the compressed image
     */
    public static void saveBitmap(String path, OnSaveSuccessListener onSaveSuccessListener) {
        String compressdPicPath = "";

//      ★★★★★★★★★★★★★★重点★★★★★★★★★★★★★
      /*//★ If you directly obtain a bitmap from the path without compression, this bitmap will be very large. When compressing the file to 100kb, it will loop many times,
        // ★而且会因为迟迟达不到100k，options一直在递减为负数，直接报错
        //★ 即使原图不是太大，options不会递减为负数，也会循环多次，UI会卡顿，所以不推荐不经过压缩，直接获取到bitmap
        Bitmap bitmap=BitmapFactory.decodeFile(path);*/
//      ★★★★★★★★★★★★★★重点★★★★★★★★★★★★★
        Bitmap bitmap = decodeSampledBitmapFromPath(path, 720, 1280);
        if (bitmap == null) return;
        ByteArrayOutputStream baos = new ByteArrayOutputStream();

        /*Options indicates that if not compressed, it is 100, indicating a compression rate of 0. If it is 70, it means the compression rate is 70, indicating a compression of 30%*/
        int options = 100;
        bitmap.compress(Bitmap.CompressFormat.PNG, 100, baos);

        while (baos.toByteArray().length / 1024 > 200) {
//Cycle to determine if the compressed image is greater than 500kb and continue to compress

            baos.reset();
            options -= 10;
            if (options < 11) {//To prevent the image size from consistently falling below 200kb, the options are constantly decreasing. When the options are less than 0, the following method will report an error
                //That means even if it doesn't reach 200kb, it's compressed to 10
                bitmap.compress(Bitmap.CompressFormat.PNG, options, baos);
                break;
            }
//Compress options% here and store the compressed data in BIOS
            bitmap.compress(Bitmap.CompressFormat.PNG, options, baos);
        }

        String mDir = Environment.getExternalStorageDirectory() + "/FNComman";
        File dir = new File(mDir);
        if (!dir.exists()) {
            dir.mkdirs();//If the file does not exist, create the file
        }
        String fileName = String.valueOf(System.currentTimeMillis());
        File file = new File(mDir, fileName + ".jpg");
        FileOutputStream fOut = null;

        try {
            FileOutputStream out = new FileOutputStream(file);
            out.write(baos.toByteArray());
            out.flush();
            out.close();
            onSaveSuccessListener.onSuccess(file.getAbsolutePath());

        } catch (IOException e) {
            e.printStackTrace();
        }

    }

    /**
     *Compress the image based on its width and height to avoid OOM
     *
     * @param path
     *@param width The width of the imageview to display
     *@param height The height of the imageview to display
     * @return
     */
    private static Bitmap decodeSampledBitmapFromPath(String path, int width, int height) {

//Obtain the width and height of the image without loading it into memory
        BitmapFactory.Options options = new BitmapFactory.Options();
        options.inJustDecodeBounds = true;
        BitmapFactory.decodeFile(path, options);

        options.inSampleSize = caculateInSampleSize(options, width, height);
//Parse the image again using the inSampleSize obtained (at this point, the compression ratio options. inSampleSize is already included in the options. Parsing again will result in a compressed image, which will no longer look good)
        options.inJustDecodeBounds = false;
        Bitmap bitmap = BitmapFactory.decodeFile(path, options);
        return bitmap;

    }

    /**
     *Calculate SampleSize based on the required width and height, as well as the actual width and height of the image
     *
     * @param options
     *@param reqWidth The width of the imageview to be displayed
     *@param reqHeight The height of the imageview to be displayed
     * @return
     *The @ compressExpand value is for requirements such as previewing images. It needs to be slightly larger in height and width than the imageview to be displayed, and can only be zoomed in for clarity
     */
    private static int caculateInSampleSize(BitmapFactory.Options options, int reqWidth, int reqHeight) {
        int width = options.outWidth;
        int height = options.outHeight;

        int inSampleSize = 1;

        if (width >= reqWidth || height >= reqHeight) {

            int widthRadio = Math.round(width * 1.0f / reqWidth);
            int heightRadio = Math.round(width * 1.0f / reqHeight);

            inSampleSize = Math.max(widthRadio, heightRadio);

        }

        return inSampleSize;
    }

    public static String[] getLeftTimeFormatedStrings(long leftTime) {
        String days = "00";
        String hours = "00";
        String minutes = "00";
        String seconds = "00";
        String millisSeconds = "000";

        if (leftTime > 0) {
            //Millisecond
            long millisValue = leftTime % 1000;
            if (millisValue > 100) {
                millisSeconds = String.valueOf(
                        millisValue);
            } else if (millisValue >= 10 && millisValue < 100) {
                millisSeconds = "0" + millisValue;
            } else {
                millisSeconds = "00" + millisValue;
            }

            //How many seconds actually
            long trueSeconds = leftTime / 1000;
            //Current seconds
            long secondValue = trueSeconds % 60;
            if (secondValue < 10) {
                seconds = "0" + secondValue;
            } else {
                seconds = String.valueOf(secondValue);
            }

            //Current score
            long trueMinutes = trueSeconds / 60;
            long minuteValue = trueMinutes % 60;
            if (minuteValue < 10) {
                minutes = "0" + minuteValue;
            } else {
                minutes = String.valueOf(minuteValue);
            }


            //Current hours
            long trueHours = trueMinutes / 60;
            long hourValue = trueHours % 24;
            if (hourValue < 10) {
                hours = "0" + hourValue;
            } else {
                hours = String.valueOf(hourValue);
            }

            //Current Days
            long dayValue = trueHours / 24;
            if (dayValue < 10) {
                days = "0" + dayValue;
            } else {
                days = String.valueOf(dayValue);
            }
        }
        return new String[]{days, hours, minutes, seconds, millisSeconds};
    }


    public static String getJSONLastNews() throws Exception {
//String path=“ https://lishipeng.oss-cn-hangzhou.aliyuncs.com/testdomain.json ;//Test
        HttpsUtils.SSLParams sslParams = HttpsUtils.getSslSocketFactory(null, null, null);
        String path = AppConfig.ossPath2 + "updateV3.json";
        HttpsURLConnection conn = (HttpsURLConnection) new URL(path).openConnection();
        if (BuildConfig.DEBUG) {
            conn.setSSLSocketFactory(sslParams.sSLSocketFactory);
        }
        conn.setConnectTimeout(5000);
        conn.setRequestMethod("GET");
        if (conn.getResponseCode() == 200) {
            try {
                InputStream json = conn.getInputStream();
                String str = getStringFromInputStream(json);
                return str;
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        return null;
    }

    private static String getStringFromInputStream(InputStream is) throws IOException {
        ByteArrayOutputStream os = new ByteArrayOutputStream();
        //Template code must be proficient
        byte[] buffer = new byte[1024];
        int len = -1;
        while ((len = is.read(buffer)) != -1) {
            os.write(buffer, 0, len);
        }
        is.close();
        String state = os.toString();//Convert the data in the stream into a string using UTF-8 encoding (the default encoding for the simulator)
        os.close();
        return state;
    }


    public static String getJSONLastNews(String path) throws Exception {
        HttpURLConnection conn = (HttpURLConnection) new URL(path).openConnection();
        conn.setConnectTimeout(5000);
        conn.setRequestMethod("GET");
        if (conn.getResponseCode() == 200) {
            InputStream json = conn.getInputStream();
            String str = getStringFromInputStream(json);
            return str;
        }
        return null;
    }

    public static String getAPIInsideString(String str) {
        if (str.indexOf(".") < 0) {
            return "";
        }
        if (str.lastIndexOf("/") < 0) {
            return "";
        }
        if (str.contains("/hongbaoapi")) {
            return str.substring(str.indexOf(".") + ".".length(), str.indexOf("/hongbaoapi"));
        } else if (str.contains("/kline-api")) {
            return str.substring(str.indexOf(".") + ".".length(), str.indexOf("/kline-api"));
        } else if (str.contains("/otc-chat")) {
            return str.substring(str.indexOf(".") + ".".length(), str.indexOf("/otc-chat"));
        } else if (str.contains("/wsswap/realTime")) {
            return str.substring(str.indexOf(".") + ".".length(), str.indexOf("/wsswap/realTime"));
        } else if (str.contains("/contract-kline-api/ws")) {
            return str.substring(str.indexOf(".") + ".".length(), str.indexOf("/contract-kline-api/ws"));
        } else {
            return str.substring(str.indexOf(".") + ".".length(), str.lastIndexOf("/"));
        }
    }

    public static String getAPIHostInsideString(String str) {
        if (str.indexOf("//") < 0) {
            return "";
        }
        if (str.lastIndexOf("/") < 0) {
            return "";
        }
        if (str.contains("/hongbaoapi")) {
            return str.substring(str.indexOf("//") + "//".length(), str.indexOf("/hongbaoapi"));
        } else if (str.contains("/kline-api")) {
            return str.substring(str.indexOf("//") + "//".length(), str.indexOf("/kline-api"));
        } else if (str.contains("/otc-chat")) {
            return str.substring(str.indexOf("//") + "//".length(), str.indexOf("/otc-chat"));
        } else if (str.contains("/wsswap/realTime")) {
            return str.substring(str.indexOf("//") + "//".length(), str.indexOf("/wsswap/realTime"));
        } else if (str.contains("/contract-kline-api/ws")) {
            return str.substring(str.indexOf("//") + "//".length(), str.indexOf("/contract-kline-api/ws"));
        } else {
            return str.substring(str.indexOf("//") + "//".length(), str.lastIndexOf("/"));
        }
    }


    public static InputStream read_user(String filename) throws Exception {
        FileInputStream inStream = ChainUpApp.appContext.openFileInput(filename);
        byte[] buffer = new byte[1024];
        int len = 0;
        ByteArrayOutputStream outStream = new ByteArrayOutputStream();
        while ((len = inStream.read(buffer)) != -1) {
            outStream.write(buffer, 0, len);
        }
        byte[] data = outStream.toByteArray();//Obtain binary data from the file
        Log.i("jinlong", new String(data));
        InputStream is = new ByteArrayInputStream(data);
        outStream.close();
        inStream.close();
        return is;
    }

    public static String returnSpeedUrl(String url, String mainUrl) {
        String domain = getAPIInsideString(mainUrl);
        return returnReplaceUrl(mainUrl, domain, url);
    }

    public static String returnSpeedUrlV2(String url, String mainUrl) {
        String domain = getAPIInsideStringIP(mainUrl, url);
        return domain;
    }

    public static int isLetterDigit(String temp) {
        int isDigit = 0;
        for (int i = 0; i < temp.length(); i++) {
            if (Character.isDigit(temp.charAt(i))) {   //Using the method of judging numbers in char packaging classes to determine each character
                isDigit += 1;
            }
        }
        return isDigit;
    }


    public static String returnAPIUrl(String url, boolean isApi) {
        if (isLetterDigit(url) < 4) {
            return url;
        }
        String domain = getAPIInsideString(url);
        String apiHost = getAPIHostInsideString(url);
        ArrayList<JSONObject> specialList = PublicInfoDataService.getInstance().getSpecialList();
        String text = PublicInfoDataService.getInstance().getTextDoMain();
        String domainUrl = netUrl(isApi);

        Log.e("jinlong", "text：" + apiHost + " domain " + domain + " domainUrl " + domainUrl);
        if (null == specialList || specialList.size() == 0) {
            if (TextUtils.isEmpty(domainUrl)) {
                if(isApi){
                    PublicInfoDataService.getInstance().saveNewWorkURL(domain);
                }else{
                    PublicInfoDataService.getInstance().saveNewWorkWSURL(domain);
                }
                return url;
            } else {
                return returnSpeedUrlV2(domainUrl,url);
            }
        } else {
            for (JSONObject json : specialList) {
                if (null != json && json.length() > 0) {
                    if (json.optString("host").equals(apiHost)) {
                        return returnReplaceUrl(url, domain, json.optString("force_domain"));
                    }
                }
            }
            if (TextUtils.isEmpty(domainUrl)) {
                if(isApi){
                    PublicInfoDataService.getInstance().saveNewWorkURL(domain);
                }else{
                    PublicInfoDataService.getInstance().saveNewWorkWSURL(domain);
                }
                return url;
            } else {
                return returnSpeedUrlV2(domainUrl,url);
            }

        }
    }


    public static String returnReplaceUrl(String normalUrl, String domain, String replaceUrl) {
        String url = normalUrl;

        url = normalUrl.replace(domain, replaceUrl);
        return url;
    }


    public static String getSpecialList(String url, String domain, String replaceUrl) {

        if (url.contains("/hongbaoapi")) {
            return url.replace(domain, "service." + replaceUrl);
        } else if (url.contains("/kline-api")) {
            return url.replace(domain, "ws." + replaceUrl);

        } else if (url.contains("/otc-chat")) {
            return url.replace(domain, "ws2." + replaceUrl);

        } else if (url.contains("/wsswap/realTime")) {
            return url.replace(domain, "ws3." + replaceUrl);

        } else if (url.contains("/contract-kline-api/ws")) {
            return url.replace(domain, "ws3." + replaceUrl);

        } else if (url.contains("otcappapi")) {
            return url.replace(domain, "otcappapi." + replaceUrl);

        } else if (url.contains("coappapi")) {
            return url.replace(domain, "coappapi." + replaceUrl);

        } else {
            return url.replace(domain, "appapi." + replaceUrl);
        }
    }

    public static <T> List<T> deepCopy(List<T> src)
            throws IOException, ClassNotFoundException {
        ByteArrayOutputStream byteOut = new ByteArrayOutputStream();
        ObjectOutputStream out = new ObjectOutputStream(byteOut);
        out.writeObject(src);
        ByteArrayInputStream byteIn = new ByteArrayInputStream(byteOut.toByteArray());
        ObjectInputStream in = new ObjectInputStream(byteIn);
        return (List<T>) in.readObject();
    }

    public static <T> ArrayList<T> jsonToArrayList(String json, Class<T> clazz) {
        Type type = new TypeToken<ArrayList<JsonObject>>() {
        }.getType();
        ArrayList<JsonObject> jsonObjects = new Gson().fromJson(json, type);

        ArrayList<T> arrayList = new ArrayList<>();
        for (JsonObject jsonObject : jsonObjects) {
            arrayList.add(new Gson().fromJson(jsonObject, clazz));
        }
        return arrayList;
    }

    public static boolean checkDeviceHasNavigationBar2(Activity activity) {
        //Determine whether there is a navigation bar by judging whether the device has a return key, a Menu key (not a virtual key, but a key outside the phone screen)
        boolean hasMenuKey = ViewConfiguration.get(activity)
                .hasPermanentMenuKey();
        boolean hasBackKey = KeyCharacterMap
                .deviceHasKey(KeyEvent.KEYCODE_BACK);

        if (!hasMenuKey && !hasBackKey) {
            //No virtual keys return true
            return true;
        }
        //Virtual button returns false
        return false;
    }

    public static String getJSONLink(String companyID) throws Exception {
        HttpsUtils.SSLParams sslParams = HttpsUtils.getSslSocketFactory(null, null, null);
        String path = AppConfig.ossPath + "domain/";
        if (companyID != null && !companyID.equals("")) {
            path = path + "update" + "_" + companyID + ".json";
        } else {
            path = AppConfig.ossPath2 + "updateV3.json";
        }
        HttpsURLConnection conn = (HttpsURLConnection) new URL(path).openConnection();
        if (BuildConfig.DEBUG) {
            conn.setSSLSocketFactory(sslParams.sSLSocketFactory);
        }
        conn.setConnectTimeout(5000);
        conn.setRequestMethod("GET");
        if (conn.getResponseCode() == 200) {
            try {
                InputStream json = conn.getInputStream();
                String str = getStringFromInputStream(json);
                return str;
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        return null;
    }

    public static String getAPIInsideStringIP(String str, String newUrl) {
        if (str.indexOf(".") < 0) {
            return "";
        }
        if (str.lastIndexOf("/") < 0) {
            return "";
        }
        URI url = URI.create(str);
        String urlHost = url.getHost();
        boolean isIp = StringUtil.isDoMainIPUrl(urlHost);
        boolean isNewIp = StringUtil.isDoMainIPUrl(newUrl);
        if (isIp && !isNewIp) {
            //Replace IP link with domain name
            String prefix = str.substring(0, str.indexOf(":"));
            String path = "//";
            String companyId = str.substring(prefix.length() + path.length() + 1, str.length()).split("/")[1];
            StringBuilder stringBuffer = new StringBuilder(prefix);
            stringBuffer.append("://");
            stringBuffer.append(companyId).append(".");
            stringBuffer.append(newUrl).append("/");
            String methodUrl = str.substring(str.indexOf(companyId), str.length());
            String urlPath = methodUrl.substring(methodUrl.indexOf("/") + 1, methodUrl.length());
            if (methodUrl.indexOf("/") + 1 != methodUrl.length()) {
                stringBuffer.append(urlPath);
            }
            return stringBuffer.toString();
        } else if (isNewIp && !isIp) {
            //Replace domain name link with IP
            String prefix = str.substring(0, str.indexOf(":"));
            String path = "//";
            int index = str.indexOf(path) + path.length();
            String companyId = str.substring(index, str.indexOf("."));
            String methodUrl = str.substring(index, str.length());
            String urlPath = methodUrl.substring(methodUrl.indexOf("/") + 1, methodUrl.length());
            StringBuilder stringBuffer = new StringBuilder(prefix);
            stringBuffer.append("://");
            stringBuffer.append(newUrl).append("/");
            stringBuffer.append(companyId).append("/");
            if (methodUrl.indexOf("/") + 1 != methodUrl.length()) {
                stringBuffer.append(urlPath);
            }
            return stringBuffer.toString();
        } else {
            if (urlHost.split("\\.").length == 3) {
                return str.replace(urlHost.substring(urlHost.indexOf(".") + 1), newUrl);
            }
            return str.replace(urlHost, newUrl);
        }
    }

    public static String getAPIHostInsideStringIP(String str) {
        if (str.indexOf("//") < 0) {
            return "";
        }
        if (str.lastIndexOf("/") < 0) {
            return "";
        }
        if (str.contains("/hongbaoapi")) {
            return str.substring(str.indexOf("//") + "//".length(), str.indexOf("/hongbaoapi"));
        } else if (str.contains("/kline-api")) {
            return str.substring(str.indexOf("//") + "//".length(), str.indexOf("/kline-api"));
        } else if (str.contains("/otc-chat")) {
            return str.substring(str.indexOf("//") + "//".length(), str.indexOf("/otc-chat"));
        } else if (str.contains("/wsswap/realTime")) {
            return str.substring(str.indexOf("//") + "//".length(), str.indexOf("/wsswap/realTime"));
        } else if (str.contains("/contract-kline-api/ws")) {
            return str.substring(str.indexOf("//") + "//".length(), str.indexOf("/contract-kline-api/ws"));
        } else {
            return str.substring(str.indexOf("//") + "//".length(), str.lastIndexOf("/"));
        }
    }

    public static String returnReplaceUrlIP(String normalUrl, String domain, String replaceUrl) {
        String url = normalUrl;
        url = normalUrl.replace(domain, replaceUrl);
        return url;
    }

    public static String netUrl(boolean isApi) {
        if (isApi) return PublicInfoDataService.getInstance().getNewWorkURL();
        else return PublicInfoDataService.getInstance().getNewWorkWSURL();
    }

}


