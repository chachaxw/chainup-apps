//
//  EXKlineWsVm.swift
//  Chainup
//
//  Created by liuxuan on 2023/3/14.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

class EXKlineWsVm: NSObject {
    static let keyLine = "Line"
}
//class EXKlineWsVm: NSObject {
//    let disposeBag = DisposeBag()
//    var accountType:KLineAccountType = .coin
//    var entity = CoinMapEntity()
//    static let keyLine = "Line"
//    var depthMaxAmount: Float = 0          //Maximum depth
//    var depthDatas: [CHKDepthChartItem] = [CHKDepthChartItem]()
//    
//    var hasFinishAllHistory:Bool = false
//    var hasOrder:Bool = false
//    var historyCount:Int = 0
//    var originHistoryModel :EXKlineModel = EXKlineModel()
//    
//    var latestPriceTS = ""
//    static let wsKeyPrice = "ws_PriceNow"
//    static let wsKeyNow = "ws_klineNow"
//    static let wsKeyHistory = "ws_klineHistory"
//    static let wsKeyDepthNow = "ws_DepthNow"
//    static let wsHistroyOrder = "ws_historyDeal"
//    static let wsNowOrder = "ws_nowDeal"
//
//    var fetchDepthChartDataTimer : Timer?
    
//    var kcandleType = KlineScaleDefaultKey {
//        didSet {
//            if kcandleType == EXKlineWsVm.keyLine {
//                kcandleType = "1min"
//            }
//        }
//    }//depth
    
//    //The second parameter is whether to flip the page
//    let kLineHistroyDatas : PublishSubject<([KLineChartItem],Bool)> = PublishSubject.init()
//    let kLineNowDatas : PublishSubject<KLineChartItem> = PublishSubject.init()
//    let tickPriceData : PublishSubject<TickItem> = PublishSubject.init()
//    let depthData : PublishSubject<([CHKDepthChartItem],Float)> = PublishSubject.init()
//    let depthChartData: PublishSubject<([CHKDepthChartItem],String)> = PublishSubject.init()
//    let orderHistoryData : PublishSubject<[TransacionEntity]> = PublishSubject.init()
//    let orderNowData : PublishSubject<[TransacionEntity]> = PublishSubject.init()
//
//    let candleScale:BehaviorRelay<String?> = BehaviorRelay(value: EXMenuSelectionModel().scaleKey)
//    let disposebag = DisposeBag()
//
//    func observeScale() {
//        candleScale.asObservable()
//            .distinctUntilChanged()
//            .subscribe(onNext: {[weak self] scale in
//                if let changedScale = scale {
//                    self?.kcandleType = changedScale
//                    self?.disconnectAll()
//                    self?.reconncet()
//                }
//            }).disposed(by: disposebag)
//    }
//    
    
