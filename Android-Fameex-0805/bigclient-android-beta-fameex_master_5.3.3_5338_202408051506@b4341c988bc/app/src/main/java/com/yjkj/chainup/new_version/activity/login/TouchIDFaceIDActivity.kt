package com.yjkj.chainup.new_version.activity.login

import android.annotation.SuppressLint
import android.app.Activity
import android.content.DialogInterface
import android.hardware.biometrics.BiometricPrompt
import android.hardware.fingerprint.FingerprintManager
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.os.Message
import androidx.core.hardware.fingerprint.FingerprintManagerCompat
import androidx.core.os.CancellationSignal
import android.text.TextUtils
import android.util.Log
import android.view.View
import com.alibaba.android.arouter.facade.annotation.Route
import com.google.gson.JsonObject
 import com.chainup.contract.view.dialog.CpTDialog
import com.chainup.kit.views.PublicHeaderKit
import com.yjkj.chainup.R
import com.yjkj.chainup.base.NBaseActivity
import com.yjkj.chainup.db.constant.ParamConstant
import com.yjkj.chainup.db.service.UserDataService
import com.yjkj.chainup.extra_service.arouter.ArouterUtil
import com.yjkj.chainup.manager.LanguageUtil
import com.yjkj.chainup.manager.LoginManager
import com.yjkj.chainup.net.HttpClient
import com.yjkj.chainup.net.retrofit.NetObserver
import com.yjkj.chainup.net_new.rxjava.NDisposableObserver
import com.yjkj.chainup.new_version.dialog.DialogUtil
import com.yjkj.chainup.util.CryptoObjectHelper
import com.yjkj.chainup.util.DisplayUtil
import com.yjkj.chainup.util.NToastUtil
import com.yjkj.chainup.util.ToastUtils
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.schedulers.Schedulers
import kotlinx.android.synthetic.main.activity_safety_setting.switch_fingerprint_pwd
import kotlinx.android.synthetic.main.activity_touch_idface_id.*
import org.json.JSONObject

/**
 * @author Bertking
 * @Date 2023-11-16
 *@description Fingerprint recognition&facial recognition (TODO)
 */
@Route(path = "/login/touchidfaceidactivity")
class TouchIDFaceIDActivity : NBaseActivity() {
    override fun setContentView(): Int {
        return R.layout.activity_touch_idface_id
    }

    var type = FINGERPRINT
    var isFirstLogin = false

    lateinit var fingerprintManager: FingerprintManagerCompat
    var cancellationSignal: CancellationSignal? = null
    var authCallBack: AuthCallBack? = null
    var tDialog:  CpTDialog? = null

    private var mBiometricPrompt: BiometricPrompt? = null
    private var mAuthenticationCallback: BiometricPrompt.AuthenticationCallback? = null
    private var mCancellationSignal: android.os.CancellationSignal? = null

    var handler = @SuppressLint("HandlerLeak")
    object : Handler(Looper.getMainLooper()) {
        override fun handleMessage(msg: Message) {
            super.handleMessage(msg)

            when (msg?.what) {
                FingerprintActivity.MSG_AUTH_SUCCESS -> {
//TV_ Result. text="Fingerprint recognition successful"
                    authSuccess()
                }

                FingerprintActivity.MSG_AUTH_FAILED -> {
                    ToastUtils.showToast(LanguageUtil.getString(mActivity, "open_failure"))
                }

                FingerprintActivity.MSG_AUTH_ERROR -> {
//TV_ Result. text="Authorization failed"
                    handlerErrorCode(msg.arg1)
                }

                FingerprintActivity.MSG_AUTH_HELP -> {
//TV_ Result. text="Authorization Help"
                    handleHelpCode(msg.arg1)
                }


            }
        }
    }

    private fun authSuccess() {
//        tDialog?.dismiss()
        tDialog?.dismissAllowingStateLoss()
        /**
         *Execute Quick Login Interface
         */
        if (isFirstLogin) {
            /**
             *This is the first login from the fingerprint settings
             */
            ToastUtils.showToast(LanguageUtil.getString(mActivity, "open_suc"))
            LoginManager.getInstance().saveFingerprint(1)
            finish()
        } else {
            /**
             *Entering during fingerprint login
             */
            if (!TextUtils.isEmpty(UserDataService.getInstance().quickToken)) {
//                            ToastUtils.showToast(LanguageUtil.getString(mActivity, "open_suc"))
                quickLogin(UserDataService.getInstance().quickToken)
            } else {
                LoginManager.getInstance().saveFingerprint(0)
                ArouterUtil.navigation("/login/NewVersionLoginActivity", null)
                finish()
            }
        }
    }

