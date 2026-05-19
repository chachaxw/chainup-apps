package com.chainup.contract.bean

data class CpTpslOrderBean(
        var triggerType: String, //Fixed enumeration of stop loss order types (1 stop loss, 2 stop gain)
        var price: String,//Ordering price (market price list transferred to 0)
        var volume: String,//Order quantity (opening market price order: amount)
        var triggerPrice: String,//Trigger Price
        var type :String,//Order type (1 limit, 2 market)
        var expiredTime :Int//Valid time (1, 7, 14, 30) days, fixed enumeration;
)
