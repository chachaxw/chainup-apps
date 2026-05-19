package com.yjkj.chainup.new_contract.adapter

import android.content.Context
import android.widget.TextView
import androidx.core.content.ContextCompat
import com.chad.library.adapter.base.BaseQuickAdapter
import com.chad.library.adapter.base.module.LoadMoreModule
import com.chad.library.adapter.base.viewholder.BaseViewHolder
import com.chainup.contract.R
import com.chainup.contract.utils.*
import com.chainup.contract.view.CpContractUpDownItemLayout
import com.chainup.kit.dialog.KKLoadingDialog
import com.yjkj.chainup.manager.CpLanguageUtil
import com.yjkj.chainup.new_contract.bean.CpCurrentOrderBean
import java.math.BigDecimal
import java.util.*

/**
 *Contract limit entrustment
 */
class CpContractPriceEntrustNewAdapter(ctx: Context, data: ArrayList<CpCurrentOrderBean>) : BaseQuickAdapter<CpCurrentOrderBean, BaseViewHolder>(
        R.layout.cp_item_contract_price_entrust_new, data), LoadMoreModule {

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
    var sl_str_trigger_price = ""
//    var sl_str_execution_price = ""
//    var sl_str_execution_volume = ""
    var cp_overview_text9 = ""
    var sl_str_market_price_simple = ""
//    var sl_str_deadline = ""
    var sl_str_trigger_time = ""
//    var sl_str_cancel_order = ""
//    var sl_str_order_complete = ""
//    var sl_str_user_canceled = ""
//    var sl_str_order_timeout = ""
//    var sl_str_trigger_failed = ""
    var cl_order_price_str = ""
    var cl_order_volume_str = ""
    var cl_open_value_str = ""
    var cl_average_price_str = ""
    var cp_overview_text3 = ""
    var cp_overview_text4 = ""
    var cl_reduce_only_str = ""
    var contract_text_orderWaitInHandicap = ""
    var statusText2 = ""
    var statusText3 = ""
    var statusText4 = ""
    var statusText5 = ""
    var statusText6 = ""
    var statusText7 = ""
    var statusText8 = ""
    var statusText9 = ""
    var sl_str_pl = ""
    var cl_expration_date_str = ""
    var transaction_text_dealNum = ""
    var mMultiplierCoin = ""
    var mPricePrecision = 0
    var mMultiplierPrecision = 0
    var mMultiplier = "0"
    var coUnit = 0

    init {

    }

    fun setIsCurrentEntrust(isCurrentEntrust: Boolean = true) {
        this.isCurrentEntrust = isCurrentEntrust
    }

    override fun convert(helper: BaseViewHolder, item: CpCurrentOrderBean) {
//        cp_ overview_ Text130=CpLanguageUtil. getString (this, "cp_overview_text13" 0)//Open Multiple
//        sl_ str_ sell_ Open0=CpLanguageUtil. getString (this,. string. sl_str_sell_open0)//Open empty
//        contract_ flat_ Short=CpLanguageUtil. getString (this,. string. contract_flat_short)//Flat
//        contract_ flat_ Long=CpLanguageUtil. getString (this,. string. contract_flat_long)//Pingduo
//        sl_ str_ latest_ price_ Simple=CpLanguageUtil. getString (this,. string. sl_str_latest_price_simple)//Latest price
//        sl_ str_ fair_ price_ Simple=CpLanguageUtil. getString (this,. string. sl_str_fair_price_simple)//Reasonable price
//        sl_ str_ index_ price_ Simple=CpLanguageUtil. getString (this,. string. sl_str_index_price_simple)//Index price
        sl_str_trigger_price = CpLanguageUtil.getString(context,"cp_overview_text29")//Trigger Price
//        sl_ str_ execution_ Price=CpLanguageUtil. getString (this,. string. sl_str_execution_price)//Execution price
//        sl_ str_ execution_ Volume=CpLanguageUtil. getString (this,. string. sl_str_execution_volume)//Number of executions
        cp_overview_text9 = CpLanguageUtil.getString(context,"cp_overview_text9")//Zhang
        sl_str_market_price_simple = CpLanguageUtil.getString(context,"cp_overview_text53")//Market price
//        sl_ str_ Deadline=CpLanguageUtil. getString (this,. string. sl_str_deadline)//Expiration time
        sl_str_trigger_time = CpLanguageUtil.getString(context,"cp_extra_text68")//Trigger time
//        sl_ str_ cancel_ Order=CpLanguageUtil. getString (this,. string. sl_str_cancel_order)//Undo
//        sl_ str_ order_ Complete=CpLanguageUtil. getString (this,. string. sl_str_order_complete)//Order completed
//        sl_ str_ user_ Canceled=CpLanguageUtil. getString (this,. string. sl_str_user_canceled)//User canceled
//        sl_ str_ order_ Timeout=CpLanguageUtil. getString (this,. string. sl_str_order_timeout)//Order expires
//        sl_ str_ trigger_ Failed=CpLanguageUtil. getString (this,. string. sl_str_trigger_failed)//Execution failed
        cl_order_price_str = CpLanguageUtil.getString(context,"cp_order_text56")//Commission price
        cl_order_volume_str = CpLanguageUtil.getString(context,"cp_order_text66")//Entrusted quantity
        cl_open_value_str = CpLanguageUtil.getString(context,"cp_overview_text28")//Opening value
        cl_average_price_str = CpLanguageUtil.getString(context,"cp_order_text58")//Average transaction price
        cp_overview_text3 = CpLanguageUtil.getString(context,"cp_overview_text3")//Price limit order
        cp_overview_text4 = CpLanguageUtil.getString(context,"cp_overview_text4")//Market Price List
        transaction_text_dealNum = CpLanguageUtil.getString(context,"cp_extra_text8")//Number of transactions
        cl_reduce_only_str = CpLanguageUtil.getString(context,"cp_order_text64")//Only reduce positions
        sl_str_pl = CpLanguageUtil.getString(context,"cp_order_text8")//Profit and loss
        cl_expration_date_str = CpLanguageUtil.getString(context,"cp_extra_text69")//Expiration time
        contract_text_orderWaitInHandicap = CpLanguageUtil.getString(context,"cp_extra_text70")//Initial Order
        statusText2 = CpLanguageUtil.getString(context,"cp_order_text95")//Expired
        statusText3 = CpLanguageUtil.getString(context,"cp_tip_text11")//"已完成"
        statusText4 = CpLanguageUtil.getString(context,"cp_tip_text12")//"触发失败"
        statusText5 = CpLanguageUtil.getString(context,"cp_extra_text71")//"执行失败"
        statusText6 = CpLanguageUtil.getString(context,"cp_status_text2")//"已撤销"
        statusText7 = CpLanguageUtil.getString(context,"cp_order_text63")//"止盈单"
        statusText8 = CpLanguageUtil.getString(context,"cp_order_text62")//"止损单"
        statusText9 = CpLanguageUtil.getString(context,"cp_order_text69")//"条件单"


        coUnit = CpClLogicContractSetting.getContractUint(context)

        //Guarantee currency
        val marginCoin = CpClLogicContractSetting.getContractMarginCoinById(context, item.contractId.toInt())
        val marginCoinPrecision = CpClLogicContractSetting.getContractMarginCoinPrecisionById(context, item.contractId.toInt())
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
        }

        if (!item.isPlan) {
////Normal
            helper.setGone(R.id.ll_plan, true)
            helper.setGone(R.id.ll_common, false)
            when (sideStr) {
                "BUY" -> {
                    helper?.setTextColor(R.id.tv_type_common, CpColorUtil.getMainColorType(true))
                }
                "SELL" -> {
                    helper?.setTextColor(R.id.tv_type_common, CpColorUtil.getMainColorType(false))
                }
                else -> {
                }
            }

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

            //0 initial, 1 new order, 2 complete transaction, 3 partial transaction, 4 canceled, 5 pending cancellation, 6 abnormal order
            var orderStatus = when (item.status) {
                "2" -> CpLanguageUtil.getString(context,"cp_status_text1")//Complete transaction
                "3" -> CpLanguageUtil.getString(context,"cp_order_text55")//"部分成交"
                "4" -> CpLanguageUtil.getString(context,"cp_status_text2")//"已撤销"
                "5" -> CpLanguageUtil.getString(context,"cp_status_text4")//"待撤销"
                "6" -> CpLanguageUtil.getString(context,"cp_status_text3")//"异常订单"
                else -> "error"
            }
            helper.setText(R.id.tv_type_common, typeStr)
            helper.setText(R.id.tv_contract_name_common, symbolName)
            helper.setText(R.id.tv_time_common, CpTimeFormatUtils.timeStampToDate(item.ctime.toLong(), "yyyy-MM-dd  HH:mm:ss"))
            if (item.type.equals("6")) {
                //Display "--" if forced position reduction
                helper.getView<CpContractUpDownItemLayout>(R.id.item_entrust_price_common).content = "--"
            } else {
                helper.getView<CpContractUpDownItemLayout>(R.id.item_entrust_price_common).content = if (item.type.equals("2")) sl_str_market_price_simple else CpBigDecimalUtils.showSNormal(item.price, item.pricePrecision)
            }
            helper.getView<CpContractUpDownItemLayout>(R.id.item_entrust_price_common).title = cl_order_price_str + "(" + item.quote + ")"
            val unitBuff = if (contractSide == 1) item.quote else item.base
            helper.getView<CpContractUpDownItemLayout>(R.id.item_entrust_volume_common).title = if (item.type.equals("2") && openStr.equals("OPEN")) cl_open_value_str + "(" + unitBuff + ")" else showEntrustUnit
            helper.getView<CpContractUpDownItemLayout>(R.id.item_entrust_volume_common).content = showEntrustNumber
            helper.setText(R.id.tv_only_reduce_position_common_key, if (isCurrentEntrust) cl_reduce_only_str else sl_str_pl + "(" + marginCoin + ")")
            val profitLossColor = if (CpBigDecimalUtils.compareTo(
                            CpBigDecimalUtils.showSNormal(item.realizedAmount, marginCoinPrecision), "0") == 1) {
                CpColorUtil.getMainColorType(true)
            } else {
                CpColorUtil.getMainColorType(false)
            }
            helper.setTextColor(R.id.tv_only_reduce_position_common_value, ContextCompat.getColor(context, if (isCurrentEntrust) R.color.text_color else profitLossColor))
            helper.setText(R.id.tv_only_reduce_position_common_value, if (isCurrentEntrust) only_reduce_position else CpBigDecimalUtils.showSNormal(item.realizedAmount, marginCoinPrecision))
//            helper.getView<ContractUpDownItemLayout>(R.id.item_only_reduce_position_common).contentTextColor = if (isCurrentEntrust) R.color.text_color else profitLossColor
//            helper.getView<ContractUpDownItemLayout>(R.id.item_only_reduce_position_common).content =if (isCurrentEntrust) only_reduce_position else BigDecimalUtils.showSNormal(item.realizedAmount, item.pricePrecision)
            if (item.type.equals("6")) {
                //Display "--" if forced position reduction
                helper.setVisible(R.id.img_liquidation_tip, true)
                helper.getView<CpContractUpDownItemLayout>(R.id.item_entrust_value_common).content = "--"
            } else {
                helper.setVisible(R.id.img_liquidation_tip, false)
                helper.getView<CpContractUpDownItemLayout>(R.id.item_entrust_value_common).content = if (CpBigDecimalUtils.compareTo(item.avgPrice, "0") == 0) "--" else CpBigDecimalUtils.showSNormal(item.avgPrice, item.pricePrecision)
            }
            helper.getView<CpContractUpDownItemLayout>(R.id.item_entrust_value_common).title = cl_average_price_str + "(" + item.quote + ")"
            helper.getView<CpContractUpDownItemLayout>(R.id.item_volume_value_common).content = showDealNumber
            helper.getView<CpContractUpDownItemLayout>(R.id.item_volume_value_common).title = showDealUnit
            helper.getView<TextView>(R.id.tv_item_order_type_common_value).text = orderType
            helper.setVisible(R.id.tv_cancel_common, isCurrentEntrust)
            helper.setVisible(R.id.ll_order_type_common, !isCurrentEntrust)
            helper.setVisible(R.id.tv_order_type_common, !isCurrentEntrust)
            helper.setVisible(R.id.img_more, !item.type.equals("6"))
            helper.setVisible(R.id.img_liquidation_tip, (item.type.equals("6") || item.type.equals("7")))
            helper.setText(R.id.tv_order_type_common, orderStatus)

            helper.setGone(R.id.ll_item_stop_profit_loss, item.otoOrder == null)
            if (item.otoOrder != null) {
                helper.getView<CpContractUpDownItemLayout>(R.id.item_stop_profit_trigger_price_value).content= if (item.otoOrder.takerProfitTrigger.toString().equals("null")) "--" else item.otoOrder.takerProfitTrigger.toString()
                helper.getView<CpContractUpDownItemLayout>(R.id.item_stop_loss_trigger_price_value).content=if (item.otoOrder.stopLossTrigger.toString().equals("null")) "--" else item.otoOrder.stopLossTrigger.toString()
            }
        } else {
            //Plan Delegation
            helper.setGone(R.id.ll_plan, false)
            helper.setGone(R.id.ll_common, true)
            when (sideStr) {
                "BUY" -> {
                    helper?.setTextColor(R.id.tv_type_plan, CpColorUtil.getMainColorType(true))
                }
                "SELL" -> {
                    helper?.setTextColor(R.id.tv_type_plan, CpColorUtil.getMainColorType(false))
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
            var orderStatus = when (item.status) {
                "0" -> contract_text_orderWaitInHandicap //"初始"
                "1" -> statusText2//"已过期"
                "2" -> statusText3//"已完成"
                "3" -> statusText5//"触发失败"
                "4" -> statusText6//"已撤销"
                else -> "error"
            }

            var orderTypeStr = when (item.triggerType) {
                1 -> statusText8 //Stop Loss Order
                2 -> statusText7 //Stop Profit Doc
                3, 4 -> statusText9//Condition sheet
                else -> "error"
            }

            helper?.run {
                setText(R.id.tv_order_type_plan, orderTypeStr)
                setText(R.id.tv_type_plan, typeStr)
                setText(R.id.tv_contract_name_plan, symbolName)
                setText(R.id.tv_time_plan, CpTimeFormatUtils.timeStampToDate(item.ctime.toLong(), "yyyy-MM-dd  HH:mm:ss"))
                setText(R.id.tv_hold_value_1_plan, CpBigDecimalUtils.showSNormal(item.triggerPrice, item.pricePrecision))
                setText(R.id.tv_trigger_price, sl_str_trigger_price + "(" + item.quote + ")")
                setText(R.id.tv_hold_value_2_plan, if (item.timeInForce.equals("2") && sideStr.equals("BUY")) sl_str_market_price_simple else CpBigDecimalUtils.showSNormal(item.price, item.pricePrecision))
                setText(R.id.tv_hold_2, cl_order_price_str + "(" + item.quote + ")")
                val unitBuff = if (contractSide == 1) item.quote else item.base
                setText(R.id.tv_hold_3_plan, if (item.timeInForce.equals("2") && openStr.equals("OPEN")) cl_open_value_str + "(" + unitBuff + ")" else showEntrustUnit)
                setText(R.id.tv_hold_value_3_plan, showEntrustNumber)
                setText(R.id.tv_hold_value_4_plan, only_reduce_position)
                setText(R.id.tv_hold_value_5_plan, orderType)
                setText(R.id.tv_hold_value_6_plan, CpTimeFormatUtils.timeStampToDate(item.mtime.toLong(), "MM-dd  HH:mm"))
                setText(R.id.tv_status_plan, orderStatus)
                setVisible(R.id.tv_status_plan, !item.status.equals("0") && !item.status.equals("1"))
                setVisible(R.id.tv_cancel_plan, isCurrentEntrust)
                setVisible(R.id.tv_status_plan, !isCurrentEntrust)
                setVisible(R.id.img_error_tips, item.status.equals("4"))

                if (isCurrentEntrust) {
                    //Display the expiration time if it is the current delegate
                    setText(R.id.tv_time, cl_expration_date_str)
                    setText(R.id.tv_hold_value_6_plan, CpTimeFormatUtils.timeStampToDate(item.expireTime.toLong(), "MM-dd  HH:mm"))
                } else {
                    //If it is a historical delegation, it is displayed as follows
                    //   "1" -> "已过期"   显示过期时间
                    //   "2" -> "已完成"   显示触发时间
                    //   "3" -> "触发失败"  显示过期时间
                    when (item.status) {
                        "1", "3" -> {
                            setText(R.id.tv_time, cl_expration_date_str)
                            setText(R.id.tv_hold_value_6_plan, CpTimeFormatUtils.timeStampToDate(item.expireTime.toLong(), "MM-dd  HH:mm"))
                        }
                        "2" -> {
                            setText(R.id.tv_time, sl_str_trigger_time)
                            setText(R.id.tv_hold_value_6_plan, CpTimeFormatUtils.timeStampToDate(item.mtime.toLong(), "MM-dd  HH:mm"))
                        }
                        else -> {
                            setText(R.id.tv_time, cl_expration_date_str)
                            setText(R.id.tv_hold_value_6_plan, CpTimeFormatUtils.timeStampToDate(item.expireTime.toLong(), "MM-dd  HH:mm"))

                        }
                    }

                }
            }
//
//
        }


    }

}