    companion object {

        const val TYPE = "type"

        /**
         *Fingerprint recognition
         */
        const val FINGERPRINT = 0


        /**
         *Facial recognition
         */
        const val FACEID = 1

        const val ISFIRSTLOGIN = "is_first_login"

        const val PATH_KEY = "/login/touchidfaceidactivity"

        fun enter2(type: Int = FINGERPRINT, status: Boolean) {
            val bundle = Bundle()
            bundle.putInt(TYPE, type)
            bundle.putBoolean(ISFIRSTLOGIN, status)
            ArouterUtil.navigation(PATH_KEY, bundle)
        }

    }

    private fun initFingerPrintManager() {
        fingerprintManager = FingerprintManagerCompat.from(this)
        if (!fingerprintManager.isHardwareDetected) {
            DisplayUtil.showSnackBar(window?.decorView, LanguageUtil.getString(mActivity, "hardware_not_recognition"), isSuc = false)
        } else if (!fingerprintManager.hasEnrolledFingerprints()) {
            DisplayUtil.showSnackBar(window?.decorView, LanguageUtil.getString(mActivity, "no_fingerprints_were_entered"), isSuc = false)
        } else {
            try {
                authCallBack = AuthCallBack(handler)
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }

        var cryptoObjectHelper = CryptoObjectHelper()
        if (cancellationSignal == null) {
            cancellationSignal = CancellationSignal()
        }
        if (authCallBack == null) return
//        try {
//            fingerprintManager.authenticate(cryptoObjectHelper.buildCryptoObject(), 0, cancellationSignal
//                    ?: return, authCallBack
//                    ?: return, null)
//        } catch (e: Exception) {
//            e.printStackTrace()
//        }
        startBiometricAuth()


    }


    private fun startBiometricAuth() {
        //创建一个生物识别的对话框，
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            mBiometricPrompt= BiometricPrompt.Builder(this)
                .setTitle(LanguageUtil.getString(this,"login_text_fingerprint"))
                .setDescription(LanguageUtil.getString(this,"login_via_fingerprint"))
                .setNegativeButton(LanguageUtil.getString(this,"common_text_btnCancel"),mainExecutor, object : DialogInterface.OnClickListener {
                    override fun onClick(dialog: DialogInterface?, which: Int) {
                        mCancellationSignal?.cancel()
                        tDialog?.dismissAllowingStateLoss()
                    }
                })
                .build()
            mAuthenticationCallback=object : BiometricPrompt.AuthenticationCallback() {
                override fun onAuthenticationError(errorCode: Int, errString: CharSequence?) {
                    super.onAuthenticationError(errorCode, errString)
                    Log.i(TAG, "onAuthenticationError: ${errString}")
                }

                override fun onAuthenticationHelp(helpCode: Int, helpString: CharSequence?) {
                    super.onAuthenticationHelp(helpCode, helpString)
                    Log.i(TAG, "onAuthenticationHelp: ${helpString}")
                }

                override fun onAuthenticationSucceeded(result: BiometricPrompt.AuthenticationResult?) {
                    super.onAuthenticationSucceeded(result)
                    authSuccess()
                }

                override fun onAuthenticationFailed() {
                    super.onAuthenticationFailed()
                    Log.i(TAG, "onAuthenticationFailed: ")
                }
            }
            //每次调用authenticate时都必须传入一个新的CancellationSignal对象，否则会抛出异常
            mCancellationSignal= android.os.CancellationSignal()
            mCancellationSignal?.setOnCancelListener {
                //主动取消后的逻辑,调用cancellationSignal.cancel()时会走这里
            }
            mCancellationSignal?.apply {
                mBiometricPrompt?.authenticate(
                    mCancellationSignal!!,mainExecutor,
                    mAuthenticationCallback!!
                )
            }
        }else{
            val cryptoObjectHelper = CryptoObjectHelper()
            cancellationSignal = CancellationSignal()
            try{
                fingerprintManager.authenticate(cryptoObjectHelper.buildCryptoObject(),0,cancellationSignal?:return,
                    authCallBack?:return,null)
            }catch (e: java.lang.Exception){
                e.printStackTrace()
            }
        }
    }

    override fun onInit(savedInstanceState: Bundle?) {
        super.onInit(savedInstanceState)
        initView()
        setTextContent()
    }

    fun setTextContent() {
        ib_back?.text = LanguageUtil.getString(this, "common_text_btnCancel")
        btn_account_login?.text = LanguageUtil.getString(this, "login_action_otherAccount")
    }


