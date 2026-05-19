//
//  EXBtoCwithRecordModel.swift
//  Chainup
//
//  Created by zewu wang on 2023/10/30.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

class EXBtoCwithRecordModel: EXBaseModel {

    var financeList : [EXBtoCwithRecordListModel] = []
    override func mj_keyValuesDidFinishConvertingToObject() {
        self.financeList = EXBtoCwithRecordListModel.mj_objectArray(withKeyValuesArray: self.financeList).copy() as! [EXBtoCwithRecordListModel]
    }
    
}

class EXBtoCwithRecordListModel: EXBaseModel {
    
    var createdAt = ""
    var createdAtTime = ""
    var symbol = ""
    var amount = ""
    var transferVoucher = ""
    var companyCard = ""
    var status_text = ""
    var userCard = ""
    var settledAmount = ""
    var status = ""
    var updatedAt = ""
    var transferType = ""//1: Bank card
    var userName = ""//Payee
    
    
}

