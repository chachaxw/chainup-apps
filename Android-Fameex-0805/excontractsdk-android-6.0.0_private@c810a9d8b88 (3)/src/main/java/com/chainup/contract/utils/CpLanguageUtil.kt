package com.yjkj.chainup.manager

import android.content.Context
import android.content.res.Resources
import android.text.TextUtils
import com.chainup.contract.app.CpMyApp
import com.chainup.contract.utils.CpClLogicContractSetting
import com.chainup.contract.utils.CpPreferenceManager
import com.chainup.contract.utils.CpStringUtil
import com.chainup.contract.utils.CpSystemUtils
import com.chainup.kit.utils.SystemUtils
import org.json.JSONException
import org.json.JSONObject
import java.util.*

/**
 * @Author: Bertking
 * @Date 2023-07-18-18:59
 * @Description:
 */
object CpLanguageUtil {

    private val TAG = CpLanguageUtil::class.java.simpleName

    private val SELECTED_LANGUAGE = "language_select"


    var systemCurrentLocal = Locale.getDefault()


    fun saveLanguage(currentLan: String) {
        CpPreferenceManager.getInstance(CpMyApp.Companion.instance()).putSharedString(CpPreferenceManager.PREF_LANGUAGE, currentLan);
    }


    @JvmStatic
    fun getSelectLanguage(): String {
        val select = CpPreferenceManager.getInstance(CpMyApp.Companion.instance())
                .getSharedString(CpPreferenceManager.PREF_LANGUAGE, "");

        if(!"".equals(select)) return select
        val spotDefLan = CpClLogicContractSetting.getInstance().userDataBridgeImpl?.defLan?:""
        if(!"".equals(spotDefLan)) return spotDefLan
        val systemLan = SystemUtils.getSystemLocaleLanguage()
        return systemLan
    }

    /**
     *Get Multilingual Copywriting
     */
    @JvmStatic
    fun getString(context: Context?, key: String): String {
        var netString = getNetString(context, key)
        return if (netString.isBlank()) {
            getLocalString(context, key)
        } else {
            netString.languageTextFormat()
        }
    }

    private fun getLocalString(context: Context?, key: String): String {
        return try {
            var id = context?.resources?.getIdentifier(key, "string", CpMyApp.instance().packageName)
                    ?: 0
            if (context == null) {
                CpMyApp.instance().getString(id)
            } else {
                context.getString(id)
            }
        } catch (e: Resources.NotFoundException) {
            e.printStackTrace()
            /**
             *If it cannot be found, directly display the key
             */
            key
        }
    }

    private fun getNetString(context: Context?, key: String): String {
        var mJSONObject= getOnlineText(context);
        if (mJSONObject != null) {
           var selectLan= getSelectLanguage()
            mJSONObject= mJSONObject.optJSONObject(selectLan);
            if (mJSONObject==null){
                return  getLocalString(context, key)
            }
            return mJSONObject.optString(key, "").languageTextFormat()
        }
        return  getLocalString(context, key)
    }

    fun String.languageTextFormat(): String {
        if (this.contains("%@")) {
            return this.replace("%@", "%s")
        }
        return this
    }

    @JvmStatic
    fun getLanguage(): String? {
        var language = "en_US"
        val currentLanguage = CpSystemUtils.getSystemLanguage()
        if(!"".equals(currentLanguage)){
            language = currentLanguage
        }else{
            language = SystemUtils.getSystemLocaleLanguage()
        }
//        if (CpSystemUtils.isZh()) {
//            language = "zh_CN"
//        } else if (CpSystemUtils.isMn()) {
//            language = "mn_MN"
//        } else if (CpSystemUtils.isRussia()) {
//            language = "ru_RU"
//        } else if (CpSystemUtils.isKorea()) {
//            language = "ko_KR"
//        } else if (CpSystemUtils.isJapanese()) {
//            language = "ja_JP"
//        } else if (CpSystemUtils.isTW()) {
//            language = "el_GR"
//        } else if (CpSystemUtils.isTC()) {
//            language = "zh_TC"
//        } else if (CpSystemUtils.isVietNam()) {
//            language = "vi_VN"
//        } else if (CpSystemUtils.isSpanish()) {
//            language = "es_ES"
//        } else if (CpSystemUtils.isTR()) {
//            language = "tr_TR"
//        }
        return language
    }


    /**
     *Store network data
     *
     * @param
     * @return
     */
    fun saveOnlineText(context: Context?, data: String?) {
        if (null != data) {
            CpPreferenceManager.getInstance(context).putSharedString(CpPreferenceManager.PREF_CONTRACT_ONLINE_STRING_TEXT, data)
        }
    }

    /**
     *Get network data
     *
     * @param
     * @return
     */
    fun getOnlineText(context: Context?): JSONObject? {
        val onlineText: String = CpPreferenceManager.getInstance(context).getSharedString(CpPreferenceManager.PREF_CONTRACT_ONLINE_STRING_TEXT, "")
        if (CpStringUtil.checkStr(onlineText)) {
            try {
                return JSONObject(onlineText)
            } catch (e: JSONException) {
                e.printStackTrace()
            }
        }
        return null
    }






}
