package com.yjkj.chainup.new_version.activity

import android.os.Bundle
import android.os.Looper
import android.util.Log
import androidx.lifecycle.lifecycleScope
import androidx.recyclerview.widget.LinearLayoutManager
import com.alibaba.android.arouter.facade.annotation.Route
import com.chainup.contract.utils.setSafeItemClickListener
import com.chainup.kit.utils.ToastUtils
import com.chainup.kit.views.KKEmptyViewKit
import com.sumsub.sns.core.SNSActionResult
import com.sumsub.sns.core.SNSMobileSDK
import com.sumsub.sns.core.data.listener.SNSActionResultHandler
import com.sumsub.sns.core.data.listener.SNSCompleteHandler
import com.sumsub.sns.core.data.listener.SNSEvent
import com.sumsub.sns.core.data.listener.SNSEventHandler
import com.sumsub.sns.core.data.listener.SNSStateChangedHandler
import com.sumsub.sns.core.data.listener.TokenExpirationHandler
import com.sumsub.sns.core.data.model.SNSCompletionResult
import com.sumsub.sns.core.data.model.SNSSDKState
import com.yjkj.chainup.BuildConfig
import com.yjkj.chainup.R
import com.yjkj.chainup.base.NBaseActivity
import com.yjkj.chainup.bean.AuthConfig
import com.yjkj.chainup.bean.KycAuthBean
import com.yjkj.chainup.common.KycTheme
import com.yjkj.chainup.db.constant.RoutePath
import com.yjkj.chainup.extra_service.arouter.ArouterUtil
import com.yjkj.chainup.extra_service.eventbus.MessageEvent
import com.yjkj.chainup.net_new.rxjava.NModelDisposableObserver
import com.yjkj.chainup.new_version.adapter.SumsubKycAdapter
import com.yjkj.chainup.util.LocalManageUtil
import com.yjkj.chainup.util.tr
import kotlinx.android.synthetic.main.activity_kyc.*
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

private const val kycLog = "SUMSUBLOG"
@Route(path = RoutePath.KycActivity)
class KycActivity : NBaseActivity() {
    override fun setContentView(): Int = R.layout.activity_kyc

    private var layoutManager:LinearLayoutManager? = null
    private var adapter:SumsubKycAdapter? = null
    private var dataList:ArrayList<KycAuthBean> = arrayListOf()
    var customTheme:KycTheme? = null
    override fun onInit(savedInstanceState: Bundle?) {
        super.onInit(savedInstanceState)
        customTheme = KycTheme(this)
        initView()
        initAdapter()
        loadData()
    }
    override fun initView() {
        super.initView()
        mHeaderKit.setTitleContent("kyc_page_name".tr(this))
    }

    override fun loadData() {
        super.loadData()
        getAuthRecord()
    }

    private fun getAuthRecord() {
        addDisposable(getMainModel().getAuthRecord(consumer = object : NModelDisposableObserver<List<KycAuthBean>>(this,true){
            override fun onResponseSuccess(data: List<KycAuthBean>) {
                dataList.clear()
                dataList.addAll(data)
                adapter?.notifyDataSetChanged()
            }

        }))
    }

    private fun initAdapter(){
        layoutManager = LinearLayoutManager(this,LinearLayoutManager.VERTICAL,false)
        adapter = SumsubKycAdapter(dataList)
        adapter!!.run {
            setEmptyView(KKEmptyViewKit(this@KycActivity))
            rv_auth_list.layoutManager = layoutManager
            rv_auth_list.adapter = this
            setSafeItemClickListener { adapter, view, position ->
                val item = dataList[position]
                when(item.authConfigName) {
                    AuthConfig.PLATFORM -> {
                        //old kyc ---> void openPlatformKyc()
                        openPlatformKyc()
                    }
                    AuthConfig.SUMSUB -> {
                        launchSumSubKyc(item.sumsubLevel)
                    }
                }
            }
        }

    }

    private fun openPlatformKyc(){
        ArouterUtil.greenChannel(RoutePath.RealNameCertificationActivity, null)
    }

