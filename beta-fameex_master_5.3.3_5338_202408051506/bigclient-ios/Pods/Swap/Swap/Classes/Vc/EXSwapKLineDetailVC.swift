//
//  EXSwapKLineDetailVC.swift
//  Chainup
//
//  Created by 李超 on 2023/6/7.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import RxSwift
import SwiftEventBus
import EXFlutterKLineKit
import EXKit
import Flutter
import MJExtension
public class EXSwapKLineDetailVC: EXSBaseVC {
   
//    private var invokeChannel: FlutterMethodChannel?
//    private var callbackChannel: FlutterMethodChannel?
//    private var flutterController: FlutterViewController?
    
    
    
    var contractVM=EXContractUserVm()
    var klineScaleKeyChanged = false
//    var newKlineDataCalculated = false //k 线最后一根，不用每次都计算买卖点,每次切换周期算一次就够 English: The last candlestick, no need to calculate the buying and selling points every time, just calculate once for each switching cycle
    var changeItemCallback: ((EXSwapItemModel) -> ())?
    var kineHistoryData: String?//历史订单数据 English: Historical order data
    public var shouldUpdateBS = false
    public var itemModel: EXSwapItemModel? {
        didSet {
            if let contractInfo = itemModel?.ex_contractInfo {
                entity.symbol =  contractInfo.wsSymbol()
                entity.name = contractInfo.showName()
                entity.price = contractInfo.coinResultVo.symbolPricePrecision
                entity.volume = String(EXSTools.decimalValue(px_unit: contractInfo.volumeDecial))
                entity.etfOpen = "1"
                entity.showName = contractInfo.volumeUnit //单位 English: unit
                if shouldUpdateBS{ //第一次会在viewDidAppear 处理 --每次更新币对,请求 English: The first time it will be processed in viewDidAppear - every time a coin pair is updated, a request is made
                    querySellAndBuy()
                }
                if EXFlutterEngine.shared.hasInited {
                    setCoinInfoToFlutter()
                }
                
            }
        }
    }
    func getWSService() ->  EXSContractKLineService{
        return EXSContractKLineService()
    }
    
    var customNaviItem = EXSNaviDrawerView()
    
    //model
    var kDetailType:EXSKLineAccountType = .coin
    public var entity:EXSCoinMapEntity =  EXSCoinMapEntity()
    var menuModel = EXCOMenuSelectionModel.init()
    var lastklineData = EXSKLineChartItem()
    //datas
    var max:Float = 0
    var hasLoadedAllKline = false
    var depthTableViewRowDatas : [EXSTransactionDepthEntity] = []
    var depthChartPrice = ""
    var asksAlllength = "0"//卖总深度 English: Total selling depth
    var buysAlllength = "0"//买总深度 English: Total depth of purchase
    var lastScaleKey = ""
    var isRolling = false
    //service
    var wsService:EXSContractKLineService = EXSContractKLineService()
    var netWorthTimer: Disposable? = nil
    var track_begin:Date?
    var track_end:Date?
    
    /// flutter -> 原生加载更多 K线历史数据 回调信号 English: /Flutter ->Native Load More K-line Historical Data Callback Signal
    var loadMoreCandleHistory: PublishSubject<Any> = PublishSubject()
    var candleOrderHistory: String?

    
     //MARK: lifecycle
    
    deinit {
        wsService.fetchDepthChartDataTimer?.invalidate()
        wsService.fetchDepthChartDataTimer = nil
        wsService.stopQueryPublicMarketInfoTimer()
        
        EXFlutterEngine.shared.destroyInstance()
        
    }
    
    
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        //flutter
        configFlutter()
        configKlineUI()
        flutterCallBack()
        registerSignals()
        queryRate()
    }
    
    
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        EXTracking.shared.track(event: EXSwapTrackingEvent.app_futures_kline_page.rawValue)
        UIViewController.attemptRotationToDeviceOrientation()
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        wsService.cancelAll()
    }
}


//MARK: 监听 English: MARK: Listening
extension EXSwapKLineDetailVC {
    
