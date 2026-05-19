//
//  EXHistoryEntrustEntity.swift
//  Chainup
//
//  Created by zewu wang on 2023/4/23.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

class EXHistoryEntrustArr : EXBaseModel{
    
    var count = ""
    
    var orderList : [EXCurrentEntrustEntity] = []
    override func mj_keyValuesDidFinishConvertingToObject() {
        self.orderList = EXCurrentEntrustEntity.mj_objectArray(withKeyValuesArray: self.orderList).copy() as! [EXCurrentEntrustEntity]
    }
    
}

class EXHistoryEntrustOpenArr : EXBaseModel{
    
    var count = ""
    
    var orders : [EXCurrentEntrustEntity] = []
    override func mj_keyValuesDidFinishConvertingToObject() {
        self.orders = EXCurrentEntrustEntity.mj_objectArray(withKeyValuesArray: self.orders).copy() as! [EXCurrentEntrustEntity]
    }
    
}

class EXHistoryEntrustEntity: EXBaseModel {

    var side = ""// BUY,//Transaction direction
    var total_price = ""// 0.05751600,//Total amount=price * volume
    var created_at = ""// 2023-02-26 10 = ""//58 = ""//12,//Creation time
    var avg_price = ""// 0.00000000,//Average transaction price
    var countCoin = ""// btc,//Valuation currency
    var source = ""// 1,//Order Source
    var type = ""// 0,//Order Type
    var side_msg = ""//Buy,
    var volume = ""// 1.000,//quantity
    var price = ""// 0.05751600,//price
    var source_msg = ""// WEB,
    var status_msg = ""// 未成交,//Order Status
    var deal_volume = ""// 0.00000000,//Number of transactions completed
    var id = ""// 1160327,
    var remain_volume = ""// 1.00000000,//Number of outstanding transactions
    var baseCoin = ""// eth,//Base currency
    var status = ""// 0//Order status,
    var status_text = ""//Complete transaction
    var deal_money = ""//Total transaction amount
    var time_long = "0"//time stamp
    var isCloseCancelOrder = ""
    var symbol = ""
    
    func getShowName() -> String{
        return "\(baseCoin.uppercased() + "/" + countCoin.uppercased())".aliasCoinMapName()
    }
}

