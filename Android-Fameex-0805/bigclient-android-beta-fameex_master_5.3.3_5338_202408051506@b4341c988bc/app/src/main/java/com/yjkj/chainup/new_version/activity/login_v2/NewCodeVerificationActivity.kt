package com.yjkj.chainup.new_version.activity.login_v2

import android.os.Bundle
import androidx.core.hardware.fingerprint.FingerprintManagerCompat
import android.text.TextUtils
import android.view.KeyEvent
import android.view.View
import com.alibaba.android.arouter.facade.annotation.Route
import com.yjkj.chainup.R
import com.yjkj.chainup.base.NBaseActivity
import com.yjkj.chainup.db.constant.RoutePath
import com.yjkj.chainup.db.service.UserDataService
import com.yjkj.chainup.extra_service.arouter.ArouterUtil
import com.yjkj.chainup.manager.LanguageUtil
import com.yjkj.chainup.manager.LoginManager
import com.yjkj.chainup.net.HttpClient
import com.yjkj.chainup.net_new.rxjava.NDisposableObserver
import com.yjkj.chainup.new_version.activity.FindPwd2verifyActivity
import com.yjkj.chainup.new_version.dialog.NewDialogUtils
import com.yjkj.chainup.new_version.view.ComVerifyView
import com.yjkj.chainup.new_version.view.CommonlyUsedButton
import com.yjkj.chainup.util.DisplayUtil
import com.yjkj.chainup.util.KeyBoardUtils
import com.yjkj.chainup.util.SoftKeyboardUtil
import kotlinx.android.synthetic.main.activity_new_version_phone_verification_type.*
import org.json.JSONObject

/**
 * @Author lianshangljl
 * @Date 2023/3/13-10:26 AM
 * @Email buptjinlong@163.com
 *@description Mobile phone or email verification or Google verification
 */
@Route(path = RoutePath.NewVersionCodeActivity)
class NewCodeVerificationActivity : NBaseActivity() {
    override fun setContentView(): Int {
        return R.layout.activity_new_version_phone_verification_type
    }

    /**
     *Security verification defaults to Google
     *  Google 0
     *Mobile 1
     *Mailbox 2
     */
    var statusPosition = 0

    var isLogin = 0

    /**
     *Account
     */
    var account = ""

    /**
     *Verification code
     */
    var code = ""

    /**
     * token
     */
    var token = ""

    /**
     *Country code
     */
    var countryCode = "86"

    /**
     *Fingerprint
     */
    lateinit var fingerprintManager: FingerprintManagerCompat

    var verificationType = ""

    var googleAuth = ""

    var arrayParams = HashMap<String, String>()

    companion object {
        const val GOOGLE_VERIFY = 0

        const val MOBiLE_VERIFY = 1

        const val EMAIL_VERIFY = 2

        const val FINDPWDSTEP2_TYPE = 1
        const val CONFIRMLOGIN_TYPE = 2
        const val LOGININFORMATION_TYPE = 3
        const val GETUSERINFO_TYPE = 4
        const val CHECKLOCALPWD_TYPE = 5
        const val REG4STEP2_TYPE = 6
        const val GETTOKEN4PWD_TYPE = 7


        const val SEND_POSITION = "send_position"
        const val SEND_ISLOGIN = "send_islogin"
        const val SEND_ACCOUNT = "send_account"
        const val SEND_TOKEN = "send_token"
        const val SEND_COUNTRYCODE = "send_countryCode"
        const val SEND_VERFITIONTYPE = "send_verifitionType"
        const val SEND_GOOGLEAUTH = "send_googleAuth"


        /**
         *@param account account
         *@param position 0 Google verification 1 is mobile verification 2 is email verification
         *@param isLogin is login 0 is login 1 is registration 2 is security verification (forgotten password) 3 is password reset
         *@param countryCode Country Code
         */

    }


    fun getData() {
        if (intent != null) {
            statusPosition = intent.getIntExtra(SEND_POSITION, 0)
            isLogin = intent.getIntExtra(SEND_ISLOGIN, 0)
            account = intent.getStringExtra(SEND_ACCOUNT) ?: ""
            token = intent.getStringExtra(SEND_TOKEN) ?: ""
            countryCode = intent.getStringExtra(SEND_COUNTRYCODE) ?: "86"
            try {
                verificationType = intent.getStringExtra(SEND_VERFITIONTYPE) ?: ""
                googleAuth = intent.getStringExtra(SEND_GOOGLEAUTH) ?: ""
            } catch (e: Exception) {
                e.printStackTrace()
            }
            if (verificationType.isEmpty()) {
                verificationType = "4,1"
            }
        }
    }

    override fun onInit(savedInstanceState: Bundle?) {
        super.onInit(savedInstanceState)
        initView()
        setTextContent()
    }


    override fun onKeyDown(keyCode: Int, event: KeyEvent?): Boolean {
        if (keyCode == KeyEvent.KEYCODE_BACK) {
            UserDataService.getInstance().clearToken()
        }
        return super.onKeyDown(keyCode, event)
    }

    fun setTextContent() {
        tv_title.text = LanguageUtil.getString(this, "login_action_fogetpwdSafety")
        tv_send_verification_code?.text = LanguageUtil.getString(this, "login_tip_didSendCode")
        cubtn_view?.setBottomTextContent(LanguageUtil.getString(this, "common_action_next"))
    }

    override fun initView() {

        fingerprintManager = FingerprintManagerCompat.from(this)
        getData()
        setOnClick()
        cubtn_view?.isEnable(false)

        val array = verificationType.split(",")
        val typeCode1 = array.get(0)
        arrayParams.put(typeCode1, "")
        cet_view.loginTypeToBean(typeCode1, token)
        if (array.size == 2) {
            val typeCode2 = array.get(1)
            cet_view_two.loginTypeToBean(typeCode2, token)
            arrayParams.put(typeCode2, "")
            cet_view_two.visibility = View.VISIBLE
        } else {
            cet_view_two.visibility = View.GONE
        }

    }