    //获取汇率 English: Obtain exchange rate
    func queryRate(){
        EXSwapPlatformSDK.shared.getFiatCoinSymbolBack?()
        EXContractNetwork.querySymboRatelist { [weak self] SymbolRate in
            EXSwapPublicInfo.shared.symboRate = SymbolRate
            print("EXSwapPublicInfo.shared.symboRate =\(EXSwapPublicInfo.shared.symboRate)")
            self?.setCoinInfoToFlutter()
        } failure: { err in
            
        }
        
    }
    
    func querySellAndBuy(){
        
        if self.kineHistoryData == nil { //没有数据，需要请求 English: No data, request needed
            EXContractNetwork.getHistoryOrderKlineData(contractId: itemModel?.instrument_id ?? 0) { [weak self] list in
                self?.sellAndBuyToFlutter(model: list)
            } failure: { _ in

            }
        }else{
            self.dealWithKLine(with: .buysell(data: self.kineHistoryData!))

        }
    }
    
    
    func sellAndBuyToFlutter(model: EXKlineOrderList){
        let newDic = model.orderList.map { item in
            var newItem = [String: Any]()
            if let side = item["side"] as? String{
                let isBuy = side == "BUY"
                newItem["isBuy"] = isBuy
            }
            if let price = item["price"] as? Int{
               let priceStr = String(price)
                newItem["price"] = priceStr
            }else{
                newItem["price"] = "0"
            }
           
            
            if let vol = item["volume"] as? Double{
               let volStr = String(vol)
                newItem["vol"] = volStr
            }else{
                newItem["vol"] = "0"
            }
            
            if let ctime = item["ctime"] as? Int{
//                print("ctime = \(ctime)")
                newItem["ctime"] = ctime
//                let ordertime = EXSDateTools.strToTimeString("\(ctime)")
//                print("ordertime = \(ordertime)")
            }
            return newItem
        }
        let dic = ["KlineBuySellData": newDic]

        guard let jsonString = dic.toJsonString() else { return }
//        print("jsonString = \(jsonString)")
        self.kineHistoryData = jsonString
        self.dealWithKLine(with: .buysell(data: jsonString))
        
    }

    func registerSignals() {
        handleNotifi()
    }
    
