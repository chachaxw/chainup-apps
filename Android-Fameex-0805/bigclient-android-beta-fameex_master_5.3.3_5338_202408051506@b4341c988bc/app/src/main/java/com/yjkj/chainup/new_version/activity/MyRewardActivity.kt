package com.yjkj.chainup.new_version.activity

import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.text.SpannableString
import android.text.Spanned
import android.text.style.AbsoluteSizeSpan
import android.text.style.ForegroundColorSpan
import android.view.View
import android.widget.TextView
import androidx.core.content.ContextCompat
import androidx.fragment.app.Fragment
import com.blankj.utilcode.util.GsonUtils
import com.chainup.contract.utils.CpBigDecimalUtils
import com.chainup.kit.KKDialogUtils
import com.chainup.kit.utils.ToastUtils
import com.yjkj.chainup.util.BigDecimalUtils
import com.yjkj.chainup.R
import com.yjkj.chainup.base.NBaseActivity
import com.yjkj.chainup.base.NBaseFragment
import com.yjkj.chainup.extra_service.eventbus.EventBusUtil
import com.yjkj.chainup.extra_service.eventbus.MessageEvent
import com.yjkj.chainup.manager.LanguageUtil
import com.yjkj.chainup.net_new.rxjava.NDisposableObserver
import com.yjkj.chainup.new_version.adapter.NVPagerAdapter
import com.yjkj.chainup.new_version.bean.RewardOverallBean
import com.yjkj.chainup.new_version.bean.WithdrawRewardInfoBean
import com.yjkj.chainup.new_version.fragment.CurrentRewardFragment
import com.yjkj.chainup.new_version.fragment.RewardRecordFragment
import com.yjkj.chainup.new_version.fragment.RewardWithdrawalRecordFragment
import kotlinx.android.synthetic.main.activity_my_reward.*
import org.json.JSONObject
import java.math.BigDecimal

/**
 * @see [RewardCenterActivity]
 * My Reward Activity
 * */
class MyRewardActivity : NBaseActivity() {
//    var rewardInfo :RewardOverallBean? = null
    var withdrawRewardInfo :WithdrawRewardInfoBean? = null
    private val tabArrays by lazy {
        arrayOf(
            LanguageUtil.getString(this,"myReward_text11"),
            LanguageUtil.getString(this,"myReward_text12"),
            LanguageUtil.getString(this,"myReward_text13"),
        )
    }
    private val fragments by lazy {
        arrayListOf<Fragment>(
            CurrentRewardFragment.newInstance(),
            RewardRecordFragment.newInstance(),
            RewardWithdrawalRecordFragment.newInstance()
        )
    }
    private var withdrawSwitch:Int = -1

    override fun setContentView(): Int = R.layout.activity_my_reward



    override fun onInit(savedInstanceState: Bundle?) {
        super.onInit(savedInstanceState)
        val bundleExtra = intent.getBundleExtra("data")
        bundleExtra?.run {
            withdrawSwitch = getInt(MyRewardActivity.withdrawSwitch)
        }
        initView()
        setClick()
        loadData()
    }

    private fun setClick() {
        sfl_refresh.setOnRefreshListener {
            loadData()
            val event = MessageEvent(MessageEvent.refresh_reward_detail)
            EventBusUtil.post(event)
        }
        btn_withdraw.setOnClickListener {
            KKDialogUtils.showCommonDialog(this,
                content = LanguageUtil.getString(this,"myReward_text8"),
                title = LanguageUtil.getString(this,"myReward_text7"),
                style = 3,
                isShowCancel = true,
                cancelTitle = LanguageUtil.getString(this,"common_text_btnCancel"),
                confrimTitle = LanguageUtil.getString(this,"common_text_btnConfirm"),
                listener = object: KKDialogUtils.DialogDoubleBottomListener{
                    override fun sendCancel() {

                    }

                    override fun sendConfirm() {
                        doWithdraw()
                    }

                }
            )
        }
    }

    private fun doWithdraw(){

        addDisposable(getMainModel().doWithdrawReward(consumer = object: NDisposableObserver(){
            override fun onResponseSuccess(jsonObject: JSONObject) {
                ToastUtils.showToast(this@MyRewardActivity,LanguageUtil.getString(this@MyRewardActivity,"myReward_text10"))
                loadData()
                val event = MessageEvent(MessageEvent.refresh_reward_detail)
                EventBusUtil.post(event)
            }

        }))
    }

