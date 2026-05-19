package com.yjkj.chainup.new_contract.activity

import android.app.Activity
import android.content.ClipData
import android.content.ClipboardManager
import android.content.Intent
import android.graphics.drawable.Drawable
import android.os.Bundle
import android.text.Spannable
import android.text.SpannableString
import android.text.SpannableStringBuilder
import android.text.TextUtils
import android.text.style.ClickableSpan
import android.text.style.ForegroundColorSpan
import android.view.Gravity
import android.view.View
import android.widget.TextView
import androidx.core.content.ContextCompat
import androidx.recyclerview.widget.LinearLayoutManager
import com.chad.library.adapter.base.BaseQuickAdapter
import com.chad.library.adapter.base.viewholder.BaseViewHolder
import com.chainup.contract.R
import com.chainup.contract.app.CpAppConfig
import com.chainup.contract.base.CpNBaseActivity
import com.chainup.contract.ui.activity.CpWebViewActivity
import com.chainup.contract.utils.*
import com.chainup.contract.view.CpEmptyForAdapterView
import com.chainup.contract.view.CpEmptyOrderForAdapterView
import com.chainup.contract.view.CpNewDialogUtils
import com.chainup.contract.view.dialog.CpTDialog
import com.chainup.kit.KKDialogUtils
import com.chainup.kit.utils.ToastUtils
import com.chainup.kit.views.KKEmptyViewKit
import com.jaeger.library.StatusBarUtil
import com.yjkj.chainup.manager.CpLanguageUtil
import com.yjkj.chainup.net_new.rxjava.CpNDisposableObserver
import com.yjkj.chainup.new_contract.bean.CpCurrentOrderBean
import kotlinx.android.synthetic.main.cp_activity_contract_entrust_detail.*
import org.jetbrains.anko.textColor
import org.json.JSONObject
import java.math.BigDecimal

/**
 *Entrustment details
 *
 *  cp_ overview_ Text34="Average Price"
    cp_order_text102 = "价值"


    1.委托详情文案调整：
    均价/价格:   Avg./Price                                   cp_overview_text34 = "均价" /cp_overview_text6

    限价：成交/数量（ETH）或 成交/数量（张） Filled/Size             "cp_order_text60"="成交"; /"cp_overview_text8"
    市价：成交（ETH)/价值（USDT）或 成交（张)/价值（USDT）Filled/Size    cp_order_text60/cp_order_text102

    2.委托详情数据显示规则：
    成交均价、价格：若没有数据则显示为"--"，若数据为0，则正常显示为0
    强平委托：成交均价、价格 无论有没有返回数值都显示为“--”
    未成交委托：成交均价 显示为"--"，成交数量显示为：0（精度按照数量精度），手续费显示为“--”（精度按照数量精度）
 */
class CpContractEntrustDetailActivity : CpNBaseActivity() {
    override fun setContentView(): Int {
        return R.layout.cp_activity_contract_entrust_detail
    }

    private var contractOrder: CpCurrentOrderBean? = null

    private var mContractTransactionRecordAdapter: ContractTransactionRecordAdapter? = null
    private val mList = ArrayList<JSONObject>()

