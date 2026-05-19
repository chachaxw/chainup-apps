package com.yjkj.chainup.new_version.activity.personalCenter

import android.content.DialogInterface
import android.content.Intent
import android.graphics.Color
import android.hardware.biometrics.BiometricPrompt
import android.hardware.fingerprint.FingerprintManager
import android.os.*
import androidx.core.hardware.fingerprint.FingerprintManagerCompat
import android.text.TextUtils
import android.util.Log
import android.view.View
import android.widget.CompoundButton
import android.widget.CompoundButton.OnCheckedChangeListener
import android.widget.Toast
import androidx.annotation.RequiresApi
import androidx.core.content.ContextCompat
import androidx.core.os.CancellationSignal
import com.alibaba.android.arouter.facade.annotation.Route
import com.blankj.utilcode.util.GsonUtils
import com.chainup.contract.utils.ChainUpLogUtil
import com.yjkj.chainup.util.JsonUtils
import com.google.gson.JsonObject
 import com.chainup.contract.view.dialog.CpTDialog
import com.chainup.kit.KKDialogUtils
import com.chainup.kit.dialog.KKTDialog
import com.chainup.kit.dialog.security.KKSecurityEnum
import com.chainup.kit.dialog.security.KKSecurityRule
import com.chainup.kit.utils.ToastUtils
import com.google.gson.Gson
import com.yjkj.chainup.R
import com.yjkj.chainup.app.AppConstant
import com.yjkj.chainup.bean.UserInfoData
import com.yjkj.chainup.db.constant.ParamConstant
import com.yjkj.chainup.db.constant.RoutePath
import com.yjkj.chainup.db.service.PublicInfoDataService
import com.yjkj.chainup.db.service.UserDataService
import com.yjkj.chainup.extra_service.arouter.ArouterUtil
import com.yjkj.chainup.extra_service.eventbus.MessageEvent
import com.yjkj.chainup.manager.LanguageUtil
import com.yjkj.chainup.manager.LoginManager
import com.yjkj.chainup.model.model.MainModel
import com.yjkj.chainup.net.HttpClient
import com.yjkj.chainup.net.api.HttpResult
import com.yjkj.chainup.net.retrofit.NetObserver
import com.yjkj.chainup.net_new.rxjava.NDisposableObserver
import com.yjkj.chainup.new_version.activity.AccountDestroyActivity
import com.yjkj.chainup.new_version.activity.NewBaseActivity
import com.yjkj.chainup.new_version.activity.TitleShowListener
import com.yjkj.chainup.new_version.activity.login.AuthCallBack
import com.yjkj.chainup.new_version.activity.login.FingerprintActivity
import com.yjkj.chainup.new_version.dialog.DialogUtil
import com.yjkj.chainup.new_version.dialog.NewDialogUtils
import com.yjkj.chainup.securityVerifyRule.VerifyRule2
import com.yjkj.chainup.util.CryptoObjectHelper
import com.yjkj.chainup.util.DisplayUtil
import com.yjkj.chainup.util.Utils
import com.yjkj.chainup.util.tr
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.disposables.Disposable
import io.reactivex.schedulers.Schedulers
import kotlinx.android.synthetic.main.activity_safety_setting.*
import org.json.JSONObject
import java.lang.Exception

/**
 * @author bertking
 * @Date 2023,5,21
 *@description Security Settings
 */
@Route(path = RoutePath.SafetySettingActivity)
class SafetySettingActivity : NewBaseActivity(),OnCheckedChangeListener {

    lateinit var fingerprintManager: FingerprintManagerCompat

    var cancellationSignal: CancellationSignal? = null

    private var fingerCheckSwitchStatus:Boolean? = null

    private var mcallBack:AuthCallBack? = null

    private var fingerDialog :CpTDialog? = null

    private val mainModel:MainModel by lazy { MainModel() }

    private var modelDisposable:Disposable? = null
    private var mBiometricPrompt: BiometricPrompt? = null
    private var mAuthenticationCallback: BiometricPrompt.AuthenticationCallback? = null
    private var mCancellationSignal: android.os.CancellationSignal? = null

