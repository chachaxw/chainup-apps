//
//  EXKlineDetailNewViewModel.swift
//  Chainup
//
//  Created by youbin on 2023/6/14.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import RxSwift
import EXKit

enum EXKlineSocketEvent {
    //KLine coin changes to entity
    case KLineChangedEntity(entity:CoinMapEntity?)
    //Introduction to KLine Coin Pairs
    case KLineCoinBrief(brief: EXIntroduceModel?)
    //KLine Net Worth
    case KLineNetworth(item:(CoinMapEntity,EXETFNetValueModel))
    //KLine Historical Data
    case KLineHistory(items:[KLineChartItem], prePage: Bool = false)
    //KLine historical data loading completed
    case KLineHistoryFinish(finished: Bool)
    //KLine's latest data
    case KLineData(item:KLineChartItem)
    //KLine Price
    case KLinePrice(item:TickItem)
    //KLine depth map data
    case KLineDepthChart(item:(chartItem:[CHKDepthChartItem], price:String))
    //KLine depth data
    case KLineDepth(item:([CHKDepthChartItem],Float,CoinMapEntity?))
    //Order History Data
    case OrderHistory(items:[EXTickDataItem])
    //Order Data
    case OrderData(item:[EXTickDataItem])
}

class EXKlineDetailNewViewModel: EXViewModel {
    
    //Recycling bag
    let disposeBag = DisposeBag()
    
    /// datas
    ///Currency to currency order data
    private(set) var depthDatas: [TransactionDepthEntity]?
    ///Currency to currency transaction data
    private(set) var dealDatas: [EXTickDataItem]?
    ///Maximum depth value of currency pair transactions
    private(set) var maxDepth: Float = 0
    
    
    /// model
    ///Market contract leverage type
    var kDetailType:KLineAccountType = .coin
    
    var isScrolling: Bool = false
    ///Coin to Information Entity
    private(set) var entity:CoinMapEntity?
    ///Selected entity of KLine
    var menuModel: EXMenuSelectionModel = EXMenuSelectionModel()
    ///Currency to Equity Entity
    private(set) var networth: EXETFNetValueModel?
    ///Introduction to Coin Pairs
    private(set) var coinBrief: EXIntroduceModel?
    ///Collection, deletion, and sorting of currency pairs
    private(set) var userSymbolsVm = UserSymbolsVM()
    
    
    // MARK: service
    ///Socket registration ID default false
    private var isSocketRegister: Bool = false
    ///Websocket instance object
    private var wsService: EXMarketKlineService = EXMarketKlineService()
    ///Net value timer
    private var networthTimer: Disposable? = nil
    ///Socket event signal
    private(set) var wsEventSubject: PublishSubject<EXKlineSocketEvent> = PublishSubject()
    
    ///Operating the burying point timing part
   private var trackTimer: Disposable? = nil
   private var kineView: EXKlineDetailTableHeader?
   private var interfaceData:EXInterfaceData = EXInterfaceData.init(page: .kline, action: .subHistory)
   private var track_begin:Date?
   private var track_end:Date?
    
    override init() {
        super.init()
        self.subscriberSocket()
    }
    
    deinit {
        if self.isSocketRegister{
            self.destorySocket()
        }
        self.destoryNetworthTimer()
        self.kineView = nil
    }
    
   
    //MARK: Reset currency to entity
    ///Reset currency to entity
    /// - Parameters:
    ///- entity: currency to entity
    ///- kDetailType: Currency Contract Leverage
    func resetEntity(_ entity: CoinMapEntity, _ kDetailType: KLineAccountType? = nil) {
        self.entity     = entity
        if let kDetailType = kDetailType {
            self.kDetailType = kDetailType
        }
        self.resetData()
        self.registerSocket()
        self.fetchNetworthTimer()
        self.requestCoinBrief()
        self.wsEventSubject.onNext(.KLineChangedEntity(entity: entity))
    }
    
    func resetKLine(_ kline: EXKlineDetailTableHeader) {
        self.kineView = kline
    }
    
