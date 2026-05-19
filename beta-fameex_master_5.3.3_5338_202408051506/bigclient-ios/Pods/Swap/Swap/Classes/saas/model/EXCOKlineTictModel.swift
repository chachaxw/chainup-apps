//
//  EXKlineTictModel.swift
//  Chainup
//
//  Created by liuxuan on 2023/3/18.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

class EXSTickItem :NSObject {
    @objc var amount :String = ""//交易额 English: Transaction volume
    @objc var open :String = "--"//开盘价 English: Opening price
    @objc var high :String = "--"//最高价 English: The highest price
    @objc var vol :String = "--"//交易量 English: Transaction volume
    @objc var low :String = "--"//最低价 English: Lowest price
    @objc var close :String = "--"//收盘价 English: Closing price
    var riseorfail = true//true上升 false下降 English: True rising false falling
    //涨幅 English: Increase in price
    var  originRose = ""
    var roseTxtColor:UIColor = UIColor.ThemekLine.up
    var roseTxt15Color:UIColor = UIColor.ThemekLine.up15
    
    @objc var rose :String = "--" {
        didSet {
            originRose = rose
            let rs = (rose as NSString).doubleValue
            if rs == 0 {
                rose = "0.00"
            }else if rs > 0 {
                roseTxtColor = UIColor.ThemekLine.up
                roseTxt15Color = UIColor.ThemekLine.up15
                rose = "+" + NSString.init(string: rose).multiplyingBy1(
                    "100", decimals:2,holdZero: true)
            }else {
                roseTxtColor = UIColor.ThemekLine.down
                roseTxt15Color = UIColor.ThemekLine.down15
                rose = rose.replacingOccurrences(of: "-", with: "")
                rose = "-" + NSString.init(string: rose).multiplyingBy1(
                    "100", decimals:2,holdZero: true)
                if let r = Int(rose) , r == 0{
                    rose = rose.replacingOccurrences(of: "-", with: "")
                }
            }
//            if rose.hasPrefix("-") {
//                rose = rose.replacingOccurrences(of: "-", with: "")
//                rose = "-" + NSString.init(string: rose).multiplying(by: "100", decimals: 2)
//                if let r = Int(rose) , r == 0{
//                    rose = rose.replacingOccurrences(of: "-", with: "")
//                }
//            }else {
//                rose = "+" + NSString.init(string: rose).multiplying(by: "100", decimals: 2)
//            }
            riseorfail = rose.contains("-") ? false : true
        }
    }
    var precision = 2
    {
        didSet{
            close = (close as NSString).decimalString1(precision)
        }
    }
    var rmb = ""
}

class EXCOKlineTictModel: NSObject {
    
    @objc var tick : EXSTickItem?
    @objc var ts : String?

}

class EXSTransactionDepthEntity: EXCOBaseModel {
    
    var buys = "--"
    
    var buysNum = "--"
    
    var asks = "--"
    
    var asksNum = "--"
    
    var askslength = "0"
    
    var buyslength = "0"
    
    var isSwap = false
    
}


