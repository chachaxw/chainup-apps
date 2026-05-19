//
//  EXJournalListModel.swift
//  Chainup
//
//  Created by liuxuan on 2023/5/6.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit

class FinanceItem:EXBaseModel {
    var amount:String  = "" {
        didSet{
            amount = amount.newString()
        }
    }
    var coinSymbol:String =  ""
    var transactionScene:String = ""
//    var createdAtTime:String = ""
    var status_text:String = ""
    var status:String = ""
    var txid:String = ""
    var fee:String = ""
    var label:String = ""
    var confirmDesc:String = ""
    var addressTo:String = ""
    var id:String = ""
    var createTime:String = ""
    var walletTime = ""{
       didSet {
            if walletTime.count > 0 && !walletTime.contains("-") {
              walletTime = DateTools.strToTimeString(walletTime,dateFormat: "yyyy-MM-dd HH:mm:ss")
            }else {
               walletTime = "--"
            }
            
        }
    }
    var updateTime:String = ""{
        didSet {
            if updateTime.count > 0 && !updateTime.contains("-") {
              updateTime = DateTools.strToTimeString(updateTime,dateFormat: "yyyy-MM-dd HH:mm:ss")
            }else {
               updateTime = "--"
            }
            
        }
    }
    var settledAmount = ""//B2c actual received amount
    var transferVoucher = ""//Transfer voucher
    var userName = ""//Name of payee
    var transferType = ""//1 Bank card
    
    var createdAtTime:String = "" {
        didSet {
            if createdAtTime.count > 0 && !createdAtTime.contains("-"){
              createdAtTime = DateTools.strToTimeString(createdAtTime,dateFormat: "yyyy/MM/dd HH:mm:ss")
            }else {
               createdAtTime = "--"
            }
            
        }
    }
}

class EXJournalListModel: EXBaseModel {
    
    var financeList:[FinanceItem] = []
    override func mj_keyValuesDidFinishConvertingToObject() {
        self.financeList = FinanceItem.mj_objectArray(withKeyValuesArray: self.financeList).copy() as! [FinanceItem]
    }
    
}

