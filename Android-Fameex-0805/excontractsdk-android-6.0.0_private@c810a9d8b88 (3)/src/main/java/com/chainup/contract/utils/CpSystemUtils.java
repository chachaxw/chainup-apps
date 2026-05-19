package com.chainup.contract.utils;


import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.net.Uri;
import android.os.Build;
import android.provider.Settings;
import android.telephony.TelephonyManager;
import android.text.TextUtils;
import android.util.Base64;
import android.util.Log;
import android.view.View;

import androidx.core.app.NotificationManagerCompat;


import com.chainup.contract.api.CpApiConstants;
import com.chainup.contract.app.CpMyApp;
import com.yjkj.chainup.manager.CpLanguageUtil;

import java.util.HashMap;
import java.util.Iterator;
import java.util.Locale;
import java.util.Map;
import java.util.Set;
import java.util.SortedMap;
import java.util.TimeZone;

public class CpSystemUtils {

    /**
     *Obtain the current phone system language.
     *
     *@return Returns the current system language. For example, if "Chinese China" is currently set, "zh CN" is returned
     */
    public static String getSystemLanguage() {
        return CpLanguageUtil.getSelectLanguage();
    }


    public static boolean isZh() {
        String language = Locale.getDefault().getLanguage();
        if (getSystemLanguage().isEmpty()){
            if (language.contains("zh")){
                return true;
            }
        }
        if (getSystemLanguage().equals("zh")) {
            return true;
        } else {
            return getSystemLanguage().equals("zh_CN");
        }
    }

    public static boolean isMn() {
        return getSystemLanguage().equals("mn_MN");
    }

    public static boolean isRussia() {
        return getSystemLanguage().equals("ru_RU");
    }

    public static boolean isKorea() {
        return getSystemLanguage().equals("ko_KR");
    }

    public static boolean isJapanese() {
        return getSystemLanguage().equals("ja_JP");
    }

    public static boolean isSpanish() {
        return getSystemLanguage().equals("es_ES");
    }

    public static boolean isVietNam() {
        return getSystemLanguage().equals("vi_VN");
    }

    public static boolean isTW() {
        return getSystemLanguage().equals("el_GR");
    }

    public static boolean isTC(){
        return getSystemLanguage().equals("zh_TC");
    }



    public static boolean isTR() {
        return getSystemLanguage().equals("tr_TR");
    }
    /**
     *Obtain the language list (Locale list) on the current system
     *
     *@return Language List
     */
    public static Locale[] getSystemLanguageList() {
        return Locale.getAvailableLocales();
    }

    /**
     *Obtain the current mobile phone system version number
     *
     *@return System version number
     */
    public static String getSystemVersion() {
        return Build.VERSION.RELEASE;
    }

    /**
     *Get phone model
     *
     *@return Mobile phone model
     */
    public static String getSystemModel() {
        return Build.MODEL;
    }

    /**
     *Obtain phone manufacturer
     *
     *@return Mobile phone manufacturer
     */
    public static String getDeviceBrand() {
        return Build.BRAND;
    }

    /**
     *Get current network status
     *
     * @param context
     * @return
     */
    public static String getAPNType(Context context) {
        String netType = "4g";
        ConnectivityManager connMgr = (ConnectivityManager) context
                .getSystemService(Context.CONNECTIVITY_SERVICE);
        NetworkInfo networkInfo = connMgr.getActiveNetworkInfo();
        if (networkInfo == null) {
            return netType;
        }
        int nType = networkInfo.getType();
        if (nType == ConnectivityManager.TYPE_WIFI) {
            netType = "WIFI";// wifi
        } else if (nType == ConnectivityManager.TYPE_MOBILE) {
            int nSubType = networkInfo.getSubtype();
            TelephonyManager mTelephony = (TelephonyManager) context
                    .getSystemService(Context.TELEPHONY_SERVICE);
            if (nSubType == TelephonyManager.NETWORK_TYPE_LTE) {
                netType = "4G";// 4G
            } else if (nSubType == TelephonyManager.NETWORK_TYPE_UMTS
                    && !mTelephony.isNetworkRoaming()) {
                netType = "3G";// 3G
            } else {
                netType = "2G";// 2G
            }

        }
        return netType;
    }


    public static String requestSign(SortedMap<String, String> parameters, String key) {
        StringBuffer sb = new StringBuffer();
        StringBuffer sbkey = new StringBuffer();
        String characterEncoding = "UTF-8";
        //All parameters involved in parameter transfer are sorted according to accsii (ascending order)
        Set<Map.Entry<String, String>> es = parameters.entrySet();
        Iterator<Map.Entry<String, String>> it = es.iterator();
        while (it.hasNext()) {
            Map.Entry<String, String> entry = it.next();
            String k = entry.getKey();
            String v = entry.getValue();
            //Null values are not passed and do not participate in the signature string
            if (!TextUtils.isEmpty(v)) {
                sb.append(k + "=" + v + "&");
                sbkey.append(k + "=" + v + "&");
            }
        }
        Log.e("字符串 {}", sb.toString());
        sbkey = sbkey.append("key=" + key);
        Log.e("字符串 {}", sbkey.toString());
        //MD5 encryption, result converted to uppercase characters
        String sign = CpMD5Util.getMD5(sbkey.toString()).toUpperCase();
        Log.e(" MD5加密值 {}:", sign);
        return sign;
    }

    /**
     *Jump to the dialing interface while passing the phone number
     *
     * @param context
     * @param phone
     */
    public static void systemCallPhone(Context context, String phone) {
        Intent dialIntent = new Intent(Intent.ACTION_DIAL, Uri.parse("tel:" + phone));
        context.startActivity(dialIntent);
    }

