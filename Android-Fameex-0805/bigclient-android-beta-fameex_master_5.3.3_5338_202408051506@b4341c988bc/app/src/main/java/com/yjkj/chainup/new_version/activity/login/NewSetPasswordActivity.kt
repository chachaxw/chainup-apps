package com.yjkj.chainup.new_version.activity.login

import android.os.Bundle
import android.text.TextUtils
import android.util.Log
import android.view.View
import android.widget.Toast
import androidx.core.hardware.fingerprint.FingerprintManagerCompat
import com.alibaba.android.arouter.facade.annotation.Route
import com.chainup.kit.views.base.BaseEditTextKit
import com.jaeger.library.StatusBarUtil
import com.yjkj.chainup.R
import com.yjkj.chainup.base.NBaseActivity
import com.yjkj.chainup.bean.RegStep2Bean
import com.yjkj.chainup.db.constant.ParamConstant
import com.yjkj.chainup.db.constant.RoutePath
import com.yjkj.chainup.db.constant.WebTypeEnum
import com.yjkj.chainup.db.service.PublicInfoDataService
import com.yjkj.chainup.db.service.UserDataService
import com.yjkj.chainup.extra_service.arouter.ArouterUtil
import com.yjkj.chainup.manager.ActivityManager
import com.yjkj.chainup.manager.LanguageUtil
import com.yjkj.chainup.manager.LoginManager
import com.yjkj.chainup.net.HttpClient
import com.yjkj.chainup.net_new.rxjava.NDisposableObserver
import com.yjkj.chainup.new_version.activity.InnerBrowserActivity
import com.yjkj.chainup.new_version.activity.ItemDetailActivity
import com.yjkj.chainup.new_version.view.CommonlyUsedButton
import com.yjkj.chainup.new_version.view.PwdSettingView
import com.yjkj.chainup.util.*
import io.reactivex.Observable
import io.reactivex.Observer
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.disposables.Disposable
import kotlinx.android.synthetic.main.activity_new_version_set_pwd.*
import org.json.JSONObject
import java.util.concurrent.TimeUnit

/**
 * @Author lianshangljl
 * @Date 2023/3/13-3:23 PM
 * @Email buptjinlong@163.com
 *@description Set password or reset password
 */
@Route(path = "/login/newsetpasswordactivity")
class NewSetPasswordActivity : NBaseActivity() {
    override fun setContentView(): Int {
        return R.layout.activity_new_version_set_pwd
    }

    lateinit var fingerprintManager: FingerprintManagerCompat

    var bean: RegStep2Bean? = null

    var account = ""
    var pwdContent = ""
    var pwdAgainContent = ""
    var index = 0
    var token = ""
    var numberCode = ""

    /**
     *Security verification defaults to Google
     *  Google 0
     *Mobile 1
     *Mailbox 2
     */
    var securityVerificationType = 0

    companion object {
        /**
         *@param account account
         *@param INDEX_ Status Set Password or Reset Password 0 Set Password 1 Reset Password
         */
        private const val ACCOUNT_NUM = "account_num"
        private const val INDEX_STATUS = "index_status"
        private const val INDEX_TOKEN = "index_token"
        private const val INDEX_NUMBER_CODE = "index_number_code"

        private const val PARAM = "param"

    }


    fun getData() {
        if (intent != null) {
            account = intent.getStringExtra(ACCOUNT_NUM) ?: ""
            token = intent.getStringExtra(INDEX_TOKEN) ?: ""
            numberCode = intent.getStringExtra(INDEX_NUMBER_CODE) ?: ""
            index = intent.getIntExtra(INDEX_STATUS, 0)
        }
    }

    override fun onInit(savedInstanceState: Bundle?) {
        super.onInit(savedInstanceState)
        initView()
    }


