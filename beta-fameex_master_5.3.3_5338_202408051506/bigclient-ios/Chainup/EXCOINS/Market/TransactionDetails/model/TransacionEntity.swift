//
//  TransacionEntity.swift
//  Chainup
//
//  Created by zewu wang on 2023/8/27.
//  Copyright © 2023年 zewu wang. All rights reserved.
//

import UIKit
import EXKit

class TransacionEntity: SuperEntity {
    
    var time = "--"
    
    var side = "--"
    
    var price = "--"
    
    var vol = "--"
    
    var precision = 2
    
    var coinMapEntity = CoinMapEntity()
    
    override func setEntityWithDict(_ dict: [String : Any]) {
        super.setEntityWithDict(dict)
        let ts = dictContains("ts")
        if ts.count >= 10{
            time = DateTools.strToTimeString(ts.extStringSub(NSRange.init(location: 0, length: 10)), dateFormat: "HH:mm:ss")
        }
        side = dictContains("side")
        price = dictContains("price")
        if let i = Int(coinMapEntity.price){
            price = NSString.init(string: price).decimalString(i)
        }
        vol = dictContains("vol")
        if let i = Int(coinMapEntity.volume){
            vol = NSString.init(string: vol).decimalString(i)
        }
    }
    
}

//24-hour increase
class TransactionHeadEntity : SuperEntity{
    
    var amount = "--"
    var close = "--"
    var high = "--"
    var low = "--"
    var open = "--"
    var rose = "--"
    var vol = "--"
    var riseorfail = true//True rising false falling
    var precision = 2

    var rmb = ""
    
    override func setEntityWithDict(_ dict: [String : Any]) {
        super.setEntityWithDict(dict)
        amount = dictContains("amount")
        close = NSString.init(string: dictContains("close")).decimalString(precision)
        if dictContains("close") == ""{
            close = "--"
        }
        high = NSString.init(string: dictContains("high")).decimalString(precision)
        if dictContains("high") == ""{
            high = "--"
        }
        low = NSString.init(string: dictContains("low")).decimalString(precision)
        if dictContains("low") == ""{
            low = "--"
        }
        open = NSString.init(string: dictContains("open")).decimalString(precision)
        if dictContains("open") == ""{
            open = "--"
        }
        rose = dictContains("rose")
        if rose.contains("-"){
            rose = rose.replacingOccurrences(of: "-", with: "")
            rose = "-" + NSString.init(string: rose).multiplying(by: "100", decimals: 2)
            if let r = Int(rose) , r == 0{
                rose = rose.replacingOccurrences(of: "-", with: "")
            }
//            rose = "-" + NSString.init(string: rose).multiplyingBy1("100", decimals: 2)
        }else{
//            rose = NSString.init(string: dictContains("rose")).multiplyingBy1("100", decimals: 2)
            rose = NSString.init(string: rose).multiplying(by: "100", decimals: 2)
        }
        if dictContains("rose") == ""{
            rose = "--"
        }
        vol = dictContains("vol")
        
        if dictContains("vol") == ""{
            vol = "--"
        }
        riseorfail = rose.contains("-") ? false : true
    }
    
}

class TransactionDepthEntity: SuperEntity {
    
    var buys = "--"
    
    var buysNum = "--"
    
    var asks = "--"
    
    var asksNum = "--"
    
    var askslength = "0"
    
    var buyslength = "0"
    
}





