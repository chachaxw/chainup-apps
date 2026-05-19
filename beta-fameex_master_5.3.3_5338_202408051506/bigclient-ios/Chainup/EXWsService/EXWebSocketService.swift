//
//  EXWebSocketService.swift
//  Chainup
//
//  Created by liuxuan on 2023/6/16.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import Starscream
import RxSwift
import SwiftEventBus
import EXKit
import Swap

let NOTI_WS_RECONNECTED = "NOTI_WS_RECONNECTED"

let NOTI_WS_CONNECTED = "NOTI_WS_CONNECTED"

let NOTI_WS_RECONNECTEDFALL = "NOTI_WS_RECONNECTEDFALL"


public class WSRecordItem :NSObject {
    //Universal key
    var recordKey:String = ""//Unique Record Value
    var event:String = ""//Ws event, sub, sub_ Batch, review, etc
    var cbid:String = ""//currency
    var channels:String = ""//wschannel
    
    //Depth map&transaction record
    var asks:String = ""//Parameters for depth map ws
    var bids:String = ""//Parameters for depth map ws
    var top:String = "" //For transaction records
    
    //K-line detail page, flipping
    var pageSize :Int? //On the K line detail page
    var endIdx :Int?//Flipping ID
    
    init(event:String,channels:String,cbid:String = "",asks:String = "",bids:String = "",top:String = "",pageSize:Int = -1, endIndex:Int = -1 ) {
        self.recordKey = channels + "#" + event + "#" + cbid
        self.event = event
        self.channels = channels
        self.cbid = cbid
        self.asks = asks
        self.bids = bids
        self.top = top
        self.pageSize = pageSize
        self.endIdx = endIndex
    }
    
    func getWsRecordInfo() ->[String:Any] {
        var wsInfo:[String:Any] = [:]
        wsInfo["event"] = self.event
        var params:[String:Any] = [:]
        params["channel"] = self.channels
        if self.cbid.count > 0 {
            params["cb_id"] = self.cbid
        }
        if self.asks.count > 0 {
            params["asks"] = self.asks
        }
        if self.bids.count > 0 {
            params["bids"] = self.bids
        }
        if self.top.count > 0 {
            params["top"] = self.top
        }
        if let pageCount = self.pageSize,pageCount >= 0 {
            params["pageSize"] = pageCount
        }
        if let end = self.endIdx,end >= 0 {
            params["endIdx"] = end
        }
        wsInfo["params"] = params
        return wsInfo
    }
}


public protocol EXWsServiceProtocol {
    
    func setupWebSocket(url:String)
    //Establishing a connection
    func connectServer()
    //Destruction
    func disconnectServer()
    //添加ws订阅任务 //Recently abandoned
    func addwsTaskSub(event:String,channel:String,cbid:String)
    //添加wsRequest任务 //Recently abandoned
    func addwsTaskReq(task:String)
    //Add record recordItem
    func addRecordObject(recordItem:WSRecordItem)
    
    //Pause, unsub, keep the task, and when you come back, you can continue to call sub. Use the scenario, go back to the background, and then go back to the foreground
    func suspend()
    //continue
    func resume()
    //Unsub all subs and remove all existing tasks.
    //Usage scenario: Enter other pages/page destruction
    func cancel()
    
    func reTryConnection()
    
    func stopRetryConnection()
    
    var webSocket:WebSocket? {get}
}

public class EXWebSocket {
    public static let `marketService`:EXMarketService = EXMarketService()
}



public enum EXMarketWsEvent:String {
    case klinePriceNow = "ws_PriceNow"
    case klineNow = "ws_klineNow"
    case klineHistory = "ws_klineHistory"
    case klineDepth = "ws_DepthNow"
    case klineDeal = "ws_historyDeal"
    case homeRecommend = "ws_recommend"
    case marketReview = "ws_marketReview"
    case ticker = "ws_marketTicker"
    
