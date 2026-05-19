//
//  EXMarketKlineService.swift
//  Chainup
//
//  Created by liuxuan on 2023/8/20.
//  Copyright © 2023 ChainUP. All rights reserved.
//

import UIKit
import RxSwift
import EXKit
import RxRelay
class EXMarketKlineService: NSObject {
    
    let disposeBag = DisposeBag()
    var entity = CoinMapEntity()
    var depthDatas: [CHKDepthChartItem] = [CHKDepthChartItem]()
    var hasFinishAllHistory:Bool = false
    var historyCount:Int = 0
    var originHistoryModel :EXKlineModel = EXKlineModel()
    var fetchDepthChartDataTimer : Timer?
    var accountType:KLineAccountType = .coin
    var service:EXMarketService {
        get {
            return EXWebSocket.marketService
        }
    }
    var kcandleType :String = "" {
        didSet {
            if kcandleType == EXKlineWsVm.keyLine {
                kcandleType = "1min"
            }
        }
    }
    
    //depth
    //The second parameter is whether to flip the page
    let kLineHistroyDatas : PublishSubject<([KLineChartItem],Bool)> = PublishSubject.init()
    let kLineHistroyFinish : PublishSubject<Bool> = PublishSubject.init()
    let kLineNowDatas : PublishSubject<KLineChartItem> = PublishSubject.init()
    let tickPriceData : PublishSubject<TickItem> = PublishSubject.init()
    let depthData : PublishSubject<([CHKDepthChartItem],Float)> = PublishSubject.init()
    let depthChartData: PublishSubject<([CHKDepthChartItem],String)> = PublishSubject.init()
    let orderHistoryData : PublishSubject<[EXTickDataItem]> = PublishSubject.init()
    let orderNowData : PublishSubject<[EXTickDataItem]> = PublishSubject.init()

    let candleScale:BehaviorRelay<String?> = BehaviorRelay(value: EXMenuSelectionModel().scaleKey)
    
     func handleEvent(_ event: EXMarketWsEvent, _ datas: [String : Any]) {
        if event == .klineHistory {
            guard let klineModel = EXKlineModel.yy_model(with: datas) else { return }
//                EXKlineModel.mj_object(withKeyValues: datas) else { return }
//          // EXLogger.log(level: .debug, scene: .websocket, message:"event == .klineHistory \(datas)")
            if let tick = klineModel.tick {
                kLineNowDatas.onNext(tick)
            }else {
#if DEBUG
//              // EXLogger.log(level: .debug, scene: .websocket, message:"klineHistory datas = \(datas)")
#else
#endif
                handleHistoryLine(model: klineModel)
            }
        }else if event == .ticker {
            guard let tickerModel = EXKlineTictModel.yy_model(with: datas) else { return }
//            EXLogger.log(level: .debug, scene: .websocket, message:".ticker == .tick amount\(tickerModel.tick?.amount)  .tick open  \(tickerModel.tick?.open)  .tick close  \(tickerModel.tick?.close)")
            handleNowPrice(model: tickerModel)
        }else if event == .klineDepth {
            guard let model = ContractWsDepthModel.yy_model(with: datas) else {return}
            handleDepthLine(model: model)
        }else if event == .klineDeal {
            guard let model = EXDealTickModel.yy_model(with: datas) else {return}
            if let tick = model.tick {
                handleNowDeal(tick.data)
            }else {
                handleHistoryDeal(model.data)
            }
        }
    }
    
    func registerCandleScale() {
        
        self.kcandleType = EXMenuSelectionModel().scaleKey
        
        candleScale.asObservable()
            .distinctUntilChanged()
            .subscribe(onNext: {[weak self] scale in
                if let changedScale = scale {
                    debugPrint("--- 》,\(changedScale)")
                    self?.reSubKlineEvents(scale: changedScale)
                }
            }).disposed(by: self.disposeBag)
        
    }
    
    func register() {
        
        registerCandleScale()
        
        service.onwskLineEventCallback
            .subscribe(onNext: {[weak self] (event,datas,symbol) in
                guard let mySelf = self else { return }
                if symbol != mySelf.entity.symbol {
                    return
                }
                mySelf.handleEvent(event, datas)
            }).disposed(by: self.disposeBag)
    }

    func getHistoriesAndTicker() {
        getKlineHistory()
        getTicker()
        //depth
        let depth_channel = "market_\(entity.symbol)_depth_step0"
        let depth_cbid = "KlineDepth\(entity.symbol)"

        let recordItem = WSRecordItem.init(event: "sub", channels: depth_channel, cbid: depth_cbid, asks: "150", bids: "150")
        service.addRecordObject(recordItem: recordItem)
        

        //order
        let order_channel = "market_\(entity.symbol)_trade_ticker"
        let order_cbid = "KlineOrderHistory\(entity.symbol)"

        let recordItemOrder = WSRecordItem.init(event: "req", channels: order_channel, cbid: order_cbid, top: "20")
        service.addRecordObject(recordItem: recordItemOrder)
    }
    
