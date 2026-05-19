package com.yjkj.chainup.new_contract.adapter

import android.content.Context
import com.chad.library.adapter.base.BaseQuickAdapter
import com.chad.library.adapter.base.module.LoadMoreModule
import com.chad.library.adapter.base.viewholder.BaseViewHolder
import com.chainup.contract.R
import com.chainup.contract.utils.CpBigDecimalUtils
import com.chainup.contract.utils.CpClLogicContractSetting
import com.chainup.contract.utils.CpColorUtil
import com.chainup.contract.utils.CpTimeFormatUtils
import com.yjkj.chainup.manager.CpLanguageUtil
import org.json.JSONObject


class CpContractHistoricalPositionAdapter(ctx: Context, data: ArrayList<JSONObject>) : BaseQuickAdapter<JSONObject, BaseViewHolder>(
    R.layout.cp_item_pl_record, data), LoadMoreModule {

    override fun convert(helper: BaseViewHolder, item: JSONObject) {
        helper?.run {

//            var mMarginCoinPrecision = CpClLogicContractSetting.getContractMarginCoinPrecisionById(context, item.optInt("contractId"))
            var mMarginCoinPrecision = item.optInt("marginCoinPrecision")
            var mSymbolPricePrecision = CpClLogicContractSetting.getContractSymbolPricePrecisionById(context, item.optInt("contractId"))
            var mMarginCoin = CpClLogicContractSetting.getContractMarginCoinById(context, item.optInt("contractId"))
            val mMultiplierPrecision = CpClLogicContractSetting.getContractMultiplierPrecisionById(context, item.optInt("contractId"))
            val mMultiplier = CpClLogicContractSetting.getContractMultiplierById(context, item.optInt("contractId"))
            val mMultiplierCoin = CpClLogicContractSetting.getContractMultiplierCoinPrecisionById(context, item.optInt("contractId"))
            val typeStr = if (item.optString("orderSide").equals("BUY")) {
               CpLanguageUtil.getString(context,"cp_order_text6")
            } else {
               CpLanguageUtil.getString(context,"cp_order_text15")
            }
            val typeColor = CpColorUtil.getMainColorType(item.optString("orderSide").equals("BUY"))

            //realizedProfitAndLoss
            setText(R.id.tv_settled_profit_loss_key,CpLanguageUtil.getString(context,"cp_order_text99")+"("+mMarginCoin+")")
            //averageOpeningPrice
            setText(R.id.tv_cp_order_text7,CpLanguageUtil.getString(context,"cp_order_text7")+"("+item.optString("quote")+")")

            setText(R.id.tv_side, typeStr)
            setTextColor(R.id.tv_side, typeColor)

            setText(R.id.tv_coin_name, item.optString("contractOtherName"))
            setText(R.id.tv_level_value, (if (item.optInt("positionType") == 1)CpLanguageUtil.getString(context,"cp_contract_setting_text1") else CpLanguageUtil.getString(context,"cp_contract_setting_text2")) + item.optString("leverageLevel") + "X")
            setText(R.id.tv_date, CpTimeFormatUtils.timeStampToDate(item.optString("mtime").toLong(), "yyyy-MM-dd  HH:mm:ss"))

//            val profitLossColor = if (CpBigDecimalUtils.compareTo(CpBigDecimalUtils.showSNormal(item.optString("historyRealizedAmount"), mMarginCoinPrecision), "0") == 1) {
//                R.color.main_green
//            } else {
//                R.color.main_red
//            }

            val positionVolume = if (CpClLogicContractSetting.getContractUint(context) == 0) CpBigDecimalUtils.showSNormal(item.optString("positionVolume"),0) else CpBigDecimalUtils.mulStr(item.optString("positionVolume"), mMultiplier, mMultiplierPrecision)

            val plVal = item.optString("profitRealizedAmount")
            val isUp = CpBigDecimalUtils.compareTo(plVal,"0") == 1//profitOrNot（>0）
            setTextColor(R.id.tv_pl_price, CpColorUtil.getMainColorType(isUp))
            //The server returns the profitRealizedAmount without the+sign and adds it by itself
            setText(R.id.tv_pl_price, (if(isUp) "+" else "") + CpBigDecimalUtils.showSNormal(plVal, mMarginCoinPrecision)) //realizedProfitAndLoss

            setText(R.id.tv_open_average_price, CpBigDecimalUtils.showSNormal(item.optString("openEndPrice"), mSymbolPricePrecision))//averageOpeningPrice
            setText(R.id.tv_position_amount, positionVolume)//numberOfPositions
            setText(R.id.tv_position_amount_key, if (CpClLogicContractSetting.getContractUint(context) == 0)CpLanguageUtil.getString(context,"cp_calculator_text38") + "("+CpLanguageUtil.getString(context,"cp_overview_text9")+")" else CpLanguageUtil.getString(context,"cp_calculator_text38") + "(" + mMultiplierCoin + ")" )
//            setText(R.id.tv_key1,CpLanguageUtil.getString(this,.string.cl_realized_profit_and_loss_str) + "(" + mMarginCoin + ")")
//            setText(R.id.tv_key2,CpLanguageUtil.getString(this,.string.cl_open_price_str) + "(" + mMarginCoin + ")")
//            setText(R.id.tv_key3,CpLanguageUtil.getString(this,.string.sl_str_avg_close_px)+ "(" + mMarginCoin + ")")
//            setText(R.id.tv_key4, if (CpClLogicContractSetting.getContractUint(context) == 0)CpLanguageUtil.getString(this,"cp_calculator_text38") + "("+context.CpLanguageUtil.getString(this,"cp_overview_text9")+")" elseCpLanguageUtil.getString(this,"cp_calculator_text38") + "(" + mMultiplierCoin + ")"+"）")
        }
    }
}
