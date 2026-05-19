package com.yjkj.chainup.new_version.activity

import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.util.Log
import android.view.View
import android.widget.LinearLayout
import androidx.core.content.ContextCompat
import androidx.fragment.app.Fragment
import androidx.recyclerview.widget.GridLayoutManager
import com.blankj.utilcode.util.GsonUtils
import com.blankj.utilcode.util.SizeUtils
import com.bumptech.glide.request.RequestOptions
import com.chad.library.adapter.base.BaseQuickAdapter
import com.chad.library.adapter.base.viewholder.BaseViewHolder
import com.chainup.kit.utils.ToastUtils
import com.chainup.kit.views.PublicHeaderKit
import com.google.gson.reflect.TypeToken
import com.yjkj.chainup.R
import com.yjkj.chainup.base.NBaseActivity
import com.yjkj.chainup.base.NBaseFragment
import com.yjkj.chainup.db.constant.RoutePath
import com.yjkj.chainup.db.service.PublicInfoDataService
import com.yjkj.chainup.db.service.UserDataService
import com.yjkj.chainup.extra_service.arouter.ArouterUtil
import com.yjkj.chainup.extra_service.eventbus.MessageEvent
import com.yjkj.chainup.manager.LanguageUtil
import com.yjkj.chainup.manager.LoginManager
import com.yjkj.chainup.net_new.rxjava.NDisposableObserver
import com.yjkj.chainup.new_version.activity.personalCenter.GoogleValidationActivity
import com.yjkj.chainup.new_version.adapter.NVPagerAdapter
import com.yjkj.chainup.new_version.bean.ItemTaskBean
import com.yjkj.chainup.new_version.bean.SignInInfoBean
import com.yjkj.chainup.new_version.dialog.NewDialogUtils
import com.yjkj.chainup.new_version.fragment.RewardListFragment
import com.yjkj.chainup.util.GlideUtils
import com.yjkj.chainup.util.LocalManageUtil
import kotlinx.android.synthetic.main.activity_reward_center.*
import kotlinx.android.synthetic.main.activity_scan.headerView
import org.jetbrains.anko.support.v4.act
import org.json.JSONObject
import java.util.Locale

class RewardCenterActivity : NBaseActivity(), PublicHeaderKit.IOnBackClickListener {
    private val tabArrays by lazy {
        arrayOf(
            LanguageUtil.getString(this,"rewardCenter_text16"),
            LanguageUtil.getString(this,"rewardCenter_text17"),
            LanguageUtil.getString(this,"rewardCenter_text18"),
//            LanguageUtil.getString(this,"rewardCenter_text19"),
        )
    }
    private val fragments = arrayListOf<Fragment>()
    private var signInInfo:SignInInfoBean? = null
    private val signAdapter by lazy { CheckListAdapter() }
    private var signPosition:Int = -1
    private var withdrawSwitch:Int = -1
    var rewardReceiveTerm:Int = 0
    var rewardReceiveType:Int = 0

    override fun setContentView(): Int = R.layout.activity_reward_center

    override fun onInit(savedInstanceState: Bundle?) {
        super.onInit(savedInstanceState)
        initView()
        setClick()
    }
    override fun initView() {
        super.initView()
        v_header.titleText = LanguageUtil.getString(this,"menus_rewardCenter")
        v_header.setTvRightText(LanguageUtil.getString(this,"myReward_text2"))
        btn_check.textContent = LanguageUtil.getString(this,"rewardCenter_text12")
        fragments.add(RewardListFragment.newInstance())
        fragments.add(RewardListFragment.newInstance(1))
        fragments.add(RewardListFragment.newInstance(0))
//        fragments.add(RewardListFragment.newInstance())
        vp_container.adapter = NVPagerAdapter(supportFragmentManager,tabArrays.toList(),fragments)
        st_tab.setViewPager(vp_container)
        rv_checklist?.run {
            layoutManager = GridLayoutManager(this@RewardCenterActivity,7)
            adapter = signAdapter
        }

        val defBannerRes = if(LocalManageUtil.getSetLanguageLocale() == Locale.CHINA){
            ContextCompat.getDrawable(this@RewardCenterActivity,R.mipmap.task_banner_zh)
        }else{
            ContextCompat.getDrawable(this@RewardCenterActivity,R.mipmap.task_banner_en)
        }
        iv_banner.setImageDrawable(defBannerRes)
    }


