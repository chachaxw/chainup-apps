package com.yjkj.chainup.util


import android.app.Activity
import android.content.Context
import android.content.DialogInterface
import android.content.Intent
import android.text.TextUtils
import android.util.Log
import android.view.View
import com.chainup.kit.KKDialogUtils
import com.google.gson.Gson
import com.google.gson.GsonBuilder
import com.google.gson.JsonObject
import com.google.gson.JsonParser
import com.yjkj.chainup.R
import com.yjkj.chainup.bean.QuotesData
import com.yjkj.chainup.db.constant.RoutePath
import com.yjkj.chainup.db.service.PublicInfoDataService
import com.yjkj.chainup.db.service.UserDataService
import com.yjkj.chainup.extra_service.arouter.ArouterUtil
import com.yjkj.chainup.manager.LanguageUtil
import com.yjkj.chainup.new_version.activity.personalCenter.GoogleValidationActivity
import com.yjkj.chainup.new_version.bean.QuotesBeanTypeAdapter
import com.yjkj.chainup.new_version.dialog.NewDialogUtils
import com.yjkj.chainup.util.SystemUtils
import com.zj.test.startActivity
import org.json.JSONArray
import org.json.JSONException
import org.json.JSONObject
import java.io.InputStream
import java.nio.charset.Charset
import java.util.*
import kotlin.collections.ArrayList

object JsonUtils {
    lateinit var gson: Gson

    fun <T> jsonToList(data: String, tClass: Class<T>): List<T> {
        val mList = ArrayList<T>()
        if (TextUtils.isEmpty(data)) return mList
        try {
            val mArray = JSONArray(data)
            (0 until mArray.length()).mapTo(mList) { jsonToBean(mArray.get(it).toString(), tClass) }
        } catch (e: JSONException) {
            e.printStackTrace()
        }

        return mList
    }
    fun <T> listToJson(data:ArrayList<T>):String{
        if(data.size>0){
            //If it is a JSONObject type
            if(data[0] is JSONObject){
                val jsonArrays = ArrayList<JsonObject>()
                for(itemObj in data){
                    //Convert the key of namePair to JsonObject first
                    val jsonParser = JsonParser()
                    val jsonObject = jsonParser.parse(itemObj.toString()) as JsonObject

                    jsonArrays.add(jsonObject)
                }

                return gson.toJson(jsonArrays)

            } else {
                return gson.toJson(data)
            }
        }else{
            return ""
        }
    }

    fun <T> jsonToBean(data: String, tClass: Class<T>): T = Gson().fromJson(data, tClass)


    init {
        val gsonBuilder = GsonBuilder()
        gsonBuilder.registerTypeAdapter(QuotesData::class.java, QuotesBeanTypeAdapter())
        gsonBuilder.setPrettyPrinting()
        gson = gsonBuilder.create()
    }


    fun convert2Quote(json: String): QuotesData {
        return gson.fromJson(json, QuotesData::class.java)
    }


    //For the following fund password pop-up window to modify new requirements ->>Android, set fund password pop-up window, set real name authentication button, click to jump to the set nickname page
    private fun pushOTCTradingPermissionsDialog(view:View){
        when(view.id){
            R.id.tv_nickname_set,R.id.tv_nickname -> {
                if (UserDataService.getInstance().nickName.isEmpty()) {
                    ArouterUtil.navigation(RoutePath.PersonalInfoActivity, null)
                }
            }
            R.id.tv_realname_certification -> {
                //Certification status 0. Under review, 1. Passed, 2. Not passed, 3. Not certified
                if (UserDataService.getInstance().authLevel != 1) {
                    ArouterUtil.navigation(RoutePath.KycActivity, null)
                }
            }
            R.id.tv_google -> {
                ArouterUtil.greenChannel(RoutePath.GoogleValidationActivity, null)
            }
        }
    }