     func reSubKlineEvents(scale:String) {
        //
        hasFinishAllHistory = false
        self.originHistoryModel.data.removeAll()
        let channel = "market_\(entity.symbol)_kline_\(kcandleType)"
        service.cancelTaskSubObject(channel: channel)
        
        self.kcandleType = scale
        self.getKlineHistory()
    }
    
    func getTicker() {
        //ticker
        let ticker_channel = "market_\(entity.symbol)_ticker"
        let ticker_cbid = "klineTicker_\(entity.symbol)"
        let recordItem = WSRecordItem.init(event: "sub", channels: ticker_channel, cbid: ticker_cbid)
        service.addRecordObject(recordItem: recordItem)
    }
    
    func getKlineHistory() {
        //Historical k-line
        let channel = "market_\(entity.symbol)_kline_\(kcandleType)"
        let cb_id = "Kline\(entity.symbol)"
        let recordItem = WSRecordItem.init(event: "req", channels: channel, cbid: cb_id)
        service.addRecordObject(recordItem: recordItem)
    }
    
    
    func reConnectAll() {
        cancelAll()
        getHistoriesAndTicker()
    }

    
    func cancelAll() {
        hasFinishAllHistory = false
        self.originHistoryModel.data.removeAll()
        service.cancellAlltaskObj()
    }
    
     func p_fetchDepthChartData() {
        //15s repeated request mechanism
        //Failure restart mechanism
        //Bind symbol and determine whether it is the current symbol when the data comes back for display
        let requestSymbol = entity.symbol
        appApi.hideAutoLoading()
        appApi.rx.request(
            .depthChart(symbol:requestSymbol))
            .MJObjectMap(EXKlineDepthModel.self,false)
            .retry(3)
            .subscribe(onSuccess: {[weak self] (model) in
                guard let myself = self else {return}
                guard requestSymbol == myself.entity.symbol else {print("requestSymbol don't equal currentSymbol"); return}
                myself.depthChartData.onNext((myself.mapDepthChartData(from: model), String(format: "%f", model.middle)))
            }).disposed(by: self.disposeBag)
    }
}

//MARK: k line history+k line now
extension EXMarketKlineService {
    
    //Previous page ws data
    func wsHistoryKLinePre() {
        let channel = "market_\(entity.symbol)_kline_\(kcandleType)"
        let cb_id = "KlinePrePage\(entity.symbol)"
        if let preItem = self.originHistoryModel.data[safe:0]{
            let recordItem = WSRecordItem.init(event: "req", channels: channel, cbid: cb_id,pageSize: 300, endIndex: preItem.id)
            service.addRecordObject(recordItem: recordItem)
        }
    }
    
