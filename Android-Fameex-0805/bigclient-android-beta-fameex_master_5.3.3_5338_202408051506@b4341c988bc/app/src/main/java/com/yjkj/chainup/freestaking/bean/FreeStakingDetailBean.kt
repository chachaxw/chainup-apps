package com.yjkj.chainup.freestaking.bean

import java.math.BigDecimal


data class FreeStakingDetailBean(var name: String? = null,
                                 var info: String? = null,
                                 var projectType: Int = 0,
                                 var shortName: String? = null,
                                 var logo: String? = null,
                                 var gainRate: Double = 0.0,
                                 var url: String? = null,
                                 var details: String? = null,
                                 var title: String? = null,
                                 var status: String? = null,
                                 var gainCoin: String? = null,
                                 var tipMine: String? = null,
                                 var activeStatus: Int = 0,
                                 var balance: BigDecimal=BigDecimal.ZERO,
                                 var totalAmount: BigDecimal= BigDecimal.ZERO,
                                 var progress: String? = null,
                                 var stimeMillis: String? = null,
                                 var etimeMillis: String? = null,
                                 var ltimeMillis: String? = null,
                                 var iasDateMillis: String? = null,
                                 var raiseAmount: BigDecimal=BigDecimal.ZERO,
                                 var buyAmountMin: BigDecimal= BigDecimal.ZERO,
                                 var buyAmountMax: BigDecimal = BigDecimal.ZERO,
                                 var isShowBuy: Int = 0,
                                 var lockDay:Int=0,
                                 var totalGainAmount: BigDecimal=BigDecimal.ZERO,
                                 var totalUserGainAmount: BigDecimal=BigDecimal.ZERO,
                                 var userGainList: ArrayList<UserGainListBean>? = null,
                                 var currencyExchangeRate:BigDecimal= BigDecimal.ZERO,
                                 var remainingTimeSeconds :Long=0,
                                 var needAuth:Int
)