//    //Historical k-line
//    lazy var ws_klineHistory : XWebSocketManager = {
//        let manager = XWebSocketManager()
//        manager.webSocketDelegate = self
//        manager.key = "ws_klineHistory"
//        return manager
//    }()
//    
//    //Real time K-line
//    lazy var ws_klineNow : XWebSocketManager = {
//        let manager = XWebSocketManager()
//        manager.webSocketDelegate = self
//        manager.key = "ws_klineNow"
//        return manager
//    }()
//    
//    //Real time pricing
//    lazy var ws_PriceNow : XWebSocketManager = {
//        let manager = XWebSocketManager()
//        manager.webSocketDelegate = self
//        manager.key = "ws_PriceNow"
//        manager.connectSever(self.getServer())
//        return manager
//    }()
//    
//    //Depth map
//    lazy var ws_DepthNow : XWebSocketManager = {
//        let manager = XWebSocketManager()
//        manager.webSocketDelegate = self
//        manager.key = "ws_DepthNow"
//        manager.connectSever(self.getServer())
//        return manager
//    }()
//    
//    //Historical transactions
//    lazy var ws_historyDeal : XWebSocketManager = {
//        let manager = XWebSocketManager()
//        manager.webSocketDelegate = self
//        manager.key = "ws_historyDeal"
//        manager.connectSever(self.getServer())
//        return manager
//    }()
//    
//    //Real time transaction
//    lazy var ws_nowDeal : XWebSocketManager = {
//        let manager = XWebSocketManager()
//        manager.webSocketDelegate = self
//        manager.key = "ws_nowDeal"
//        manager.connectSever(self.getServer())
//        return manager
//    }()
//    
//    
//    func reconncet() {
//        self.connecKlineWs()//Start Historical K Line
//        self.connectDepth()
//        self.connectprice()
//        self.connectHistoryOrder()
//    }
//    
//    func getServer() -> String {
//        var server = EXNetworkDoctor.sharedManager.getKlineWs()
//        if accountType == .coin || accountType == .lever {
//            server = EXNetworkDoctor.sharedManager.getKlineWs()
//        }
//        return server
//    }
//    
//    func connectDepth() {
//        ws_DepthNow.connectSever(self.getServer())//Request sshendu
//    }
//    
//    func connectHistoryOrder() {
//        
//        ws_historyDeal.connectSever(self.getServer())//Historical transactions
//    }
//
//    func connecKlineWs() {
//        ws_klineHistory.connectSever(self.getServer())//Request Historical K-Line
//    }
//    
//    func connecKlineNow() {
//        ws_klineNow.connectSever(self.getServer())//Request real-time K-line
//    }
//    
//    func connectprice(){
//        ws_PriceNow.connectSever(self.getServer())//price
//    }
//    
//    func disconnectKlineWs() {
//        
//    }
//    
//    func disconnectAll(){
//        self.hasFinishAllHistory = false
//        self.hasOrder = false
//        self.historyCount = 0
//        self.originHistoryModel.data.removeAll()
//        
//        ws_historyDeal.disconnect()
//        ws_DepthNow.disconnect()
//        ws_klineHistory.disconnect()
//        ws_klineNow.disconnect()
//        ws_PriceNow.disconnect()
//        ws_nowDeal.disconnect()
//    }
//}

