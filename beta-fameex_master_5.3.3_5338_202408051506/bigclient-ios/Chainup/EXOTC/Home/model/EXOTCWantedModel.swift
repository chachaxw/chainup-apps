//
//  EXOTCWantedModel.swift
//  Chainup
//
//  Created by liuxuan on 2023/3/27.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import HandyJSON
class EXOTCWantedModel:NSObject, HandyJSON {
    required override init() {
        super.init()
    }
    var currentUserBanlance :String = ""
    var side :String = ""
    var otcNickName :String = ""
    var totalPrice : String = ""
    var ctime : String = ""
    var volume : String = ""
    var advertId : String = ""//Advertising ID
    var days : String = ""//Expiration time
    var autoReply : String = ""//Automatic reply
    var Description : String = ""//Advertising messages
    var priceRate : String = "" //When customizing the price for premium rate: 0; Write an integer for market premium: 80 represents 80%
    var priceRateType : String = ""//Advertising premium rate 0 Custom 2: Above 3: Below
//    var description :String = ""
    var minTrade :String = ""
    var loginStatus :String = ""
    var payCoin :String = ""
    var volumeBalance :String = ""
    var dealVolume :String = ""
    var price :String = ""
    var imageUrl :String = ""
    var maxTrade :String = ""
    var status_text :String = ""
    var completeOrders :String = ""
    var turnover :String = ""
    var coin :String = ""
    var status :String = ""
    var payments:[OTCPaymentModel] = []
    var creditGrade :String = "" {
        didSet {
            let str = creditGrade as NSString
            let rst = str.decimalString(2)
            if let result = rst {
                creditGrade =  NSString.init(string: "100").multiplying(by: result, decimals: 2) + "%"
            }
        }
    }
    
    func didFinishMapping() {
        let creditGrade = self.creditGrade
        self.creditGrade = creditGrade
    }
    
    var limitTime :String = ""
    
    func fmtPrice()->String {
        return price.formatCurrencyMoney(self.payCoin, format: .fiatFormat)
    }
    
    func fmtMin()->String {
        return minTrade.formatCurrencyMoney(self.payCoin,format:.fiatFormat)
    }
    
    func fmtMax()->String {
        return maxTrade.formatCurrencyMoney(self.payCoin,format:.fiatFormat)
    }
    

    func mapping(mapper: HelpingMapper) {
        mapper.specify(property: &Description, name: "description")
    }

}

