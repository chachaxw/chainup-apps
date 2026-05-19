package com.chainup.kit.utils;

import java.util.Locale;

public class SystemUtils {
    
    private static final String LANGUAGE_th_TH = "th_TH";
    private static final String LANGUAGE_fr_FR = "fr_FR";
    private static final String LANGUAGE_hi_IN = "hi_IN";
    private static final String LANGUAGE_kn_IN = "kn_IN";
    private static final String LANGUAGE_nl_NL = "nl_NL";
    private static final String LANGUAGE_it_IT = "it_IT";
    private static final String LANGUAGE_pl_PL = "pl_PL";
    private static final String LANGUAGE_pt_BR = "pt_BR";
    private static final String LANGUAGE_uk_UA = "uk_UA";
    private static final String LANGUAGE_ar_AE = "ar_AE";
    
    
    public static String getSystemLocaleLanguage(){
        final Locale systemCurrentLocal = Locale.getDefault();
        final String language = systemCurrentLocal.getLanguage();
        if (language.contains("zh")) {
            return "zh_CN";
        }

        if (language.contains("en")) {
            return "en_US";
        }
        if (language.contains("ko")) {
            return "ko_KR";
        }

        if (language.contains("ja")) {
            return "ja_JP";
        }
        if (language.contains("id")) {
            return "id_ID";
        }
        if (language.contains("tr")) {
            return "tr_TR";
        }
        if (language.contains("er")) {
            return "el_GR";
        }
        if (language.contains("ru")) {
            return "ru_RU";
        }
        if (language.contains("mn")) {
            return "mn_MN";
        }
        if (language.contains("vi")) {
            return "vi_VN";
        }
        if (language.contains("es")) {
            return "es_ES";
        }

        if (language.contains("th")) {
            return LANGUAGE_th_TH;
        }
        if (language.contains("fr")) {
            return LANGUAGE_fr_FR;
        }
        if (language.contains("hi")) {
            return LANGUAGE_hi_IN;
        }
        if (language.contains("kn")) {
            return LANGUAGE_kn_IN;
        }
        if (language.contains("nl")) {
            return LANGUAGE_nl_NL;
        }
        if (language.contains("it")) {
            return LANGUAGE_it_IT;
        }
        if (language.contains("pl")) {
            return LANGUAGE_pl_PL;
        }
        if (language.contains("pt")) {
            return LANGUAGE_pt_BR;
        }
        if (language.contains("uk")) {
            return LANGUAGE_uk_UA;
        }
        if (language.contains("ar")) {
            return LANGUAGE_ar_AE;
        }

        return "en_US";
    }


}
