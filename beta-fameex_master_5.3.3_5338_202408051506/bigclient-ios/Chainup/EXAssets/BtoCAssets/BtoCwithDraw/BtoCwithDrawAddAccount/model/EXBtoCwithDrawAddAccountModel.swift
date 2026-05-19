//
//  EXBtoCwithDrawAddAccountModel.swift
//  Chainup
//
//  Created by zewu wang on 2023/10/23.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

class EXBtoCwithDrawAddAccountModel: NSObject {

    var title = ""
    
    var text = ""
    
    var placeHolder = ""
    
    var editor = false//Can I edit it
    
    var state = "0"//Type 0 editing status 1 clicking status
    
}

class EXBtoCwithDrawBankModel : EXBaseModel{
    var accountName = ""
    var bankNo = ""
    var id = ""
}

class EXBtoCwithDrawUserBankModel : EXBaseModel{
    var bankNo = ""
    var name = ""
    var bankName = ""
    var bankSub = ""
    var id = ""
    var cardNo = ""
    var status = ""
}

