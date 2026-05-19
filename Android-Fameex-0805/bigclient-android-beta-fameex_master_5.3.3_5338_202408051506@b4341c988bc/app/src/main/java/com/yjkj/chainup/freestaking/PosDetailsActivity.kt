package com.yjkj.chainup.freestaking

import android.annotation.SuppressLint
import android.graphics.Typeface
import android.os.Bundle
import android.text.*
import android.text.style.ForegroundColorSpan
import com.bumptech.glide.Glide
import com.yjkj.chainup.R
import com.yjkj.chainup.manager.LoginManager
import com.yjkj.chainup.net.HttpClient
import com.yjkj.chainup.net.retrofit.NetObserver
import io.reactivex.android.schedulers.AndroidSchedulers
import android.text.style.AbsoluteSizeSpan
import android.text.style.StyleSpan
import android.view.LayoutInflater
import android.view.View
import android.widget.EditText
import android.widget.ImageView
import android.widget.TextView
import androidx.core.content.ContextCompat
import androidx.recyclerview.widget.LinearLayoutManager
import com.alibaba.android.arouter.facade.annotation.Route
import com.chainup.kit.utils.PublicSizeUtil
import com.chainup.kit.views.KKEmptyViewKit
import com.chainup.kit.views.base.BaseEditTextKit
import com.fengniao.news.util.DateUtil
import com.scwang.smartrefresh.layout.util.DensityUtil
import com.yjkj.chainup.app.ChainUpApp
import com.yjkj.chainup.db.constant.ParamConstant
import com.yjkj.chainup.db.constant.RoutePath
import com.yjkj.chainup.db.constant.WebTypeEnum
import com.yjkj.chainup.db.service.UserDataService
import com.yjkj.chainup.extra_service.arouter.ArouterUtil
import com.yjkj.chainup.freestaking.adapter.IncomeRecyclerAdapter
import com.yjkj.chainup.freestaking.bean.FreeStakingDetailBean
import com.yjkj.chainup.freestaking.bean.NotificationRefreshBean
import com.yjkj.chainup.freestaking.bean.UserGainListBean
import com.yjkj.chainup.manager.LanguageUtil
import com.yjkj.chainup.manager.NCoinManager
import com.yjkj.chainup.model.model.MainModel
import com.yjkj.chainup.net.api.HTTPCode
import com.yjkj.chainup.net.api.HttpResult
import com.yjkj.chainup.new_version.activity.NewBaseActivity
import com.yjkj.chainup.new_version.dialog.NewDialogUtils
import com.yjkj.chainup.util.BigDecimalUtils
import com.yjkj.chainup.util.CommonCountDownTimer
import com.yjkj.chainup.util.DisplayUtil
import com.yjkj.chainup.util.JsonUtils
import com.yjkj.chainup.util.tr
import io.reactivex.Observable
import io.reactivex.functions.BiFunction
import io.reactivex.schedulers.Schedulers
import kotlinx.android.synthetic.main.activity_free_staking.v_head
import kotlinx.android.synthetic.main.activity_pos_details.*
import kotlinx.android.synthetic.main.detail_head_layout.*
import kotlinx.android.synthetic.main.expected_return_layout.*
import kotlinx.android.synthetic.main.income_breakdown_layout.*
import kotlinx.android.synthetic.main.pos_rules_layout.*
import org.greenrobot.eventbus.EventBus
import org.jetbrains.anko.textColor
import org.json.JSONObject
import java.math.BigDecimal


/**
 *PoS Details Page
 */
const val PROJECT_NAME = "project_name"
const val PROJECT_INFO = "project_info"
fun BigDecimal.formatAmount(scale: Int = 2): BigDecimal {
    return this.setScale(scale, BigDecimal.ROUND_DOWN)
}

@Route(path = RoutePath.PosDetailsActivity)
class PosDetailsActivity : NewBaseActivity() {

