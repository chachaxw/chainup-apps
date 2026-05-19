//
//  EXContractKLineService.swift
//  Chainup
//
//  Created by ZYJ on 2023/11/3.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import RxSwift
import EXKit
// 行情用的socket English: Socket for market use
class EXSContractKLineService: EXSMarketKlineService {
    
    var currentItemModel : EXSwapItemModel? {
        didSet {
            lastId = nil
            if let contractInfo = currentItemModel?.ex_contractInfo {
                symbol = contractInfo.subSymbol// wsSymbol()
//                symbol = contractInfo.wsSymbol()
            }
        }
    }
    //MARK: k线详情页 用了 English: MARK: The k-line detail page has been used
    var queryPublicMarketInfoTimer:Timer?

    let publicMarketData: PublishSubject<(SLPublicMarketInfo,Int64)> = PublishSubject.init()
    
    override var service: EXCOMarketService {
        get {
            return EXSwapSocketManager.shared
        }
    }
    override func register() {
        
        registerCandleScale()

        service.onwskLineEventCallback
            .subscribe(onNext: {[weak self] (event,datas,symbol) in
                guard let mySelf = self else { return }
                guard let channel = datas["channel"] as? String else {return}
                
                if !channel.contains("\(mySelf.symbol)_") {
                    #if DEBUG
                    
//                    EXAlert.showWarning(msg: "\(channel)没有取消订阅") English: EXAlert. showWarning (msg: "\ (channel) not unsubscribed")
                    #endif
                    return
                }
                mySelf.handleEvent(event, datas)
            }).disposed(by: self.disposeBag)
    }
    override func cancelAll() {
        super.cancelAll()
        service.cancellAlltaskObj()
        stopFetchDepthChartDataTimer()
    }
    
    override func p_fetchDepthChartData() {
        let id = currentItemModel?.instrument_id ?? 0
        networkApi.rx.request(.depthChart(id:id ))
            .exs_MJObjectMap(EXCOKlineDepthModel.self,false)
            .retry(3)
            .subscribe(onSuccess: {[weak self] (model) in
                guard let myself = self else {return}
                guard id == myself.currentItemModel?.instrument_id else {print("requestSymbol don't equal currentSymbol");return}
//                myself.depthChartData.onNext((myself.mapDepthChartData(from: model), String(format: "%f", model.middle)))
                myself.flutterDepthChartData.onNext(model.mj_keyValues() as? [String : Any])
            }).disposed(by: self.disposeBag)
    }
}

extension EXSContractKLineService {
    
    func startQueryPublicMarketInfoTimer(instrumentId:Int64, symbol:String) {
        
        stopQueryPublicMarketInfoTimer()
        queryPublicMarketInfoTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true) {[weak self] _ in
//            //print("startQueryPublicMarketInfoTimer")
            self?.p_queryPublicMarketInfo(instrumentId: instrumentId,symbol: symbol)
        }
        
        queryPublicMarketInfoTimer?.fire()
    }
    
    func stopQueryPublicMarketInfoTimer() {
        queryPublicMarketInfoTimer?.invalidate()
        queryPublicMarketInfoTimer = nil
    }
    
    func p_queryPublicMarketInfo(instrumentId:Int64, symbol:String) {
    
        if instrumentId != 0, !symbol.isEmpty {
            networkApi.exs_hideAutoLoading()
            networkApi.rx.request(.publicMarketInfo(symbol: symbol, contractId: instrumentId)).exs_MJObjectMap(SLPublicMarketInfo.self).subscribe(onSuccess: {[weak self] (info) in
               
                self?.publicMarketData.onNext((info,instrumentId))
          
            }).disposed(by: self.disposeBag)
        }
    }
}

