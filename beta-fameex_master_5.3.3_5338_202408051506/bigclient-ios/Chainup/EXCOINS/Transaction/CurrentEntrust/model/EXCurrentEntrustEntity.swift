//
//  EXCurrentEntrustEntity.swift
//  Chainup
//
//  Created by zewu wang on 2023/4/1.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

@objcMembers class EXCurrentEntrustArr : EXBaseModel{
    
    var symbol = ""//Currency pair
    
    var minPrice = "0.01"//Corresponding to minimum price+-
    
    var baseCoinBalance = "0"//Remaining Base Currency
    
    var volumePrecision : Int = 2//Quantity precision Quantity Decimal separator number
    
    var price = ""
    
    var count = ""
    
    var countCoinBalance = "0"//Remaining Valuation Currency
    
    var minVolume = "0.01"//Quantity+-
    
    var pricePrecision : Int = 2//Price precision Decimal separator
        
    var orderList : [EXCurrentEntrustEntity] = []
    override func mj_keyValuesDidFinishConvertingToObject() {
        self.orderList = EXCurrentEntrustEntity.mj_objectArray(withKeyValuesArray: self.orderList).copy() as! [EXCurrentEntrustEntity]
    }
    
}

enum EXCurrentEntrustSourceType:String {
    case quantGrid = "QUANT-GRID"
}

@objcMembers class EXCurrentEntrustEntity: EXBaseModel {

    var id = ""
    
    var volume = ""//Number of Commissions
    
    var total_price = ""//Total amount=price * volume
    
    var created_at = ""
    
    var avg_price = ""//Average transaction price
    
    var countCoin = ""//Valuation currency
    
    var remain_volume = ""//Number of outstanding transactions
    
    var side = ""//Buying and selling direction
    
    var source = ""//Order Source
    
    var type = ""//Order Type 1 Limit Price 2 Market Price
    
    var price = ""//Commission price
    
    var deal_volume = ""//Turnover volume
    
    var deal_money = ""//Turnover volume

    var baseCoin = ""//Base currency
    
    var time_long = "0"
    
    var status_text = ""
    
    var status = ""//
    
    var isCloseCancelOrder = ""//Close Order List Cancel Order Button 1 Yes 0 No
/*Order status INIT (0, "Initial order, not closed but not entered into trading"),
NEW_ (1, "New orders, no transactions entered trading"),
FILLED (2, "Complete transaction"),
PART_ Filled (3, "Partial transaction"),
CANCELED (4, "Cancelled"),
PENDING_ CANCEL (5, "Pending Cancellation"),
EXPIRED (6, "Abnormal Orders");
PART_ Filled_ CANCELED (7, "Some transactions have been cancelled, the Vue version front-end display is in use, and the database does not have this status");
    */
    
//    var status_msg = "" //Order Status
//    var side_msg = "";//Buy out
    
    func getShowName() -> String{
        return "\(baseCoin.uppercased() + "/" + countCoin.uppercased())".aliasCoinMapName()
    }
    
    func fmtPrice() -> String {
        return ""
    }
    
    func fmtVolume() ->String {
        return ""
    }
    
    func fmtDealVolume() -> String {
        return ""
    }
    
}

