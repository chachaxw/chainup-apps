//
//  EXCommonAssetModel.swift
//  Chainup
//
//  Created by liuxuan on 2023/4/28.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

class EXCommonAssetModel: EXBaseModel {
    
    var title:String = ""
    var bgIcon:String = ""
    var totalBalance:String = ""
    var totalBalanceSymbol:String = ""
   
    //Contractual use
    var canUseBalance = ""
    var positionMargin = ""
    var orderMargin = ""
    var assetType:EXAccountType?

    func getCaculatePrice()->String {
        //Exchange rate of btc
        let currency = EXAppMarketManager.sharedInstance.getCoinExchangeRate(totalBalanceSymbol)
        let unit = currency.0
        let rate = currency.1
        let decimal = currency.2
        let balance = totalBalance as NSString
        if let rst =  balance.multiplying(by: rate, decimals: decimal,holdZeor: true) {
            return "≈" + unit + rst
        }else {
            return "≈" + unit + "0"
        }
    }
}

