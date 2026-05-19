//
//  EXSMarketKlineService.swift
//  Chainup
//
//  Created by liuxuan on 2023/8/20.
//  Copyright © 2023 ChainUP. All rights reserved.
//

import UIKit
import RxSwift
import EXKit
import RxRelay
import YYModel

class EXSMarketKlineService: NSObject {
   
    let disposeBag = DisposeBag()
    //todo
    var symbol = ""
    
    var depthDatas: [COKDepthChartItem] = [COKDepthChartItem]()
    var hasFinishAllHistory:Bool = false
    var historyCount:Int = 0
    var originHistoryModel :EXCOKlineModel = EXCOKlineModel()
    var fetchDepthChartDataTimer : Timer?
    var accountType:EXSKLineAccountType = .coin
    var service:EXCOMarketService {
        get {
            return EXCOWebSocket.marketService
        }
    }
    var _kcandleType = ""
    var lastId:Int? //防止数据重复 Prevent data duplication
    var kcandleType :String {
        set {
            _kcandleType = newValue
        }
        get {
            if _kcandleType == EXNewKlineWsVm.keyLine {
                return "1min"
            }else {
                return _kcandleType
            }
        }
        
    }
    
    //深度 English: depth
    //第二个参数为是否翻页 English: The second parameter is whether to flip the page
//    let kLineHistroyDatas : PublishSubject<([EXSKLineChartItem],Bool)> = PublishSubject.init()
//    let kLineHistroyFinish : PublishSubject<Bool> = PublishSubject.init()
    let kLineNowDatas : PublishSubject<EXSKLineChartItem> = PublishSubject.init()
    let tickPriceData : PublishSubject<EXSTickItem> = PublishSubject.init()
    let depthData : PublishSubject<([COKDepthChartItem],Float)> = PublishSubject.init()
    let depthChartData: PublishSubject<([COKDepthChartItem],String)> = PublishSubject.init()
    let orderHistoryData : PublishSubject<[EXCOTickDataItem]> = PublishSubject.init()
    let orderNowData : PublishSubject<[EXCOTickDataItem]> = PublishSubject.init()
    let candleScale: BehaviorRelay<String?> = BehaviorRelay(value: EXCOMenuSelectionModel().scaleKey)
    
    
    /// Flutter K线 English: /Flutter K-line
    /// flutter k线的订阅标识 English: /Subscription identifier for Flutter K-line
    var isFlutterKLine: Bool = false;
    let flutterkLineNowDatas : PublishSubject<[String: Any]> = PublishSubject.init()
    let flutterKLineHistroyDatas : PublishSubject<([String: Any],Bool)> = PublishSubject.init()
    let flutterkLineHistroyFinish : PublishSubject<Bool> = PublishSubject.init()
    let flutterTickPriceData : PublishSubject<[String: Any]> = PublishSubject.init()
    let flutterDepthChartData: PublishSubject<[String: Any]?> = PublishSubject.init()
    let flutterDepthData : PublishSubject<[String: Any]> = PublishSubject.init()
    let flutterOrderHistoryData : PublishSubject<[String: Any]> = PublishSubject.init()
    let flutterOrderNowData : PublishSubject<[String: Any]> = PublishSubject.init()
    

     func handleEvent(_ event: EXCOMarketWsEvent, _ datas: [String : Any]) {
        if event == .klineHistory {
            handleHistoryLine(datas: datas)
        }else if event == .ticker {
//            guard let tickerModel = EXCOKlineTictModel.mj_object(withKeyValues: datas) else { return }
//            handleNowPrice(model: tickerModel)
            flutterTickPriceData.onNext(datas)
        }else if event == .klineDepth {
//            guard let model = EXSContractWsDepthModel.mj_object(withKeyValues: datas) else {return}
//            handleDepthLine(model: model)
            EXLogLine(message: "klineDepth = \(datas)")
            self.flutterDepthData.onNext(datas)
        }else if event == .klineDeal {
            guard let model = EXCODealTickModel.mj_object(withKeyValues: datas) else {return}
            if let tick = model.tick {
//                handleNowDeal(tick.data)
                flutterOrderNowData.onNext(datas)
            }else {
                handleHistoryDeal(model.data,datasMap: datas)
            }
        }
    }
    