   static func getTickerChannel(symbol:String) -> String {
        return "market_\(symbol)_ticker"
    }
    
   static func getTickerChannelSymbol(channel:String) -> String {
        var ret = ""
        if channel.contains("market_") {
            ret = channel.replacingOccurrences(of: "market_", with: "")
        }
        if channel.contains("_ticker") {
            ret = ret.replacingOccurrences(of: "_ticker", with: "")
        }
        return ret
    }
}

enum EXMarketServiceType{
    case Markets
    case KLine
    case FullScreenKline
}


public class EXMarketService:EXWsServiceProtocol {
    
    var startTime: CFAbsoluteTime?
    var endTime: CFAbsoluteTime?
    
    public func disconnectServer() {
        self.webSocket?.disconnect()
    }
    
    public func reTryConnection() {
        self.webSocket?.connect()
        self.startTime = NSDate.init().timeIntervalSince1970
//        debugPrint("reTryConnection",self.retryTime)
        if self.retryTime > 3 {
            NotificationCenter.default.post(name: Notification.Name(rawValue: NOTI_WS_RECONNECTEDFALL), object: nil)
        }
    }
    
    public func stopRetryConnection() {
        disconnectServer()
    }
    
    var retryTime:Int = 0
    var maxRetry:Int = 10
    
    public var webSocket: WebSocket?
    
    var resumeTasks:[String] = []
    var suspendTasks:[String] = []
    var timerDisposable: Disposable? = nil
    var recordItemMap:[String:WSRecordItem] = [:]
    var onwsEventCallback :PublishSubject<(EXMarketWsEvent,EXMarketWsModel,String)>  = PublishSubject.init()
    var onwskLineEventCallback :PublishSubject<(EXMarketWsEvent,[String:Any],String)>  = PublishSubject.init()
    var latestTicker:[String:Any] = [:]
    var latestSymbol:String = ""
    
    
    var track_begin:Date?
    var track_end:Date?


    public func setupWebSocket(url: String) {
        self.startTime = NSDate.init().timeIntervalSince1970
        guard let serverURL = URL.init(string: url) else {return}
        self.webSocket = WebSocket.init(url: serverURL)
        self.webSocket?.delegate = self
        self.webSocket?.connect()
        self.track_begin = Date()
    }
    ///Connect ws
    public func connectServer() {
        self.setupWebSocket(url: EXNetworkDoctor.sharedManager.getKlineWs())
        //Monitor network status
        SwiftEventBus.onBackgroundThread(self, name: EXReachabilityKey.onNetworkConnected) { (result) in
            self.handleNetworkingConnected()
        }
//        debugPrint("ws=",EXNetworkDoctor.sharedManager.getKlineWs())
    }
    ///Reconnect ws
    public func reconnectServer() {
        guard let ws = webSocket else {return}
        ws.disconnect()
        ws.delegate = nil
        self.setupWebSocket(url: EXNetworkDoctor.sharedManager.getKlineWs())
//        debugPrint("reconnectServer=",EXNetworkDoctor.sharedManager.getKlineWs())
    }
    ///Network state change
    func handleNetworkingConnected() {
//        debugPrint("Processing network connection status ws, when no network changes to network present")
        guard let ws = webSocket else {return}
        if ws.isConnected {
            return
        }else {
            reTryConnection()
        }
    }
    
    func isConnecting() ->Bool {
        guard let ws = webSocket else {return false}
        return ws.isConnected
    }