    private fun setClick(){
        v_header.listener = this
        btn_check.setOnClickListener {
            if(!LoginManager.checkLogin(this,true)) return@setOnClickListener
            signInInfo?.run {
                if(isKyc==1){
                    if(UserDataService.getInstance().authLevel != 1){
                        showUnPassDialog(isTwoCheck==1,true)
                        return@setOnClickListener
                    }
                }
                if(isTwoCheck==1){
                    if(UserDataService.getInstance().googleStatus!=1){
                        showUnPassDialog(true,isKyc==1)
                        return@setOnClickListener
                    }
                }
                doSignIn()
            }
        }

        sfl_refresh.setOnRefreshListener {
            loadData()
            for(fragment in fragments){
                val basefg = fragment as NBaseFragment
                if(basefg.activity != null) {
                    basefg.loadData()
                }
            }
        }
    }

    private fun showUnPassDialog(googleValid:Boolean, identifyValid:Boolean){
        NewDialogUtils.showRewardSignUnPassDialog(
            this@RewardCenterActivity,
            listener = object : NewDialogUtils.DialogBottomListener{
                override fun sendConfirm() {

                }

                override fun sendConfirm(view:View) {
                    when(view.id){
                        R.id.tv_realname_certification -> {
                            when (UserDataService.getInstance().authLevel) {
                                0 -> {
                                    ArouterUtil.navigation(RoutePath.RealNameCertificaionSuccessActivity, null)
                                }

                                2, 3 -> {
                                    ArouterUtil.navigation(RoutePath.RealNameCertificationActivity, null)
                                }
                            }
                        }
                        R.id.tv_google -> {
                            val intent = Intent(this@RewardCenterActivity,
                                GoogleValidationActivity::class.java)
                            startActivity(intent)
//                            ArouterUtil.navigation(RoutePath.SafetySettingActivity, null)
                        }
                    }
                }

        },googleValid=googleValid, identifyValid=identifyValid, title = LanguageUtil.getString(this,"common_text_tip"))
    }

    private fun doSignIn(){
        addDisposable(
            getMainModel().doSignIn(consumer = object: NDisposableObserver(){
                override fun onResponseSuccess(jsonObject: JSONObject) {
                    signPosition++
                    if(signPosition>6) signPosition=0
                    val signModel = signAdapter.data[signPosition]
                    signModel.isSign = true
                    btn_check.isEnabled = false
                    loadData()
                    NewDialogUtils.showSignSuccessDialog(this@RewardCenterActivity,signModel.reward,signModel.rewardCoin)
                }

                override fun onResponseFailure(code: Int, msg: String?) {
                    super.onResponseFailure(code, msg)
                    ToastUtils.showToast(this@RewardCenterActivity,LanguageUtil.getString(this@RewardCenterActivity,msg?:""))
                }
            })
        )
    }

