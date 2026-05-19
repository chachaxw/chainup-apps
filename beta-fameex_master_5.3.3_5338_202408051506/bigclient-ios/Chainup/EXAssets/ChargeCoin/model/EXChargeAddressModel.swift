//
//  EXChargeAddressModel.swift
//  Chainup
//
//  Created by liuxuan on 2023/4/29.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

class EXChargeAddressModel: EXBaseModel {
    var addressQRCode:String = "" //Base64
    var tagAddress:String = "" //Label Address
    //Address, if there is _, Label
    var addressStr:String = "" {
        didSet {
            let addressTags = addressStr.components(separatedBy: "_")
            if addressTags.count == 2 {
                addressStr = addressTags[0]
                tagAddress = addressTags[1]
            }
        }
    }
    var depositConfirm = ""
}