    func registerCandleScale() {
        
        self.kcandleType = EXCOMenuSelectionModel().scaleKey
//        candleScale.asObservable()
//            .distinctUntilChanged()
//            .subscribe(onNext: {[weak self] scale in
//                if let changedScale = scale {
//                    EXLogLine(mark:klineWorklog, message:"klinetime ->\(changedScale)")
//                    self?.reSubKlineEvents(scale: changedScale)
//                }
//            }).disposed(by: self.disposeBag)
        
        
        if (self.isFlutterKLine) {
            // 移除观察值变化过滤 English: Remove observation value change filtering
            candleScale.asObservable()
                .subscribe(onNext: {[weak self] scale in
                    if let changedScale = scale {
//                        EXLogger.debug(message: "changedScale = \(changedScale)")
                        self?.reSubKlineEvents(scale: changedScale)
                    }
                }).disposed(by: self.disposeBag)
        } else  {
            candleScale.asObservable()
                .distinctUntilChanged()
                .subscribe(onNext: {[weak self] scale in
                    if let changedScale = scale {
                        //                    debugPrint("时间轴 --- 》,\(changedScale)") English: DebugPrint ("Timeline ---", \ (changedScale) ")
                        self?.reSubKlineEvents(scale: changedScale)
                    }
                }).disposed(by: self.disposeBag)
        }
        
    }
    
    func register() {
        
        registerCandleScale()
        
        service.onwskLineEventCallback
            .subscribe(onNext: {[weak self] (event,datas,symbol) in
                guard let mySelf = self else { return }
                if symbol != mySelf.symbol {
                    return
                }
                mySelf.handleEvent(event, datas)
            }).disposed(by: self.disposeBag)
    }

    func getHistoriesAndTicker() {
        hasFinishAllHistory = false
        getKlineHistory()
        getTicker()
        //depth
        subscribeKlineDepth()
        //order
        subOrder()
    }
    
    func subOrder(){
        let order_channel = "market_\(symbol)_trade_ticker"
        let order_cbid = "KlineOrderHistory\(symbol)"
        let recordItemOrder = EXSWSRecordItem.init(event: "req", channels: order_channel, cbid: order_cbid, top: "20")
        service.addRecordObject(recordItem: recordItemOrder)
    }
    func subscribeKlineDepth() {
        //depth
        let depth_channel = "market_\(symbol)_depth_step0"
        let depth_cbid = "KlineDepth\(symbol)"
        EXLogger.debug(message: "subscribeKlineDepth")
        let recordItem = EXSWSRecordItem.init(event: "sub", channels: depth_channel, cbid: depth_cbid, asks: "150", bids: "150")
        service.addRecordObject(recordItem: recordItem)
    }
    
     func reSubKlineEvents(scale:String) {
        //
        hasFinishAllHistory = false
        self.originHistoryModel.data.removeAll()
        let channel = "market_\(symbol)_kline_\(kcandleType)"
        service.cancelTaskSubObject(channel: channel)
        //先取消上一次的订阅,再订阅本次的 English: Cancel the previous subscription first, and then subscribe to the current one
        self.kcandleType = scale
        self.getKlineHistory()
    }
    
    func getTicker(isSmallKline: Bool = false) {
        //ticker
        let ticker_channel = "market_\(symbol)_ticker"
        let ticker_cbid = "klineTicker_\(symbol)"
        let recordItem = EXSWSRecordItem.init(event: "sub", channels: ticker_channel, cbid: ticker_cbid)
        if isSmallKline{
            recordItem.recordKey += EX_Small_Kline_id
        }
        service.addRecordObject(recordItem: recordItem)
    }
    
    func getKlineHistory(isSmallKline: Bool = false) {
        //历史k线 English: Historical candlestick
        let channel = "market_\(symbol)_kline_\(kcandleType)"
        let cb_id = "Kline\(symbol)"
        let recordItem = EXSWSRecordItem.init(event: "req", channels: channel, cbid: cb_id)
        if isSmallKline{
            recordItem.recordKey += EX_Small_Kline_id
        }
        service.addRecordObject(recordItem: recordItem)
    }
    
    
    func reConnectAll() {
        lastId = nil
        cancelAll()
        getHistoriesAndTicker()
    }

    
    func cancelAll() {
        lastId = nil
        hasFinishAllHistory = false
        self.originHistoryModel.data.removeAll()
        service.cancellAlltaskObj()
    }
    
