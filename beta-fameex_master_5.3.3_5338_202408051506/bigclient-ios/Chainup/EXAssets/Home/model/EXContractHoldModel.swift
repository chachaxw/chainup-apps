//
//  EXContractHoldModel.swift
//  Chainup
//
//  Created by liuxuan on 2023/4/28.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

class EXContractHoldModel: EXBaseModel {
    var contractId = ""//Contract ID
    var contractName = ""//Contract Name
    var volume = ""//Number of Outstanding Contracts
    var volumeColor = UIColor.ThemeLabel.colorLite
    var realisedAmount = ""//Realized profit and loss
    var realisedColor = UIColor.ThemeLabel.colorLite
    var unrealisedAmount = ""//Unrealized gains and losses
    var unrealisedColor = UIColor.ThemeLabel.colorLite
    var quoteSymbol = ""//Pricing currency
    var side = ""//BUY multiple SELL empty
    var bond = ""//Guarantee coin type
    var symbol = ""//
    var contractSeries = ""//Contract Series
    var showPrecision = ""
    var leverageLevel = ""
    
 
    func valueDecimal() ->Int? {
        let tmpPrecision = Int(showPrecision)
        if let precision = tmpPrecision {
            return precision
        }
        return nil
    }
    
    
    func fmtRealisedAmount() ->String {
        let precision = self.valueDecimal()
        if precision != nil, !realisedAmount.isEmpty {
            let nsMargin = realisedAmount as NSString
            if nsMargin.hasPrefix("-") {
                let newStr = nsMargin.substring(from: 1) as NSString
                return "-\(newStr.decimalString(precision!) ?? "")"
            }
            let rst = nsMargin.decimalString(precision!)
            if let realRst = rst {
                return realRst
            }
        }
        return realisedAmount
    }

    func fmtUnrealisedAmountMarket() ->String {
        let precision = self.valueDecimal()
        if precision != nil, !unrealisedAmount.isEmpty {
            let nsMargin = unrealisedAmount as NSString
            if nsMargin.hasPrefix("-") {
                let newStr = nsMargin.substring(from: 1) as NSString
                return "-\(newStr.decimalString(precision!) ?? "")"
            }
            return nsMargin.decimalString(precision!)
        }
        return unrealisedAmount
    }

}

