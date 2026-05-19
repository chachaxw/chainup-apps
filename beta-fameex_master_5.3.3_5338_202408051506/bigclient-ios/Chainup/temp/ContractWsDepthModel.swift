//
//  ContractWsDepthModel.swift
//  Chainup
//
//  Created by liuxuan on 2023/1/24.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit
import YYModel
class TickValue:EXBaseModel {
    var value:String = ""
}

class TickModel:EXBaseModel {
    var asks:[[Any]]=[]
    var buys:[[Any]]=[]
}

class ContractWsDepthModel: EXBaseModel,YYModel{
    
    var channel :String=""
    var data :String=""
    var eventRep :String=""
    var status :String=""
    var tick :TickModel?
    var ts :String=""
    var depthDatas: [CHKDepthChartItem] = [CHKDepthChartItem]()
    var depthMaxAmount:Float = 0
    
    func modelCustomTransform(from dic: [AnyHashable : Any]) -> Bool {
        mj_keyValuesDidFinishConvertingToObject()
        return true
    }
    
    override func mj_keyValuesDidFinishConvertingToObject() {
        guard let ticker = self.tick else { return }
        
        var asksArray : [[Double]] = []
        var bidsArray : [[Double]] = []
        
        for arr in ticker.asks{
            if arr.count > 1{
                asksArray.append([NumberHandler.handleDouble(arr[0]),NumberHandler.handleDouble(arr[1])])
            }
        }
        for arr in ticker.buys {
            if arr.count > 1{
                bidsArray.append([NumberHandler.handleDouble(arr[0]),NumberHandler.handleDouble(arr[1])])
            }
        }
        
        var askTotal:Float = 0
        if asksArray.count > 0{
            let asksItem = asksArray.map { (asks) -> CHKDepthChartItem in
                let item = CHKDepthChartItem()
                item.value = CGFloat(asks[0])
                item.amount = CGFloat(asks[1])
                item.type = .ask
                return item
            }
            
            askTotal = asksItem.reduce(0, { (result:Float, ele:CHKDepthChartItem) -> Float in
                return result + Float(ele.amount)
            })
            
            self.depthDatas.append(contentsOf: asksItem)
        }
        
        var bidsTotal:Float = 0
        if bidsArray.count > 0{
            let bidsItem = bidsArray.map { (asks) -> CHKDepthChartItem in
                let item = CHKDepthChartItem()
                item.value = CGFloat(asks[0])
                item.amount = CGFloat(asks[1])
                item.type = .bid
                return item
            }
            bidsTotal = bidsItem.reduce(0, { (result:Float, ele:CHKDepthChartItem) -> Float in
                return result + Float(ele.amount)
            })
            self.depthDatas.append(contentsOf: bidsItem.reversed())
        }
        self.depthMaxAmount = (askTotal >= bidsTotal) ? askTotal : bidsTotal
        
        
//        ///log
//        for ask in ticker.asks {
//            EXLogger.log(level: .debug, scene: .websocket, message:".klineDepth== ask =\(ask)")
//        }
//        for buy in ticker.buys {
//            EXLogger.log(level: .debug, scene: .websocket, message:".klineDepth== buy =\(buy)")
//        }
//        for item in depthDatas{
//            EXLogger.log(level: .debug, scene: .websocket, message:".klineDepth== item value=\(item.value) item amount=\(item.amount)")
//        }
        
    }
    
}
