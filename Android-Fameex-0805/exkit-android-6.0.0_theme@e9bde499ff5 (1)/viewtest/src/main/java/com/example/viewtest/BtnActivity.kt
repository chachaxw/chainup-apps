package com.example.viewtest

import android.os.Bundle
import android.util.Log
import android.view.View
import androidx.appcompat.app.AppCompatActivity
import com.chainup.kit.KKDialogUtils
import com.chainup.kit.KKDialogUtils.Companion.showBottomSheetList
import com.chainup.kit.bean.KKItemTabInfo
import com.chainup.kit.utils.setSafeListener
import com.chainup.kit.views.KKButtonKit

class BtnActivity : AppCompatActivity() {


    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_btn)

        (findViewById<View>(R.id.kk_btn_1) as KKButtonKit).apply {
            this.setOnClickListener { view: View? ->

            }
        }
        (findViewById<View>(R.id.kk_btn_2) as KKButtonKit).apply {
            this.setOnClickListener { view: View? ->

            }
        }
        (findViewById<View>(R.id.kk_btn_3) as KKButtonKit).apply {
            this.setOnClickListener { view: View? ->

            }
        }
        (findViewById<View>(R.id.kk_btn_4) as KKButtonKit).apply {
            this.setOnClickListener { view: View? ->

            }
        }
        (findViewById<View>(R.id.kk_btn_5) as KKButtonKit).apply {
//            this.setOnClickListener { view: View? ->
//
//            }
            this.isEnable(false)
        }

        (findViewById<KKButtonKit>(R.id.kk_btn_9)).isEnable(false)
        (findViewById<KKButtonKit>(R.id.kk_btn_10)).isEnable(false)

        (findViewById<View>(R.id.kk_btn_6) as KKButtonKit).apply {
            this.setOnClickListener { view: View? ->

            }
        }
        (findViewById<View>(R.id.kk_btn_7) as KKButtonKit).apply {
            this.setOnClickListener { view: View? ->
                if(this.isLoading){
                    this.hideLoading()
                }else{
                    this.showLoading()
                }

            }
        }
        (findViewById<View>(R.id.kk_btn_8) as KKButtonKit).apply {
            this.setOnClickListener { view: View? ->

            }
        }

        (findViewById<View>(R.id.kk_btn_confirm) as KKButtonKit).setSafeListener {
            Log.e("setSafeListener","防连击confirm")
        }
        (findViewById<View>(R.id.kk_btn_cancel) as KKButtonKit).setSafeListener {
            Log.e("setSafeListener","防连击cancel")
        }
    }
}