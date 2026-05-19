package com.yjkj.chainup.new_version.activity.personalCenter

import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.text.TextUtils
import android.view.Gravity
import androidx.appcompat.app.AppCompatActivity
import androidx.recyclerview.widget.LinearLayoutManager
import com.chainup.contract.utils.ChainUpLogUtil
import com.chainup.contract.utils.CpClLogicContractSetting
import com.chainup.contract.utils.CpLocalManageUtil
import com.chainup.kit.dialog.KKLoadingDialog
import com.qmuiteam.qmui.util.QMUIDisplayHelper
import com.yjkj.chainup.R
import com.yjkj.chainup.bean.NetworkLanguage
import com.yjkj.chainup.db.service.PublicInfoDataService
import com.yjkj.chainup.extra_service.eventbus.EventBusUtil
import com.yjkj.chainup.extra_service.eventbus.MessageEvent
import com.yjkj.chainup.manager.CpLanguageUtil
import com.yjkj.chainup.manager.DataInitService
import com.yjkj.chainup.manager.LanguageUtil
import com.yjkj.chainup.manager.SymbolManager
import com.yjkj.chainup.net.HttpClient
import com.yjkj.chainup.new_version.activity.NewMainActivity
import com.yjkj.chainup.new_version.activity.SplashActivity
import com.yjkj.chainup.new_version.adapter.OTCChangeLanguageAdapter
import com.yjkj.chainup.new_version.view.EmptyForAdapterView
import com.yjkj.chainup.util.LocalManageUtil
import com.yjkj.chainup.util.SystemUtils
import com.yjkj.chainup.util.Utils
import io.reactivex.Observable
import io.reactivex.ObservableOnSubscribe
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.disposables.Disposable
import io.reactivex.schedulers.Schedulers
import kotlinx.android.synthetic.main.activity_otc_choose_countries.*
import org.json.JSONArray
import org.json.JSONObject


/**
 * @Author lianshangljl
 *@ Date 2018/10/13-5:37 PM
 * @Email buptjinlong@163.com
 *@description Choose a country
 */
