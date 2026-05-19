//
//  EXOTCManagerEntity.swift
//  Chainup
//
//  Created by zewu wang on 2023/10/12.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

class EXOTCManagerEntity: EXBaseModel {

    var count = ""
    
    var closeHide = "0"//If left blank, default to display all, 0 to display all, 1 to hide and close advertisements
    
    var adList : [EXOTCManagerAdListEntity] = []
    
    override func mj_keyValuesDidFinishConvertingToObject() {
        self.adList = EXOTCManagerAdListEntity.mj_objectArray(withKeyValuesArray: self.adList).copy() as! [EXOTCManagerAdListEntity]
    }
}

class EXOTCManagerPaymentEntity : EXBaseModel{
    var key = ""
    var title = ""
    var icon = ""
    var used : Bool = false
}

class EXOTCManagerAdListEntity : EXBaseModel{
    
    var payments : [EXOTCManagerPaymentEntity] = []
    override func mj_keyValuesDidFinishConvertingToObject() {
        self.payments = EXOTCManagerPaymentEntity.mj_objectArray(withKeyValuesArray: self.payments).copy() as! [EXOTCManagerPaymentEntity]
    }
    
    var minTrade = ""
//    {
//        didSet{
//            let precision = PublicInfoManager.sharedInstance.getRatePrecision()
//            if let price1 = (minTrade.decimalNumberWithDouble() as NSString).decimalString1(precision){
//                minTrade = price1
//            }
//        }
//    }
    var maxTrade = ""
//    {
//        didSet{
//            let precision = PublicInfoManager.sharedInstance.getRatePrecision()
//            if let price1 = (maxTrade.decimalNumberWithDouble() as NSString).decimalString1(precision){
//                maxTrade = price1
//            }
//        }
//    }
    var payCoin = ""//payment currency 
    var volume = ""//total
    var leftVolume = ""//Remaining number of advertisements
    var side = ""//BUY SELL
    var createTime = ""//Creation time
    var price = ""//unit price
//    {
//        didSet{
//            let precision = PublicInfoManager.sharedInstance.getRatePrecision()
//            if let price1 = (price.decimalNumberWithDouble() as NSString).decimalString1(precision){
//                price = price1
//            }
//        }
//    }
    var sell = ""//Turnover volume
    var advertId = ""//Advertising ID
    var status = ""//Advertising status 1 in release 2 in transaction 3 expired 4 closed
    {
        didSet{
            switch status {
            case "1":
                status_str = "otc_text_releaseing".localized()
            case "2":
                status_str = "otc_text_trading".localized()
            case "3":
                status_str = "otc_text_expired".localized()
            case "4":
                status_str = "otc_have_closed".localized()
            default:
                break
            }
        }
    }
    
    var status_str = ""
    
    var coin = ""//currency
    var isHaveOrder = ""//Are there any unfinished orders? 1 Yes 0 No
    var priceRateType = ""//Ratio type of transaction price to market price 0: Custom fixed price 2: Above, 3: Below
    
    //Calculate remaining quantity
    func fmsResidue() -> String{
        var precision = 18
        if let precision1 = Int(EXAppMarketManager.sharedInstance.getCoinEntity(coin)?.showPrecision ?? "18"){
            precision = precision1
        }
        var residueStr = leftVolume
        if let str = (leftVolume as NSString).decimalString1(precision){
            residueStr = str
        }
        return residueStr
    }
    
    override func mj_objectDidFinishConvertingToKeyValues() {
        
    }
    
}

