
//
//  EXHistoryDetailEntity.swift
//  Chainup
//
//  Created by zewu wang on 2023/3/10.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

class EXHistoryDetailAllEntity : EXBaseModel{
    var trade_list : [EXHistoryDetailEntity] = []
    override func mj_keyValuesDidFinishConvertingToObject() {
        self.trade_list = EXHistoryDetailEntity.mj_objectArray(withKeyValuesArray: self.trade_list).copy() as! [EXHistoryDetailEntity]
    }
}

class EXHistoryDetailEntity: EXBaseModel {

    var volume = ""
    var side = ""
    var feeCoin = ""
    var time_long = ""
    var price = ""
    var fee = ""
    var ctime = ""
    var deal_price = ""
    var id = ""
    
}
