package com.chainup.contract.bean

import java.io.Serializable

data class ContractListBean(
    val base: String?="",
    val brokerId: Int?=0,
    val capitalFrequency: Int?=0,
    val capitalStartTime: Int?=0,
    val classification: Int?=0,
    val coType: String?="",
    val coinResultVo: CoinResultVo?=null,
    val contractName: String?="",
    val contractOtherName: String?="",
    val contractShowType: String?="",
    val contractSide: Int?=0,
    val contractType: String?="",
    val deliveryKind: String?="",
    val id: Int?=0,
    val marginCoin: String?="",
    val marginRate: Double?=0.0,
    val maxLever: Int?=0,
    val minLever: Int?=0,
    val multiplier: Double?=0.0,
    val multiplierCoin: String?="",
    val quote: String?="",
    val settlementFrequency: Int?=0,
    val sort: Int?=0,
    val symbol: String?=""
):Serializable,Comparable<ContractListBean>{
    override fun compareTo(other: ContractListBean): Int {
        return (this.id?:0) - (other.id?:0)
    }

}

data class CoinResultVo(
    val depth: List<String>,
    val fundsInStatus: Int?=0,
    val fundsOutStatus: Int?=0,
    val marginCoinPrecision: Int?=0,
    val maxLimitMoney: Double?=0.0,
    val maxLimitVolume: Int?=0,
    val maxMarketMoney: Double?=0.0,
    val maxMarketVolume: Int?=0,
    val minOrderMoney: Double?=0.0,
    val minOrderVolume: Int?=0,
    val priceRange: Double?=0.0,
    val symbolPricePrecision: Int?=0
):Serializable
