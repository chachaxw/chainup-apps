//
//  SLContractCreatOrder.swift
//  Chainup
//
//  Created by ZYJ on 2023/10/19.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
public class EXContractCreatOrder:EXCOBaseModel {
    
    //合约ID English: Contract ID
    var contractId:Int64 = 0
    //持仓类型(1 全仓，2 仓逐) English: Position type (1 full position, 2 positions one by one)
    var positionType:Int = 0
    //开平仓方向(OPEN 开仓，CLOSE 平仓) English: Direction of opening and closing positions (OPEN opening, Close closing)
    var open = ""
    //买卖方向（BUY 买入，SELL 卖出） English: Buying and selling directions (BUY buying, Sell selling)
    var side = ""
    //订单类型(1 limit， 2 market，3 IOC，4 FOK，5 POST_ONLY) English: Order types (1 limit, 2 market, 3 IOC, 4 FOK, 5 POST-ONLY)
    var type = 1
    //杠杆倍数 English: Leverage ratio
    var leverageLevel:String = ""
    //下单价格(市价单传0) English: Order price (market price transferred to 0)
    var price = ""
    //下单数量(开仓市价单：金额) English: Order quantity (opening market price order: amount)
    var volume = ""
    //是否是条件单 English: Is it a condition sheet
    var isConditionOrder = false
    //触发价格 English: Trigger price
    var triggerPrice:String?
    //有效期 English: Validity period
    var expireTime:String?
    var isOto:Bool {
        return !takerProfitTrigger.isEmpty || !stopLossTrigger.isEmpty
    }
    var takerProfitTrigger = ""
    var takerProfitPrice = "0"
    var takerProfitType = "2"
    var stopLossTrigger = ""
    var stopLossPrice = "0"
    var stopLossType = "2"
    var priceType = ""
    var isCheckLiq = 1// 是否进行爆仓验证（不进行：传0或者不传，进行：传1） English: Do you want to perform stock explosion verification (do not perform: transmit 0 or do not transmit, perform: transmit 1)
    var orderUnit = 0

    /**
     上架需要混淆,增加垃圾代码,如果增加了bool 类型, English: Listing requires confusion and adding junk code. If a bool type is added,
     md5后 服务端会签名校验失败,所以这里指定参数，不影响其他接口 English: After MD5, the server will fail signature verification, so specifying parameters here does not affect other interfaces
     */
    
    func getParams() -> [String: Any] {
        var dic:[String : Any] = [
            "isCheckLiq": self.isCheckLiq,
            "contractId": self.contractId,
            "positionType": self.positionType,
            "open": self.open,
            "side": self.side,
            "type": self.type,
            "leverageLevel": self.leverageLevel,
            "price":self.price,
            "volume": self.volume,
            "isConditionOrder":self.isConditionOrder,
            "isOto": self.isOto,
            "takerProfitTrigger":self.takerProfitTrigger,
            "takerProfitPrice": self.takerProfitPrice,
            "takerProfitType": self.takerProfitType,
            "stopLossTrigger":self.stopLossTrigger,
            "stopLossPrice": self.stopLossPrice,
            "stopLossType": self.stopLossType,
            "priceType": self.priceType,
            "orderUnit": self.orderUnit
        ] 
        if let triggerPrice = triggerPrice {
            dic["triggerPrice"] = triggerPrice
        }
        if let expireTime = expireTime {
            dic["expireTime"] = expireTime
        }
        return dic
    }
    static func generateOrderBy(_ order:EXContractOrderModel) -> EXContractCreatOrder {
        
        let retModel = EXContractCreatOrder()
        retModel.positionType = order.position_type.rawValue
        retModel.contractId = order.instrument_id
        retModel.leverageLevel = order.leverage
        retModel.open = order.parmDescForOpenWay();
        retModel.side = order.parmDescForSideWay();
        retModel.volume = order.qty
        retModel.takerProfitTrigger = order.takerProfitTrigger
        retModel.stopLossTrigger = order.stopLossTrigger
        retModel.priceType =  order.priceType.parmStr
        retModel.isCheckLiq = order.isCheckLiq
        retModel.orderUnit = order.orderUnit
        if let type = EXSwapMarketOrderType.creatBy(category: order.category) {
            
            if let parm = Int(type.parmDesc) {
                
                retModel.type = parm
            }
            var valueToCoin = true // 将价值转化为币 English: Convert value into coins
            switch type {
            case .planOrder(let isMarket):
                retModel.isConditionOrder = true
                retModel.triggerPrice = order.triggerPrice
                retModel.price = isMarket ? "0" : order.exec_px
                retModel.expireTime = EXSwapPlanOrderValidityPeriod.init(rawValue: order.orderCycle)?.parm()
                if isMarket{
                    valueToCoin = false
                }
            case .market:
                retModel.price = "0"
                valueToCoin = false
                break
            default:
                retModel.price = order.px
                break
            }
            
            if order.openOrderType == .value && valueToCoin{ //MARK:市价不需要转 English: MARK: Market price does not need to be converted
//                //print("xxx==  order.qty=\(order.qty)")
                //将价值转化为币 English: Convert value into coins
                if let m = EXSwapPublicInfo.shared.getSwapInfo(order.instrument_id) {
                    retModel.volume = EXFormula.valueToCoin(value: order.qty, price: order.px, contractModel: m)
                }
//                //print("xxx==  order.qty=\(retModel.volume)")
               
            }
            
            
        }
        return retModel
    }
}

