//
//  EXCheckAuthInfoModel.swift
//  Chainup
//
//  Created by liuxuan on 2023/3/19.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

enum EXCheckAuthCode :String {
    case success = "0"
    case userNameErr = "1"
    case idNumberErr = "2"
    case tryTimesErr = "3"
}

class EXCheckAuthInfoModel: EXBaseModel {
    /*
Verification result 0: success, 1: user name error, 2: user ID number error, 3: verification times exceed the limit
     */
    var result = ""
    var reqNum = ""
}

