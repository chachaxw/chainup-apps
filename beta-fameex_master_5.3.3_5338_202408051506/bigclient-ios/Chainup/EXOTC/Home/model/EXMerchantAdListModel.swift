//
//  EXMerchantAdListModel.swift
//  Chainup
//
//  Created by liuxuan on 2023/4/19.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

class EXAdListItem : EXBaseHanyJsonModel {
    var payCoin:String = ""
    var paySymbol:String = ""
    var volume:String = ""
    var side:String = ""
    var createTime:String = ""
    var price:String = ""
    var sell:String = ""
    var advertId:String = ""
    var status:String = ""
    var coin:String = ""
    var isHaveOrder:String = ""
    var minTrade : String = ""
    var maxTrade : String = ""
    
    func fmtMin()->String {
        return minTrade.formatCurrencyMoney(self.payCoin,format: .fiatFormat)
    }
    
    func fmtMax()->String {
        return maxTrade.formatCurrencyMoney(self.payCoin,format: .fiatFormat)
    }
    
    func fmtPrice()->String {
//        price = NSString.init(string: price).decimalString1(PublicInfoManager.sharedInstance.getRatePrecision())
//        return price
        return price.formatCurrencyMoney(self.payCoin,format: .fiatFormat)
    }


    
    var payments : [OTCPaymentModel] = []//Payment method
//    override func mj_keyValuesDidFinishConvertingToObject() {
//        self.payments = OTCPaymentModel.mj_objectArray(withKeyValuesArray: self.payments).copy() as! [OTCPaymentModel]
//    }
}

class EXMerchantAdListModel: EXBaseHanyJsonModel {
    var adList : [EXAdListItem] = []//Payment method
 
    
//    override func mj_keyValuesDidFinishConvertingToObject() {
//        self.adList = EXAdListItem.mj_objectArray(withKeyValuesArray: self.adList).copy() as! [EXAdListItem]
//    }
}