class OTCChooseLanguageActivity : AppCompatActivity() {
    private var mLoadingDialog: KKLoadingDialog? = null
    var adapter: OTCChangeLanguageAdapter? = null
    private var downLoadLangTaskDisposable: Disposable? = null
    private var isCanSwitchLang:Boolean = true
    companion object {
        fun newIntent(context: Context) {
            context.startActivity(Intent(context, OTCChooseLanguageActivity::class.java))
        }
    }
    protected fun showLoadingDialog() {
        if (null == mLoadingDialog) {
            mLoadingDialog = KKLoadingDialog(this)
        }
        try {
            mLoadingDialog?.showLoadingDialog()
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }
    protected fun closeLoadingDialog() {
        if (mLoadingDialog != null) {
            mLoadingDialog?.closeLoadingDialog()
            mLoadingDialog = null
        }

    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        setContentView(R.layout.activity_otc_choose_countries)
        title_layout?.setContentTitle(LanguageUtil.getString(this, "customSetting_action_language"))
        val layoutParams = getWindow().getAttributes()
        layoutParams.width = QMUIDisplayHelper.getScreenWidth(this)
        layoutParams.gravity= Gravity.BOTTOM
        getWindow().setAttributes(layoutParams)
        initView()
        setSelcetOnclick()
    }

    var launch: JSONObject? = null
    var lauList: ArrayList<JSONObject>? = arrayListOf()
    var saveLanguage: String = ""
    fun initView() {
        launch = PublicInfoDataService.getInstance().getLan(null)
        saveLanguage = SymbolManager.instance.getOTCLanguage().toString()
        lauList = PublicInfoDataService.getInstance().lanList
        if (lauList == null) return

        if (TextUtils.isEmpty(saveLanguage)) {
            for (i in 0 until lauList?.size!!) {
                lauList!![i].putOpt("open", (LanguageUtil.getSelectLanguage() == lauList!![i].optString("id")))
            }
        } else {
            for (i in 0 until lauList?.size!!) {
                lauList!![i].putOpt("open", (saveLanguage == lauList!![i].optString("id")))
            }
        }

        rv_location.layoutManager = LinearLayoutManager(this)
        adapter = OTCChangeLanguageAdapter(lauList!!)

        adapter?.setEmptyView(EmptyForAdapterView(this))
        rv_location.adapter = adapter
        tv_title.setText(LanguageUtil.getString(this,"customSetting_action_language"))
        tv_cancel.setText(LanguageUtil.getString(this,"common_text_btnCancel"))

    }

    fun setSelcetOnclick() {
        /**
         *Click on language
         */
        adapter?.setOnItemClickListener { adapter, view, position ->
            if(!isCanSwitchLang) return@setOnItemClickListener
            launch?.putOpt("defLan", lauList?.get(position)?.optString("id")!!)
            SymbolManager.instance.saveOTCLanguage(lauList?.get(position)?.optString("id")!!)
            setLanguageStatus(lauList?.get(position)?.optString("id") ?: "")

        }
        rl_content.setOnClickListener { finish() }
        tv_cancel.setOnClickListener { finish() }

    }

    fun setLanguageStatus(lan: String) {
        CpLocalManageUtil.saveSelectLanguage(this, lan)
        downLoadContractLan(lan)
    }

    private fun downLoadContractLan(lan: String) {
        showLoadingDialog()
        isCanSwitchLang = false
        downLoadLangTaskDisposable = Observable.create(ObservableOnSubscribe<Boolean> {
            val mContractLanguageJsonListStr = CpClLogicContractSetting.getContractLanguageJsonListStr(this)
            if (!TextUtils.isEmpty(mContractLanguageJsonListStr.toString())) {
                val jsonArray = JSONArray(mContractLanguageJsonListStr)
                for (i in 0 until jsonArray.length()) {
                    val jsonArrayBuff = jsonArray[i] as JSONObject
                    val langKey = jsonArrayBuff.optString("langKey")
                    val url = jsonArrayBuff.optString("nowFileAddress")
                    if (lan.equals(langKey)) {
                        try {
                            val jsonFile = Utils.getJSONLastNews(url)
                            if(jsonFile==null){
                                CpLanguageUtil.saveOnlineText(this,"")
                            }else{
                                CpLanguageUtil.saveOnlineText(this,jsonFile.toString())
                            }
                        }catch (e:Exception){
                            e.printStackTrace()
                            CpLanguageUtil.saveOnlineText(this,"")
                        }
                        it.onNext(true)
                    }
                }
            }else{
                it.onNext(false)
            }
            it.onComplete()
        })
            .subscribeOn(Schedulers.io())
            .observeOn(AndroidSchedulers.mainThread())
            .doOnComplete {
                val select = getNetString(lan)
                if (!select) {
                    setLanguageDefault(lan)
                }

            }
            .subscribe({
                ChainUpLogUtil.d("downLoadContractLan>>>$it")
            },{
                it.printStackTrace()
            })


    }


    override fun onDestroy() {
        super.onDestroy()
        downLoadLangTaskDisposable?.dispose()
    }
    /**
     *Default Setting Language
     */
    fun setLanguageDefault(lan: String) {
        when (lan) {
            "zh_CN" -> {
                selectLanguage("zh_CN")
            }
            "zh" -> {
                selectLanguage("zh")
            }
            "en_US" -> {
                selectLanguage("en_US")
            }
            "ko_KR" -> {
                selectLanguage("ko_KR")
            }
            "el_GR" -> {
                selectLanguage("el_GR")
            }
            "mn_MN" -> {
                selectLanguage("mn_MN")
            }
            "ja_JP" -> {
                selectLanguage("ja_JP")
            }
            "ru_RU" -> {
                selectLanguage("ru_RU")
            }
            "vi_VN" -> {
                selectLanguage("vi_VN")
            }
            "es_ES" -> {
                selectLanguage("es_ES")
            }
            "id_ID" -> {
                selectLanguage("id_ID")
            }
            "tr_TR" -> {
                selectLanguage("tr_TR")
            }
            "th_TH" -> {
                selectLanguage("th_TH")
            }
            else -> {
                selectLanguage("en_US")
            }
        }
    }


    /**
     *TODO specific implementation
     */
    private fun getNetString(key: String): Boolean {
        var locales = PublicInfoDataService.getInstance().getLocalesList(null)
        if (locales == null) return false

        val jsonArray = locales
        for (i in 0 until jsonArray.length()) {
            val jsonArrayBuff = jsonArray[i] as JSONObject
            val langKey = jsonArrayBuff.optString("langKey")
            val url = jsonArrayBuff.optString("nowFileAddress")
            if (key.equals(langKey)) {
                var jsonObject: JSONObject? = PublicInfoDataService.getInstance().onlineText
                if (jsonObject == null) {
                    downLoadLan(url, key)
                } else {
                    var lan = jsonObject.optString(key, "") ?: ""
                    if (TextUtils.isEmpty(lan)) {
                        downLoadLan(url, key)
                    } else {
                        selectLanguage(key)
                    }
                }
                return true
            }
        }
        return false
    }

    fun downLoadLan(url: String, key: String) {
        Thread(Runnable {
            try {
                println("多语言url = ${url}")
                println("多语言key = ${key}")
                val jsonFile = Utils.getJSONLastNews(url)
                if(jsonFile==null){
                    PublicInfoDataService.getInstance().saveOnlineText("")
                }else{
                    PublicInfoDataService.getInstance().saveOnlineText(jsonFile)
                }


//                val mContractLanguageJsonListStr = LogicContractSetting.getContractLanguageJsonListStr(this)
//                if (!TextUtils.isEmpty(mContractLanguageJsonListStr.toString())) {
//                    val jsonArray = JSONArray(mContractLanguageJsonListStr)
//                    for (i in 0 until jsonArray.length()) {
//                        val jsonArrayBuff = jsonArray[i] as JSONObject
//                        val langKey = jsonArrayBuff.optString("langKey")
//                        val url = jsonArrayBuff.optString("nowFileAddress")
//                        if (key.equals(langKey)) {
//                            var jsonFile = Utils.getJSONLastNews(url)
//                            CpLanguageUtil.saveOnlineText(this,jsonFile.toString())
//                        }
//                    }
//                }

                selectLanguage(key)
            } catch (e: Exception) {
                e.printStackTrace()
                PublicInfoDataService.getInstance().saveOnlineText("")
                selectLanguage(key)
            }
        }).start()
    }


    fun selectLanguage(select: String) {
        closeLoadingDialog()
        LocalManageUtil.saveSelectLanguage(this, select)
        try {
            val isZhEnv = SystemUtils.isZh()
            //Notification Contract SDK Language Environment
//            ContractSDKAgent.isZhEnv = isZhEnv
        } catch (e: Exception) {
            e.printStackTrace()
        }
        NetworkLanguage().cleanLanguage()
//        RestartAPPTool.restartAPP(this)
//        var msg_event = MessageEvent(MessageEvent.finish_page_event)
//        EventBusUtil.post(msg_event)
        val dataIntent = Intent(this, DataInitService::class.java)
        dataIntent.putExtra("isFirst", true)
        try {
            startService(dataIntent)
        } catch (e: Exception) {
            e.printStackTrace()
        }

        val intent = Intent(this,SplashActivity::class.java)
        intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
        startActivity(intent)

    }

    fun reStart(context: Context) {
        finish()
        val intent = Intent(context, NewMainActivity::class.java)
        intent.flags = Intent.FLAG_ACTIVITY_CLEAR_TASK or Intent.FLAG_ACTIVITY_NEW_TASK
        context.startActivity(intent)
        HttpClient.instance.refresh()
        PublicInfoDataService.getInstance().saveData(JSONObject())
    }

    override fun attachBaseContext(newBase: Context?) {
        super.attachBaseContext(LocalManageUtil.setLocal(newBase))
    }
}