    func handleScale(key:String) {
        if lastScaleKey == key {
            return
        }
        self.trackActionOn()
        self.hasLoadedAllKline = false
        self.menuModel.scaleKey = key
        lastScaleKey = key
        self.wsService.candleScale.accept(key)
    }
    

    
    func handlekLineWs() {
        //先订阅历史k线/历史订单/深度 + ticker(ticker可以从其他页面传过来,再订阅) English: First subscribe to the historical K-line/historical orders/depth+ticket (the ticket can be uploaded from other pages before subscribing)
        //后定于k线最新/订单最新 English: Set the latest K line/latest order
        wsService.isFlutterKLine = true
        wsService.currentItemModel = itemModel
        wsService.register()
        wsService.getTicker()
        wsService.subOrder()
        wsService.subscribeKlineDepth()
        wsService.startFetchDepthChartDataTimer()
        if let instrument_id = itemModel?.instrument_id, let symbol = itemModel?.symbol {
            wsService.startQueryPublicMarketInfoTimer(instrumentId: instrument_id, symbol: symbol)
        }

        //MARK:  资金费率 标记价格 English: MARK: Fund rate marking price
        wsService.publicMarketData.subscribe(onNext: {[weak self] (info,instrumentId) in
            if self?.itemModel?.instrument_id != instrumentId {
                return
            }
//            self?.capitalRate(info.currentFundRateDisplay(),info.tagPrice)
            self?.updatePublicMarketData(price: info.tagPrice.toPricePrecision(withContractID: self?.itemModel?.instrument_id ?? 0), fundRate: info.currentFundRateDisplay())
        }).disposed(by: self.exs_disposeBag)
        
        
        
        //MARK: 历史k和最新k English: MARK: Historical k and Latest k
        wsService.flutterKLineHistroyDatas
            .subscribe(onNext:{[weak self] (items,prePage) in
                guard let `self` = self else {return}
//                self.printKlinedata(klineData: historys)
                guard let data = items.toJsonString() else { return }
                EXLogger.debug(message: "kline flutter => k线历史数据 ")
                let isLine = self.menuModel.scaleKey.localizedUppercase == "line".localizedUppercase
                self.dealWithKLine(with: .candleHistory(data: data, isMore: prePage, isLine: isLine))
            }).disposed(by: self.disposeBag)
        
        wsService.flutterkLineHistroyFinish
            .subscribe(onNext:{[weak self] (finished) in
                guard let `self` = self else {return}
                if finished {
                    self.hasLoadedAllKline = true
                    self.dealWithKLine(with: .KLineHistoryFinish(finished: true))
                }
            }).disposed(by: self.disposeBag)
        
        wsService.flutterkLineNowDatas
            .subscribe(onNext:{[weak self] item in
                guard let `self` = self else {return}
                guard let data = item.toJsonString() else { return }
                let isLine = self.menuModel.scaleKey.localizedUppercase == "line".localizedUppercase
                self.dealWithKLine(with: .candleData(data: data, isLine: isLine))
                
            }).disposed(by: self.disposeBag)
        
        
        wsService.flutterTickPriceData.subscribe(onNext:{[weak self] item in
            guard let self = self else { return }
            guard let data = item.toJsonString() else { return }
            self.dealWithKLine(with:.candlePrice(data: data, entity: self.entity))
        }).disposed(by: disposeBag)
        
        wsService.flutterDepthChartData.subscribe(onNext: {[weak self] item in
            guard let self = self else { return }
            guard let data = item?.toJsonString() else { return }
            self.dealWithKLine(with:.candleDepthChart(data: data))
        }).disposed(by: disposeBag)
        
        wsService.flutterDepthData.subscribe(onNext: {[weak self] datas in
            guard let self = self else { return }
            EXLogger.debug(message: "flutterDepthData = \(datas)")
            guard let data = datas.toJsonString() else { return }
            self.dealWithKLine(with:.candleDepth(data: data))
        }).disposed(by: disposeBag)
        
        wsService.flutterOrderHistoryData.subscribe(onNext: {[weak self] items in
            guard let self = self else { return }
            guard let data = items.toJsonString() else { return }
            self.candleOrderHistory = data
            self.dealWithKLine(with:.candleOrderHistory(data: data))
        }).disposed(by: disposeBag)
        
        wsService.flutterOrderNowData.subscribe(onNext: {[weak self] item in
            guard let self = self else { return }
            guard let data = item.toJsonString() else { return }
            self.dealWithKLine(with:.candleOrderData(data: data))
        }).disposed(by: disposeBag)
        
        loadMoreCandleHistory.subscribe(onNext: {[weak self] endIdx in
            guard let self = self else { return }
            if let end = endIdx as? Int{
                self.wsService.wsHistoryKLinePre(endIndex: end)
            }
        }).disposed(by: disposeBag)
    }
}

//MARK: Action Buy & Sell & introduce & etf & etc.
extension EXSwapKLineDetailVC {
    //MARK: 导航栏事件 - 切换币对 English: MARK: Navigation Bar Events - Switch Coin Pairs
    // 点击选择合约按钮 English: Click the Select Contract button
    @objc func customBtnClick(){
        self.view.isUserInteractionEnabled = false
        let vc = EXSDrawerVC()
        let list = EXDrawContainerVC()
        list.fromKline = true
        list.vm.eventSubject.subscribe(onNext: {[weak self,weak vc] event in
            guard let mySelf = self else{return}
            switch event{
            case .selectFinsh(let entity):
                vc?.pullAnimation()
                self?.shouldUpdateBS = true
                self?.newReloadDetailWithCoinPairName(entity: entity)
                return
            default:
                break
            }
        }).disposed(by: disposeBag)
        vc.pullBlock = {[weak self] in
            self?.view.isUserInteractionEnabled = true
        }
        vc.contentVc = list
        vc.addVC(list)
        
    }
    
    
    //MARK: 自选 English: MARK: Self selection
    func handleRightAction(_ tag : Int){
        if tag == 0{
            let view = EXSKlineShareView()
            view.isSwap = true
            view.vc = self
            view.swapConfig()
            if let img = self.screenshot() {
                view.setImg(img)
                view.show()
                
            }
           
        }else{
            if self.itemModel == nil{
                return
            }
            //更新自选 English: Update self selection
            let isCollecion = self.isCollect()
            contractVM.handleCoFavorite(actionType: isCollecion ? .singleDelete : .singleAdd, swapIds: [String(self.itemModel!.instrument_id)]) { [weak self] success in
                guard let `self` = self else {return}
                if success{
                }
            }
        }
    }
    
    
    //买卖 English: business
    @objc func buyAction() {
        self.goToContract()
    }
    
