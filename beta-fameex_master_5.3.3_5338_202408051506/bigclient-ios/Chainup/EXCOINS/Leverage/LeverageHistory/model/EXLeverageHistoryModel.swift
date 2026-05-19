//
//  EXLeverageHistoryModel.swift
//  Chainup
//
//  Created by zewu wang on 2023/11/7.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

class EXLeverHistoryEntrustArr : EXBaseModel{
    
    var count = ""
    
    var orders : [EXLeverageHistoryDetailModel] = []
    override func mj_keyValuesDidFinishConvertingToObject() {
        self.orders = EXLeverageHistoryDetailModel.mj_objectArray(withKeyValuesArray: self.orders).copy() as! [EXLeverageHistoryDetailModel]
    }
    
}

class EXLeverageHistoryModel: EXBaseModel {

    var orderList : [EXLeverageHistoryDetailModel] = []
    
    override func mj_keyValuesDidFinishConvertingToObject() {
        self.orderList = EXLeverageHistoryDetailModel.mj_objectArray(withKeyValuesArray: self.orderList).copy() as! [EXLeverageHistoryDetailModel]
    }
}

class EXLeverageHistoryDetailModel : EXBaseModel {
    
    var side = ""//Transaction direction
    var total_price = ""//Total amount=price * volume
    var created_at = ""//Creation time
    var avg_price = ""//Average transaction price
    var countCoin = ""//Valuation currency
    var source = ""//Order Source
    var type = ""//Order Type
    var side_msg = ""
    var volume = ""//quantity
    var price = ""//price
    var source_msg = ""
    var status_msg = ""//Order Status
    var deal_volume = ""//Number of transactions completed
    var id = ""
    var remain_volume = ""//Number of outstanding transactions
    var baseCoin = ""//Base currency
    var status = ""//Order status,
    var status_text = ""
    var deal_money = ""
    var time_long = "0"//time stamp
    
    func getShowName() -> String{
        return "\(baseCoin.uppercased() + "/" + countCoin.uppercased())".aliasCoinMapName()
    }
    
}