    override fun initView() {
        setBgFill2()
        fingerprintManager = FingerprintManagerCompat.from(this)
        getData()
        tv_info?.text = LanguageUtil.getString(this, "register_tip_agreement")
        tv_terms_service?.text = LanguageUtil.getString(this, "register_action_agreement")

        cet_pwd_view?.isFocusable = true
        cet_pwd_view?.isFocusableInTouchMode = true
        cet_pwd_view?.hint = LanguageUtil.getString(this, "password_input_rule_tips")
        cet_pwd_again_view?.isFocusable = true
        cet_pwd_again_view?.isFocusableInTouchMode = true

        cet_pwd_invite_code_view?.isFocusable = true
        cet_pwd_invite_code_view?.isFocusableInTouchMode = true

        cet_pwd_again_view?.hint = LanguageUtil.getString(this, "register_tip_repeatPassword")
        cet_pwd_invite_code_view?.hint = LanguageUtil.getString(this, "invite_code_hint")

        cet_pwd_view.title = LanguageUtil.getString(this, "personal_text_newPwd")
        cet_pwd_again_view.title = LanguageUtil.getString(this, "personal_text_confirmPwd")
        cet_pwd_invite_code_view.title = LanguageUtil.getString(this, "register_text_inviteCode")
        cubtn_view?.isEnable(false)


        /**
         *Configuration is
         */
        when (index) {
            0 -> {
                ll_tip?.visibility = View.GONE
                v_header?.titleText = LanguageUtil.getString(mActivity, "register_action_setPassword")
                cet_pwd_invite_code_view?.visibility = View.VISIBLE
                cubtn_view?.textContent = LanguageUtil.getString(mActivity, "register_action_register")
//Bean=intent GetParcelableExtra (PARAM)//This is a bug... I haven't noticed it for two years, and there's no feedback online. Kneeling down! Don't touch it.
                bean = intent?.getSerializableExtra(PARAM) as RegStep2Bean

                if (bean?.invitationCodeRequired == 0) {
                    cet_pwd_invite_code_view.title = LanguageUtil.getString(this, "register_text_inviteCode") + LanguageUtil.getString(this, "regitser_tip_inputOptional")
                    cet_pwd_invite_code_view?.hint = LanguageUtil.getString(mActivity, "invite_code_hint")
                } else {
                    cet_pwd_invite_code_view.title = LanguageUtil.getString(this, "common_tip_inviteCodeRequired")
                    cet_pwd_invite_code_view?.hint = LanguageUtil.getString(mActivity, "register_text_inviteCode")
                }
                cet_pwd_again_view.visibility = View.GONE
                /**
                 *Click on the service terms
                 */
                tv_terms_service?.setOnClickListener {
                    var bundle = Bundle()
                    bundle.putString(ParamConstant.head_title, LanguageUtil.getString(this, "register_action_agreement"))
                    bundle.putInt(ParamConstant.web_type, WebTypeEnum.AGREEMENT_USER.value)
                    bundle.putString(ParamConstant.web_url, "")
                    ArouterUtil.greenChannel(RoutePath.ItemDetailActivity, bundle)
                }

            }
            1 -> {
                val reset_tips=  String.format(LanguageUtil.getString(this, "password_reset_tips"),
                    PublicInfoDataService.getInstance().getSafeWithdrawHour(PublicInfoDataService.getInstance().getData(null)))

                v_header?.titleText = LanguageUtil.getString(mActivity, "login_action_resetPassword")
//                tv_reset_password?.text = LanguageUtil.getString(mActivity, "password_reset_tips")
                tv_sub_title?.text = reset_tips
                ll_tip?.visibility = View.VISIBLE
                tv_info?.visibility = View.GONE
                cet_pwd_invite_code_view?.visibility = View.GONE
                tv_terms_service?.visibility = View.GONE
                cubtn_view?.textContent = LanguageUtil.getString(mActivity, "common_text_btnConfirm")
            }
        }
        setOnclick()
        removeToken()
    }

