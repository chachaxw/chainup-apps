//
//  EXDecimalHandler.swift
//  Chainup
//
//  Created by liuxuan on 2022/7/15.
//  Copyright © 2022 Chainup. All rights reserved.
//

import UIKit

class EXDecimalHandler: NSObject {

}


enum EXCurrencyUnitFormat {
    case coinFormat
    case fiatFormat
}


extension String {
    
    func getCaculatePrice(forSymbol:String,withUnit:Bool = false)->String {
        let currency = EXAppMarketManager.sharedInstance.getCoinExchangeRate(forSymbol)
        let unit = currency.0
        let rate = currency.1
        let decimal = currency.2
        let balance = self as NSString
        if let rst =  balance.multiplying(by: rate, decimals: decimal,holdZeor: true) {
            if withUnit {
                return "≈" + unit + rst
            }else {
                return rst
            }
        }else {
            if withUnit {
                return "≈" + unit + "0"
            }else {
                return "0"
            }
        }
    }
    
    func formatCurrencyMoney(_ symbol:String,holdZero:Bool = true, format:EXCurrencyUnitFormat = .coinFormat) ->String {
        if self.isEmpty {
            return ""
        }
        //Currency and fiat currency accuracy
        if format == .coinFormat {
            let currencyModel = EXAppMarketManager.sharedInstance.getCurrencyModel(symbol)
            let precion = Int(currencyModel.coin_precision)
            
            let nsAmount = self as NSString
            if holdZero {
                let rst = nsAmount.decimalString1(precion ?? 4)
                if let rightRst = rst {
                    return rightRst
                }
                return self
            }else {
                let rst = nsAmount.decimalString(precion ?? 4)
                if let rightRst = rst {
                    return rightRst
                }
                return self
            }
        }
            //Legal currency accuracy, independent configuration of legal currency
        else if format == .fiatFormat {
            let currencyModel = EXAppMarketManager.sharedInstance.getCurrencyModel(symbol)
            let precion = Int(currencyModel.coin_fiat_precision)
            
            let nsAmount = self as NSString
            if holdZero {
                let rst = nsAmount.decimalString1(precion ?? 4)
                if let rightRst = rst {
                    return rightRst
                }
                return self
            }else {
                let rst = nsAmount.decimalString(precion ?? 4)
                if let rightRst = rst {
                    return rightRst
                }
                return self
            }
        }else  {
            //Format failed, return directly
            return self
        }
    }
    
    func formatAmount(_ forSymbol:String, holdZero:Bool = true,isLeverage : Bool = false,deci: Int? = 0) -> String {
        if self.isEmpty {
            return "0"
        }

        var decimal = EXAppMarketManager.sharedInstance.getCoinPrecision(forSymbol)

        if isLeverage {
            decimal = 8
        }
        if let d = deci,d > 0{
            decimal = d
        }
        let nsAmount = self as NSString
        if holdZero {
            let rst = nsAmount.decimalString1(decimal)
            if let rightRst = rst {
                return rightRst
            }
            return self
        }else {
            let rst = nsAmount.decimalString(decimal)
            if let rightRst = rst {
                return rightRst
            }
            return self
        }
    }
    
    //Directly calling symbol to obtain alias
    func aliasName() -> String {
        if self.isEmpty {
            return self
        }
        if let coinModel = EXAppMarketManager.sharedInstance.getCoinEntity(self) {
            //TODO: showname
            if coinModel.name.isEmpty {
                return self
            }
            //TODO: return showname
            return coinModel.showName
        }
        return self
    }
    
    //Directly call name to obtain alias
    func aliasCoinMapName() -> String{
        if self.isEmpty {
            return self
        }
        let coinMapModel = EXAppMarketManager.sharedInstance.getCoinMapEntityByName(self)
        if coinMapModel.name.isEmpty{
            return self
        }else{
            return coinMapModel.showName
        }
    }
    
    func standardQuickMoneyDecimal(currencyModel:EXCurrencyModel,
                                   format:EXCurrencyUnitFormat,
                                   holdZero:Bool = true) ->String {
        if self.isEmpty {
            return ""
        }
        var precion = 2
        if format == .coinFormat {
            precion = Int(currencyModel.coin_precision) ?? 4
        }else {
            precion = Int(currencyModel.coin_fiat_precision) ?? 2
        }
        let rst = self.decimalString(value: precion, holdZero: holdZero)
        return rst
    }
    
}