    /**
     * @param levelName level name 等级名称
     * */
    private fun launchSumSubKyc(levelName:String) {
        if("".equals(levelName)) return

        lifecycleScope.launch(Dispatchers.Main) {
            showLoadingDialog()
            val token = withContext(Dispatchers.IO){
                getAccessToken(levelName)
            }
            closeLoadingDialog()
            if("".equals(token) || token==null) {
                ToastUtils.showToast(this@KycActivity,"Token is null!")
                return@launch
            }
            val snsSdk = SNSMobileSDK.Builder(this@KycActivity)
                .withAccessToken(token, object : TokenExpirationHandler {
                    override fun onTokenExpired(): String? {
                        Log.d(TAG, "api.sumsub.com onTokenExpired")
                        Log.d(TAG,"onTokenExpired run current thread is>>>${Thread.currentThread()}")
                        return getAccessToken(levelName)
                    }
                })
                .withDebug(BuildConfig.DEBUG)
                .withActionResultHandler(onActionResultHandler)
                .withStateChangedHandler(getOnStateChangeListener(levelName))
                .withCompleteHandler(getOnSDKCompletedHandler())
                .withEventHandler(getOnEventHandler())
                .withLocale(LocalManageUtil.getSetLanguageLocale())
                .withTheme(customTheme!!)
                .build()
            snsSdk.launch()
        }
    }

    private val onActionResultHandler: SNSActionResultHandler = object : SNSActionResultHandler {
        override fun onActionResult(
            actionId: String,
            actionType: String,
            answer: String?,
            allowContinuing: Boolean
        ): SNSActionResult {
            Log.d(kycLog,"SNSSDK Action Result: actionId: $actionId answer: $answer")
            // use default scenario
            return SNSActionResult.Continue
        }
    }

    private fun getOnStateChangeListener(levelName: String): SNSStateChangedHandler = object : SNSStateChangedHandler {
        override fun onStateChanged(previousState: SNSSDKState, currentState: SNSSDKState) {
            Log.d(kycLog,"SNSSDK The SDK state was changed: $previousState -> $currentState")

            when (currentState) {
                is SNSSDKState.Ready -> Log.d(kycLog,"SDK is ready")
                is SNSSDKState.Failed -> {
                    when (currentState) {
                        is SNSSDKState.Failed.Unauthorized -> Log.e(kycLog,"Invalid token or a token can't be refreshed by the SDK. Please, check your token expiration handler ${currentState.exception}")
                        is SNSSDKState.Failed.Unknown -> Log.e(kycLog, "Unknown error ${currentState.exception}")
                    }
                }
                is SNSSDKState.Initial -> Log.d(kycLog,"No verification steps are passed yet")
                is SNSSDKState.Incomplete -> Log.d(kycLog,"Some but not all verification steps are passed over")
                is SNSSDKState.Pending -> {
                    Log.d(kycLog,"Verification is in pending state")
                    submitCallback(levelName)
                }
                is SNSSDKState.FinallyRejected -> Log.d(kycLog,"Applicant has been finally rejected")
                is SNSSDKState.TemporarilyDeclined -> Log.d(kycLog,"Applicant has been declined temporarily")
                is SNSSDKState.Approved -> Log.d(kycLog,"Applicant has been approved")
                is SNSSDKState.ActionCompleted -> Log.d(kycLog,"Action is completed")
            }
        }
    }

    private fun getOnSDKCompletedHandler(): SNSCompleteHandler =
        object : SNSCompleteHandler {
            override fun onComplete(result: SNSCompletionResult, state: SNSSDKState) {
                loadData()
                Log.d(kycLog,"SNSSDK The SDK is finished. Result: $result, State: ${state.name} [] ${state.message}")
                when (result) {
                    is SNSCompletionResult.SuccessTermination -> Log.d(kycLog,result.toString())
                    is SNSCompletionResult.AbnormalTermination -> Log.d(kycLog,result.exception.toString())
                }
            }
        }


    private fun getOnEventHandler(): SNSEventHandler = object : SNSEventHandler {
        override fun onEvent(event: SNSEvent) {
            when (event) {
                is SNSEvent.SNSEventStepInitiated -> {
                    Log.d(kycLog,"SNSSDK onEvent: step initiated $event")
                }
                is SNSEvent.SNSEventStepCompleted -> {
                    Log.d(kycLog,"SNSSDK onEvent: step completed $event")
                }
            }
        }

    }



    private fun submitCallback(level:String){
        addDisposable(
            getMainModel().doKycSubmitCallback(
                level,
                consumer = object :NModelDisposableObserver<String?>(this){
                    override fun onResponseSuccess(data: String?) {}
                }
            )
        )
    }


    private fun getAccessToken(sumsubLevel:String):String? {
        return try {
            val blockingSingle = getMainModel().getAccessToken(sumsubLevel).blockingGet()
            if(blockingSingle.isSuccess){
                blockingSingle.data
            }else{
                Looper.prepare()
                ToastUtils.showToast(this, blockingSingle.msg)
                Looper.loop()
                ""
            }
        }catch (e:RuntimeException){
            e.printStackTrace()
            null
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        customTheme = null
    }

    override fun onMessageEvent(event: MessageEvent) {
        super.onMessageEvent(event)
        when(event.msg_type){
            MessageEvent.platform_auth_success_event -> {
                loadData()
            }
        }
    }

}