    fun setOnClick() {
        iv_cancel?.setOnClickListener {
            UserDataService.getInstance().clearToken()
            finish()
        }

        cet_view?.onTextListener = object : ComVerifyView.OnTextListener {
            override fun showText(text: String): String {
                code = text
                checkBtn()
                return text
            }
        }
        cet_view_two?.onTextListener = object : ComVerifyView.OnTextListener {
            override fun showText(text: String): String {
                code = text
                checkBtn()
                return text
            }
        }

        cubtn_view?.listener = object : CommonlyUsedButton.OnBottonListener {
            override fun bottonOnClick() {
                setLoginStatus()
            }

        }

    }

    fun setLoginStatus() {
        when (isLogin) {
            0 -> {
                showLoadingDialog()
                addDisposable(getMainModel().confirmLoginV2(arrayParams, token, consumer = MyNDisposableObserver(CONFIRMLOGIN_TYPE)))
            }
            1 -> {
                addDisposable(getMainModel().reg4Step2(account, cet_view.code, consumer = MyNDisposableObserver(REG4STEP2_TYPE)))

            }
            2 -> {
                addDisposable(getMainModel().findPwdStep2(token, code, "", "", "", "", "", consumer = MyNDisposableObserver(FINDPWDSTEP2_TYPE)))
            }
            else -> {
                val bundle = Bundle()
                bundle.putString("account_num", account)
                bundle.putInt("index_status", 0)
                bundle.putString("index_token", token)
                bundle.putString("index_number_code", "")
                bundle.putString("param", "")
                ArouterUtil.navigation("/login/newsetpasswordactivity", bundle)
            }
        }

    }

    inner class MyNDisposableObserver(type: Int) : NDisposableObserver(this, true) {
        var reqType = type

        override fun onResponseSuccess(jsonObject: JSONObject) {
            var json = jsonObject.optJSONObject("data")
            when (reqType) {
                FINDPWDSTEP2_TYPE -> {
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
                CONFIRMLOGIN_TYPE -> {
                    /**
                     * {"code":"0","msg":"suc","data":null}
                     */
                    UserDataService.getInstance().saveToken(token)
                    HttpClient.instance.setToken(token)
                    getMainModel().saveUserInfo()
                    addDisposable(getMainModel().getUserInfo(MyNDisposableObserver(GETUSERINFO_TYPE)))
                    /**
                     *Login successful
                     */
                    DisplayUtil.showSnackBar(window?.decorView, LanguageUtil.getString(mActivity, "login_tip_loginsuccess"), isSuc = true)

                    KeyBoardUtils.closeKeyBoard(this@NewCodeVerificationActivity)

                }
                LOGININFORMATION_TYPE -> {

                }
                GETUSERINFO_TYPE -> {
                    closeLoadingDialog()
                    getUserInfo(json)
                }
                CHECKLOCALPWD_TYPE -> {

                }
                REG4STEP2_TYPE -> {
                    var numberCode = getType(statusPosition).toString()
                    val bundle = Bundle()
                    bundle.putString("account_num", account)
                    bundle.putInt("index_status", 0)
                    bundle.putString("index_token", "")
                    bundle.putString("index_number_code", numberCode)
                    bundle.putString("param", json.toString())
                    ArouterUtil.navigation("/login/newsetpasswordactivity", bundle)
                    finish()
                }
                GETTOKEN4PWD_TYPE -> {

                }
            }


        }

        override fun onResponseFailure(code: Int, msg: String?) {
            super.onResponseFailure(code, msg)
            closeLoadingDialog()
            when (reqType) {
                CONFIRMLOGIN_TYPE -> {
                    DisplayUtil.showSnackBar(v_container, msg, isSuc = false)
                }
                GETUSERINFO_TYPE -> {
                    finish()
                }
            }

        }

    }


    fun getType(index: Int): Int {
        var type = 1
        when (index) {
            0 -> {
                type = 1
            }
            1 -> {
                type = 2
            }
            2 -> {
                type = 3
            }
        }
        return type
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
        showDialog()
        if (!TextUtils.isEmpty(gesturePwd) && TextUtils.isEmpty(UserDataService.getInstance().gesturePass)) {
            UserDataService.getInstance().saveGesturePass(gesturePwd)
            SoftKeyboardUtil.hideSoftKeyboard(focusView)
            return
        } else if (!TextUtils.isEmpty(gesturePwd) || !TextUtils.isEmpty(UserDataService.getInstance().gesturePass)) {
            SoftKeyboardUtil.hideSoftKeyboard(focusView)
            return
        }
    }

    private fun checkBtn() {
        var text1 = cet_view.code.trim()
        var text2 = cet_view_two.code.trim()
        val array = verificationType.split(",")
        val typeCode1 = array.get(0)
        arrayParams.put(typeCode1, text1)
        if (array.size == 2) {
            val typeCode2 = array.get(1)
            arrayParams.put(typeCode2, text2)
        }
        var isEnable = text1.isNotEmpty() && (if (arrayParams.size == 1) true else text2.isNotEmpty())
        cubtn_view.isEnable(isEnable)
    }

    private fun showDialog() {
        NewDialogUtils.loginTypeDialog(this, object : NewDialogUtils.DialogTransferBottomListener {
            override fun sendConfirm() {
                ArouterUtil.navigation(RoutePath.PersonalCenterActivity, null)
                finish()
            }

            override fun showCancel() {
                finish()
            }

        }, "", googleAuth)
    }

}
