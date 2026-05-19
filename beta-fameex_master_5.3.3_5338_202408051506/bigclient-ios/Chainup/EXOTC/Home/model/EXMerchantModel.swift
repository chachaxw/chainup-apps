//
//  EXMerchantModel.swift
//  Chainup
//
//  Created by liuxuan on 2023/4/19.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

class EXMerchantModel: EXBaseModel {
    var lastLoginTime:String = ""
    var mobileAuthStatus:String = ""
    var registerTime:String = ""
    var identity:String = ""
    var otcNickName:String = ""
    var imageUrl:String = ""
    var complainNum:String = ""
    var loginStatus:String = ""
    var completeOrders:String = ""
    var authLevel:String = ""
    var sucComplainNum:String = ""
    var trustScore:String =  "" {
        didSet {
            let str = NSString.init(string: "1").subtracting(trustScore, decimals: 2)
            trustScore =  NSString.init(string: "100").multiplying(by: str, decimals: 2) + "%"
        }
    }

}