    ///Reset data after switching currency pairs
    func resetData()  {
        self.networth    = nil
        self.depthDatas  = nil
        self.dealDatas   = nil
        self.menuModel   = EXMenuSelectionModel()
        self.coinBrief   = nil
        self.maxDepth    = 0
        self.track_begin = nil
        self.track_end   = nil
    }
    
    ////////////////////////////////////////////////////
    //MARK: Net value of currency to currency
    ///Net value (for ETFs)
    func getCoinNetworth() {
        guard let _entity = entity else { return }
        guard _entity.etfOpen == "1" else { return }
        appApi.hideAutoLoading()
        appApi.rx.request(.etfNetValue(base: _entity.coinName, quote: _entity.marketName))
            .MJObjectMap(EXETFNetValueModel.self, false)
            .subscribe(onSuccess: { [weak self] (networth) in
                guard let `self` = self else { return }
                self.networth = networth
                self.wsEventSubject.onNext(.KLineNetworth(item: (_entity, networth)))
            }, onFailure: nil).disposed(by: disposeBag)
        
    }
    
    ///Regularly obtain the net value of currency pairs
    func fetchNetworthTimer() {
        networthTimer?.dispose()
        guard let _entity = entity else { return }
        guard _entity.etfOpen == "1" else { return }
        getCoinNetworth()
        networthTimer = Observable<Int>.interval(.seconds(3), scheduler: MainScheduler.instance).subscribe(onNext: { [weak self] _ in
            guard let `self` = self else { return }
            self.getCoinNetworth()
        })
    }
    
    ///Destroy Get Coin Net Worth Timer
    func destoryNetworthTimer() {
        networthTimer?.dispose()
    }
    
    ////////////////////////////////////////////////////
    //MARK: Socket related operations section
    ///Registration of Coin to Socket
    internal func registerSocket() {
        wsService.cancelAll()
        wsService.entity = entity ?? CoinMapEntity()
        if isSocketRegister == false {
            //Register Socket
            isSocketRegister = true
            wsService.register()
        }
        wsService.getHistoriesAndTicker()
        wsService.startFetchDepthChartDataTimer()
    }
    
    ///Destroy socket
    func destorySocket() {
        wsService.cancelAll()
        wsService.fetchDepthChartDataTimer?.invalidate()
        wsService.fetchDepthChartDataTimer = nil
        isSocketRegister = false
    }
    
    ///Obtain historical KLine data
    func getHistoryKline() {
        guard let _entity = entity else { return }
        if _entity.name.count > 0 {
            trackActionOn()
            wsService.getHistoriesAndTicker()
        }
    }
    func getHistoryKlinePre(){
        self.wsService.wsHistoryKLinePre()
    }
   

    func scoketCandleScale(key: String) {
        wsService.candleScale.accept(key)
    }
    
    ///Reconnect all sockets
    func reconnectSocket() {
        wsService.reConnectAll()
    }
    
    func cancelSocket() {
        wsService.cancelAll()
    }
    
