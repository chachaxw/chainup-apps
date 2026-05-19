//
//  KlineChartData.swift
//  Chainup
//
//  Created by zewu wang on 2023/8/15.
//  Copyright © 2023年 zewu wang. All rights reserved.
//

import UIKit
import EXKit
//import SwiftyJSON

class KlineChartData: SuperEntity,Codable {
    
    var time: Int = 0
    var lowPrice: Double = 0
    var highPrice: Double = 0
    var openPrice: Double = 0
    var closePrice: Double = 0
    var vol: Double = 0
//    var symbol: String = ""
//    var platfom: String = ""
//    var rise: Double = 0
//    var timeType: String = ""
    //amplitude
    var amplitude: Double = 0
    var amplitudeRatio: Double = 0
    var type = "History"
    //"id":1506602880,//Time scale start value
    //"amount":123.1221,//Transaction volume
    //"vol":1212.12211,//Trading volume
    //"open":2233.22,//Opening price
    //"close":1221.11,//Closing price
    //"high":22322.22,//Maximum price
    //"low":2321.22//Lowest price
    override func setEntityWithDict(_ dict: [String : Any]) {
        super.setEntityWithDict(dict)
        if let amount = dict["amount"]{
            
        }
        if type == "History"{
            if let id = dict["id"] as? Int{
                time = id
            }
        }else{
            if let ts = dict["ts"] as? Int{
                let t = ts/1000
                time = t
            }
        }
        
        if let close = dict["close"]{
            self.closePrice = NumberHandler.handleDouble(close)
        }
        if let open = dict["open"]{
            self.openPrice = NumberHandler.handleDouble(open)
        }
        
        if let high = dict["high"]{
            self.highPrice =  NumberHandler.handleDouble(high)
        }
        
        if let low = dict["low"]{
            self.lowPrice =  NumberHandler.handleDouble(low)
        }
        
        if let vol = dict["vol"]{
            self.vol =  NumberHandler.handleDouble(vol)
        }
        if self.openPrice > 0 {
            self.amplitude = self.closePrice - self.openPrice
            self.amplitudeRatio = self.amplitude / self.openPrice * 100
        }

    }
    
    
    
    
    
//    convenience init(json: [JSON]) {
//        self.init()
//        self.time = json[0].intValue
//        self.highPrice = json[2].doubleValue
//        self.lowPrice = json[1].doubleValue
//        self.openPrice = json[3].doubleValue
//        self.closePrice = json[4].doubleValue
//        self.vol = json[5].doubleValue
//        //amplitude
//        if self.openPrice > 0 {
//            self.amplitude = self.closePrice - self.openPrice
//            self.amplitudeRatio = self.amplitude / self.openPrice * 100
//        }
//
//    }
    
}