    ///Start heartbeat
    private func startPong() {
//        debugPrint("Start heartbeat")
        self.timerDisposable?.dispose()
        self.timerDisposable = Observable<Int>.interval(.seconds(10), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] (element) in
                guard let `self` = self else { return }
                self.onPoneAction()
            })
    }
    //Responding to heartbeat
    func onPoneAction() {
        guard let ws = webSocket else {return}
        if self.isConnecting() {
//            debugPrint("ping...ip",self.webSocket?.currentURL ?? "")
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: ["pong" :DateTools.getNowTimeInterval()], options: JSONSerialization.WritingOptions.prettyPrinted)
                guard let jsonStr = String.init(data: jsonData, encoding: String.Encoding.utf8) else {return}
                ws.write(string: jsonStr)
                
            } catch _ {

            }
        }else{
            self.reTryConnection()
        }
        
    }
    
    private func stopPong() {
//        debugPrint("Active heartbeat stop")
        self.timerDisposable?.dispose()
    }

    public func addwsTaskSub(event:String, channel: String, cbid: String) {
        guard let ws = webSocket else {return}
        
        let jsonStr = JSONSerialization.jsonDataFromDictToString(["event" : event , "params" : ["channel" : channel , "cb_id" : cbid]])
        let unsubJson = JSONSerialization.jsonDataFromDictToString(["event" : "un"+event , "params" : ["channel" : channel , "cb_id" : cbid]])
        

        if !resumeTasks.contains(jsonStr) {
            resumeTasks.append(jsonStr)
        }
        if !suspendTasks.contains(unsubJson) {
            suspendTasks.append(unsubJson)
        }
        //Not linked
        if ws.isConnected == false {
            reTryConnection()
        }else {
            ws.write(string: jsonStr)
        }
    }
    //Unsubscribe
    public func cancelTaskSub(event:String, channel: String, cbid: String) {
        guard let ws = webSocket else {return}
        
//        let jsonStr = JSONSerialization.jsonDataFromDictToString(["event" : event , "params" : ["channel" : channel , "cb_id" : cbid]])
        let unsubJson = JSONSerialization.jsonDataFromDictToString(["event" : "un"+event , "params" : ["channel" : channel , "cb_id" : cbid]])
        
//Print ("###############  n  n Subscribing to SUB --> (jsonStr)  n  n  n ##############")

//        if !resumeTasks.contains(jsonStr) {
//            resumeTasks.append(jsonStr)
//        }
//        if !suspendTasks.contains(unsubJson) {
//            suspendTasks.append(unsubJson)
//        }
        //Not linked
        if ws.isConnected == false {
            reTryConnection()
        }else {
            ws.write(string: unsubJson)
        }
    }
    
    
    
    public func addwsTaskReq(task: String) {
        guard let ws = webSocket else {return}
        ws.write(string: task)
    }
    
    //suspend
    public func suspend() {
        self.unsubAll()
    }
    
    //continue
    public func resume() {
        for subJson in resumeTasks {
            webSocket?.write(string: subJson)
        }
    }
    
    //cancel
    public func cancel() {
        self.unsubAll()
        self.clearData()
    }
    
    private func unsubAll() {
        for unsubJson in suspendTasks {
//            debugPrint("################ Unsubscribe ->###############")
//            debugPrint(unsubJson.util_subString(end: 300))
//            debugPrint("#####################################")
            
            webSocket?.write(string: unsubJson)
        }
    }
    
    private func clearData() {
        suspendTasks.removeAll()
        resumeTasks.removeAll()
    }
}


//Dedicated to the K line details page
extension EXMarketService  {
    
    
    public func addRecordObject(recordItem:WSRecordItem) {
        guard let ws = webSocket else {return}
        if recordItem.channels.isEmpty {return}
        
        recordItemMap[recordItem.recordKey] = recordItem
        let jsonStr = JSONSerialization.jsonDataFromDictToString(recordItem.getWsRecordInfo())
//        debugPrint("Subscribing to SUB --> \(jsonStr)")
        //Not linked
        if ws.isConnected == false {
            reTryConnection()
        }else {
            ws.write(string: jsonStr)
        }
    }
    