    ///Socket subscription service signal
    func subscriberSocket() {
        //History KLine
        wsService.kLineHistroyDatas.subscribe(onNext: { [weak self] (items, prePage) in
            guard let `self` = self else { return }
            if self.track_end == nil{
                self.track_end = Date()
            }
            self.wsEventSubject.onNext(.KLineHistory(items: items, prePage: prePage))
        }).disposed(by: disposeBag)
        wsService.kLineHistroyFinish.subscribe(onNext: { [weak self] (finished) in
            guard let `self` = self else { return }
            self.wsEventSubject.onNext(.KLineHistoryFinish(finished: finished))
        }).disposed(by: disposeBag)
        
        //Latest data
        wsService.kLineNowDatas.subscribe(onNext: { [weak self] item in
            guard let `self` = self else { return }
            guard self.isScrolling == false else { return }
            self.wsEventSubject.onNext(.KLineData(item: item))
        }).disposed(by: disposeBag)
        
        //timer
        wsService.tickPriceData.subscribe(onNext: { [weak self] item in
            guard let `self` = self else { return }
            guard self.isScrolling == false else { return }
            self.wsEventSubject.onNext(.KLinePrice(item: item))
        }).disposed(by: disposeBag)
        //Depth map of KLine
        wsService.depthChartData.subscribe(onNext: { [weak self] chartData in
            guard let `self` = self else { return }
            guard self.isScrolling == false else { return }
            self.wsEventSubject.onNext(.KLineDepthChart(item: chartData))
        }).disposed(by: disposeBag)
        
        //depth
        wsService.depthData.subscribe(onNext: { [weak self] depthInfo in
            guard let `self` = self else { return }
            guard self.isScrolling == false else { return }
            let max = depthInfo.1
            self.maxDepth = max
            self.wsEventSubject.onNext(.KLineDepth(item: (depthInfo.0, max, self.entity)))
        }).disposed(by: disposeBag)
        
        //Order History Data
        wsService.orderHistoryData.subscribe(onNext:{ [weak self] items in
            guard let `self` = self else { return }
            guard self.isScrolling == false else { return }
            self.wsEventSubject.onNext(.OrderHistory(items: items))
        }).disposed(by: disposeBag)
        //Order Data
        wsService.orderNowData.subscribe(onNext: { [weak self] item in
            guard let `self` = self else { return }
            guard self.isScrolling == false else { return }
            self.wsEventSubject.onNext(.OrderData(item: item))
        }).disposed(by: disposeBag)
    }
    
    ////////////////////////////////////////////////////
    //MARK: Getting an Introduction to Comparison
    func requestCoinBrief() {
        guard let _entity = self.entity else { return }
        guard EXAppConfigManager.sharedInstance.isCoinIntroduceSupport(_entity.coinName) else {
            return
        }
        let item = EXAppMarketManager.sharedInstance.getCoinMapEntityBySymbol(_entity.symbol)
        appApi.hideAutoLoading()
        appApi.rx.request(.coinIntroduce(coinSymbol: item.coinListEntity().name))
            .MJObjectMap(EXIntroduceModel.self)
            .subscribe { [weak self] event in
                guard let `self` = self else { return }
                switch event {
                case .success(let model):
                    self.coinBrief = model
                    self.wsEventSubject.onNext(.KLineCoinBrief(brief: model))
                case .failure(_):
                    break
                }
            }.disposed(by: self.disposeBag)
    }
    
    ////////////////////////////////////////////////////
    //MARK: Operation buried point
    func trackActionOn() {
        self.track_begin = Date()
        self.track_end   = nil
        
        self.trackTimer?.dispose()
        self.trackTimer = Observable<Int>.interval(.seconds(3), scheduler: MainScheduler.asyncInstance).subscribe(onNext: { [weak self] _ in
            guard let `self` = self else { return }
            self.handleInterfaceData()
        })
        
//        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(handleInterfaceData), object: nil)
//        NSObject.perform(#selector(handleInterfaceData), with: nil, afterDelay: 3)
    }
    
    @objc  func handleInterfaceData()  {
        self.trackTimer?.dispose()
        var duration  = ""
        var errorType = "0"
        if let begin = self.track_begin, let end = self.track_end {
            let interval = end.timeIntervalSince(begin)
            let millisecond = CLongLong(round(interval*1000))
            duration = "\(millisecond)"
        }
        
        /*
0: Normal data default
1: Ws is not connected
2: Subscription data not linked
3: The app did not load out
        */
        if let _kine = self.kineView {
            if _kine.klineViewIsEmpty() {
                if wsService.service.isConnecting() == false {
                    errorType = "1"
                } else if _kine.klineView.kLineDatas.count == 0 {
                    errorType = "2"
                } else {
                    errorType = "3"
                }
            }
        }
        interfaceData.errorType = errorType
        interfaceData.duration  = duration
        EXTracking.shared.uploadInterFaceData(model: interfaceData)
    }
    
    
}

