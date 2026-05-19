package com.yjkj.chainup.new_contract.adapter

import android.content.Context
import android.widget.TextView
import androidx.core.content.ContextCompat
import com.chad.library.adapter.base.BaseQuickAdapter
import com.chad.library.adapter.base.module.LoadMoreModule
import com.chad.library.adapter.base.viewholder.BaseViewHolder
import com.chainup.contract.R
import com.chainup.contract.utils.*
import com.chainup.kit.dialog.KKLoadingDialog
import com.yjkj.chainup.manager.CpLanguageUtil
import com.yjkj.chainup.new_contract.bean.CpCurrentOrderBean
import java.math.BigDecimal
import java.util.*

/**
 * contractLimitCommission
 */
class CpContractPlanEntrustNewAdapter(ctx: Context, data: ArrayList<CpCurrentOrderBean>) : BaseQuickAdapter<CpCurrentOrderBean, BaseViewHolder>(
        R.layout.cp_item_plan_entrust, data), LoadMoreModule {

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
    var cp_overview_text3 = ""
    var cp_overview_text4 = ""
//    var cl_reduce_only_str = ""
//    var contract_text_orderWaitInHandicap = ""
//    var statusText2 = ""
//    var statusText3 = ""
//    var statusText4 = ""
//    var statusText5 = ""
//    var statusText6 = ""
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
        helper.setText(R.id.tv_cancel,CpLanguageUtil.getString(context,"cp_order_text68"))
        helper.setText(R.id.tv_price_title,CpLanguageUtil.getString(context,"cp_overview_text29"))
        helper.setText(R.id.tv_cp_overview_text30,CpLanguageUtil.getString(context,"cp_overview_text30"))
        helper.setText(R.id.tv_cp_order_text67,CpLanguageUtil.getString(context,"cp_order_text67"))
//        cp_ overview_ Text130=CpLanguageUtil. getString (this, "cp_overview_text13" 0)//Open Multiple
//        sl_ str_ sell_ Open0=CpLanguageUtil. getString (this,. string. sl_str_sell_open0)//Open empty
//        contract_ flat_ Short=CpLanguageUtil. getString (this,. string. contract_flat_short)//Flat
//        contract_ flat_ Long=CpLanguageUtil. getString (this,. string. contract_flat_long)//Pingduo
//        sl_ str_ latest_ price_ Simple=CpLanguageUtil. getString (this,. string. sl_str_latest_price_simple)//Latest price
//        sl_ str_ fair_ price_ Simple=CpLanguageUtil. getString (this,. string. sl_str_fair_price_simple)//Reasonable price
//        sl_ str_ index_ price_ Simple=CpLanguageUtil. getString (this,. string. sl_str_index_price_simple)//Index price
//        sl_ str_ trigger_ Price=CpLanguageUtil. getString (this,. string. sl_str_trigger_price)//Trigger price
//        sl_ str_ execution_ Price=CpLanguageUtil. getString (this,. string. sl_str_execution_price)//Execution price
//        sl_ str_ execution_ Volume=CpLanguageUtil. getString (this,. string. sl_str_execution_volume)//Number of executions
        cp_overview_text9 = CpLanguageUtil.getString(context,"cp_overview_text9")//Zhang
//        sl_ str_ market_ price_ Simple=CpLanguageUtil. getString (this,. string. sl_str_market_price_simple)//Market Price
//        sl_ str_ Deadline=CpLanguageUtil. getString (this,. string. sl_str_deadline)//Expiration time
//        sl_ str_ trigger_ Time=CpLanguageUtil. getString (this,. string. sl_str_trigger_time)//Trigger time
//        sl_ str_ cancel_ Order=CpLanguageUtil. getString (this,. string. sl_str_cancel_order)//Undo
//        sl_ str_ order_ Complete=CpLanguageUtil. getString (this,. string. sl_str_order_complete)//Order completed
//        sl_ str_ user_ Canceled=CpLanguageUtil. getString (this,. string. sl_str_user_canceled)//User canceled
//        sl_ str_ order_ Timeout=CpLanguageUtil. getString (this,. string. sl_str_order_timeout)//Order expires
//        sl_ str_ trigger_ Failed=CpLanguageUtil. getString (this,. string. sl_str_trigger_failed)//Execution failed
//        cl_ order_ price_ Str=CpLanguageUtil. getString (this,. string. cl_order_price_str)//Entrustment Price
        cl_order_volume_str = CpLanguageUtil.getString(context,"cp_order_text66")//Entrusted quantity
//        cl_ open_ value_ Str=CpLanguageUtil. getString (this,. string. cl_open_value_str)//Opening value
//        cl_ average_ price_ Str=CpLanguageUtil. getString (this,. string. cl_average_price_str)//Average transaction price
        cp_overview_text3 = CpLanguageUtil.getString(context,"cp_overview_text3")//Price limit order
        cp_overview_text4 = CpLanguageUtil.getString(context,"cp_overview_text4")//Market Price List
        transaction_text_dealNum = CpLanguageUtil.getString(context,"cp_order_text66")//Number of transactions
//        cl_ reduce_ only_ Str=CpLanguageUtil. getString (this,. string. cl_reduce_only_str)//Only reduce positions
//        sl_ str_ Pl=CpLanguageUtil. getString (this,. string. sl_str_pl)//Profit and Loss
//        cl_ expration_ date_ Str=CpLanguageUtil. getString (this,. string. cl_expration_date_str)//Expiration time
//        contract_ text_ OrderWaitInHandicap=CpLanguageUtil. getString (this,. string. contract_text_orderWaitInHandicap)//Initial order
//StatusText2=CpLanguageUtil. getString (this,. string. cl_order_statitext2)//Expired
//StatusText3=CpLanguageUtil. getString (this,. string. cl_order_statitext3)//"Completed"
//StatusText4=CpLanguageUtil. getString (this,. string. cl_order_statitext4)//"Trigger failed"
//StatusText5=CpLanguageUtil. getString (this,. string. sl_str_trigger_failed)//"Execution failed"
//StatusText6=CpLanguageUtil. getString (this,. string. cl_cancelled_str)//"Revoked"
        statusText7 =CpLanguageUtil.getString(context,"cp_order_text63")//"止盈单"
        statusText8 =CpLanguageUtil.getString(context,"cp_order_text62")//"止损单"
        statusText9 =CpLanguageUtil.getString(context,"cp_overview_text5")//"条件单"


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
            typeStr = CpLanguageUtil.getString(context,"cp_overview_text13")//Purchase of Kaiduo
        } else if (openStr.equals("OPEN") && sideStr.equals("SELL")) {
            typeStr = CpLanguageUtil.getString(context,"cp_overview_text14")//Selling open space
        } else if (openStr.equals("CLOSE") && sideStr.equals("BUY")) {
            typeStr = CpLanguageUtil.getString(context,"cp_extra_text4")//Purchase of Ping Kong
        } else if (openStr.equals("CLOSE") && sideStr.equals("SELL")) {
            typeStr = CpLanguageUtil.getString(context,"cp_extra_text5")//Sales of Pingduo
        }
        if (openStr.equals("CLOSE")) {
            only_reduce_position = CpLanguageUtil.getString(context,"cp_extra_text3")//"是"
            isOnlyReducePosition = true
        }

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

        if (openStr.equals("CLOSE")) {
            only_reduce_position = CpLanguageUtil.getString(context,"cp_extra_text3")
        }
        var orderType = when (item.timeInForce) {
            "1" -> cp_overview_text3
            "2" -> cp_overview_text4
            "3" -> "IOC"
            "4" -> "FOK"
            "5" -> "Post Only"
            else -> "error"
        }
        //0 initial, 1 expired, 2 completed, 3 failed to trigger, 4 canceled
