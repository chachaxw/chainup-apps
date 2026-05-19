package com.yjkj.chainup.new_contract.adapter

import android.content.Context
import android.graphics.Color
import android.text.Html
import android.text.Spannable
import android.text.SpannableString
import android.text.style.ForegroundColorSpan
import android.widget.ProgressBar
import android.widget.TextView
import androidx.core.content.ContextCompat
import com.chad.library.adapter.base.BaseMultiItemQuickAdapter
import com.chad.library.adapter.base.module.LoadMoreModule
import com.chad.library.adapter.base.viewholder.BaseViewHolder
import com.chainup.contract.R
import com.chainup.contract.utils.*
import com.chainup.contract.view.trade.CircleProgressView
import com.chainup.kit.dialog.KKLoadingDialog
import com.yjkj.chainup.manager.CpLanguageUtil
import com.yjkj.chainup.new_contract.bean.CpCurrentOrderBean
import kotlinx.android.synthetic.main.cp_activity_contract_entrust_detail.*
import java.math.BigDecimal
import java.text.DecimalFormat
import java.util.*


class CpContractEntrustNewAdapter(ctx: Context, data: ArrayList<CpCurrentOrderBean>) :
    BaseMultiItemQuickAdapter<CpCurrentOrderBean, BaseViewHolder>(data), LoadMoreModule {

    init {
        addItemType(1, R.layout.cp_item_current_entrust)
        addItemType(2, R.layout.cp_item_plan_entrust)
        addItemType(3, R.layout.cp_item_history_common_entrust)
        addItemType(4, R.layout.cp_item_history_plan_entrust)
        addChildClickViewIds(R.id.tv_liquidation,R.id.tv_price_title,R.id.tv_liq_price_title)
    }

    //Is it the current delegation
    private var isCurrentEntrust = true
    private var loadDialog: KKLoadingDialog? = null


    //    var cp_overview_text130 = ""
//    var sl_str_sell_open0 = ""
//    var contract_flat_short = ""
//    var contract_flat_long = ""
//    var sl_str_latest_price_simple = ""
//    var sl_str_fair_price_simple = ""
//    var sl_str_index_price_simple = ""
//    var sl_str_trigger_price = ""
//    var sl_str_execution_price = ""
//    var sl_str_execution_volume = ""
    var cp_overview_text9 = ""

    //    var sl_str_market_price_simple = ""
//    var sl_str_deadline = ""
//    var sl_str_trigger_time = ""
//    var sl_str_cancel_order = ""
//    var sl_str_order_complete = ""
//    var sl_str_user_canceled = ""
//    var sl_str_order_timeout = ""
//    var sl_str_trigger_failed = ""
//    var cl_order_price_str = ""
    var cl_order_volume_str = ""

    //    var cl_open_value_str = ""
//    var cl_average_price_str = ""
//    var cp_overview_text3 = ""
//    var cp_overview_text4 = ""
//    var cl_reduce_only_str = ""
    var contract_text_orderWaitInHandicap = ""
    var statusText2 = ""
    var statusText3 = ""
    var statusText4 = ""
    var statusText5 = ""
    var statusText6 = ""
    var statusText7 = ""
    var statusText8 = ""
    var statusText9 = ""

    //    var sl_str_pl = ""
//    var cl_expration_date_str = ""
    var transaction_text_dealNum = ""

    //    var mMultiplierCoin = ""
//    var mPricePrecision = 0
//    var mMultiplierPrecision = 0
//    var mMultiplier = "0"
    var coUnit = 0

    init {

    }

    fun setIsCurrentEntrust(isCurrentEntrust: Boolean = true) {
        this.isCurrentEntrust = isCurrentEntrust
    }

    override fun convert(helper: BaseViewHolder, item: CpCurrentOrderBean) {
//        cp_ overview_ text130 = CpLanguageUtil.. GetString (this, "cp_overview_text13" 0)//Open multiple
//        sl_ str_ sell_ open0 = CpLanguageUtil.. GetString (this,. string. sl_str_sell_open0)//Open empty
//        contract_ flat_ short = CpLanguageUtil.. GetString (this,. string. contract_flat_short)//Flat
//        contract_ flat_ long = CpLanguageUtil.. GetString (this,. string. contract_flat_long)//Pingduo
//        sl_str_latest_price_simple = CpLanguageUtil..getString(this,.string.sl_str_latest_price_simple)//latestPrice
//        sl_str_fair_price_simple = CpLanguageUtil..getString(this,.string.sl_str_fair_price_simple)//reasonablePrice
//        sl_str_index_price_simple = CpLanguageUtil..getString(this,.string.sl_str_index_price_simple)//indexPrice
//        sl_str_trigger_price = CpLanguageUtil..getString(this,.string.sl_str_trigger_price)//triggerPrice
//        sl_str_execution_price = CpLanguageUtil..getString(this,.string.sl_str_execution_price)//executionPrice
//        sl_str_execution_volume = CpLanguageUtil..getString(this,.string.sl_str_execution_volume)//executedQuantity
        cp_overview_text9 = CpLanguageUtil.getString(context, "cp_overview_text9")//Zhang
//        sl_str_market_price_simple = CpLanguageUtil..getString(this,.string.sl_str_market_price_simple)//marketPrice
//        sl_str_deadline = CpLanguageUtil..getString(this,.string.sl_str_deadline)//expirationTime
//        sl_str_trigger_time = CpLanguageUtil..getString(this,.string.sl_str_trigger_time)//triggerTime
//        sl_str_cancel_order = CpLanguageUtil..getString(this,.string.sl_str_cancel_order)//revoke
//        sl_str_order_complete = CpLanguageUtil..getString(this,.string.sl_str_order_complete)//orderCompletion
//        sl_str_user_canceled = CpLanguageUtil..getString(this,.string.sl_str_user_canceled)//userCancel
//        sl_str_order_timeout = CpLanguageUtil..getString(this,.string.sl_str_order_timeout)//orderExpiration
//        sl_str_trigger_failed = CpLanguageUtil..getString(this,.string.sl_str_trigger_failed)//executionFailed
//        cl_order_price_str = CpLanguageUtil..getString(this,.string.cl_order_price_str)//commissionPrice
        cl_order_volume_str =
            CpLanguageUtil.getString(context, "cl_order_volume_str")//entrustedQuantity
//        cl_open_value_str = CpLanguageUtil..getString(this,.string.cl_open_value_str)//openingValue
//        cl_average_price_str = CpLanguageUtil..getString(this,.string.cl_average_price_str)//AverageTransactionPrice
//        cp_overview_text3 = CpLanguageUtil..getString(this,"cp_overview_text3")//limitOrder
//        cp_overview_text4 = CpLanguageUtil..getString(this,"cp_overview_text4")//marketOrder
        //numberOfTransactions
//        transaction_text_dealNum = CpLanguageUtil.getString(context,"cp_calculator_text10")
//        cl_reduce_only_str = CpLanguageUtil..getString(this,.string.cl_reduce_only_str)//onlyReducePositions
//        sl_str_pl = CpLanguageUtil..getString(this,.string.sl_str_pl)//profitAndLoss
//        cl_expration_date_str = CpLanguageUtil..getString(this,.string.cl_expration_date_str)//expirationTime
        contract_text_orderWaitInHandicap =
            CpLanguageUtil.getString(context, "cp_extra_text70")//Initial order
        statusText2 = CpLanguageUtil.getString(context, "cp_tip_text10")//"Expired"
        statusText3 = CpLanguageUtil.getString(context, "cp_tip_text11")//"Completed"
        statusText4 = CpLanguageUtil.getString(context, "cp_tip_text12")//"Trigger failed"
        statusText5 = CpLanguageUtil.getString(context, "cp_tip_text12")//"Execution failed"
        statusText6 = CpLanguageUtil.getString(context, "cp_status_text2")//"rescinded"
        statusText7 = CpLanguageUtil.getString(context, "cp_order_text63")//"Stop Gain Doc"
        statusText8 = CpLanguageUtil.getString(context, "cp_order_text62")//"Stop loss order"
        statusText9 = CpLanguageUtil.getString(context, "cp_order_text69")//"Condition order"


        coUnit = CpClLogicContractSetting.getContractUint(context)

        //margincoin
        val marginCoin =
            CpClLogicContractSetting.getContractMarginCoinById(context, item.contractId.toInt())
        val quote = CpClLogicContractSetting.getContractQuoteById(context, item.contractId.toInt())
        val marginCoinPrecision = CpClLogicContractSetting.getContractMarginCoinPrecisionById(
            context,
            item.contractId.toInt()
        )
        //contractMultiplier
        val multiplier =
            CpClLogicContractSetting.getContractMultiplierById(context, item.contractId.toInt())
        //contractMultiplierCoin
        val multiplierCoin =
            CpClLogicContractSetting.getContractMultiplierCoinById(context, item.contractId.toInt())

        val multiplierBuff = BigDecimal(multiplier).stripTrailingZeros().toPlainString()

        //ContractShowName
        var symbolName =
            CpClLogicContractSetting.getContractShowNameById(context, item.contractId.toInt())

        var mSymbolPricePrecision = CpClLogicContractSetting.getContractSymbolPricePrecisionById(
            context,
            item.contractId.toInt()
        )

        var contractSide =
            CpClLogicContractSetting.getContractSideById(context, item.contractId.toInt())

        //ValuePrecision
        val multiplierPrecision = if (multiplierBuff.contains(".")) {
            ChainUpLogUtil.e("------------", multiplierBuff)
            ChainUpLogUtil.e(
                "------------",
                multiplierBuff.split(".".toRegex()).toTypedArray().size.toString() + ""
            )
            val index = multiplierBuff.indexOf(".")
            if (index < 0) 0 else multiplierBuff.length - index - 1
        } else {
            multiplierBuff.length
        }
        var showDealNumber = ""
        var showEntrustNumber = ""
        //delegatedQuantityDisplayUnit
        var showEntrustUnit = ""
        if (coUnit == 0) {
            showEntrustUnit = cl_order_volume_str + "(" + cp_overview_text9 + ")"
        } else {
            showEntrustUnit = cl_order_volume_str + "(" + multiplierCoin + ")"
        }

        //transactionQuantityDisplayUnit
        var showDealUnit = ""
        if (coUnit == 0) {
            showDealUnit = transaction_text_dealNum + "(" + cp_overview_text9 + ")"
        } else {
            showDealUnit = transaction_text_dealNum + "(" + multiplierCoin + ")"
        }
        if (coUnit == 0) {
            //numberOfTransactions
            showDealNumber = item.dealVolume
            //entrustedQuantity
            showEntrustNumber = item.volume
            showDealUnit = transaction_text_dealNum + "(" + cp_overview_text9 + ")"
        } else {
            showDealNumber =
                CpBigDecimalUtils.mulStr(item.dealVolume, multiplier, multiplierPrecision)
            showEntrustNumber =
                CpBigDecimalUtils.mulStr(item.volume, multiplier, multiplierPrecision)
            showDealUnit = transaction_text_dealNum + "(" + multiplierCoin + ")"
        }

        if (item.type.equals("2") && item.open.equals("OPEN")) {
            showEntrustNumber = item.volume
        }


        var openStr = item.open
        var sideStr = item.side
        var typeStr = ""
        var isOnlyReducePosition = false
        var only_reduce_position = CpLanguageUtil.getString(context, "cp_extra_text2")//"否"
        //context.getLineText("cp_overview_text13")
        if (openStr.equals("OPEN") && sideStr.equals("BUY")) {
            typeStr = getTextByItemType(helper.itemViewType, "cp_overview_text13")//Purchase of Kaiduo
        } else if (openStr.equals("OPEN") && sideStr.equals("SELL")) {
            typeStr = getTextByItemType(helper.itemViewType, "cp_overview_text14")//Selling open space
        } else if (openStr.equals("CLOSE") && sideStr.equals("BUY")) {
            typeStr = getTextByItemType(helper.itemViewType, "cp_extra_text4")//Purchase of Ping Kong
        } else if (openStr.equals("CLOSE") && sideStr.equals("SELL")) {
            typeStr = getTextByItemType(helper.itemViewType, "cp_extra_text5")//Sales of Pingduo
        }
        typeStr = typeStr.replace("\\n","<br/>").trim()
        if (openStr.equals("CLOSE")) {
            only_reduce_position = CpLanguageUtil.getString(context, "cp_extra_text3")//"是"
            isOnlyReducePosition = true
        }


        //Limit Order, Market Order, IOC, FOK, Post Only


////Normal
//            helper.setGone(R.id.ll_plan, true)
//            helper.setGone(R.id.ll_common, false)
        when (sideStr) {
            "BUY" -> {
                helper?.setTextColor(R.id.tv_side, CpColorUtil.getMainColorType(true))
            }
            "SELL" -> {
                helper?.setTextColor(R.id.tv_side, CpColorUtil.getMainColorType(false))
            }
            else -> {
            }
        }

        //Ensure no flashback for compatibility: when the new version uses orderType and the old version uses type test, the online environment orderType does not exist and will crash
        var orderType = try {
            when (item.orderType) {
                "1" -> CpLanguageUtil.getString(context, "cp_overview_text3")//"limitOrder"
                "2" -> CpLanguageUtil.getString(context, "cp_overview_text4")//"marketOrder"
                "3" -> "IOC"
                "4" -> "FOK"
                "5" -> "Post Only"
                "6" -> CpLanguageUtil.getString(
                    context,
                    "cp_extra_text6"
                )//compulsoryPositionReduction
                "7" -> CpLanguageUtil.getString(context, "cp_extra_text7")//positionConsolidation
                "9" -> CpLanguageUtil.getString(context, "cp_other_text2")//systemClosing
                "10" -> CpLanguageUtil.getString(context, "cp_other_text3")//systemDelivery
                else -> "error"
            }
        } catch (e: Exception) {
            when (item.type) {
                "1" -> CpLanguageUtil.getString(context, "cp_overview_text3")//"limitOrder"
                "2" -> CpLanguageUtil.getString(context, "cp_overview_text4")//"marketOrder"
                "3" -> "IOC"
                "4" -> "FOK"
                "5" -> "Post Only"
                "6" -> CpLanguageUtil.getString(
                    context,
                    "cp_extra_text6"
                )//compulsoryPositionReduction
                "7" -> CpLanguageUtil.getString(context, "cp_extra_text7")//positionConsolidation
                "9" -> CpLanguageUtil.getString(context, "cp_other_text2")//systemClosing
                "10" -> CpLanguageUtil.getString(context, "cp_other_text3")//systemDelivery
                else -> "error"
            }
        }


        var sourceType: String = if (item.source == null) {
            "error"
        } else {
            when (item.source) {
                "6" -> CpLanguageUtil.getString(
                    context,
                    "cp_extra_text6"
                )//compulsoryPositionReduction
                "7" -> CpLanguageUtil.getString(context, "cp_extra_text7")//positionConsolidation
                "9" -> CpLanguageUtil.getString(context, "cp_other_text2")//systemClosing
                "10" -> CpLanguageUtil.getString(context, "cp_other_text3")//systemDelivery
                "11" -> CpLanguageUtil.getString(context, "cp_order_adl1")
                else -> "error"
            }
        }


        if (coUnit == 0) {
            showDealUnit = "(" + CpLanguageUtil.getString(context, "cp_overview_text9") + ")"
        } else {
            showDealUnit = "(" + multiplierCoin + ")"
        }


        when (helper.itemViewType) {
            1 -> {
                helper.setText(
                    R.id.tv_price_title,
                    CpLanguageUtil.getString(context, "cp_overview_text6")
                )
                helper.setText(
                    R.id.tv_volume_title,
                    CpLanguageUtil.getString(context, "cp_order_text81")
                )
                helper.setText(
                    R.id.tv_deal_title,
                    CpLanguageUtil.getString(context, "cp_overview_text12")
                )
                helper.setText(R.id.tv_cancel, CpLanguageUtil.getString(context, "cp_order_text68"))

                var volumePercentBig = CpBigDecimalUtils.div(item.dealVolume, item.volume, 2)
                var volumePercentStr = DecimalFormat("0%").format(volumePercentBig)
                helper.setText(R.id.tv_side, Html.fromHtml(typeStr))
                helper.setText(R.id.tv_coin_name, symbolName)
                helper.setText(
                    R.id.tv_date,
                    CpTimeFormatUtils.timeStampToDate(item.ctime.toLong(), "yyyy-MM-dd  HH:mm:ss")
                )
                helper.setText(R.id.tv_order_type, orderType)
                helper.setText(
                    R.id.tv_price,
                    if(item.isMarketOrder()) CpLanguageUtil.getString(context,"cp_overview_text53") else CpBigDecimalUtils.showSNormal(item.price, item.pricePrecision)
                )
                helper.setText(
                    R.id.tv_volume,
                    if (CpBigDecimalUtils.compareTo(
                            item.avgPrice,
                            "0"
                        ) == 0
                    ) "--" else item.avgPrice
                )
                helper.setText(
                    R.id.tv_dealvolume,
                    (if (coUnit == 0) item.dealVolume else CpBigDecimalUtils.mulStr(
                        item.dealVolume,
                        multiplier,
                        multiplierPrecision
                    )) + "(" + volumePercentStr + ")"
                )
                helper.setText(
                    R.id.tv_totalvolume,
                    if (coUnit == 0) item.volume else CpBigDecimalUtils.mulStr(
                        item.volume,
                        multiplier,
                        multiplierPrecision
                    )
                )
                helper.setText(
                    R.id.tv_dealvolume_key,
                    CpLanguageUtil.getString(context, "cp_extra_text8") + showDealUnit
                )
                helper.setText(
                    R.id.tv_totalvolume_key,
                    CpLanguageUtil.getString(context, "cp_order_text66") + showDealUnit
                )
                helper.setText(R.id.tv_only_reduce_position,CpLanguageUtil.getString(context,"cp_order_text54"))
                helper.setVisible(R.id.tv_only_reduce_position, openStr.equals("CLOSE"))
                if (item.otoOrder != null) {
                    val takerProfitTrigger = if (item.otoOrder.takerProfitTrigger.toString()
                            .equals("null")
                    ) "--" else item.otoOrder.takerProfitTrigger.toString()
                    val stopLossTrigger = if (item.otoOrder.stopLossTrigger.toString()
                            .equals("null")
                    ) "--" else item.otoOrder.stopLossTrigger.toString()
                    helper.setText(R.id.tv_deal, takerProfitTrigger + "/" + stopLossTrigger)
                }
//                val pbDealVolume = helper.getView<ProgressBar>(R.id.pb_deal_volume)
//                pbDealVolume.progress = volumePercentStr.replace("%", "").toInt()


                //Set Progress
                val mDealVolume = helper.getView<CircleProgressView>(R.id.mDeal_volume)
                val progressVal = volumePercentStr.replace("%", "").toInt()
                mDealVolume.setColor(CpColorUtil.getMainColorType(sideStr == "BUY"))
                mDealVolume.setProgress(progressVal)
                helper.setText(R.id.tv_quantity, "${showDealNumber}/${showEntrustNumber}")
                helper.setText(
                    R.id.tv_quantity_title,
                    CpLanguageUtil.getString(context, "cp_calculator_text10") + showDealUnit
                )
            }
            2 -> {
                helper.setText(R.id.tv_cancel, CpLanguageUtil.getString(context, "cp_order_text68"))
                helper.setText(
                    R.id.tv_price_title,
                    CpLanguageUtil.getString(context, "cp_overview_text29")
                )
                helper.setText(
                    R.id.tv_cp_overview_text30,
                    CpLanguageUtil.getString(context, "cp_overview_text30")
                )
                helper.setText(
                    R.id.tv_cp_order_text67,
                    CpLanguageUtil.getString(context, "cp_order_text67")
                )


                var orderTypeStr = when (item.triggerType) {
                    1 -> statusText8 //Stop Loss Order
                    2 -> statusText7 //Stop Profit Doc
                    3, 4 -> statusText9//Condition sheet
                    else -> "error"
                }
                helper.setText(R.id.tv_side, Html.fromHtml(typeStr))
                helper.setText(R.id.tv_coin_name, symbolName)
                helper.setText(
                    R.id.tv_date,
                    CpTimeFormatUtils.timeStampToDate(item.ctime.toLong(), "yyyy-MM-dd  HH:mm:ss")
                )
                helper.setText(R.id.tv_order_type, orderTypeStr)
                helper.setText(R.id.tv_trigger_price, item.triggerPrice)
                helper.setText(
                    R.id.tv_entrust_price,
                    if (item.timeInForce.equals("2")) CpLanguageUtil.getString(
                        context,
                        "cp_overview_text53"
                    ) else item.price
                )
//                helper.setText(R.id.tv_entrust_amount_value, if (coUnit == 0) item.volume else CpBigDecimalUtils.mulStr(item.volume, multiplier, multiplierPrecision))
//                helper.setText(R.id.tv_entrust_amount_key, CpLanguageUtil..getString(this,"cp_order_text66") + showDealUnit)

                if (openStr.equals("OPEN") && item.type.equals("2")) {
                    helper.setText(
                        R.id.tv_entrust_amount_key,
                        CpLanguageUtil.getString(
                            context,
                            "cp_extra_text9"
                        ) + "(" + (if (contractSide == 1) item.quote else item.base) + ")"
                    )
                    helper.setText(R.id.tv_entrust_amount_value, item.volume)
                } else {
                    helper.setText(
                        R.id.tv_entrust_amount_key,
                        CpLanguageUtil.getString(context, "cp_order_text66") + showDealUnit
                    )
                    helper.setText(
                        R.id.tv_entrust_amount_value,
                        if (coUnit == 0) item.volume else CpBigDecimalUtils.mulStr(
                            item.volume,
                            multiplier,
                            multiplierPrecision
                        )
                    )
                }

                helper.setText(
                    R.id.tv_expiration_date,
                    CpTimeFormatUtils.timeStampToDate(item.expireTime.toLong(), "MM-dd  HH:mm")
                )
                helper.setText(R.id.tv_only_reduce_position,CpLanguageUtil.getString(context,"cp_order_text54"))
                helper.setVisible(R.id.tv_only_reduce_position, openStr.equals("CLOSE"))
            }
            3 -> {
                helper.setText(
                    R.id.tv_price_title,
                    CpLanguageUtil.getString(context, "cp_overview_text6")
                )
                helper.setText(
                    R.id.tv_cp_order_text81,
                    CpLanguageUtil.getString(context, "cp_order_text81")
                )
                helper.setText(
                    R.id.tv_cp_order_text93,
                    CpLanguageUtil.getString(context, "cp_order_text93")
                )

                var orderStatus = when (item.status) {
                    "2" -> CpLanguageUtil.getString(context, "cp_extra_text1")//completeTransaction
                    "3" -> CpLanguageUtil.getString(
                        context,
                        "cp_status_text5"
                    )//"partialTransaction"
                    "4" -> CpLanguageUtil.getString(context, "cp_status_text2")//"rescinded"
                    "5" -> CpLanguageUtil.getString(
                        context,
                        "cp_status_text4"
                    )//"pendingCancellation"
                    "6" -> CpLanguageUtil.getString(context, "cp_status_text3")//"abnormalOrder"
                    else -> "error"
                }
                var mEntrustAmountValue = ""
                var mDealAmountValue = ""
                if (openStr.equals("OPEN") && item.type.equals("2")) {
                    helper.setText(
                        R.id.tv_entrust_amount_key,
                        (CpLanguageUtil.getString(context, "cp_order_text78") + if (coUnit == 0) "(" + CpLanguageUtil.getString(context,"cp_overview_text9") + ")" else "(" + multiplierCoin + ")")
                        + "/" + (CpLanguageUtil.getString(context, "cp_order_text102") + "(" + (marginCoin) + ")")
                    )
//                    helper.setText(R.id.tv_entrust_amount, item.volume)
                    mEntrustAmountValue = item.volume
                } else {
                    helper.setText(
                        R.id.tv_entrust_amount_key,
                        CpLanguageUtil.getString(context, "cp_order_text78") + showDealUnit
                    )
//                    helper.setText(R.id.tv_entrust_amount, if (coUnit == 0) item.volume else CpBigDecimalUtils.mulStr(item.volume, multiplier, multiplierPrecision))
                    mEntrustAmountValue =
                        if (coUnit == 0) item.volume else CpBigDecimalUtils.mulStr(
                            item.volume,
                            multiplier,
                            multiplierPrecision
                        )
                }
                mDealAmountValue = if (coUnit == 0) item.dealVolume else CpBigDecimalUtils.mulStr(
                    item.dealVolume,
                    multiplier,
                    multiplierPrecision
                )

                helper.setText(R.id.tv_side, Html.fromHtml(typeStr))
                helper.setText(R.id.tv_coin_name, symbolName)
                helper.setText(
                    R.id.tv_date,
                    CpTimeFormatUtils.timeStampToDate(item.ctime.toLong(), "yyyy-MM-dd  HH:mm:ss")
                )
                helper.setText(R.id.tv_order_type, orderType)

                val amountString = SpannableString("$mDealAmountValue / $mEntrustAmountValue")
                amountString.setSpan(
                    ForegroundColorSpan(
                        ContextCompat.getColor(
                            context,
                            R.color.text_color_2
                        )
                    ),
                    amountString.indexOf("/"),
                    amountString.length,
                    Spannable.SPAN_EXCLUSIVE_EXCLUSIVE
                )
                helper.setText(R.id.tv_amount, amountString)

                var prefix = if (CpBigDecimalUtils.compareTo(
                        item.realizedAmount,
                        "0"
                    ) == -1 || CpBigDecimalUtils.compareTo(item.realizedAmount, "0") == 0
                ) "" else "+"
                helper.setText(
                    R.id.tv_pl,
                    prefix + CpBigDecimalUtils.showSNormal(item.realizedAmount, marginCoinPrecision)
                )
                helper?.setTextColor(
                    R.id.tv_pl,
                    if (item.realizedAmount.contains("-")) CpColorUtil.getMainColorType(false,CpBigDecimalUtils.compareTo(item.realizedAmount, "0") == 0) else CpColorUtil.getMainColorType(
                        true,CpBigDecimalUtils.compareTo(item.realizedAmount, "0") == 0
                    )
                )
                helper.setText(
                    R.id.tv_pl_key,
                    CpLanguageUtil.getString(context, "cp_order_text8") + "(" + marginCoin + ")"
                )
                helper.setText(
                    R.id.tv_deal_price,
                    CpBigDecimalUtils.showSNormal(item.avgPrice, mSymbolPricePrecision)
                )
                helper.setText(
                    R.id.tv_deal_amount,
                    if (coUnit == 0) item.dealVolume else CpBigDecimalUtils.mulStr(
                        item.dealVolume,
                        multiplier,
                        multiplierPrecision
                    )
                )
                helper.setText(
                    R.id.tv_deal_amount_key,
                    CpLanguageUtil.getString(context, "cp_extra_text8") + showDealUnit
                )
                helper.setText(R.id.tv_status_go, orderStatus)
                val entrustPrice = if (item.isMarketOrder()) CpLanguageUtil.getString(
                    context,
                    "cp_overview_text53"
                ) else CpBigDecimalUtils.showSNormal(item.price, item.pricePrecision)
                val avgPrice = CpBigDecimalUtils.showSNormal(item.avgPrice, mSymbolPricePrecision)
                var priceString = SpannableString("$avgPrice / $entrustPrice")
                var tvOrderType = helper.getView<TextView>(R.id.tv_order_type);
                var tvLiquidation = helper.getView<TextView>(R.id.tv_liquidation);
                val nav_up = context.getResources().getDrawable(R.mipmap.public_hint)
                val isGone = null == item.source || (!item.source.equals("6") && !item.source.equals("7") && !item.source.equals("9") && !item.source.equals("10") && !item.source.equals("11"))
                nav_up.setBounds(
                    5,
                    0,
                    nav_up.minimumWidth + 5,
                    nav_up.minimumHeight
                )
                if ("11".equals(item.source)) {
                    tvLiquidation.setCompoundDrawables(null, null, nav_up, null);
                } else {
                    tvLiquidation.setCompoundDrawables(null, null, null, null);
                }



                helper.setText(R.id.tv_liquidation, sourceType)
                helper.setGone(R.id.tv_liquidation, isGone)

                if(item.source!=null && "6".equals(item.source)){
                    val takeOverPriceStr = CpBigDecimalUtils.showSNormal(item.takeOverPrice,mSymbolPricePrecision)
                    priceString = SpannableString("$takeOverPriceStr / $takeOverPriceStr")
                    val tvLiqTitle = helper.getView<TextView>(R.id.tv_liq_price_title)
                    val tvPriceTitle = helper.getView<TextView>(R.id.tv_price_title)
                    tvLiqTitle.text = CpLanguageUtil.getString(context,"cp_calculator_text20")
                    helper.setText(R.id.tv_liq_price,CpBigDecimalUtils.showSNormal(item.forcedPrice,mSymbolPricePrecision))
                    helper.setGone(R.id.ll_liq,false)
                    val iconLiq = context.getResources().getDrawable(R.mipmap.public_hint)
                    iconLiq.setBounds(
                        5,
                        0,
                        nav_up.minimumWidth + 5,
                        nav_up.minimumHeight
                    )

                    tvLiqTitle.setCompoundDrawables(null, null, iconLiq, null)

                    val iconLiq2 = context.getResources().getDrawable(R.mipmap.public_hint)
                    iconLiq2.setBounds(
                        5,
                        0,
                        nav_up.minimumWidth + 5,
                        nav_up.minimumHeight
                    )
                    tvPriceTitle.setCompoundDrawables(null, null, iconLiq2, null)

                }

                priceString.setSpan(
                    ForegroundColorSpan(
                        ContextCompat.getColor(
                            context,
                            R.color.text_color_2
                        )
                    ),
                    priceString.indexOf("/"),
                    priceString.length,
                    Spannable.SPAN_EXCLUSIVE_EXCLUSIVE
                )
                helper.setText(R.id.tv_price, priceString)

            }

            4 -> {
                helper.setText(
                    R.id.tv_price_title,
                    CpLanguageUtil.getString(context, "cp_order_text56")
                )
                helper.setText(
                    R.id.tv_cp_order_text67,
                    CpLanguageUtil.getString(context, "cp_order_text67")
                )
                helper.setText(
                    R.id.tv_cp_order_text70,
                    CpLanguageUtil.getString(context, "cp_order_text70")
                )
                var orderStatus = when (item.status) {
                    "0" -> contract_text_orderWaitInHandicap //"initial"
                    "1" -> statusText2//"expired"
                    "2" -> statusText3//"completed"
                    "3" -> statusText5//"triggerFailed"
                    "4" -> statusText6//"rescinded"
                    else -> "error"
                }
                var orderTypeNewStr = when (item.timeInForce) {
                    "1" -> CpLanguageUtil.getString(context, "cp_overview_text3")
                    "2" -> CpLanguageUtil.getString(context, "cp_overview_text4")
                    "3" -> "IOC"
                    "4" -> "FOK"
                    "5" -> "Post Only"
                    else -> "error"
                }
                helper.setText(R.id.tv_side, Html.fromHtml(typeStr))
                helper.setText(R.id.tv_coin_name, symbolName)
                helper.setText(
                    R.id.tv_date,
                    CpTimeFormatUtils.timeStampToDate(item.ctime.toLong(), "yyyy-MM-dd  HH:mm:ss")
                )
                helper.setText(R.id.tv_status, orderStatus)
                helper.setText(
                    R.id.tv_trigger_price,
                    CpBigDecimalUtils.showSNormal(item.triggerPrice, mSymbolPricePrecision)
                )
                helper.setText(
                    R.id.tv_entrust_price,
                    if (item.timeInForce.equals("2")) CpLanguageUtil.getString(
                        context,
                        "cp_overview_text53"
                    ) else CpBigDecimalUtils.showSNormal(item.price, mSymbolPricePrecision)
                )
                helper.setText(
                    R.id.tv_entrust_amount_value,
                    if (coUnit == 0) item.volume else CpBigDecimalUtils.mulStr(
                        item.volume,
                        multiplier,
                        multiplierPrecision
                    )
                )
//                helper.setText(R.id.tv_entrust_amount_key, CpLanguageUtil.getString(context,"cp_order_text66") + showDealUnit)
                helper.setText(
                    R.id.tv_expiration_date,
                    CpTimeFormatUtils.timeStampToDate(item.expireTime.toLong(), "MM-dd  HH:mm")
                )
                helper.setText(R.id.tv_only_reduce_position,CpLanguageUtil.getString(context,"cp_order_text54"))
                helper.setVisible(R.id.tv_only_reduce_position, openStr.equals("CLOSE"))
                helper.setText(R.id.tv_order_type, orderTypeNewStr)


                if (item.type.equals("2")) {
                    helper.setText(
                        R.id.tv_entrust_amount_key,
                        CpLanguageUtil.getString(
                            context,
                            "cp_extra_text9"
                        ) + "(" + (if (contractSide == 1) item.quote else item.base) + ")"
                    )
                } else {
                    helper.setText(
                        R.id.tv_entrust_amount_key,
                        CpLanguageUtil.getString(context, "cp_order_text66") + showDealUnit
                    )
                }
            }
        }

    }

    fun getTextByItemType(type: Int, label: String): String =
        if (type == 1) {
            CpLanguageUtil.getString(context, "${label}_trim")
        } else {
            CpLanguageUtil.getString(context, label)
        }


}
