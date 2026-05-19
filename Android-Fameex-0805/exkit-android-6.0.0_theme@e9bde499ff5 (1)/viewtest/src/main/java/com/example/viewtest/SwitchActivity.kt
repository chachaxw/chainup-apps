package com.example.viewtest

import android.os.Bundle
import android.view.View
import androidx.appcompat.app.AppCompatActivity
import com.chainup.kit.bean.KKItemTabInfo
import com.chainup.kit.utils.ToastUtils
import com.chainup.kit.views.KKCommonListItemView
import com.chainup.kit.views.KKCommonTabKit
import com.chainup.kit.views.KKTradeTabBarKit
import com.chainup.kit.views.SwitchButtonView
import com.flyco.tablayout.CommonTabLayout
import com.flyco.tablayout.SlidingTabLayout
import com.flyco.tablayout.listener.CustomTabEntity
import java.util.*

class SwitchActivity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_switch)

        (findViewById<View>(R.id.s_btn) as SwitchButtonView).apply {
            this.listener=object :SwitchButtonView.OnKKSwitchListener{
                override fun onSwitch(b: Boolean) {
                    ToastUtils.showToast(this@SwitchActivity, if(b){"Open"}else{"Close"})
                }
            }
        }
    }
}