    public static String getUUID() {
        String UUID = Settings.System.getString(CpMyApp.Companion.instance().getContentResolver(), Settings.System.ANDROID_ID);
        if (null == UUID) {
            UUID = "";
        }
        return UUID;
    }

    public static boolean isOpenNotifications() {
        NotificationManagerCompat manager = NotificationManagerCompat.from(CpMyApp.Companion.instance());
        boolean isOpened = manager.areNotificationsEnabled();
        return isOpened;
    }

    public static void startNotifactions() {
        Intent intent = new Intent();
        intent.setAction(Settings.ACTION_APPLICATION_DETAILS_SETTINGS);
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        Uri uri = Uri.fromParts("package", CpMyApp.Companion.instance().getPackageName(), null);
        intent.setData(uri);
        CpMyApp.Companion.instance().startActivity(intent);
    }


    private static HashMap<String, String> HEADER_PARAMS = new HashMap<String, String>();

    static {
        String UUID = CpSystemUtils.getUUID();
        HEADER_PARAMS.put("Content-Type", "application/json;charset=utf-8");
        HEADER_PARAMS.put("Build-CU", CpPackageUtil.getVersionCode() + "");
        HEADER_PARAMS.put("exChainupBundleVersion", CpApiConstants.EX_CHAINUP_BUNDLE_VERSION);
        HEADER_PARAMS.put("SysVersion-CU", CpSystemUtils.getSystemVersion());
        HEADER_PARAMS.put("SysSDK-CU", Build.VERSION.SDK_INT + "");
        HEADER_PARAMS.put("Channel-CU", "google play");
        HEADER_PARAMS.put("Mobile-Model-CU", CpSystemUtils.getSystemModel());
        HEADER_PARAMS.put("UUID-CU", UUID);
        HEADER_PARAMS.put("Platform-CU", "android");
        HEADER_PARAMS.put("Network-CU", CpNetworkUtils.getNetType());
        HEADER_PARAMS.put("exchange-client", "app");
        HEADER_PARAMS.put("appChannel", "google play");
        HEADER_PARAMS.put("appNetwork", CpSystemUtils.getAPNType(CpMyApp.Companion.instance()));
        HEADER_PARAMS.put("timezone", TimeZone.getDefault().getID());
        HEADER_PARAMS.put("osName", "android");
        HEADER_PARAMS.put("os", "android");
        HEADER_PARAMS.put("osVersion", CpSystemUtils.getSystemVersion());
        HEADER_PARAMS.put("platform", "android");
        HEADER_PARAMS.put("device", UUID);
        HEADER_PARAMS.put("clientType", "android");
        HEADER_PARAMS.put("language", "android");
    }

    public static HashMap<String, String> getHeaderParams() {
        if (!TextUtils.isEmpty(CpClLogicContractSetting.getToken())) {
            HEADER_PARAMS.put("exchange-token", CpClLogicContractSetting.getToken());
        } else {
            HEADER_PARAMS.remove("exchange-token");
        }
        HEADER_PARAMS.put("exchange-language",  CpLanguageUtil.getLanguage());
        HEADER_PARAMS.put("appAcceptLanguage", CpLanguageUtil.getLanguage());
        return HEADER_PARAMS;
    }

    public static Bitmap base64ToPicture(String imgBase64) {
        if (!TextUtils.isEmpty(imgBase64) && imgBase64.contains(",")) {
            //Get the real base64 data
            try {
                String base64Img = imgBase64.split(",")[1];
                byte[] decode = Base64.decode(base64Img, Base64.DEFAULT);
                Bitmap bitmap = BitmapFactory.decodeByteArray(decode, 0, decode.length);
                return bitmap;
            } catch (Exception e) {
                e.printStackTrace();
            }
            return null;
        }
        return null;
    }

    public static String getLogParams() {
        HashMap<String, String> map = getHeaderParams();
        try {
            if(map.containsKey("exchange-token")){
                map.remove("exchange-token");
            }
            return CpJsonUtils.INSTANCE.getGson().toJson(map);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return "chainUP header Not Found";
    }

    /**
     *The calculated position is displayed aligned above and below the anchor view in the y direction, and aligned with the right side of the screen in the x direction
     *If the position of the anchor view changes, you can appropriately add additional offsets to correct it
     *@param anchorView calls out the window's view
     *Content layout of the @param contentView window
     *The xOff, yOff coordinates of the upper left corner displayed in the @return window
     */
    public static int[] calculatePopWindowPos(final View anchorView, final View contentView) {
        final int windowPos[] = new int[2];
        final int anchorLoc[] = new int[2];
        anchorView.getLocationOnScreen(anchorLoc);
        final int anchorHeight = anchorView.getHeight();
        //Obtain the height and width of the screen
        final int screenHeight = CpDisplayUtils.getScreenHeight(anchorView.getContext());
        final int screenWidth = CpDisplayUtils.getScreenWidth(anchorView.getContext());
        contentView.measure(View.MeasureSpec.UNSPECIFIED, View.MeasureSpec.UNSPECIFIED);
        //Calculate the height and width of the contentView
        final int windowHeight = contentView.getMeasuredHeight();
        final int windowWidth = contentView.getMeasuredWidth();
        //Determine whether to pop up or down the display
        final boolean isNeedShowUp = true;
        if (isNeedShowUp) {
            windowPos[0] = screenWidth - windowWidth;
            windowPos[1] = anchorLoc[1] - windowHeight;
        } else {
            windowPos[0] = screenWidth - windowWidth;
            windowPos[1] = anchorLoc[1] + anchorHeight;
        }
        return windowPos;
    }

}
