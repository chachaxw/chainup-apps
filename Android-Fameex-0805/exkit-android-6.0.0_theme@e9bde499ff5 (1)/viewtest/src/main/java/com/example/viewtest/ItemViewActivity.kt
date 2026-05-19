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

class ItemViewActivity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_itemview)

        (findViewById<View>(R.id.kkItemViewItem0) as KKCommonListItemView).apply {
            this.setOnClickListener(object :View.OnClickListener{
                override fun onClick(p0: View?) {
                    ToastUtils.showToast(this@ItemViewActivity, "点击了1")
                }
            })
        }
        (findViewById<View>(R.id.kkItemViewItem4) as KKCommonListItemView).apply {
            this.setOnClickListener(object :View.OnClickListener{
                override fun onClick(p0: View?) {
                    ToastUtils.showToast(this@ItemViewActivity, "点击了1")
                }
            })
            this.setSwitchListener(object :SwitchButtonView.OnKKSwitchListener{
                override fun onSwitch(b: Boolean) {
                    ToastUtils.showToast(this@ItemViewActivity, if (b){"Open"}else{"Close"})
                }
            })
        }
        (findViewById<View>(R.id.kkItemViewItem4) as KKCommonListItemView).isSwitchClick(true)
    }
}