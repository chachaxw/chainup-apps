//
//  EXKlineTictModel.swift
//  Chainup
//
//  Created by liuxuan on 2023/3/18.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit

class TickItem :NSObject {
    @objc var amount :String = ""//Transaction volume
    @objc var open :String = "--"//Opening price
    @objc var high :String = "--"//Maximum price
    @objc var vol :String = "--"//Trading volume
    @objc var low :String = "--"//Lowest price
    @objc var close :String = "--"//Closing price
    var riseorfail = true//True rising false falling
    //Increase
    var  originRose = ""
    var roseTxtColor:UIColor = .Ex.kLine.up1
    
    @objc var rose :String = "--" {
        didSet {
            originRose = rose
            let rs = (rose as NSString).doubleValue
            if rs == 0 {
                rose = "0.00"
                roseTxtColor = .Ex.text3
            }else if rs > 0 {
                roseTxtColor = .Ex.kLine.up1
                rose = "+" + NSString.init(string: rose).multiplyingBy1(
                    "100", decimals:2,holdZero: true)
            }else {
                roseTxtColor = .Ex.kLine.down1
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

class EXKlineTictModel: NSObject {
    
    @objc var tick : TickItem?
    @objc var ts : String?

}