    @objc func sellAction() {
        self.goToContract()
    }
    func goToContract(){
        if let id = self.itemModel?.instrument_id {
            EXStoreData.setStoreObjectAndKey(String(id), key: EXNewFuturesContractID)
        }
        self.navigationController?.popToRootViewController(animated: true)
        if let vc = AppService.topViewController() {
            if let tabbar = vc.tabBarController{
                tabbar.selectedIndex = 3
            }
        }
    }
    //更换币种 English: Change currency
    func newReloadDetailWithCoinPairName(entity: EXSwapItemModel) {
        if entity.instrument_id == self.itemModel?.instrument_id {
           return
           
        }
        self.kineHistoryData = nil
        self.wsService.cancelAll()
        self.wsService.service.cancellAlltaskObj()
        self.itemModel = entity
        EXStoreData.setStoreObjectAndKey(String(entity.instrument_id), key: EXNewFuturesContractID)
        self.hasLoadedAllKline = false
        self.wsService.currentItemModel = self.itemModel
        self.getHistoriesKline()
        self.wsService.startFetchDepthChartDataTimer()
        if let instrument_id = itemModel?.instrument_id, let symbol = itemModel?.symbol {
            wsService.startQueryPublicMarketInfoTimer(instrumentId: instrument_id, symbol: symbol)
        }
        self.dealWithKLine(with: .KLineChangedEntity(entity: self.entity))
 
    }
    
    func isCollect() ->Bool {
        var isCollect: Bool = false
        if let item = self.itemModel{
            let swapId = String(item.instrument_id)
            isCollect =  EXStoreData.whetherCollectionCoinMap(swapId)
        }
        return isCollect
    }
}

//MARK: UI
extension EXSwapKLineDetailVC {

    public override var preferredStatusBarStyle: UIStatusBarStyle{
        if EXThemeManager.current == EXThemeManager.day {
            return .default
        }else{
            return .lightContent
        }
    }
    


}


//MARK: NOTIFICATION
extension EXSwapKLineDetailVC {
    func handleNotifi() {
        _ = NotificationCenter.default.rx
            .notification(UIApplication.didBecomeActiveNotification)
            .takeUntil(self.rx.deallocated) //页面销毁自动移除通知监听 English: Page destruction automatically removes notification listening
            .subscribe(onNext: {[weak self] noti in
                self?.homeBtnAction(false)
            })
        
        _ = NotificationCenter.default.rx
            .notification(UIApplication.willResignActiveNotification)
            .takeUntil(self.rx.deallocated) //页面销毁自动移除通知监听 English: Page destruction automatically removes notification listening
            .subscribe(onNext: {[weak self] noti in
                self?.homeBtnAction(true)
            })
        
        _ = NotificationCenter.default.rx
            .notification(Notification.Name(rawValue: NOTI_CONCTRACT_WS_RECONNECTED))
            .takeUntil(self.rx.deallocated) //页面销毁自动移除通知监听 English: Page destruction automatically removes notification listening
            .subscribe(onNext: {[weak self] noti in
                self?.wsService.reConnectAll()
            })
    }
    
