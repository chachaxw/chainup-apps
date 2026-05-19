package com.yjkj.chainup.new_version.activity.login

import android.content.Intent
import android.os.Bundle
import android.view.LayoutInflater
import com.alibaba.android.arouter.facade.annotation.Route
import com.chainup.contract.utils.setSafeListener
import com.jaeger.library.StatusBarUtil
 import com.chainup.contract.view.dialog.CpTDialog
import com.chainup.kit.views.KKCommonlyUsedButtonViewKit
import com.chainup.kit.views.base.BaseEditTextKit
import com.yjkj.chainup.R
import com.yjkj.chainup.app.AppConstant
import com.yjkj.chainup.base.NBaseActivity
import com.yjkj.chainup.bean.CountryInfo
import com.yjkj.chainup.bean.TartCaptchaV2Bean
import com.yjkj.chainup.db.service.PublicInfoDataService
import com.yjkj.chainup.extra_service.arouter.ArouterUtil
import com.yjkj.chainup.manager.CountryAreaDataManger
import com.yjkj.chainup.manager.LanguageUtil
import com.yjkj.chainup.manager.LoginManager
import com.yjkj.chainup.net_new.rxjava.NDisposableObserver
import com.yjkj.chainup.net_new.rxjava.NModelDisposableObserver
import com.yjkj.chainup.new_version.activity.FindPwd2verifyActivity
import com.yjkj.chainup.new_version.activity.SelectAreaActivity
import com.yjkj.chainup.new_version.dialog.NewDialogUtils
import com.yjkj.chainup.new_version.view.CustomEditTextLayout
import com.yjkj.chainup.new_version.view.Gt3GeeListener
import com.yjkj.chainup.util.*
import kotlinx.android.synthetic.main.activity_new_version_forget_pwd.*
import kotlinx.android.synthetic.main.v_area_code.view.tv_area_code
import org.greenrobot.eventbus.Subscribe
import org.greenrobot.eventbus.ThreadMode
import org.json.JSONObject
import java.util.Locale

/**
 * @Author lianshangljl
 * @Date 2023/3/13-3:24 PM
 * @Email buptjinlong@163.com
 *@description Forgot Password
 */
@Route(path = "/login/newversionforgetpwdactivity")
class NewVersionForgetPwdActivity : NBaseActivity() {
    override fun setContentView(): Int {
        return R.layout.activity_new_version_forget_pwd
    }

    var accountText = ""
    private val areaView by lazy { LayoutInflater.from(this).inflate(R.layout.v_area_code,null) }
    private var countryCode:String? = null
    override fun initView() {
        cet_view?.isFocusable = true
        cet_view?.isFocusableInTouchMode = true
        cubtn_view?.isEnable(false)
        setOnClick()
        setTextContent()
        if (intent != null) {
            cet_view?.getRealEditText()?.setText(intent.getStringExtra("account_num") ?: "")
        }
    }

    fun setTextContent() {
        v_header?.titleText = LanguageUtil.getString(this, "login_action_fogotPassword")
        cet_view?.title = LanguageUtil.getString(this, "userinfo_text_account")
        cet_view?.hint = LanguageUtil.getString(this, "common_tip_inputPhoneOrMail")
        cubtn_view?.textContent = LanguageUtil.getString(this, "common_action_next")

        val reset_tips = String.format(LanguageUtil.getString(this, "password_reset_tips"),
            PublicInfoDataService.getInstance().getSafeWithdrawHour(PublicInfoDataService.getInstance().getData(null)))
        tv_sub_title.setText(reset_tips)
    }

    var tDialog: CpTDialog? = null

    fun setOnClick() {
        cet_view?.listener = object:BaseEditTextKit.OnKKBaseListener{
            override fun textChange(text: String) {
                changeLoginWay(StringUtil.isNumeric(text) && text.length>3)
                accountText = text.trim()
                if (accountText.isNotEmpty()) {
                    cubtn_view?.isEnable(true)
                } else {
                    cubtn_view?.isEnable(false)
                }
            }

        }

        areaView.setOnClickListener {
            startActivity(Intent(this, SelectAreaActivity::class.java))
        }


        cubtn_view?.setSafeListener {

            addDisposable(getMainModel().getTartCaptchaV2(
                consumer = object : NModelDisposableObserver<TartCaptchaV2Bean>(this,true){
                    override fun onResponseSuccess(data: TartCaptchaV2Bean) {
                        NewDialogUtils.createSafeVerifyDialog(this@NewVersionForgetPwdActivity,data){
                            findPwdStep1(accountText,it)
                        }
                    }
                }
            ))
        }
    }

    private fun changeLoginWay(isPhoneLogin:Boolean){
        if(isPhoneLogin){
            setCountryCode()
            cet_view.addCustomActionBefore(areaView)
        }else{
            countryCode = null
            cet_view.removeCustomActionBefore()
        }
    }


    override fun onInit(savedInstanceState: Bundle?) {
        super.onInit(savedInstanceState)
        initView()
    }


    private val verificationType by lazy { PublicInfoDataService.getInstance().getVerifyType(null) }

    var token = ""

    /**
     *Account
     */
    var account = ""

