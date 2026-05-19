package com.yjkj.chainup.new_version.activity.personalCenter

import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.util.Log
import android.view.View
import com.yjkj.chainup.db.constant.RoutePath
import com.yjkj.chainup.db.service.ColorDataService
import com.yjkj.chainup.db.service.PublicInfoDataService
import com.yjkj.chainup.db.service.UserDataService
import com.yjkj.chainup.extra_service.arouter.ArouterUtil
import com.yjkj.chainup.extra_service.eventbus.MessageEvent
import com.yjkj.chainup.extra_service.eventbus.NLiveDataUtil
import com.yjkj.chainup.manager.ChainUpManager
import com.yjkj.chainup.manager.LanguageUtil
import com.yjkj.chainup.manager.LoginManager
import com.yjkj.chainup.net.HttpClient
import com.yjkj.chainup.net.retrofit.NetObserver
import com.yjkj.chainup.new_version.activity.NewBaseActivity
import com.yjkj.chainup.new_version.activity.TitleShowListener
import com.yjkj.chainup.new_version.activity.personalCenter.push.PushSettingsActivity
import com.yjkj.chainup.new_version.dialog.NewDialogUtils
import com.yjkj.chainup.new_version.view.CommonlyUsedButton
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.schedulers.Schedulers
import kotlinx.android.synthetic.main.activity_new_setting.*
import android.net.Uri
import com.chainup.contract.utils.CpColorUtil
import com.chainup.contract.view.dialog.CpTDialog
import com.chainup.kit.KKDialogUtils
import com.chainup.kit.views.KKCommonlyUsedButtonViewKit
import com.yjkj.chainup.R
import com.yjkj.chainup.extra_service.eventbus.EventBusUtil
import com.yjkj.chainup.net.api.ApiConstants
import com.yjkj.chainup.new_version.activity.personalCenter.contract.ContractChangeActivity
import com.yjkj.chainup.new_version.dialog.DialogUtil
import com.yjkj.chainup.new_version.activity.NewMainActivity
import com.yjkj.chainup.util.*
import org.greenrobot.eventbus.Subscribe
import org.greenrobot.eventbus.ThreadMode
import org.json.JSONObject
import java.io.File


/**
 * @Author lianshangljl
 * @Date 2023/3/27-5:35 PM
 * @Email buptjinlong@163.com
 *@description Settings Page
 */
class NewSettingActivity : NewBaseActivity() {
    //Green rising
    var global = ""

    //Red Rising
    var china = ""

    //Day Edition
    private var themeDay = ""

    //Night Edition
    private var themeNight = ""

    //White version K line night version
    private var themedayKlineNight = ""

    var riseAndFallDialog:  CpTDialog? = null
    var setSkinTDialog:  CpTDialog? = null
    var setLogTDialog: CpTDialog? = null

    companion object {
        fun enter2(context: Context) {
            var intent = Intent()
            intent.setClass(context, NewSettingActivity::class.java)
            context.startActivity(intent)
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_new_setting)
        global = LanguageUtil.getString(this, "customSetting_action_global")
        china = LanguageUtil.getString(this, "customSetting_action_china")
        themeDay = LanguageUtil.getString(this, "customSetting_action_themeDay")
        themeNight = LanguageUtil.getString(this, "customSetting_action_themeNight")
        themedayKlineNight = LanguageUtil.getString(this, "customSetting_action_themeDay_KlineNight")
        title_layout?.setContentTitle(LanguageUtil.getString(this, "personal_text_setting"))
        LogUtil.e(TAG, "onCreate()")
        setOnClick()

    }

    override fun onResume() {
        super.onResume()
        initView()
    }


    fun initView() {
        var language = ""
        var languageList = PublicInfoDataService.getInstance().lanList
        for (i in 0 until languageList?.size!!) {
            if (languageList[i].optString("id") == LanguageUtil.getSelectLanguage()) {
                language = languageList[i].optString("name")
            }
        }
        aiv_change_language?.setTitle(LanguageUtil.getString(this, "customSetting_action_language"))
        aiv_rise_and_fall_color?.setTitle(LanguageUtil.getString(this, "customSetting_action_kline"))
        aiv_skin_is_set?.setTitle(LanguageUtil.getString(this, "customSetting_action_theme"))
        aiv_about_us?.setTitle(LanguageUtil.getString(this, "personal_text_aboutus"))
        login_out?.textContent = LanguageUtil.getString(this, "common_text_logout")
        aiv_change_language.setStatusText(language)

        if (ColorUtil.getColorType() == 0) {
            aiv_rise_and_fall_color?.setStatusText(global)
        } else {
            aiv_rise_and_fall_color?.setStatusText(china)
        }
        if (PublicInfoDataService.getInstance().themeMode == 0) {
            aiv_skin_is_set?.setStatusText(themeDay)
//            if (PublicInfoDataService.getInstance().klineThemeMode == 1){
//                aiv_skin_is_set?.setStatusText(themedayKlineNight)
//            }
        } else {
            aiv_skin_is_set?.setStatusText(themeNight)
        }
    }