class SLContractStopProfitOrStopLossOrder:EXCOBaseModel {

    var triggerType = ""
    //下单价格(市价单传0) English: Order price (market price transferred to 0)
    var price = ""
    //下单数量(开仓市价单：金额) English: Order quantity (opening market price order: amount)
    var volume = ""
    //触发价格 English: Trigger price
    var triggerPrice:String?
    //订单类型(1 limit， 2 market) English: Order type (1 limit, 2 markets)
    var type = 1
    
    var expiredTime:String?
    func getParams() -> [String: Any] {
        var dic:[String : Any] = [
            "triggerType": self.triggerType,
            "price": self.price,
            "volume": self.volume,
            "type": self.type,
        ]
        if let expiredTime = expiredTime {
            dic["expiredTime"] = expiredTime
        }
        if let triggerPrice = triggerPrice {
            dic["triggerPrice"] = triggerPrice
        }
        return dic
    }
    
    
}

public class SLContractCreatStopProfitOrStopLossOrder:EXCOBaseModel {
    
    var contractId:Int64 = 0
    //持仓类型(1 全仓，2 仓逐) English: Position type (1 full position, 2 positions one by one)
    var positionType:Int = 0
    //买卖方向（BUY 买入，SELL 卖出） English: Buying and selling directions (BUY buying, Sell selling)
    var side = ""
    var positionId:Int64 = 0
    var orderListStr = ""
    //杠杆倍数 English: Leverage ratio
    var leverageLevel:String = ""
    var orderUnit: Int{
        let isCoin = EXStoreData.storeBool(forKey: EXS_UNIT_VOL)
        //订单单位：0:张，1:价值，2:币 English: Order unit: 0: sheet, 1: value, 2: coin
        return isCoin ? 2 : 0
    }
    func getParams() -> [String: Any] {
        let dic:[String : Any] = [
            "contractId": self.contractId,
            "positionType": self.positionType,
            "side": self.side,
            "positionId": self.positionId,
            "leverageLevel": self.leverageLevel,
            "orderListStr": self.orderListStr,
            "orderUnit": self.orderUnit
        ]
        return dic
    }
    
    
    static func generateOrderBy(position:EXSwapPositionModel) -> SLContractCreatStopProfitOrStopLossOrder {
        
        let retModel = SLContractCreatStopProfitOrStopLossOrder()
        retModel.positionType = position.position_type.rawValue
        retModel.contractId = position.instrument_id
        retModel.leverageLevel = position.leverageLevel
        retModel.positionId = position.pid
        retModel.side = position.side == .openMore ? "SELL" : "BUY";
        
        return retModel
    }
}


