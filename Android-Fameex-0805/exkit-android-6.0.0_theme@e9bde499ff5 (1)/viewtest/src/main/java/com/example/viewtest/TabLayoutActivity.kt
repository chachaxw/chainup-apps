package com.example.viewtest

import android.os.Bundle
import android.view.View
import androidx.appcompat.app.AppCompatActivity
import com.chainup.kit.bean.KKItemTabInfo
import com.chainup.kit.utils.ToastUtils
import com.chainup.kit.views.KKCommonTabKit
import com.chainup.kit.views.KKTradeTabBarKit
import com.flyco.tablayout.CommonTabLayout
import com.flyco.tablayout.SlidingTabLayout
import com.flyco.tablayout.listener.CustomTabEntity

class TabLayoutActivity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_tablayout)
        var arrdata= arrayOfNulls<String>(11)
        var listdata=ArrayList<CustomTabEntity>()
        for (i in 0..10){
            listdata.add(KKItemTabInfo("Example-$i"))
            arrdata.set(i,"Example-$i")
        }
        (findViewById<View>(R.id.tab_1) as KKCommonTabKit).apply {
         this.setTabData(listdata.subList(0,2).toList() as ArrayList<CustomTabEntity>);
        }

        (findViewById<View>(R.id.tab_1_1) as KKCommonTabKit).apply {
           this.setTabData(listdata.subList(0,3).toList() as ArrayList<CustomTabEntity>);
        }

        (findViewById<View>(R.id.tab_1_2) as KKCommonTabKit).apply {
            this.setTabData(listdata.subList(0,4).toList() as ArrayList<CustomTabEntity>);
        }


        (findViewById<View>(R.id.tab_2) as SlidingTabLayout).apply {
            this.setTitle(arrdata.copyOfRange(0,2))
            this.currentTab=0
        }

        (findViewById<View>(R.id.tab_2_1) as SlidingTabLayout).apply {
            this.setTitle(arrdata.copyOfRange(0,3))
            this.currentTab=1
        }

        (findViewById<View>(R.id.tab_2_2) as SlidingTabLayout).apply {
            this.setTitle(arrdata.copyOfRange(0,4))
            this.currentTab=2
        }

        (findViewById<View>(R.id.tab_2_3) as SlidingTabLayout).apply {
            this.setTitle(arrdata)
            this.currentTab=3
        }

        (findViewById<View>(R.id.tab_3) as SlidingTabLayout).apply {
            this.setTitle(arrdata.copyOfRange(0,2))
            this.currentTab=0
        }

        (findViewById<View>(R.id.tab_3_1) as SlidingTabLayout).apply {
            this.setTitle(arrdata.copyOfRange(0,3))
            this.currentTab=1
        }

        (findViewById<View>(R.id.tab_3_2) as SlidingTabLayout).apply {
            this.setTitle(arrdata.copyOfRange(0,4))
            this.currentTab=2
        }

        (findViewById<View>(R.id.tab_3_3) as SlidingTabLayout).apply {
            this.setTitle(arrdata)
            this.currentTab=3
        }

        (findViewById<View>(R.id.tab_4) as SlidingTabLayout).apply {
            this.setTitle(arrdata.copyOfRange(0,2))
            this.currentTab=0
        }

        (findViewById<View>(R.id.tab_4_1) as SlidingTabLayout).apply {
            this.setTitle(arrdata.copyOfRange(0,3))
            this.currentTab=1
        }

        (findViewById<View>(R.id.tab_4_2) as SlidingTabLayout).apply {
            this.setTitle(arrdata.copyOfRange(0,4))
            this.currentTab=2
        }

        (findViewById<View>(R.id.tab_4_3) as SlidingTabLayout).apply {
            this.setTitle(arrdata)
            this.currentTab=3
        }

        (findViewById<View>(R.id.kk_trade_bibi) as KKTradeTabBarKit).apply {
           this.listener=object :KKTradeTabBarKit.OnKKTradeTabChangeListener{
               override fun onChange(position: Int) {
                   ToastUtils.showToast(this@TabLayoutActivity,if (position==0) "Buy" else "Sell")
               }
           }
        }

        (findViewById<View>(R.id.kk_trade_contract) as KKTradeTabBarKit).apply {
           this.listener=object :KKTradeTabBarKit.OnKKTradeTabChangeListener{
               override fun onChange(position: Int) {
                   ToastUtils.showToast(this@TabLayoutActivity,if (position==0) "Open" else "Close")
               }
           }
        }

    }
}