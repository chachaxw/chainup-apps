package com.yjkj.chainup.new_contract.adapter

import android.content.Context
import android.text.Html
import android.widget.ProgressBar
import com.chad.library.adapter.base.BaseQuickAdapter
import com.chad.library.adapter.base.module.LoadMoreModule
import com.chad.library.adapter.base.viewholder.BaseViewHolder
import com.chainup.contract.R
import com.chainup.contract.utils.*
import com.chainup.contract.view.trade.CircleProgressView
import com.chainup.kit.dialog.KKLoadingDialog
import com.yjkj.chainup.manager.CpLanguageUtil
import com.yjkj.chainup.new_contract.bean.CpCurrentOrderBean
import java.math.BigDecimal
import java.text.DecimalFormat
import java.util.*

/**
 * Contract limit commission
 */
class CpContractCurrentEntrustNewAdapter(ctx: Context, data: ArrayList<CpCurrentOrderBean>) : BaseQuickAdapter<CpCurrentOrderBean, BaseViewHolder>(
        R.layout.cp_item_current_entrust, data), LoadMoreModule {

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
//    var contract_text_orderWaitInHandicap = ""
//    var statusText2 = ""
//    var statusText3 = ""
//    var statusText4 = ""
//    var statusText5 = ""
//    var statusText6 = ""
//    var statusText7 = ""
//    var statusText8 = ""
//    var statusText9 = ""
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
            helper.setText(R.id.tv_cancel,CpLanguageUtil.getString(context,"cp_order_text68"))
            helper.setText(R.id.tv_price_title,CpLanguageUtil.getString(context,"cp_overview_text6"))
            helper.setText(R.id.tv_volume_title,CpLanguageUtil.getString(context,"cp_order_text81"))
            helper.setText(R.id.tv_deal_title,CpLanguageUtil.getString(context,"cp_overview_text12"))

//        cp_ overview_ Text130=context. CpLanguageUtil. getString (this, "cp_overview_text13" 0)//Open Multiple
//        sl_ str_ sell_ Open0=context. CpLanguageUtil. getString (this,. string. sl_str_sell_open0)//Open empty
//        contract_ flat_ Short=context. CpLanguageUtil. getString (this,. string. contract_flat_short)//Flat
//        contract_ flat_ Long=context. CpLanguageUtil. getString (this,. string. contract_flat_long)//Pingduo
//        sl_ str_ latest_ price_ Simple=context. CpLanguageUtil. getString (this,. string. sl_str_latest_price_simple)//Latest price
//        sl_ str_ fair_ price_ Simple=context. CpLanguageUtil. getString (this,. string. sl_str_fair_price_simple)//Reasonable price
//        sl_ str_ index_ price_ Simple=context. CpLanguageUtil. getString (this,. string. sl_str_index_price_simple)//Index price
//        sl_ str_ trigger_ Price=context. CpLanguageUtil. getString (this,. string. sl_str_trigger_price)//Trigger price
//        sl_ str_ execution_ Price=context. CpLanguageUtil. getString (this,. string. sl_str_execution_price)//Execution price
//        sl_ str_ execution_ Volume=context. CpLanguageUtil. getString (this,. string. sl_str_execution_volume)//Number of executions
        cp_overview_text9 = CpLanguageUtil.getString(context,"cp_overview_text9")//Zhang
//        sl_ str_ market_ price_ Simple=context. CpLanguageUtil. getString (this,. string. sl_str_market_price_simple)//Market Price
//        sl_ str_ Deadline=context. CpLanguageUtil. getString (this,. string. sl_str_deadline)//Expiration time
//        sl_ str_ trigger_ Time=context. CpLanguageUtil. getString (this,. string. sl_str_trigger_time)//Trigger time
//        sl_ str_ cancel_ Order=context. CpLanguageUtil. getString (this,. string. sl_str_cancel_order)//Undo
//        sl_ str_ order_ Complete=context. CpLanguageUtil. getString (this,. string. sl_str_order_complete)//Order completed
//        sl_ str_ user_ Canceled=context. CpLanguageUtil. getString (this,. string. sl_str_user_canceled)//User canceled
//        sl_ str_ order_ Timeout=context. CpLanguageUtil. getString (this,. string. sl_str_order_timeout)//The order expires
//        sl_ str_ trigger_ Failed=context. CpLanguageUtil. getString (this,. string. sl_str_trigger_failed)//Execution failed
//        cl_ order_ price_ Str=context. CpLanguageUtil. getString (this,. string. cl_order_price_str)//Entrustment Price
        cl_order_volume_str =CpLanguageUtil.getString(context,"cp_order_text66")//Entrusted quantity
//        cl_ open_ value_ Str=context. CpLanguageUtil. getString (this,. string. cl_open_value_str)//Opening value
//        cl_ average_ price_ Str=context. CpLanguageUtil. getString (this,. string. cl_average_price_str)//Average transaction price
//        cp_ overview_ Text3=context. CpLanguageUtil. getString (this, "cp_overview_text3")//Price Limit List
//        cp_ overview_ Text4=context. CpLanguageUtil. getString (this, "cp_overview_text4")//Market Price List
        transaction_text_dealNum = CpLanguageUtil.getString(context,"cp_calculator_text10")//Number of transactions
//        cl_ reduce_ only_ Str=context. CpLanguageUtil. getString (this,. string. cl_reduce_only_str)//Only reduce positions
//        sl_ str_ Pl=context. CpLanguageUtil. getString (this,. string. sl_str_pl)//Profit and Loss
//        cl_ expration_ date_ Str=context. CpLanguageUtil. getString (this,. string. cl_expration_date_str)//Expiration time
//        contract_ text_ OrderWaitInHandicap=context. CpLanguageUtil. getString (this,. string. contract_text_orderWaitInHandicap)//Initial order
//StatusText2=context. CpLanguageUtil. getString (this,. string. cl_order_statitext2)//Expired
//StatusText3=context. CpLanguageUtil. getString (this,. string. cl_order_statitext3)//"Completed"
//StatusText4=context. CpLanguageUtil. getString (this,. string. cl_order_statitext4)//"Trigger failed"
//StatusText5=context. CpLanguageUtil. getString (this,. string. sl_str_trigger_failed)//"Execution failed"
//StatusText6=context. CpLanguageUtil. getString (this,. string. cl_cancelled_str)//"Revoked"
//StatusText7=context. CpLanguageUtil. getString (this,. string. cl_contract_add_text31)//"Stop Gain Doc"
//StatusText8=context. CpLanguageUtil. getString (this,. string. cl_contract_add_text32)//"Stop Loss Order"
//StatusText9=context. CpLanguageUtil. getString (this,. string. cl_contract_add_text33)//"Condition Sheet"


        coUnit = CpClLogicContractSetting.getContractUint(context)

        //Guarantee currency
        val marginCoin = CpClLogicContractSetting.getContractMarginCoinById(context, item.contractId.toInt())
        val marginCoinPrecision = CpClLogicContractSetting.getContractMarginCoinPrecisionById(context, item.contractId.toInt())
        val symbolPricePrecision = CpClLogicContractSetting.getContractSymbolPricePrecisionById(context,item.contractId.toInt())
        //Contract face value
        val multiplier = CpClLogicContractSetting.getContractMultiplierById(context, item.contractId.toInt())
        //Contract face value unit
        val multiplierCoin = CpClLogicContractSetting.getContractMultiplierCoinById(context, item.contractId.toInt())

        val multiplierBuff = BigDecimal(multiplier).stripTrailingZeros().toPlainString()

        //Contract Name
        var symbolName = CpClLogicContractSetting.getContractShowNameById(context, item.contractId.toInt())

        var contractSide = CpClLogicContractSetting.getContractSideById(context, item.contractId.toInt())

        //Nominal value accuracy
        val multiplierPrecision = if (multiplierBuff.contains(".")) {
            ChainUpLogUtil.e("------------", multiplierBuff)
            ChainUpLogUtil.e("------------", multiplierBuff.split(".".toRegex()).toTypedArray().size.toString() + "")
            val index = multiplierBuff.indexOf(".")
            if (index < 0) 0 else multiplierBuff.length - index - 1
        } else {
            multiplierBuff.length
        }
        var showDealNumber = ""
        var showEntrustNumber = ""
        //Delegated Quantity Display Unit
        var showEntrustUnit = ""
        if (coUnit == 0) {
            showEntrustUnit = cl_order_volume_str + "(" + cp_overview_text9 + ")"
        } else {
            showEntrustUnit = cl_order_volume_str + "(" + multiplierCoin + ")"
        }

        //Transaction Quantity Display Unit
        var showDealUnit = ""
        if (coUnit == 0) {
            showDealUnit = transaction_text_dealNum + "(" + cp_overview_text9 + ")"
        } else {
            showDealUnit = transaction_text_dealNum + "(" + multiplierCoin + ")"
        }
        if (coUnit == 0) {
            //Number of transactions
            showDealNumber = item.dealVolume
            //Entrusted quantity
            showEntrustNumber = item.volume
            showDealUnit = transaction_text_dealNum + "(" + cp_overview_text9 + ")"
        } else {
            //Number of transactions
            showDealNumber = CpBigDecimalUtils.mulStr(item.dealVolume, multiplier, multiplierPrecision)
            //Entrusted quantity
            showEntrustNumber = CpBigDecimalUtils.mulStr(item.volume, multiplier, multiplierPrecision)
            showDealUnit = transaction_text_dealNum + "(" + multiplierCoin + ")"
        }

        if (item.type.equals("2") && item.open.equals("OPEN")) {
            showEntrustNumber = item.volume
        }


        var openStr = item.open
        var sideStr = item.side
        var typeStr = ""
        var isOnlyReducePosition = false
        var only_reduce_position = CpLanguageUtil.getString(context,"cp_extra_text2")//"否"
        //context.getLineText("cp_overview_text13")
        if (openStr.equals("OPEN") && sideStr.equals("BUY")) {
            typeStr = CpLanguageUtil.getString(context,"cp_overview_text_13")//Purchase of Kaiduo
        } else if (openStr.equals("OPEN") && sideStr.equals("SELL")) {
            typeStr = CpLanguageUtil.getString(context,"cp_overview_text_14")//Selling short
        } else if (openStr.equals("CLOSE") && sideStr.equals("BUY")) {
            typeStr = CpLanguageUtil.getString(context,"cp_extra_text_4")//Buy flat
        } else if (openStr.equals("CLOSE") && sideStr.equals("SELL")) {
            typeStr = CpLanguageUtil.getString(context,"cp_extra_text_5")//Selling Pingduo
        }
        typeStr = typeStr.replace("\\n","<br/>").trim()
        if (openStr.equals("CLOSE")) {
            only_reduce_position = CpLanguageUtil.getString(context,"cp_extra_text3")//"是"
            isOnlyReducePosition = true
        }

        if (!item.isPlan) {

            //Limit Order, Market Order, IOC, FOK, Post Only
            var orderType = when (item.type) {
                "1" -> CpLanguageUtil.getString(context,"cp_overview_text3")//"限价单"
                "2" -> CpLanguageUtil.getString(context,"cp_overview_text4")//"市价单"
                "3" -> "IOC"
                "4" -> "FOK"
                "5" -> "Post Only"
                "6" -> CpLanguageUtil.getString(context,"cp_extra_text6")//Compulsory position reduction
                "7" -> CpLanguageUtil.getString(context,"cp_extra_text7")//Position Consolidation
                else -> "error"
            }

////Normal
//            helper.setGone(R.id.ll_plan, true)
//            helper.setGone(R.id.ll_common, false)
            when (sideStr) {
                "BUY" -> {
                    helper?.setTextColor(R.id.tv_side, CpColorUtil.getMainColorType(true))
                }
                "SELL" -> {
                    helper?.setTextColor(R.id.tv_side,CpColorUtil.getMainColorType(false))
                }
                else -> {
                }
            }
            var volumePercentBig = CpBigDecimalUtils.div(item.dealVolume, item.volume, 2)
            var volumePercentStr = DecimalFormat("0%").format(volumePercentBig)
            helper.setText(R.id.tv_side, Html.fromHtml(typeStr))
            helper.setText(R.id.tv_coin_name, symbolName)
            helper.setText(R.id.tv_date, CpTimeFormatUtils.timeStampToDate(item.ctime.toLong(), "yyyy-MM-dd  HH:mm:ss"))
            helper.setText(R.id.tv_order_type, orderType)
            helper.setText(R.id.tv_price, if(item.isMarketOrder()) CpLanguageUtil.getString(context,"cp_overview_text53") else CpBigDecimalUtils.showSNormal(item.price,symbolPricePrecision))
            helper.setText(R.id.tv_volume, if (CpBigDecimalUtils.compareTo(item.avgPrice,"0")==0) "--" else item.avgPrice)
//            helper.setText(R.id.tv_dealvolume, item.dealVolume + "(" + volumePercentStr + ")")
//            helper.setText(R.id.tv_totalvolume, item.volume)
            helper.setText(R.id.tv_only_reduce_position,CpLanguageUtil.getString(context,"cp_order_text54"))
            helper.setVisible(R.id.tv_only_reduce_position, openStr.equals("CLOSE"))
            if (item.otoOrder != null) {
                val takerProfitTrigger = if (item.otoOrder.takerProfitTrigger.toString().equals("null")) "--" else item.otoOrder.takerProfitTrigger.toString()
                val stopLossTrigger = if (item.otoOrder.stopLossTrigger.toString().equals("null")) "--" else item.otoOrder.stopLossTrigger.toString()
                helper.setText(R.id.tv_deal, takerProfitTrigger + "/" + stopLossTrigger)
            }else{
                helper.setText(R.id.tv_deal, "--/--")
            }

            //Set Progress
            val mDealVolume = helper.getView<CircleProgressView>(R.id.mDeal_volume)
            val progressVal = volumePercentStr.replace("%", "").toInt()
            mDealVolume.setColor(CpColorUtil.getMainColorType(sideStr=="BUY"))
            mDealVolume.setProgress(progressVal)

            helper.setText(R.id.tv_quantity_title,showDealUnit)
            helper.setText(R.id.tv_quantity,"${showDealNumber}/${showEntrustNumber}")
        }
    }

}
