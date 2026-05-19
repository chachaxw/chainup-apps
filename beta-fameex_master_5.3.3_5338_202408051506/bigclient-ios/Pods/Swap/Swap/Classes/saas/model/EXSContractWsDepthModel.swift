//
//  ContractWsDepthModel.swift
//  Chainup
//
//  Created by liuxuan on 2023/1/24.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit

///Deep data item type
///
///- bid: buyer's depth
///- ask: seller depth
public enum COKDepthChartItemType {
    case bid
    case ask
}
/**
 *  深度数据元素 English: *Deep data elements
 */
open class COKDepthChartItem: NSObject {
    
    open var value: CGFloat = 0                              //数值 English: numerical value
    open var amount: CGFloat = 0                             //数量 English: quantity
    open var depthAmount: CGFloat = 0                        //计算得到的深度 English: Calculated depth
    open var type: COKDepthChartItemType = .bid               //数据类型 English: data type
  
}


class EXSTickModel:EXCOBaseModel {
    var asks:[[Any]]=[]
    var buys:[[Any]]=[]
}

class EXSContractWsDepthModel: EXCOBaseModel {
    
    var channel :String=""
    var data :String=""
    var eventRep :String=""
    var status :String=""
    var tick :EXSTickModel?
    var ts :String=""
    var depthDatas: [COKDepthChartItem] = [COKDepthChartItem]()
    var depthMaxAmount:Float = 0

//    func modelCustomTransform(from dic: [AnyHashable : Any]) -> Bool {
//        mj_keyValuesDidFinishConvertingToObject()
//        return true
//    }
//    override func mj_keyValuesDidFinishConvertingToObject() {
//        guard let ticker = self.tick else { return }
//        
//        var asksArray : [[Double]] = []
//        var bidsArray : [[Double]] = []
//        
//        for arr in ticker.asks{
//            if arr.count > 1{
//                asksArray.append([NumberHandler.handleDouble(arr[0]),NumberHandler.handleDouble(arr[1])])
//            }
//        }
//        for arr in ticker.buys {
//            if arr.count > 1{
//                bidsArray.append([NumberHandler.handleDouble(arr[0]),NumberHandler.handleDouble(arr[1])])
//            }
//        }
//        
//        var askTotal:Float = 0
//        if asksArray.count > 0{
//            let asksItem = asksArray.map { (asks) -> COKDepthChartItem in
//                let item = COKDepthChartItem()
//                item.value = CGFloat(asks[0])
//                item.amount = CGFloat(asks[1])
//                item.type = .ask
//                return item
//            }
//            
//            askTotal = asksItem.reduce(0, { (result:Float, ele:COKDepthChartItem) -> Float in
//                return result + Float(ele.amount)
//            })
//            
//            self.depthDatas.append(contentsOf: asksItem)
//        }
//        
//        var bidsTotal:Float = 0
//        if bidsArray.count > 0{
//            let bidsItem = bidsArray.map { (asks) -> COKDepthChartItem in
//                let item = COKDepthChartItem()
//                item.value = CGFloat(asks[0])
//                item.amount = CGFloat(asks[1])
//                item.type = .bid
//                return item
//            }
//            bidsTotal = bidsItem.reduce(0, { (result:Float, ele:COKDepthChartItem) -> Float in
//                return result + Float(ele.amount)
//            })
//            self.depthDatas.append(contentsOf: bidsItem.reversed())
//        }
//        self.depthMaxAmount = (askTotal >= bidsTotal) ? askTotal : bidsTotal
//    }
    
}
