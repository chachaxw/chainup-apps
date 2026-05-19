//
//  EXContractHomePageModel.swift
//  Chainup
//
//  Created by ZYJ on 2023/9/15.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import EXKit
import Swap
class EXContractHomeTickerModel:EXBaseModel {
    var list = [EXContractHomeTicker]()
    override func mj_keyValuesDidFinishConvertingToObject() {
        self.list = EXContractHomeTicker.mj_objectArray(withKeyValuesArray: self.list).copy() as! [EXContractHomeTicker]
    }
}

class EXContractHomeTicker:EXHomeTicker {
    var price = ""
    var contract_name = ""
    var change_rate = ""
    override class func mj_replacedKeyFromPropertyName() -> [AnyHashable : Any]! {
        return [
            "vol":"h_trades_vol"]
    }
    override func mj_keyValuesDidFinishConvertingToObject() {
        close = price
        name = contract_name
        showName = contract_name
        rose = change_rate
        super.mj_keyValuesDidFinishConvertingToObject()
        print("")
    }
}

class EXContractRecommendTicker:EXHomeTicker {
    var instrument_id:Int64 = 0
    var name_zh = ""
    var price = ""
    var change_value = ""
    var change_rate = ""
    
    override class func mj_replacedKeyFromPropertyName() -> [AnyHashable : Any]! {
        return [
            "vol":"24h_trades_vol"]
    }
    
    override func mj_keyValuesDidFinishConvertingToObject() {
        name = name_zh
        showName = name_zh
        contract_id = instrument_id
        close = price
        rose = change_rate
        super.mj_keyValuesDidFinishConvertingToObject()
    }
    
}

class EXContractLanguageModel:EXBaseModel {
    var el_GR = ""
    var en_US = ""
    var ja_Jp = ""
    var ko_KR = ""
    var zh_CN = ""
}

class EXContractRecommendList:EXRecommendList {
    var language = [String:String]()
    
    override class func mj_replacedKeyFromPropertyName() -> [AnyHashable : Any]! {
        return [
            "list":"contracts"]
    }
    override func mj_keyValuesDidFinishConvertingToObject() {
        
        title = language[LanguageHandler.priviatePhoneLanguage] ?? language["en_US"] ?? ""
        
        self.list = EXContractRecommendTicker.mj_objectArray(withKeyValuesArray: self.list).copy() as! [EXContractRecommendTicker]
        
        for (idx,entity) in list.enumerated() {
            entity.app_serial_number = idx + 1
        }
        print("")
    }
}

extension EXTickerModel {
    
     class func initWithBTItemModel(_ model:EXSwapItemModel) -> EXTickerModel {
         let entity = EXTickerModel()
         
         entity.high = model.high
         entity.low = model.low
         entity.close = model.last_px//Latest price
         entity.vol = model.qty24
         entity.rose = model.change_rate
         //What is amount?
         return entity
     }
   
}
extension EXHomeTicker {
    
    func mapToBtItemModel() -> EXSwapItemModel {
        let newModel = EXSwapItemModel()
//        newModel.name = name
        newModel.instrument_id = contract_id
        newModel.last_px = close
        newModel.symbol = name
        return newModel
    }
}
class EXHomeContractModel:EXContractsModel {
    var pricePrecision = 2
    var openPrice = ""
}

