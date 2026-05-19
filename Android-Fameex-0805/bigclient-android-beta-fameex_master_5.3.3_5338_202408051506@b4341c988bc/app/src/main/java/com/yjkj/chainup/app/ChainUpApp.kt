package com.yjkj.chainup.app

import android.app.Activity
import android.app.ActivityManager
import android.app.Application
import android.content.Context
import android.content.Intent
import android.content.res.Configuration
import android.os.*
import android.util.Log
import android.webkit.WebView
import androidx.appcompat.app.AppCompatDelegate
import com.bilibili.boxing.BoxingCrop
import com.bilibili.boxing.BoxingMediaLoader
import com.bumptech.glide.Glide
import com.bumptech.glide.integration.okhttp3.OkHttpUrlLoader
import com.bumptech.glide.load.model.GlideUrl
import com.chad.library.adapter.base.module.LoadMoreModuleConfig
import com.chainup.contract.app.CpMyApp
import com.chainup.contract.utils.CpClLogicContractSetting
import com.chainup.contract.utils.CpLocalManageUtil
import com.chainup.contract.view.trade.ContractLoadMoreView
import com.chainup.contract.ws.CpWsContractAgentManager
import com.yjkj.chainup.util.SystemUtils
import com.yjkj.chainup.db.service.PublicInfoDataService
import com.chainup.talkingdata.AppAnalyticsExt
import com.igexin.sdk.PushManager
import com.yjkj.chainup.BuildConfig
import com.yjkj.chainup.db.constant.CommonConstant
import com.yjkj.chainup.db.service.UserDataService
import com.yjkj.chainup.extra_service.push.DemoPushService
import com.yjkj.chainup.extra_service.push.HandlePushIntentService
import com.yjkj.chainup.manager.DataInitService
import com.yjkj.chainup.net.api.ApiConstants
import com.yjkj.chainup.net_new.NetUrl
import com.yjkj.chainup.new_version.activity.asset.BoxingGlideLoader
import com.yjkj.chainup.new_version.activity.asset.BoxingUcrop
import com.yjkj.chainup.new_version.view.ForegroundCallbacksObserver
import com.yjkj.chainup.util.*
import com.yjkj.chainup.wedegit.ForegroundCallbacks
import com.yjkj.chainup.ws.WsAgentManager
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.disposables.Disposable
import okhttp3.OkHttpClient
import zendesk.android.FailureCallback
import zendesk.android.SuccessCallback
import zendesk.android.Zendesk
import zendesk.logger.Logger
import zendesk.messaging.android.DefaultMessagingFactory
import java.io.InputStream
import java.security.SecureRandom
import java.security.cert.X509Certificate
import java.util.concurrent.TimeUnit
import javax.net.ssl.*


/**
 * @Author: Bertking
 * @Date 2023/3/6-10:52 AM
 * @Description:
 */
class ChainUpApp : CpMyApp() {

    //    val TAG = ChainUpApp::class.java.simpleName
//    var appCount = 0
    private var appStateChangeListener: AppStateChangeListener? = null
    private var currentState: Int = 0
//    val STATE_FOREGROUND = 0
//    val STATE_BACKGROUND = 1

    companion object {
        lateinit var appContext: Context
        lateinit var app: Application
    }

