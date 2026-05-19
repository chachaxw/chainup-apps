package com.example.viewtest

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import androidx.appcompat.app.AppCompatActivity
import com.chainup.kit.utils.ToastUtils
import com.chainup.kit.views.PublicHeaderKit

class TitleActivity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_title)

        (findViewById<View>(R.id.mHeaderKit1) as PublicHeaderKit).apply {
            this.listener=object : PublicHeaderKit.IOnBackClickListener{
                override fun onTitleClick(view: View) {
                    super.onTitleClick(view)
                    ToastUtils.showToast(this@TitleActivity,"点击头部下拉")
                }
            }
        }

        (findViewById<View>(R.id.mHeaderKit3) as PublicHeaderKit).apply {
            this.setFilterTitleContent("ETH/USDT")
            this.listener=object : PublicHeaderKit.IOnBackClickListener{

                override fun onRightBtn(view: View) {
                    super.onRightBtn(view)
                    ToastUtils.showToast(this@TitleActivity,"显示更多菜单")
                }

                override fun onFilterTitle(view: View) {
                    super.onFilterTitle(view)
                    ToastUtils.showToast(this@TitleActivity,"显示侧边栏")
                }

                override fun onSubRightBtn(view: View) {
                    super.onSubRightBtn(view)
                    ToastUtils.showToast(this@TitleActivity,"显示K线详情页")
                }
            }
        }
        (findViewById<View>(R.id.mHeaderKit8) as PublicHeaderKit).apply {
            this.setRightIconGone(true)
        }
        (findViewById<View>(R.id.mHeaderKit4) as PublicHeaderKit).apply {
            this.setFilterTitleContent("BNB/USDT")
            this.setCoinChgValue("+0.65%")
        }
        (findViewById<View>(R.id.mHeaderKit5) as PublicHeaderKit).apply {
            this.setFilterTitleContent("BTC/USDT")
        }
        val rightView = LayoutInflater.from(this).inflate(R.layout.layout_header_custom_staking,null)
        (findViewById<View>(R.id.mHeaderKit7) as PublicHeaderKit).setRightCustomLayout(rightView)
    }
}