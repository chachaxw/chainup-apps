package com.yjkj.chainup.new_version.activity.b2c

import android.app.Activity
import android.content.Intent
import android.graphics.Typeface
import android.os.Bundle
import androidx.core.content.ContextCompat
import android.text.Editable
import android.text.TextUtils
import android.text.TextWatcher
import android.util.Log
import android.view.Gravity
import android.view.View
import com.alibaba.android.arouter.facade.annotation.Route
 import com.chainup.contract.view.dialog.CpTDialog
import com.yjkj.chainup.R
import com.yjkj.chainup.base.NBaseActivity
import com.yjkj.chainup.db.constant.ParamConstant
import com.yjkj.chainup.db.constant.RoutePath
import com.yjkj.chainup.db.service.PublicInfoDataService
import com.yjkj.chainup.db.service.UserDataService
import com.yjkj.chainup.extra_service.arouter.ArouterUtil
import com.yjkj.chainup.manager.LanguageUtil
import com.yjkj.chainup.net_new.rxjava.NDisposableObserver
import com.yjkj.chainup.new_version.activity.CoinActivity
import com.yjkj.chainup.new_version.dialog.NewDialogUtils
import com.yjkj.chainup.new_version.view.CommonlyUsedButton
import com.yjkj.chainup.util.*
import kotlinx.android.synthetic.main.activity_b2_cwithdraw.*
import kotlinx.android.synthetic.main.activity_b2_cwithdraw.btn_confirm
import kotlinx.android.synthetic.main.activity_b2_cwithdraw.collapsing_toolbar
import kotlinx.android.synthetic.main.activity_b2_cwithdraw.et_amount
import kotlinx.android.synthetic.main.activity_b2_cwithdraw.toolbar
import kotlinx.android.synthetic.main.activity_b2_cwithdraw.tv_available_balance
import kotlinx.android.synthetic.main.activity_b2_cwithdraw.tv_choose_symbol
import kotlinx.android.synthetic.main.activity_b2_cwithdraw.tv_note
import kotlinx.android.synthetic.main.activity_b2_cwithdraw.tv_recharge_record
import org.json.JSONObject

/**
 *@description: Withdrawal (B2C)
 * @author Bertking
 * @Date 2023-10-23 AM
 */
@Route(path = RoutePath.B2CWithdrawActivity)
class B2CWithdrawActivity : NBaseActivity() {

    /*Withdrawal amount*/
    var withdrawAmount = ""
    /*Withdrawal account ID*/
    var withdrawId = ""

    var dialog:  CpTDialog? = null


    var symbol: String = PublicInfoDataService.getInstance().coinInfo4B2c

    var precision: Int = 2

    var availableBalance: String = "0"

    var fee = ""
    var feeType = "0"
    //Minimum withdrawal amount for a single transaction
    var withdrawMin = "0"
    //Maximum withdrawal amount for a single transaction
    var withdrawMax = "0"
    //Withdrawable today
    var canWithdrawBalance = "0"


    override fun setContentView() = R.layout.activity_b2_cwithdraw

    override fun onInit(savedInstanceState: Bundle?) {
        super.onInit(savedInstanceState)
        initView()
    }

    override fun onResume() {
        super.onResume()

        if (!TextUtils.isEmpty(withdrawAmount) && (!TextUtils.isEmpty(withdrawId))) {
            btn_confirm?.isEnable(true)
        } else {
            btn_confirm?.isEnable(false)
        }

        
        if (StringUtil.checkStr(withdrawId)) {
            fiatGetBank()
        } else {
            initWithdrawAccount()
        }

        getB2CAccount(symbol)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (resultCode == Activity.RESULT_OK) {
            when (requestCode) {
                /**Currency*/
                321 -> {
                    symbol = data?.getStringExtra(CoinActivity.SELECTED_COIN) ?: ""
                    PublicInfoDataService.getInstance().saveCoinInfo4B2C(symbol)
                    getB2CAccount(symbol)
                }

                123 -> {
                    withdrawId = data?.getStringExtra(ParamConstant.WITHDRAW_ID) ?: ""
                    
                    if (StringUtil.checkStr(withdrawId)) {
                        fiatGetBank()
                    } else {
                        initWithdrawAccount()
                    }
                }

            }
        }
    }


