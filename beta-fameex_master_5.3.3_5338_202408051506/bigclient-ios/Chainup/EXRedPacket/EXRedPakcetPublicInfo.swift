//
//  EXRedPakcetPublicInfo.swift
//  Chainup
//
//  Created by zewu wang on 2023/7/3.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import RxSwift

class EXRedPakcetPublicInfo: NSObject {
    
    var entity = EXRedPakcetPublicInfoEntity()
    
    //MARK: Single Example
    public static var sharedInstance : EXRedPakcetPublicInfo{
        struct Static {
            static let instance : EXRedPakcetPublicInfo = EXRedPakcetPublicInfo()
        }
        return Static.instance
    }
    
    func getData(_ completeHandle: @escaping (() -> ())){
        _ = redPacketApi.rx.request(RedPacketAPIEndPoint.index).MJObjectMap(EXRedPakcetPublicInfoEntity.self).subscribe(onSuccess: {[weak self] (entity) in
            self?.entity = entity
            completeHandle()
        }) { (error) in
            
        }
    }
}

extension EXRedPakcetPublicInfo{
    
    //Obtain all red envelope information
    func getAllRedPacket() -> [EXRedPakcetPublicInfoManagerEntity]{
        return self.entity.symbolList
    }
    
    //Obtain red envelope entities based on symbol
    func getRedPacket(_ coinSymbol : String) -> EXRedPakcetPublicInfoManagerEntity{
        var entity : EXRedPakcetPublicInfoManagerEntity = EXRedPakcetPublicInfoManagerEntity()
        for model in getAllRedPacket(){
            if model.coinSymbol == coinSymbol{
                entity = model
                break
            }
        }
        return entity
    }
    
    //Obtain the first spell luck red envelope
    func getFirstSpellLuck() -> EXRedPakcetPublicInfoManagerEntity?{
        let model = getAllSpellLuck()
        if model.count > 0{
            return model[0]
        }
        return nil
    }
    
    //Obtain the first regular red envelope
    func getNormal() -> EXRedPakcetPublicInfoManagerEntity?{
        let model = getAllNormal()
        if model.count > 0{
            return model[0]
        }
        return nil
    }
    
    //Obtain all spell luck red envelopes
    func getAllSpellLuck() -> [EXRedPakcetPublicInfoManagerEntity]{
        var allSpellLuck : [EXRedPakcetPublicInfoManagerEntity] = []
        for model in getAllRedPacket(){
            if model.randomStatus == "1"{
                allSpellLuck.append(model)
            }
        }
        return allSpellLuck
    }
    
    //Obtain all regular red envelopes
    func getAllNormal() -> [EXRedPakcetPublicInfoManagerEntity]{
        var allNormal : [EXRedPakcetPublicInfoManagerEntity] = []
        for model in getAllRedPacket(){
            if model.generalStatus == "1"{
                allNormal.append(model)
            }
        }
        return allNormal
    }
    
    //Set available balance
    func setAmount(_ amount : String , coinSymbol : String){
        let entity = getRedPacket(coinSymbol)
        entity.amount = amount
    }
    
}

class EXRedPakcetPublicInfoEntity : EXBaseModel{
    
    var defaultTip = "" //Default prompt
    var operationType = ""
    var symbolList : [EXRedPakcetPublicInfoManagerEntity] = []
    override func mj_keyValuesDidFinishConvertingToObject() {
        self.symbolList = EXRedPakcetPublicInfoManagerEntity.mj_objectArray(withKeyValuesArray: self.symbolList).copy() as! [EXRedPakcetPublicInfoManagerEntity]
    }
}

class EXRedPakcetPublicInfoManagerEntity : EXBaseModel{
    var singleAmountMin = "" //Individual minimum limit
    var generalStatus = "" //Is regular red envelope enabled? 0. No 1. Yes
    var amount = "" //User's holdings in this currency
    var coinSymbol = "" //currency
    {
        didSet{
            if let entity = EXAppMarketManager.sharedInstance.getCoinEntity(coinSymbol){
                if let p = Int(entity.showPrecision){
                    precision = p
                }
            }
        }
    }
    var singleAmountMax = ""//Single maximum limit
    var singleCountMax = "" //Maximum copies of a single red envelope
    var randomStatus = "" //Is the red envelope of Pinshouqi enabled? 0. No 1. Yes
    var expiredHour = "" //Red envelope expiration time
    
    var precision = 8//Default precision of 8 bits
    
    //Processing currency holdings
    func fmsAmount() -> String{
        if amount == ""{
            return "0"
        }
        return (amount.decimalNumberWithDouble() as NSString).decimalString1(precision)
    }
    
}

