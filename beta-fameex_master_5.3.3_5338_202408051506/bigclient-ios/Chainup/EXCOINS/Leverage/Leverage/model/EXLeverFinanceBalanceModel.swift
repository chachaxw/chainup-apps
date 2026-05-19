//
//  EXLeverFinanceBalanceModel.swift
//  Chainup
//
//  Created by zewu wang on 2023/11/7.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

class EXLeverFinanceBalanceModel: EXBaseModel {

    var baseTotalBalance = ""//total assets
    var baseNormalBalance = "" //available
    var baseLockBalance = "" //freeze
    var baseBorrowBalance = "" //Borrowed
    var baseCanBorrow = "" //Borrowable
    var baseTotalBorrow = "" //Total amount
    var quoteTotalBalance = ""//total assets
    var quoteNormalBalance = "" //available
    var quoteLockBalance = "" //freeze
    var quoteBorrowBalance = "" //Borrowed
    var quoteCanBorrow = "" //Borrowable
    var quoteTotalBorrow = "" //Total amount
    var quoteCoin = ""//Valuation currency
    var baseCoin = "" //Base currency
    var riskRate = ""//Risk rate
    var burstPrice = ""//Burst price
    
    var symbol = ""
    var name = ""
    var multiple = ""//multiple
    var rate = ""//interest rate
    var baseMinBorrow = ""//Minimum borrowing and lending in base currency
    var baseMinPayment = ""//Minimum repayment amount in base currency
    var quoteMinBorrow = ""//Minimum borrowing and lending amount in pricing currency
    var quoteMinPayment = ""//Minimum repayment amount in valuation currency
    
    var baseExNormalBalance = "" //available
    var quoteEXNormalBalance = "" //available
    var baseCanTransfer = "" //Base transferable
    var quoteCanTransfer = "" //Quote transferable
    var baseReturnPrecision = "" //Base return accuracy
    var quoteReturnPrecision = "" //Quote return accuracy
    
    func hiddenRisk() -> Bool{
        if let risk = Double(riskRate){
            if risk < 110{
                return true
            }
        }
        return false
    }
    
    func riskLength() -> CGFloat{
        var length : CGFloat = 0
        if let risk = Double(riskRate){
            if risk <= 110{
                length = 0
            }else if risk >= 150{
                length = SCREEN_WIDTH - 30
            }else{
                length =  (SCREEN_WIDTH - 30) * (CGFloat(risk) - 110) / 40
            }
        }
       return length
    }
    
    
    func riskColor() -> UIColor{
        var color = UIColor.ThemeLabel.colorMedium
        if let risk = Double(riskRate){
            if risk >= 200{
                color = UIColor.ThemeState.success
            }else if risk >= 110 && risk < 200 {
                color = UIColor.ThemeState.fail
            }else{
                
            }
        }
        return color
    }
    
    func riskStep() -> Int{
        var length : Int = 1
        if let risk = Double(riskRate),risk > 0{
            if risk >= 200 {
                length = 1
            }else if risk >= 150, risk < 200 {
                length = 2
            }else if risk >= 120, risk < 150 {
                length = 3
            }else  {
                length = 4
            }
        }
        return length
    }
    
    
    func fmsRiskRate() -> String{
        var risk = "--"
        if let risk1 = Double(riskRate){
            if risk1 < 110{
                risk = "--"
            }else{
                if risk1 > 999{
                    riskRate = "999"
                }
                risk = riskRate + "%"
            }
        }
        return risk
    }
    
    func fmsburstPrice() -> String{
        if let risk1 = Double(riskRate),risk1 >= 999{
            return "--"
        }
        let coinmapmodel = EXAppMarketManager.sharedInstance.getCoinMapEntityBySymbol(symbol)
        var burst = "--"
        if burst != ""{
            if let index = Int(coinmapmodel.price){//Change product requirements to price accuracy
                burst = (burstPrice.decimalNumberWithDouble() as NSString).decimalString1(index)
            }else{
                burst = burstPrice.decimalNumberWithDouble()
            }
        }
        return burst
    }
    
    func getSymbolCoin() -> String{
        return baseCoin.aliasName() + "/" + quoteCoin.aliasName()
    }
    
    func fmsBaseNormalBalance() -> String{
        if let b = (baseNormalBalance.decimalNumberWithDouble() as NSString).decimalString1(8){
            return b
        }
        return baseNormalBalance.decimalNumberWithDouble()
    }
    
    func fmsQuoteNormalBalance() -> String{
        if let q = (quoteNormalBalance.decimalNumberWithDouble() as NSString).decimalString1(8){
            return q
        }
        return quoteNormalBalance.decimalNumberWithDouble()
    }
    
}