    func connectKlineNow() {
        let channel = "market_\(entity.symbol)_kline_\(kcandleType)"
        let cb_id = "KlineNew\(entity.symbol)"
        
        let recordItem = WSRecordItem.init(event: "sub", channels: channel, cbid: cb_id)
        service.addRecordObject(recordItem: recordItem)
    }
    
    
    func handleHistoryLine(model:EXKlineModel){
        if hasFinishAllHistory {
            kLineHistroyFinish.onNext(true)
          // EXLogger.log(level: .debug, scene: .websocket, message:"kLineHistroyFinish")
            return
        }
        if model.data.count > 0 {
            if originHistoryModel.data.count > 0 {
                let firstId = model.data[0].id
                let originFid = originHistoryModel.data[0].id
                if firstId >= originFid {
                    return
                }
            }
        }
        
      // EXLogger.log(level: .debug, scene: .websocket, message:"Data before processing")
      // EXLogger.log(level: .debug, scene: .websocket, message:"Data before count-\(originHistoryModel.data.count) data")
//        if originHistoryModel.data.count > 0{
//            printKlinedata(klineData: [originHistoryModel.data[0],originHistoryModel.data.last!])
//        }else{
          // EXLogger.log(level: .debug, scene: .websocket, message:"originHistoryModel empty data")
//        }
      // EXLogger.log(level: .debug, scene: .websocket, message:"Received Data \(model.data.count) data")
      // EXLogger.log(level: .debug, scene: .websocket, message:"Received Data")
//        if model.data.count > 0{
//            printKlinedata(klineData: [model.data[0],model.data.last!])
//        }else{
          // EXLogger.log(level: .debug, scene: .websocket, message:"Received Data empty")
//        }
        var toPrePage = true
        if model.data.count < 300 { //no more data
            if originHistoryModel.data.count == 0 {//first need connectKlineNow
                connectKlineNow()
            }
            if model.data.count == 0 { //
                if historyCount == 0 {
                    toPrePage = false
                    originHistoryModel.data.removeAll()
                }
            }else{
                originHistoryModel.data.insert(contentsOf: model.data, at: 0)
            }
            
            kLineHistroyDatas.onNext((originHistoryModel.data,toPrePage))
            kLineHistroyFinish.onNext(true)
            hasFinishAllHistory = true
        }else{
            if originHistoryModel.data.count == 0 {//first first need connectKlineNow
                toPrePage = false
                connectKlineNow()
            }
            originHistoryModel.data.insert(contentsOf: model.data, at: 0)
            kLineHistroyDatas.onNext((originHistoryModel.data,toPrePage))
            historyCount += 1

        }
      // EXLogger.log(level: .debug, scene: .websocket, message:"historyCount = \(historyCount)")
      // EXLogger.log(level: .debug, scene: .websocket, message:"Data after processing")
      // EXLogger.log(level: .debug, scene: .websocket, message:"Data after count \(originHistoryModel.data.count) ")
//        if originHistoryModel.data.count > 0{
//            printKlinedata(klineData: [originHistoryModel.data[0],originHistoryModel.data.last!])
//        }else{
          // EXLogger.log(level: .debug, scene: .websocket, message:"originHistoryModel empty")
//        }
    }
    
//    func printKlinedata(klineData:[KLineChartItem]){
//       EXLogger.log(level: .debug, scene: .websocket, message:"klineData  = \(klineData.count)")
//        for datum in klineData {
//            let klineTimeStamp  = String(datum.time)
//            let KT = DateTools.strToTimeString(klineTimeStamp,dateFormat: "yyyy-MM-dd HH:mm:ss")
//            EXLogger.log(level: .debug, scene: .websocket, message:"datum = \(datum.id) kline== \(KT) high = \(datum.high) low =\(datum.low)")
//        }
//    }
}


//MARK: Deep disc mouth
extension EXMarketKlineService {
    
    func handleDepthLine(model:ContractWsDepthModel) {
        self.depthData.onNext((model.depthDatas, model.depthMaxAmount))
    }
}

//MARK: Ticker
extension EXMarketKlineService {
    //Handle the current 24-hour market situation
    func handleNowPrice(model: EXKlineTictModel) {
        if let tickItem = model.tick {
            if let precision = Int(entity.price){
                tickItem.precision = precision
            }
            tickPriceData.onNext(tickItem)
        }
    }
}

//MARK: Transaction Record

extension EXMarketKlineService {
    
    func connectDealNow() {
        let order_channel = "market_\(entity.symbol)_trade_ticker"
        let order_cbid = "KlineOrderNow\(entity.symbol)"
        
        let recordItem = WSRecordItem.init(event: "sub", channels: order_channel, cbid: order_cbid)
        service.addRecordObject(recordItem: recordItem)
    }
    
    //Process historical transactions
    func handleHistoryDeal(_ datas:[EXTickDataItem]){
        connectDealNow()
        orderHistoryData.onNext(datas)
    }
    
    //Processing real-time transactions
    func handleNowDeal(_ item: [EXTickDataItem] ){
        orderNowData.onNext(item)
    }
}

//MARK: Depth Map API
extension EXMarketKlineService {
    
    func startFetchDepthChartDataTimer() {
        
        stopFetchDepthChartDataTimer()
        fetchDepthChartDataTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { _ in
            
            self.p_fetchDepthChartData()
        }
        
        fetchDepthChartDataTimer?.fire()
    }
    
    func stopFetchDepthChartDataTimer() {
        fetchDepthChartDataTimer?.invalidate()
        fetchDepthChartDataTimer = nil
        
    }
    
    func mapDepthChartData(from:EXKlineDepthModel) -> [CHKDepthChartItem] {
        //Filter for data greater than 2, and then map the elements of each array in the array to Double
        let asksArray : [[Double]] = from.asks.filter{$0.count>2}.map{$0.map{NumberHandler.handleDouble($0)}}
        let bidsArray : [[Double]] = from.buys.filter{$0.count>2}.map{$0.map{NumberHandler.handleDouble($0)}}
        
        return mapDepthChartData(from: asksArray, type: .ask) + mapDepthChartData(from: bidsArray.reversed(), type: .bid)
    }
    
    func mapDepthChartData(from:[[Double]],type:CHKDepthChartItemType) -> [CHKDepthChartItem] {
        
        return  from.map { (data) -> CHKDepthChartItem in
            
            let item = CHKDepthChartItem()
            item.value = CGFloat(data[0])
            item.amount = CGFloat(data[1])
            item.depthAmount = CGFloat(data[2])
            item.type = type
            return item
        }
    }
}

