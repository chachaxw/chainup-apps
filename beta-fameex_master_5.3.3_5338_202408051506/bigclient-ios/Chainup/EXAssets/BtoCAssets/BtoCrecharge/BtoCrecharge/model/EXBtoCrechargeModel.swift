//
//  EXBtoCrechargeModel.swift
//  Chainup
//
//  Created by zewu wang on 2023/11/4.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

class EXBtoCrechargeModel: NSObject {

    var coinSymbol = ""//currency
    var amount = ""//Recharge amount
    var imgUrl = ""//Transfer voucher (image)
    var depositMin = ""//Latest recharge amount
}

class EXCompanyBankInfoModel : EXBaseModel{
    var bankName = ""
    var id = ""
    var cardNo = ""
    var bankNo = ""
    var bankSub = ""
    var name = ""
    var ctime = ""
    var mtime = ""
    var isDelete = ""
    var defaultBankName = ""
    var isTransferVoucher = ""
    var langKey = ""
    var symbol = ""
    var remark = ""
}

