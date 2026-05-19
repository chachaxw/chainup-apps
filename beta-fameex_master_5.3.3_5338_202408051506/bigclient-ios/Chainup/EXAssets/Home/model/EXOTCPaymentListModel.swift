//
//  EXOTCPaymentListModel.swift
//  Chainup
//
//  Created by liuxuan on 2023/4/22.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

class EXOTCPaymentListModel: EXBaseModel {
    var id:String = ""
    var payment:String = ""
    var userName :String = ""
    var account :String = ""
    var qrcodeImg :String = ""
    var bankName :String = ""
    var bankOfDeposit :String = ""
    var ifscCode :String = ""
    var remittanceInformation :String = ""
    var isChoose : Bool = false//The advertising page is used to record whether it is selected or not
    var isOpen :String = ""
    var icon :String = ""
    var title :String = ""
    var accountType: String = ""
    var cci:String = ""
    var idNumber:String = ""
    var email:String = ""
}

