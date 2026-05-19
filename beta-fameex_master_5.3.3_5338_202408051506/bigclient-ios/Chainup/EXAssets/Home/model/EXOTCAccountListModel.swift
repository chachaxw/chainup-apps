//
//  EXOTCAccountListModel.swift
//  Chainup
//
//  Created by liuxuan on 2023/4/22.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

class CoinMapItem:EXBaseModel {
/*
     {
CoinSymbol: BTC, Currency
     "normal": "0.00000000",//Normal balance
     "exNormal":"0.0000000",//Normal balance of the exchange
     "lock": "0.00000000",//Frozen amount
     "exLock": "0.00000000",//Exchange frozen amount
     "total_balance": 0.00000000,//total assets
     "btcValuation"： "0.00000000",//Asset conversion
     "exchangeNormal": 999.00000//Spot balance
     "checked":"true"
     }
 */
    var coinSymbol :String = ""
    var normal :String = ""
    var exNormal :String = ""
    var lock :String = ""
    var total_balance :String = ""
    var btcValuation :String = ""
    var exchangeNormal :String = ""
    var checked :String = ""
    
    
}

class EXOTCAccountListModel: EXBaseModel {
    var allCoinMap:[CoinMapItem] = []
    var totalBalance :String = ""
    var totalBalanceSymbol :String = ""
    
    //Used in B2C
    var withdrawTip : String = ""//Withdrawal reminder
    var depositTip : String = ""//Recharge prompt
    //B2c returns the field totalBtcValue
   override static func mj_replacedKeyFromPropertyName() -> [AnyHashable : Any]! {
       return ["totalBtcValue":"totalBalance"]
   }
    override func mj_keyValuesDidFinishConvertingToObject() {
        self.allCoinMap = CoinMapItem.mj_objectArray(withKeyValuesArray: self.allCoinMap).copy() as! [CoinMapItem]
    }
    
    func isBalanceEmpty(coinSymbol:String) -> Bool{
        var isEmpty = false
        if self.allCoinMap.count > 0 {
            var coinItem:CoinMapItem?
            for item in self.allCoinMap {
                if item.coinSymbol == coinSymbol {
                    coinItem = item
                    break
                }
            }
            if let selectItem = coinItem {

                let balance = selectItem.normal as NSString
                if !balance.isBig("0") {
                    isEmpty = true
                }
            }
        }
        return isEmpty
    }
    
    func getCoinMap(coinSymbol:String) -> CoinMapItem{
        var coinMap:CoinMapItem = CoinMapItem()
        if self.allCoinMap.count > 0 {
            for item in self.allCoinMap {
                if item.coinSymbol == coinSymbol {
                    coinMap = item
                    break
                }
            }
        }
        return coinMap
    }
}


//For B2C module
class B2CCoinMapItem:EXBaseModel {
    var depositMin: String = ""
    var withdrawOpen: String = ""//Withdrawal switch, 1 on, 0 off
    var normalBalance: String = ""
    var symbol: String = ""
    var isAuth: String = ""
    var withdrawMin: String = ""
    var withdrawMax: String = ""
    var title: String = ""
    var lockBalance: String = ""
    var canWithdrawBalance: String = ""
    var btcValue: String = ""
    var totalBalance: String = ""
    var sort: String = ""
    var depositOpen: String = ""//Recharge
    var showPrecision : String = "2"//accuracy
    
}
class EXB2CAccountListModel: EXBaseModel {
    static let shareInstance : EXB2CAccountListModel = EXB2CAccountListModel()
    
    func getAllCoinMap() -> [B2CCoinMapItem] {
        return allCoinMap
    }
    var allCoinMap:[B2CCoinMapItem] = []
    var totalBtcValue :String = ""
    var totalBalanceSymbol :String = ""
    var withdrawTip : String = ""//Withdrawal reminder
    var depositTip : String = ""//Recharge prompt
   
    override func mj_keyValuesDidFinishConvertingToObject() {
        self.allCoinMap = B2CCoinMapItem.mj_objectArray(withKeyValuesArray: self.allCoinMap).copy() as! [B2CCoinMapItem]
    }
    
    func isBalanceEmpty(coinSymbol:String) -> Bool{
        var isEmpty = false
        if self.allCoinMap.count > 0 {
            var coinItem:B2CCoinMapItem?
            for item in self.allCoinMap {
                if item.symbol == coinSymbol {
                    coinItem = item
                    break
                }
            }
            if let selectItem = coinItem {

                let balance = selectItem.normalBalance as NSString
                if !balance.isBig("0") {
                    isEmpty = true
                }
            }
        }
        return isEmpty
    }
    
    func getCoinMap(coinSymbol:String) -> B2CCoinMapItem{
        var coinMap:B2CCoinMapItem = B2CCoinMapItem()
        if self.allCoinMap.count > 0 {
            for item in self.allCoinMap {
                if item.symbol == coinSymbol {
                    coinMap = item
                    break
                }
            }
        }
        return coinMap
    }
}