    fun getCertification(context: Context?): Boolean {
        if (null == context)
            return false
        if (PublicInfoDataService.getInstance().isEnforceGoogleAuth(null)) {
            if (UserDataService.getInstance().nickName.isEmpty() ||  UserDataService.getInstance().googleStatus != 1) {
                NewDialogUtils.OTCTradingMustPermissionsDialog(context, object : NewDialogUtils.DialogBottomListener {
                    override fun sendConfirm() {


                    }

                    override fun sendConfirm(view: View) {
                        super.sendConfirm(view)
                        pushOTCTradingPermissionsDialog(view)
                    }


                }, title = LanguageUtil.getString(context, "otcSafeAlert_text_title_forotc"),type = -2)
                return false
            }
        } else {
            if (UserDataService.getInstance().nickName.isEmpty() ||  (UserDataService.getInstance().isOpenMobileCheck != 1 && UserDataService.getInstance().googleStatus != 1)) {
                NewDialogUtils.OTCTradingPermissionsDialog(context, object : NewDialogUtils.DialogBottomListener {
                    override fun sendConfirm() {

                    }

                    override fun sendConfirm(view: View) {
                        super.sendConfirm(view)
                        pushOTCTradingPermissionsDialog(view)
                    }
                },title = LanguageUtil.getString(context, "otcSafeAlert_text_title_forotc"),type = -2)
                return false
            }
        }
        return true
    }

    fun showAuthPermissionNoEnoughDialog(activity:Activity,isForce:Boolean){
        KKDialogUtils.showCommonDialog(
            activity,
            "kyc_common_content".tr(activity),
            "kyc_common_title".tr(activity),
            object : KKDialogUtils.DialogDoubleBottomListener {
                override fun sendConfirm() {
                    if(isForce) activity.finish()
                    ArouterUtil.navigation(RoutePath.KycActivity,null)
                }
                override fun sendCancel() {
                    if(isForce) activity.finish()
                }

                override fun dismiss(dialog: DialogInterface) {
                    super.dismiss(dialog)
                    if(isForce) activity.finish()
                }
            },
            confrimTitle = "kyc_common_button_verify".tr(activity),
            cancelTitle = "kyc_common_button_later".tr(activity),
            isShowCancel = true,
            style = 1
        )
    }

    fun getLanguage(): String {
//        val language = if (SystemUtils.isZh()) {
//            "zh_CN"
//        } else if (SystemUtils.isMn()) {
//            "mn_MN"
//        } else if (SystemUtils.isRussia()) {
//            "ru_RU"
//        } else if (SystemUtils.isKorea()) {
//            "ko_KR"
//        } else if (SystemUtils.isJapanese()) {
//            "ja_JP"
//        } else if (SystemUtils.isTW()) {
//            "el_GR"
//        } else if (SystemUtils.isVietNam()) {
//            "vi_VN"
//        } else if (SystemUtils.isSpanish()) {
//            "es_ES"
//        } else if (SystemUtils.isID()) {
//            "id_ID"
//        }else if (SystemUtils.isTR()) {
//            "tr_TR"
//        } else {
//            "en_US"
//        }

        return LanguageUtil.getSelectLanguage()
    }

    fun getAreaData(context: Context): JsonObject {
        val stream: InputStream = context.assets.open("area.json")
        val size = stream.available()
        val byteArray = ByteArray(size)
        stream.read(byteArray)
        stream.close()
        val json: String = String(byteArray, Charset.defaultCharset())
        val jsonObject = JsonParser().parse(json).asJsonObject

        return jsonObject

    }

    fun getCertificationNew(context: Context?, title: String="",isNeedBindGa:Boolean = true): Boolean {
        if (null == context)
            return false

//        val isGoogle = PublicInfoDataService.getInstance().isEnforceGoogleAuth(null)
        val isBindGoogle = if(isNeedBindGa) UserDataService.getInstance().googleStatus != 1 else true
        if (UserDataService.getInstance().nickName.isEmpty() ||  isBindGoogle) {
            NewDialogUtils.OTCTradingMustPermissionsDialogNew(context, object : NewDialogUtils.DialogBottomListener {
                override fun sendConfirm() {


                }

                override fun sendConfirm(view: View) {
                    super.sendConfirm(view)
                    pushOTCTradingPermissionsDialog(view)
                }


            }, title = title, isNeedBindGa = isNeedBindGa, type = -2)
            return false
        }
        return true
    }

}
