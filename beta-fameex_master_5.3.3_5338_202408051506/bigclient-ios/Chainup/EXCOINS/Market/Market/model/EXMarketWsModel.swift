//
//  EXMarketWsModel.swift
//  Chainup
//
//  Created by liuxuan on 2023/3/25.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import Swap
import YYModel
class EXTickerModel:EXBaseModel,YYModel{
    var amount:String = ""
    var close:String = ""
    var high:String = ""
    var low:String = ""
    var open:String = ""
    var rose:String = ""
    var ticker:String = ""
    var vol:String = ""
    var roseNumber:Float = 0
    var showRose:String = "--"
    var color = UIColor.ThemeLabel.colorMedium

    func modelCustomTransform(from dic: [AnyHashable : Any]) -> Bool {
        mj_keyValuesDidFinishConvertingToObject()
        return true
    }
    override func mj_keyValuesDidFinishConvertingToObject() {
        if let roseTmp = Float(rose) {
            if roseTmp == 0{
                showRose = "0.00" + "%"
            }else if roseTmp < 0{
                showRose = rose.replacingOccurrences(of: "-", with: "")
                showRose = "-" + NSString.init(string:showRose).multiplyingBy1("100", decimals: 2,holdZero: true) + "%"
                color = UIColor.ThemekLine.down
            }else{
                showRose = "+" + NSString.init(string:rose).multiplyingBy1("100", decimals: 2,holdZero: true) + "%"
                color = UIColor.ThemekLine.up
            }
            self.roseNumber = roseTmp
        }
    }
    
    class func getNewInstanceFromModel(tick: EXCOTickerModel) -> EXTickerModel {
        let item = EXTickerModel()
        item.amount = tick.amount
        item.close = tick.close
        item.high = tick.high
        item.low = tick.low
        item.open = tick.open
        item.rose = tick.rose
        item.ticker = tick.ticker
        item.vol = tick.vol
        item.roseNumber = tick.roseNumber
        item.showRose = tick.showRose
        item.color = tick.color
        return item
    }
}

class EXMarketWsModel: EXBaseModel,YYModel {
    var channel:String = ""
    var event_rep:String = ""
    var ts:String = ""
    var status:String = ""
    var data:[String:Any] = [:]
    var tick:EXTickerModel = EXTickerModel()
}