    public func cancellAlltaskObj() {
        guard let ws = webSocket else {return}
        
        for (_,item) in recordItemMap {
            if item.event == "sub" {
                item.event = "unsub"
            }else if item.event == "sub_batch" {
                item.event = "unsub_batch"
            }
            if item.event != "req" {
                let json = JSONSerialization.jsonDataFromDictToString(item.getWsRecordInfo())
//                debugPrint("################ Unsubscribe ->###############")
//                debugPrint(json)
//                debugPrint("#####################################")
                ws.write(string: json)
            }
        }
        recordItemMap.removeAll()
    }
    
    public func cancelTaskSubObject(channel:String) {
        guard let ws = webSocket else {return}
        if channel.isEmpty {return}
        
        var removedKey:String = ""
        for (key,item) in recordItemMap {
            let recordKey = self.getRecordKey(key: key)
            if recordKey == channel, item.event != "req"{
                removedKey = key
                if item.event == "sub" {
                    item.event = "unsub"
                }else if item.event == "sub_batch" {
                    item.event = "unsub_batch"
                }
                let json = JSONSerialization.jsonDataFromDictToString(item.getWsRecordInfo())
//                debugPrint("################ Unsubscribe ->###############")
//                debugPrint(json)
//                debugPrint("#####################################")
                ws.write(string: json)
            }
        }
        if removedKey.count > 0 {
            recordItemMap.removeValue(forKey: removedKey)
        }
        
    }
    
  
}

//Starcrest Agent

extension EXMarketService : WebSocketDelegate {
    
    public func websocketDidConnect(socket: WebSocketClient) {
        #if DEBUG
        startPong()
        self.endTime = NSDate.init().timeIntervalSince1970
//        debugPrint("ws.DidConnect..",String(self.endTime! - self.startTime!))
        #endif
        startPong()
        self.handleInterfaceData()
        EXTracking.shared.track(event: .wsTrack, info: ["url":self.webSocket?.currentURL.absoluteString ?? ""])
        if retryTime > 0 {
            NotificationCenter.default.post(name: Notification.Name(rawValue: NOTI_WS_RECONNECTED), object: nil)
        }
        if retryTime == 0 {
            NotificationCenter.default.post(name: Notification.Name(rawValue: NOTI_WS_CONNECTED), object: nil)
        }
        //When the link mechanism reconnects and there are tasks in the current task, rewrite the data
        if resumeTasks.count > 0 {
            resume()
        }
        retryTime = 0
    }
     