    override fun initView() {
        super.initView()
        v_header.titleText = LanguageUtil.getString(this,"myReward_text2")
        tv_total_reward_money_label.text = LanguageUtil.getString(this,"myReward_text3")
        btn_withdraw.textContent = LanguageUtil.getString(this,"myReward_text6")
        btn_withdraw.isEnable(withdrawSwitch==1)
        formatTextStyle("0.00","USDT",tv_total_reward_money)
        tv_total_tip.text = "--"

        vp_container.adapter = NVPagerAdapter(supportFragmentManager,tabArrays.toList(),fragments)
        vp_container.offscreenPageLimit = 3
        st_tab.setViewPager(vp_container)
    }

    override fun loadData() {
        super.loadData()
//        addDisposable(getMainModel().getUserRewardOverall(consumer = object :NDisposableObserver(){
//            override fun onResponseSuccess(jsonObject: JSONObject) {
//                if(!jsonObject.isNull("data")){
//                    val dataStr = jsonObject.optString("data")
//                    rewardInfo = GsonUtils.fromJson(dataStr, RewardOverallBean::class.java)
//                    rewardInfo?.let {
//                        formatTextStyle(it.unWithdrawUsdtAmount,"USDT",tv_total_reward_money)
//                    }
//
//                }
//            }
//        }))
        addDisposable(getMainModel().getWithdrawRewardInfo(consumer = object :NDisposableObserver(){
            override fun onResponseSuccess(jsonObject: JSONObject) {
                if(!jsonObject.isNull("data")){
                    val dataStr = jsonObject.optString("data")
                    withdrawRewardInfo = GsonUtils.fromJson(dataStr, WithdrawRewardInfoBean::class.java)
                    withdrawRewardInfo?.let {
                        if(BigDecimalUtils.greaterThan(it.leftWithdrawPendingUsdt,"0")){
                            tv_total_tip.visibility = View.VISIBLE
                            val lanStr = String.format(LanguageUtil.getString(this@MyRewardActivity,"myReward_text4"),it.leftWithdrawPendingUsdt,LanguageUtil.getString(this@MyRewardActivity,"assets_text_exchange"))
                            formatTextTipStyle(it.leftWithdrawPendingUsdt,lanStr,tv_total_tip)
                            btn_withdraw.isEnable(false)
                        }else{
                            tv_total_tip.visibility = View.GONE
                            btn_withdraw.isEnable(withdrawSwitch==1)
                        }
                        formatTextStyle(it.withdrawPendingUsdt,"USDT",tv_total_reward_money)
                    }

                }
            }

            override fun onComplete() {
                super.onComplete()
                sfl_refresh.isRefreshing = false
            }
        }))
    }

    fun updateUSDTAmount(usdtAmount:String){
        formatTextStyle(usdtAmount,"USDT",tv_total_reward_money)
    }

    private fun formatTextStyle(amount:String,unit:String,view:TextView){
        var color= if(BigDecimal(amount).equals(BigDecimal.ZERO)){
            R.color.text_3
        }else{
            R.color.main_1
        }
        val value = "$amount $unit"
        val spannableString = SpannableString(value)
        val absoluteSizeSpan = AbsoluteSizeSpan(28, true)
        val absoluteSizeSpanUnit = AbsoluteSizeSpan(16, true)
        val foregroundColorSpan = ForegroundColorSpan(ContextCompat.getColor(this,color))
        val foregroundColorSpanUnit = ForegroundColorSpan(ContextCompat.getColor(this,R.color.text_1))
        spannableString.setSpan(absoluteSizeSpan,0,amount.length, Spanned.SPAN_EXCLUSIVE_INCLUSIVE)
        spannableString.setSpan(foregroundColorSpan,0,amount.length, Spanned.SPAN_EXCLUSIVE_INCLUSIVE)
        spannableString.setSpan(absoluteSizeSpanUnit,amount.length,value.length, Spanned.SPAN_EXCLUSIVE_INCLUSIVE)
        spannableString.setSpan(foregroundColorSpanUnit,amount.length,value.length, Spanned.SPAN_EXCLUSIVE_INCLUSIVE)
        view.setText(spannableString)
    }

    private fun formatTextTipStyle(leftWithdrawPendingUsdt:String,str:String,view: TextView){
        val position = str.indexOf("USDT")
        val spannableString = SpannableString(str)
        val foregroundColorSpan = ForegroundColorSpan(ContextCompat.getColor(this,R.color.text_1))
        spannableString.setSpan(foregroundColorSpan,position-leftWithdrawPendingUsdt.length-1,position+4, Spanned.SPAN_EXCLUSIVE_INCLUSIVE)
        view.setText(spannableString)
    }

    companion object {
        const val withdrawSwitch:String = "withdrawSwitch"
        fun enterActivity(context: Context,bundle: Bundle) {
            val intent = Intent(context,MyRewardActivity::class.java)
            intent.putExtra("data",bundle)
            context.startActivity(intent)
        }
    }
}