    /**
     *Retrieve password
     *@param registerCode Fill in your phone number or email address
     */
    private fun findPwdStep1(registerCode: String, safeVerifyMap: Map<String, String>) {

        showLoadingDialog()
        var isPhoneNum = StringUtils.isNumeric(registerCode)
        var mobileNumber = ""
        var email = ""
        if (isPhoneNum) {
            mobileNumber = registerCode
        } else {
            email = registerCode
        }
        addDisposable(getMainModel().findPwdStep1(
                mobileNumber,
                email,
                countryCode,
                verificationType = verificationType,
                safeVerifyDataMap = safeVerifyMap,
                consumer = object : NDisposableObserver(true) {
                    override fun onResponseSuccess(jsonObject: JSONObject) {
                        closeLoadingDialog()
                        var json = jsonObject.optJSONObject("data")
                        token = json?.optString("token") ?: ""
//                if (StringUtils.checkEmail(registerCode)) {
//                    var bundle = Bundle()
//                    bundle.putString("send_account", accountText)
//                    bundle.putString("send_token", token)
//                    bundle.putString("send_countryCode", "")
//                    bundle.putInt("send_position", 2)
//                    bundle.putInt("send_islogin", 2)
//                    ArouterUtil.navigation("/login/newphoneverificationactivity", bundle)
//                } else if (StringUtils.isNumeric(registerCode)) {
//                    var bundle = Bundle()
//                    bundle.putString("send_account", accountText)
//                    bundle.putString("send_token", token)
//                    bundle.putString("send_countryCode", "")
//                    bundle.putInt("send_position", 1)
//                    bundle.putInt("send_islogin", 2)
//                    ArouterUtil.navigation("/login/newphoneverificationactivity", bundle)
//                }
//Finish()//Otherwise, if the Token expires, it will be awkward

//Var isCertificateNumber=json OptString ("isCertificateNumber"). equals ("1")//Whether to verify the identity card in the next step, 0 indicates no need
                        var isGoogleAuth = json?.optString("isGoogleAuth").equals("1") //Next step, do you want to perform Google verification? 0 is not required
                        var isCertificateNumber = false //Next step is to verify the ID card, 0 indicates no need

//Var isCertificateNumber=true//Next step is to verify the ID card, where 0 indicates no need
//Var isGoogleAuth=true//Whether to perform Google verification next, 0 is not required

                        var codeType = if (isPhoneNum) AppConstant.FIND_PWD_MOBILE else AppConstant.FIND_PWD_EMAIL
                        NewDialogUtils.showForgetPwdSecurityVerificationDialog(this@NewVersionForgetPwdActivity, isPhoneNum, !isPhoneNum, isGoogleAuth, isCertificateNumber, codeType, object : NewDialogUtils.DialogVerifiactionNewListener {
                            override fun returnCode(phone: String?, mail: String?, phoneCode: String?, mailCode: String?, googleCode: String?, certifcateNumber: String?) {
                                addDisposable(getMainModel().findPwdStep2(
                                        token,
                                        phoneCode.toString(),
                                        phone.toString(),
                                        mailCode.toString(),
                                        mail.toString(),
                                        certifcateNumber.toString(),
                                        googleCode.toString(),
                                        consumer = MyNDisposableObserver(NewPhoneVerificationActivity.FINDPWDSTEP2_TYPE)))

                            }
                        }, -1, LanguageUtil.getString(this@NewVersionForgetPwdActivity, "common_text_btnConfirm"), token, accountText)
                    }

                    override fun onResponseFailure(code: Int, msg: String?) {
                        super.onResponseFailure(code, msg)
                        closeLoadingDialog()
                        DisplayUtil.showSnackBar(window?.decorView, msg, isSuc = false)
                    }
                }))
    }

    inner class MyNDisposableObserver(type: Int) : NDisposableObserver(this, true) {
        var reqType = type

        override fun onResponseSuccess(jsonObject: JSONObject) {
            var json = jsonObject.optJSONObject("data")
            when (reqType) {
                NewPhoneVerificationActivity.FINDPWDSTEP2_TYPE -> {
                    var isCertificateNumber = json?.optString("isCertificateNumber") ?: "0"
                    var isGoogleAuth = json?.optString("isGoogleAuth") ?: "0"
                    if (isCertificateNumber == "0" && isGoogleAuth == "0") {
                        /**
                         *Directly jump to the 'Reset Password' interface
                         */
                        val bundle = Bundle()
                        bundle.putString("account_num", account)
                        bundle.putInt("index_status", 1)
                        bundle.putString("index_token", token)
                        bundle.putString("index_number_code", "")
                        bundle.putString("param", "")
                        ArouterUtil.navigation("/login/newsetpasswordactivity", bundle)
                    } else {
                        /**
                         *Verify Google, ID
                         */
                        FindPwd2verifyActivity.enter2(token, isCertificateNumber.toInt(), isGoogleAuth.toInt(), account)
                    }
                    finish()
                }
            }


        }

        override fun onResponseFailure(code: Int, msg: String?) {
            super.onResponseFailure(code, msg)

        }

    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    fun onEvent4Area(area: CountryInfo) {
        countryCode = area.dialingCode
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