    override fun initView() {
        setSupportActionBar(toolbar)
        toolbar?.setNavigationOnClickListener {
            finish()
        }

        collapsing_toolbar?.run {
            setCollapsedTitleTextColor(ContextCompat.getColor(mActivity, R.color.text_color))
            setExpandedTitleColor(ContextCompat.getColor(mActivity, R.color.text_color))
            setExpandedTitleTypeface(Typeface.DEFAULT_BOLD)
            expandedTitleGravity = Gravity.BOTTOM
        }


        /*Withdrawal records*/
        tv_recharge_record?.setOnClickListener {
            ArouterUtil.navigation(RoutePath.B2CRecordsActivity, Bundle().apply { putInt(ParamConstant.OPTION_TYPE, ParamConstant.WITHDRAW) })
        }

        /*Select Currency*/
        tv_choose_symbol?.setOnClickListener {
            ArouterUtil.navigation4Result(RoutePath.SelectCoinActivity, Bundle().apply {
                putInt(ParamConstant.OPTION_TYPE, ParamConstant.WITHDRAW)
                putBoolean(ParamConstant.COIN_FROM, false)
            }, mActivity, 321)
        }

        //Select withdrawal account
        rl_into_withdraw_layout?.setOnClickListener {
            ArouterUtil.navigation4Result(RoutePath.B2CWithdrawAccountListActivity, Bundle().apply { putString(ParamConstant.symbol, symbol) }, mActivity, 123)
        }

        //All amounts
        btn_all?.setOnClickListener {
            et_amount?.setText(availableBalance)
            et_amount?.setSelection(et_amount?.text?.length ?: 0)
        }


        et_amount?.isFocusable = true
        et_amount?.isFocusableInTouchMode = true

        et_amount?.addTextChangedListener(object : TextWatcher {
            override fun afterTextChanged(s: Editable?) {
                withdrawAmount = s.toString()
                //0: Fixed value 1: Percentage

                if (StringUtil.checkStr(fee)) {
                    val realAmount = if (feeType == "1") {
                        val precent = (100f - fee.toFloat()).div(100f).toString()
                        BigDecimalUtils.mul(withdrawAmount, precent).toPlainString()
                    } else {
                        BigDecimalUtils.sub(withdrawAmount, fee).toPlainString()
                    }
                    tv_real_amount?.text = DecimalUtil.cutValueByPrecision(realAmount, precision) + symbol

                    if (feeType == "1") {
                        val feePrecent = fee.toFloat().div(100f).toString()
                        
                        et_fee?.setText(BigDecimalUtils.mul(withdrawAmount, feePrecent).toPlainString())
                    }

                }

                if (!TextUtils.isEmpty(withdrawAmount) && (!TextUtils.isEmpty(withdrawId))) {
                    btn_confirm?.isEnable(true)
                } else {
                    btn_confirm?.isEnable(false)
                }

            }

            override fun beforeTextChanged(s: CharSequence?, start: Int, count: Int, after: Int) {
            }

            override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) {
            }

        })