    func homeBtnAction(_ enterBackground:Bool) {
        //注意当前控制器 English: Pay attention to the current controller
        guard let top = AppService.topViewController() else {return}
        if top == self {
            if enterBackground {
                wsService.cancelAll()
            }else {
                getHistoriesKline()
            }
        }
    }
    
    func trackActionOn() {
        track_begin = Date()
        track_end = nil
    }
    
    func getHistoriesKline() {
        trackActionOn()
        wsService.getHistoriesAndTicker()
    }
}

extension EXSwapKLineDetailVC{
    func configFlutter() {
        var waterLogoPath: String? = nil
        if EXThemeManager.current == .dayKlinenight || EXThemeManager.current == .night {
            waterLogoPath = EXSwapPlatformSDK.shared.app_img_night
        } else {
            waterLogoPath =  EXSwapPlatformSDK.shared.app_img
        }
        let klineGuideFlag = EXStoreData.stirngObject(forKey: klineGuide) ?? "0"
        let isDark = EXThemeManager.current == .dayKlinenight || EXThemeManager.current == .night
        var parameters: [String: Any] = [
            "exToken" : EXSwapPlatformSDK.shared.activeAccount?.token ?? "",
            //            "domain"  : EXAppConfigManager.sharedInstance.companyDomain(),
            "lan"     : LanguageHandler.phoneLanguage,
            "riseFallTrend": EXTheme.KLineTrend.current == .reversed ? 1 : 0,
            "theme"   : isDark ? "dark" : "light",
            "main1": UIColor.Ex.named("main1", color: isDark ? .dark : .light).rgbString ?? "",
            "main2": UIColor.Ex.named("main2", color: isDark ? .dark : .light).rgbString ?? "",
            "main3": UIColor.Ex.named("main3", color: isDark ? .dark : .light).rgbString ?? "",
            "main4": UIColor.Ex.named("main4", color: isDark ? .dark : .light).rgbString ?? "",
            "text4": UIColor.Ex.named("text4", color: isDark ? .dark : .light).rgbString ?? "",
            "needSubWs" : false,
            "klineGuideFlag":klineGuideFlag,
            "waterPath": waterLogoPath ?? "",
        ]
#if DEBUG
        parameters["isDebug"] = "1"
#endif
        guard let jsonString = parameters.toJsonString() else { return }
        EXFlutterEngine.shared.startEngine(initialRoute: "klineDetail?\(jsonString)")
        EXSwapPlatformSDK.shared.flutteEngine = EXFlutterEngine.shared
        self.addChild(EXFlutterEngine.shared.flutterController!)
        EXFlutterEngine.shared.flutterController?.didMove(toParent: self)
    }
    
    func configKlineUI(){
        guard let flutterController = EXFlutterEngine.shared.flutterController else{
            return
        }
       self.view.addSubview(flutterController.view)
       flutterController.view.snp.makeConstraints { make in
           make.top.equalToSuperview()
           make.left.right.equalToSuperview()
           make.bottom.equalToSuperview()
       }
    }
    
    
    private func updateWaterLogoPath() {
        var klineImage: String?
        if let imgUrl = EXSwapPlatformSDK.shared.getKlineImage(), imgUrl.isEmpty == false {
            let coinDict: [String: Any] = ["waterLogoPath": imgUrl]
            if let jsonString = coinDict.toJsonString() {
                EXFlutterEngine.shared.invokeMethod(method: .updateWaterLogoPath, arguments: jsonString)
            }
        }
    }
    private func updatePublicMarketData(price: String, fundRate: String) {
        let coinDict: [String: Any] = ["markPrice": price,
                                       "fundRate": fundRate]

        if let jsonString = coinDict.toJsonString() {
            EXFlutterEngine.shared.invokeMethod(method: .updatePriceInfo, arguments: jsonString)
        }
        
    }

    
    //flutter 回调 English: Flutter callback
    func flutterCallBack(){
       EXFlutterEngine.shared.flutterController?.setFlutterViewDidRenderCallback { [weak self] in
            guard let self = self else { return }
            self.dealWithFlutterDidRender()
        }
        
        EXFlutterEngine.shared.callbackChannel?.setMethodCallHandler { [weak self] (call, result) in
            guard let self = self else { return }
            self.dealWithFlutterCallback(call: call, result: result)
        }
        
//        self.viewModel?.wsEventSubject.subscribe(onNext: {[weak self] event in
//            guard let self = self else { return }
//            self.dealWithKLine(with: event)
//        }).disposed(by: self.disposeBag)
        
     

    }
    
}

