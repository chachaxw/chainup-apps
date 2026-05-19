package com.yjkj.chainup.new_version.activity

import android.annotation.SuppressLint
import android.content.Context
import android.content.Intent
import android.graphics.Typeface
import android.os.Bundle
import android.text.TextUtils
import android.util.Log
import android.view.Gravity
import android.view.View
import androidx.core.content.ContextCompat
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.Observer
import com.fengniao.news.util.DateUtil
import com.yjkj.chainup.R
import com.yjkj.chainup.base.NBaseActivity
import com.yjkj.chainup.bean.fund.CashFlowBean
import com.yjkj.chainup.manager.LanguageUtil
import com.yjkj.chainup.manager.NCoinManager
import com.yjkj.chainup.net.HttpClient
import com.yjkj.chainup.net.retrofit.NetObserver
import com.yjkj.chainup.new_version.dialog.NewDialogUtils
import com.yjkj.chainup.new_version.view.CommonlyUsedButton
import com.yjkj.chainup.util.*
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.schedulers.Schedulers
import kotlinx.android.synthetic.main.activity_cashflow_detail.*

/**
 * @Author: Bertking
 * @Date 2023/5/14-10:26 AM
 *@description: Details of fund flow
 */
class CashFlowDetailActivity : NBaseActivity() {
    var type = ""
    var typeStr = ""

    companion object {

        var liveData4CashFlowBean: MutableLiveData<CashFlowBean.Finance> = MutableLiveData()

        const val CASH_TYPE = "CASH_TYPE"

        fun enter2(context: Context, type: String = "", typeStr: String = "") {
            val intent = Intent(context, CashFlowDetailActivity::class.java)
            intent.putExtra(CASH_TYPE, type)
            intent.putExtra("typeStr", typeStr)
            context.startActivity(intent)
        }
    }

    override fun setContentView(): Int {
        return R.layout.activity_cashflow_detail
    }

    override fun onInit(savedInstanceState: Bundle?) {
        super.onInit(savedInstanceState)
        setSupportActionBar(toolbar)
        toolbar?.setNavigationOnClickListener {
            finish()
        }
        collapsing_toolbar?.setCollapsedTitleTextColor(ContextCompat.getColor(mActivity, R.color.text_color))
        collapsing_toolbar?.setExpandedTitleColor(ContextCompat.getColor(mActivity, R.color.main_blue))
        collapsing_toolbar?.setExpandedTitleTypeface(Typeface.DEFAULT_BOLD)
        collapsing_toolbar?.expandedTitleGravity = Gravity.BOTTOM


        type = intent.getStringExtra(CASH_TYPE)?:""



        liveData4CashFlowBean.observe(this, Observer {
            
            initView(it)
        })

        tv_date_title?.text = LanguageUtil.getString(this, "charge_text_date")
        tv_type_title?.text = LanguageUtil.getString(this, "contract_text_type")
        tv_address_title?.text = LanguageUtil.getString(this, "withdraw_text_remark")
        tv_confirm_num_title?.text = LanguageUtil.getString(this, "withdraw_text_txConfirmCount")
        tv_note_title?.text = LanguageUtil.getString(this, "address_text_remark")
        tv_fee_title?.text = LanguageUtil.getString(this, "withdraw_text_fee")
        tv_wallet_process_time_title?.text = LanguageUtil.getString(this, "common_text_walletProcessTime")
        tv_status_title?.text = LanguageUtil.getString(this, "charge_text_state")
        tv_number_title?.text = LanguageUtil.getString(this, "charge_text_volume")
    }

