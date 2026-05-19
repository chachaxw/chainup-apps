//
//  EXCurrentAuthResult.swift
//  Chainup
//
//  Created by cwd on 2023/11/6.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
class EXCurrentAuthResult: EXBaseHanyJsonModel {
    var showName = ""
    var isPass = false
}


class EXKycUserWithdrawAmountInfo: EXBaseHanyJsonModel {
    var withdrawAmount :Double = 0
    var canUseAmount = ""
    var c2cStatus: Int = 0
    var depositStatus = ""
    var currentSymbolAmount: Double = 0
    
    
    var canWithdraw: Bool{
        return withdrawAmount > 0
    }
    var canC2C: Bool{
        return c2cStatus == 1
    }
    var candeposit: Bool {
        return depositStatus == "1"
    }
}
