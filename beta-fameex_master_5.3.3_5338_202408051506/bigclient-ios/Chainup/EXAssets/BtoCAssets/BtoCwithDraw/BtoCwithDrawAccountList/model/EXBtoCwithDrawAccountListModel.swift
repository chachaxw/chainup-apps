//
//  EXBtoCwithDrawAccountListModel.swift
//  Chainup
//
//  Created by zewu wang on 2023/10/30.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

class EXBtoCwithDrawAccountModel : EXBaseModel{
    
    var list : [EXBtoCwithDrawAccountListModel] = []
    override func mj_keyValuesDidFinishConvertingToObject() {
        self.list = EXBtoCwithDrawAccountListModel.mj_objectArray(withKeyValuesArray: self.list).copy() as! [EXBtoCwithDrawAccountListModel]
    }
}

class EXBtoCwithDrawAccountListModel: EXBaseModel {

    var userName = ""
    var bankName = ""
    var opName = ""
    var id = ""
    var uid = ""
    var cardNo = ""
    {
        didSet{
            if cardNo.count >= 3{
                showCardNo = String(cardNo.suffix(3))
            }else{
                showCardNo = cardNo
            }
        }
    }
    var showCardNo = ""
    var bankNo = ""
    var bankSub = ""
    var name = ""
    var ctime = ""
    var mtime = ""
    var status = ""
    var isDelete = ""
    var type = ""
    var outTransId = ""
    var opUid = ""
    var remarks = ""
    var email = ""
    var mobileNumber = ""
    var transferVoucher = ""
    var fee = ""
    var feeType = ""//0 handling fee 1 handling rate
    var symbol = ""
    
}

