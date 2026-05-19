package com.chainup.contract.utils;

import android.content.Context;
import android.content.res.Configuration;
import android.content.res.Resources;
import android.os.Build;
import android.os.LocaleList;
import android.util.DisplayMetrics;
import android.util.Log;

import com.chainup.contract.app.CpMyApp;
import com.yjkj.chainup.manager.CpLanguageUtil;

import java.util.Locale;

/**
 * @Author lianshangljl
 * @Date 2018/10/22-7:31 PM
 * @Email buptjinlong@163.com
 * @description
 */
public class CpLocalManageUtil {
    private static final String TAG = "LocalManageUtil";

    /**
     *Obtain the system's locale
     *
     *@return Locale object
     */
    public static Locale getSystemLocale() {
        return CpLanguageUtil.INSTANCE.getSystemCurrentLocal();
    }


    /**
     *Get selected language settings
     *
     * @return
     */
    public static Locale getSetLanguageLocale() {
        String language = CpLanguageUtil.getSelectLanguage();
        switch (language) {
            case "":
                return getSystemLocale();
            case "zh_CN":
                return Locale.CHINA;
            case "zh":
                return Locale.CHINA;
            case "el_GR":
                return Locale.TAIWAN;
            case "zh_TC":
                return Locale.TAIWAN;
            case "en_US":
                return Locale.ENGLISH;
            case "ko_KR":
                return Locale.KOREA;
            case "ru_RU":
                return new Locale("ru");
            case "mn_MN":
                return new Locale("mn");
            case "ja_JP":
                return Locale.JAPAN;
            case "vi_VN":
                return new Locale("vi");
            case "es_ES":
                return new Locale("es");
            case "th_TH":
                return new Locale("th","TH");
            case "id_ID":
                return new Locale("id");
            default:
                return Locale.ENGLISH;
        }
    }

    public static void saveSelectLanguage(Context context, String select) {
        String currentLan = CpLanguageUtil.getSelectLanguage();
        CpLanguageUtil.INSTANCE.saveLanguage(select);
        if(select.equals(currentLan)) return;
        setApplicationLanguage();
        CpFlutterEngineCacheUtil.removeAllEngine();
    }

    public static Context setLocal(Context context) {
        return updateResources(context, getSetLanguageLocale());
    }

    private static Context updateResources(Context context, Locale locale) {
        Locale.setDefault(locale);

        Resources res = context.getResources();
        Configuration config = new Configuration(res.getConfiguration());
        if (Build.VERSION.SDK_INT >= 17) {
            config.setLocale(locale);
            context = context.createConfigurationContext(config);
        } else {
            config.locale = locale;
            res.updateConfiguration(config, res.getDisplayMetrics());
        }
        return context;
    }

    /**
     *Set Language Type
     */
    public static Context setApplicationLanguage() {
        Context context = CpMyApp.Companion.instance();
        Resources resources = context.getResources();
        DisplayMetrics dm = resources.getDisplayMetrics();
        Configuration config = resources.getConfiguration();
        Locale locale = getSetLanguageLocale();
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            LocaleList localeList = new LocaleList(locale);
            LocaleList.setDefault(localeList);
            config.setLocales(localeList);
            Locale.setDefault(locale);
            return context.createConfigurationContext(config);
        } else {
            config.locale = locale;
        }
        resources.updateConfiguration(config, dm);
        return context;
    }

    public static void saveSystemCurrentLanguage() {
        Locale locale;
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            locale = LocaleList.getDefault().get(0);
        } else {
            locale = Locale.getDefault();
        }
        
        CpLanguageUtil.INSTANCE.setSystemCurrentLocal(locale);
    }

    public static void onConfigurationChanged(Context context) {
        saveSystemCurrentLanguage();
        setLocal(context);
        setApplicationLanguage();
    }
}