// MARK: flutter did render
extension EXSwapKLineDetailVC{
    
    private func dealWithFlutterDidRender() {
        if let jsonString = ["KlineBgColor": "#00000000"].toJsonString() {
            EXFlutterEngine.shared.invokeMethod(method: .setKlineBgColor, arguments: jsonString)
        }
        //MARK: fix ？
//        if let jsonString = ["mTimeIndexList": self.scaleKeys].toJsonString() {
//            EXFlutterEngine.shared.invokeMethod(method: .setKlineTimeIndexList, arguments: jsonString)
//        }
        
        
        if let jsonString = ["VolStateIndex": 0].toJsonString() {
            EXFlutterEngine.shared.invokeMethod(method: .setKlineVolState, arguments: jsonString)
        }
        EXLogger.debug(message: "dealWithFlutterDidRender ")
        handlekLineWs()
        sendKlineConfig()
//        handleScale(key: self.menuModel.scaleKey)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.kineHistoryData = nil
            self.querySellAndBuy()
            self.updateWaterLogoPath()
//            self.setCoinInfoToFlutter()

        }
        
    }
    
    private func sendKlineConfig(){
        //更新 English: update
        let map = EXFlutterKlineCache.shared.klineUsePreference
        guard let data = map.toJsonString() else{
            return
        }
        EXFlutterEngine.shared.invokeMethod(method: EXInvokeFlutterMethod.updateMainIndexVisible, arguments: data)
    }
    private func setCoinInfoToFlutter() {
         //0符号 1汇率 2位数 English: 0 symbol 1 exchange rate 2 digits
        let currencys =  itemModel?.getCurrentRate() ?? ("¥","1",2)
        let volumeUnit = itemModel?.ex_contractInfo?.volumeUnit ?? ""
        let priceUnit = itemModel?.ex_contractInfo?.quote_coin ?? ""
        let coinName = entity.name
        let isCoin = EXStoreData.storeBool(forKey: EXS_UNIT_VOL)
        let facevalue = itemModel?.ex_contractInfo?.face_value
        let marginCoinPrecision = Int(itemModel?.ex_contractInfo?.coinResultVo.marginCoinPrecision ?? "2") ?? 2
        
        let coinDict: [String: Any] = ["coinName": coinName,
                                       "mSymbolPricePrecision": Int(entity.price) ?? 8,
                                       "mSymbolAmountPrecision":Int(entity.volume) ?? 8,
                                       "mAmountUnit": volumeUnit,
                                       "mPriceUnit": priceUnit,
                                       "mklineScale": menuModel.scaleKey,
                                       "mCurrencyUnit":currencys.0,
                                       "mCurrencyPrecision": currencys.2,
                                       "mCurrencyRates": currencys.1,
                                       "isCollect": self.isCollect(),
                                       "etfOpen": false,
                                       "symbol_profile": false,
                                       "FundRate": "",
                                       "etf_coin_name": "",
                                       "etf_coin_desc": "",
                                       "etfRisk": "",
                                       "marketTag":"",
                                       "leverMultiple":"",
                                       "isContractKline": true,
                                       "isCoin":isCoin,
                                       "mMultiplier": facevalue ?? "1",
                                       "marginCoinPrecision":marginCoinPrecision
        ]

        if let jsonString = coinDict.toJsonString() {
            EXFlutterEngine.shared.invokeMethod(method: .setCoinInfo, arguments: jsonString)
        }
    }
    
}



// MARK: flutter -> 原生  EXSwapKLineDetailVC English: MARK: Flutter ->Native EXSwapKLineDetailVC
extension EXSwapKLineDetailVC {
    
