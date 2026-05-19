//
//  EXFlutterKLineChartViewModel.swift
//  Chainup
//
//  Created by 尤彬 on 2023/5/30.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import RxSwift



enum EXContractSmallFlutterKLineEvent {
    // 最新数据 English: Latest data
    case KLineData(item: String)
    // 历史数据 English: historical data
    case KLineHistory(item: String)
    // 历史数据 English: historical data
    case KLineHistory(item: String, prePage: Bool)
    // 历史数据加载完成 English: Historical data loading completed
    case KLineHistoryFinish(finished: Bool)
    // 币对实体发生变化 English: Changes in currency to entity
    case KLineChangedEntity(entity:EXSwapItemModel?)
    case timeKeyChange(itemKey: String)
    case bigKlineTimeKeyChange(itemKey: String)
    case updateMainIndexVisible
}


class EXContractFlutterKLineChartViewModel: EXViewModel {
    
    private let disposeBag = DisposeBag()
    /// socket注册标识 默认false English: /Socket registration identity defaults to false
    private var isSocketRegister: Bool = false
    var wsService: EXSContractKLineService = EXSContractKLineService()
    /// socket事件信号 English: /Socket event signal
    private(set) var wsEventSubject: PublishSubject<EXContractSmallFlutterKLineEvent> = PublishSubject()
    /// 行情 合约 杠杆类型 English: /Market contract leverage type
    var kDetailType:EXSKLineAccountType = .coin
    /// 币对信息实体 English: /Coin to Information Entity
    var currentItemModel : EXSwapItemModel?
    
    /// 分时图标识 English: /Time sharing chart identification
    private(set) var isLine: Bool = false
    var isExpand: Bool = false
    var scrollEnableSubject: PublishSubject<Bool> = PublishSubject()
    var loadMoreHistoryKLine: PublishSubject<Any> = PublishSubject()
    var reloadKLineSubject:PublishSubject<Bool> = PublishSubject()
    
    override init() {
        super.init()
        wsService.isFlutterKLine = true
        subscriberWS()
    }
    
   private func subscriberWS() {
    
       wsService.flutterKLineHistroyDatas.subscribe(onNext: {[weak self] (items, prePage) in
           guard let self = self else { return }
           let data = try? JSONSerialization.data(withJSONObject: items, options: [])
           let itemString = String(data: data!, encoding: String.Encoding.utf8)
           guard let _itemString = itemString else { return }
           self.wsEventSubject.onNext(.KLineHistory(item: _itemString, prePage: prePage))
       }).disposed(by: self.disposeBag)
       
       wsService.flutterkLineHistroyFinish.subscribe(onNext: {[weak self] (isFinished) in
           guard let self = self else { return }
           self.wsEventSubject.onNext(.KLineHistoryFinish(finished: isFinished))
       }).disposed(by: self.disposeBag)
        
        wsService.flutterkLineNowDatas.subscribe(onNext: { [weak self] item in
            guard let self = self else { return }
            let data = try? JSONSerialization.data(withJSONObject: item, options: [])
            let itemString = String(data: data!, encoding: String.Encoding.utf8)
            guard let _itemString = itemString else { return }
            self.wsEventSubject.onNext(.KLineData(item: _itemString))
        }).disposed(by: disposeBag)
       
       loadMoreHistoryKLine.subscribe(onNext: {[weak self] endIdx in
           guard let self = self else { return }
           if let end = endIdx as? Int{
               self.wsService.wsHistoryKLinePre(endIndex: end)
           }
       }).disposed(by: disposeBag)
       
       reloadKLineSubject.subscribe(onNext: {[weak self] _ in
           guard let self = self else { return }
           self.wsService.connectKlineNow();
       }).disposed(by: disposeBag)
    }

    /// 币对socket的注册 English: /Registration of Coin to Socket
    internal func registerSocket() {
        wsService.cancelAll()
        wsService.currentItemModel = currentItemModel ?? EXSwapItemModel()
        if isSocketRegister == false {
            // 注册socket English: Register socket
            isSocketRegister = true
            wsService.register()
        }
        wsService.getHistoriesAndTicker()
    }
    
    /// 销毁socket English: /Destroy socket
    func destorySocket() {
        wsService.cancelAll()
    }
    
    //MARK: 重置币对实体 English: MARK: Reset Coin to Entity
    /// 重置币对实体 English: /Reset Coin to Entity
    /// - Parameters:
    ///   - entity: 币对实体 English: /- entity: Coin to entity
    ///   - kDetailType: 币币 合约 杠杆 English: /- kDetailType: Currency Contract Leverage
    func resetEntity(_ itemModel: EXSwapItemModel, _ kDetailType: EXSKLineAccountType = .coin) {
        //MARK: fix
        self.currentItemModel     = itemModel
        self.kDetailType = kDetailType
        self.registerSocket()
        self.wsEventSubject.onNext(.KLineChangedEntity(entity: itemModel))
    }
    
    /// 设置K线订阅周期 English: /Set K-line subscription cycle
    /// - Parameter scale: 1min 5min 15min ...
    func setCandleScale(_ scale: String) {
        self.isLine = scale == "Line" ?  true : false
        self.wsService.lastId = nil
        self.wsService.candleScale.accept(scale)
        self.wsEventSubject.onNext(.timeKeyChange(itemKey: scale))
    }
    
}