    override fun loadData() {
        super.loadData()

        addDisposable(getMainModel().getTaskCenterIndex(consumer = object : NDisposableObserver(){
            override fun onResponseSuccess(jsonObject: JSONObject) {
                if(!jsonObject.isNull("data")){
                    val dataObj = jsonObject.getJSONObject("data")
                    val themeMode = PublicInfoDataService.getInstance().getThemeModeNew()
                    val bannerUrl = if("night".equals(themeMode)) dataObj.optString("nightBannerImageH5Url") else dataObj.optString("bannerImageH5Url")
                    val signSwitch = dataObj.optInt("signSwitch")
                    val signInInfoStr = dataObj.optString("signInInfo")
                    withdrawSwitch = dataObj.optInt("withdrawSwitch")
                    rewardReceiveTerm = dataObj.optInt("rewardReceiveTerm")
                    rewardReceiveType = dataObj.optInt("rewardReceiveType")
                    signInInfo = GsonUtils.fromJson(signInInfoStr, SignInInfoBean::class.java)
                    signPosition = signInInfo?.let {
                        if(it.rewardDetails.isNullOrEmpty()) -1
                        else it.rewardDetails.size-1
                    }?:-1

                    val defBannerRes = if(LocalManageUtil.getSetLanguageLocale() == Locale.CHINA){
                        ContextCompat.getDrawable(this@RewardCenterActivity,R.mipmap.task_banner_zh)
                    }else{
                        ContextCompat.getDrawable(this@RewardCenterActivity,R.mipmap.task_banner_en)

                    }
                    val options = RequestOptions().placeholder(defBannerRes).error(defBannerRes)
                    GlideUtils.load(this@RewardCenterActivity,bannerUrl,iv_banner,options)

                    qll_sign.visibility = if(signSwitch==1) View.VISIBLE else View.GONE
                    val st_tab = st_tab.layoutParams as LinearLayout.LayoutParams
                    st_tab.topMargin=if(signSwitch==1)  SizeUtils.dp2px(0f) else SizeUtils.dp2px(12f)
                    signInInfo?.run {
                        btn_check.isEnabled = this.isSignIn != 1
                        if(isSignIn==1) {
                            btn_check.textContent = LanguageUtil.getString(this@RewardCenterActivity,"rewardCenter_text11")
                        }else{
                            btn_check.textContent = LanguageUtil.getString(this@RewardCenterActivity,"rewardCenter_text12")
                        }
                        signAdapter.setList(createSignList(rewards,rewardDetails))
                        tv_sign_title.text = String.format(LanguageUtil.getString(this@RewardCenterActivity,"rewardCenter_text2"),seriateSignInNum)
                        tv_sign_subtitle.text = String.format(LanguageUtil.getString(this@RewardCenterActivity,"rewardCenter_text3"),PublicInfoDataService.getInstance().serviceTimeZone)
                    }
                    for(itemFragment in this@RewardCenterActivity.fragments){
                        val rewardListFragment = itemFragment as RewardListFragment
                        if(rewardListFragment.mIsVisibleToUser){
                            rewardListFragment.updateHeadView(rewardReceiveTerm,rewardReceiveType)
                        }
                    }
                }
            }

            override fun onComplete() {
                super.onComplete()
                sfl_refresh.setRefreshing(false)
            }

        }))


    }

    override fun onRightBtn(view: View) {
        super.onRightBtn(view)
        if(LoginManager.checkLogin(this,true)){
            MyRewardActivity.enterActivity(this,Bundle().apply {
                putInt(MyRewardActivity.withdrawSwitch,withdrawSwitch)
            })
        }

    }

    override fun onResume() {
        super.onResume()
        loadData()
        for(fragment in fragments){
            val basefg = fragment as NBaseFragment
            if(basefg.activity != null) {
                basefg.loadData()
            }
        }
    }

    companion object {
        fun enterActivity(context: Context) {
            val intent = Intent(context,RewardCenterActivity::class.java)
            context.startActivity(intent)
        }
    }

    private fun createSignList(reward: List<String>,rewardDetails: List<SignInInfoBean.RewardDetail>?):List<SignModel>{
        val newList = arrayListOf<SignModel>()
        if(signInInfo == null) return newList

        if(!rewardDetails.isNullOrEmpty()){
            for(item in rewardDetails){
                newList.add(SignModel(item.reward, item.rewardCoin, true))
            }
            val unSignRewardList = reward.subList(rewardDetails.size,reward.size)
            val rewardCoin = signInInfo!!.rewardCoin
            for(item in unSignRewardList){
                newList.add(SignModel(item, rewardCoin, false))
            }
        }else{
            val rewardCoin = signInInfo!!.rewardCoin
            for(item in reward){
                newList.add(SignModel(item, rewardCoin, false))
            }
        }

        return newList
    }

    internal class CheckListAdapter : BaseQuickAdapter<SignModel,BaseViewHolder>(R.layout.item_check_view){
        override fun convert(holder: BaseViewHolder, item: SignModel) {
            holder.itemView.isSelected = item.isSign
            holder.setText(R.id.tv_amount,item.reward)
            holder.setTextColorRes(R.id.tv_amount,if(item.isSign) R.color.white else R.color.text_3)
            holder.setText(R.id.tv_unit,item.rewardCoin)
            holder.setText(R.id.tv_no,(holder.adapterPosition+1).toString())
            holder.setTextColorRes(R.id.tv_no,if(item.isSign) R.color.white else R.color.text_3)
        }

    }
    data class SignModel(val reward:String, val rewardCoin:String, var isSign:Boolean = false)
}