    fun setOnClick() {
        listener = object : TitleShowListener {
            override fun TopAndBottom(status: Boolean) {
                title_layout?.slidingShowTitle(status)
            }

        }
        if (UserDataService.getInstance().isLogined) {
            login_out?.visibility = View.VISIBLE
        } else {
            login_out?.visibility = View.GONE
        }
        val isPush = PublicInfoDataService.getInstance().getPushStatus(null)
        aiv_push.visibility = isPush.visiableOrGone()
        /**
         *Set Language
         */
        aiv_change_language?.setOnClickListener {
            OTCChooseLanguageActivity.newIntent(this)
        }
        aiv_push?.setOnClickListener {
            if (!LoginManager.checkLogin(this, true)) {
                return@setOnClickListener
            }
            startActivity(Intent(context, PushSettingsActivity::class.java))
        }
        aiv_about_us?.setOnClickListener {
            startActivity(Intent(this, AboutActivity::class.java))
        }
        aiv_about_us.setStatusText("V"+AppUtils.getVersionName(this))
        /**
         *Increase Color
         */
        aiv_rise_and_fall_color?.setOnClickListener {

            riseAndFallDialog = NewDialogUtils.showListDialogTx(this, LanguageUtil.getString(this, "customSetting_action_kline"),arrayListOf(global, china), ColorUtil.getColorType(), object : NewDialogUtils.DialogOnclickListener {
                override fun clickItem(data: ArrayList<String>, item: Int) {
                    ColorDataService.getInstance().colorType = item
                    CpColorUtil.setColorType(this@NewSettingActivity,item)
                    if (item == 0) {
                        aiv_rise_and_fall_color?.setStatusText(global)
                    } else {
                        aiv_rise_and_fall_color?.setStatusText(china)
                    }
                    riseAndFallDialog?.dismiss()

                    var messageEvent = MessageEvent(MessageEvent.color_rise_fall_type)
                    NLiveDataUtil.postValue(messageEvent)
                    EventBusUtil.post(messageEvent)
                }

                override fun onDismiss() {

                }

            })
        }

        /**
         *Set skin color
         */
        aiv_skin_is_set?.setOnClickListener {
            var selecttheme = PublicInfoDataService.getInstance().themeMode
//            if (selecttheme == ApiConstants.themeDay() && PublicInfoDataService.getInstance().klineThemeMode != ApiConstants.themeDay()){
//                selecttheme = 2
//            }
            setSkinTDialog = NewDialogUtils.showListDialogTx(this, LanguageUtil.getString(this, "customSetting_action_theme"),arrayListOf(themeDay, themeNight), selecttheme, object : NewDialogUtils.DialogOnclickListener {
                override fun clickItem(data: ArrayList<String>, item: Int) {

                    setSkinTDialog?.dismiss()
                    if (item == 0) {
                        aiv_skin_is_set?.setStatusText(themeDay)
                        PublicInfoDataService.getInstance().themeMode = item
                        PublicInfoDataService.getInstance().klineThemeMode = item
                    } else if (item == 1){
                        aiv_skin_is_set?.setStatusText(themeNight)
                        PublicInfoDataService.getInstance().themeMode = item
                        PublicInfoDataService.getInstance().klineThemeMode = item
                    }else{
                        PublicInfoDataService.getInstance().themeMode = 0
                        PublicInfoDataService.getInstance().klineThemeMode = 1
                        aiv_skin_is_set?.setStatusText(themedayKlineNight)
                    }
                    /**
                     *Is it set for day or night here
                     *@param item 0 day version 1 night version
                     ** This only changes the status bar, not yet
                     */
                    setBarColor(PublicInfoDataService.getInstance().themeMode)
                    reStart(this@NewSettingActivity)
                    LocalManageUtil.saveSelectLanguage(this@NewSettingActivity, LanguageUtil.getSelectLanguage())
                    finish()

                }

                override fun onDismiss() {

                }
            })
        }
        val localShare = LanguageUtil.getString(this, "customSetting_action_log_system")
        val networkShare = LanguageUtil.getString(this, "customSetting_action_log_network")
        aiv_log_upload?.setOnClickListener {
            setLogTDialog = NewDialogUtils.showBottomListDialog(this, arrayListOf(localShare, networkShare), 0, object : NewDialogUtils.DialogOnclickListener {
                override fun clickItem(data: ArrayList<String>, item: Int) {
                    if (item == 0) {
                        ChainUpManager.instance.updateLocalLogShare().subscribeOn(Schedulers.io())
                                .observeOn(AndroidSchedulers.mainThread())
                                .subscribe({
                                    setLogTDialog?.dismiss()
                                    Log.e("LogUtils", "it ${it}")
                                    val intent = Intent(Intent.ACTION_SEND)
                                    intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                                    intent.putExtra(Intent.EXTRA_STREAM, it)  //Streaming the transmission of images or files
                                    intent.type = "*/*" //Share files
                                    context.startActivity(Intent.createChooser(intent, LanguageUtil.getString(this@NewSettingActivity, "contract_share_label")))
                                })
                    } else {
                        showProgressDialog()
                        ChainUpManager.instance.updateHttpStatus().subscribeOn(Schedulers.io())
                                .observeOn(AndroidSchedulers.mainThread())
                                .subscribe({
                                    cancelProgressDialog()
                                    Log.e("LogUtils", "it ${it}")
                                    setLogTDialog?.dismiss()
                                    if (it) {
                                        DisplayUtil.showSnackBar(window?.decorView, LanguageUtil.getString(this@NewSettingActivity, "toast_trade_success"), isSuc = it)
                                    }
                                }, {
                                    it.printStackTrace()
                                    cancelProgressDialog()
                                    setLogTDialog?.dismiss()
                                    DisplayUtil.showSnackBar(window?.decorView, LanguageUtil.getString(this@NewSettingActivity, "otc_uplaod_error"), isSuc = false)
                                })
                    }
                }

                override fun onDismiss() {

                }
            })
        }

        /**
         *Exit
         */
        login_out?.isEnable(true)
        login_out?.listener = object : KKCommonlyUsedButtonViewKit.OnKKBottonClickListener {
            override fun bottonOnClick() {
                showLogoutDialog()
            }

        }
        val publicTheme = PublicInfoDataService.getInstance().contractMode
        val message = when (publicTheme) {
            0 -> "customSetting_text_coDescOld"
            else -> "customSetting_text_coDescNew"
        }
        if (publicTheme == 1) {
            aiv_change_contract?.showMailRed(true, R.drawable.bg_right_red)
        }

        aiv_change_contract?.showLeftRed(true)
        aiv_change_contract?.iv_red_dot_left?.setOnClickListener {
            DialogUtil.showContractStatement(this)
        }
        aiv_change_contract.visibility = PublicInfoDataService.getInstance().getContractSwitchDefault(null).visiableOrGone()
        aiv_change_contract?.setStatusText(LanguageUtil.getString(this, message))
        aiv_change_contract?.setOnClickListener {
            //Process contract switching
            startActivity(Intent(context, ContractChangeActivity::class.java))
        }
    }
    fun reStart(context: Context) {
        val intent = Intent(context, NewMainActivity::class.java)
        intent.flags = Intent.FLAG_ACTIVITY_CLEAR_TASK or Intent.FLAG_ACTIVITY_NEW_TASK
        context.startActivity(intent)
        HttpClient.instance.refresh()
        PublicInfoDataService.getInstance().saveData(JSONObject())
    }