    func canceSmallKlinel() {
        lastId = nil
        service.cancelSmallKline()
    }
    
     func p_fetchDepthChartData() {
    }
}

//MARK: k线历史 + k线now English: MARK: K-line history+K-line now
extension EXSMarketKlineService {
    
    //上一页ws数据 English: Previous page ws data
    func wsHistoryKLinePre(endIndex: Int) {
        if hasFinishAllHistory == true{
            return
        }
        let channel = "market_\(symbol)_kline_\(kcandleType)"
        let cb_id = "KlinePrePage\(symbol)"
        let recordItem = EXSWSRecordItem.init(event: "req", channels: channel, cbid: cb_id,pageSize: 300, endIndex: endIndex)
        service.addRecordObject(recordItem: recordItem)
    }
    
    func connectKlineNow() {
        let channel = "market_\(symbol)_kline_\(kcandleType)"
        let cb_id = "KlineNew\(symbol)"
        
        let recordItem = EXSWSRecordItem.init(event: "sub", channels: channel, cbid: cb_id)
        service.addRecordObject(recordItem: recordItem)
    }
    
    
    func handleHistoryLine(datas: [String : Any]){
//        EXLogger.debug(message: "kline history = datas\(datas)")
        //ticke
        if let tickData = datas["tick"] as? [String: Any],tickData.isEmpty == false{
            flutterkLineNowDatas.onNext(datas)
            //ticker
            return
        }
        
        //historyData
        var isMore = lastId != nil
        if lastId == nil{
            connectKlineNow()
        }
        if let dicArr = datas["data"] as? [[String: Any]]{
            if let firstDic = dicArr.first{
                if let id = firstDic["id"] as? Int{
                    if id == lastId {
                        return
                    }
                    lastId = id
                }
            }
        }
//        EXLogger.debug(message: "kline send flutterKLineHistroyDatas = \(flutterKLineHistroyDatas) isMore \(isMore)")
        flutterKLineHistroyDatas.onNext((datas, isMore))
    }
}


//MARK: 深度盘口 English: MARK: Deep disc mouth
extension EXSMarketKlineService {
    
    func handleDepthLine(model:EXSContractWsDepthModel) {
        self.depthData.onNext((model.depthDatas, model.depthMaxAmount))
    }
}

//MARK: Ticker
extension EXSMarketKlineService {
    //处理当前24小时行情 English: Handle the current 24-hour market situation
    func handleNowPrice(model: EXCOKlineTictModel) {
        if let tickItem = model.tick {
//            if let precision = Int(entity.price){
//                tickItem.precision = precision
//            }
            tickPriceData.onNext(tickItem)
        }
    }
}

//MARK: 成交记录 English: MARK: Transaction Records

extension EXSMarketKlineService {
    
    func connectDealNow() {
        let order_channel = "market_\(symbol)_trade_ticker"
        let order_cbid = "KlineOrderNow\(symbol)"
        
        let recordItem = EXSWSRecordItem.init(event: "sub", channels: order_channel, cbid: order_cbid)
        service.addRecordObject(recordItem: recordItem)
    }
    
    //处理历史成交 English: Process historical transactions
    func handleHistoryDeal(_ datas:[EXCOTickDataItem], datasMap: [String : Any]){
        connectDealNow()
//        orderHistoryData.onNext(datas)
        flutterOrderHistoryData.onNext(datasMap)

    }
    
    //处理实时交易 English: Processing real-time transactions
    func handleNowDeal(_ item: [EXCOTickDataItem] ){
        orderNowData.onNext(item)
    }
}

//MARK: 深度图API English: MARK: Depth Map API
extension EXSMarketKlineService {
    
    func startFetchDepthChartDataTimer() {
        EXLogger.debug(message: "startFetchDepthChartDataTimer")
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
}

