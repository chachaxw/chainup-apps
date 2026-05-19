package com.yjkj.chainup.util;

/**
 * @Description:
 * @Author: wanghao
 * @CreateDate: 2019-09-23 20:37
 * @UpdateUser: wanghao
 * @UpdateDate 2023-09-23 20:37
 *@ UpdateRemark: Update Description
 */
public class NLanguageUtil {

    public static String getLanguage(){
        String language = "en_US";
//        if (SystemUtils.isZh()) {
//            language = "zh_CN";
//        } else if (SystemUtils.isMn()) {
//            language = "mn_MN";
//        } else if (SystemUtils.isRussia()) {
//            language = "ru_RU";
//        } else if (SystemUtils.isKorea()) {
//            language = "ko_KR";
//        } else if (SystemUtils.isJapanese()) {
//            language = "ja_JP";
//        } else if (SystemUtils.isTW()) {
//            language = "el_GR";
//        } else if (SystemUtils.isVietNam()) {
//            language = "vi_VN";
//        }else if (SystemUtils.isSpanish()){
//            language = "es_ES";
//        }else if (SystemUtils.isID()){
//            language = "id_ID";
//        }else if (SystemUtils.isTR()){
//            language = "tr_TR";
//        }else if(SystemUtils.isTH()){
//            language = "th_TH";
//        }
        String systemLanguage = SystemUtils.getSystemLanguage();
        if(!"".equals(systemLanguage)) {
            language = systemLanguage;
        }
        return language;
    }
}
