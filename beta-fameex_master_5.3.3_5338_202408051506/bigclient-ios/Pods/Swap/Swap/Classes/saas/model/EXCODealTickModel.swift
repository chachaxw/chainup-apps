//
//  EXDealTickModel.swift
//  Chainup
//
//  Created by liuxuan on 2023/8/21.
//  Copyright © 2023 ChainUP. All rights reserved.
//

import UIKit
import EXKit


class EXCOTickDataItem:EXCOBaseModel {
    var time = "--"
    var side = "--"
    var price = "--"
    var vol = "--"
    var precision = 2
    var coinMapEntity = EXSCoinMapEntity()
    var ts:String = ""
    
    func modelCustomTransform(from dic: [AnyHashable : Any]) -> Bool {
        if ts.count >= 10{
            time = DateTools.strToTimeString(ts.extStringSub(NSRange.init(location: 0, length: 10)), dateFormat: "HH:mm:ss")
        }
        if let i = Int(coinMapEntity.price){
            price = NSString.init(string: price).decimalString1(i)
        }
        if let i = Int(coinMapEntity.volume){
            vol = NSString.init(string: vol).decimalString1(i)
        }
        return true
    }
}

class EXCODealTickItem:EXCOBaseModel {
    
    var data:[EXCOTickDataItem] = []
    
    static func modelContainerPropertyGenericClass() -> [String : Any]? {
         return ["data":EXCOTickDataItem.self]
    }

}

class EXCODealTickModel: EXCOBaseModel {
    var data:[EXCOTickDataItem] = []
    var tick:EXCODealTickItem?
    var channel:String = ""
    static func modelContainerPropertyGenericClass() -> [String : Any]? {
         return ["data":EXCOTickDataItem.self]
    }

}