    override fun onCreate() {
        super.onCreate()
        app = this
        LoadMoreModuleConfig.defLoadMoreView = ContractLoadMoreView()
        if (BuildConfig.APPLICATION_ID == getCurProcessName(this)) {
            appContext = this
            appStateChangeListener = getAppStateChangeListener()
            registerActivityLifecycleCallbacks(this)
            CommonComponent.getInstance().init(app)
            val headerParams = SystemUtils.getHeaderParams()
            LogUtil.e(TAG, "headerParams ${headerParams}")
            AppAnalyticsExt.instance.init(this, headerParams)

            CpClLogicContractSetting.setApiWsUrl(
                this,
                NetUrl.getContractNewUrl(),
                NetUrl.getContractSocketNewUrl()
            )

            Handler().postDelayed({
                WsAgentManager.instance.socketUrl(ApiConstants.SOCKET_ADDRESS, true)
//                WsContractAgentManager.instance.socketUrl(NetUrl.getContractSocketNewUrl(), true)
                CpWsContractAgentManager.instance.socketUrl(
                    CpClLogicContractSetting.getWsUrl(this),
                    true
                )
            }, 1500)
            setCurrentTheme()
            initAppStatusListener()

            /**
             *Contract_ Version_ Settings 0- Old version contract 1- New version contract
             *IsNewOldContract true new version false old version
             */
            var isNewOldContract: Boolean
            val mContractMode = PublicInfoDataService.getInstance().getContractMode()
            if (mContractMode == 0 || mContractMode == -1) {
                //Old version contract
                isNewOldContract = false
//                openContract()
            } else {
                //New contract
                isNewOldContract = true
            }

//            val isNewOldContract = PublicInfoDataService.getInstance().isNewOldContract
//            if (!isNewOldContract) {
//                openContract()
//            }
            AppConstant.IS_NEW_CONTRACT = isNewOldContract
            Debug.stopMethodTracing()
            BoxingMediaLoader.getInstance()
                .init(BoxingGlideLoader()) //Need to implement IBoxingMediaLoader
            BoxingCrop.getInstance().init(BoxingUcrop())
            ZenDeskUtils.initialize(app)
        }
        webViewSetPath(this)
        //Com. getui. demo. ChainUpPushService is a third-party custom push service
        PushManager.getInstance().initialize(this, DemoPushService::class.java)
        //Com. getui. demo. DemoIntentService is a third-party custom push service event receiving class
        PushManager.getInstance()
            .registerPushIntentService(this, HandlePushIntentService::class.java)
        PushManager.getInstance().setPrivacyPolicyStrategy(this, false)

        try {
            Glide.get(this).registry.replace(
                GlideUrl::class.java, InputStream::class.java,
                OkHttpUrlLoader.Factory(getSSLOkHttpClient()!!)
            )
        } catch (e: java.lang.Exception) {
            e.printStackTrace()
        }

//        Zendesk.initialize(app, ApiConstants.ZENDESK_KEY,object : SuccessCallback<Zendesk> {
//            override fun onSuccess(value: Zendesk) {
//               LogUtil.e("Zendesk","onSuccess")
//            }
//
//        },object : FailureCallback<Throwable> {
//            override fun onFailure(error: Throwable) {
//                LogUtil.e("Zendesk","onFailure"+error.message)
//            }
//
//        }, DefaultMessagingFactory())

//        Zendesk.INSTANCE.init(app, "https://newbt1.zendesk.com",
//                "48cf307a1fbf3fbb574a2791b830c8420f8879836bfc3b89",
//                "mobile_sdk_client_fa2f71680fccd2378d82");
//        val identity: Identity = AnonymousIdentity()
//        Zendesk.INSTANCE.setIdentity(identity)
//        Support.INSTANCE.init(Zendesk.INSTANCE);
//        AnswerBot.INSTANCE.init(Zendesk.INSTANCE, Support.INSTANCE);
//        Chat.INSTANCE.init(app, "newbt1.zendesk.com");
        Logger.setLoggable(true);
    }

    /**
     *Trust all certificates when setting up HTTPS access
     *
     * @throws Exception
     */
    private fun getSSLOkHttpClient(): OkHttpClient? {
        val trustManager: X509TrustManager = object : X509TrustManager {
            override fun checkClientTrusted(p0: Array<X509Certificate?>, p1: String?) {

            }

            override fun checkServerTrusted(p0: Array<X509Certificate?>, p1: String?) {
            }

            override fun getAcceptedIssuers(): Array<X509Certificate?> {
                return arrayOfNulls(0)
            }
        }
        val sslContext = SSLContext.getInstance("SSL")
        sslContext.init(null, arrayOf<TrustManager>(trustManager), SecureRandom())
        val sslSocketFactory = sslContext.socketFactory
        return OkHttpClient.Builder()
            .sslSocketFactory(sslSocketFactory, trustManager)
            .hostnameVerifier(HostnameVerifier { hostname, session -> true })
            .build()
    }

