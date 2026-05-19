package com.yjkj.chainup.treaty.adapter

import android.util.Log
import android.widget.TextView
import com.chad.library.adapter.base.BaseQuickAdapter
import com.chad.library.adapter.base.viewholder.BaseViewHolder
import com.coorchice.library.SuperTextView
import com.yjkj.chainup.R
import com.yjkj.chainup.manager.Contract2PublicInfoManager
import com.yjkj.chainup.util.ColorUtil
import com.yjkj.chainup.new_version.view.PositionITemView
import com.yjkj.chainup.treaty.bean.ActiveOrderListBean
import com.yjkj.chainup.util.TimeUtil
import com.yjkj.chainup.util.setGoneV3
import org.jetbrains.anko.textColor

/**
 * @Author: Bertking
 * @Date 2023/5/10-17:26 PM
 *@description: The current commission for Contract 4.0
 *
 * PS:For contract,
 *
 * BTCUSDT  :
 *Price: USDT here quotSymbol
 *Value: BTC here baseSymbol
 *Balance: BTC here baseSymbol
 */
open class ContractCurrentEntrustOrderAdapter(data: ArrayList<ActiveOrderListBean.Order>) :
        BaseQuickAdapter<ActiveOrderListBean.Order, BaseViewHolder>(R.layout.item_current_entrust_contract, data) {

    val TAG = ContractCurrentEntrustOrderAdapter::class.java.simpleName

    override fun convert(helper: BaseViewHolder, item: ActiveOrderListBean.Order) {
        if(item?.contractId != Contract2PublicInfoManager.currentContract()?.id){
            return
        }

        /**
         *Market price list hidden button
         *(1: Limit Order, 2: Market Order)
         */
        if (item?.type == 2) {
            helper.setGoneV3(R.id.tv_status, false)
        } else {
            helper.setGoneV3(R.id.tv_status, true)
        }

        addChildClickViewIds(R.id.tv_status)

        /**
         *Buyer and Seller
         */
        if (Contract2PublicInfoManager.isPureHoldPosition()) {
            val side = item?.side
            if (side == "BUY") {
                helper?.setText(R.id.tv_side, context.getString(R.string.contract_text_long))
                helper?.getView<TextView>(R.id.tv_side)?.textColor = ColorUtil.getMainColorType()
            } else {
                helper?.setText(R.id.tv_side, context.getString(R.string.contract_text_short))
                helper?.getView<TextView>(R.id.tv_side)?.textColor = ColorUtil.getMainColorType(isRise = false)
            }
        } else {
            val side = item?.side
            val action = item?.action
            if (side == "BUY") {
                if (action == "OPEN") {
                    //Go long
                    helper?.setText(R.id.tv_side, context.getString(R.string.contract_action_long))
                } else {
                    //Pingduo
                    helper?.setText(R.id.tv_side, context.getString(R.string.contract_flat_long))
                }
                helper?.getView<TextView>(R.id.tv_side)?.textColor = ColorUtil.getMainColorType()
            } else {
                val text = if (action == "OPEN") {
                    //Short selling
                    context.getString(R.string.contract_action_short)
                } else {
                    context.getString(R.string.contract_flat_short)
                }
                helper?.setText(R.id.tv_side, text)
                helper?.getView<TextView>(R.id.tv_side)?.textColor = ColorUtil.getMainColorType(isRise = false)
            }


        }



        helper?.setText(R.id.tv_contract_symbol, item?.symbol)

        val level = if (!Contract2PublicInfoManager.isPureHoldPosition()) {
            " (${item?.leverageLevel}X)"
        } else {
            ""
        }
        helper?.setText(R.id.tv_contract_type, Contract2PublicInfoManager.getContractType(context, item?.contractId) + level)


        
        /**
         *Entrustment price (the price on the market price list is "market price")
         *(1: Limit Order, 2: Market Order)
         */
        val pricePositionITemView = helper?.getView<PositionITemView>(R.id.tv_entrust_price)
        pricePositionITemView?.title = context.getString(R.string.contract_text_trustPrice) + "(${item?.quoteSymbol})"
        if (item?.type == 1) {
            val price = Contract2PublicInfoManager.cutValueByPrecision(item.price.toString(), item.pricePrecision
                    ?: 4)
            pricePositionITemView?.value = price
        } else {
            pricePositionITemView?.value = (context.getString(R.string.contract_action_marketPrice))
        }

        /**
         *Number of positions (pieces)
         */
        val pit_position_amount = helper?.getView<PositionITemView>(R.id.tv_position_amount)
        pit_position_amount?.title = context.getString(R.string.contract_text_positionNumber)
        if (item?.side == "BUY") {
            pit_position_amount?.value = "${item.volume.toString()}"
            pit_position_amount?.tailValueColor = ColorUtil.getMainColorType(true)
        } else {
            pit_position_amount?.value = "${item?.volume.toString()}"
            pit_position_amount?.tailValueColor = ColorUtil.getMainColorType(false)
        }

        /**
         *Order time
         */
        val dateItemView = helper?.getView<PositionITemView>(R.id.tv_date)
        dateItemView?.title = context.getString(R.string.kline_text_dealTime)
        dateItemView?.value = TimeUtil.instance.getTime(item?.ctime)

        /**
         *Value
         */
        val valuePositionITemView = helper?.getView<PositionITemView>(R.id.tv_entrust_value)
        valuePositionITemView?.title = context.getString(R.string.contract_text_value) + "(BTC)"
        valuePositionITemView?.value = Contract2PublicInfoManager.cutDespoitByPrecision(item?.orderPriceValue.toString())


        /**
         *Average transaction price
         */
        val avgPrice = Contract2PublicInfoManager.cutValueByPrecision(item?.avgPrice.toString(), item?.pricePrecision
                ?: 4)
        val avgPricePositionITemView = helper?.getView<PositionITemView>(R.id.tv_avg_price)
        avgPricePositionITemView?.title = context.getString(R.string.contract_text_dealAverage) + "(${item?.quoteSymbol})"
        avgPricePositionITemView?.value = (avgPrice)


        /**
         *Closed
         */
        val dealtPositionITemView = helper?.getView<PositionITemView>(R.id.tv_deal)
        dealtPositionITemView?.title = context.getString(R.string.contract_text_dealDone) + "(${context.getString(R.string.contract_text_volumeUnit)})"
        dealtPositionITemView?.value = item?.dealVolume.toString()


        /**
         *Remaining quantity
         */
        val remainVolumePositionITemView = helper?.getView<PositionITemView>(R.id.tv_remain_volume)
        remainVolumePositionITemView?.title = context.getString(R.string.contract_text_remaining) + "(${context.getString(R.string.contract_text_volumeUnit)})"
        remainVolumePositionITemView?.value = (item?.undealVolume.toString())


        /**
         *Order status:
         *0: Initial status 1: New order 2: Full transaction 3: Partial transaction 4: Canceled 5: Pending cancellation 6: Abandoned 7: Partial transaction has been cancelled (0 1 3 shows the cancellation button
         */
        val statusView = helper?.getView<SuperTextView>(R.id.tv_status)
        when (item?.status) {
            0, 1, 3 -> {
                statusView?.text = context.getString(R.string.contract_action_cancle)
                statusView?.textColor = ColorUtil.getColor(R.color.main_blue)
            }
            else -> {
                helper?.setTextColor(R.id.tv_status, ColorUtil.getColor(R.color.normal_text_color))
                helper?.setText(R.id.tv_status, item?.statusText)
            }
        }

    }

}
