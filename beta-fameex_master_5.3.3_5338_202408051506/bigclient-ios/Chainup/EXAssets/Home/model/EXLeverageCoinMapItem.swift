//
//  EXLeverageCoinMapItem.swift
//  Chainup
//
//  Created by ljw on 2023/11/4.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

class EXLeverageCoinMapItem: EXBaseModel {
    var quoteReturnPrecision: String = ""
    var baseTotalBorrow: String = ""
    var quoteCanBorrow: String = ""
    var quoteBorrowBalance: String = ""
    var quoteMinBorrow: String = ""
    var riskRate: String = ""
    var baseNormalBalance: String = ""//Leveraged available balance
    var baseTotalBalance: String = ""
    var multiple: String = ""
    var quoteNormalBalance: String = ""
    var baseMinBorrow: String = ""
    var burstPrice: String = ""
    var quoteEXNormalBalance: String = ""
    var quoteCoin: String = ""
    var quoteMinPayment: String = ""
    var name: String = ""
    var baseCanBorrow: String = ""
    var baseBorrowBalance: String = ""
    var quoteLockBalance: String = ""
    var baseLockBalance: String = ""
    var symbol: String = ""
    var baseReturnPrecision: String = ""
    var baseMinPayment: String = ""
    var quoteTotalBorrow: String = ""
    var quoteTotalBalance: String = ""
    var rate: String = ""
    var baseCoin: String = ""
    var baseExNormalBalance: String = ""//Available balance in currency
    var symbolBalance : String = ""//Equivalent to total assets
    var doubleSort : Double = 10000
}