    private func dealWithFlutterCallback(call: FlutterMethodCall, result: FlutterResult) {
        guard let method = EXKlineCallbackMethod(rawValue: call.method) else { return }
        let arguments = call.arguments
        EXLogger.debug(message: "flutter => method \(method),arguments =\(arguments)")
        switch method {
        case .kline_guide_flag:
            guard let _arguments = arguments as? [String: String],
            let message    = _arguments["flagStr"] as? String else { return }
            EXFlutterKlineCache.shared.klineUsePreference["kline_v_guide1"] = "1"
            EXStoreData.setStoreObjectAndKey(message, key: klineGuide)
        case .show_native_toast:
            guard let _arguments = arguments as? [String: String],
            let message    = _arguments["message"] as? String else { return }
            EXAlert.showFail(msg: message)
        case .flutter_canPop:
            guard let _arguments = arguments as? [String: Any],
            let canPop    = _arguments["flutter_canPop"] as? Bool else { return }
            self.navigationController?.interactivePopGestureRecognizer?.isEnabled = !canPop
        case .reload_kline:
            let scaleKey = self.menuModel.scaleKey
            handleScale(key: scaleKey)
        case .more_history_kline:
            guard let _arguments = arguments as? [String: Any],
                  let _endIdx    = _arguments["endIdx"] else { return }
            self.loadMoreCandleHistory.onNext(_endIdx)
            return
        case .close_kline_vpage:
            self.navigationController?.popViewController(animated: true)
//            self.viewModel?.flutterCallback.onNext(method)
            break
        case .kline_coin_sidebar:
            customBtnClick()
            break
        case .kline_coin_share:
            handleRightAction(0)
            break
        case .kline_enlarge:
            let rotation : UIInterfaceOrientationMask = [ .landscapeRight]
            UIDeviceManger.shared.blockRotation = rotation
            //重新订阅 English: Unsubscribe
            lastScaleKey = ""
            handleScale(key: self.menuModel.scaleKey)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {//延迟处理。否则刷不出来 English: Delay processing. Otherwise, it won't come out
                if self.kineHistoryData != nil {
                    self.dealWithKLine(with: .buysell(data: self.kineHistoryData!))
                }
                self.updateWaterLogoPath()
                self.setCoinInfoToFlutter()
            }
            break
        case .close_kline_hpage:
            let rotation : UIInterfaceOrientationMask = [ .portrait]
            UIDeviceManger.shared.blockRotation = rotation
            break
        case .kline_coin_collect:
            handleRightAction(1)
            break
        case .kline_switch_time_index:
//            EXLogger.debug(message: "flutter => self.menuModel.scaleKey = \(self.menuModel.scaleKey))")
            self.wsService.lastId = nil
            guard let _arguments   = arguments as? [String : Any] else { return }
            guard let _mklineScale = _arguments["mklineScale"] as? String else { return }
            let scaleKey = _mklineScale.uppercased() == "line".uppercased() ? "Line" : _mklineScale
            if lastScaleKey == scaleKey {
                return
            }
            let info = ["mklineScale": scaleKey]
            NotificationCenter.default.post(name: NSNotification.Name.init(ContractKTimeScakeyChanged), object:nil,userInfo: info)
            handleScale(key: scaleKey)
        case .kline_coin_info:
            self.setCoinInfoToFlutter()
        case .kline_order_book:
//            self.viewModel?.flutterCallback.onNext(.kline_order_book)
            break
        case .kline_transaction_record:
            guard let data = self.candleOrderHistory else { return }
            let dict: [String: Any] = ["mRecordData": data,"isHistory":true]
            guard let jsonString = dict.toJsonString() else { return }
            EXFlutterEngine.shared.invokeMethod(method: .setTransactionRecordData, arguments: jsonString)
            break

        case .kline_coin_intro:
            break
//            self.viewModel?.flutterCallback.onNext(.kline_coin_intro)

        case .kline_etf_coin_intro:
            break
//            self.viewModel?.flutterCallback.onNext(.kline_etf_coin_intro)

        case .kline_etf_position_record:
            break
//            self.viewModel?.flutterCallback.onNext(.kline_etf_position_record)

        case .kline_go_webview:
            break
        case .kline_trading_sell:
            self.sellAction()
        case .kline_trading_buy:
            self.buyAction()
        case .kline_detail_clickMainIndex:// 大k线配置同步到小K线 English: Synchronize the configuration of the large K line to the small K line
            guard var _arguments = arguments as? [String: Any] else { return }
//            EXLogger.debug(message: "flutter =>_arguments = \(_arguments)")
            _arguments["kline_v_guide1"] = "1"
            EXFlutterKlineCache.shared.klineUsePreference = _arguments
        default:
            break
        }
    }
}



