package com.yjkj.chainup.new_contract.adapter

import android.view.Gravity
import android.view.View
import android.view.ViewGroup
import android.widget.LinearLayout
import androidx.core.content.ContextCompat
import com.chad.library.adapter.base.BaseQuickAdapter
import com.chad.library.adapter.base.viewholder.BaseViewHolder
import com.chainup.contract.R
import com.chainup.contract.utils.*
import com.chainup.kit.utils.PublicSizeUtil
import com.yjkj.chainup.manager.CpLanguageUtil
import com.yjkj.chainup.new_contract.bean.CpContractPositionBean
import org.jetbrains.anko.backgroundColor

class CpHoldContractNewAdapter(data: ArrayList<CpContractPositionBean>) : BaseQuickAdapter<CpContractPositionBean, BaseViewHolder>(
    R.layout.cp_item_position, data) {

    private var tvOnekeyClose: View? = null
    private val adlLight = arrayOf(
        R.color.rise_1,
        R.color.rise_1,
        R.color.line_4,
        R.color.fall_1,
        R.color.fall_1
    )
    fun setViewVisible(view: View){
        tvOnekeyClose = view
    }

    override fun convert(helper: BaseViewHolder, item: CpContractPositionBean) {
        setLight(helper.getView(R.id.ll_adl),item.adlLevel-1)
        val mPricePrecision = CpClLogicContractSetting.getContractSymbolPricePrecisionById(context, item.contractId)

        val mMarginCoinPrecision = CpClLogicContractSetting.getContractMarginCoinPrecisionById(context, item.contractId)

        val mMultiplierCoin = CpClLogicContractSetting.getContractMultiplierCoinPrecisionById(context, item.contractId)

        val mMultiplierPrecision = CpClLogicContractSetting.getContractMultiplierPrecisionById(context, item.contractId)

        val mMultiplier = CpClLogicContractSetting.getContractMultiplierById(context, item.contractId)
        helper?.run {

            setText(R.id.tv_deal_title,CpLanguageUtil.getString(context, "cp_order_text10"))
            setText(R.id.tv_cp_order_text100,CpLanguageUtil.getString(context, "cp_order_text100"))
            setText(R.id.tv_forced_close_price_key,CpLanguageUtil.getString(context, "cp_order_text9"))
            setText(R.id.tv_cp_overview_text20,CpLanguageUtil.getString(context, "cp_overview_text20"))
//            setText(R.id.tv_settled_profit_loss_key,CpLanguageUtil.getString(context, "cp_order_text14"))
            setText(R.id.tv_tag_price,CpLanguageUtil.getString(context, "cp_extra_text135"))
            setText(R.id.tv_adjust_margins,CpLanguageUtil.getString(context, "cp_order_text16"))
            setText(R.id.tv_profit_loss,CpLanguageUtil.getString(context, "cp_order_text29"))
            setText(R.id.tv_close_position,CpLanguageUtil.getString(context, "cp_order_text40"))
            setText(R.id.tv_quick_close_position,CpLanguageUtil.getString(context, "cp_order_text18"))

            when (item.orderSide) {
                "BUY" -> {
                    setText(R.id.tv_type, CpLanguageUtil.getString(context,"cp_order_text6"))

                }
                "SELL" -> {
                    setText(R.id.tv_type, CpLanguageUtil.getString(context,"cp_order_text15"))
                }
                else -> {
                }
            }
            setTextColor(R.id.tv_type, CpColorUtil.getMainColorType(item.orderSide == "BUY"))
            setTextColor(R.id.tv_profit_loss_value, CpColorUtil.getMainColorType(item.orderSide == "BUY"))
            setTextColor(R.id.tv_floating_gains_value, CpColorUtil.getMainColorType(item.orderSide == "BUY"))

            val isRise = CpBigDecimalUtils.compareTo(CpBigDecimalUtils.showSNormal(item.openRealizedAmount, mMarginCoinPrecision),"0") >= 0
            val isZero = CpBigDecimalUtils.compareTo(CpBigDecimalUtils.showSNormal(item.openRealizedAmount, mMarginCoinPrecision),"0") == 0
            setTextColor(R.id.tv_profit_loss_value, CpColorUtil.getMainColorType(isRise,isZero))
            setTextColor(R.id.tv_floating_gains_value, CpColorUtil.getMainColorType(isRise,isZero))


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
            var prefix = if(isRise) "+" else ""
            prefix = if(isZero) "" else prefix
            setText(R.id.tv_profit_loss_value, prefix + CpBigDecimalUtils.showSNormal(item.openRealizedAmount, mMarginCoinPrecision))
            //Profit/Loss Key
            setText(R.id.tv_floating_gains_balance_key, CpLanguageUtil.getString(context,"cp_roi_6") + "(" + CpClLogicContractSetting.getContractMarginCoinById(context, item.contractId) + ")")
            //Estimated strong parity
            if (CpBigDecimalUtils.compareTo(item.reducePrice, "0") == 1) {
                setText(R.id.tv_forced_close_price_value, CpBigDecimalUtils.showSNormal(item.reducePrice, mPricePrecision))
            } else {
                setText(R.id.tv_forced_close_price_value, "--")
            }
            //Rate of return
            val returnRateValue = CpNumberUtil().getDecimal(2).format(CpMathHelper.round(CpMathHelper.mul(item.returnRate, "100"), 2)).toString()
            setText(R.id.tv_floating_gains_value, CpBigDecimalUtils.formatNumberWithLogo(returnRateValue) + "%")
            //Total position
            setText(R.id.tv_total_position_value, if (CpClLogicContractSetting.getContractUint(context) == 0) item.positionVolume else CpBigDecimalUtils.mulStr(item.positionVolume,mMultiplier, mMultiplierPrecision))
            //Total Position Key
            setText(R.id.tv_total_position_key, if (CpClLogicContractSetting.getContractUint(context) == 0) CpLanguageUtil.getString(context,"cp_order_text11") + "("+CpLanguageUtil.getString(context,"cp_overview_text9")+")" else CpLanguageUtil.getString(context,"cp_order_text11") + "(" + mMultiplierCoin + ")")
            //Security deposit
            setText(R.id.tv_margins_value, CpBigDecimalUtils.showSNormal(item.holdAmount, CpClLogicContractSetting.getContractMarginCoinPrecisionById(context, item.contractId)))
            //Deposit Key
            setText(R.id.tv_margins_key, CpLanguageUtil.getString(context,"cp_order_text12") + "(" + CpClLogicContractSetting.getContractMarginCoinById(context, item.contractId) + ")")
            //Keping
//            setText(R.id.tv_gains_balance_value, if (CpClLogicContractSetting.getContractUint(context) == 0) item.canCloseVolume else CpBigDecimalUtils.mulStr(item.canCloseVolume, mMultiplier, mMultiplierPrecision))
            //Keyable
//            setText(R.id.tv_gains_balance_key, if (CpClLogicContractSetting.getContractUint(context) == 0) CpLanguageUtil.getString(context,"cp_order_text35") + "("+CpLanguageUtil.getString(context,"cp_overview_text9")+")" else CpLanguageUtil.getString(context,"cp_order_text35") + "(" + mMultiplierCoin + ")")
            //Margin ratio
            setText(R.id.tv_tag_price_value, CpNumberUtil().getDecimal(2).format(
                CpMathHelper.round(
                    CpMathHelper.mul(item.marginRate, "100"), 2)).toString() + "%")
            //Tag Price
            setText(R.id.tv_holdings_value, CpBigDecimalUtils.showSNormal(item.indexPrice, mPricePrecision))
            //Lever
//            setText(R.id.tv_amount_can_be_liquidated_value, item.leverageLevel.toString() + "X")
            //Settled profit and loss
//            setText(R.id.tv_settled_profit_loss_value, CpBigDecimalUtils.showSNormal(item.profitRealizedAmount, mMarginCoinPrecision))

//            if (CpBigDecimalUtils.compareTo(
//                    CpBigDecimalUtils.showSNormal(item.profitRealizedAmount, mMarginCoinPrecision),"0")==1){
//                setTextColor(R.id.tv_settled_profit_loss_value, context.resources.getColor(R.color.main_green))
//            }else{
//                setTextColor(R.id.tv_settled_profit_loss_value, context.resources.getColor(R.color.main_red))
//            }
        }
    }

    override fun setList(list: Collection<CpContractPositionBean>?) {
        super.setList(list)
        tvOnekeyClose?.visibility = if(list.isNullOrEmpty()){
            View.GONE
        }else{
            View.VISIBLE
        }
    }

    private fun createAdl(vg:ViewGroup,position: Int){
        vg.removeAllViews()
        for(index in adlLight.indices){
            val itemLight = View(context)
            val lp = LinearLayout.LayoutParams(PublicSizeUtil.dp2px(context,2.0f),PublicSizeUtil.dp2px(context,8.0f))
            lp.gravity = Gravity.CENTER_VERTICAL
            lp.marginEnd = PublicSizeUtil.dp2px(context,2.0f)
            itemLight.backgroundColor = ContextCompat.getColor(context,if(index in 0..position){
                adlLight[index]
            }else{
                R.color.special_4
            })
            vg.addView(itemLight,lp)
        }
    }

    private fun setLight(vg:ViewGroup,position:Int) {
        if(vg.childCount<=0) {
            createAdl(vg,position)
        }else{
            for(index in adlLight.indices){
                val itemLight = vg.getChildAt(index)
                itemLight.backgroundColor = ContextCompat.getColor(context,if(index in 0..position){
                    adlLight[index]
                }else{
                    R.color.special_4
                })
            }
        }
    }
}
