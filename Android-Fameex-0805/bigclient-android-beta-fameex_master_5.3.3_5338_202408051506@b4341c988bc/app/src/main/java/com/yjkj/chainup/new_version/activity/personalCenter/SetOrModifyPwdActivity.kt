package com.yjkj.chainup.new_version.activity.personalCenter

import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.text.TextUtils
import android.view.View
import android.view.View.OnClickListener
import com.alibaba.android.arouter.facade.annotation.Autowired
import com.alibaba.android.arouter.facade.annotation.Route
 import com.chainup.contract.view.dialog.CpTDialog
import com.yjkj.chainup.R
import com.yjkj.chainup.app.AppConstant
import com.yjkj.chainup.db.constant.ParamConstant
import com.yjkj.chainup.db.constant.RoutePath
import com.yjkj.chainup.db.service.PublicInfoDataService
import com.yjkj.chainup.db.service.UserDataService
import com.yjkj.chainup.extra_service.arouter.ArouterUtil
import com.yjkj.chainup.extra_service.eventbus.EventBusUtil
import com.yjkj.chainup.extra_service.eventbus.MessageEvent
import com.yjkj.chainup.manager.LanguageUtil
import com.yjkj.chainup.manager.LoginManager
import com.yjkj.chainup.net.HttpClient
import com.yjkj.chainup.net.retrofit.NetObserver
import com.yjkj.chainup.new_version.activity.TitleShowListener
import com.yjkj.chainup.new_version.dialog.NewDialogUtils
import com.yjkj.chainup.util.DisplayUtil
import com.yjkj.chainup.new_version.view.CommonlyUsedButton
import com.yjkj.chainup.new_version.view.TextViewAddEditTextView
import com.yjkj.chainup.new_version.view.TextViewAndPwdView
import com.yjkj.chainup.new_version.activity.NewBaseActivity
import com.yjkj.chainup.securityVerifyRule.VerifyRule1
import com.yjkj.chainup.securityVerifyRule.VerifyRule2
import com.yjkj.chainup.util.StringUtils
import com.yjkj.chainup.util.ToastUtils
import com.yjkj.chainup.util.getLineText
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.schedulers.Schedulers
import kotlinx.android.synthetic.main.activity_set_modify_pwd.*

/**
 * @Author lianshangljl
 * @Date 2023/4/2-11:07 AM
 * @Email buptjinlong@163.com
 *@description Set or modify the fund password or login password
 */
@Route(path = RoutePath.SetOrModifyPwdActivity)
class SetOrModifyPwdActivity : NewBaseActivity() {


    @JvmField
    @Autowired(name = ParamConstant.taskType)
    var taskType = ParamConstant.RESET_PWD

    @JvmField
    @Autowired(name = ParamConstant.taskFrom)
    var taskFrom = ParamConstant.FROM_OTC

    var realContent = ""
    var oldPwd = ""
    var newPwd = ""
    var newAgainPwd = ""

    private var isForgetCapitalPwd:Boolean = false

    /*companion object {
        //const val SET_PWD = "SET_PWD"
        //const val RESET_PWD = "RESET_PWD"
        //const val FROM_LOGIN = "FROM_LOGIN"
        //const val FROM_OTC = "FROM_OTC"
        //const val TASKTYPE = "TASKTYPE"
        //const val FROM = "FROM"
        */
    /**
     *@param taskType task type modification or password setting
     *@param from changing login password or fund password
     *
     *//*
        fun enter2(context: Context, taskType: String, from: String) {
            var intent = Intent()
            intent.setClass(context, SetOrModifyPwdActivity::class.java)
            intent.putExtra(TASKTYPE, taskType)
            intent.putExtra(FROM, from)
            context.startActivity(intent)
        }
    }*/

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        ArouterUtil.inject(this)
        setContentView(R.layout.activity_set_modify_pwd)

        real_name_layout?.setTitle(LanguageUtil.getString(this, "safety_text_userIdentifier"))
        old_pws?.setTitle(LanguageUtil.getString(this, "safety_text_oldPassword"))
        old_pws?.setEditHint(LanguageUtil.getString(this, "personal_tip_inputOldPwd"))

