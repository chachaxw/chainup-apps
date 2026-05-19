//
//  EXOTCSearch.swift
//  Chainup
//
//  Created by liuxuan on 2023/3/26.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

class OTCSearchListItem:EXBaseHanyJsonModel {
    var side :String = ""
    var otcNickName :String = ""
    var loginStatus :String = ""
    var userId :String = ""
    var advertId :String = ""
    var volume :String = ""
    var volumeBalance :String = ""
    var payCoin :String = ""
    var paySymbol :String = ""
    var imageUrl :String = ""
    var completeOrders :String = ""
    var isBlockTrade :String = ""
    var minTrade :String = ""
    var maxTrade :String = ""
    var price :String = ""
    @objc dynamic var creditGrade :String = "" {
        didSet {
            let str = NSString.init(string: "1").subtracting(creditGrade, decimals: 2)
            creditGrade =  NSString.init(string: "100").multiplying(by: str, decimals: 2) + "%"
        }
    }
    var payments:[OTCPaymentModel] = []
    
    func fmtPrice()->String {
        return price.formatCurrencyMoney(self.payCoin, format: .fiatFormat)
    }
    
    func fmtMin()->String {
        return minTrade.formatCurrencyMoney(self.payCoin,format:.fiatFormat)
    }
    
    func fmtMax()->String {
        return maxTrade.formatCurrencyMoney(self.payCoin,format: .fiatFormat)
    }
    
    func fmtVolumeBalance(_ coinName:String) ->String {
        let precion = EXAppMarketManager.sharedInstance.getCoinPrecision(coinName)
        volumeBalance = NSString.init(string: volumeBalance).decimalString(precion)
        return volumeBalance
    }
    
//    override func mj_keyValuesDidFinishConvertingToObject() {
//        self.payments = OTCPaymentModel.mj_objectArray(withKeyValuesArray: self.payments).copy() as! [OTCPaymentModel]
//    }
    
}

class EXOTCSearch: EXBaseHanyJsonModel {
    
    var count : String = ""
    var advertList:[OTCSearchListItem] = []
    
//    override func mj_keyValuesDidFinishConvertingToObject() {
//        self.advertList = OTCSearchListItem.mj_objectArray(withKeyValuesArray: self.advertList).copy() as! [OTCSearchListItem]
//    }
    
}