    fun setOnclick() {

//        iv_cancel?.setOnClickListener { finish() }

        /**
         *Listen for the first password edittext
         */
        cet_pwd_view?.listener = object: BaseEditTextKit.OnKKBaseListener{
            override fun textChange(text: String) {
                pwdContent = text
                if (pwdContent.isNotEmpty() && index == 0) {
                    cubtn_view?.isEnable(true)
                } else {
                    if (pwdContent.isNotEmpty() && pwdAgainContent.isNotEmpty()) {
                        cubtn_view?.isEnable(true)
                    } else {
                        cubtn_view?.isEnable(false)
                    }
                }
            }

        }


        /**
         *Listen for the second password edittext
         */
        cet_pwd_again_view?.listener = object: BaseEditTextKit.OnKKBaseListener{
            override fun textChange(text: String) {
                pwdAgainContent = text
                if (pwdContent.isNotEmpty() && pwdAgainContent.isNotEmpty()) {
                    cubtn_view?.isEnable(true)
                } else {
                    cubtn_view?.isEnable(false)
                }
            }

        }


        /**
         *Click to confirm login
         */
        cubtn_view?.setOnClickListener{
            //0 Set Password 1 Reset Password
            //The process of setting passwords does not require adding double password verification
            //The process of resetting passwords requires adding double password verification
            if (index == 0) {
                if (!StringUtils.checkPass(pwdContent)) {
                    DisplayUtil.showSnackBar(window?.decorView, LanguageUtil.getString(mActivity, "login_tip_passwordRequire"), isSuc = false)
                    return@setOnClickListener
                }
            } else {
                /**
                 *Determine if the passwords are the same
                 */
                if (pwdContent == pwdAgainContent) {
                    if (!StringUtils.checkPass(pwdAgainContent)) {
                        DisplayUtil.showSnackBar(window?.decorView, LanguageUtil.getString(mActivity, "login_tip_passwordRequire"), isSuc = false)
                        return@setOnClickListener
                    }
                } else {
                    DisplayUtil.showSnackBar(window?.decorView, LanguageUtil.getString(mActivity, "login_tip_passwordNotMatch"), isSuc = false)
                    return@setOnClickListener
                }
            }
            when (index) {
                /**
                 *Registration
                 */
                0 -> {
                    /**
                     *Server return field is required if it is 1 invitation code
                     *0 invitation code optional
                     */
                    if (bean?.invitationCodeRequired == 1) {
                        if (TextUtils.isEmpty(cet_pwd_invite_code_view.getText().trim())) {
                            DisplayUtil.showSnackBar(window?.decorView, LanguageUtil.getString(mActivity, "common_tip_inputInviteCode"), false)
                            return@setOnClickListener
                        } else {
                            reg4Step3(account, pwdContent, cet_pwd_invite_code_view.getText())
                        }
                    } else {
                        reg4Step3(account, pwdContent, cet_pwd_invite_code_view.getText())
                    }
                }
                /**
                 *Forgot password
                 */
                1 -> {
                    findPwdStep4(token, pwdContent)
                }
            }
        }


    }

    /**
     *Retrieve Password Step 4: The actual third step in the new version has been removed, only the first, second, and third steps have been retained
     */
    private fun findPwdStep4(token: String, loginPword: String = "") {
        addDisposable(getMainModel().findPwdStep4(token, loginPword, object : NDisposableObserver(this, true) {
            override fun onResponseSuccess(jsonObject: JSONObject) {
                closeLoadingDialog()
                ArouterUtil.navigation("/login/NewVersionLoginActivity", null)
                var userInfo = LoginManager.getInstance().loginInfo
                userInfo.loginPwd = loginPword
                LoginManager.getInstance().saveLoginInfo(userInfo)
//DisplayUtil. showSnackBar (window?. ecorView, LanguageUtil. getString (mActivity, "Reset completed, will automatically redirect you..."), isSuc=true)
//                Toast.makeText(this@NewSetPasswordActivity, LanguageUtil.getString(this@NewSetPasswordActivity, LanguageUtil.getString(this@NewSetPasswordActivity,"set_password_completed_jumping")), Toast.LENGTH_SHORT).show()
                finish()
            }
//
//            override fun onResponseFailure(code: Int, msg: String?) {
//                super.onResponseFailure(code, msg)
//                NToastUtil.showTopToastNet(mActivity,false, LanguageUtil.getString(this@NewSetPasswordActivity, "account_action_token_expire_tip"))
//            }

        }))

    }


    /**
     *Register Step 3?
     *
     *@param registerCode, please note that the 'phone or email verification code' is filled in here
     */
    private fun reg4Step3(registerCode: String, loginPwd: String, invitedCode: String = "") {
        addDisposable(getMainModel().reg4Step3(registerCode = registerCode, loginPword = loginPwd, newPassword = loginPwd, invitedCode = invitedCode, consumer = object : NDisposableObserver(this, true) {
            override fun onResponseSuccess(jsonObject: JSONObject) {
                closeLoadingDialog()

                var json = jsonObject.optJSONObject("data") ?: return
                var token = json.optString("token") ?: ""
                UserDataService.getInstance().saveGesturePass("")
                UserDataService.getInstance().clearToken()
                UserDataService.getInstance().clearLoginState()
                LoginManager.getInstance().saveFingerprint(0)


                UserDataService.getInstance().saveToken(token)
                HttpClient.instance.setToken(token)
//                getMainModel().saveUserInfo()
                addDisposable(getMainModel().getUserInfo(MyNDisposableObserver()))
                var quicktoken = json?.optString("quicktoken") ?: ""
                UserDataService.getInstance().saveQuickToken(quicktoken)
                val loginAreaCodeCache = LoginManager.getInstance().loginAreaCodeCache
                if(!"".equals(loginAreaCodeCache)) LoginManager.getInstance().saveSelectCountryCode(loginAreaCodeCache)
                val loginInfo = LoginManager.getInstance().loginInfo
                loginInfo.account = registerCode
                LoginManager.getInstance().saveLoginInfo(loginInfo)
                /**
                 *Save Information
                 */
//                        val loginInfo = LoginManager.getInstance().loginInfo
//                        loginInfo.loginPwd = loginPwd
//                        LoginManager.getInstance().saveLoginInfo(loginInfo)

                //Quicktoken added in version 5.0 for direct login after registration
//                val quicktoken = jsonObject?.optString("quicktoken") ?: ""
//                UserDataService.getInstance().saveQuickToken(quicktoken)

//                DisplayUtil.showSnackBar(window?.decorView, LanguageUtil.getString(mActivity, "common_tip_registerSuccess"), isSuc = true)

                ActivityManager.popAllActFromStack()
                finish()
                KeyBoardUtils.closeKeyBoard(this@NewSetPasswordActivity)
            }

        }))

    }