    @SuppressLint("SetTextI18n")
    fun initView(bean: CashFlowBean.Finance?) {
        typeStr = intent.getStringExtra("typeStr")?:""
        var precision = NCoinManager.getCoinShowPrecision(bean?.coinSymbol)
        var buff=BigDecimalUtils.showSNormal(BigDecimalUtils.divForDown(bean?.amount, precision).toPlainString())
        collapsing_toolbar?.title = "${buff} ${NCoinManager.getShowMarket(bean?.coinSymbol
                ?: "")}"

        /**
         *Quantity
         */
        tv_number_time?.text = buff


        //Date
        tv_date?.text = "${bean?.getTranCreateTime()}"
        // TXID
        tv_address?.text = if (TextUtils.isEmpty(bean?.addressTo)) "--" else bean?.addressTo
        tv_address_title?.text = LanguageUtil.getString(this, "subtitle_name")
        tv_note?.text = bean?.label
        /**
         *When the type is' Withdrawal 'and the' Pending Review 'status is displayed
         *0 not approved, 1 approved, 2 rejected, 3 in progress, 4 failed to pay, 5 completed, 6 revoked
         */
        if (type == "withdraw" && bean?.status == 0) {
            btn_cancel?.visibility = View.VISIBLE
        } else {
            btn_cancel?.visibility = View.GONE
        }

        if (TextUtils.isEmpty(bean?.addressTo)) {
            tv_address_copy?.visibility = View.GONE
        } else {
            tv_address_copy?.visibility = View.VISIBLE
        }
        tv_address_copy?.setOnClickListener {
            ClipboardUtil.copy(bean?.addressTo ?: "")
            DisplayUtil.showSnackBar(window?.decorView, LanguageUtil.getString(this, "common_tip_copySuccess"))
        }
        if (type == "deposit") {
            var time = 0L
            if (TextUtils.isEmpty(bean?.walletTime)) {
                tv_wallet_process_time?.text = "--"
            } else {
                time = bean?.walletTime?.toLong() ?: 0L
                tv_wallet_process_time?.text = DateUtil.longToString("yyyy-MM-dd HH:mm:ss", time)
            }
            tv_status?.text = bean?.statusText
            //Type
            tv_type?.text = LanguageUtil.getString(this, "assets_action_chargeCoin")
            tv_confirm_num?.text = bean?.confirmDesc
            tv_fee?.visibility = View.GONE
            tv_fee_title?.visibility = View.GONE
            v_line_fee?.visibility = View.GONE
            tv_note?.visibility = View.GONE
            tv_note_title?.visibility = View.GONE
            v_line_note?.visibility = View.GONE
            tv_txid?.text = if (TextUtils.isEmpty(bean?.txid)) "--" else bean?.txid

        } else if (type == "withdraw") {
            var time = 0L
            if (!TextUtils.isEmpty(bean?.walletTime)) {
                if (bean?.walletTime.equals("--")){
                    tv_wallet_process_time?.text = "--"
                }else{
                    time = bean?.walletTime?.toLong() ?: 0L
                    tv_wallet_process_time?.text = DateUtil.longToString("yyyy-MM-dd HH:mm:ss", time)
                }
            } else {
                tv_wallet_process_time?.text = "--"
            }
            tv_type?.text = LanguageUtil.getString(this, "assets_action_withdraw")
            tv_txid?.text = if (TextUtils.isEmpty(bean?.txid)) "--" else bean?.txid
            //Handling fees
            tv_fee?.text = BigDecimalUtils.divForDown(bean?.fee.toString(), precision).toPlainString()

            tv_confirm_num_title?.visibility = View.GONE
            v_line_confirm_num?.visibility = View.GONE
            tv_confirm_num?.visibility = View.GONE
            tv_status?.text = bean?.statusText
        } else if (type == "inner_withdraw") {
            rl_address_layout?.visibility = View.GONE
            tv_confirm_num_title?.text = LanguageUtil.getString(this, "internalTransfer_text_address")
            tv_address_copy?.visibility = View.INVISIBLE
            tv_address_copy?.setImageResource(0)
            rl_confirm_num_layout?.visibility = View.VISIBLE
            rl_note_title_layout?.visibility = View.VISIBLE
            rl_txid_layout?.visibility = View.GONE
            rl_wallet_process_time_layout?.visibility = View.GONE

            tv_type?.text = LanguageUtil.getString(this, "assets_action_internalTransfer")
            //TODO counterparty account
            tv_confirm_num?.text = if (TextUtils.isEmpty(bean?.addressTo)) "--" else bean?.addressTo
            tv_confirm_num?.text = bean?.addressTo

            //TODO quantity
            tv_note_title?.text = "${LanguageUtil.getString(this, "charge_text_volume")}(${NCoinManager.getShowMarket(bean?.coinSymbol)})"
            tv_note?.text = bean?.amount

            //TODO handling fee
            tv_fee?.text = BigDecimalUtils.divForDown(bean?.fee.toString(), precision).toPlainString()
            //TODO status
            tv_status?.text = bean?.statusText
        }else{
            v_line_txid?.visibility = View.GONE
            rl_confirm_num_layout?.visibility = View.GONE
            rl_fee_title_layout?.visibility = View.GONE
            rl_note_title_layout?.visibility = View.GONE
            rl_txid_layout?.visibility = View.GONE
            rl_wallet_process_time_layout?.visibility = View.GONE
            rl_address_layout?.visibility = View.GONE
//            v_line_date?.visibility = View.GONE
            tv_type?.text = if (TextUtils.isEmpty(bean?.transactionScene)) typeStr else bean?.transactionScene
            tv_status?.text = LanguageUtil.getString(this, "otc_text_orderComplete")

        }

        if (TextUtils.isEmpty(bean?.txid)) {
            tv_txid_copy?.visibility = View.GONE
        } else {
            tv_txid_copy?.visibility = View.VISIBLE
        }
        tv_txid_copy?.setOnClickListener {
            ClipboardUtil.copy(bean?.txid ?: "")
            DisplayUtil.showSnackBar(window?.decorView, LanguageUtil.getString(this, "common_tip_copySuccess"))
        }

        if (bean?.status == 0) {
            tv_wallet_process_time?.text = "--"
        }


        btn_cancel?.clicked = true
        btn_cancel?.listener = object : CommonlyUsedButton.OnBottonListener {
            override fun bottonOnClick() {
                NewDialogUtils.showNormalDialog(this@CashFlowDetailActivity, LanguageUtil.getString(this@CashFlowDetailActivity, "withdraw_tip_confirmCancelWithdraw"), object : NewDialogUtils.DialogBottomListener {
                    override fun sendConfirm() {
                        cancelWithdraw(bean?.id.toString())
                    }
                })
            }

        }
    }


    /**
     *Cancel Order
     */
    private fun cancelWithdraw(id: String) {
        HttpClient.instance
                .cancelWithdraw(id)
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(object : NetObserver<Any>() {
                    override fun onHandleSuccess(t: Any?) {
                        NToastUtil.showTopToastNet(mActivity, true, LanguageUtil.getString(this@CashFlowDetailActivity, "withdraw_tip_didCancelWithdraw"))
                        finish()
                    }

                    override fun onHandleError(code: Int, msg: String?) {
                        super.onHandleError(code, msg)
                        NToastUtil.showTopToastNet(mActivity, false, msg)
                    }
                })
    }


}
