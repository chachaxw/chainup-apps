package com.yjkj.chainup.new_contract.bean

import com.chad.library.adapter.base.entity.MultiItemEntity
import java.io.Serializable

data class CpCurrentOrderBean(
        val avgPrice: String,
        val ctime: String,
        val dealVolume: String,
        val id: String,
        val orderId:String?,
        val triggerOrderId:String?,
        val contractId: String,
        val open: String,
        val positionType: String,
        val price: String,
        val pricePrecision: Int,
        val triggerPrice: String,
        val expireTime: String,
        val base: String,
        val quote: String,
        val realizedAmount: String,
        val side: String,
        val status: String,
        val symbol: String,
        val type: String,
        val orderType:String,
        val source: String,
        val timeInForce: String,
        val fee: String,
        val tradeFee: String,
        val mtime: String,
        val orderBalance: String,
        val liqPositionMsg: String,
        val liqPositionMsgTimeStamp: String,
        val triggerType: Int,
        val memo: Int,
        val volume: String,
        val otoOrder: otoOrder,
        var layoutType: Int,
        // Liquidation prices 强平价格 30000.03018
        val forcedPrice:String,
        // Take over the price 接管价格 29820
        val takeOverPrice:String,
        var isCompensate: Boolean?,
        var isAdd: Boolean?
) : Serializable, MultiItemEntity {
    var isPlan: Boolean = false
    override val itemType: Int
        get() = layoutType

    fun isMarketOrder() :Boolean{
        return "2".equals(type) || "2".equals(orderType)
    }
}

data class otoOrder(
        val stopLossPrice: String?="--",
        val stopLossStatus: Boolean,
        val stopLossTrigger: String?="--",
        val takerProfitPrice: String?="--",
        val takerProfitStatus: Boolean,
        val takerProfitTrigger: String?="--"
): Serializable