// MARK: deal with K-line events
extension EXSwapKLineDetailVC {
    
    private func dealWithKLine(with event: ContractKlineSocketEvent) {
        let mSymbolPricePrecision = Int(entity.price) ?? 2
        switch event {
        case .KLineChangedEntity(let entity):
            self.setCoinInfoToFlutter()

        case .candleHistory(let data, let isMore, let isLine):
            let dict: [String: Any] = ["mSymbolPricePrecision": mSymbolPricePrecision,"isLine": isLine,"isMore": isMore,"mKlineData": data]
            guard let jsonString    = dict.toJsonString() else { return }
            EXFlutterEngine.shared.invokeMethod(method: .setHistoryKlineData, arguments: jsonString)

        case .candleData(let data, let isLine):
            let dict: [String: Any] = ["mSymbolPricePrecision": mSymbolPricePrecision, "isLine": isLine, "mKlineData": data]
            guard let jsonString    = dict.toJsonString() else { return }
            EXFlutterEngine.shared.invokeMethod(method: .setNewKlineData, arguments: jsonString)


        case .candlePrice(let data, _ ):
            let dict: [String: Any] = ["mTickerData": data]
            guard let jsonString = dict.toJsonString() else { return }
            EXFlutterEngine.shared.invokeMethod(method: .set24HTickerData, arguments: jsonString)
        case .candleDepthChart(let data):
            let dict: [String: Any] = ["mDepthMapData": data]
            guard let jsonString = dict.toJsonString() else { return }
            EXFlutterEngine.shared.invokeMethod(method: .setDepthMapData, arguments: jsonString)

        case .candleDepth(let data):
            let dict: [String: Any] = ["mOrderBookData": data]
            guard let jsonString = dict.toJsonString() else { return }
            EXFlutterEngine.shared.invokeMethod(method: .setOrderBookData, arguments: jsonString)

        case .candleOrderHistory(let data):
            let dict: [String: Any] = ["mRecordData": data,"isHistory": true]
            guard let jsonString = dict.toJsonString() else { return }
            EXFlutterEngine.shared.invokeMethod(method: .setTransactionRecordData, arguments: jsonString)

        case .candleOrderData(let data):
            let dict: [String: Any] = ["mRecordData": data,"isHistory": true]
            guard let jsonString = dict.toJsonString() else { return }
            EXFlutterEngine.shared.invokeMethod(method: .setTransactionRecordData, arguments: jsonString)

        case .candleCoinBrief(let data):
            let dict: [String: Any] = ["mCoinIntroData": data]
            guard let jsonString = dict.toJsonString() else { return }
            EXFlutterEngine.shared.invokeMethod(method: .setCoinIntroData, arguments: jsonString)

        case .candleNetworth(let data):
            let dict: [String: Any] = ["mCoinETFData": data]
            guard let jsonString = dict.toJsonString() else { return }
            EXFlutterEngine.shared.invokeMethod(method: .setCoinETFData, arguments: jsonString)

        case .candleETFAct(let data):
            let dict: [String: Any] = ["mEtfPositionRecord": data]
            guard let jsonString = dict.toJsonString() else { return }
            EXFlutterEngine.shared.invokeMethod(method: .setCoinETFRuleData, arguments: jsonString)
        case .buysell(let data):
            EXFlutterEngine.shared.invokeMethod(method: .setKlineBuySellData, arguments: data)
        default:
            break
        }
        
    }
}


