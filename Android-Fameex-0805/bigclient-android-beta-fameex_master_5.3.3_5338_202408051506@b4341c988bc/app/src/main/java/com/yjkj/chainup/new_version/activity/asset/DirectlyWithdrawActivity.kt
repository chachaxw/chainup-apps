package com.yjkj.chainup.new_version.activity.asset

import android.app.Activity
import android.content.Intent
import android.graphics.Typeface
import android.os.Bundle
import android.text.Editable
import android.text.TextUtils
import android.text.TextWatcher
import android.view.Gravity
import android.view.View
import androidx.core.content.ContextCompat
import com.alibaba.android.arouter.facade.annotation.Autowired
import com.alibaba.android.arouter.facade.annotation.Route
 import com.chainup.contract.view.dialog.CpTDialog
import com.chainup.kit.views.PublicHeaderKit
import com.yjkj.chainup.R
import com.yjkj.chainup.app.AppConstant
import com.yjkj.chainup.base.NBaseActivity
import com.yjkj.chainup.bean.EquityBean
import com.yjkj.chainup.db.constant.ParamConstant
import com.yjkj.chainup.db.constant.RoutePath
import com.yjkj.chainup.extra_service.arouter.ArouterUtil
import com.yjkj.chainup.manager.LanguageUtil
import com.yjkj.chainup.manager.NCoinManager
import com.yjkj.chainup.net_new.rxjava.NDisposableObserver
import com.yjkj.chainup.net_new.rxjava.NModelDisposableObserver
import com.yjkj.chainup.new_version.activity.CoinActivity
import com.yjkj.chainup.new_version.dialog.NewDialogUtils
import com.yjkj.chainup.new_version.view.CommonlyUsedButton
import com.yjkj.chainup.new_version.view.TRANSFER_RECORD
import com.yjkj.chainup.securityVerifyRule.VerifyRule3
import com.yjkj.chainup.util.BigDecimalUtils
import com.yjkj.chainup.util.ColorUtil
import com.yjkj.chainup.util.DisplayUtil
import com.yjkj.chainup.util.JsonUtils
import com.yjkj.chainup.util.NToastUtil
import com.yjkj.chainup.util.tr
import kotlinx.android.synthetic.main.activity_directly_withdraw.*
import kotlinx.android.synthetic.main.activity_withdraw_record.spw_layout
import kotlinx.android.synthetic.main.activity_withdraw_record.title_layout
import kotlinx.android.synthetic.main.item_screening_popup_window.view.cub_confirm
import org.json.JSONObject
import kotlinx.android.synthetic.main.layout_withdraw_amount_tip.*

/**
 * @Author lianshangljl
 * @Date 2023-07-03-15:53
 * @Email buptjinlong@163.com
 * @description
 */
@Route(path = RoutePath.DirectlyWithdrawActivity)
class DirectlyWithdrawActivity : NBaseActivity() {
    override fun setContentView() = R.layout.activity_directly_withdraw

    @JvmField
    @Autowired(name = ParamConstant.JSON_BEAN)
    var bean = ""

    var showSymbol = ""
    var coinPrecision = 2
    var jsonBean: JSONObject? = null

    override fun onInit(savedInstanceState: Bundle?) {
        super.onInit(savedInstanceState)
        ArouterUtil.inject(this)
        title_layout?.setContentTitle(LanguageUtil.getString(this, "assets_action_internalTransfer"))
        setBgFill2()
        setContentText()
        initView()
        onSetClick()
        getCost()
        getEquity(showSymbol)
    }

