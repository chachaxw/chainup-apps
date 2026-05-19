package com.yjkj.chainup.new_version.activity.personalCenter

import android.content.Intent
import android.os.Bundle
import android.util.Log
import android.view.View
import android.widget.CompoundButton
import android.widget.Switch
import com.alibaba.android.arouter.facade.annotation.Route
 import com.chainup.contract.view.dialog.CpTDialog
import com.yjkj.chainup.R
import com.yjkj.chainup.app.AppConstant
import com.yjkj.chainup.base.NBaseActivity
import com.yjkj.chainup.db.constant.ParamConstant
import com.yjkj.chainup.db.constant.RoutePath
import com.yjkj.chainup.db.service.UserDataService
import com.yjkj.chainup.manager.LanguageUtil
import com.yjkj.chainup.net.HttpClient
import com.yjkj.chainup.net.retrofit.NetObserver
import com.yjkj.chainup.net_new.rxjava.NDisposableObserver
import com.yjkj.chainup.new_version.dialog.NewDialogUtils
import com.yjkj.chainup.util.DisplayUtil
import com.yjkj.chainup.util.Utils
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.schedulers.Schedulers
import kotlinx.android.synthetic.main.activity_rate_discount.*
import kotlinx.android.synthetic.main.activity_safety_setting.*
import kotlinx.android.synthetic.main.activity_verify_mobile_mail_google.*
import kotlinx.android.synthetic.main.activity_verify_mobile_mail_google.switch_gesture_pwd
import kotlinx.android.synthetic.main.activity_verify_mobile_mail_google.title_layout
import kotlinx.android.synthetic.main.activity_verify_mobile_mail_google.tv_title_name
import org.json.JSONObject

/**
 * @Author lianshangljl
 * @Date 2023/3/31-6:23 PM
 * @Email buptjinlong@163.com
 *@description verification page
 */
class RateDiscountActivity : NBaseActivity() {
    override fun setContentView(): Int {
        return R.layout.activity_rate_discount
    }


    override fun onInit(savedInstanceState: Bundle?) {
        super.onInit(savedInstanceState)
        initView()
        setOnClick()
    }


    override fun initView() {
//        title_layout?.setContentTitle(LanguageUtil.getString(this,"personal_Center_text30"))
        title_layout?.setContentTitle(LanguageUtil.getString(this,"personal_Center_text3"))
       val fee_trade_status= intent.getStringExtra("fee_trade_status")
//        tv_title_name?.setText(LanguageUtil.getString(this,"personal_Center_text30"))
        if (fee_trade_status.equals("1")){
//TV_ Title_ Name SetText ("Close or not")
            switch_gesture_pwd?.isChecked = true
//            switch_gesture_pwd.setBackgroundResource(R.drawable.open)
        }else{
//TV_ Title_ Name SetText ("Enable")
            switch_gesture_pwd?.isChecked = false
//            switch_gesture_pwd.setBackgroundResource(R.drawable.shut_down)
        }
      val mTradeCoin=  intent.getStringExtra("mTradeCoin")
      val mTrade=  intent.getStringExtra("mTrade")
//TV_ Tip. setText ("If you use ${mTradeCoin} to offset the spot transaction handling fee, you will enjoy a rate discount of ${mTrade}.")
        tv_tip.setText(String.format(LanguageUtil.getString(this,"personal_Center_text19"),mTrade))
        val content = LanguageUtil.getString(this,"personal_Center_text18")
        tv_title_name.setText(String.format(content,mTradeCoin,mTradeCoin))
    }


    fun setOnClick() {
        /**
         *Enable or disable validation
         */
        switch_gesture_pwd?.setOnCheckedChangeListener(object : CompoundButton.OnCheckedChangeListener {
            override fun onCheckedChanged(buttonView: CompoundButton?, isChecked: Boolean) {
                if (!buttonView!!.isPressed) return
                switch_gesture_pwd?.isChecked = isChecked
                updatePcTradeFeeStatus(if (!isChecked) "0" else "1")
                if (isChecked){
//TV_ Title_ Name SetText ("Close or not")
                }else{
//TV_ Title_ Name SetText ("Enable")
                }
            }
        })
    }



    /**
     *Rate discount switch status
     */
    fun updatePcTradeFeeStatus(status:String) {
        HttpClient.instance.updatePcTradeFeeStatus(status)
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(object : NetObserver<Any>() {
                    override fun onHandleSuccess(t: Any?) {
//                        if (switch_gesture_pwd?.isChecked!!) {
//                            switch_gesture_pwd.setBackgroundResource(R.drawable.open)
//                        } else {
//                            switch_gesture_pwd.setBackgroundResource(R.drawable.shut_down)
//                        }
                    }

                    override fun onHandleError(code: Int, msg: String?) {
                        super.onHandleError(code, msg)
                    }
                })
    }

}
