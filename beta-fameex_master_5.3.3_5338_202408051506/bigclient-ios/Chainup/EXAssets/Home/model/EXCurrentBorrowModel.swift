//
//  EXCurrentBorrowModel.swift
//  Chainup
//
//  Created by ljw on 2023/11/11.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

class EXCurrentBorrowModel: EXBaseModel {
    var financeList = [EXCurrentBorrowListModel]()
    var count = ""
    var pageSize = ""
    override func mj_keyValuesDidFinishConvertingToObject() {
        self.financeList = EXCurrentBorrowListModel.mj_objectArray(withKeyValuesArray: self.financeList).copy() as! [EXCurrentBorrowListModel]
    }
}

class EXCurrentBorrowListModel: EXBaseModel {
    
    var id = ""
    var base = ""
    var quote = ""
    var ctime = ""
    var symbol = ""
    var coin = ""
    var showName = ""
    var borrowMoney = ""
    var interestRate = "" {
        didSet {
            if interestRate.greaterThan("0"){
                let rest = interestRate.bigMul("100",decimals: 2,up: true)
                interestRate = rest + "%"
            }
        }
    }
    var oweInterest = ""
    var oweAmount = ""
    var status = ""
    //For historical records (returned)
    var interest: String = ""
}