    /**
     *Log out of the login dialog
     */
    fun showLogoutDialog() {

        KKDialogUtils.showCommonDialog(this,"",LanguageUtil.getString(this, "common_tip_logoutDesc"),
            listener = object: KKDialogUtils.DialogDoubleBottomListener{
                override fun sendConfirm() {
                    logout()
                }

                override fun sendCancel() {

                }

            },
            style = 1,
            cancelTitle = LanguageUtil.getString(this,"common_text_btnCancel"),
            confrimTitle = LanguageUtil.getString(this,"common_text_btnConfirm")
        )

//        NewDialogUtils.showNormalDialog(
//            this,
//            LanguageUtil.getString(this, "common_tip_logoutDesc"),
//            listener = object:NewDialogUtils.DialogBottomListener{
//            override fun sendConfirm() {
//                logout()
//            }
//        })
//        NewDialogUtils.showNewDoubleDialog(this,LanguageUtil.getString(this, "common_tip_logoutDesc"), object : NewDialogUtils.DialogBottomListener {
//            override fun sendConfirm() {
//
//            }
//        })
//        NewDialogUtils.showNormalDialog(this, LanguageUtil.getString(this, "common_tip_logoutDesc"), object : NewDialogUtils.DialogBottomListener {
//            override fun sendConfirm() {
//                logout()
//            }
//        })
    }

    /**
     *Log out of login
     */
    fun logout() {
        showProgressDialog()
        HttpClient.instance.logout()
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(object : NetObserver<Any>() {
                    override fun onHandleSuccess(t: Any?) {
                        cancelProgressDialog()
                        DisplayUtil.showSnackBar(window?.decorView, LanguageUtil.getString(this@NewSettingActivity, "common_action_logout"), isSuc = true)
                        UserDataService.getInstance().clearToken()
                        LoginManager.postValue(false)
                        finish()
                    }

                    override fun onHandleError(code: Int, msg: String?) {
                        super.onHandleError(code, msg)
                        cancelProgressDialog()
                        DisplayUtil.showSnackBar(window?.decorView, msg, isSuc = false)
                    }
                }
                )

    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    override fun onMessageEvent(event: MessageEvent) {
        super.onMessageEvent(event)
        if (event.msg_type == MessageEvent.finish_page_event) {
            finish()
        }
    }

}