    fun setContentText() {
        tv_instructions_title?.text = LanguageUtil.getString(this, "withdraw_tip_notice")
        tv_can_use_amount_label.text = "kyc_withdrawal_amount".tr(this)
        tv_withdraw_amount_label.text = "kyc_withdrawal_24h".tr(this)
        tv_single_max_withdraw_label.text = "charge_chargeAlert_contentB".tr(this)
        tv_instructions_title?.text = LanguageUtil.getString(this, "transfer_tip_notice")
        tv_withdraw_adr_title?.text = LanguageUtil.getString(this, "internalTransfer_text_address")
        tv_number_title?.text = LanguageUtil.getString(this, "charge_text_volume")
        tv_available_balance?.text = LanguageUtil.getString(this, "sl_str_available_balance")
        tv_fee_title?.text = LanguageUtil.getString(this, "withdraw_text_fee")
        tv_withdraw_text_moneyWithoutFee?.text = LanguageUtil.getString(this, "withdraw_text_moneyWithoutFee")
        cubtn_confirm?.setContent(LanguageUtil.getString(this, "common_text_btnConfirm"))
        cet_withdraw_adr?.hint = LanguageUtil.getString(this, "filter_Input_placeholder") + LanguageUtil.getString(this, "internalTransfer_text_address")
        title_layout.setTvRightText(LanguageUtil.getString(this, "internalTransfer_action_History"))
    }

    var normal_balance = ""

