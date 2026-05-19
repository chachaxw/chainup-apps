//
//  EXDealTickModel.swift
//  Chainup
//
//  Created by liuxuan on 2023/8/21.
//  Copyright © 2023 ChainUP. All rights reserved.
//

import UIKit
import EXKit
import YYModel
class EXTickDataItem:EXBaseModel,YYModel {
    var time = "--"
    var side = "--"
    var price = "--"
    var vol = "--"
    var precision = 2
    var coinMapEntity = CoinMapEntity()
    var ts:String = ""
    
    func modelCustomTransform(from dic: [AnyHashable : Any]) -> Bool {
        mj_keyValuesDidFinishConvertingToObject()
        return true
    }
    
    override func mj_keyValuesDidFinishConvertingToObject() {
        if ts.count >= 10{
            time = DateTools.strToTimeString(ts.extStringSub(NSRange.init(location: 0, length: 10)), dateFormat: "HH:mm:ss")
        }
        if let i = Int(coinMapEntity.price){
            price = NSString.init(string: price).decimalString1(i)
        }
        if let i = Int(coinMapEntity.volume){
            vol = NSString.init(string: vol).decimalString1(i)
        }
        
//        EXLogger.log(level: .debug, scene: .websocket, message:".EXTickDataItem== price =\(price) vol =\(vol)")

    }
}

class EXDealTickItem:EXBaseModel {
    
    var data:[EXTickDataItem] = []
    
    static func modelContainerPropertyGenericClass() -> [String : Any]? {
         return ["data":EXTickDataItem.self]
    }
//    override func mj_keyValuesDidFinishConvertingToObject() {
//        self.data = EXTickDataItem.mj_objectArray(withKeyValuesArray: self.data).copy() as! [EXTickDataItem]
//        
//    }
}

class EXDealTickModel: EXBaseModel,YYModel {
    var data:[EXTickDataItem] = []
    var tick:EXDealTickItem?
    var channel:String = ""
    static func modelContainerPropertyGenericClass() -> [String : Any]? {
         return ["data":EXTickDataItem.self]
    }
//    override func mj_keyValuesDidFinishConvertingToObject() {
//        self.data = EXTickDataItem.mj_objectArray(withKeyValuesArray: self.data).copy() as! [EXTickDataItem]
//    }
}