    public func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [self] in
            #if DEBUG
//            debugPrint("ws websocketDidDisconnect！！！,",error ?? "")
//            debugPrint("")
            #endif
            EXLogger.debug(message:"\(self.webSocket?.currentURL.absoluteString ?? "") error=\(String(describing: error))")
            stopPong()
            EXTracking.shared.track(event: .wsTrackError, info: ["url":self.webSocket?.currentURL.absoluteString ?? ""])
            changeLine()
          
        }
    }
    
    //Sub_ The key of the batch class is in CVS format, all of which are commas
    func getRecordKey(key:String) -> String {
        let splits = key.components(separatedBy: "#")
        if splits.count > 0 {
            return splits[0]
        }
        return ""
    }

    
    public func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        guard let uncompress = NSData.uncompressZippedData(data) else {return}
        
        do {
            let json = try JSONSerialization.jsonObject(with: uncompress, options: JSONSerialization.ReadingOptions.allowFragments)
            if let dataInfo = json as? [String : Any] {
                if dataInfo.keys.contains("ping") {
                    let jsonData = try JSONSerialization.data(withJSONObject: ["pong" : dataInfo["ping"]], options: JSONSerialization.WritingOptions.prettyPrinted)
                    guard let jsonStr = String.init(data: jsonData, encoding: String.Encoding.utf8) else {return}
                    self.webSocket?.write(string: jsonStr)
                }else {
                    guard let channel = dataInfo["channel"] as? String else {return}
                    var keys:[String] = []
                    for (key,item) in recordItemMap {
                        let recordKey = self.getRecordKey(key: key)
                        if item.event == "sub_batch" {
                            let batchKeys = recordKey.components(separatedBy: ",")
                            keys += batchKeys
                        }else {
                            keys.append(recordKey)
                        }
                    }
            
                    if keys.contains(channel){
                        if (channel.contains("depth_step")) {
                            guard let symbol = getChannelSymbol(channel) else {return}
                            self.onwskLineEventCallback.onNext((EXMarketWsEvent.klineDepth,dataInfo,symbol))
                        }else if (channel.contains("trade_ticker")) {
                            guard let symbol = getChannelSymbol(channel.replacingOccurrences(of: "trade_ticker", with: "")) else {return}
                            self.onwskLineEventCallback.onNext((EXMarketWsEvent.klineDeal,dataInfo,symbol))
                        }else if (channel.contains("kline_")) {
                            guard let symbol = getChannelSymbol(channel.replacingOccurrences(of: "kline_", with: "")) else {return}
                            self.onwskLineEventCallback.onNext((EXMarketWsEvent.klineHistory,dataInfo,symbol))
                        }else if (channel.contains("ticker")) {
                            guard let symbol = getChannelSymbol(channel.replacingOccurrences(of: "ticker", with: "")) else {return}
                            self.latestTicker = dataInfo
                            self.latestSymbol = symbol
                            self.onwskLineEventCallback.onNext((EXMarketWsEvent.ticker,dataInfo,symbol))
                        }
                    }else {
                        //The old ones here have not been unified yet, mainly used for market trends
                        guard let wsModel = EXMarketWsModel.mj_object(withKeyValues: dataInfo) else {return}
                        if (channel == "review" || channel == "reviewV2") {
                            EXMarketReqVm.shared().wsReviewData = wsModel.data
                        }else if (channel.contains("ticker")) {
                            guard let symbol = getChannelSymbol(channel) else {return}
                            if let tick = dataInfo["tick"] {
                                EXMarketReqVm.shared().wsReviewData[symbol] = tick
                            }
                            self.onwsEventCallback.onNext((EXMarketWsEvent.ticker,wsModel,symbol))
                        }
                    }
                }
            }
        } catch _ {
            
        }
    }
    
    func fetchLatestTicker() {
        guard let wsModel = EXMarketWsModel.mj_object(withKeyValues: self.latestTicker) else {return}
        if self.latestSymbol.count > 0 {
            self.onwsEventCallback.onNext((EXMarketWsEvent.ticker,wsModel,self.latestSymbol))
        }
    }
    
    func getChannelSymbol(_ channel:String) -> String?{
        do {
            let pattern = "_(.*?)_"
            let regExp = try NSRegularExpression(pattern: pattern, options: .caseInsensitive)
            var results = [String]()
            regExp.enumerateMatches(in: channel, options: [], range: NSMakeRange(0, channel.utf16.count)) { result, flags, stop in
                if let r = result?.range(at: 1), let range = Range(r, in: channel) {
                    results.append(String(channel[range]))
                }
            }
            if results.count  >= 1 {
                let symbol = results[0]
                return symbol
            }
            return nil
        } catch {
            return nil
        }
    }
    
    @objc func changeLine(){
        if self.retryTime > 2 {
            EXWsAlarm.sharedManager.changeLinkForUrgentcy()
            self.stopRetryConnection()
        }else {
            self.retryTime += 1
            self.reTryConnection()
        }
    }
    public func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
         print("ws received message")
    }
}

extension EXMarketService {
    
    func handleInterfaceData() {
        self.track_end = Date()
        if let begin = self.track_begin,let end = self.track_end {
            var duration = ""
            let interfaceData = EXInterfaceData.init(page: .wsService, action: .wsHandShake)
            let interval = end.timeIntervalSince(begin)
            let millisecond = CLongLong(round(interval*1000))
            duration = "\(millisecond)"
            interfaceData.errorType = "0"
            interfaceData.duration = duration
            EXTracking.shared.uploadInterFaceData(model: interfaceData)
            self.track_begin = nil
        }
    }
}


