//
//  SLPublicMarketInfo.swift
//  Chainup
//
//  Created by ZYJ on 2023/10/15.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit

class SLPublicMarketInfo: EXCOBaseModel {
    //标记价格 English: Mark price
    var tagPrice:String = ""
   
    //资金费率(下次结算) English: Fund rate (next settlement)
    var nextFundRate = ""
    //资金费率(本期结算) English: Fund rate (current settlement)
    var  currentFundRate = ""
    //指数价格 English: Index price
    var indexPrice:String = ""
    
    func currentFundRateDisplay() -> String {
        
        return (currentFundRate.isEmpty ? "--" : currentFundRate.toPercentString(5))
    }
    func nextFundRateDisplay() -> String {
        return (nextFundRate.isEmpty ? "--" : nextFundRate.toPercentString(5))

    }
}

