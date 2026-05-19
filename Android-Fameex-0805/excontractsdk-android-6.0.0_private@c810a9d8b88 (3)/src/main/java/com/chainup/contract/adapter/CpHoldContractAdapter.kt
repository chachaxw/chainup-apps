package com.yjkj.chainup.new_contract.adapter

import com.chad.library.adapter.base.BaseQuickAdapter
import com.chad.library.adapter.base.viewholder.BaseViewHolder
import com.chainup.contract.R
import com.chainup.contract.utils.*
import com.yjkj.chainup.manager.CpLanguageUtil
import com.yjkj.chainup.new_contract.bean.CpContractPositionBean

class CpHoldContractAdapter(data: ArrayList<CpContractPositionBean>) : BaseQuickAdapter<CpContractPositionBean, BaseViewHolder>(
    R.layout.cp_item_hold_contract, data) {


    override fun convert(helper: BaseViewHolder, item: CpContractPositionBean) {
        val mPricePrecision = CpClLogicContractSetting.getContractSymbolPricePrecisionById(context, item.contractId)

        val mMarginCoinPrecision = CpClLogicContractSetting.getContractMarginCoinPrecisionById(context, item.contractId)

        val mMultiplierCoin = CpClLogicContractSetting.getContractMultiplierCoinPrecisionById(context, item.contractId)

        val mMultiplierPrecision = CpClLogicContractSetting.getContractMultiplierPrecisionById(context, item.contractId)

        val mMultiplier = CpClLogicContractSetting.getContractMultiplierById(context, item.contractId)
        helper?.run {

            when (item.orderSide) {
                "BUY" -> {
                    setText(R.id.tv_type, CpLanguageUtil.getString(context,"cp_order_text6"))
                    setTextColor(R.id.tv_type, CpColorUtil.getMainColorType(true))
                    setTextColor(R.id.tv_profit_loss_value, CpColorUtil.getMainColorType(true))
                    setTextColor(R.id.tv_floating_gains_value, CpColorUtil.getMainColorType(true))
                }
                "SELL" -> {
                    setText(R.id.tv_type, CpLanguageUtil.getString(context,"cp_order_text15"))
                    setTextColor(R.id.tv_type, CpColorUtil.getMainColorType(false))
                    setTextColor(R.id.tv_profit_loss_value, CpColorUtil.getMainColorType(false))
                    setTextColor(R.id.tv_floating_gains_value, CpColorUtil.getMainColorType(false))
                }
                else -> {
                }
            }
            if (CpBigDecimalUtils.compareTo(
                    CpBigDecimalUtils.showSNormal(item.openRealizedAmount, mMarginCoinPrecision),"0")==1){
                setTextColor(R.id.tv_profit_loss_value, CpColorUtil.getMainColorType(true))
                setTextColor(R.id.tv_floating_gains_value, CpColorUtil.getMainColorType(true))
            }else{
                setTextColor(R.id.tv_profit_loss_value, CpColorUtil.getMainColorType(false))
                setTextColor(R.id.tv_floating_gains_value, CpColorUtil.getMainColorType(false))
            }

            //There is only adjustment margin for each position, and there is no adjustment margin for the entire position
            when (item.positionType) {
                1 -> {
                    setGone(R.id.tv_adjust_margins, true)
                    setText(R.id.tv_open_type, CpLanguageUtil.getString(context,"cp_contract_setting_text1")+" "+item.leverageLevel.toString() + "X")
                }
                2 -> {
                    setGone(R.id.tv_adjust_margins, false)
                    setText(R.id.tv_open_type, CpLanguageUtil.getString(context,"cp_contract_setting_text2")+" "+item.leverageLevel.toString() + "X")
                }
                else -> {
                }
            }
            var symbolName = CpClLogicContractSetting.getContractShowNameById(context, item.contractId)
            setText(R.id.tv_contract_name, symbolName)
            //Average opening price
            setText(R.id.tv_open_price_value, CpBigDecimalUtils.showSNormal(item.openAvgPrice, mPricePrecision))
            //Profit and loss
            setText(R.id.tv_profit_loss_value, CpBigDecimalUtils.showSNormal(item.openRealizedAmount, mMarginCoinPrecision))
            //Profit/Loss Key
            setText(R.id.tv_floating_gains_balance_key, CpLanguageUtil.getString(context,"cp_order_text8") + "(" + CpClLogicContractSetting.getContractMarginCoinById(context, item.contractId) + ")")
            //Estimated strong parity
            if (CpBigDecimalUtils.compareTo(item.reducePrice, "0") == 1) {
                setText(R.id.tv_forced_close_price_value, CpBigDecimalUtils.showSNormal(item.reducePrice, mPricePrecision))
            } else {
                setText(R.id.tv_forced_close_price_value, "--")
            }
            //Rate of return
            setText(R.id.tv_floating_gains_value, CpNumberUtil().getDecimal(2).format(
                CpMathHelper.round(CpMathHelper.mul(item.returnRate, "100"), 2)).toString() + "%")
            //Total position
            setText(R.id.tv_total_position_value, if (CpClLogicContractSetting.getContractUint(context) == 0) item.positionVolume else CpBigDecimalUtils.mulStr(item.positionVolume,mMultiplier, mMultiplierPrecision))
            //Total Position Key
            setText(R.id.tv_total_position_key, if (CpClLogicContractSetting.getContractUint(context) == 0) CpLanguageUtil.getString(context,"cp_order_text11") + "("+CpLanguageUtil.getString(context,"cp_overview_text9")+")" else CpLanguageUtil.getString(context,"cp_order_text11") + "(" + mMultiplierCoin + ")")
            //Security deposit
            setText(R.id.tv_margins_value, CpBigDecimalUtils.showSNormal(item.holdAmount, CpClLogicContractSetting.getContractMarginCoinPrecisionById(context, item.contractId)))
            //Deposit Key
            setText(R.id.tv_margins_key, CpLanguageUtil.getString(context,"cp_order_text12") + "(" + CpClLogicContractSetting.getContractMarginCoinById(context, item.contractId) + ")")
            //Keping
            setText(R.id.tv_gains_balance_value, if (CpClLogicContractSetting.getContractUint(context) == 0) item.canCloseVolume else CpBigDecimalUtils.mulStr(item.canCloseVolume, mMultiplier, mMultiplierPrecision))
            //Keyable
            setText(R.id.tv_gains_balance_key, if (CpClLogicContractSetting.getContractUint(context) == 0) CpLanguageUtil.getString(context,"cp_order_text35") + "("+CpLanguageUtil.getString(context,"cp_overview_text9")+")" else CpLanguageUtil.getString(context,"cp_order_text35") + "(" + mMultiplierCoin + ")")
            //Margin ratio
            setText(R.id.tv_tag_price_value, CpNumberUtil().getDecimal(2).format(
                CpMathHelper.round(
                    CpMathHelper.mul(item.marginRate, "100"), 2)).toString() + "%")
            //Tag Price
            setText(R.id.tv_holdings_value, CpBigDecimalUtils.showSNormal(item.indexPrice, mPricePrecision))
            //Lever
            setText(R.id.tv_amount_can_be_liquidated_value, item.leverageLevel.toString() + "X")
            //Settled profit and loss
            setText(R.id.tv_settled_profit_loss_value, CpBigDecimalUtils.showSNormal(item.profitRealizedAmount, mMarginCoinPrecision))

            if (CpBigDecimalUtils.compareTo(
                    CpBigDecimalUtils.showSNormal(item.profitRealizedAmount, mMarginCoinPrecision),"0")==1){
                setTextColor(R.id.tv_settled_profit_loss_value, CpColorUtil.getMainColorType(true))
            }else{
                setTextColor(R.id.tv_settled_profit_loss_value, CpColorUtil.getMainColorType(false))
            }
        }
    }
}