    private val mHandler : Handler = object : Handler(Looper.getMainLooper()){
        override fun handleMessage(msg: Message) {
            super.handleMessage(msg)
            println("msg.what = ${msg.what}")
            when(msg.what){
                FingerprintActivity.MSG_AUTH_SUCCESS -> {
                    if(fingerCheckSwitchStatus==null) return
                    if (fingerCheckSwitchStatus as Boolean) {
                        DisplayUtil.showSnackBar(window?.decorView, LanguageUtil.getString(this@SafetySettingActivity, "common_tip_addSuccess"), isSuc = true)
                        val fingerprint = 1
                        LoginManager.getInstance().saveFingerprint(fingerprint)
                        switch_fingerprint_pwd.isChecked = LoginManager.getInstance().fingerprint == fingerprint
                        setViewSelect(switch_fingerprint_pwd, LoginManager.getInstance().fingerprint == fingerprint)
                    } else {
                        LoginManager.getInstance().saveFingerprint(0)
                        setViewSelect(switch_fingerprint_pwd, LoginManager.getInstance().fingerprint == 1)
                    }

                    fingerDialog?.dismiss()
                }
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_safety_setting)
        context = this
        fingerprintManager = FingerprintManagerCompat.from(context)
        initOnClickListener()
        listener = object : TitleShowListener {
            override fun TopAndBottom(status: Boolean) {
                title_layout.slidingShowTitle(status)
            }

        }
        title_layout?.setContentTitle(LanguageUtil.getString(this, "personal_text_safetycenter"))
        rl_phone?.setStatusText(LanguageUtil.getString(this, "personal_text_safeSettingOpen"))
        rl_phone?.setTitle(LanguageUtil.getString(this, "mobile"))

        rl_email?.setTitle(LanguageUtil.getString(this, "register_text_mail"))
        rl_email?.setStatusText(LanguageUtil.getString(this, "personal_text_safeSettingOpen"))

        rl_google_verify?.setTitle(LanguageUtil.getString(this, "safety_text_googleAuth"))
        rl_google_verify?.setStatusText(LanguageUtil.getString(this, "close_verify"))

        rl_change_pwd?.setTitle(LanguageUtil.getString(this, "register_text_loginPwd"))
        rl_change_pwd?.setStatusText(LanguageUtil.getString(this, "filter_action_reset_change_loginpwd"))

        rl_fund_pwd?.setTitle(LanguageUtil.getString(this, "otc_text_pwd_forotc"))
        rl_fund_pwd?.setStatusText(LanguageUtil.getString(this, "filter_action_reset_change_loginpwd"))

        tv_safety_text_gesturePassword?.text = LanguageUtil.getString(this, "gesture_pass")
        tv_login_text_fingerprint?.text = LanguageUtil.getString(this, "login_text_fingerprint")

        rl_account_destory?.setTitle(LanguageUtil.getString(this,"account_destory_text1"))
        tv_safe_level_label?.text = "personal_Center_text7".tr(this)
        tv_white_list_title.text = "safety_withdrawalWhitelist".tr(this)
        tv_white_list_label.text = "safety_withdrawalWhitelist_tips".tr(this)
        rl_account_destory.visibility = if(UserDataService.getInstance().isLogined){
            //Open
            View.VISIBLE
        }else{
            View.GONE
        }
        modelDisposable = mainModel.getAccountDestroyVisibleStatus(consumer = object: NDisposableObserver(){
            override fun onResponseSuccess(jsonObject: JSONObject) {
                val deleteAccount = jsonObject.optJSONObject("data")?.run {
                    optString("deleteAccount")
                }
                
                rl_account_destory.visibility = if("1".equals(deleteAccount)){
                    //Open
                    View.VISIBLE
                }else{
                    View.GONE
                }
            }
        })


        try{
            mcallBack  = AuthCallBack(mHandler)
        }catch (e:Exception){
            e.printStackTrace()
        }




    }

    override fun onPause() {
        super.onPause()

        if(cancellationSignal!=null){
            cancellationSignal?.cancel()
            fingerDialog?.dismiss()

        }
    }

    override fun onDestroy() {
        super.onDestroy()
        modelDisposable?.dispose()
    }

    override fun onResume() {
        super.onResume()
        
//        getUserInfo()
        initView()
    }
//    fun getUserInfo(){
//        HttpClient.instance.getUserInfo()
//                .subscribeOn(Schedulers.io())
//                .observeOn(AndroidSchedulers.mainThread())
//                .subscribe(object:NetObserver<UserInfoData>(){
//                    override fun onHandleSuccess(t: UserInfoData?) {
//
//                    }
//
//                    override fun onHandleError(msg: String?) {
//                        super.onHandleError(msg)
//                    }
//
//                })
//    }

    fun initView() {

        var level=0;
        if (UserDataService.getInstance().isOpenMobileCheck != 0) {
            //Open
            level= level+1
        }
        if (!TextUtils.isEmpty(UserDataService.getInstance().email)) {
            //Open
            level= level+1
        }
        if (UserDataService.getInstance().googleStatus != 0) {
            //Open
            level= level+1
        }

        if (level<=1){
            tv_level.setText( LanguageUtil.getString(this, "personal_Center_text29"))
            pb_level.setAnimProgress(20)
            tv_level.setTextColor(Color.parseColor("#D1425E"))
            pb_level.setProgressColor(Color.parseColor("#D1425E"))
        }else if (level>1 && level<=2){
            tv_level.setText(LanguageUtil.getString(this, "personal_Center_text28"))
            tv_level.setTextColor(Color.parseColor("#F7B500"))
            pb_level.setAnimProgress(60)
            pb_level.setProgressColor(Color.parseColor("#F7B500"))
        }else if (level>=3){
            tv_level.setText(LanguageUtil.getString(this, "personal_Center_text27"))
            pb_level.setAnimProgress(100)
            tv_level.setTextColor(Color.parseColor("#00B595"))
            pb_level.setProgressColor(Color.parseColor("#00B595"))
        }

        var status = !TextUtils.isEmpty(UserDataService.getInstance()
                .gesturePass) || !TextUtils.isEmpty(UserDataService.getInstance().gesturePwd)
        /**
         *Status of gesture password
         */
        switch_gesture_pwd?.isChecked = status
        setViewSelect(switch_gesture_pwd, status)
        /**
         *Mobile login situation
         */
        if (!TextUtils.isEmpty(UserDataService.getInstance().mobileNumber)) {
            if (UserDataService.getInstance().isOpenMobileCheck == 0) {
                rl_phone.setStatusText(LanguageUtil.getString(this, "personal_text_safeSettingOff"))
            } else {
                rl_phone.setStatusText(LanguageUtil.getString(this, "personal_text_safeSettingOpen"))
            }
            rl_phone.setOnClickListener {
                var bundle = Bundle()
                bundle.putInt(ParamConstant.VERIFY_TYPE, ParamConstant.MOBILE_TYPE)
                ArouterUtil.navigation(RoutePath.NewVerifyActivity, bundle)
                // NewDialogUtils.showNewDoubleDialog(this@SafetySettingActivity, String.format(LanguageUtil.getString(this, "login_tip_safeSettingChange"),
                //                    PublicInfoDataService.getInstance().getSafeWithdrawHour(PublicInfoDataService.getInstance().getData(null))), object : NewDialogUtils.DialogBottomListener {
                //                    override fun sendConfirm() {
                //
                //                       }
                //                },confrimTitle = LanguageUtil.getString(this, "personal_Center_text32"),cancelTitle =  LanguageUtil.getString(this, "common_text_btnCancel"))
            }
        } else {
            rl_phone.setStatusText(LanguageUtil.getString(this, "userinfo_text_mailUnbind"))
            rl_phone.setOnClickListener {
                BindMobileOrEmailActivity.enter2(this, BindMobileOrEmailActivity.MOBILE_TYPE, BindMobileOrEmailActivity.VALIDATION_BIND)
            }
        }


        /**
         *Email login situation
         */
        if (TextUtils.isEmpty(UserDataService.getInstance().email)) {
            rl_email.setStatusText(LanguageUtil.getString(this, "userinfo_text_mailUnbind"))

            /**
             *Bind email
             */
            rl_email.setOnClickListener {
                if (!Utils.isFastClick()) {
                    BindMobileOrEmailActivity.enter2(context, BindMobileOrEmailActivity.MAIL_TYPE, BindMobileOrEmailActivity.VALIDATION_BIND)
                }

            }


        } else {
            rl_email.setStatusText(LanguageUtil.getString(this, "common_action_edit"))
            rl_email.setOnClickListener {
                if (!Utils.isFastClick()) {
//                    var bundle = Bundle()
//                    bundle.putInt(ParamConstant.VERIFY_TYPE, ParamConstant.MAIL_TYPE)
//                    ArouterUtil.navigation(RoutePath.NewVerifyActivity, bundle)


                    KKDialogUtils.showCommonDialog(
                        this@SafetySettingActivity,
                        title = String.format(LanguageUtil.getString(this, "login_tip_safeSettingChange"), PublicInfoDataService.getInstance().getSafeWithdrawHour(PublicInfoDataService.getInstance().getData(null))),
                        style = 1,
                        listener =  object : KKDialogUtils.DialogDoubleBottomListener {
                            override fun sendConfirm() {
                                BindMobileOrEmailActivity.enter2(this@SafetySettingActivity, BindMobileOrEmailActivity.MAIL_TYPE, BindMobileOrEmailActivity.VALIDATION_CHANGE)
                            }

                            override fun sendCancel() {

                            }

                        },
                        confrimTitle = LanguageUtil.getString(this, "personal_Center_text32"),
                        cancelTitle =  LanguageUtil.getString(this, "common_text_btnCancel")
                    )

                }
            }
        }


        /**
         *Google verification
         */
        val googleStatus = UserDataService.getInstance().googleStatus

        if (googleStatus == 0) {
            rl_google_verify?.setStatusText(LanguageUtil.getString(this, "userinfo_text_mailUnbind"))

        } else {
            rl_google_verify?.setStatusText(LanguageUtil.getString(this, "personal_text_safeSettingOpen"))
        }
        rl_google_verify?.setOnClickListener {
            when (googleStatus) {
                0 -> {
                    startActivity(Intent(this, GoogleValidationActivity::class.java))
                }
                1 -> {
                    //https://jira.dw2nn.com/browse/BIGFUTURES-3084
                    var bundle = Bundle()
                    bundle.putInt(ParamConstant.VERIFY_TYPE, ParamConstant.GOOGLE_TYPE)
                    ArouterUtil.navigation(RoutePath.NewVerifyActivity, bundle)
//                    if (UserDataService.getInstance().isOpenMobileCheck == 1) {
//
//
//                    } else {
//                        DisplayUtil.showSnackBar(window?.decorView, LanguageUtil.getString(this, "login_tip_bindPhoneFirst"), isSuc = false)
//                        return@setOnClickListener
//                    }
                }
            }

        }


        /**
         *Fund password -->display hidden judgment
         */
        rl_fund_pwd.visibility = View.VISIBLE
//        if (PublicInfoDataService.getInstance().otcOpen(null)) {
//            rl_fund_pwd.visibility = View.VISIBLE
//        } else {
//            rl_fund_pwd.visibility = View.GONE
//        }


        /**
         *Fund password
         *
         */
        val pwdTitle = if (PublicInfoDataService.getInstance().getB2CSwitchOpen(null)) {
            LanguageUtil.getString(this, "otc_text_pwd_forotc")
        } else {
            LanguageUtil.getString(this, "otc_text_pwd")
        }

        rl_fund_pwd.setTitle(pwdTitle)

        if (UserDataService.getInstance().isCapitalPwordSet == 0) {
            rl_fund_pwd.setStatusText(LanguageUtil.getString(this, "otc_not_set"))

        } else {
            rl_fund_pwd.setAction("safety_fundsPass_Unbind".tr(this),object :View.OnClickListener{
                override fun onClick(v: View?) {
                    KKDialogUtils.showCommonDialog(
                        this@SafetySettingActivity,
                        title = String.format(LanguageUtil.getString(this@SafetySettingActivity, "fundsPass_unbindConfirm"), PublicInfoDataService.getInstance().getSafeWithdrawHour(PublicInfoDataService.getInstance().getData(null))),
                        style = 1,
                        listener =  object : KKDialogUtils.DialogDoubleBottomListener {
                            override fun sendConfirm() {
                                unBindCapitalPwd()
                            }

                            override fun sendCancel() {

                            }

                        },
                        confrimTitle = LanguageUtil.getString(this@SafetySettingActivity, "personal_Center_text32"),
                        cancelTitle =  LanguageUtil.getString(this@SafetySettingActivity, "common_text_btnCancel")
                    )

                }

            })
            rl_fund_pwd.setStatusText(LanguageUtil.getString(this, "filter_action_reset_change_loginpwd"))

        }

        rl_fund_pwd.setOnClickListener {

            val isFirstSet = UserDataService.getInstance().isCapitalPwordSet == 0
            if (!isFirstSet) {

                KKDialogUtils.showCommonDialog(
                    this@SafetySettingActivity,
                    title = String.format(LanguageUtil.getString(this, "login_tip_safeSettingChange"),
                        PublicInfoDataService.getInstance().getSafeWithdrawHour(PublicInfoDataService.getInstance().getData(null))),
                    style = 1,
                    listener =  object : KKDialogUtils.DialogDoubleBottomListener {
                        override fun sendConfirm() {
//                            if (UserDataService.getInstance().isOpenMobileCheck == 0 && UserDataService.getInstance().googleStatus == 0) {
//                                DisplayUtil.showSnackBar(window?.decorView, LanguageUtil.getString(this@SafetySettingActivity, "unbind_verify_warn"), isSuc = false)
//                                return
//                            }
                            if (isFirstSet) {
                                ArouterUtil.forwardModifyPwdPage(ParamConstant.SET_PWD, ParamConstant.FROM_OTC)
                            } else {
                                ArouterUtil.forwardModifyPwdPage(ParamConstant.RESET_PWD, ParamConstant.FROM_OTC)
                            }
                        }

                        override fun sendCancel() {

                        }

                    },
                    confrimTitle = LanguageUtil.getString(this, "personal_Center_text32"),
                    cancelTitle =  LanguageUtil.getString(this, "common_text_btnCancel")
                )
            } else {
                if (isFirstSet) {
                    ArouterUtil.forwardModifyPwdPage(ParamConstant.SET_PWD, ParamConstant.FROM_OTC)
                } else {
                    ArouterUtil.forwardModifyPwdPage(ParamConstant.RESET_PWD, ParamConstant.FROM_OTC)
                }
            }
        }
    }

    private fun unBindCapitalPwd(){
        var dialog:CpTDialog? = null
        dialog = NewDialogUtils.createNewVersionSecurityDialog(
            this,
            VerifyRule2(),
            AppConstant.UNBIND_CAPITALPWD,
            listener = object: NewDialogUtils.DialogVerifiactionListener{
                override fun returnCode(phone: String?, mail: String?, googleCode: String?) {}
                override fun returnCode(
                    phone: String,
                    mail: String,
                    googleCode: String,
                    capitalPwd: String,
                    loginPwd: String
                ) {

                    showProgressDialog()
                    HttpClient.instance.capitalPasswordUnBind(
                        phone,
                        googleCode,
                        mail
                    )
                        .subscribeOn(Schedulers.io())
                        .observeOn(AndroidSchedulers.mainThread())
                        .subscribe(object: NetObserver<Any>(){
                            override fun onHandleSuccess(t: Any?) {
                                ToastUtils.showToast(this@SafetySettingActivity,"Success".tr(this@SafetySettingActivity))
                                cancelProgressDialog()
                                rl_fund_pwd.setAction("",null)
                                rl_fund_pwd.setStatusText(LanguageUtil.getString(this@SafetySettingActivity, "otc_not_set"))
                                val userData = UserDataService.getInstance().userData
                                userData.put("isCapitalPwordSet",0)
                                UserDataService.getInstance().saveData(userData)
                                dialog?.dismiss()
                            }

                            override fun onHandleError(code: Int, msg: String?) {
                                super.onHandleError(code, msg)
                                cancelProgressDialog()
                                ToastUtils.showToast(this@SafetySettingActivity,msg)
                                dialog?.dismiss()
                            }
                        })
                }
            }
        )

    }


    private fun initOnClickListener() {
        val isOpenWithdrawWhitelist = UserDataService.getInstance().withdrawWhitelistFlag==1
        ctrl_white_list.isChecked = isOpenWithdrawWhitelist
        ctrl_white_list.setOnCheckedChangeListener(this)
        /**
         *Change password
         */
        rl_change_pwd.setOnClickListener {
            if (UserDataService.getInstance().isOpenMobileCheck != 1 && UserDataService.getInstance().googleStatus != 1) {
                DisplayUtil.showSnackBar(window?.decorView, LanguageUtil.getString(this, "common_text_pleaseBindGoogleFirst"), isSuc = false)
                return@setOnClickListener
            }

            KKDialogUtils.showCommonDialog(
                this@SafetySettingActivity,
                title = String.format(LanguageUtil.getString(this, "login_tip_safeSettingChange"), PublicInfoDataService.getInstance().getSafeWithdrawHour(PublicInfoDataService.getInstance().getData(null))),
                style = 1,
                listener =  object : KKDialogUtils.DialogDoubleBottomListener {
                    override fun sendConfirm() {
                        if (UserDataService.getInstance().isOpenMobileCheck == 0 && UserDataService.getInstance().googleStatus == 0) {
                            DisplayUtil.showSnackBar(window?.decorView, LanguageUtil.getString(this@SafetySettingActivity, "unbind_verify_warn"), isSuc = false)

                            return
                        }
                        ArouterUtil.forwardModifyPwdPage(ParamConstant.RESET_PWD, ParamConstant.FROM_LOGIN)
                    }

                    override fun sendCancel() {

                    }

                },
                confrimTitle = LanguageUtil.getString(this, "personal_Center_text32"),
                cancelTitle =  LanguageUtil.getString(this, "common_text_btnCancel")
            )

        }


        /**
         *Gesture password
         */
        switch_gesture_pwd?.setOnCheckedChangeListener(object : CompoundButton.OnCheckedChangeListener {
            override fun onCheckedChanged(buttonView: CompoundButton?, isChecked: Boolean) {
                
                if (!buttonView!!.isPressed) return
                if (LoginManager.getInstance().fingerprint == 1) {
                    switch_gesture_pwd?.isChecked = false
                    DisplayUtil.showSnackBar(window?.decorView, LanguageUtil.getString(this@SafetySettingActivity, "common_tip_activeLimit"), isSuc = false)
                    return
                }
                switch_gesture_pwd?.isChecked = isChecked
                setViewSelect(switch_gesture_pwd, isChecked)
                if (isChecked) {
                    showGestureVerifyDialog(true)
                } else {
                    if (TextUtils.isEmpty(UserDataService.getInstance().gesturePass)) {
                        return
                    }
                    showGestureVerifyDialog(false)
                }
            }
        })


        /**
         *Fingerprint recognition
         */
        if (!fingerprintManager.isHardwareDetected) {
            rl_fingerprint.visibility = View.GONE
        } else {
            rl_fingerprint.visibility = View.VISIBLE
            /**
             *Did you record a fingerprint
             */
            if (fingerprintManager.hasEnrolledFingerprints()) {
                /**
                 *Judging based on the open state
                 */
                switch_fingerprint_pwd.isChecked = LoginManager.getInstance().fingerprint == 1
                setViewSelect(switch_fingerprint_pwd, LoginManager.getInstance().fingerprint == 1)

            } else {

                switch_fingerprint_pwd.isChecked = false
                setViewSelect(switch_fingerprint_pwd, false)


            }
        }

        switch_fingerprint_pwd.setOnCheckedChangeListener(object : CompoundButton.OnCheckedChangeListener {
            override fun onCheckedChanged(buttonView: CompoundButton?, isChecked: Boolean) {
                /**
                 *Determine if fingerprint is supported
                 */
                if (fingerprintManager.isHardwareDetected) {
                    /**
                     *Determine whether to input fingerprints
                     */
                    if (!fingerprintManager.hasEnrolledFingerprints()) {
                        switch_fingerprint_pwd.isChecked = false
                        setViewSelect(switch_fingerprint_pwd, false)

                        DisplayUtil.showSnackBar(window?.decorView, LanguageUtil.getString(this@SafetySettingActivity, "no_fingerprints_were_entered"), isSuc = false)

                        return
                    }
                }


                if (!TextUtils.isEmpty(UserDataService.getInstance().gesturePass)) {
                    switch_fingerprint_pwd.isChecked = false
                    setViewSelect(switch_fingerprint_pwd, false)
                    DisplayUtil.showSnackBar(window?.decorView, LanguageUtil.getString(this@SafetySettingActivity, "only_set_one_login_way"), isSuc = false)

                    return
                }
                if (!buttonView!!.isPressed) return
                if(mcallBack == null) return
                startBiometricAuth()
                if(fingerDialog==null){
                    fingerDialog = DialogUtil.showFingerprintOrFaceIDDialog(context=this@SafetySettingActivity,onCancel = object : DialogUtil.CancelListener{
                        override fun click() {
                            fingerCheckSwitchStatus = !fingerCheckSwitchStatus!!
                            cancellationSignal?.cancel()
                        }
                    })
                }else{
                    fingerDialog?.show()
                }

                fingerCheckSwitchStatus = isChecked


            }

        })

        rl_account_destory?.setOnClickListener {
            if (!Utils.isFastClick()) {
                if(!UserDataService.getInstance().isLogined) return@setOnClickListener
                val intent = Intent(this, AccountDestroyActivity::class.java)
                startActivity(intent)
            }
        }

    }

    private fun switchWhiteList(isChecked:Boolean,smsAuthCode: String?,googleCode:String?,emailAuthCode:String?,dialog:CpTDialog?,getDisposable: (disposable:Disposable)->Unit){
        showProgressDialog()
        HttpClient.instance.withdrawWhiteListSwitch(smsAuthCode,googleCode,emailAuthCode,if(isChecked) "1" else "0")
            .subscribeOn(Schedulers.io())
            .observeOn(AndroidSchedulers.mainThread())
            .subscribe(object: NetObserver<Any>(){
                override fun onSubscribe(d: Disposable) {
                    super.onSubscribe(d)
                    getDisposable.invoke(d)
                }
                override fun onHandleSuccess(t: Any?) {
                    ToastUtils.showToast(this@SafetySettingActivity,"Success".tr(this@SafetySettingActivity))
                    UserDataService.getInstance().setWithdrawWhitelistFlag(isChecked)
                    cancelProgressDialog()
                    dialog?.dismiss()
                }

                override fun onHandleError(code: Int, msg: String?) {
                    super.onHandleError(code, msg)
                    ctrl_white_list.isChecked = !isChecked
                    cancelProgressDialog()
                    dialog?.dismiss()
                    ToastUtils.showToast(this@SafetySettingActivity,msg)
                }

            })
    }

    private fun startBiometricAuth() {
        //create a biometric dialog box，
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            mBiometricPrompt=BiometricPrompt.Builder(this)
                .setTitle(LanguageUtil.getString(this,"login_text_fingerprint"))
                .setDescription(LanguageUtil.getString(this,"login_via_fingerprint"))
                .setNegativeButton(LanguageUtil.getString(this,"common_text_btnCancel"),mainExecutor, object : DialogInterface.OnClickListener {
                    override fun onClick(dialog: DialogInterface?, which: Int) {
                        fingerCheckSwitchStatus = !fingerCheckSwitchStatus!!
                        mCancellationSignal?.cancel()
                        fingerDialog?.dismiss()
                        switch_fingerprint_pwd.isChecked = !switch_fingerprint_pwd.isChecked
                    }
                })
                .build()
            mAuthenticationCallback=object : BiometricPrompt.AuthenticationCallback() {
                override fun onAuthenticationError(errorCode: Int, errString: CharSequence?) {
                    super.onAuthenticationError(errorCode, errString)
                    Log.i(TAG, "onAuthenticationError: ${errString}")
                    switch_fingerprint_pwd.isChecked = !switch_fingerprint_pwd.isChecked
                    mCancellationSignal?.cancel()
                    fingerDialog?.dismiss()
                    fingerCheckSwitchStatus = false
                }

                override fun onAuthenticationHelp(helpCode: Int, helpString: CharSequence?) {
                    super.onAuthenticationHelp(helpCode, helpString)
                    Log.i(TAG, "onAuthenticationHelp: ${helpString}")
                }

                override fun onAuthenticationSucceeded(result: BiometricPrompt.AuthenticationResult?) {
                    super.onAuthenticationSucceeded(result)
                    if(fingerCheckSwitchStatus==null) return
                    if (fingerCheckSwitchStatus as Boolean) {
                        val fingerprint = 1
                        LoginManager.getInstance().saveFingerprint(fingerprint)
                        switch_fingerprint_pwd.isChecked = LoginManager.getInstance().fingerprint == fingerprint
                        setViewSelect(switch_fingerprint_pwd, LoginManager.getInstance().fingerprint == fingerprint)
                    } else {
                        LoginManager.getInstance().saveFingerprint(0)
                        setViewSelect(switch_fingerprint_pwd, LoginManager.getInstance().fingerprint == 1)
                    }
                    ToastUtils.showToast(this@SafetySettingActivity,"common_tip_setupSuccess".tr(this@SafetySettingActivity))
                    fingerDialog?.dismiss()
                }

                override fun onAuthenticationFailed() {
                    super.onAuthenticationFailed()
                    Log.i(TAG, "onAuthenticationFailed: ")
                }
            }
            //A new Cancellation Signal object must be passed in each time authenticate is called, otherwise an exception is thrown
            mCancellationSignal= android.os.CancellationSignal()
            mCancellationSignal?.setOnCancelListener {
                //The logic after active cancellation will go here when calling cancellation Signal.cancel().
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
                        mcallBack?:return,null)
                }catch (e:Exception){
                    e.printStackTrace()
                }
        }
    }

    var dialog:  CpTDialog? = null

    /**
     *Set gesture password
     *Isopen true Enable gesture password false Close gesture password
     */
    private fun showGestureVerifyDialog(isOpen: Boolean) {
        dialog = NewDialogUtils.showCertificationSecondDialog(this, AppConstant.GESTURE_PWD, object : NewDialogUtils.DialogSecondListener, NewDialogUtils.DialogCertificationSecondListener {
            override fun cancelBtn() {
                switch_gesture_pwd?.isChecked = !isOpen
                setViewSelect(switch_gesture_pwd, !isOpen)
            }

            override fun returnCode(phone: String?, mail: String?, googleCode: String?, pwd: String?) {
                dialog?.dismiss()
                /**
                 *Request server to enable gesture password
                 */
                if (isOpen) {
                    showProgressDialog()
                    HttpClient.instance.openHandPwd(pwd ?: "", phone ?: "", googleCode ?: "")
                            .subscribeOn(Schedulers.io())
                            .observeOn(AndroidSchedulers.mainThread())
                            .subscribe(object : NetObserver<JsonObject>() {
                                override fun onHandleSuccess(t: JsonObject?) {
                                    cancelProgressDialog()
                                    

                                    var bundle = Bundle()
                                    bundle.putInt("SET_TYPE", 0)
                                    bundle.putString("SET_TOKEN", t?.get("token")?.asString
                                            ?: "")
                                    bundle.putBoolean("SET_STATUS", false)
                                    bundle.putBoolean("SET_LOGINANDSET", false)
                                    ArouterUtil.navigation("/login/gesturespasswordactivity", bundle)

                                    switch_gesture_pwd?.isChecked = true
                                    setViewSelect(switch_gesture_pwd, true)
                                    ToastUtils.showToast(this@SafetySettingActivity,"common_tip_setupSuccess".tr(this@SafetySettingActivity))
                                }

                                override fun onHandleError(code: Int, msg: String?) {
                                    super.onHandleError(code, msg)
                                    cancelProgressDialog()
                                    switch_gesture_pwd?.isChecked = false
                                    setViewSelect(switch_gesture_pwd, false)
                                    DisplayUtil.showSnackBar(window?.decorView, msg, isSuc = false)

                                    

                                }
                            })
                } else {
                    /**
                     *Turn off gesture password
                     */
                    showProgressDialog()
                    HttpClient.instance.closeHandPwd(pwd ?: "", phone ?: "", googleCode ?: "")
                            .subscribeOn(Schedulers.io())
                            .observeOn(AndroidSchedulers.mainThread())
                            .subscribe(object : NetObserver<Any>() {
                                override fun onHandleSuccess(t: Any?) {
                                    cancelProgressDialog()
                                    switch_gesture_pwd?.isChecked = false
                                    setViewSelect(switch_gesture_pwd, false)
                                    UserDataService.getInstance().saveGesturePass("")
                                    var userInfoData = UserDataService.getInstance().userData
                                    userInfoData.put("gesturePwd", "")
                                    UserDataService.getInstance().saveData(userInfoData)
                                    ToastUtils.showToast(this@SafetySettingActivity,"common_tip_setupSuccess".tr(this@SafetySettingActivity))
                                }

                                override fun onHandleError(code: Int, msg: String?) {
                                    super.onHandleError(code, msg)
                                    cancelProgressDialog()
                                    switch_gesture_pwd?.isChecked = true
                                    setViewSelect(switch_gesture_pwd, true)
                                    DisplayUtil.showSnackBar(window?.decorView, msg, isSuc = false)
                                }
                            })
                }
            }

        }, confirmTitle = LanguageUtil.getString(this, "common_text_btnConfirm"))

    }

    fun setViewSelect(view: View, status: Boolean) {
//        if (status) {
//            view.setBackgroundResource(R.drawable.personal_switch_on)
//        } else {
//            view.setBackgroundResource(R.drawable.personal_switch_off)
//        }
    }

    override fun onMessageEvent(event: MessageEvent) {
        super.onMessageEvent(event)
        when(event.msg_type){
            MessageEvent.destroy_account_event,MessageEvent.modify_account_pwd_event -> {
                finish()
            }
        }
    }

    override fun onCheckedChanged(buttonView: CompoundButton?, isChecked: Boolean) {
        ctrl_white_list.setOnCheckedChangeListener(null)
        var subscribeDisposable:Disposable? = null
        var dialog:CpTDialog? = null

        dialog = NewDialogUtils.createNewVersionSecurityDialog(
            this@SafetySettingActivity,
            VerifyRule2(),
            if(isChecked) AppConstant.WHITE_LIST_STATUS_OPEN else AppConstant.WHITE_LIST_STATUS_CLOSE,
            listener = object:NewDialogUtils.DialogVerifiactionListener{
                override fun returnCode(phone: String?, mail: String?, googleCode: String?) {}

                override fun returnCode(
                    phone: String,
                    mail: String,
                    googleCode: String,
                    capitalPwd: String,
                    loginPwd: String
                ) {
                    super.returnCode(phone, mail, googleCode, capitalPwd, loginPwd)
                    switchWhiteList(isChecked,phone,googleCode,mail,dialog){
                        subscribeDisposable = it
                    }
                }
            },
            manualCancelListener = object:NewDialogUtils.DialogDismissListener{
                override fun onDismiss() {
                    ctrl_white_list.isChecked = !isChecked
                }
            },
            dismissListener = object: DialogInterface.OnDismissListener{
                override fun onDismiss(dialog: DialogInterface?) {
                    subscribeDisposable?.dispose()
                    ctrl_white_list.setOnCheckedChangeListener(this@SafetySettingActivity)
                }

            }
        )

    }

}
