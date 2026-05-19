//
//  EXSwapSocketManager.swift
//  Chainup
//
//  Created by ZYJ on 2023/10/17.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
//import SwiftEventBus
import RxSwift
import Starscream

let wsWorklog = "contract wsWorklog"

public let NOTI_CONCTRACT_WS_RECONNECTED = "NOTI_CONTRACT_WS_RECONNECTED"
public let NOTI_CONCTRACT_WS_CONNECTED = "NOTI_CONTRACT_WS_CONNECTED"

public class EXSwapSocketManager:EXCOMarketService {
    
    static let `manager` = EXSwapSocketManager()
    open class var shared: EXSwapSocketManager {
        
        return manager
    }
    var currentItemModel : EXSwapItemModel?
    var urlString = ""
    
    func isConnected() -> Bool {
        if let ws = webSocket {
            return ws.isConnected
        }
        return false
    }
   
    public func connectServer(url:String) {
        retryTime = 1
        if url.isEmpty || url == "null" || url == "NULL" {
            return
        }
        self.setupWebSocket(url: url)
        subCribeNet()
        _ = onwskLineEventCallback
            .subscribe(onNext: {[weak self] (event,datas,symbol) in
                guard let channel = datas["channel"] as? String else {return}
                guard let mySelf = self else { return }
                if let s = mySelf.currentItemModel?.ex_contractInfo?.wsSymbol(), !channel.contains("\(s)_") {
                    #if DEBUG
                    #endif
                    return
                }
                EXSwapSocketDataManager.shared.handlerData(event: event, datas: datas, symbol: symbol)
            })
    }
    //更换路线 English: Change route
    @objc override func changeLine(){
        if self.retryTime > 10 {
            EXSwapPlatformSDK.shared.changeWsHostLineCall?()
            self.stopRetryConnection()
        }else {
//            self.reTryConnection()
        }
    }
    
    public override func postWsStatutsNoti(){
        if retryTime > 0 {
            EXLogLine(mark: wsWorklog, message: "recontent success")
//            NotificationCenter.default.post(name: Notification.Name(rawValue: NOTI_CONCTRACT_WS_RECONNECTED), object: nil)
        }
        if retryTime == 0 {
            EXLogLine(mark: wsWorklog, message: "content success")
//            NotificationCenter.default.post(name: Notification.Name(rawValue: NOTI_CONCTRACT_WS_CONNECTED), object: nil)
        }
        NotificationCenter.default.post(name: Notification.Name(rawValue: NOTI_CONCTRACT_WS_RECONNECTED), object: nil)

        
    }

    func wsSymbol() -> String? {
        
        if let contractInfo = currentItemModel?.ex_contractInfo {
        
            return contractInfo.subSymbol
        }
        return nil
    }
    //请求五档数据 English: Request five levels of data
    func currentBuySellFiveData(_ idx:Int = 0){
        
        if let s = wsSymbol() {
            //depth
            let depth_channel = "market_\(s)_depth_step\(idx)"
            
            let recordItem = EXSWSRecordItem.init(event: "sub", channels: depth_channel, cbid:"", asks: "150", bids: "150")
            addRecordObject(recordItem: recordItem)
        }
    }
    
    func getCurrentTicker() {
        
        if let s = wsSymbol() {
            //ticker
            let ticker_channel = "market_\(s)_ticker"

            let recordItem = EXSWSRecordItem.init(event: "sub", channels: ticker_channel, cbid:"")
            addRecordObject(recordItem: recordItem)
        }
    }
    //MARK: 订阅全部 English: MARK: subscribe to all
    func subscribeTickers() {
        let allSwapInfo = EXSwapPublicInfo.shared.getAllSwapInfo()
        
        if let infos = allSwapInfo {
            //market_h$1021_eosusdt_ticker
            // market_contractType_symbol_ticker//
            let tickers = infos.map { (model) -> String in
                return "market_\(model.wsSymbol())_ticker"
            }
            let prepareCoins = tickers.joined(separator: ",")
            EXLogLine(mark: wsWorklog, message: "subscribeTickers: " + "\(prepareCoins)" )
            addwsTaskSub(event:"sub_batch", channel:prepareCoins, cbid: "")
        }
    }
    //MARK: 部分订阅 English: MARK: Partial subscription
    public func subscribeTickers(datas:[EXContractsModel]? = nil, cancel:Bool = false) {
        
        /**
         datas :不传,默认订阅全部 English: Data: No transmission, default subscription to all
         */
//        //print("EXSwapSocketManager =>subscribeTickers")
        var allSwapInfo = EXSwapPublicInfo.shared.getAllSwapInfo() //默认订阅全部 English: Default subscription all
        if datas != nil {
            allSwapInfo = datas!
        }
        if let infos = allSwapInfo {
            //market_h$1021_eosusdt_ticker
            // market_contractType_symbol_ticker//
            let tickers = infos.map { (model) -> String in
                return "market_\(model.wsSymbol())_ticker"
            }
            let prepareCoins = tickers.joined(separator: ",")
           
            if cancel {
                EXLogLine(mark: wsWorklog, message: "cancelSubscribe: " + "\(prepareCoins)" )
                cancelTaskSub(event: "sub_batch", channel: prepareCoins, cbid: "")
            }else{
                EXLogLine(mark: wsWorklog, message: "subscribe: " + "\(prepareCoins)" )
                addwsTaskSub(event:"sub_batch", channel:prepareCoins, cbid: "")
            }
        }
    }
    deinit {
        //print("EXSwapSocketManager =defint")
    }
}


