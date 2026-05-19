package com.yjkj.chainup.manager

import android.content.Context
import android.content.res.Resources
import android.text.TextUtils
import android.util.Log
import com.chainup.contract.utils.CpClLogicContractSetting
import com.chainup.kit.utils.SystemUtils
import com.tencent.mmkv.MMKV
import com.yjkj.chainup.R
import com.yjkj.chainup.app.ChainUpApp
import com.yjkj.chainup.bean.NetworkLanguage
import com.yjkj.chainup.db.service.PublicInfoDataService
import com.yjkj.chainup.net_new.JSONUtil
import com.yjkj.chainup.util.JsonUtils
import com.yjkj.chainup.util.JsonWSUtils
import com.yjkj.chainup.util.LocalManageUtil
import com.yjkj.chainup.util.LogUtil
import com.yjkj.chainup.util.NetworkUtils
import com.yjkj.chainup.util.Utils
import org.json.JSONArray
import org.json.JSONObject
import java.util.*

/**
 * @Author: Bertking
 * @Date 2023-07-18-18:59
 * @Description:
 */
object LanguageUtil {

    private val TAG = LanguageUtil::class.java.simpleName

    private val SELECTED_LANGUAGE = "language_select"

    const val TYPE_ADD = 0

    const  val LANGUAGE_th_TH :String = "th_TH"
    const val LANGUAGE_fr_FR = "fr_FR"
    const val LANGUAGE_hi_IN = "hi_IN"
    const val LANGUAGE_kn_IN = "kn_IN"
    const val LANGUAGE_nl_NL = "nl_NL"
    const val LANGUAGE_it_IT = "it_IT"
    const val LANGUAGE_pl_PL = "pl_PL"
    const val LANGUAGE_pt_BR = "pt_BR"
    const val LANGUAGE_uk_UA = "uk_UA"
    const val LANGUAGE_ar_AE = "ar_AE"

    private val mmkv = MMKV.mmkvWithID("local_language")

    var systemCurrentLocal = Locale.getDefault()


    fun saveLanguage(currentLan: String) {
        mmkv.encode(SELECTED_LANGUAGE, currentLan)
    }


    @JvmStatic
    fun getSelectLanguage(): String {
        val select = mmkv.decodeString(SELECTED_LANGUAGE, "") ?: ""

        if (!TextUtils.isEmpty(select)) return select
        val defLan = PublicInfoDataService.getInstance().defLan
        if (!TextUtils.isEmpty(defLan)) return defLan
        val systemLan = SystemUtils.getSystemLocaleLanguage()

        return systemLan

//        var lan: String? = ""
//        val languageBean = PublicInfoDataService.getInstance().getLan(null)
//        if (languageBean != null) {
//            lan = languageBean.optString("defLan")
//        }
//
//        if (TextUtils.isEmpty(lan)) {
//            return mmkv.decodeString(SELECTED_LANGUAGE, "en_US")
//        }
//
//        return lan!!
    }

    /**
     *Less than 5% loss: I can still afford this loss

    亏损5%-10%：小赌怡情，大赌伤身。

    亏损11%-20%：我还会回来再战的！

    亏损21%-50%：币圈一天，人间一年。

    亏损50%以上：生死看淡，不服就干！

    盈利5%以下：不输就是赢。

    盈利5%-10%：小赚一笔。

    盈利11%-20%：这个水平马马虎虎。

    盈利21-50%：耶稣也阻止不了我，我说的！

    盈利50%以上：老夫从来都是一把唆！
     */
    fun getContractShareText(context: Context, rate: String): String {
        LogUtil.d(TAG, "rate:$rate")
        val negative = rate.contains("-")
        var rates = 0.0
        if (negative) {
            rates = rate.replace("-", "").toDouble()
        } else {
            rates = rate.toDouble()
        }



        return when (rates) {
            in 0.0..5.0 -> {
                if (negative) {
                    context.getString(R.string.common_share_losePrompt5)
                } else {
                    context.getString(R.string.common_share_winPrompt5)
                }
            }

            in 5.0000000000001..10.0 -> {
                if (negative) {
                    context.getString(R.string.common_share_losePrompt10)
                } else {
                    context.getString(R.string.common_share_winPrompt10)
                }
            }

            in 10.0000000000001..20.0 -> {
                if (negative) {
                    context.getString(R.string.common_share_losePrompt20)
                } else {
                    context.getString(R.string.common_share_winPrompt20)

                }
            }

            in 20.0000000000001..50.0 -> {
                if (negative) {
                    context.getString(R.string.common_share_losePrompt50)
                } else {
                    context.getString(R.string.common_share_winPrompt50)
                }
            }

            else -> {
                if (negative) {
                    context.getString(R.string.common_share_losePrompt100)
                } else {
                    context.getString(R.string.common_share_winPrompt100)
                }
            }
        }

    }