    var mPricePrecision = 0
    var mMultiplierCoin = ""
    var mMarginCoin = "--"
    var mMarginCoinPrecision = 0
    var mMultiplier = "0"
    var mMultiplierPrecision = 0
    private var mAdlDialog: CpTDialog? = null
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        StatusBarUtil.setColor(this,ContextCompat.getColor(this,R.color.bg_card_color),0)
        loadData()
        initView()
    }

    override fun loadData() {
        contractOrder = intent.extras?.getSerializable("order") as CpCurrentOrderBean?
        if (contractOrder == null) {
            finish()
        }

        mMultiplierCoin = CpClLogicContractSetting.getContractMultiplierCoinPrecisionById(this, contractOrder?.contractId!!.toInt())

        mPricePrecision = CpClLogicContractSetting.getContractSymbolPricePrecisionById(this, contractOrder?.contractId!!.toInt())

        mMarginCoinPrecision = CpClLogicContractSetting.getContractMarginCoinPrecisionById(this, contractOrder?.contractId!!.toInt())

        mMarginCoin = CpClLogicContractSetting.getContractMarginCoinById(this, contractOrder?.contractId!!.toInt())

        mMultiplierPrecision = CpClLogicContractSetting.getContractMultiplierPrecisionById(this, contractOrder?.contractId!!.toInt())

        mMultiplier = CpClLogicContractSetting.getContractMultiplierById(this, contractOrder?.contractId!!.toInt())

        //Number of transactions
//        tv_volume.setText(CpLanguageUtil.getString(this,"cp_extra_text8") + if (CpClLogicContractSetting.getContractUint(this) == 0) "(" + CpLanguageUtil.getString(this,.string.cp_overview_text9) + ")" else "(" + mMultiplierCoin + ")")
        tv_trades_volume_key.setText(CpLanguageUtil.getString(this,"cp_extra_text8") + if (CpClLogicContractSetting.getContractUint(this) == 0) "(" + CpLanguageUtil.getString(this,"cp_overview_text9") + ")" else "(" + mMultiplierCoin + ")")

        //Average transaction price
//        tv_deal_price.setText(CpLanguageUtil.getString(this,.string.cl_average_price_str) + "(" + contractOrder?.quote + ")")
        tv_deal_price_key.setText(CpLanguageUtil.getString(this,"cp_extra_text31") + "(" + mMarginCoin + ")")

        //Handling fee
//        tv_fee.setText(CpLanguageUtil.getString(this,.string.cp_position_text2) + "(" + mMarginCoin + ")")
        tv_fee_key.setText(CpLanguageUtil.getString(this,"cp_position_text2") + "(" + mMarginCoin + ")")

        tv_pl_price_key.setText(CpLanguageUtil.getString(this,"cp_order_text8") + "(" + mMarginCoin + ")")
    }

    override fun initView() {
        tv_liq_label.text = CpLanguageUtil.getString(this,"cp_calculator_text20")

        tv_price_title.setOnClickListener(this)
        tv_liq_label.setOnClickListener(this)

        mContractTransactionRecordAdapter = ContractTransactionRecordAdapter(mList)
        ll_layout.layoutManager = LinearLayoutManager(this)

        val emptyView = KKEmptyViewKit(this)
        emptyView.setImageViewTop(16.0f)
        mContractTransactionRecordAdapter?.setEmptyView(emptyView)
        ll_layout.adapter = mContractTransactionRecordAdapter

        initAutoStringView()
        contractOrder?.let {
            //Contract Name
            val symbol = CpClLogicContractSetting.getContractShowNameById(mActivity, it.contractId.toInt())
            tv_contract_name.text = symbol
            //Direction
            when (it.side) {
                "BUY" -> {
                    if (it.open.equals("OPEN")) {
                        tv_type.setText(CpLanguageUtil.getString(this,"cp_overview_text13"))
                        tv_type.setTextColor(CpColorUtil.getMainColorType(true))
//                        collapsing_toolbar.title = symbol
                    } else {
                        tv_type.setText(CpLanguageUtil.getString(this,"cp_extra_text4"))
                        tv_type.setTextColor(CpColorUtil.getMainColorType(true))
//                        collapsing_toolbar.title = symbol
                    }
                }
                "SELL" -> {
                    if (it.open.equals("OPEN")) {
                        tv_type.setText(CpLanguageUtil.getString(this,"cp_overview_text14"))
                        tv_type.setTextColor(CpColorUtil.getMainColorType(false))
//                        collapsing_toolbar.title = symbol
                    } else {
                        tv_type.setText(CpLanguageUtil.getString(this,"cp_extra_text5"))
                        tv_type.setTextColor(CpColorUtil.getMainColorType(false))
//                        collapsing_toolbar.title = symbol
                    }
                }
            }
            ll_stop_profit.visibility = if (it.otoOrder == null) View.GONE else View.VISIBLE
            ll_stop_profit_title.visibility = if (it.otoOrder == null) View.GONE else View.VISIBLE

            if (it.otoOrder != null) {
                tv_stop_profit_trigger_price_value.setText(if (it.otoOrder.takerProfitTrigger.toString().equals("0")) CpLanguageUtil.getString(this,"cp_overview_text53") else it.otoOrder.takerProfitTrigger)
                tv_stop_profit_entrust_price_value.setText(if (it.otoOrder.takerProfitPrice.toString().equals("0")) CpLanguageUtil.getString(this,"cp_overview_text53") else it.otoOrder.takerProfitPrice)
                if (it.otoOrder.takerProfitPrice.toString().equals("null")) {
                    tv_stop_profit_state_value.setText("--")
                    ll_stop_profit.visibility = View.GONE
                } else {
                    tv_stop_profit_state_value.setText(if (it.otoOrder.takerProfitStatus) CpLanguageUtil.getString(this,"cp_order_text88") else CpLanguageUtil.getString(this,"cp_extra_text72"))
                }

                tv_stop_loss_trigger_price_value.setText(if (it.otoOrder.stopLossTrigger.toString().equals("0")) CpLanguageUtil.getString(this,"cp_overview_text53") else it.otoOrder.stopLossTrigger)
                tv_loss_profit_entrust_price_value.setText(if (it.otoOrder.stopLossPrice.toString().equals("0")) CpLanguageUtil.getString(this,"cp_overview_text53") else it.otoOrder.stopLossPrice)

                if (it.otoOrder.stopLossPrice.toString().equals("null")) {
                    tv_loss_profit_state_value.setText("--")
                } else {
                    tv_loss_profit_state_value.setText(if (it.otoOrder.stopLossStatus) CpLanguageUtil.getString(this,"cp_order_text88") else CpLanguageUtil.getString(this,"cp_extra_text72"))
                }
            }


            tv_pl_price.text = CpBigDecimalUtils.formatNumberWithLogo(CpBigDecimalUtils.showSNormal(it.realizedAmount, mMarginCoinPrecision))
            val isRise = CpBigDecimalUtils.compareTo(it.realizedAmount,"0") >= 0
            tv_pl_price.textColor = CpColorUtil.getMainColorType(isRise,CpBigDecimalUtils.compareTo(it.realizedAmount,"0")==0)

            tv_order_type.text = when (it.orderType) {
                "1" -> CpLanguageUtil.getString(this,"cp_overview_text3")//Price limit order
                "2" -> CpLanguageUtil.getString(this,"cp_overview_text4")//Market Price List
                "3" -> "IOC"
                "4" -> "FOK"
                "5" -> "Post Only"
                "6" -> CpLanguageUtil.getString(this,"cp_extra_text6") //Compulsory position reduction
                "7" -> CpLanguageUtil.getString(this,"cp_extra_text7") //Position Consolidation
                "9" -> CpLanguageUtil.getString(this,"cp_other_text2")//System Closing
                "10" -> CpLanguageUtil.getString(this,"cp_other_text3")//System delivery
                "11" -> CpLanguageUtil.getString(this,"cp_order_adl1")//System delivery
                else -> "error"
            }
            tv_order_type.isEnabled=false

            tv_date.text = CpTimeFormatUtils.timeStampToDate(it.ctime.toLong(), "yyyy-MM-dd  HH:mm:ss")
            tv_status.text = when (it.status) {
                "2" -> CpLanguageUtil.getString(this,"cp_extra_text1")//Complete transaction
                "3" -> CpLanguageUtil.getString(this,"   ")//"部分成交"
                "4" -> CpLanguageUtil.getString(this,"cp_status_text2")//"已撤销"
                "5" -> CpLanguageUtil.getString(this,"cp_status_text4")//"待撤销"
                "6" -> CpLanguageUtil.getString(this,"cp_status_text3")//"异常订单"
                else -> "error"
            }
            tv_id.text =it.orderId
        }

        tv_liq.setOnClickListener {
            contractOrder?.run{
                if("6".equals(this.source)){
                    if(liqPositionMsgTimeStamp.isNotEmpty()){
                        var tip = liqPositionMsg
                        if (TextUtils.isEmpty(tip)){
                            tip = ""
                        }
                        tip = CpStringUtil.liqPositionTime(tip,liqPositionMsgTimeStamp)
                        CpNewDialogUtils.showDialogNew(
                            mActivity,
                            tip,
                            true,
                            null,
                            CpLanguageUtil.getString(this@CpContractEntrustDetailActivity,"cp_extra_text80"),
                            CpLanguageUtil.getString(this@CpContractEntrustDetailActivity,"cp_extra_text28"),
                            contentGravity = Gravity.LEFT
                        )
                    }
                }else if("11".equals(this.source)) {
                    val normalText = CpLanguageUtil.getString(mActivity,"cp_order_adl2")
                    val linkText = CpLanguageUtil.getString(mActivity,"cp_adl_introduce")
                    val spannableStringBuilder = SpannableStringBuilder()
                    spannableStringBuilder.append(normalText)
                    spannableStringBuilder.append(" ")
                    spannableStringBuilder.append(linkText)
                    spannableStringBuilder.setSpan(ForegroundColorSpan(ContextCompat.getColor(this@CpContractEntrustDetailActivity,R.color.main_color)),normalText.length+1,(normalText.length+1+linkText.length),SpannableString.SPAN_EXCLUSIVE_EXCLUSIVE)
                    spannableStringBuilder.setSpan(object : ClickableSpan(){
                        override fun onClick(widget: View) {
                            val uri = if(CpSystemUtils.isZh()){
                                CpAppConfig.adl_uri_zh
                            }else{
                                CpAppConfig.adl_uri_en
                            }
                            CpWebViewActivity.enterActivity(this@CpContractEntrustDetailActivity, uri)
                            mAdlDialog?.dismiss()
                        }
                    },normalText.length+1,(normalText.length+1+linkText.length),SpannableString.SPAN_EXCLUSIVE_EXCLUSIVE)
                    mAdlDialog = CpNewDialogUtils.showDialogNew(
                        this@CpContractEntrustDetailActivity,
                        spannableStringBuilder,
                        true,
                        null,
                        CpLanguageUtil.getString(this@CpContractEntrustDetailActivity,"cp_order_adl1"),
                        CpLanguageUtil.getString(this@CpContractEntrustDetailActivity,"cp_extra_text28"),
                        contentGravity = Gravity.LEFT
                    )
                }

            }

        }

        tv_order_tips.setText(when (contractOrder?.memo) {
            1 -> CpLanguageUtil.getString(this,"cp_extra_text17")
            2 -> CpLanguageUtil.getString(this,"cp_extra_text73")
            3 -> CpLanguageUtil.getString(this,"cp_extra_text74")
            4 -> CpLanguageUtil.getString(this,"cp_extra_text75")
            5 -> CpLanguageUtil.getString(this,"cp_extra_text76")
            6 -> CpLanguageUtil.getString(this,"cp_extra_text77")
            7 -> CpLanguageUtil.getString(this,"cp_extra_text78")
            8 -> CpLanguageUtil.getString(this,"cp_extra_text79")
            11 -> CpLanguageUtil.getString(this,"cp_other_text1")
            12 -> CpLanguageUtil.getString(this,"cp_order_adl3")
            else -> ""
        })
        ll_list_tips.visibility = if (contractOrder?.status.equals("4")) View.VISIBLE else View.GONE
//        ll_list_title.visibility = if (!contractOrder?.status.equals("4")) View.VISIBLE else View.GONE


        val mContractUint = CpClLogicContractSetting.getContractUint(this@CpContractEntrustDetailActivity)
        contractOrder?.let {

            val mMarginCoin = CpClLogicContractSetting.getContractMarginCoinById(mActivity, it.contractId.toInt())
            var contractSide = CpClLogicContractSetting.getContractSideById(this@CpContractEntrustDetailActivity, it.contractId.toInt())

            //Average transaction price
            val dealPriceValue = if(it.avgPrice.isNullOrEmpty()) "--" else CpBigDecimalUtils.showSNormalNew(it.avgPrice, CpClLogicContractSetting.getContractSymbolPricePrecisionById(this,it.contractId.toInt()))
            //Commission price
            val entrustPrice = if ("2".equals(it.type)||"2".equals(it.orderType)) CpLanguageUtil.getString(this,"cp_overview_text53")
                else (
                        if(it.price.isNullOrEmpty()) "--" else CpBigDecimalUtils.showSNormal(it.price, it.pricePrecision)
                )

            //Volume
            val dealVolumeValue = if (mContractUint == 0) {
                it.dealVolume
            } else {
                CpBigDecimalUtils.mulStr(it.dealVolume, mMultiplier, mMultiplierPrecision)
            }


            //Quantity
            if (it.open.equals("OPEN") && it.type.equals("2")) {
                //Entrustment value
                tv_entrust_amount_key.text = (
                    //Transaction (ETH)/Value (USDT) Transaction (sheet)/Value (USDT)
                    (CpLanguageUtil.getString(this,"cp_order_text60") + if (mContractUint == 0) "(" + CpLanguageUtil.getString(this,"cp_overview_text9") + ")" else "(" + mMultiplierCoin + ")")
                    + "/" +
                    (CpLanguageUtil.getString(this,"cp_order_text102") + "(" + mMarginCoin + ")")
                )
                val spanString = SpannableString("$dealVolumeValue / ${it.volume}")
                spanString.setSpan(ForegroundColorSpan(ContextCompat.getColor(this, R.color.text_color_2)), spanString.indexOf("/"), spanString.length, Spannable.SPAN_EXCLUSIVE_EXCLUSIVE)
                tv_entrust_amount.text = spanString
            } else {
                //Entrusted quantity
                val entrustAmountValue = if (mContractUint == 0) it.volume else CpBigDecimalUtils.mulStr(it.volume, mMultiplier, mMultiplierPrecision)
                tv_entrust_amount_key.text = (
                    //Transaction/Quantity (ETH) Transaction/Quantity (sheet)
                    CpLanguageUtil.getString(this,"cp_order_text60") +"/"+ CpLanguageUtil.getString(this,"cp_overview_text8") + if (mContractUint == 0) "(" + CpLanguageUtil.getString(this,"cp_overview_text9") + ")" else "(" + mMultiplierCoin + ")"
                )
                val spanString = SpannableString("$dealVolumeValue / $entrustAmountValue")
                spanString.setSpan(ForegroundColorSpan(ContextCompat.getColor(this, R.color.text_color_2)), spanString.indexOf("/"), spanString.length, Spannable.SPAN_EXCLUSIVE_EXCLUSIVE)
                tv_entrust_amount.text = spanString
            }
            //Price
            var spanString = SpannableString("${dealPriceValue} / ${entrustPrice}")

            val isGone = null==it.source||(!it.source.equals("6")&&!it.source.equals("7")&&!it.source.equals("9")&&!it.source.equals("10")&&!it.source.equals("11"))
            if(isGone){
                tv_liq.visibility = View.GONE
            } else{
                tv_liq.visibility = View.VISIBLE
                tv_liq.text = when (it.source) {
                    "6" -> CpLanguageUtil.getString(
                        this,
                        "cp_extra_text6"
                    )//compulsoryPositionReduction
                    "7" -> CpLanguageUtil.getString(this, "cp_extra_text7")//positionConsolidation
                    "9" -> CpLanguageUtil.getString(this, "cp_other_text2")//systemClosing
                    "10" -> CpLanguageUtil.getString(this, "cp_other_text3")//systemDelivery
                    "11" -> CpLanguageUtil.getString(this, "cp_order_adl1")
                    else -> "error"
                }
            }

            if (!isGone) {
                val nav_up = getResources().getDrawable(R.mipmap.public_hint)
                nav_up.setBounds(0, 0, nav_up.getMinimumWidth(), nav_up.getMinimumHeight())
                tv_liq.setCompoundDrawables(null, null, if ("6".equals(it.source)||"11".equals(it.source)) nav_up else null, null)
            }
            if("6".equals(it.source)){
                ll_liq.visibility = View.VISIBLE
                tv_liq_value.text = CpBigDecimalUtils.showSNormal(it.forcedPrice,mPricePrecision)
                val takeOverPriceStr = CpBigDecimalUtils.showSNormal(it.takeOverPrice,mPricePrecision)
                spanString = SpannableString("$takeOverPriceStr / $takeOverPriceStr")

                val iconLiq = getResources().getDrawable(R.mipmap.public_hint)
                iconLiq.setBounds(0, 0, iconLiq.getMinimumWidth(), iconLiq.getMinimumHeight())
                tv_price_title.setCompoundDrawables(null, null, iconLiq, null)
                val iconLiq2 = getResources().getDrawable(R.mipmap.public_hint)
                iconLiq2.setBounds(0, 0, iconLiq2.getMinimumWidth(), iconLiq2.getMinimumHeight())
                tv_liq_label.setCompoundDrawables(null, null, iconLiq2, null)
                tv_price_title.isEnabled = true
                tv_liq_label.isEnabled = true
            }else{
                ll_liq.visibility = View.GONE
                tv_price_title.isEnabled = false
                tv_liq_label.isEnabled = false
                tv_price_title.setCompoundDrawables(null, null, null, null)
                tv_liq_label.setCompoundDrawables(null, null, null, null)
            }
            spanString.setSpan(ForegroundColorSpan(ContextCompat.getColor(this, R.color.text_color_2)), spanString.indexOf("/"), spanString.length, Spannable.SPAN_EXCLUSIVE_EXCLUSIVE)
            tv_entrust_price.text = spanString
            tv_liq.isEnabled="6".equals(it.source)||"11".equals(it.source)

        }

        //Copy id
        iv_copy?.setOnClickListener {
            val mClipboardManager = getSystemService(CLIPBOARD_SERVICE) as ClipboardManager
            if(mClipboardManager==null || contractOrder?.orderId.isNullOrEmpty()){
                //Replication failed
                ToastUtils.showToast(this,CpLanguageUtil.getString(this,"copy_failed"))
            }else{
                mClipboardManager.setPrimaryClip(ClipData.newPlainText("",contractOrder?.orderId))
                ToastUtils.showToast(this,CpLanguageUtil.getString(this,"common_tip_copySuccess"))
            }
        }

        getHistoryTradeList()
    }

    private fun getHistoryTradeList() {
        mList.clear()
        addDisposable(getContractModel().getHistoryTradeList(contractOrder?.contractId!!.toString(), contractOrder?.orderId!!,
                consumer = object : CpNDisposableObserver(mActivity, true) {
                    override fun onResponseSuccess(jsonObject: JSONObject?) {
                        jsonObject?.optJSONObject("data")?.run {
                            if (!isNull("tradeList")) {
                                val mTradeList = optJSONArray("tradeList")
                                var buffFee = BigDecimal.ZERO;
                                var feeCoinPrecision = 0
                                if (mTradeList.length() != 0) {
                                    for (i in 0..(mTradeList.length() - 1)) {
                                        var obj: JSONObject = mTradeList.get(i) as JSONObject
                                        buffFee = buffFee.add(BigDecimal(obj.optString("fee")))
                                        feeCoinPrecision = obj.optInt("feeCoinPrecision")
                                        obj.putOpt("mMultiplier", mMultiplier)
                                        obj.putOpt("mMultiplierPrecision", mMultiplierPrecision)
                                        obj.putOpt("mContractUint", CpClLogicContractSetting.getContractUint(this@CpContractEntrustDetailActivity))
                                        mList.add(obj)
                                    }
                                }
                                contractOrder?.let {
                                    //Handling fee
                                    val isCompensate = it.isCompensate?:false
                                    val isAdd = it.isAdd?:false
                                    val icTip = this@CpContractEntrustDetailActivity.getDrawable(R.mipmap.public_instructions)
                                    icTip?.setBounds(5, 0, icTip.getMinimumWidth(), icTip.getMinimumHeight())
                                    tv_fee_value.setCompoundDrawables(null, null, if (isCompensate) icTip else null, null)
                                    tv_fee_value.text = (if(isAdd) "+" else "")+CpBigDecimalUtils.showSNormal(it.tradeFee,feeCoinPrecision)
                                    if(isCompensate){
                                        tv_fee_value.setOnClickListener {
                                            KKDialogUtils.showCommonDialog(this@CpContractEntrustDetailActivity, title = CpLanguageUtil.getString(this@CpContractEntrustDetailActivity,"fee_tips"), content = "", isShowCancel = false, confrimTitle = CpLanguageUtil.getString(this@CpContractEntrustDetailActivity,"cp_extra_text28"), listener = null)
                                        }
                                    }else{
                                        tv_fee_value.setOnClickListener(null)
                                    }
                                    if ("6".equals(contractOrder?.source)){
                                        tv_fee_value.text = "--"
                                    }
                                }
                                mContractTransactionRecordAdapter?.notifyDataSetChanged()

                                //Hide title if there are no records
                                if(mList.size<=0){
                                    ll_record_title.visibility = View.GONE
                                    ll_record_pview_group.background = null
                                }else{
                                    ll_record_title.visibility = View.VISIBLE
                                    ll_record_pview_group.background = ContextCompat.getDrawable(this@CpContractEntrustDetailActivity,R.drawable.bg_default_color)
                                }
                            }else{
                                ll_record_title.visibility = View.GONE
                                ll_record_pview_group.background = null
                                if ("6".equals(contractOrder?.source)){
                                    tv_fee_value.text = "--"
                                }
                            }
                        }
                    }
                }))
    }

    private fun initAutoStringView() {
        mHeaderKit?.titleText = getLineText("cp_order_text85")

        //Average Price/Price: Avg./Price
        tv_price_title.text=getLineText("cp_overview_text47")+"/"+getLineText("cp_overview_text6")
        tv_cp_order_text93.text=getLineText("cp_order_text93")
        tv_cp_position_text2.text=getLineText("cp_position_text2")
        tv_cp_overview_text12.text=getLineText("cp_overview_text12")
        tv_cp_overview_text15.text=getLineText("cp_overview_text15")
        tv_cp_order_text91.text=getLineText("cp_order_text91")
        tv_cp_order_text87.text=getLineText("cp_order_text87")
        tv_cp_overview_text16.text=getLineText("cp_overview_text16")
        tv_cp_order_text37.text=getLineText("cp_order_text37")
        tv_cp_order_text86.text=getLineText("cp_order_text87")
        tv_cp_order_text123.text=getLineText("cp_order_text86")
        tv_time_label.text = getLineText("cp_order_time_label")
        tv_cp_order_direction_label.text = getLineText("cp_order_direction_label")
    }


    companion object {
        fun show(activity: Activity, order: CpCurrentOrderBean) {
            val intent = Intent(activity, CpContractEntrustDetailActivity::class.java)
            val bundle = Bundle()
            bundle.putSerializable("order", order)
            intent.putExtras(bundle)
            activity.startActivity(intent)
        }
    }

    override fun onClick(view: View) {
        super.onClick(view)
        when(view.id){
            R.id.tv_price_title -> {
                KKDialogUtils.showCommonDialog(
                    this,
                    title = CpLanguageUtil.getString(this,"order_history_bankr_price"),
                    listener = null,
                    confrimTitle = CpLanguageUtil.getString(this,"guide_3"),
                    isShowCancel = false,
                    style = 1
                )
            }
            R.id.tv_liq_label -> {
                KKDialogUtils.showCommonDialog(
                    this,
                    title = CpLanguageUtil.getString(this,"order_history_liq_price"),
                    listener = null,
                    confrimTitle = CpLanguageUtil.getString(this,"guide_3"),
                    isShowCancel = false,
                    style = 1
                )
            }
        }
    }

    class ContractTransactionRecordAdapter(data: ArrayList<JSONObject>) : BaseQuickAdapter<JSONObject, BaseViewHolder>(R.layout.cp_item_deal_order, data) {
        override fun convert(helper: BaseViewHolder, item: JSONObject) {
            helper?.run {
                //Transaction quantity (piece)
                setText(R.id.tv_type_value, if (item.optInt("mContractUint") == 0) {
                    item.optString("volume")
                } else {
                    CpBigDecimalUtils.mulStr(item.optString("volume"), item.optString("mMultiplier"), item.optInt("mMultiplierPrecision"))
                })
                //Transaction price
                setText(R.id.tv_time_value, CpBigDecimalUtils.showSNormal(item.optString("price"), item.optInt("pricePrecision")))
                val isAdd = item.optBoolean("isAdd")
                //Handling fees
                setText(R.id.tv_amount_value, (if(isAdd) "+" else "")+CpBigDecimalUtils.showSNormal(item.optString("fee"), item.optInt("feeCoinPrecision")))
            }
        }
    }
}

