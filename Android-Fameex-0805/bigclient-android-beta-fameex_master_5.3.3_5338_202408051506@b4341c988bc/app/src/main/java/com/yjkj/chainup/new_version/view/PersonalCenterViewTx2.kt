package com.yjkj.chainup.new_version.view

import android.app.Activity
import android.content.Context
import android.util.AttributeSet
import android.view.LayoutInflater
import android.view.View
import android.widget.LinearLayout
import com.chainup.contract.utils.setSafeListener
import com.yjkj.chainup.R
import com.yjkj.chainup.db.constant.RoutePath
import com.yjkj.chainup.db.service.PublicInfoDataService
import com.yjkj.chainup.db.service.UserDataService
import com.yjkj.chainup.extra_service.arouter.ArouterUtil
import com.yjkj.chainup.manager.LanguageUtil
import com.yjkj.chainup.manager.LoginManager
import com.yjkj.chainup.util.ColorUtil
import com.yjkj.chainup.util.NToastUtil
import com.yjkj.chainup.util.Utils
import kotlinx.android.synthetic.main.personal_center_info_view_layout.view.*
import org.json.JSONObject

class PersonalCenterViewTx2 @JvmOverloads constructor(
    context: Context, attrs: AttributeSet? = null
) : LinearLayout(context, attrs) {
    private val mActivity:Activity = context as Activity

    var listener:OnViewClick? = null
    init {
        initView()
    }


    private fun initView(){
        LayoutInflater.from(context).inflate(R.layout.personal_center_info_view_layout,this,true)
        tv_login_no?.setText(LanguageUtil.getString(context, "personal_Center_text1"))
        setViewClick()
    }


    //Set whether to log in or not
    fun setIsLogin(isLogin:Boolean){
        if (isLogin) {
            tv_login_no.visibility=View.GONE
            ll_login_yes.visibility=View.VISIBLE
        }else{
            tv_login_no.visibility=View.VISIBLE
            ll_login_yes.visibility=View.GONE
        }
    }


    fun setUserInfo(t: JSONObject){
        tv_id.setText( t.optString("id"))
        tv_phone_tx?.text = t.optString("nickName",t.optString("userAccount","--"))
    }


    fun setCertificationTx(showName: String,isPass:Boolean) {
        tv_certification_tx?.text = showName
        when (isPass) {
            true -> {
                ll_certification_tx?.setBackgroundResource(R.drawable.bg_personal_authorized)
                tv_certification_tx?.setTextColor(ColorUtil.getColor(R.color.main_blue))
                iv_certification_tx?.setImageResource(R.drawable.personal_certified)
            }
            false -> {
                iv_certification_tx?.setImageResource(R.drawable.personal_notcertified)
//              iv_certification_tx?.setImageResource(R.drawable.personal_underreview)
                ll_certification_tx?.setBackgroundResource(R.drawable.bg_personal_unauthorized)
                tv_certification_tx?.setTextColor(ColorUtil.getColor(R.color.text_3))
            }
        }
    }

    private fun setViewClick(){
        setIsLogin(UserDataService.getInstance().isLogined)

        iv_back_tx.setOnClickListener {
            mActivity.finish()
        }

        tv_login_no.setOnClickListener {
            if (LoginManager.checkLogin(context, true)) {
                ArouterUtil.greenChannel(RoutePath.PersonalInfoActivity, null)
            }
        }

        ll_login_yes.setOnClickListener {
            if (LoginManager.checkLogin(context, true)) {
                ArouterUtil.greenChannel(RoutePath.PersonalInfoActivity, null)
            }
        }

        ll_certification_tx.setSafeListener {
            ArouterUtil.navigation(RoutePath.KycActivity,null)
        }

        //Copy ID
        tv_id.setOnClickListener {
            Utils.copyString(tv_id.text.toString())
            NToastUtil.showTopToastNet(mActivity,true, LanguageUtil.getString(mActivity, "common_tip_copySuccess"))
        }
        iv_copy.setOnClickListener {
            Utils.copyString(tv_id.text.toString())
            NToastUtil.showTopToastNet(mActivity,true, LanguageUtil.getString(mActivity, "common_tip_copySuccess"))
        }


        /**
         *Switch Theme Colors
         */
        val selecttheme = PublicInfoDataService.getInstance().themeMode
        var isNight=(selecttheme==0)
//        if (isNight){
//            right_icon_tx.setImageResource(R.drawable.personal_night)
//        }else{
//            right_icon_tx.setImageResource(R.drawable.personal_day)
//        }
        right_icon_tx.setOnClickListener {
            if (isNight){
                PublicInfoDataService.getInstance().themeMode = 1
//                right_icon_tx.setImageResource(R.drawable.personal_day)
            }else{
                PublicInfoDataService.getInstance().themeMode = 0
//                right_icon_tx.setImageResource(R.drawable.personal_night)
            }
            isNight=!isNight


            listener?.themeModeChange()

        }

    }

    interface OnViewClick{
        fun themeModeChange()
    }

}