    /**
     *Obtain multilingual copy
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
            if (context == null) {
                val id = ChainUpApp.appContext.resources?.getIdentifier(key, "string", ChainUpApp.appContext.packageName) ?: 0
                ChainUpApp.appContext.getString(id)
            } else {
                val id = context.resources?.getIdentifier(key, "string", ChainUpApp.appContext.packageName) ?: 0
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

    /**
     *TODO specific implementation
     */
    private fun getNetString(context: Context?, key: String): String {
        var saveString = NetworkLanguage().getLanguageJson()
        if (saveString == null || saveString.length() == 0) return ""
        var netText = saveString.optString(key, "")
        return netText.languageTextFormat()
    }

    fun String.languageTextFormat(): String {
        if (this.contains("%@")) {
            return this.replace("%@", "%s")
        }
        return this
    }

    fun downLoadLan(url: String, key: String,isContract: Boolean = false) {
        Log.w(TAG,"downLoadLan ${key}")
        Thread(Runnable {
            try {
                val jsonFile = Utils.getJSONLastNews(url)
                if(jsonFile.isNullOrEmpty()){
                    if(isContract){
                        CpLanguageUtil.saveOnlineText(ChainUpApp.appContext,"")
                    } else {
                        PublicInfoDataService.getInstance().saveOnlineText("")
                    }
                } else {
                    if(isContract){
                        CpLanguageUtil.saveOnlineText(ChainUpApp.appContext,jsonFile)
                    } else {
                        PublicInfoDataService.getInstance().saveOnlineText(jsonFile)
                    }
                }
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }).start()
    }

    private fun getNetString(key: String,isReLoad: Boolean = false): Boolean {
        val locales = PublicInfoDataService.getInstance().getLocalesList(null)
        Log.w(TAG,"downLoadLan ${locales}")
        if(locales==null || locales?.length() == 0){
            return false
        }
        val lanLists  = JSONUtil.arrayToList(locales)
        val item = lanLists.find { it.optString("langKey") == key }
        val url = item?.optString("nowFileAddress","") ?: ""
        Log.w(TAG,"downLoadLan ${url}")
        if (TextUtils.isEmpty(url)) {
            return false
        }
        val jsonObject: JSONObject? = PublicInfoDataService.getInstance().onlineText
        if (jsonObject == null) {
            downLoadLan(url, key,false)
        } else {
            val lan = jsonObject.optString(key, "") ?: ""
            if (TextUtils.isEmpty(lan) || isReLoad) {
                downLoadLan(url, key,false)
            }
        }
        return true
    }

    private fun contractNet(key: String){
        val mContractLanguageJsonListStr = CpClLogicContractSetting.getContractLanguageJsonListStr(ChainUpApp.appContext)
        if (!TextUtils.isEmpty(mContractLanguageJsonListStr.toString())) {
            val jsonArray = JSONArray(mContractLanguageJsonListStr)
            if(jsonArray.length() == 0){
                return
            }
            val lanLists  = JSONUtil.arrayToList(jsonArray)
            val item = lanLists.find { it.optString("langKey") == key }
            val url = item?.optString("nowFileAddress","") ?: ""
            Log.w(TAG,"downLoadLan ${url}")
            if (TextUtils.isEmpty(url)) {
                return
            }
            downLoadLan(url, key,true)
        }

    }

    fun checkChangeDefaultLanguage(isSpot:Boolean = true){

        val select = mmkv.decodeString(SELECTED_LANGUAGE, "") ?: ""
        val language = systemCurrentLocal.language
        Log.w(TAG,"checkChangeDefaultLanguage  select ${select} 系统 ${language}")
        if(select.isEmpty()){
            var lan: String? = ""
            val languageBean = PublicInfoDataService.getInstance().getLan(null)
            if (languageBean != null) {
                lan = languageBean.optString("defLan")
            }
            LogUtil.w(TAG,"getSelectLanguage  config default ${lan}")
            val lanList = PublicInfoDataService.getInstance().lanList
            if (!lan.isNullOrEmpty() && lanList.isNotEmpty()) {
                lanList.forEach {
                    LogUtil.w(TAG,"getSelectLanguage  config  ${it}")
                }
                val lanConfig = lanList.find { it.optString("id") == lan }
                if(lanConfig != null && !lanConfig.isNull("id")){
                    // 说明存在 然后去下载
                    if(isSpot){
                        getNetString(lan,isSpot)
                    } else {
                        contractNet(lan)
                    }

                }
            }
        } else {
            if(isSpot){
                getNetString(select,isSpot)
            } else {
                contractNet(select)
            }
        }

    }
}