        new_pws?.setTitle(LanguageUtil.getString(this, "otcSafeAlert_text_otcPwd"))
        new_pws?.setEditHint(LanguageUtil.getString(this, "hint_input_new_pwd"))

        new_again_pws?.setTitle(LanguageUtil.getString(this, "safety_text_confrimPasswod"))
        new_again_pws?.setEditHint(LanguageUtil.getString(this, "hint_input_new_pwd"))
        cub_submit?.setBottomTextContent(LanguageUtil.getString(this, "common_action_next"))
        cub_submit?.isEnable(false)
        initView()
        setOnClick()
    }

    fun setOnClick() {

        cub_submit?.listener = object : CommonlyUsedButton.OnBottonListener {
            override fun bottonOnClick() {
                if (newPwd != newAgainPwd) {
                    DisplayUtil.showSnackBar(window?.decorView, LanguageUtil.getString(this@SetOrModifyPwdActivity, "common_tip_inputsNotMatch"), isSuc = false)

                    return
                }
                if (!StringUtils.checkPass(newPwd)) {
                    DisplayUtil.showSnackBar(window?.decorView, LanguageUtil.getString(this@SetOrModifyPwdActivity, "common_tip_pwdNotice"), isSuc = false)
                    return
                }
                if (newPwd.equals(oldPwd)) {
                    DisplayUtil.showSnackBar(window?.decorView, LanguageUtil.getString(this@SetOrModifyPwdActivity, "other_text1"), isSuc = false)
                    return
                }
                when (taskFrom) {
                    ParamConstant.FROM_LOGIN -> {
                        dialog = NewDialogUtils.showBindDialog(this@SetOrModifyPwdActivity, AppConstant.CHANGE_PWD, object : NewDialogUtils.DialogVerifiactionListener {
                            override fun returnCode(phone: String?, mail: String?, googleCode: String?) {
                                dialog?.dismiss()
                                changeLoginPwd(phone ?: "", oldPwd, newPwd, googleCode
                                        ?: "", realContent)
                            }
                        }, 1)
                    }
                    ParamConstant.FROM_OTC -> {
                        dialog = NewDialogUtils.createNewVersionSecurityDialog(
                            this@SetOrModifyPwdActivity,
                            VerifyRule1(),
                            when (taskType) {
                                ParamConstant.SET_PWD -> AppConstant.SET_CAPITAL_PWD
                                else -> AppConstant.CHANGE_CAPITAL_PWD
                            },
                            listener = object : NewDialogUtils.DialogVerifiactionListener{
                                override fun returnCode(
                                    phone: String?,
                                    mail: String?,
                                    googleCode: String?
                                ) {}

                                override fun returnCode(
                                    phone: String,
                                    mail: String,
                                    googleCode: String,
                                    capitalPwd: String,
                                    loginPwd: String
                                ) {
                                    super.returnCode(phone, mail, googleCode, capitalPwd, loginPwd)
                                    dialog?.dismiss()
                                    when (taskType) {
                                        ParamConstant.SET_PWD -> {
                                            capitalPassword4OTC(newPwd, phone, mail,googleCode)

                                        }
                                        ParamConstant.RESET_PWD -> {
                                            capitalPasswordReset4OTC(phone, googleCode,mail)
                                        }
                                    }
                                }

                            }
                        )


                    }
                }
            }

        }
    }

    var dialog:  CpTDialog? = null

    fun initView() {
        real_name_layout?.visibility = View.GONE
        val title = if (PublicInfoDataService.getInstance().getB2CSwitchOpen(null)) {
            LanguageUtil.getString(this, "safety_text_editOtcPassword_forotc")
        } else {
            LanguageUtil.getString(this, "safety_text_editOtcPassword")
        }

        when (taskFrom) {
            ParamConstant.FROM_LOGIN -> {
                if (taskType == ParamConstant.RESET_PWD) {
                    if (UserDataService.getInstance().authLevel != 1) {
                        real_name_layout?.visibility = View.GONE
                    }
                }
                title_layout?.setContentTitle(LanguageUtil.getString(this, "safety_action_changeLoginPassword"))
                new_pws?.setTitle(LanguageUtil.getString(this, "personal_text_newPwd"))

                new_again_pws?.setTitle(LanguageUtil.getString(this, "personal_text_confirmPwd"))
                new_again_pws?.setEditHint(LanguageUtil.getString(this, "personal_text_confirmPwd"))
            }
            ParamConstant.FROM_OTC -> {
                tv_forget_capital_pwd.setOnClickListener(object : OnClickListener {
                    override fun onClick(v: View?) {
                        var dialog:CpTDialog? = null
                        dialog = NewDialogUtils.createNewVersionSecurityDialog(
                            this@SetOrModifyPwdActivity,
                            VerifyRule2(),
                            AppConstant.CAPITALPWD_FORGET,
                            object: NewDialogUtils.DialogVerifiactionListener{
                                override fun returnCode(
                                    phone: String?,
                                    mail: String?,
                                    googleCode: String?
                                ) {
                                    forgetCapitalPwd(dialog,phone?:"",googleCode?:"", mail?:"")
                                }
                            }
                        )
                    }
                })
                old_pws?.setTitle(LanguageUtil.getString(this, "original_assets_pass"))
                old_pws?.setEditHint(LanguageUtil.getString(this, "hint_assets_pass_old"))
                real_name_layout?.visibility = View.GONE

                when (taskType) {
                    ParamConstant.SET_PWD -> {
                        old_pws?.visibility = View.GONE
                        title_layout?.setContentTitle(LanguageUtil.getString(this, "safety_action_otcPassword"))
                    }
                    ParamConstant.RESET_PWD -> {
                        old_pws?.visibility = View.VISIBLE
                        tv_forget_capital_pwd.visibility = View.VISIBLE
                        title_layout?.setContentTitle(title)
                    }
                }

                new_pws?.setTitle(LanguageUtil.getString(this, "funding_password"))
                new_again_pws?.setTitle(LanguageUtil.getString(this, "safety_text_confrimPasswod"))
                new_pws?.setEditHint(LanguageUtil.getString(this, "personal_Center_text21"))
                new_again_pws?.setEditHint(LanguageUtil.getString(this, "safety_tip_inputOtcPassword"))
            }
        }
        real_name_layout?.listener = object : TextViewAddEditTextView.OnTextListener {
            override fun showText(text: String): String {
                realContent = text
                setButtonEnable()
                return text
            }
        }
        old_pws?.listener = object : TextViewAndPwdView.OnTextListener {
            override fun showText(text: String): String {
                oldPwd = text
                setButtonEnable()
                return text
            }
        }
        new_pws?.listener = object : TextViewAndPwdView.OnTextListener {
            override fun showText(text: String): String {
                newPwd = text
                setButtonEnable()
                return text
            }
        }
        new_again_pws?.listener = object : TextViewAndPwdView.OnTextListener {
            override fun showText(text: String): String {
                newAgainPwd = text
                setButtonEnable()
                return text
            }
        }
    }

    private fun forgetCapitalPwd(dialog:CpTDialog?,smsAuthCode:String,googleCode:String,emailAuthCode:String){
        HttpClient.instance.capitalPasswordForget(smsAuthCode, googleCode, emailAuthCode)
            .subscribeOn(Schedulers.io())
            .observeOn(AndroidSchedulers.mainThread())
            .subscribe(object: NetObserver<Any>(){
                override fun onHandleSuccess(t: Any?) {
                    dialog?.dismiss()
                    isForgetCapitalPwd = true
                    old_pws?.visibility = View.GONE
                    tv_forget_capital_pwd.visibility = View.GONE
                }

                override fun onHandleError(code: Int, msg: String?) {
                    super.onHandleError(code, msg)
                    com.chainup.kit.utils.ToastUtils.showToast(this@SetOrModifyPwdActivity,msg)
                }
            })
    }


    fun setButtonEnable() {
        when (taskFrom) {
            ParamConstant.FROM_LOGIN -> {
                if (!TextUtils.isEmpty(oldPwd) && !TextUtils.isEmpty(newPwd) && !TextUtils.isEmpty(newAgainPwd)) {
                    cub_submit?.isEnable(true)
                } else {
                    cub_submit?.isEnable(false)
                }
            }
            ParamConstant.FROM_OTC -> {
                if (!TextUtils.isEmpty(newPwd) && !TextUtils.isEmpty(newAgainPwd)) {
                    cub_submit?.isEnable(true)
                } else {
                    cub_submit?.isEnable(false)
                }

            }
        }
    }


    /**
     *Change login password
     */
    fun changeLoginPwd(smsAuthCode: String = "", loginPwd: String, newLoginPwd: String,
                       googleCode: String = "", identificationNumber: String? = "") {
        HttpClient.instance.changeLoginPwd(smsAuthCode = smsAuthCode, loginPwd = loginPwd, newLoginPwd = newLoginPwd, googleCode = googleCode, identificationNumber = identificationNumber)
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(object : NetObserver<Any>() {
                    override fun onHandleSuccess(t: Any?) {
//                        DisplayUtil.showSnackBar(window?.decorView, LanguageUtil.getString(this@SetOrModifyPwdActivity, "common_tip_editSuccess"), isSuc = true)

                        /**
                         *Change login password
                         */
                        val loginInfo = LoginManager.getInstance().loginInfo
                        loginInfo.loginPwd = newLoginPwd
                        LoginManager.getInstance().saveLoginInfo(loginInfo)

                        clearLoginStatus()

//                        finish()
                    }

                    override fun onHandleError(code: Int, msg: String?) {
                        super.onHandleError(code, msg)
                        DisplayUtil.showSnackBar(window?.decorView, msg, isSuc = false)

                    }

                })
    }

    private fun clearLoginStatus() {
        EventBusUtil.post(MessageEvent(MessageEvent.modify_account_pwd_event))
        UserDataService.getInstance().clearToken()
        UserDataService.getInstance().saveQuickToken("")
        LoginManager.postValue(false)
        ToastUtils.showToast(getLineText("login_pwd_change_success"))
        ArouterUtil.greenChannel(RoutePath.NewVersionLoginActivity,null)
        finish()
    }

    /**
     *Set fund pwd
     */
    fun capitalPassword4OTC(capitalPwd: String, smsAuthCode: String, emailAuthCode:String,googleCode: String) {
        HttpClient.instance.capitalPassword4OTC(capitalPwd, smsAuthCode, emailAuthCode,googleCode)
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(object : NetObserver<Any>() {
                    override fun onHandleSuccess(t: Any?) {
                        DisplayUtil.showSnackBar(window?.decorView, LanguageUtil.getString(this@SetOrModifyPwdActivity, "Success"), isSuc = true)

                        var info = UserDataService.getInstance().userData
                        info.put("isCapitalPwordSet", 1)
                        UserDataService.getInstance().saveData(info)
                        finish()
                    }

                    override fun onHandleError(code: Int, msg: String?) {
                        super.onHandleError(code, msg)
                        DisplayUtil.showSnackBar(window?.decorView, msg, isSuc = false)
                    }

                })
    }



    fun capitalPasswordReset4OTC(smsAuthCode: String, googleCode: String,emailCode:String) {
        HttpClient.instance.capitalPasswordReset4OTC(if(isForgetCapitalPwd) null else oldPwd,newPwd,if(isForgetCapitalPwd) "0" else "1", smsAuthCode, googleCode,emailCode)
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(object : NetObserver<Any>() {
                    override fun onHandleSuccess(t: Any?) {
                        DisplayUtil.showSnackBar(window?.decorView, LanguageUtil.getString(this@SetOrModifyPwdActivity, "Success"), isSuc = true)

                        var info = UserDataService.getInstance().userData
                        info.put("isCapitalPwordSet", 1)
                        UserDataService.getInstance().saveData(info)
                        finish()
                    }

                    override fun onHandleError(code: Int, msg: String?) {
                        super.onHandleError(code, msg)
                        DisplayUtil.showSnackBar(window?.decorView, msg, isSuc = false)
                    }

                })
    }

}