//        var orderStatus = when (item.status) {
//            "0" -> contract_text_orderWaitInHandicap //"初始"
//            "1" -> statusText2//"已过期"
//            "2" -> statusText3//"已完成"
//            "3" -> statusText5//"触发失败"
//            "4" -> statusText6//"已撤销"
//            else -> "error"
//        }

        var orderTypeStr = when (item.triggerType) {
            1 -> statusText8 //Stop Loss Order
            2 -> statusText7 //Stop Profit Doc
            3, 4 -> statusText9//Condition sheet
            else -> "error"
        }

        var orderTypeNewStr = when (item.timeInForce) {
            "1" -> CpLanguageUtil.getString(context,"cp_overview_text3")//"限价单"
            "2" -> CpLanguageUtil.getString(context,"cp_overview_text4")//"市价单"
            "3" -> "IOC"
            "4" -> "FOK"
            "5" -> "Post Only"
            else -> "error"
        }

        helper.setGone(R.id.tv_only_reduce_position,!"CLOSE".equals(openStr))

        helper.setText(R.id.tv_side, typeStr)
        helper.setText(R.id.tv_coin_name, symbolName)
        helper.setText(R.id.tv_date, CpTimeFormatUtils.timeStampToDate(item.ctime.toLong(), "yyyy-MM-dd  HH:mm:ss"))
        helper.setText(R.id.tv_order_type, orderTypeStr)
        helper.setText(R.id.tv_trigger_price, CpBigDecimalUtils.showSNormal(item.triggerPrice,symbolPricePrecision))
        helper.setText(R.id.tv_entrust_price, if (item.timeInForce.equals("2")) CpLanguageUtil.getString(context,"cp_overview_text53") else CpBigDecimalUtils.showSNormal(item.price,symbolPricePrecision))
//        helper.setText(R.id.tv_entrust_amount_value, if (coUnit == 0) item.volume else CpBigDecimalUtils.mulStr(item.volume, multiplier, multiplierPrecision))
        helper.setText(R.id.tv_expiration_date, CpTimeFormatUtils.timeStampToDate(item.expireTime.toLong(), "MM-dd  HH:mm"))
        helper.setText(R.id.tv_only_reduce_position, CpLanguageUtil.getString(context,"cp_order_text54"))
//        helper.setText(R.id.tv_entrust_amount_key, showEntrustUnit)

        if (openStr.equals("OPEN") && item.type.equals("2")) {
            helper.setText(R.id.tv_entrust_amount_key, CpLanguageUtil.getString(context,"cp_extra_text9") + "(" + (if (contractSide == 1) item.quote else item.base) + ")")
            helper.setText(R.id.tv_entrust_amount_value, item.volume)
        } else {
            helper.setText(R.id.tv_entrust_amount_key,  showDealUnit)
            helper.setText(R.id.tv_entrust_amount_value, if (coUnit == 0) item.volume else CpBigDecimalUtils.mulStr(item.volume, multiplier, multiplierPrecision))
        }

    }

}
