package com.chainup.kit.app

import android.app.Application
import android.content.Context
import com.chainup.kit.views.KKRefreshFooter
import com.chainup.kit.views.KKRefreshHeader
import com.example.chainup_kit.R
import com.scwang.smart.refresh.layout.SmartRefreshLayout
import com.scwang.smart.refresh.layout.api.RefreshFooter
import com.scwang.smart.refresh.layout.api.RefreshHeader
import com.scwang.smart.refresh.layout.api.RefreshLayout
import com.scwang.smart.refresh.layout.listener.DefaultRefreshFooterCreator
import com.scwang.smart.refresh.layout.listener.DefaultRefreshHeaderCreator


open class KitApp : Application() {
    val TAG = KitApp::class.java.simpleName


    companion object {
        private var instance: KitApp? = null
        fun instance() = instance!!
    }

    override fun attachBaseContext(base: Context?) {
        super.attachBaseContext(base)
    }

    override fun onCreate() {
        super.onCreate()
        instance = this
        initRefresh()
    }

    private fun initRefresh() {
        //Set the global header builder
        SmartRefreshLayout.setDefaultRefreshHeaderCreator(object :DefaultRefreshHeaderCreator{
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