    override fun initView() {
        type = intent?.getIntExtra(TYPE, FINGERPRINT) ?: FINGERPRINT
        isFirstLogin = intent?.getBooleanExtra(ISFIRSTLOGIN, false) ?: false
        initFingerPrintManager()


        tDialog = DialogUtil.showFingerprintOrFaceIDDialog(this)


        var userinfo = UserDataService.getInstance().userData
        var mobileNumber = userinfo.optString("mobileNumber")
        var email = userinfo.optString("email")
        when (type) {
            FINGERPRINT -> {
                tv_recognition_title.text = LanguageUtil.getString(mActivity, "fingerprint_recognition")
                tv_recognition_tips.text = LanguageUtil.getString(mActivity, "tap_to_fingerprint")
                iv_recognition.setImageResource(R.drawable.fingerprint)
            }

            FACEID -> {
                tv_recognition_title.text = LanguageUtil.getString(mActivity, "face_recongnition")
                tv_recognition_tips.text = LanguageUtil.getString(mActivity, "tap_to_face")
                iv_recognition.setImageResource(R.drawable.faceid)
            }
        }
        if (userinfo != null) {
            if (mobileNumber.isNotEmpty()) {
                tv_recognition_title.text = mobileNumber
            } else if (email.isNotEmpty()) {
                tv_recognition_title.text = email
            }
        }
        initOnClicker()
    }


    override fun onResume() {
        super.onResume()
        if (cancellationSignal == null) {
            var cryptoObjectHelper = CryptoObjectHelper()
            cancellationSignal = CancellationSignal()
            if (authCallBack == null) return
//            try {
//                fingerprintManager.authenticate(cryptoObjectHelper.buildCryptoObject(), 0, cancellationSignal
//                        ?: return, authCallBack
//                        ?: return, null)
//            } catch (e: Exception) {
//                e.printStackTrace()
//            }
            startBiometricAuth()

        }
    }

    override fun onPause() {
        super.onPause()
        if (cancellationSignal != null) {
            cancellationSignal?.cancel()
            cancellationSignal = null
        }
    }


    private fun initOnClicker() {
        title_layout?.listener=object : PublicHeaderKit.IOnBackClickListener {
            override fun onRightBtn(view: View) {
                super.onRightBtn(view)
                cancellationSignal?.cancel()
                finish()
            }
        }

        ib_back.setOnClickListener {
            cancellationSignal?.cancel()
            finish()
        }


        iv_recognition.setOnClickListener {
            when (type) {
                FINGERPRINT -> {
                    var cryptoObjectHelper = CryptoObjectHelper()
                    if (cancellationSignal == null) {
                        cancellationSignal = CancellationSignal()
                    }

//                    try {
//                        fingerprintManager.authenticate(cryptoObjectHelper.buildCryptoObject(), 0, cancellationSignal
//                                ?: return@setOnClickListener, authCallBack
//                                ?: return@setOnClickListener, null)
//                    } catch (e: Exception) {
//                        e.printStackTrace()
//                    }
                    startBiometricAuth()
                    tDialog?.show()
                }

                FACEID -> {
//                    DialogUtil.showFingerprintOrFaceIDDialog(context, title = "", tips = "")
                }
            }
        }

        tv_title_touch.setOnClickListener {
            when (type) {
                FINGERPRINT -> {
                    var cryptoObjectHelper = CryptoObjectHelper()
                    if (cancellationSignal == null) {
                        cancellationSignal = CancellationSignal()
                    }

//                    try {
//                        fingerprintManager.authenticate(cryptoObjectHelper.buildCryptoObject(), 0, cancellationSignal
//                                ?: return@setOnClickListener, authCallBack
//                                ?: return@setOnClickListener, null)
//                    } catch (e: Exception) {
//                        e.printStackTrace()
//                    }
                    startBiometricAuth();
                    tDialog?.show()
                }

                FACEID -> {
//                    DialogUtil.showFingerprintOrFaceIDDialog(context, title = "", tips = "")
                }
            }
        }

        /**
         *Account login
         */
        btn_account_login.setOnClickListener {
            finish()
            cancellationSignal?.cancel()
            ArouterUtil.navigation("/login/NewVersionLoginActivity", null)
        }
    }


    private fun handleHelpCode(code: Int) {
        when (code) {
            FingerprintManager.FINGERPRINT_ACQUIRED_GOOD -> {
                DisplayUtil.showSnackBar(window?.decorView, LanguageUtil.getString(mActivity, "fingerprint_complete"), isSuc = false)
            }
            /**
             *Fingerprints are inaccurate (dirty)
             */
            FingerprintManager.FINGERPRINT_ACQUIRED_IMAGER_DIRTY -> {
                DisplayUtil.showSnackBar(window?.decorView, LanguageUtil.getString(mActivity, "fingerprints_too_fuzzy"), isSuc = false)
            }
            /**
             *Fingerprints are inaccurate or there is a problem with the sensor
             */
            FingerprintManager.FINGERPRINT_ACQUIRED_INSUFFICIENT -> {
                DisplayUtil.showSnackBar(window?.decorView, LanguageUtil.getString(mActivity, "fingerprint_blur_or_sensor_blur"), isSuc = false)
            }
            /**
             *Incomplete fingerprint
             */
            FingerprintManager.FINGERPRINT_ACQUIRED_PARTIAL -> {
                DisplayUtil.showSnackBar(window?.decorView, LanguageUtil.getString(mActivity, "Incomplete_fingerprint"), isSuc = false)

            }
            /**
             *Too fast to identify fingerprints
             */
            FingerprintManager.FINGERPRINT_ACQUIRED_TOO_FAST -> {
                DisplayUtil.showSnackBar(window?.decorView, LanguageUtil.getString(mActivity, "moving_too_fast"), isSuc = false)
            }
            /**
             *Too slow to identify fingerprints
             */
            FingerprintManager.FINGERPRINT_ACQUIRED_TOO_SLOW -> {
                DisplayUtil.showSnackBar(window?.decorView, LanguageUtil.getString(mActivity, "cannot_read_fingerprint"), isSuc = false)
            }
        }
    }


