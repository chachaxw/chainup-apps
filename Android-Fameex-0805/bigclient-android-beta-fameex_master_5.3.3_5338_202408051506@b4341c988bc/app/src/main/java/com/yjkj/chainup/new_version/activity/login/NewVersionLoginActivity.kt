package com.yjkj.chainup.new_version.activity.login


import android.content.Intent
import android.os.Bundle
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import com.alibaba.android.arouter.facade.annotation.Route
import com.chainup.contract.utils.setSafeListener
import com.chainup.contract.view.dialog.CpTDialog
import com.chainup.kit.views.PublicHeaderKit
import com.chainup.kit.views.base.BaseEditTextKit
import com.yjkj.chainup.R
import com.yjkj.chainup.base.NBaseActivity
import com.yjkj.chainup.bean.CountryInfo
import com.yjkj.chainup.bean.TartCaptchaV2Bean
import com.yjkj.chainup.db.constant.ParamConstant
import com.yjkj.chainup.db.constant.RoutePath
import com.yjkj.chainup.db.service.PublicInfoDataService
import com.yjkj.chainup.db.service.UserDataService
import com.yjkj.chainup.extra_service.arouter.ArouterUtil
import com.yjkj.chainup.freestaking.PROJECT_TYPE
import com.yjkj.chainup.manager.ActivityManager
import com.yjkj.chainup.manager.CountryAreaDataManger
import com.yjkj.chainup.manager.LanguageUtil
import com.yjkj.chainup.manager.LoginManager
import com.yjkj.chainup.net_new.rxjava.NDisposableObserver
import com.yjkj.chainup.net_new.rxjava.NModelDisposableObserver
import com.yjkj.chainup.new_version.activity.SelectAreaActivity
import com.yjkj.chainup.new_version.dialog.NewDialogUtils
import com.yjkj.chainup.util.*
import kotlinx.android.synthetic.main.activity_new_version_login.*
import kotlinx.android.synthetic.main.v_area_code.view.tv_area_code
import org.greenrobot.eventbus.Subscribe
import org.greenrobot.eventbus.ThreadMode
import org.json.JSONObject
import java.util.Locale

/**
 * @Author lianshangljl
 * @Date 2023/3/9-3:37 PM
 * @Email buptjinlong@163.com
 * @description login
 */
@Route(path = RoutePath.NewVersionLoginActivity)
class NewVersionLoginActivity : NBaseActivity() {
    override fun setContentView() = R.layout.activity_new_version_login

    override fun onInit(savedInstanceState: Bundle?) {
        super.onInit(savedInstanceState)
        windowTransitionBottomInBottomOut()
        initView()
        ActivityManager.pushAct2Stack(this)
    }


    var list: ArrayList<String> = arrayListOf()

    /**
     *Password
     */
    var pwdTextContent = ""

    /**
     *Account
     */
    var accountContent = ""

    private val areaView by lazy { LayoutInflater.from(this).inflate(R.layout.v_area_code,null) }
    private var countryCode:String? = null

    override fun initView() {
        setListener()
        list.add(LanguageUtil.getString(mActivity, "safety_text_googleAuth"))
        list.add(LanguageUtil.getString(mActivity, "safety_text_phoneAuth"))
        list.add(LanguageUtil.getString(mActivity, "safety_text_mailAuth"))
        tv_welcome.setText(LanguageUtil.getString(this,"login_action_login"))
        val logoBeanLogos = PublicInfoDataService.getInstance().getApp_logo_list_new(null)

        if (logoBeanLogos != null && logoBeanLogos.size > 0) {
            var logo_black = logoBeanLogos[0]
            var logo_white = ""
            if (logoBeanLogos.size > 1) {
                logo_white = logoBeanLogos[1]
            }
            if (PublicInfoDataService.getInstance().themeMode == 0) {

                if (StringUtil.checkStr(logo_white)) {
                    tv_welcome.visibility = View.GONE
                    GlideUtils.loadImageHeader(this, logo_white, app_logo)
                }else{
                    tv_welcome.visibility = View.VISIBLE
                }
            } else {
                if (StringUtil.checkStr(logo_black)) {
                    tv_welcome.visibility = View.GONE
                    GlideUtils.loadImageHeader(this, logo_black, app_logo)
                }else{
                    tv_welcome.visibility = View.VISIBLE
                }
            }
        }

        cbtn_view?.isEnable(false)
        val account = LoginManager.getInstance().loginInfo.account
        if(!"".equals(account)){
            changeLoginWay(StringUtil.isNumeric(account) && account.length>3)
            ce_account.getRealEditText().setText(account)
        }else{
            LoginManager.getInstance().removeSelectCountryCode()
        }


        setTextContent()
    }