        /**
         *Confirm
         */
        btn_confirm?.listener = object : CommonlyUsedButton.OnBottonListener {
            override fun bottonOnClick() {

                if (BigDecimalUtils.compareTo(withdrawAmount, availableBalance) > 0) {
                    NToastUtil.showTopToastNet(mActivity,false, LanguageUtil.getString(this@B2CWithdrawActivity,"common_tip_balanceNotEnough"))
                    return
                }

                if (BigDecimalUtils.compareTo(withdrawAmount, withdrawMin) < 0) {
                    NToastUtil.showTopToastNet(mActivity,false, LanguageUtil.getString(this@B2CWithdrawActivity,"b2c_text_singleWithdrawMin").format(DecimalUtil.cutValueByPrecision(withdrawMin, precision)))
                    return
                }

                if (BigDecimalUtils.compareTo(withdrawAmount, canWithdrawBalance) > 0) {
                    NToastUtil.showTopToastNet(mActivity,false, LanguageUtil.getString(this@B2CWithdrawActivity,"b2c_text_singleWithdrawMin").format(DecimalUtil.cutValueByPrecision(canWithdrawBalance, precision)))
                    return
                }

                if (BigDecimalUtils.compareTo(withdrawAmount, withdrawMax) > 0) {
                    NToastUtil.showTopToastNet(mActivity,false, LanguageUtil.getString(this@B2CWithdrawActivity,"b2c_text_singleWithdrawMax").format(DecimalUtil.cutValueByPrecision(withdrawMax, precision)))
                    return
                }

                dialog = NewDialogUtils.showAccountBindDialog(mActivity, UserDataService.getInstance().mobileNumber, 1, 32, object : NewDialogUtils.DialogVerifiactionListener {
                    override fun returnCode(phone: String?, mail: String?, googleCode: String?) {
                        dialog?.dismiss()
                        
                        withdraw(phone ?: return, googleCode ?: return)
                    }
                })
            }
        }
    }

    /**
     *Withdrawal
     */
    fun withdraw(smsAuthCode: String = "", googleCode: String = "") {
        addDisposable(getMainModel().fiatWithdraw(symbol = symbol,
                userWithdrawBankId = withdrawId,
                amount = withdrawAmount,
                smsAuthCode = smsAuthCode,
                googleCode = googleCode,
                consumer = object : NDisposableObserver(mActivity) {
                    override fun onResponseSuccess(jsonObject: JSONObject) {
                        NToastUtil.showTopToastNet(mActivity,true, LanguageUtil.getString(this@B2CWithdrawActivity,"b2c_text_withdrawSuccess"))
                        et_amount?.setText("")
                        finish()
                    }
                }))
    }

    private fun getB2CAccount(symbol: String) {
        addDisposable(getMainModel().fiatBalance(symbol = symbol,
                consumer = object : NDisposableObserver(mActivity) {
                    override fun onResponseSuccess(jsonObject: JSONObject) {

                        val data = jsonObject.optJSONObject("data")
                        val withdrawTip = data?.optString("withdrawTip", "")
                        tv_note?.text = withdrawTip
                        tv_notes_title?.visibility = if (TextUtils.isEmpty(withdrawTip)) View.INVISIBLE else View.VISIBLE

                        val jsonArray = data?.optJSONArray("allCoinMap")
                        if (jsonArray?.length() != 0) {
                            jsonArray?.optJSONObject(0)?.run {
                                tv_symbol?.text = optString("symbol", "")
                                /*Recharge amount*/
                                precision = optInt("showPrecision", 2)
                                et_amount?.filters = arrayOf(DecimalDigitsInputFilter(precision))

                                availableBalance = optString("normalBalance", "0")
                                tv_available_balance?.text = LanguageUtil.getString(this@B2CWithdrawActivity,"withdraw_text_available") + " $availableBalance"

                                tv_fee_symbol?.text = symbol
                                //Single stroke minimum
                                withdrawMin = optString("withdrawMin", "")
                                tv_min_amount?.text = LanguageUtil.getString(this@B2CWithdrawActivity,"b2c_text_singleWithdrawMin").format(DecimalUtil.cutValueByPrecision(withdrawMin, precision)) + " $symbol"
                                //Single maximum
                                withdrawMax = optString("withdrawMax", "")
                                tv_max_amount?.text = LanguageUtil.getString(this@B2CWithdrawActivity,"b2c_text_singleWithdrawMax").format(DecimalUtil.cutValueByPrecision(withdrawMax, precision)) + " $symbol"
                                //Today
                                canWithdrawBalance = optString("canWithdrawBalance", "")
                                tv_amount_day?.text = LanguageUtil.getString(this@B2CWithdrawActivity,"b2c_text_todaywithdraw").format(DecimalUtil.cutValueByPrecision(canWithdrawBalance, precision)) + " $symbol"

                            }
                        }


                    }
                }))
    }


    /**
     *Query withdrawal bank
     */
    private fun fiatGetBank() {
        addDisposable(getMainModel().fiatGetBank(id = withdrawId,
                consumer = object : NDisposableObserver(mActivity) {
                    override fun onResponseSuccess(jsonObject: JSONObject) {
                        val data = jsonObject.optJSONObject("data")
                        if (data == null) {
                            initWithdrawAccount()
                        } else {
                            data.run {
                                val cardNo = optString("cardNo", "")
                                val bankName = optString("bankName", "")
                                withdrawId = optString("id")
                                //Account display
                                cet_withdraw_adr?.text = bankName + "_**" + cardNo.takeLast(3)
                                fee = optString("fee")

                                //0: Fixed value 1: Percentage
                                /**
                                 *Handling fees
                                 */
                                feeType = optString("feeType")
                                if (feeType != "1") {
                                    et_fee?.setText(DecimalUtil.cutValueByPrecision(fee, precision))
                                }

                            }
                        }


                    }
                }))

    }

    private fun initWithdrawAccount() {
        cet_withdraw_adr?.text = ""
        et_fee?.setText("--")
    }
}