//extension EXKlineWsVm : DSWebSocketDelegate {
//    
//    func websocketDidConnect(socket: XWebSocketManager) {
//        if socket.key == EXKlineWsVm.wsKeyHistory {//Historical k-line
//            wsHistoryKLineData()
//        }else if socket.key == EXKlineWsVm.wsKeyNow{//Real time K-line
//            wsNowKLineData()
//        }else if socket.key == EXKlineWsVm.wsKeyPrice {//price
//            wsNowPriceData()
//        }else if socket.key == EXKlineWsVm.wsKeyDepthNow {
//            wsDepthNowDate()
//        }else if socket.key == EXKlineWsVm.wsHistroyOrder {
//            wsHistoryDealData()
//        }else if socket.key == EXKlineWsVm.wsNowOrder {
//            wsNowDealData()
//        }
//    }
//    
//    //Request History K Line
//    func wsHistoryKLineData(){
//        let channel = "market_\(entity.symbol)_kline_\(kcandleType)"
//        let cb_id = "Kline\(entity.symbol)"
//        let jsonStr = JSONSerialization.jsonDataFromDictToString(["event" : "req" , "params" : ["channel" : channel , "cb_id" : cb_id]])
//        ws_klineHistory.sendBrandStr(string: jsonStr)
//    }
//    
//    //Previous page ws data
//    func wsHistoryKLinePre() {
//        let channel = "market_\(entity.symbol)_kline_\(kcandleType)"
//        let cb_id = "Kline\(entity.symbol)"
//        let preItem = self.originHistoryModel.data[0]
//        let jsonStr = JSONSerialization.jsonDataFromDictToString(["event" : "req" , "params" : ["channel" : channel , "cb_id" : cb_id, "endIdx":preItem.id , "pageSize":300]])
//        ws_klineHistory.sendBrandStr(string: jsonStr)
//    }
//    
//    //Request the latest K-line
//    func wsNowKLineData(){
//        let channel = "market_\(entity.symbol)_kline_\(kcandleType)"
//        let cb_id = "KlineNow\(entity.symbol)"
//        let jsonStr = JSONSerialization.jsonDataFromDictToString(["event" : "sub" , "params" : ["channel" : channel , "cb_id" : cb_id]])
//        ws_klineNow.sendBrandStr(string: jsonStr)
//    }
//    
//    //Request the current 24-hour market situation
//    func wsNowPriceData(){
//        let channel = "market_\(entity.symbol)_ticker"
//        let cb_id = "mainCell\(entity.symbol)"
//        let jsonStr = JSONSerialization.jsonDataFromDictToString(["event" : "sub" , "params" : ["channel" : channel , "cb_id" : cb_id]])
//        ws_PriceNow.sendBrandStr(string: jsonStr)
//    }
//    
//    func wsDepthNowDate() {
//        let channel = "market_\(entity.symbol)_depth_step0"
//        let cb_id = "KlineDepth\(entity.symbol)"
//        let jsonStr = JSONSerialization.jsonDataFromDictToString(["event" : "sub" , "params" : ["channel" : channel , "cb_id" : cb_id , "asks" : "150" , "bids" : "150"]])
//        ws_DepthNow.sendBrandStr(string: jsonStr)
//    }
//    
//    //Request historical transactions
//    func wsHistoryDealData(){
//        let channel = "market_\(entity.symbol)_trade_ticker"
//        let cb_id = "KlineDownHistory\(entity.symbol)"
//        let jsonStr = JSONSerialization.jsonDataFromDictToString(["event" : "req" , "params" : ["channel" : channel , "cb_id" : cb_id , "top" : "20"]])
//        ws_historyDeal.sendBrandStr(string: jsonStr)
//        
//    }
//    //Request real-time transactions
//    func wsNowDealData(){
//        let channel = "market_\(entity.symbol)_trade_ticker"
//        let cb_id = "KlineDown\(entity.symbol)"
//        let jsonStr = JSONSerialization.jsonDataFromDictToString(["event" : "sub" , "params" : ["channel" : channel , "cb_id" : cb_id]])
//        ws_nowDeal.sendBrandStr(string: jsonStr)
//    }
//    
//    //Process historical transactions
//    func handleHistoryDeal(_ dict : [String : Any]){
//        if hasOrder {
//            return
//        }
//        if let data = dict["data"] as? [[String : Any]]{
//            var arr : [TransacionEntity] = []
//            for item in data{
//                let entity = TransacionEntity()
//                entity.coinMapEntity = self.entity
////                entity.precision = self.precision
//                entity.setEntityWithDict(item)
//                arr.append(entity)
//            }
//            orderHistoryData.onNext(arr)
//            ws_nowDeal.disconnect()
//            ws_nowDeal.connectSever(self.getServer())
//        }else {
//            orderHistoryData.onNext([])
//        }
//        hasOrder = true
//    }
//    
//    //Processing real-time transactions
//    func handleNowDeal(_ dict : [String : Any]){
//        if let tick = dict["tick"] as? [String : Any]{
//            if let data = tick["data"] as? [[String : Any]]{
//                var arr : [TransacionEntity] = []
//
//                if data.count > 0{
//                    for i in data{
//                        let entity = TransacionEntity()
//                        entity.coinMapEntity = self.entity
//                        entity.setEntityWithDict(i)
//                        arr.append(entity)
////                        tableViewRowDatas.insert(entity, at: 0)
////                        tableView.reloadData()
//                    }
//                }
//                orderNowData.onNext(arr)
//            }
//        }
//    }
//    
//    
//    
//    
//    //receive data 
//    func websocketDidReceiveData(socket: XWebSocketManager, data: Data) {
//        let uncompress = NSData.uncompressZippedData(data)
//        if uncompress == nil{
//            return
//        }
//        do{
//            let json = try JSONSerialization.jsonObject(with: uncompress!, options: JSONSerialization.ReadingOptions.allowFragments)
//            if let dict = json as? [String : Any]{
//                if socket.key == "ws_DepthNow"{//depth
//                }
//                if dict.keys.contains("ping"){
//                    let jsonData = try JSONSerialization.data(withJSONObject: ["pong" : dict["ping"]], options: JSONSerialization.WritingOptions.prettyPrinted)
//                    let jsonStr = String.init(data: jsonData, encoding: String.Encoding.utf8)
//                    socket.sendBrandStr(string: jsonStr!)
//                }else{
//                    
//                    if socket.key == EXKlineWsVm.wsKeyHistory ||
//                        socket.key == EXKlineWsVm.wsKeyNow {
//                        guard let klineModel = EXKlineModel.mj_object(withKeyValues: dict) else {
//                            return
//                        }
//                        if socket.key == EXKlineWsVm.wsKeyHistory {//Historical k-line
//                            handleHistoryLine(model:klineModel)
//                        }else if socket.key == EXKlineWsVm.wsKeyNow {//Real time K-line
//                            handleNowKline(model: klineModel)
//                        }
//                    }else if socket.key ==  EXKlineWsVm.wsKeyPrice {//24-hour market
//                        guard let tickModel = EXKlineTictModel.mj_object(withKeyValues: dict), let currentTs = tickModel.ts, (currentTs as NSString).isBig(latestPriceTS) else {
//
////                            print("currentTs =====  is Small latestPriceTS  ")
//                            return
//                        }
//                        
////                        print("currentTs ===== \(currentTs) is Great latestPriceTS =====\(latestPriceTS) curerntTs is Big latestPriceTS \(currentTs.isBig(latestPriceTS))")
//                        latestPriceTS = currentTs as String
//                        handleNowPrice(model: tickModel)
//                    }else if socket.key == "ws_DepthNow"{//depth
//                        handleDepthLine(dict)
//                    }else if socket.key == "ws_historyDeal"{//Historical transactions
//                        handleHistoryDeal(dict)
//                    }else if socket.key == "ws_nowDeal"{//Real time transactions
//                        handleNowDeal(dict)
//                    }
//                }
//            }
//        }catch _ {
//            
//        }
//    }
//    
//    func handleHistoryLine(model:EXKlineModel) {
//        if model.data.count == 0 {
//            return
//        }
//        //All history has been loaded
//        if hasFinishAllHistory {
//            return
//        }
//        //Throw historical data model.data
//        if originHistoryModel.data.count == 0 {
//            originHistoryModel = model
//            kLineHistroyDatas.onNext((model.data,false))
//            connecKlineNow()
//        }else {
//            //The first time the historical data is not enough for the specified 300, there is no need to page forward
//            if originHistoryModel.data.count < 300 {
//                hasFinishAllHistory = true
//                return
//            }
//            let firstId = model.data[0].id
//            let originFid = originHistoryModel.data[0].id
//            //The return value is consistent with the existing value id, and no further processing will be added
//            if firstId >= originFid {
//                return
//            }
//            if historyCount == 1 {
//                hasFinishAllHistory = true
//                return
//            }
//            originHistoryModel.data.insert(contentsOf: model.data, at: 0)
//            kLineHistroyDatas.onNext((originHistoryModel.data,true))
//            historyCount += 1
//        }
//    }
//    
//    func handleNowKline(model:EXKlineModel) {
//        //Throw the current kline data
//        kLineNowDatas.onNext(model.tick!)
//    }
//    
//    //Handle the current 24-hour market situation
//    func handleNowPrice(model: EXKlineTictModel) {
//        if let tickItem = model.tick {
//            if let precision = Int(entity.price){
//                tickItem.precision = precision
//            }
//            tickPriceData.onNext(tickItem)
//        }
//    }
//    
//    func handleDepthLine(_ dict : [String : Any]) {
//        let model = ContractWsDepthModel.mj_object(withKeyValues: dict)
//        guard let depthModel = model else {
//            return
//        }
//        if let ticket = depthModel.tick {
//            self.depthMaxAmount = 0
//            depthDatas.removeAll()
//            var asksArray : [[Double]] = []
//            var bidsArray : [[Double]] = []
//            
//            if ticket.asks.count > 0 {
//                for arr in ticket.asks{
//                    if arr.count > 1{
//                        asksArray.append([NumberHandler.handleDouble(arr[0]),NumberHandler.handleDouble(arr[1])])
//                    }
//                }
//            }
//            if ticket.buys.count > 0 {
//                for arr in ticket.buys {
//                    if arr.count > 1{
//                        bidsArray.append([NumberHandler.handleDouble(arr[0]),NumberHandler.handleDouble(arr[1])])
//                    }
//                }
//            }
//            if asksArray.count > 0{
//                self.decodeDatasToAppend(datas: asksArray, type: .ask)
//            }
//            
//            if bidsArray.count > 0{
//                self.decodeDatasToAppend(datas: bidsArray.reversed(), type: .bid)
//            }
//            
//            self.depthData.onNext((self.depthDatas, self.depthMaxAmount))
//        }
//    }
//    
//    func startFetchDepthChartDataTimer() {
//        
//        fetchDepthChartDataTimer?.invalidate()
//        fetchDepthChartDataTimer = nil
//        
//        fetchDepthChartDataTimer = Timer.scheduledTimer(withTimeInterval: 15, repeats: true) { _ in
//            
//            self.p_fetchDepthChartData()
//        }
//        
//        fetchDepthChartDataTimer?.fire()
//    }
//    
//    private func p_fetchDepthChartData() {
//        //15s repeated request mechanism
//        //Failure restart mechanism
//        //Bind symbol and determine whether it is the current symbol when the data comes back for display
//        let requestSymbol = entity.symbol
//        
//        appApi.rx.request(.depthChart(symbol:requestSymbol)).MJObjectMap(EXKlineDepthModel.self,false)
//            .retry(3).subscribe(onSuccess: {[weak self] (model) in
//                
//                guard let myself = self else {return}
//                guard requestSymbol == myself.entity.symbol else {print("requestSymbol don't equal currentSymbol"); return}
//                myself.depthChartData.onNext((myself.mapDepthChartData(from: model), String(format: "%f", model.middle)))
//                
//            }).disposed(by: self.disposeBag)
//    }
//    
//    func mapDepthChartData(from:EXKlineDepthModel) -> [CHKDepthChartItem] {
//        //Filter for data greater than 2, and then map the elements of each array in the array to Double
//        let asksArray : [[Double]] = from.asks.filter{$0.count>2}.map{$0.map{NumberHandler.handleDouble($0)}}
//        let bidsArray : [[Double]] = from.buys.filter{$0.count>2}.map{$0.map{NumberHandler.handleDouble($0)}}
//
//        return mapDepthChartData(from: asksArray, type: .ask) + mapDepthChartData(from: bidsArray.reversed(), type: .bid)
//    }
//    ///Parsing data
//    func decodeDatasToAppend(datas: [[Double]], type: CHKDepthChartItemType) {
//        var total: Float = 0
//        if datas.count > 0 {
//            for data in datas {
//                let item = CHKDepthChartItem()
//                item.value = CGFloat(data[0])
//                item.amount = CGFloat(data[1])
//                item.type = type
//                
//                self.depthDatas.append(item)
//                
//                total += Float(item.amount)
//            }
//        }
//        
//        if total > self.depthMaxAmount {
//            self.depthMaxAmount = total
//        }
//    }
//    
//    func mapDepthChartData(from:[[Double]],type:CHKDepthChartItemType) -> [CHKDepthChartItem] {
//        
//        return  from.map { (data) -> CHKDepthChartItem in
//            
//            let item = CHKDepthChartItem()
//            item.value = CGFloat(data[0])
//            item.amount = CGFloat(data[1])
//            item.depthAmount = CGFloat(data[2])
//            item.type = type
//            return item
//        }
//    }
//}


