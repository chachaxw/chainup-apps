//
//  EXMarketWsModel.swift
//  Chainup
//
//  Created by liuxuan on 2023/3/25.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

public class EXCOTickerModel:EXCOBaseModel {
    public var amount:String = ""
    public var close:String = ""
    public var high:String = ""
    public var low:String = ""
    public var open:String = ""
    public var rose:String = ""
    public var ticker:String = ""
    public var vol:String = ""
    public var roseNumber:Float = 0
    public var showRose:String = "--"
    public var color = UIColor.ThemeLabel.colorMedium
    func modelCustomTransform(from dic: [AnyHashable : Any]) -> Bool {
        mj_keyValuesDidFinishConvertingToObject()
        return true
    }
    public override func mj_keyValuesDidFinishConvertingToObject() {
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
}

public class EXCOMarketWsModel: EXCOBaseModel {
    public var channel:String = ""
    var event_rep:String = ""
    var ts:String = ""
    var status:String = ""
    var data:[String:Any] = [:]
    public var tick:EXCOTickerModel = EXCOTickerModel()

}
