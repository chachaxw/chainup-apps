package com.yjkj.chainup.new_version.activity.personalCenter

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.util.DisplayMetrics
import android.view.Gravity
import android.view.View
import androidx.appcompat.app.AppCompatActivity
import com.alibaba.android.arouter.facade.annotation.Route
import com.qmuiteam.qmui.util.QMUIDisplayHelper
import com.yjkj.chainup.R
import com.yjkj.chainup.base.NBaseActivity
import com.yjkj.chainup.db.constant.RoutePath
import com.yjkj.chainup.extra_service.eventbus.EventBusUtil
import com.yjkj.chainup.extra_service.eventbus.MessageEvent
import com.yjkj.chainup.manager.LanguageUtil
import com.yjkj.chainup.new_version.activity.NewBaseActivity
import com.yjkj.chainup.util.LocalManageUtil
import kotlinx.android.synthetic.main.activity_real_name_success.*

/**
 * @Author lianshangljl
 * @Date 2023/5/20-9:29 AM
 * @Email buptjinlong@163.com
 *@description Real name authentication success page
 */
@Route(path = RoutePath.RealNameCertificaionSuccessActivity)
class RealNameCertificaionSuccessActivity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_real_name_success)
        iv_back?.setOnClickListener { finish() }
        tv_common_tip_cerSubmitSuccess?.text = LanguageUtil.getString(this,"common_tip_cerSubmitSuccess")
        tv_common_tip_cerSubmitDesc?.text = LanguageUtil.getString(this,"common_tip_cerSubmitDesc")
        iv_back?.text = LanguageUtil.getString(this,"common_text_close")

        val mDisplay = getWindowManager().getDefaultDisplay()
        val outMetrics =  DisplayMetrics()
        mDisplay.getMetrics(outMetrics)
        val layoutParams = getWindow().getAttributes()
        layoutParams.width = QMUIDisplayHelper.getScreenWidth(this)
        layoutParams.gravity= Gravity.BOTTOM
        layoutParams.height = QMUIDisplayHelper.getScreenHeight(this)-100
        getWindow().setAttributes(layoutParams)

    }
    override fun attachBaseContext(newBase: Context?) {
        super.attachBaseContext(LocalManageUtil.setLocal(newBase))
    }

    override fun onDestroy() {
        EventBusUtil.post(MessageEvent(MessageEvent.platform_auth_success_event))
        super.onDestroy()
    }
}
