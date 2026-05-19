package com.yjkj.chainup.net_new.rxjava

import android.app.Activity
import com.chainup.contract.app.CpMyApp
import com.chainup.contract.eventbus.CpEventBusUtil
import com.chainup.contract.eventbus.CpMessageEvent
import com.chainup.contract.net.CpJSONUtil
import com.chainup.contract.utils.ChainUpLogUtil
import com.chainup.contract.utils.CpClLogicContractSetting
import com.chainup.contract.utils.CpNToastUtil
import com.chainup.kit.dialog.KKLoadingDialog
import com.chainup.kit.utils.ToastUtils
import com.yjkj.chainup.manager.CpLanguageUtil
import io.reactivex.observers.DisposableObserver
import okhttp3.ResponseBody
import org.json.JSONObject
import retrofit2.HttpException
import java.io.IOException
import java.net.ConnectException
import java.net.SocketException
import java.net.SocketTimeoutException

/**
 *

 * @Description:

 * @Author:         wanghao

 * @CreateDate:     2019-08-06 19:20

 * @UpdateUser:     wanghao

 * @UpdateDate:     2019-08-06 19:20

 * @UpdateRemark:   updateDescription

 */
abstract class CpNDisposableObserver : DisposableObserver<ResponseBody> {

    private val TAG = "MyDisposableObserver"

    private val server_errorCode = -2
    private val net_errorCode = -1

    constructor(showToast: Boolean = false) {
        isShowToast = showToast
    }

    var mActivity: Activity? = null
    private var isShowToast = false
    var mapParams: Any? = null

    constructor(activity: Activity?, showToast: Boolean = false,isNoLoading:Boolean) {
        this.mActivity = activity
        this.isShowToast = showToast
//        this.showLoadingDialog()
    }
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

    override fun onNext(responseBody: ResponseBody) {
        ChainUpLogUtil.d(TAG, "MyDisposableObserver==onNext==t is " + responseBody)
        closeLoadingDialog()
        var jsonObj = CpJSONUtil.parse(responseBody, isShowToast)
        if (null != jsonObj) {
            val code = jsonObj.optString("code")

            if ("0".equals(code, true)) {
                onResponseSuccess(jsonObj)
            } else {
                var msg = jsonObj.optString("msg")
                onResponseFailure(jsonObj.optInt("code"), msg)
            }
        } else {
            onResponseFailure(-1, null)
        }
    }

    override fun onComplete() {
        closeLoadingDialog()
    }

    override fun onError(e: Throwable) {
        closeLoadingDialog()
        e.printStackTrace()
//        if(e is ConnectException || e is SocketException){
////            ToastUtils.showToast(CpMyApp.instance(),CpLanguageUtil.getString(CpMyApp.instance(),"cp_extra_text11"))
//        }else{
//            if (e is HttpException) {
////                val code = e.code()
////                val message = e.message
////                onResponseFailure(code, message)
//            } else if (e is SocketTimeoutException) {
////                onResponseFailure(net_errorCode, CpLanguageUtil.getString(CpMyApp.Companion.instance(),"cp_extra_text10"))
//            } else if (e is IOException) {
////                onResponseFailure(net_errorCode, CpLanguageUtil.getString(CpMyApp.Companion.instance(),"cp_extra_text11"))
//            } else {
//                //server Error
////                onResponseFailure(net_errorCode, CpLanguageUtil.getString(CpMyApp.Companion.instance(),"cp_extra_text12"))
//            }
//        }
    }

    abstract fun onResponseSuccess(jsonObject: JSONObject?)

    /*
     *Public error request codes can be processed here
     */
    open fun onResponseFailure(code: Int, msg: String?) {
        if (code == 10002) {
            CpClLogicContractSetting.cleanToken()
            CpEventBusUtil.post(CpMessageEvent(CpMessageEvent.sl_contract_logout_event))
            return
        }
        if (isShowToast) {
            val app = CpMyApp.instance() as CpMyApp
            if (app.appCount != 0){
                if (code != 200002&&code != 109006&& msg!=null) {
                    CpNToastUtil.showTopToast(false, msg)
                }
            }
        }
        if (code == 10021 || code == 10002 || code == 3 || code == 104008) {
            CpNToastUtil.showTopToast(false, msg+"  "+code)
        }
    }

    private var mLoadingDialog: KKLoadingDialog? = null
    private fun showLoadingDialog() {
        closeLoadingDialog()
        if (null != mActivity) {
            if (null == mLoadingDialog) {
                mLoadingDialog =
                    KKLoadingDialog(mActivity)
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
