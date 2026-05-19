//
//  EXKlineModel.swift
//  Chainup
//
//  Created by liuxuan on 2023/3/14.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import YYModel
class KLineChartItem : NSObject {
    
    @objc var time:Int = 0 //id
    @objc var low:Double = 0
    @objc var high:Double = 0
    @objc var amount:Double = 0
    @objc var close:Double = 0
    @objc var vol:Double = 0
    @objc var ds:String = ""//date
    @objc var tradeId:String = ""//date
    //amplitude
    @objc var amplitude: Double = 0
    @objc var amplitudeRatio: Double = 0
    
    @objc var `id`:Int = 0 {
        didSet {
            time = id
        }
    }
    @objc var open:Double = 0 {
        didSet {
            if open > 0 {
                amplitude = close - open
                amplitudeRatio = amplitude / open * 100
            }
        }
    }
}

class EXKlineModel: NSObject,YYModel {
    @objc var tick :KLineChartItem?
    @objc var data :[KLineChartItem] = []
    @objc var channel :String = ""
    static func modelContainerPropertyGenericClass() -> [String : Any]? {
         return ["data":KLineChartItem.self]
     }

}

