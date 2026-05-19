package com.yjkj.chainup.net_new.rxjava

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import androidx.core.hardware.fingerprint.FingerprintManagerCompat
import android.text.TextUtils
import com.chainup.kit.dialog.KKLoadingDialog
import com.yjkj.chainup.R
import com.yjkj.chainup.app.AppConfig
import com.yjkj.chainup.app.ChainUpApp
import com.yjkj.chainup.db.constant.ParamConstant
import com.yjkj.chainup.db.service.UserDataService
import com.yjkj.chainup.extra_service.arouter.ArouterUtil
import com.yjkj.chainup.manager.LanguageUtil
import com.yjkj.chainup.manager.LoginManager
import com.yjkj.chainup.net.api.HttpResult
import com.yjkj.chainup.net_new.JSONUtil
import com.yjkj.chainup.new_version.activity.login.TouchIDFaceIDActivity
import com.yjkj.chainup.util.ContextUtil
import com.yjkj.chainup.util.LogUtil
import com.yjkj.chainup.util.NToastUtil
import com.yjkj.chainup.util.NetworkUtils
import io.reactivex.observers.DisposableObserver
import okhttp3.ResponseBody
import org.json.JSONObject
import retrofit2.HttpException
import java.io.IOException
import java.net.SocketTimeoutException

abstract class NModelDisposableObserver<T> : DisposableObserver<HttpResult<T>> {

    private val TAG = this::class.java.simpleName

    private val net_errorCode = -1

    constructor(showToast: Boolean = false) {
        isShowToast = showToast
    }

    var mActivity: Activity? = null
    private var isShowToast = false
    var mapParams: Any? = null

    constructor(activity: Activity?, showToast: Boolean = false) {
        this.mActivity = activity
        this.isShowToast = showToast
        this.showLoadingDialog()
    }

    constructor(activity: Activity?, showToast: Boolean = false, map: Any = "") {
        this.mActivity = activity
        this.isShowToast = showToast
        this.mapParams = map
        this.showLoadingDialog()
    }

    /*
     *Toast display switch control, default display
     */
    fun setShowToast(isShowToast: Boolean) {
        this.isShowToast = isShowToast
    }

    override fun onNext(responseBody: HttpResult<T>) {
        closeLoadingDialog()
        if(responseBody.isSuccess){
            onResponseSuccess(responseBody.data)
        }else{
            onResponseFailure(responseBody.code.toInt(), responseBody.msg)
        }
    }

    override fun onComplete() {
        closeLoadingDialog()
    }

    override fun onError(e: Throwable) {
        closeLoadingDialog()

//        if (e is HttpException) {
//            val code = e.code()
//            val message = e.message
//            onResponseFailure(code, message)
//        } else if (e is SocketTimeoutException) {
//            onResponseFailure(net_errorCode, LanguageUtil.getString(null,"network_connection_is_out_of_time"))
//        } else if (e is IOException) {
//            onResponseFailure(net_errorCode, LanguageUtil.getString(null,"network_is_exception"))
//        } else {
//            //server Error
//            onResponseFailure(net_errorCode, LanguageUtil.getString(null,"Server_error_please_try_again_later"))
//        }
    }

    abstract fun onResponseSuccess(data: T)

    /*
     *Public error request code, which can be processed here
     */
    open fun onResponseFailure(code: Int, msg: String?) {
        if (isShowToast) {
            val app = ChainUpApp.app as ChainUpApp
            LogUtil.e(TAG, "code:" + code)
            if (app.appCount != 0) {
                if (code != 200002 && msg!=null) {
                    LogUtil.e(TAG, "msg:" + msg)
                    NToastUtil.showTopToastNet(mActivity,false, msg)
                }
            }
        }
        if (code == 10021 || code == 10002 || code == 3 || code == ParamConstant.QUICK_LOGIN_FAILURE|| code == ParamConstant.QUICK_LOGIN_FAILURE_EXPAND) {
            UserDataService.getInstance().clearToken()
            val userinfo = UserDataService.getInstance().userData
            if (null == userinfo) {
                ArouterUtil.navigation("/login/NewVersionLoginActivity", null)
            } else {
                val fingerprintManager = FingerprintManagerCompat.from(ChainUpApp.appContext)
                if (fingerprintManager.isHardwareDetected) {
                    /**
                     *Determine whether to input fingerprints
                     */
                    if (fingerprintManager.hasEnrolledFingerprints() && LoginManager.getInstance().fingerprint == 1) {
                        val bundle = Bundle()
                        bundle.putInt("type", TouchIDFaceIDActivity.FINGERPRINT)
                        bundle.putBoolean("is_first_login", false)
                        ArouterUtil.navigation("/login/touchidfaceidactivity", bundle)
                    } else if (!TextUtils.isEmpty(UserDataService.getInstance().gesturePass) || !TextUtils.isEmpty(UserDataService.getInstance().gesturePwd)) {
                        val bundle = Bundle()
                        bundle.putInt("SET_TYPE", 1)
                        bundle.putString("SET_TOKEN", "")
                        bundle.putBoolean("SET_STATUS", true)
                        bundle.putBoolean("SET_LOGINANDSET", true)
                        ArouterUtil.navigation("/login/gesturespasswordactivity", bundle)
                    } else {
                        ArouterUtil.navigation("/login/NewVersionLoginActivity", null)
                    }
                } else if (!TextUtils.isEmpty(UserDataService.getInstance().gesturePass) || !TextUtils.isEmpty(UserDataService.getInstance().gesturePwd)) {

                    val bundle = Bundle()
                    bundle.putInt("SET_TYPE", 1)
                    bundle.putString("SET_TOKEN", "")
                    bundle.putBoolean("SET_STATUS", true)
                    bundle.putBoolean("SET_LOGINANDSET", true)
                    ArouterUtil.navigation("/login/gesturespasswordactivity", bundle)
                } else {
                    ArouterUtil.navigation("/login/NewVersionLoginActivity", null)
                }
            }

            //            Intent intent = new Intent(ChainUpApp.appContext, NewVersionLoginActivity.class);
            //            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            //            ChainUpApp.appContext.startActivity(intent);

        } else {
            LogUtil.e(TAG, "网络错误 需要切换网络 ${NetworkUtils.isNetworkAvailable(ChainUpApp.appContext)}")
        }
    }


    private var mLoadingDialog: KKLoadingDialog? = null
    private fun showLoadingDialog() {
        closeLoadingDialog()
        if (null != mActivity) {
            if (null == mLoadingDialog) {
                mLoadingDialog = KKLoadingDialog(mActivity)
            }
            mLoadingDialog!!.showLoadingDialog()
        }
    }

    private fun closeLoadingDialog() {
        if (null != mActivity) {
            if (null != mLoadingDialog) {
                mLoadingDialog!!.closeLoadingDialog()
                mLoadingDialog = null
            }
        }
    }

    fun getHomeTabType(): String {
        if (mapParams is String) {
            return mapParams.toString()
        }
        return ""
    }

}