    fun handlerErrorCode(code: Int) {
        when (code) {
            /**
             *Cancel
             */
            FingerprintManager.FINGERPRINT_ERROR_CANCELED -> {
//                DisplayUtil.showSnackBar(window?.decorView, LanguageUtil.getString(mActivity, "defingerprinting"), isSuc = false)
            }

            /**
             *Unavailable
             */
            FingerprintManager.FINGERPRINT_ERROR_HW_UNAVAILABLE -> {
                DisplayUtil.showSnackBar(window?.decorView, LanguageUtil.getString(mActivity, "hardware_error"), isSuc = false)
            }

            /**
             *Error 5 times, locked
             */
            FingerprintManager.FINGERPRINT_ERROR_LOCKOUT -> {
                ArouterUtil.navigation("/login/NewVersionLoginActivity", null)
                DisplayUtil.showSnackBar(window?.decorView, LanguageUtil.getString(mActivity, "error_more_5"), isSuc = false)
                finish()
            }

            /**
             *Supported but set with incomplete fingerprints
             */
            FingerprintManager.FINGERPRINT_ERROR_NO_SPACE -> {
                DisplayUtil.showSnackBar(window?.decorView, LanguageUtil.getString(mActivity, "fingerprint_incomplete"), isSuc = false)
            }

            /**
             *Identification timeout
             */
            FingerprintManager.FINGERPRINT_ERROR_TIMEOUT -> {
                DisplayUtil.showSnackBar(window?.decorView, LanguageUtil.getString(mActivity, "fingerprint_identification_timeout"), isSuc = false)
            }

            /**
             *The sensor cannot process the current fingerprint
             */
            FingerprintManager.FINGERPRINT_ERROR_UNABLE_TO_PROCESS -> {
                DisplayUtil.showSnackBar(window?.decorView, LanguageUtil.getString(mActivity, "cannot_handle_the_current_fingerprint"), isSuc = false)
            }


        }
    }


    private fun quickLogin(quicktoken: String) {
        showLoadingDialog()
        HttpClient.instance.newQuickLogin(quicktoken)
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(object : NetObserver<JsonObject>() {
                    override fun onHandleSuccess(jsonObject: JsonObject?) {
                        closeLoadingDialog()
                        ArouterUtil.refreshWebview()
                        val token = jsonObject!!.get("token").asString
                        UserDataService.getInstance().saveToken(token)
                        HttpClient.instance.setToken(token)
                        getUserInfo()
                        setResult(Activity.RESULT_OK)
                        finish()
                    }

                    override fun onHandleError(code: Int, msg: String?) {
                        super.onHandleError(code, msg)
                        NToastUtil.showTopToastNet(this@TouchIDFaceIDActivity,false, msg)
                        if (code == ParamConstant.QUICK_LOGIN_FAILURE
                            || code == ParamConstant.QUICK_LOGIN_FAILURE_EXPAND
                            || code==ParamConstant.QUICK_LOGIN_FAILURE_DESTROY
                            || code==ParamConstant.LOGIN_EXPIRE
                        ) {
                            UserDataService.getInstance().saveQuickToken("")
                            ArouterUtil.navigation("/login/NewVersionLoginActivity", null)
                            finish()
                        }
                        closeLoadingDialog()

                    }
                })


    }


    /**
     *Obtain user information
     */
    private fun getUserInfo() {

        addDisposable(getMainModel().getUserInfo(object : NDisposableObserver() {
            override fun onResponseSuccess(jsonObject: JSONObject) {
                var json = jsonObject.optJSONObject("data")
                var gesturePwd = json.optString("gesturePwd")
                UserDataService.getInstance().saveData(json)
                if (!TextUtils.isEmpty(gesturePwd) && TextUtils.isEmpty(UserDataService.getInstance().gesturePass)) {
                    UserDataService.getInstance().saveGesturePass(gesturePwd)
                }
            }
        }))


    }
}