    fun changeLoginWay(isPhoneLogin:Boolean){
        if(isPhoneLogin){
            setCountryCode()
            ce_account.addCustomActionBefore(areaView)
        }else{
            countryCode = null
            ce_account.removeCustomActionBefore()
        }
    }


    fun setTextContent() {
        tv_forget_pwd?.text = LanguageUtil.getString(this, "login_action_fogotPassword")
        tv_to_register?.text = LanguageUtil.getString(this, "login_action_register")
        ce_account?.hint = LanguageUtil.getString(this, "common_tip_inputPhoneOrMail")
        ce_account?.title = LanguageUtil.getString(this, "userinfo_text_account")
        pws_view?.hint = LanguageUtil.getString(this, "register_tip_inputPassword")
        pws_view?.title = LanguageUtil.getString(this, "login_text_pwd")
        cbtn_view?.textContent = LanguageUtil.getString(this, "login_action_login")
    }

    var dialog: CpTDialog? = null

    /**
     *
     */
    var tDialog: CpTDialog? = null

    fun setListener() {
        ce_account?.listener = object :BaseEditTextKit.OnKKBaseListener{
            override fun textChange(text: String) {
                changeLoginWay(StringUtil.isNumeric(text) && text.length>3)
                accountContent = text.trim()
                if (pwdTextContent.isNotEmpty() && accountContent.isNotEmpty()) {
                    cbtn_view?.isEnable(true)
                } else {
                    cbtn_view?.isEnable(false)
                }
            }

        }


        areaView.setOnClickListener {
            startActivity(Intent(this, SelectAreaActivity::class.java))
        }

        pws_view?.listener = object : BaseEditTextKit.OnKKBaseListener{
            override fun textChange(text: String) {
                pwdTextContent = text
                if (pwdTextContent.isNotEmpty() && accountContent.isNotEmpty()) {
                    cbtn_view?.isEnable(true)
                } else {
                    cbtn_view?.isEnable(false)
                }
            }

        }


        title_layout?.listener=object : PublicHeaderKit.IOnBackClickListener {
            override fun onRightBtn(view: View) {
                super.onRightBtn(view)
                KeyBoardUtils.closeKeyBoard(this@NewVersionLoginActivity)
                finish()
            }
        }
        /**
         *Go to register
         */
        tv_to_register?.setOnClickListener {
            ArouterUtil.greenChannel("/login/newversionregisteractivity", null)
            finish()
        }

        /**
         *Forgot password
         */
        tv_forget_pwd?.setOnClickListener {
            val bundle = Bundle()
            bundle.putString("account_num", ce_account.getText())
            ArouterUtil.greenChannel("/login/newversionforgetpwdactivity", bundle)
//            finish()
        }

        /**
         *Click to log in
         */
        cbtn_view?.setSafeListener {
            addDisposable(getMainModel().getTartCaptchaV2(
                consumer = object :NModelDisposableObserver<TartCaptchaV2Bean>(this,true){
                    override fun onResponseSuccess(data: TartCaptchaV2Bean) {
                        NewDialogUtils.createSafeVerifyDialog(this@NewVersionLoginActivity,data){
                            login(accountContent, pwdTextContent,it)
                        }
                    }
                }
            ))
        }
    }

    private val verificationType by lazy { PublicInfoDataService.getInstance().getVerifyType(null) }

    var token: String = ""