    private var itemId: Int = 0
    private var projectType: Int = 0
    var msgUrl = ""
    var projectName: String? = ""
    var projectInfo: String? = ""
    lateinit var adapter: IncomeRecyclerAdapter
    var countDownTimer: CommonCountDownTimer? = null
    private var ivIcon: ImageView? = null
    private var ivText: TextView? = null
    private var isShowAuthDialog:Boolean = false
    private var mIncomeList:ArrayList<UserGainListBean> = arrayListOf()
    private val mainModel by lazy { MainModel() }
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_pos_details)
        this.itemId = intent.getIntExtra(ITEM_ID, 0)
        this.projectType = intent.getIntExtra(PROJECT_TYPE, 0)
        initView()
    }

    @SuppressLint("NewApi")
    private fun initView() {

        val rightView = LayoutInflater.from(this).inflate(R.layout.layout_header_custom_staking,null)
        ivIcon = rightView.findViewById(R.id.ic_image)
        ivText = rightView.findViewById(R.id.tv_text)

        v_head.setTitleContent("")
        v_head.setRightCustomLayout(rightView)

        when (projectType) {
            1 -> {
                ll_activityProgressParent.visibility = View.GONE
                cb_agree.visibility = View.GONE
                btn_agree.visibility = View.GONE
            }
            3 -> {
                rl_activityProgressParent.visibility = View.GONE
            }

        }

        cb_agree.setOnCheckedChangeListener { _, isChecked ->
            if (isChecked && et_number.getText().isNotBlank()) {
                btn_agree.setBackgroundResource(R.drawable.agreebtn_click)
                btn_agree.isEnabled = true
            } else {
                btn_agree.setBackgroundResource(R.drawable.agreebtn_unclick)
                btn_agree.isEnabled = false

            }
        }
        tv_interestRate.setText(LanguageUtil.getString(this,"pos_string_interestRate"))
        tv_details.setText(LanguageUtil.getString(this,"pos_string_detail"))
        tv_grandTotal.setText(LanguageUtil.getString(this,"pos_string_allEarn"))
        tv_already.setText(LanguageUtil.getString(this,"pos_string_myEarn"))
        tv_process.setText(LanguageUtil.getString(this,"pos_string_process"))
        tv_process_2.setText(LanguageUtil.getString(this,"pos_string_process"))
        tv_recruitmentStart.setText(LanguageUtil.getString(this,"pos_state_lockStart"))
        tv_recruitmentEnd.setText(LanguageUtil.getString(this,"pos_state_lockEnd"))
        tv_interestStart.setText(LanguageUtil.getString(this,"pos_state_InterestStart"))
        tv_interestEnd.setText(LanguageUtil.getString(this,"pos_state_InterestEnd"))
        tv_lockProcess.setText(LanguageUtil.getString(this,"pos_string_lockProcess"))
        tv_toutalAmount.setText(LanguageUtil.getString(this,"pos_string_toutalAmount"))
        tv_state_locked.setText(LanguageUtil.getString(this,"pos_state_locked"))
        tv_state_allEarn.setText(LanguageUtil.getString(this,"pos_string_allEarn"))
        tv_state_myEarn.setText(LanguageUtil.getString(this,"pos_string_myEarn"))
        tv_earnDetail.setText(LanguageUtil.getString(this,"pos_string_earnDetail"))
        tv_allDetail.setText(LanguageUtil.getString(this,"pos_string_all"))
        tv_income_time.setText(LanguageUtil.getString(this,"pos_string_timeEarn"))
        tv_income_number.setText(LanguageUtil.getString(this,"pos_string_earnNumber"))
        cb_agree.setText(LanguageUtil.getString(this,"pos_sting_potocolTitle"))
        tv_rules_title.setText(LanguageUtil.getString(this,"pos_state_rules"))
        tv_rules_title.setText(LanguageUtil.getString(this,"pos_state_rules"))
        btn_agree.setText(LanguageUtil.getString(this,"pos_sting_agree"))
        initIncomeListAdapter()
    }


    override fun onResume() {
        super.onResume()
        getProjectDetail(itemId.toString())

    }

    /**
     *Project subscription
     */
    fun requestTOBuy(amount: String, projectId: Int) {
        HttpClient.instance.requestToBuy(amount, projectId)
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(object : NetObserver<Any>() {
                    override fun onHandleSuccess(t: Any?) {

                        NewDialogUtils.showSuccessDialog(this@PosDetailsActivity, getString(R.string.pos_buy_success), true, object : NewDialogUtils.DialogBottomListener {
                            override fun sendConfirm() {
                                EventBus.getDefault().post(NotificationRefreshBean("refreshStatus"))
                                finish()
                                ArouterUtil.greenChannel(RoutePath.PosDetailsActivity, Bundle().apply {
                                    putInt(ITEM_ID, itemId)
                                    putInt(PROJECT_TYPE, projectType)
                                })
                            }
                        }, "common_text_tip".tr(this@PosDetailsActivity), "", "")



                    }

                    override fun onHandleError(code: Int, msg: String?) {
                        super.onHandleError(code, msg)
                        if(code==HTTPCode.PleaseDealnameVerify.code){
                            JsonUtils.showAuthPermissionNoEnoughDialog(this@PosDetailsActivity,isForce = false)
                        }else{
                            DisplayUtil.showSnackBar(window?.decorView, msg, false)
                        }


                    }

                })
    }

    /**
     *Obtain FreeStaking project details
     */
    private fun getProjectDetail(itemId: String) {
        showProgressDialog()
        Observable.zip(HttpClient.instance.getProjectDetail(itemId).subscribeOn(Schedulers.io()),mainModel.getUserInfoObservable().subscribeOn(Schedulers.io()),
            object: BiFunction<HttpResult<FreeStakingDetailBean>,HttpResult<Map<String,Any>>,HttpResult<FreeStakingDetailBean>> {
                override fun apply(t1: HttpResult<FreeStakingDetailBean>, t2: HttpResult<Map<String,Any>>): HttpResult<FreeStakingDetailBean> {
                    UserDataService.getInstance().saveData(JSONObject(t2.data))
                    return t1
                }
            }
        )
            .observeOn(AndroidSchedulers.mainThread())
            .subscribe(object : NetObserver<FreeStakingDetailBean>() {
                override fun onHandleSuccess(freeStakingDetailBean: FreeStakingDetailBean?) {
                    cancelProgressDialog()
                    freeStakingDetailBean?.let {
                        initData(it)
                    }
                }

                override fun onHandleError(code: Int, msg: String?) {
                    super.onHandleError(code, msg)
                    cancelProgressDialog()
                }
            })

    }

    override fun onDestroy() {
        super.onDestroy()
        if (countDownTimer != null) {
            countDownTimer?.cancel()
        }
    }

    @SuppressLint("NewApi")
    private fun initData(freeStakingDetailBean: FreeStakingDetailBean?) {
        freeStakingDetailBean?.let { setListener(it) }
        if(freeStakingDetailBean?.needAuth==1 && !isShowAuthDialog){
            if(UserDataService.getInstance().authLevel==0){
                isShowAuthDialog = true
                JsonUtils.showAuthPermissionNoEnoughDialog(this,isForce = false)
            }
        }

        val url = freeStakingDetailBean?.url.toString()
        if(url.isEmpty()){
            ivIcon?.visibility = View.GONE
        }else{
            ivIcon?.visibility = View.VISIBLE
        }
        if (projectType == 3 && freeStakingDetailBean?.activeStatus == 0 && freeStakingDetailBean?.remainingTimeSeconds > 0) {
            countDownTimer = CommonCountDownTimer(freeStakingDetailBean?.remainingTimeSeconds.times(1000), 1000)
            countDownTimer?.setCountDownTimerListener(object : CommonCountDownTimer.OnCountDownTimerListener {
                override fun onTick(millisUntilFinished: Long) {

                }

                override fun onFinish() {
                    freeStakingDetailBean.activeStatus = 1
                    initData(freeStakingDetailBean)

                }


            })
            countDownTimer?.start()

        }
        if (projectType == 3 && freeStakingDetailBean?.activeStatus == 1) {
            ll_lockNumber.visibility = View.VISIBLE
            expectedReturn.visibility = View.VISIBLE
            cb_agree.visibility = View.VISIBLE
            btn_agree.visibility = View.VISIBLE
            ll_cumulativeDistribution.visibility = View.GONE
            ll_youHaveObtained.visibility = View.GONE
            when (freeStakingDetailBean?.isShowBuy) {
                0 -> {
                    ll_lockNumber.visibility = View.GONE
                    cb_agree.visibility = View.GONE
                    btn_agree.visibility = View.GONE

                }

            }


        }
        //PoS records
        ivText?.text = freeStakingDetailBean?.tipMine
        if (isDestroyed) {
            return
        }
        //Currency logo
        Glide.with(this).load(freeStakingDetailBean?.logo).into(iv_logo)
        //BIKI
        tv_name.text = freeStakingDetailBean?.shortName
        //The URL of the message
        msgUrl = freeStakingDetailBean?.url.toString()
        tv_content.text = freeStakingDetailBean?.title
        projectName = freeStakingDetailBean?.name
        projectInfo = freeStakingDetailBean?.info
        tv_current.text = projectName
        tv_income.text = freeStakingDetailBean?.gainRate.toString() + "%"
        var totalAmountBig = freeStakingDetailBean?.totalAmount?.formatAmount(NCoinManager.getCoinShowPrecision(freeStakingDetailBean?.gainCoin.toString()))?: BigDecimal.ZERO
        var totalAmount = totalAmountBig?.toPlainString()?:"0"
        var totalAmountString = SpannableStringBuilder(totalAmount)
        val totalGainAmount = freeStakingDetailBean?.totalGainAmount?.formatAmount(NCoinManager.getCoinShowPrecision(freeStakingDetailBean?.gainCoin.toString()))?.toPlainString()
        val totalUserGainAmount = freeStakingDetailBean?.totalUserGainAmount?.formatAmount(NCoinManager.getCoinShowPrecision(freeStakingDetailBean?.gainCoin.toString()))?.toPlainString()
        val totalGainAmountString = SpannableStringBuilder(totalGainAmount)
        val totalUserGainAmountString = SpannableStringBuilder(totalUserGainAmount)
        val foregroundColor = ForegroundColorSpan(ContextCompat.getColor(ChainUpApp.appContext, R.color.text_color))
        totalGainAmountString.setSpan(foregroundColor, 0, totalGainAmount!!.length, Spanned.SPAN_INCLUSIVE_EXCLUSIVE)
        totalAmountString.setSpan(foregroundColor, 0, totalAmount!!.length, Spanned.SPAN_INCLUSIVE_EXCLUSIVE)
        totalUserGainAmountString.setSpan(foregroundColor, 0, totalUserGainAmount!!.length, Spanned.SPAN_INCLUSIVE_EXCLUSIVE)
        val absoluteSizeSpan = AbsoluteSizeSpan(16, true)
        totalGainAmountString.setSpan(absoluteSizeSpan, 0, totalGainAmount.length, Spanned.SPAN_INCLUSIVE_EXCLUSIVE)
        totalAmountString.setSpan(absoluteSizeSpan, 0, totalAmount.length, Spanned.SPAN_INCLUSIVE_EXCLUSIVE)
        totalAmountString.setSpan(StyleSpan(Typeface.BOLD), 0, totalAmount.length, Spanned.SPAN_INCLUSIVE_EXCLUSIVE)
        totalGainAmountString.setSpan(StyleSpan(Typeface.BOLD), 0, totalGainAmount.length, Spanned.SPAN_INCLUSIVE_EXCLUSIVE)
        totalUserGainAmountString.setSpan(absoluteSizeSpan, 0, totalUserGainAmount.length, Spanned.SPAN_INCLUSIVE_EXCLUSIVE)
        totalUserGainAmountString.setSpan(StyleSpan(Typeface.BOLD), 0, totalUserGainAmount.length, Spanned.SPAN_INCLUSIVE_EXCLUSIVE)
        var shortNameString = SpannableStringBuilder(freeStakingDetailBean?.shortName)
        var gainCoin = freeStakingDetailBean?.gainCoin
        val gainCoinString = SpannableStringBuilder(gainCoin)
        val gainCoinStringColor = ForegroundColorSpan(ContextCompat.getColor(ChainUpApp.appContext, R.color.normal_text_color))
        gainCoinString.setSpan(gainCoinStringColor, 0, gainCoinString.length, Spanned.SPAN_INCLUSIVE_EXCLUSIVE)
        shortNameString.setSpan(gainCoinStringColor, 0, shortNameString.length, Spanned.SPAN_INCLUSIVE_EXCLUSIVE)
        val gainCoinStringSize = AbsoluteSizeSpan(12, true)
        gainCoinString.setSpan(gainCoinStringSize, 0, gainCoinString.length, Spanned.SPAN_INCLUSIVE_EXCLUSIVE)
        shortNameString.setSpan(gainCoinStringSize, 0, shortNameString.length, Spanned.SPAN_INCLUSIVE_EXCLUSIVE)
        var dailyIncome = SpannableStringBuilder(totalAmountBig.multiply(freeStakingDetailBean?.lockDay.toBigDecimal())?.multiply(freeStakingDetailBean?.currencyExchangeRate?: BigDecimal.ZERO)?.multiply((freeStakingDetailBean?.gainRate?.div(100)?.div(365))?.toBigDecimal())?.formatAmount(NCoinManager.getCoinShowPrecision(freeStakingDetailBean?.gainCoin.toString()))?.stripTrailingZeros()?.toPlainString())
        dailyIncome.setSpan(foregroundColor, 0, dailyIncome.length, Spanned.SPAN_INCLUSIVE_EXCLUSIVE)
        dailyIncome.setSpan(absoluteSizeSpan, 0, dailyIncome.length, Spanned.SPAN_INCLUSIVE_EXCLUSIVE)
        dailyIncome.setSpan(StyleSpan(Typeface.BOLD), 0, dailyIncome.length, Spanned.SPAN_INCLUSIVE_EXCLUSIVE)
        if (!UserDataService.getInstance().isLogined) {
            when (projectType) {
                1 -> {
                    tv_grandTotalNumber.text = "- - - " + (freeStakingDetailBean?.gainCoin)
                    tv_grandTotalNumber.textColor = ContextCompat.getColor(ChainUpApp.appContext, R.color.normal_text_color)
                    tv_grandTotalNumber.textSize = 12f
                    tv_grandTotalNumber.typeface = Typeface.defaultFromStyle(Typeface.BOLD)
                    tv_alreadyNumber.text = "- - - " + (freeStakingDetailBean?.gainCoin)
                    tv_alreadyNumber.textColor = ContextCompat.getColor(ChainUpApp.appContext, R.color.normal_text_color)
                    tv_alreadyNumber.textSize = 12f
                    tv_alreadyNumber.typeface = Typeface.defaultFromStyle(Typeface.BOLD)
                    incomeBreakdown.visibility = View.GONE

                }
                3 -> {
                    tv_lockPosition.text = "- - - " + (freeStakingDetailBean?.shortName)
                    tv_lockPosition.textColor = ContextCompat.getColor(ChainUpApp.appContext, R.color.normal_text_color)
                    tv_lockPosition.textSize = 12f
                    tv_lockPosition.typeface = Typeface.defaultFromStyle(Typeface.BOLD)
                    tv_cumulativeDistribution.text = "- - - " + (freeStakingDetailBean?.gainCoin)
                    tv_cumulativeDistribution.textColor = ContextCompat.getColor(ChainUpApp.appContext, R.color.normal_text_color)
                    tv_cumulativeDistribution.textSize = 12f
                    tv_cumulativeDistribution.typeface = Typeface.defaultFromStyle(Typeface.BOLD)
                    tv_alreadyGot.text = "- - - " + (freeStakingDetailBean?.gainCoin)
                    tv_alreadyGot.textColor = ContextCompat.getColor(ChainUpApp.appContext, R.color.normal_text_color)
                    tv_alreadyGot.textSize = 12f
                    tv_alreadyGot.typeface = Typeface.defaultFromStyle(Typeface.BOLD)
                    availableBalance.text = getString(R.string.pos_string_available) + "- - - " + freeStakingDetailBean?.shortName
                    availableBalance.textColor = ContextCompat.getColor(ChainUpApp.appContext, R.color.normal_text_color)
                    availableBalance.textSize = 12f
                    tv_twoDayIncomeNumber.text = "- - - " + (freeStakingDetailBean?.gainCoin)
                    tv_twoDayIncomeNumber.textColor = ContextCompat.getColor(ChainUpApp.appContext, R.color.normal_text_color)
                    tv_twoDayIncomeNumber.textSize = 12f
                    tv_twoDayIncomeNumber.typeface = Typeface.defaultFromStyle(Typeface.BOLD)
                    incomeBreakdown.visibility = View.GONE

                }


            }


        } else {
            when (freeStakingDetailBean?.projectType) {
                1 -> {
                    tv_grandTotalNumber.text = totalGainAmountString.append(" ").append(gainCoinString).toString()
                    tv_alreadyNumber.text = totalUserGainAmountString.append(" ").append(gainCoinString).toString()

                }
                3 -> {
                    tv_alreadyGot.text = totalUserGainAmountString.append(" ").append(gainCoinString).toString()
                    tv_cumulativeDistribution.text = totalGainAmountString.append(" ").append(gainCoinString).toString()
                    tv_lockPosition.text = totalAmountString.append(" ").append(shortNameString).toString()
                    tv_twoDayIncomeNumber.text = dailyIncome.append(" ").append(gainCoinString).toString()
                    et_number.listener = object : BaseEditTextKit.OnKKBaseListener {
                        override fun statusChange(status: Boolean) {
                            super.statusChange(status)

                        }

                        override fun actionClick(targetView: EditText, actionView: View) {
                            super.actionClick(targetView, actionView)
                            if(actionView.id == R.id.tv_action2){
                                et_number.getRealEditText().text = Editable.Factory.getInstance().newEditable(freeStakingDetailBean?.balance.toPlainString())
                                et_number.getRealEditText().setSelection(freeStakingDetailBean?.balance.toPlainString().length)
                            }
                        }

                        override fun textChange(text: String) {
                            if (cb_agree.isChecked && et_number.getText().isNotBlank()) {
                                btn_agree.setBackgroundResource(R.drawable.agreebtn_click)
                                btn_agree.isEnabled = true
                            } else {
                                btn_agree.setBackgroundResource(R.drawable.agreebtn_unclick)
                                btn_agree.isEnabled = false

                            }
                            if (text.isBlank()) {
                                dailyIncome = SpannableStringBuilder((freeStakingDetailBean?.totalAmount.multiply(freeStakingDetailBean?.lockDay.toBigDecimal())?.multiply(freeStakingDetailBean?.currencyExchangeRate)?.multiply((freeStakingDetailBean?.gainRate?.div(100)?.div(365))?.toBigDecimal())?.formatAmount(NCoinManager.getCoinShowPrecision(freeStakingDetailBean?.gainCoin.toString()))?.stripTrailingZeros()?.toPlainString()))

                            } else {
                                dailyIncome = SpannableStringBuilder((freeStakingDetailBean?.totalAmount.add(text.toBigDecimal()))?.multiply(freeStakingDetailBean?.lockDay.toBigDecimal())?.multiply(freeStakingDetailBean?.currencyExchangeRate)?.multiply((freeStakingDetailBean?.gainRate?.div(100)?.div(365))?.toBigDecimal())?.formatAmount(NCoinManager.getCoinShowPrecision(freeStakingDetailBean?.gainCoin.toString()))?.stripTrailingZeros()?.toPlainString())
                            }
                            dailyIncome.setSpan(foregroundColor, 0, dailyIncome.length, Spanned.SPAN_INCLUSIVE_EXCLUSIVE)
                            dailyIncome.setSpan(absoluteSizeSpan, 0, dailyIncome.length, Spanned.SPAN_INCLUSIVE_EXCLUSIVE)
                            dailyIncome.setSpan(StyleSpan(Typeface.BOLD), 0, dailyIncome.length, Spanned.SPAN_INCLUSIVE_EXCLUSIVE)
                            tv_twoDayIncomeNumber.text = dailyIncome.append(" ").append(gainCoinString)
                        }

                    }

                }

            }
        }
        ll_lockePosition.visibility = View.VISIBLE
        when (projectType) {
            1 -> {

            }
            3 -> {

                when (freeStakingDetailBean?.activeStatus) {
                    0 -> {
                        image_one.setImageResource(R.drawable.audit_uncom)
                        progress_one.progress = 0
                        image_two.setImageResource(R.drawable.audit_uncom)
                        progress_two.progress = 0
                        image_three.setImageResource(R.drawable.audit_uncom)
                        progress_three.progress = 0
                        image_four.setImageResource(R.drawable.audit_uncom)
                        ll_lockePosition.visibility = View.GONE
                        ll_lockNumber.visibility = View.GONE
                        expectedReturn.visibility = View.GONE
                        cb_agree.visibility = View.GONE
                        btn_agree.visibility = View.GONE
                        incomeBreakdown.visibility = View.GONE
                    }
                    1, 6 -> {
                        image_one.setImageResource(R.drawable.audit_com)
                        progress_one.progress = 50
                        image_two.setImageResource(R.drawable.audit_uncom)
                        progress_two.progress = 0
                        image_three.setImageResource(R.drawable.audit_uncom)
                        progress_three.progress = 0
                        image_four.setImageResource(R.drawable.audit_uncom)
                        ll_cumulativeDistribution.visibility = View.GONE
                        ll_youHaveObtained.visibility = View.GONE
                        incomeBreakdown.visibility = View.GONE
                        when (freeStakingDetailBean?.isShowBuy) {
                            0 -> {
                                ll_lockNumber.visibility = View.GONE
                                cb_agree.visibility = View.GONE
                                btn_agree.visibility = View.GONE

                            }

                        }


                    }
                    2 -> {
                        image_one.setImageResource(R.drawable.audit_com)
                        progress_one.progress = 100
                        image_two.setImageResource(R.drawable.audit_com)
                        progress_two.progress = 50
                        image_three.setImageResource(R.drawable.audit_uncom)
                        progress_three.progress = 0
                        image_four.setImageResource(R.drawable.audit_uncom)
                        ll_cumulativeDistribution.visibility = View.GONE
                        ll_youHaveObtained.visibility = View.GONE
                        ll_lockNumber.visibility = View.GONE
                        cb_agree.visibility = View.GONE
                        btn_agree.visibility = View.GONE
                        incomeBreakdown.visibility = View.GONE
                    }
                    3 -> {
                        image_one.setImageResource(R.drawable.audit_com)
                        progress_one.progress = 100
                        image_two.setImageResource(R.drawable.audit_com)
                        progress_two.progress = 100
                        image_three.setImageResource(R.drawable.audit_com)
                        progress_three.progress = 50
                        image_four.setImageResource(R.drawable.audit_uncom)
                        ll_lockNumber.visibility = View.GONE
                        expectedReturn.visibility = View.GONE
                        cb_agree.visibility = View.GONE
                        btn_agree.visibility = View.GONE

                    }
                    4, 5 -> {
                        image_one.setImageResource(R.drawable.audit_com)
                        progress_one.progress = 100
                        image_two.setImageResource(R.drawable.audit_com)
                        progress_two.progress = 100
                        image_three.setImageResource(R.drawable.audit_com)
                        progress_three.progress = 100
                        image_four.setImageResource(R.drawable.audit_com)
                        ll_lockNumber.visibility = View.GONE
                        cb_agree.visibility = View.GONE
                        btn_agree.visibility = View.GONE
                        expectedReturn.visibility = View.GONE


                    }

                }


            }
        }




        if (projectType == 3) {
            tv_progress.text = freeStakingDetailBean?.progress
            var progress = freeStakingDetailBean?.progress.toString().substring(0, freeStakingDetailBean?.progress.toString().length - 1)
            lock_progress.progress = progress.toInt()
            lock_count.text = (freeStakingDetailBean?.raiseAmount?.formatAmount(NCoinManager.getCoinShowPrecision(freeStakingDetailBean?.shortName.toString()))?.toPlainString()) + freeStakingDetailBean?.shortName
            tv_numberLock.text = LanguageUtil.getString(this,"pos_string_lockNumber") + ": "
            tv_numberLockMaxMin.text = "（" + LanguageUtil.getString(this,"pos_string_minLimit") + ": " + ((freeStakingDetailBean?.buyAmountMin)?.stripTrailingZeros()?.toPlainString()) + (freeStakingDetailBean?.shortName) + " " + LanguageUtil.getString(this,"pos_string_maxlockNumber") + ": " + (freeStakingDetailBean?.buyAmountMax)?.stripTrailingZeros()?.toPlainString() + (freeStakingDetailBean?.shortName) + "）"
            availableBalance.text = LanguageUtil.getString(this,"pos_string_available") + ((freeStakingDetailBean?.balance)?.formatAmount(NCoinManager.getCoinShowPrecision(freeStakingDetailBean?.shortName.toString()))?.toPlainString()) + (freeStakingDetailBean?.shortName)
            tv_twoDayIncome.text = freeStakingDetailBean?.lockDay.toString() + LanguageUtil.getString(this,"pos_string_twoDaysEarn")
            freeStakingDetailBean.stimeMillis?.let {
                val time = it.toLong()
                val timeStr = DateUtil.longToString(DateUtil.ymdHmFormat,time)
                tv_yearMonthDayOne.text = timeStr.split(" ")[0]
                tv_timeOne.text = timeStr.split(" ")[1]
            }
            freeStakingDetailBean.etimeMillis?.let{
                val time = it.toLong()
                val timeStr = DateUtil.longToString(DateUtil.ymdHmFormat,time)
                tv_yearMonthDayTwo.text = timeStr.split(" ")[0]
                tv_timeTwo.text = timeStr.split(" ")[1]
            }
            freeStakingDetailBean.ltimeMillis?.let{
                val time = it.toLong()
                val timeStr = DateUtil.longToString(DateUtil.ymdHmFormat,time)
                tv_yearMonthDayThree.text = timeStr.split(" ")[0]
                tv_timeThree.text = timeStr.split(" ")[1]
            }
            freeStakingDetailBean.iasDateMillis?.let{
                val time = it.toLong()
                val timeStr = DateUtil.longToString(DateUtil.ymdHmFormat,time)
                tv_yearMonthDayFour.text = timeStr.split(" ")[0]
                tv_timeFour.text = timeStr.split(" ")[1]
            }


        }


        for (item in freeStakingDetailBean?.userGainList!!) {
            item.gainCoin = freeStakingDetailBean?.gainCoin

        }
        val list = freeStakingDetailBean?.userGainList
        mIncomeList.clear()
        list?.let {
            mIncomeList.addAll(it)
        }

        rl_head.visibility = if(mIncomeList.size<=0) View.GONE else View.VISIBLE

        adapter.setList(mIncomeList)

        tv_rules.text = Html.fromHtml(freeStakingDetailBean?.details)









    }

    fun setListener(freeStakingDetailBean:FreeStakingDetailBean) {
        //Message click
        ivIcon?.setOnClickListener {
            var bundle = Bundle()
            bundle.putString(ParamConstant.web_url, msgUrl)
            bundle.putInt(ParamConstant.web_type, WebTypeEnum.COMMON_WEB.value)
            ArouterUtil.greenChannel(RoutePath.ItemDetailActivity, bundle)
        }
        //View Announcement Click
        tv_details.setOnClickListener {
            ArouterUtil.greenChannel(RoutePath.ProjectDescriptionActivity, Bundle().apply {
                putString(PROJECT_NAME, projectName)
                putString(PROJECT_INFO, projectInfo)
            })
        }
        //All
        tv_all.setOnClickListener {
            et_number.getRealEditText().text = Editable.Factory.getInstance().newEditable(freeStakingDetailBean?.balance.toPlainString())
            et_number.getRealEditText().setSelection(freeStakingDetailBean?.balance.toPlainString().length)
        }
        //Full income details
        tv_allDetail.setOnClickListener {
            var bundle = Bundle()
            bundle.putParcelableArrayList("userGainList", freeStakingDetailBean?.userGainList)
            ArouterUtil.greenChannel(RoutePath.IncomeDetailActivity, bundle)
        }
        //PoS record click
        ivText?.setOnClickListener {
            if (LoginManager.checkLogin(this, true)) {
                ArouterUtil.greenChannel(RoutePath.PositionRecordActivity, Bundle().apply {
                    putInt(PROJECT_TYPE, projectType)
                })
            }
        }
        //Agree to PoS click event
        btn_agree.setOnClickListener {
           var mPrecision= NCoinManager.getCoinShowPrecision(freeStakingDetailBean?.shortName)
            if (!LoginManager.checkLogin(this, true)) {
                return@setOnClickListener
            }
            if ((et_number.getText().toBigDecimal()).compareTo(freeStakingDetailBean?.buyAmountMin!!) < 0) {
                var limit=freeStakingDetailBean.buyAmountMin.setScale(mPrecision).toPlainString()
                DisplayUtil.showSnackBar(window?.decorView, LanguageUtil.getString(this,"pos_string_minquantityperLock") + limit + freeStakingDetailBean?.shortName, false)
                return@setOnClickListener
            }
            if (freeStakingDetailBean?.buyAmountMax!!.compareTo((et_number.getText().toBigDecimal().add(freeStakingDetailBean?.totalAmount))) < 0) {
                var limit=freeStakingDetailBean.buyAmountMax.setScale(mPrecision).toPlainString()
                DisplayUtil.showSnackBar(window?.decorView, LanguageUtil.getString(this,"pos_string_maxquantityLock") + limit + freeStakingDetailBean?.shortName, false)
                return@setOnClickListener
            }
            if ((freeStakingDetailBean?.balance)!!.compareTo(et_number.getText().toBigDecimal()) <= 0) {
                DisplayUtil.showSnackBar(window?.decorView, LanguageUtil.getString(this,"pos_string_lockNotAvailable"), false)
                return@setOnClickListener
            }
            requestTOBuy(et_number.getText(), itemId)
        }
    }

    private fun initIncomeListAdapter(){
        rl_head.visibility = View.GONE
        val linearLayoutManager = LinearLayoutManager(this, LinearLayoutManager.VERTICAL, false)
        rv_incomeBreakdown.layoutManager = linearLayoutManager
        val lp = rv_incomeBreakdown.layoutParams
        lp.height = DensityUtil.dp2px(44.0f * 5)
        rv_incomeBreakdown.layoutParams = lp
        adapter = IncomeRecyclerAdapter(mIncomeList)
        adapter.setEmptyView(KKEmptyViewKit(this).apply {
            setImageViewTop(50.0f)
        })
        rv_incomeBreakdown.adapter = adapter

    }


}
