//
//  EXContractJournalModel.swift
//  Chainup
//
//  Created by liuxuan on 2023/5/22.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

class ContractTransactionItem : EXBaseModel {
    var address :String = ""
    var sceneStr:String = ""
    var amountStr:String = ""
    var accountBalance:String = ""
    var ctimeL:String = ""
    var showPrecision:String = ""
    var quoteSymbol:String = ""
    
    
    func valueDecimal() ->Int? {
        let tmpPrecision = Int(showPrecision)
        if let precision = tmpPrecision {
            return precision
        }
        return nil
    }
    
    func fmtAmountStr() ->String {
        let precision = self.valueDecimal()
        if precision != nil, !amountStr.isEmpty {
            let nsMargin = amountStr as NSString
            let rst = nsMargin.decimalString(precision!)
            if let realRst = rst {
                return realRst
            }
        }
        return amountStr
    }
    
    func fmtAccountBalance() ->String {
        let precision = self.valueDecimal()
        if precision != nil, !accountBalance.isEmpty {
            let nsMargin = accountBalance as NSString
            return nsMargin.decimalString(precision!)
        }
        return accountBalance
    }

}

class EXContractJournalModel: EXBaseModel {
    var transactionsList:[ContractTransactionItem] = []
    
    override func mj_keyValuesDidFinishConvertingToObject() {
        self.transactionsList = ContractTransactionItem.mj_objectArray(withKeyValuesArray: self.transactionsList).copy() as! [ContractTransactionItem]
    }
    
    

}