    override fun initView() {
        super.initView()
        jsonBean = JSONObject(bean)
        showSymbol = jsonBean?.optString("coinName", "") ?: ""
        coinPrecision = NCoinManager.getCoinShowPrecision(showSymbol)
        normal_balance = jsonBean?.optString("normal_balance") ?: "0"
        tv_available_balance?.text = "${LanguageUtil.getString(this, "withdraw_text_available")}${BigDecimalUtils.divForDown(jsonBean?.optString("normal_balance"), coinPrecision).toPlainString()}"

        /**
         *Opposite account address
         */
        cet_withdraw_adr?.isFocusable = true
        cet_withdraw_adr?.isFocusableInTouchMode = true
        cet_withdraw_adr?.setOnFocusChangeListener { v, hasFocus ->
            view_withdraw_adr_line?.setBackgroundResource(if (hasFocus) R.color.main_blue else R.color.new_edit_line_color)
        }
        cet_withdraw_adr?.addTextChangedListener(object : TextWatcher {
            override fun beforeTextChanged(s: CharSequence?, start: Int, count: Int, after: Int) {

            }

            override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) {

            }

            override fun afterTextChanged(s: Editable?) {

            }
        })
        /**
         *Transfer quantity
         */
        et_amount?.isFocusable = true
        et_amount?.isFocusableInTouchMode = true
        et_amount?.setOnFocusChangeListener { v, hasFocus ->
            view_amount_line?.setBackgroundResource(if (hasFocus) R.color.main_blue else R.color.new_edit_line_color)
            println("hasFocus = ${hasFocus}")

        }
        et_amount?.addTextChangedListener(object : TextWatcher {
            override fun afterTextChanged(s: Editable?) {
                realAmount(innerTransferFee, s.toString())
            }

            override fun beforeTextChanged(s: CharSequence?, start: Int, count: Int, after: Int) {

            }

            override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) {

            }

        })
    }


    private fun realAmount(fee: String, amount: String) {
        var value = "0"
        if (!TextUtils.isEmpty(amount)) {
            value = amount
        }

        if (value.startsWith(".")) {
            value = "0"
        }

        if (value.endsWith(".")) {
            value = value.substring(0, value.length - 1)
        }
        /**
         *Actual Received Quantity
         */
        var result = BigDecimalUtils.sub(value, fee).toString()
        /**
         *To avoid Scientific notation
         */
        if (amount.isEmpty()) {
            tv_real_amount?.text = "0" + NCoinManager.getShowMarket(showSymbol)
        } else {
            tv_real_amount?.setTextColor(ColorUtil.getColor(R.color.main_font_color))
            tv_real_amount?.text = BigDecimalUtils.divForDown(result, coinPrecision).toPlainString() + NCoinManager.getShowMarket(showSymbol)
        }

    }


    var innerTransferFee = "0"
    var maxAmount = ""
    var minAmount = ""
    var todayAmount = ""

    /**
     *Load data
     */
    fun setFeeView(json: JSONObject) {
        tv_fee_symbol?.text = NCoinManager.getShowMarket(showSymbol)
        tv_coin_name?.text = NCoinManager.getShowMarket(showSymbol)
        tv_symbol_name?.text = NCoinManager.getShowMarket(showSymbol)
        maxAmount = json.optString("withdraw_max")
        minAmount = json.optString("withdraw_min")
        todayAmount = json.optString("withdraw_max_day")
        tv_single_max_withdraw_value.text = "${BigDecimalUtils.showNormal(json.optString("withdraw_max"))} $showSymbol"
        innerTransferFee = json.optString("innerTransferFee")
        et_fee?.setText(BigDecimalUtils.showNormal(innerTransferFee))
        et_amount.hint = String.format(LanguageUtil.getString(mActivity, "withdraw_tip_withdrawMinValueError"),minAmount)
    }

    fun onSetClick() {
        /**
         *Withdrawal of currency
         */
        cubtn_confirm?.isEnable(true)
        cubtn_confirm?.listener = object : CommonlyUsedButton.OnBottonListener {
            override fun bottonOnClick() {

                val address = cet_withdraw_adr?.text.toString()

                if (TextUtils.isEmpty(address)) {
                    NToastUtil.showTopToast(false, LanguageUtil.getString(this@DirectlyWithdrawActivity, "common_tip_targetAccount"))
                    return
                }

                val amount = et_amount?.text.toString()

                if (BigDecimalUtils.compareTo(BigDecimalUtils.divForDown(jsonBean?.optString("normal_balance"), coinPrecision).toPlainString(), amount) < 0) {
                    NToastUtil.showTopToast(false, "${LanguageUtil.getString(this@DirectlyWithdrawActivity, "common_tip_balanceNotEnough")}")
                    return
                }

                if (TextUtils.isEmpty(amount)) {
                    NToastUtil.showTopToast(false, LanguageUtil.getString(this@DirectlyWithdrawActivity, "transfer_tip_emptyVolume"))
                    return
                }
                if (BigDecimalUtils.compareTo(maxAmount, amount) < 0) {
                    NToastUtil.showTopToast(false, "${LanguageUtil.getString(this@DirectlyWithdrawActivity, "internalTransfer_tip_maxValueError")}$maxAmount")
                    return
                }
                if (BigDecimalUtils.compareTo(minAmount, amount) > 0) {
                    NToastUtil.showTopToast(false, "${LanguageUtil.getString(this@DirectlyWithdrawActivity, "internalTransfer_tip_minValueError")}$minAmount")
                    return
                }
                val actualaMount = BigDecimalUtils.sub(et_amount?.text.toString(), innerTransferFee).toString()
                if(BigDecimalUtils.compareTo(actualaMount, "0") != 1){
                    DisplayUtil.showSnackBar(window?.decorView, LanguageUtil.getString(mActivity, "withdraw_tip_withdrawMinArrivalError"), isSuc = false)
                    return
                }

//                if (BigDecimalUtils.compareTo(amount, todayAmount) > 0) {
//                    NToastUtil.showTopToast(false, "${LanguageUtil.getString(this@DirectlyWithdrawActivity, "common_tip_todayRemaining")}$todayAmount")
//                    return
//                }

                sendTransfer(address)
            }
        }
        /**
         *Click to switch currency
         */
        rl_symbol_name?.setOnClickListener {
            ArouterUtil.navigation4Result(RoutePath.SelectCoinActivity, Bundle().apply {
                putInt(ParamConstant.OPTION_TYPE, ParamConstant.INNEROPEN)
                putBoolean(ParamConstant.COIN_FROM, false)
            }, this, 321)
        }

        /**
         *Transfer records
         */
        title_layout?.listener = object : PublicHeaderKit.IOnBackClickListener{
            override fun onRightBtn(view: View) {
                super.onRightBtn(view)
                WithDrawRecordActivity.enter2(this@DirectlyWithdrawActivity, showSymbol, ParamConstant.DIRECTLY_WITHDRAW_TYPE, TRANSFER_RECORD)
            }
        }
        /**
         *All
         */
        btn_all_amount?.setOnClickListener {
            et_amount?.setText(BigDecimalUtils.divForDown(normal_balance, coinPrecision).toPlainString())
        }

    }


    /**
     *Scan result
     */
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (resultCode == Activity.RESULT_OK) {
            cet_withdraw_adr?.setText("")
            et_amount?.setText("")
            et_fee?.setText("")
            when (requestCode) {
                /**
                 *Currency
                 */
                321 -> {
                    showSymbol = data?.getStringExtra(CoinActivity.SELECTED_COIN) ?: ""
                    coinPrecision = NCoinManager.getCoinShowPrecision(showSymbol)
                    getCost()
                }

            }
        }
    }

    var tDialog:  CpTDialog? = null
    /**
     *Confirm transfer interface
     */
    fun sendTransfer(id: String) {
        addDisposable(getMainModel().innerTransferUserAuth(id, object : NDisposableObserver() {
            override fun onResponseSuccess(jsonObject: JSONObject) {
                tDialog = NewDialogUtils.createNewVersionSecurityDialog(
                    this@DirectlyWithdrawActivity,
                    VerifyRule3(),
                    AppConstant.CONFIRM_TRANSFER_IPHONE,
                    coinTypeEmail = AppConstant.CONFIRM_TRANSFER_EMAIL,
                    listener = object:NewDialogUtils.DialogVerifiactionListener{
                        override fun returnCode(
                            phone: String?,
                            mail: String?,
                            googleCode: String?
                        ) {

                        }

                        override fun returnCode(
                            phone: String,
                            mail: String,
                            googleCode: String,
                            capitalPwd: String,
                            loginPwd: String
                        ) {
                            val amount = BigDecimalUtils.sub(et_amount?.text.toString(), innerTransferFee).toString()
                            val fee = et_fee?.text.toString()
                            doWithdraw(id, amount, fee, showSymbol, phone, googleCode,mail,capitalPwd)
                            tDialog?.dismiss()
                        }

                    }
                )

            }

            override fun onResponseFailure(code: Int, msg: String?) {
                super.onResponseFailure(code, msg)
                NToastUtil.showTopToast(false, msg)
            }
        }))

    }

    /**
     *Internal transfer user authentication
     */
    fun doWithdraw(id: String, amount: String, fee: String, symbol: String, smsAuthCode: String, googleCode: String,mail:String,capitalPwd:String?) {
        addDisposable(getMainModel().innerTransferDoWithdraw(id, amount, fee, symbol, smsAuthCode, googleCode,mail,capitalPwd, object : NDisposableObserver() {
            override fun onResponseSuccess(jsonObject: JSONObject) {
                NToastUtil.showTopToast(true, LanguageUtil.getString(this@DirectlyWithdrawActivity, "internalTransfer_tip_success"))
                finish()
            }

            override fun onResponseFailure(code: Int, msg: String?) {
                super.onResponseFailure(code, msg)
                NToastUtil.showTopToast(false, msg)
            }
        }))

    }


    /**
     *Query service fees and withdrawal addresses based on currency
     */
    private fun getCost() {
        addDisposable(getMainModel().getCost(showSymbol, object : NDisposableObserver(this) {
            override fun onResponseSuccess(jsonObject: JSONObject) {
                var data = jsonObject.optJSONObject("data")
                if (null == data || data.length() == 0) return
                setFeeView(data)
            }
        }))

    }

    private fun getEquity(symbol: String){
        addDisposable(
            getMainModel().getEquity(symbol,consumer = object : NModelDisposableObserver<EquityBean>(){
                override fun onResponseSuccess(data: EquityBean) {
                    if(BigDecimalUtils.compareTo(data.withdrawAmount,"0")<=0){
                        JsonUtils.showAuthPermissionNoEnoughDialog(this@DirectlyWithdrawActivity,isForce = true)
                        return
                    }
                    tv_can_use_amount_value.text = BigDecimalUtils.showSNormal(data.currentSymbolAmount) + symbol
                    tv_withdraw_amount_value.text = BigDecimalUtils.showSNormal(data.canUseAmount) + "/" + BigDecimalUtils.showSNormal(data.withdrawAmount) + "USDT"
                }
            })
        )
    }

}