    /**
     *Login
     */
    private fun login(mobile: String, password: String,safeDataMap:Map<String,String>) {

        addDisposable(getMainModel().getLoginByMobile(
                mobile, password,
                countryCode=countryCode,
                verificationType,
                safeDataMap,
                consumer = object : NDisposableObserver(mActivity, true) {
                    override fun onResponseSuccess(jsonObject: JSONObject) {

                        LogUtil.d(TAG, "login==onResponseSuccess==jsonObject $jsonObject ")
                        var data = jsonObject.optJSONObject("data")

                        //Save token
                        token = data?.optString("token") ?: ""

                        /**
                         *Save login information
                         */
                        val loginInfo = LoginManager.getInstance().loginInfo
                        if (mobile != loginInfo.account) {
                            UserDataService.getInstance().saveGesturePass(null)
                            UserDataService.getInstance().saveData(JSONObject())
                            LoginManager.getInstance().saveFingerprint(0)
                        }

                        loginInfo.account = mobile
                        loginInfo.loginPwd = password
                        LoginManager.getInstance().saveLoginInfo(loginInfo)


                        // {"code":"0","msg":"成功","data":{"type":"2","token":"39257f8399139a329ca6637f6c9f6474"}}
                        Log.d("=== mobile login====", "登录成功" + data.toString())


        //                val typeList = data.optString("typeList") ?: ""
        //                if (typeList.isNotEmpty() && StringUtil.checkStr(typeList) && typeList.split(",").size <= 2) {
        //                    val googleAuth = data.optString("googleAuth") ?: "0"
        //                    nextPageLoginType(ParamConstant.LOGIN_GOOOGLE,typeList,googleAuth)
        //                } else {
                        /**
                         *Login to new logic
                         *Jump to the verification code page
                         */
                        /**
                         *Login to new logic
                         *Jump to the verification code page
                         */
                        val googleAuth = data.optString("googleAuth") ?: "0"
                        if (googleAuth == "1") {
                            nextPage(ParamConstant.LOGIN_GOOOGLE)
                        } else if (StringUtils.isNumeric(accountContent)) {
                            nextPage(ParamConstant.LOGIN_PHONE)
                        } else if (StringUtils.checkEmail(accountContent)) {
                            nextPage(ParamConstant.LOGIN_EMAIL)
                        }
        //                }
        //                finish()
                    }
            }))


    }

    private fun nextPage(type: Int) {
        val bundle = Bundle()
        bundle.putString("send_account", accountContent)
        bundle.putString("send_token", token)
        bundle.putString("send_countryCode", "")
        bundle.putInt("send_position", type)
        bundle.putInt("send_islogin", 0)
        ArouterUtil.greenChannel("/login/newphoneverificationactivity", bundle)
    }

    private fun nextPageLoginType(type: Int, typeList: String? = "", googleAuth: String? = "") {
        val bundle = Bundle()
        bundle.putString("send_account", accountContent)
        bundle.putString("send_token", token)
        bundle.putString("send_countryCode", "")
        bundle.putInt("send_position", type)
        bundle.putInt("send_islogin", 0)
        bundle.putString("send_verifitionType", typeList)
        bundle.putString("send_googleAuth", googleAuth)
        ArouterUtil.greenChannel(RoutePath.NewVersionCodeActivity, bundle)
    }

    override fun onDestroy() {
        super.onDestroy()
        Utils.setGeetestDeatroy()
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    fun onEvent4Area(area: CountryInfo) {
        countryCode = area.dialingCode
        LoginManager.getInstance().loginAreaCodeCache = countryCode
        if (Locale.getDefault().language.contentEquals("zh")) {
            areaView.tv_area_code.setText(area.cnName + " " + area.dialingCode)
        } else {
            areaView.tv_area_code.setText(area.enName + " " + area.dialingCode)
        }

    }

    fun setCountryCode() {
        val areaDataList = CountryAreaDataManger.instance.getAreaDataList()
        var countryCode = ""
        val selectCountryCode = LoginManager.getInstance().selectCountryCode
        if("".equals(selectCountryCode)){
            countryCode = PublicInfoDataService.getInstance().getDefaultCountryCode(null)
            LoginManager.getInstance().loginAreaCodeCache = countryCode
        }else{
            countryCode = selectCountryCode
        }
        areaDataList.forEach {
            if (it.dialingCode == countryCode) {
                runOnUiThread {
                    if (Locale.getDefault().language.contentEquals("zh")) {
                        areaView.tv_area_code.setText(it.cnName + " " + it.dialingCode)
                    } else {
                        areaView.tv_area_code.setText(it.enName + " " + it.dialingCode)
                    }
                    this.countryCode = it.dialingCode
                }
                return@forEach
            }
        }
    }

}