    private fun getProcessName(context: Context): String? {
        val am: ActivityManager =
            context.getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
        val runningApps: List<ActivityManager.RunningAppProcessInfo> = am.runningAppProcesses
            ?: return null
        for (proInfo in runningApps) {
            if (proInfo.pid == Process.myPid()) {
                if (proInfo.processName != null) {
                    return proInfo.processName
                }
            }
        }
        return null
    }

    private fun initAppStatusListener() {

        ForegroundCallbacks.init(ChainUpApp.app).addListener(object : ForegroundCallbacks.Listener {
            override fun onBecameForeground() {

                ForegroundCallbacksObserver.getInstance().ForegroundListener()
            }

            override fun onBecameBackground() {

                ForegroundCallbacksObserver.getInstance().CallBacksListener()
            }

            override fun onBackChange(visiable: Boolean) {
                ForegroundCallbacksObserver.getInstance().BackAppListener(visiable)
            }
        })
    }

    private fun setCurrentTheme() {
        val themeMode = PublicInfoDataService.getInstance().themeMode
        when (themeMode) {
            PublicInfoDataService.THEME_MODE_DAYTIME -> {
                AppCompatDelegate.setDefaultNightMode(AppCompatDelegate.MODE_NIGHT_NO)
            }

            PublicInfoDataService.THEME_MODE_NIGHT -> {
                AppCompatDelegate.setDefaultNightMode(AppCompatDelegate.MODE_NIGHT_YES)
            }
        }
    }


    override fun onConfigurationChanged(newConfig: Configuration) {
        super.onConfigurationChanged(newConfig)

        if (!SystemUtil().isMainProcessFun(this)) return

    LocalManageUtil.setApplicationLanguage()
    CpLocalManageUtil.setApplicationLanguage()
    if (newConfig.orientation == Configuration.ORIENTATION_LANDSCAPE) {
        
    }
    val isZhEnv = SystemUtils.isZh()
    //Notification Contract SDK Language Environment
    if (isZhEnv) {
        
        LocalManageUtil.saveSelectLanguage(this, "zh_CN")
        CpLocalManageUtil.saveSelectLanguage(this, "zh_CN")
    } else if (SystemUtils.isVietNam()) {
        
        LocalManageUtil.saveSelectLanguage(this, "vi_VN")
        CpLocalManageUtil.saveSelectLanguage(this, "vi_VN")
    }
}
//        LocalManageUtil.setApplicationLanguage()
//        CpLocalManageUtil.setApplicationLanguage()
//        if (newConfig.orientation == Configuration.ORIENTATION_LANDSCAPE) {
//
//        }
//        val isZhEnv = SystemUtils.isZh()
//        //Notification Contract SDK Language Environment
////    ContractSDKAgent.isZhEnv = isZhEnv
//        if (isZhEnv) {
//
//            LocalManageUtil.saveSelectLanguage(this, "zh_CN")
//            CpLocalManageUtil.saveSelectLanguage(this, "zh_CN")
//        } else if (SystemUtils.isVietNam()) {
//
//            LocalManageUtil.saveSelectLanguage(this, "vi_VN")
//            CpLocalManageUtil.saveSelectLanguage(this, "vi_VN")
//        }
//    }


    interface AppStateChangeListener {
        fun appTurnIntoForeground()
        fun appTurnIntoBackGround()
    }

    var isBackgroud = false
    private fun getAppStateChangeListener() = object : AppStateChangeListener {
        override fun appTurnIntoBackGround() {

            isBackgroud = true
            WsAgentManager.instance.isBackgroud = true
            restart()
        }

        override fun appTurnIntoForeground() {

            isBackgroud = true
            WsAgentManager.instance.isBackgroud = false
            startTime()
        }
    }