    inner class MyNDisposableObserver() : NDisposableObserver(this, true) {
        override fun onResponseSuccess(jsonObject: JSONObject) {
            var json = jsonObject.optJSONObject("data")
            UserDataService.getInstance().saveData(json)
            getUserInfo(jsonObject)
        }

    }

    /**
     *Obtain user information
     */
    private fun getUserInfo(data: JSONObject?) {
        if (data == null) return

        var gesturePwd = data.optString("gesturePwd") ?: ""

        UserDataService.getInstance().saveData(data)

        var focusView = this.currentFocus

        /**
         *Determine if a gesture password has been set
         */
        if (!TextUtils.isEmpty(gesturePwd) && TextUtils.isEmpty(UserDataService.getInstance().gesturePass)) {
            UserDataService.getInstance().saveGesturePass(gesturePwd)
            SoftKeyboardUtil.hideSoftKeyboard(focusView)
            finish()
            return
        } else if (!TextUtils.isEmpty(gesturePwd) || !TextUtils.isEmpty(UserDataService.getInstance().gesturePass)) {
            SoftKeyboardUtil.hideSoftKeyboard(focusView)
            finish()
            return
        }


        /**
         *Determine if fingerprint is supported
         */
        if (fingerprintManager.isHardwareDetected) {
            /**
             *Determine whether to input fingerprints
             */
            if (fingerprintManager.hasEnrolledFingerprints()) {
                if (LoginManager.getInstance().fingerprint == 1) {
                    SoftKeyboardUtil.hideSoftKeyboard(focusView)
                    finish()
                    return
                }

                enter2GUdeGesture(2)
            } else {
                quickLogin()
            }
        } else {
            quickLogin()
        }
    }

    private fun enter2GUdeGesture(type: Int, handPwd: String = "") {
        SoftKeyboardUtil.hideSoftKeyboard(mActivity?.currentFocus)

        var bundle = Bundle()
        bundle.putInt("guidegesturetype", type)
        bundle.putString("guidegesturehandpwd", handPwd)
        ArouterUtil.navigation("/login/guidegesturepwdactivity", bundle)

        finish()
    }

    fun quickLogin() {
        var bundle = Bundle()
        bundle.putInt("SET_TYPE", 0)
        bundle.putBoolean("SET_STATUS", false)
        bundle.putBoolean("SET_LOGINANDSET", true)
        bundle.putString("SET_TOKEN", "")
        ArouterUtil.navigation("/login/gesturespasswordactivity", bundle)
    }

    var disposable: Disposable? = null

    /**
     *Delete the token and destroy the page in 5 minutes
     */
    fun removeToken() {
        Observable.interval(5, TimeUnit.MINUTES)
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(object : Observer<Long> {
                    override fun onNext(aLong: Long) {
                        Log.d("====onNext=====", "=====count:===along:$aLong")
                        if (disposable != null && !disposable?.isDisposed!!) {
                            disposable?.dispose()
                        }
                        finish()
                        ActivityManager.popAllActFromStack()
                        ArouterUtil.greenChannel("/login/newversionregisteractivity", null)
                        DisplayUtil.showSnackBar(window?.decorView, LanguageUtil.getString(mActivity, "new_register_time_out"), isSuc = false)
                    }

                    override fun onSubscribe(d: Disposable) {
                        Log.d("=========", "====onSubscribe====")
                        disposable = d
                    }


                    override fun onError(e: Throwable) {
                        Log.d("========", "===onError")

                    }

                    override fun onComplete() {
                        Log.d("========", "===onComplete")

                    }
                })
    }

    override fun onDestroy() {
        super.onDestroy()
        cancel()
    }


    fun cancel() {
        if (disposable != null && !disposable?.isDisposed()!!) {
            disposable?.dispose()
        }
    }


}
