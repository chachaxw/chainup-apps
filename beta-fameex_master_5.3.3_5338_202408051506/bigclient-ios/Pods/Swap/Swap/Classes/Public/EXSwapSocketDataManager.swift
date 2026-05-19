//
//  EXSwapSocketDataManager.swift
//  Chainup
//
//  Created by ZYJ on 2023/10/18.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import RxSwift
import YYModel
class EXSwapSocketDataManager {
    
    static let `manager` = EXSwapSocketDataManager()
    open class var shared: EXSwapSocketDataManager {
        
        return manager
    }
    
    let tickPriceData : PublishSubject<EXCOTickerModel> = PublishSubject.init()//原生APP 左侧买卖深度中间cell的最新价处理 English: The latest price processing for the middle cell of the buying and selling depth on the left side of the native APP
    let depthData : PublishSubject<([COKDepthChartItem],Float)> = PublishSubject.init()//原生APP 左侧买卖深度 English: The depth of buying and selling on the left side of the native app
    

    func handlerData(event: EXCOMarketWsEvent, datas:[String:Any], symbol:String) {
        if event == .ticker {
            if let tickerModel = EXCOMarketWsModel.yy_model(with: datas) {
                tickPriceData.onNext(tickerModel.tick)
           }
       }else if event == .klineDepth {
           guard let model = EXSContractWsDepthModel.yy_model(with: datas) else {return}
            
            let asks = model.tick?.asks.map({ (datas) -> EXOrderBookModel in
                let model = EXOrderBookModel()
                model.px = "\(EXSTools.handleDouble(datas[0]))"
                model.qty = "\(EXSTools.handleDouble(datas[1]))"
                return model
            })
            let bids = model.tick?.buys.map({ (datas) -> EXOrderBookModel in
                let model = EXOrderBookModel()
                model.px = "\(EXSTools.handleDouble(datas[0]))"
                model.qty = "\(EXSTools.handleDouble(datas[1]))"
                return model
            })
            
            EXSwapPublicInfo.shared.setOrderBookAsks(asks)
            EXSwapPublicInfo.shared.setOrderBookBids(bids)
         
            depthData.onNext((model.depthDatas, model.depthMaxAmount))
        }
    }
}




enum ContractKlineSocketEvent {
    // KLine币对实体发生变化 English: KLine Coin Changes Entity
    case KLineChangedEntity(entity:EXSCoinMapEntity?)
    // KLine历史数据 English: KLine Historical Data
    case KLineHistory(items:[EXSKLineChartItem], prePage: Bool = false)
    // KLine历史数据加载完成 English: KLine historical data loading completed
    case KLineHistoryFinish(finished: Bool)
    // KLine最新数据 English: KLine's latest data
    case KLineData(item:EXSKLineChartItem)
    // KLine价格 English: KLine price
    case KLinePrice(item:EXSTickItem)
    // KLine深度图数据 English: KLine depth map data
    case KLineDepthChart(item:(chartItem:[COKDepthChartItem], price:String))
    // KLine深度数据 English: KLine depth data
    case KLineDepth(item:([COKDepthChartItem],Float,EXSCoinMapEntity?))
    // 订单历史数据 English: Order History Data
    case OrderHistory(items:[EXCOTickDataItem])
    // 订单数据 English: Order data
    case OrderData(item:[EXCOTickDataItem])
    case candleHistory(data: String, isMore: Bool = false, isLine: Bool = false)
    case candleData(data: String, isLine: Bool = false)
    case candlePrice(data: String, entity: EXSCoinMapEntity?)
    case candleDepthChart(data: String)
    case candleDepth(data: String)
    case candleOrderHistory(data: String)
    case candleOrderData(data: String)
    case candleCoinBrief(data: String)
    case candleNetworth(data: String)
    case candleETFAct(data: String)
    case buysell(data:String)
}