    var subscribe: Disposable? = null//Save subscribers
    fun startTime() {

        Log.e("LogUtils", "startTime time")
        restart()
        subscribe = io.reactivex.Observable.interval(
            0,
            CommonConstant.rateLoopTime,
            TimeUnit.SECONDS
        )//Sending Observeable integers at time intervals
            .observeOn(AndroidSchedulers.mainThread())//Switch to the main thread to modify the UI
            .subscribe {
                val intent = Intent(this, DataInitService::class.java)
                if (it > 1L) {
                    intent.putExtra("isFirst", true)
                }
                try {
                    startService(intent)
                } catch (e: Exception) {
                    e.printStackTrace()
                }
            }
    }

    /**
     *End timing, restart
     */
    fun restart() {
        Log.e("LogUtils", "dispose ${subscribe}")
        if (subscribe != null) {
            subscribe?.dispose()//Unsubscribe
            Log.e("LogUtils", "dispose time")
        }
    }

    private fun webViewSetPath(context: Context?) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            if (!SystemUtil().isMainProcessFun(this)) {//Determine if it is not equal to the default process name
                WebView.setDataDirectorySuffix(SystemV2Utils.getProcessName(context) ?: "")
            }
        }
    }

    private var timeCount = 0
    private fun initStrictMode() {
        StrictMode.setThreadPolicy(
            StrictMode.ThreadPolicy.Builder().detectDiskReads().detectDiskWrites().detectNetwork()
                .penaltyLog().build()
        )
        StrictMode.setVmPolicy(
            StrictMode.VmPolicy.Builder().detectLeakedSqlLiteObjects().detectLeakedClosableObjects()
                .penaltyLog().penaltyDeath().build()
        )
    }

    private fun getCurProcessName(context: Context): String? {
        val pid = Process.myPid()
        val activityManager = context.getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
        for (appProcess in activityManager.runningAppProcesses) {
            if (appProcess.pid == pid) {
                return appProcess.processName
            }
        }
        return null
    }

//private fun openContract() {
//    //The contract SDK initializes the main process before instantiating it
//    val contractHttpConfig = ContractHttpConfig()
//    contractHttpConfig.prefixHeader = "ex"
//    contractHttpConfig.contractUrl = NetUrl.getcontractUrl() + "fe-cov2-api/swap/"
//    contractHttpConfig.contractWsUrl = NetUrl.getContractSocketUrl()
//    contractHttpConfig.headerParams = SystemUtils.getHeaderParams()
//    contractHttpConfig.wsSignLength = 128
//    if (ContractCloudAgent.isCloudOpen) {
//        //Is it a contract cloud SDK
//        ContractSDKAgent.isContractCloudSDK = true
//    } else {
//        contractHttpConfig.aesSecret = "lMYQry09AeIt6PNO"
//        //Is it a contract cloud SDK
//        ContractSDKAgent.isContractCloudSDK = false
//    }
//    //Contract SDK Http Configuration Initialization
//    ContractSDKAgent.httpConfig = contractHttpConfig
//    //Whether to open contract API exception log collection
//    ContractSDKAgent.openErrorLogCollect = true
//    //Notification Contract SDK Language Environment
//    ContractSDKAgent.isZhEnv = SystemUtils.isZh()
//    //The contract SDK must be set to call at the end
//    ContractSDKAgent.init(this)
//    UserDataService.getInstance().token
//    //Delay 2 seconds to initialize contract token
//    UserDataService.getInstance().notifyContractLoginStatusListener()
//}

    override fun onActivityPaused(p0: Activity) {

    }

    override fun onActivityStarted(p0: Activity) {


        if (appCount == 0) {
            currentState = STATE_FOREGROUND
            appStateChangeListener?.appTurnIntoForeground()
        }
        appCount++

    }

    override fun onActivityDestroyed(p0: Activity) {

    }

    override fun onActivitySaveInstanceState(p0: Activity, p1: Bundle) {

    }

    override fun onActivityStopped(p0: Activity) {
        appCount--

        if (appCount == 0) {
            currentState = STATE_BACKGROUND
            appStateChangeListener?.appTurnIntoBackGround()
        }
    }

    override fun onActivityCreated(p0: Activity, p1: Bundle?) {

    }

    override fun onActivityResumed(p0: Activity) {

    }

}
