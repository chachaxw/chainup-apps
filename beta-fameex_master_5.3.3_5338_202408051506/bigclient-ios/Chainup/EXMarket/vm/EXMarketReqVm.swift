
//
//  EXMarketReqVm.swift
//  Chainup
//
//  Created by liuxuan on 2023/7/27.
//  Copyright © 2023 ChainUP. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import YYModel

class EXMarketReqVm: NSObject {
    
    var currentReviewData:[String:Any] = [:]
    let disposeBag = DisposeBag()
    var rx_wsReviewData = BehaviorRelay<[String:Any]>(value:[:])
    var wsReviewData :[String:Any] {
        get {
            return rx_wsReviewData.value
        }
        set {
            rx_wsReviewData.accept(newValue)
        }
    }
    
    private static var _sharedInstance:EXMarketReqVm?
    //Destroy single instance objects
    class func destroy() {
        _sharedInstance = nil
    }
    
    static let `manager` = EXMarketReqVm()

    open class func shared() -> EXMarketReqVm {
        guard let instance = _sharedInstance else {
            _sharedInstance = EXMarketReqVm()
            return _sharedInstance!
        }
        return instance
    }
    
    func registerPubLicInfoSignal() {
//        print("Enter publicInfoSignal")
        self.fetchReqV2()
//        EXAppMarketManager.sharedInstance.onMarketPublish
//            .subscribe(onNext: {[weak self] (success) in
//                guard let `self` = self else {return}
//                if success {
//                    self.fetchReqV2()
//                }
//            }).disposed(by: self.disposeBag)
    }
    
    func retryFetchReqV2() {
        fetchReqV2()
    }
    
    private func fetchReqV2() {
        if self.wsReviewData.count > 0 {
            return
        }
        
        do {
            var json:[String:Any] = [:]
            let cid = EXAppConfigManager.sharedInstance.companyID()
            if cid.isEmpty {
                json = ["event":"req","params":["channel":"review"]]
            }else {
                json = ["event":"req","params":["channel":"reviewV2","cid":cid]]
            }
            let jsonData = try JSONSerialization.data(withJSONObject:json, options: JSONSerialization.WritingOptions.prettyPrinted)
            if let jsonStr = String.init(data: jsonData, encoding: String.Encoding.utf8) {
                EXWebSocket.marketService.addwsTaskReq(task: jsonStr)
            }
        } catch _ {
            
        }
    }
    
    ///
    private var needUpdateTickerSymbols:Set<String> = .init()
    private var tickerModelCache:[String:EXTickerModel] = [:]
    ///
    func tickerModel(of symbol:String) -> EXTickerModel? {
        if !needUpdateTickerSymbols.contains(symbol) { return tickerModelCache[symbol] }
        guard let data = wsReviewData[symbol] else { return nil }
        let model = EXTickerModel.yy_model(withJSON: data)
        tickerModelCache[symbol] = model
        needUpdateTickerSymbols.remove(symbol)
        return model
    }
    ///
    func updateTicker(for symbol:String, data:Any?) {
        guard let data = data else { return }
        wsReviewData[symbol] = data
        needUpdateTickerSymbols.insert(symbol)
    }
    ///
    func updateTickers(with data:[String:Any]) {
        wsReviewData = data
        needUpdateTickerSymbols = .init(data.keys)
    }
}


