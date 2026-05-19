package com.chainup.contract.app

import android.app.Activity
import android.app.Application
import android.content.Context
import android.os.Bundle
import androidx.appcompat.app.AppCompatDelegate
import com.chainup.contract.listener.CpForegroundCallbacks
import com.chainup.contract.listener.CpForegroundCallbacksObserver
import com.chainup.contract.utils.ChainUpLogUtil
import com.chainup.contract.utils.CpClLogicContractSetting
import com.chainup.contract.utils.CpFlutterEngineCacheUtil
import com.chainup.kit.views.KKRefreshFooter
import com.chainup.kit.views.KKRefreshHeader
import com.example.chainup_kit.R
import com.scwang.smart.refresh.layout.SmartRefreshLayout
import com.scwang.smart.refresh.layout.api.RefreshFooter
import com.scwang.smart.refresh.layout.api.RefreshHeader
import com.scwang.smart.refresh.layout.api.RefreshLayout
import com.scwang.smart.refresh.layout.listener.DefaultRefreshFooterCreator
import com.scwang.smart.refresh.layout.listener.DefaultRefreshHeaderCreator


open class CpMyApp : Application(), Application.ActivityLifecycleCallbacks {
    val TAG = CpMyApp::class.java.simpleName
    var appCount = 0
    private var currentState: Int = 0
    private var appStateChangeListener: AppStateChangeListener? = null
    val STATE_FOREGROUND = 0
    val STATE_BACKGROUND = 1


    companion object {
        private var instance: CpMyApp? = null
        fun instance() = instance!!
    }

    override fun attachBaseContext(base: Context?) {
        super.attachBaseContext(base)
    }

    override fun onCreate() {
        super.onCreate()
        instance = this
        setCurrentTheme()
        initAppStatusListener()
        initRefresh()
        io.flutter.Log.setLogLevel(io.flutter.Log.VERBOSE)
    }


    override fun onLowMemory() {
        super.onLowMemory()
        CpFlutterEngineCacheUtil.removeAllEngine()
    }
    private fun setCurrentTheme() {
        val themeMode = CpClLogicContractSetting.getThemeMode(this)
        when (themeMode) {
            CpClLogicContractSetting.THEME_MODE_DAYTIME -> {
                AppCompatDelegate.setDefaultNightMode(AppCompatDelegate.MODE_NIGHT_NO)
            }
            CpClLogicContractSetting.THEME_MODE_NIGHT -> {
                AppCompatDelegate.setDefaultNightMode(AppCompatDelegate.MODE_NIGHT_YES)
            }
        }
    }

    private fun initAppStatusListener() {
        CpForegroundCallbacks.init(this).addListener(object : CpForegroundCallbacks.Listener {
            override fun onBecameForeground() {
                CpForegroundCallbacksObserver.getInstance().ForegroundListener()
            }

            override fun onBecameBackground() {
                CpForegroundCallbacksObserver.getInstance().CallBacksListener()
            }

            override fun onBackChange(visiable: Boolean) {
                CpForegroundCallbacksObserver.getInstance().BackAppListener(visiable)
            }
        })
    }

    override fun onActivityPaused(activity: Activity) {
        ChainUpLogUtil.e(TAG, "------------ onActivityPaused ------------")
    }

    override fun onActivityStarted(activity: Activity) {
        ChainUpLogUtil.e(TAG, "------------ onActivityStarted ------------")
        if (appCount == 0) {
            currentState = STATE_FOREGROUND
            appStateChangeListener?.appTurnIntoForeground()
        }
        appCount++
    }

    override fun onActivityDestroyed(activity: Activity) {
        ChainUpLogUtil.e(TAG, "------------ onActivityDestroyed ------------")
    }

    override fun onActivitySaveInstanceState(activity: Activity, outState: Bundle) {
        ChainUpLogUtil.e(TAG, "------------ onActivitySaveInstanceState ------------")
    }

    override fun onActivityStopped(activity: Activity) {
        ChainUpLogUtil.e(TAG, "------------ onActivityStopped ------------")
        appCount--
        if (appCount == 0) {
            currentState = STATE_BACKGROUND
            appStateChangeListener?.appTurnIntoBackGround()
        }
    }

    override fun onActivityCreated(activity: Activity, savedInstanceState: Bundle?) {
        ChainUpLogUtil.e(TAG, "------------ onActivityCreated ------------")
    }

    override fun onActivityResumed(activity: Activity) {
        ChainUpLogUtil.e(TAG, "------------ onActivityResumed ------------")
    }

    interface AppStateChangeListener {
        fun appTurnIntoForeground()
        fun appTurnIntoBackGround()
    }


    private fun initRefresh() {
        //Set the global header builder
        SmartRefreshLayout.setDefaultRefreshHeaderCreator(object : DefaultRefreshHeaderCreator {
            override fun createRefreshHeader(
                context: Context,
                layout: RefreshLayout
            ): RefreshHeader {
                layout.setPrimaryColorsId(R.color.transparent, R.color.text_color_1);//Global Theme Colors
                return  KKRefreshHeader(context).setArrowResource(R.drawable.ic_refresh_down).setEnableLastTime(false);
            }

        })
        //Set the global Footer builder
        SmartRefreshLayout.setDefaultRefreshFooterCreator(object : DefaultRefreshFooterCreator {
            override fun createRefreshFooter(
                context: Context,
                layout: RefreshLayout
            ): RefreshFooter {
                return  KKRefreshFooter(context).setProgressResource(R.drawable.ic_refresh_progress)
            }
        })
    }
}
