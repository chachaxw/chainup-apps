package com.example.viewtest

import android.os.Bundle
import android.view.Gravity
import androidx.appcompat.app.AppCompatActivity
import androidx.core.content.ContextCompat
import com.chainup.kit.bean.KKItemTabInfo
import com.chainup.kit.utils.ToastUtils
import com.chainup.kit.views.KKDropDownView
import com.chainup.kit.views.KKPopupSelectKit

class DropDownActivity : AppCompatActivity() {


    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_drop_down)

        findViewById<KKPopupSelectKit>(R.id.mSelectView).apply {
            val list = ArrayList<KKItemTabInfo>()
            list.add(KKItemTabInfo("固定宽度", 1))
            list.add(KKItemTabInfo("固定宽度21234123", 2))
            list.add(KKItemTabInfo("固定宽度3235123123123132", 3, true))
            this.data = list
            this.currentPosition = 1
            this.setTipVisible(true)
            this.listener=object : KKPopupSelectKit.OnKKPopupSelectListener{
                override fun onChangeSelect(position: Int) {
                    ToastUtils.showToast(this@DropDownActivity,"选中:$position")
                }

                override fun onPopTipClick(position: Int) {
                    ToastUtils.showToast(this@DropDownActivity,"选中:${position}出提示语")
                }

                override fun onSelectTipClick() {
                    ToastUtils.showToast(this@DropDownActivity,"提示语！")
                }

            }
        }

        findViewById<KKPopupSelectKit>(R.id.mSelectView_sp1).apply {
            val list = ArrayList<KKItemTabInfo>()
            list.add(KKItemTabInfo("固定宽度", 1))
            list.add(KKItemTabInfo("固定宽度21234123", 2))
            list.add(KKItemTabInfo("固定宽度3235123123123132", 3, true))
            this.data = list
            this.currentPosition = 1
            this.setTipVisible(true)
            this.setSelectorGravity(Gravity.LEFT)
            this.listener=object : KKPopupSelectKit.OnKKPopupSelectListener{
                override fun onChangeSelect(position: Int) {
                    ToastUtils.showToast(this@DropDownActivity,"选中:$position")
                }

                override fun onPopTipClick(position: Int) {
                    ToastUtils.showToast(this@DropDownActivity,"选中:${position}出提示语")
                }

                override fun onSelectTipClick() {
                    ToastUtils.showToast(this@DropDownActivity,"提示语！")
                }

            }
        }

        findViewById<KKPopupSelectKit>(R.id.mSelectView2).apply {
            val list = ArrayList<KKItemTabInfo>()
            list.add(KKItemTabInfo("自动宽度", 1))
            list.add(KKItemTabInfo("自动宽度21234123", 2))
            list.add(KKItemTabInfo("自动宽度32351231231231321", 3, true))
            this.data = list
            this.currentPosition = 1
            this.setTipVisible(false)
            this.listener=object : KKPopupSelectKit.OnKKPopupSelectListener{
                override fun onChangeSelect(position: Int) {
                    ToastUtils.showToast(this@DropDownActivity,"选中:$position")
                }

                override fun onPopTipClick(position: Int) {
                    ToastUtils.showToast(this@DropDownActivity,"选中:${position}出提示语")
                }

                override fun onSelectTipClick() {
                    ToastUtils.showToast(this@DropDownActivity,"提示语！")
                }

            }
        }

        findViewById<KKPopupSelectKit>(R.id.mSelectView3).apply {
            val list = ArrayList<KKItemTabInfo>()
            list.add(KKItemTabInfo("自定义targetView", 1))
            list.add(KKItemTabInfo("自定义targetView21234123", 2))
            list.add(KKItemTabInfo("自定义targetView32351231231231321", 3, true))
            this.data = list
            this.currentPosition = 1
            this.targetView = this@DropDownActivity.findViewById<KKPopupSelectKit>(R.id.mSelectView)
            this.setTipVisible(false)
            this.listener=object : KKPopupSelectKit.OnKKPopupSelectListener{
                override fun onChangeSelect(position: Int) {
                    ToastUtils.showToast(this@DropDownActivity,"选中:$position")
                }

                override fun onPopTipClick(position: Int) {
                    ToastUtils.showToast(this@DropDownActivity,"选中:${position}出提示语")
                }

                override fun onSelectTipClick() {
                    ToastUtils.showToast(this@DropDownActivity,"提示语！")
                }

            }
        }

        findViewById<KKPopupSelectKit>(R.id.psk_selector).setSelectorGravity(Gravity.LEFT)
        findViewById<KKPopupSelectKit>(R.id.psk_selector).data = arrayListOf(
            KKItemTabInfo("USDT",1),
            KKItemTabInfo("BTC",2),
            KKItemTabInfo("ETH",3),
            KKItemTabInfo("gggggggg",4),
            KKItemTabInfo("xxxxx",5)
        )
        findViewById<KKPopupSelectKit>(R.id.psk_selector).listener = object :KKPopupSelectKit.OnKKPopupSelectListener{
            override fun onChangeSelect(position: Int) {

            }

            override fun onPopTipClick(position: Int) {

            }

            override fun onSelectTipClick() {

            }

        }

        findViewById<KKPopupSelectKit>(R.id.psk_selector2).setSelectorGravity(Gravity.LEFT)
        findViewById<KKPopupSelectKit>(R.id.psk_selector2).data = arrayListOf(
            KKItemTabInfo("USDT",1),
            KKItemTabInfo("BTC",2),
            KKItemTabInfo("ETH",3),
            KKItemTabInfo("gggggggg",4),
            KKItemTabInfo("xxxxx",5)
        )
        findViewById<KKPopupSelectKit>(R.id.psk_selector3).setSelectorGravity(Gravity.LEFT)
        findViewById<KKPopupSelectKit>(R.id.psk_selector3).data = arrayListOf(
            KKItemTabInfo("USDT",1),
            KKItemTabInfo("BTC",2),
            KKItemTabInfo("ETH",3),
            KKItemTabInfo("gggggggg",4),
            KKItemTabInfo("xxxxx",5)
        )
        findViewById<KKPopupSelectKit>(R.id.psk_selector2).listener = object :KKPopupSelectKit.OnKKPopupSelectListener{
            override fun onChangeSelect(position: Int) {

            }

            override fun onPopTipClick(position: Int) {

            }

            override fun onSelectTipClick() {

            }

        }

        findViewById<KKDropDownView>(R.id.item_1).apply {
            this.setImageLeftIcon("https://saas-oss.oss-cn-hongkong.aliyuncs.com/upload/20211014165916050.png")
            this.setLeftTvTitle("BTC")
            this.setImageRightStatus("https://saas-oss.oss-cn-hongkong.aliyuncs.com/upload/20211014165916050.png",true)
            this.setOnClickListener {
                ToastUtils.showToast(this@DropDownActivity,"点击提示语！")
            }
        }

        findViewById<KKDropDownView>(R.id.item_2).apply {
            this.setImageRightIcon(R.drawable.ic_refresh_down)
            this.setRightTvTitle("BTC")
        }

        findViewById<KKDropDownView>(R.id.item_4).apply {

        }

        findViewById<KKDropDownView>(R.id.item_6).apply {
            this.setImageRightIcon("https://saas-oss.oss-cn-hongkong.aliyuncs.com/upload/20211014165916050.png")
            this.rightTvTitle = "BTC"
        }
    }
}