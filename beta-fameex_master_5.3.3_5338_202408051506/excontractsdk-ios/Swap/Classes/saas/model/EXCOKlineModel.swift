//
//  EXKlineModel.swift
//  Chainup
//
//  Created by liuxuan on 2023/3/14.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
class EXSKLineChartItem : EXCOBaseModel {
    
    @objc var time:Int = 0 //id
    @objc var low:Double = 0
    @objc var high:Double = 0
    @objc var amount:Double = 0
    @objc var close:Double = 0
    @objc var vol:Double = 0
    @objc var ds:String = ""//日期 English: date
    @objc var tradeId:String = ""//日期 English: date
    @objc open var isSwap: Bool = false //合约 English: contract
    @objc open var buySellPointShow: Bool = false //绘制买卖标记 English: Draw buying and selling marks
    /*
     开多或平空委托：显示为绿色标记，位于 K 线下方 English: Open or flat commission: displayed as a green mark, located below the K-line
     开空或平多委托：显示为红色标记，位于 K 线上方 English: Open or flat commission: displayed as a red marker above the K-line
     只需区分位置即可 English: Just differentiate the location
     */
    @objc open var buySellKlineShowTop: Bool = false // 绘制顶部 English: Draw top
    @objc open var buySellKlineShowBottom: Bool = false // 绘制顶部 English: Draw top
    
    
    //振幅 English: amplitude
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

class EXCOKlineModel: EXCOBaseModel {
    @objc var tick :EXSKLineChartItem?
    @objc var data :[EXSKLineChartItem] = []
    @objc var channel :String = ""
    static func modelContainerPropertyGenericClass() -> [String : Any]? {
         return ["data":EXSKLineChartItem.self]
     }

}

