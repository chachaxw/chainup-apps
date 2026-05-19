//
//  EXContractHomeViewmodel.swift
//  Chainup
//
//  Created by cwd on 2022/10/9.
//  Copyright © 2022 Chainup. All rights reserved.
//

import UIKit
import RxSwift
import SwiftEventBus
import EXKit
enum EXContractEvent {
//    // KLine币对实体发生变化 English: KLine Coin Changes Entity
//    case KLineChangedEntity(entity:EXSCoinMapEntity?)
//    // KLine历史数据 English: KLine Historical Data
//    case KLineHistory(items:[EXSKLineChartItem], prePage: Bool = false)
//    // KLine历史数据加载完成 English: KLine historical data loading completed
//    case KLineHistoryFinish(finished: Bool)
//    // KLine最新数据 English: KLine's latest data
//    case KLineData(item:EXSKLineChartItem)
//    // KLine价格 English: KLine price
//    case KLinePrice(item:EXSTickItem)
//    // KLine深度图数据 English: KLine depth map data
//    case KLineDepthChart(item:(chartItem:[COKDepthChartItem], price:String))
    ///底部列表数据 English: /Bottom List Data
    //当前持仓 English: Current position
    case positionData
    //当前委托 English: Current commission
    case currentEntrustmentData
    //计划委托 English: Plan delegation
    case planEntrustmentData
    //网络请求返回 English: Network request return
    case updateItemModel
    case updateUserConfig
    case reloadData
    case logSuccess
    case updateRate
    case updateTicer
    //更新标记价格 English: Update marked prices
    case updateIndexPrice(item: EXPricelistModel)
    //ws
    case publicMarketData(SLPublicMarketInfo)
    //深度 English: depth
    case depthData
    //
    case updateOpenUnit
    //通知 English: notice
    case setFuturesDataUpdata
    case refreshLoginSuccess
    case refreshLogout
    case sl_showOpenContractView
    case kycLimitValite
    case lineChange
    case wslineChange
    case closePositionSuccess //平仓成功 English: Closing successful
    case cancelPositionSuccess //撤单成功 English: Cancellation successful
    case updateAssetInfo //余额 English: balance
    //公告栏 English: Announcement Board
    case noticeInfo(info: EXContractNotice?)
    case noticeClose

    case scaleChange(scale: String)
    
}

class EXContractHomeViewModel: EXViewModel {
    let tickKey = "EXTickerModel"
    var queryNextRateTime = false
    // 回收袋 English: Recycling bags
    let exs_disposeBag = DisposeBag()
    var updatedOpenOrderUnit = false //登录后只需要更新一次 English: After logging in, only one update is required
    var onlyCurrentContarct: Bool = false // 近当前合约 English: Recent contracts
//    var itemModel : EXSwapItemModel?
    var isScrolling: Bool = false //页面滑动无需 English: Page sliding does not require
    /// 是否需要重置深度数据订阅 (进入详情页时不需要取消, 每次界面重新显示时重置) 深度订阅每次数据回调会2次,每次切换币对，深度数据 English: /Do you need to reset the deep data subscription (do not need to cancel when entering the details page, reset every time the interface is redisplayed)? Deep subscription will have 2 data callbacks each time, and switching currency pairs each time will result in deep data
    var isNeedUpdateSubscribeDepthData = true
    /// 是否需要刷新Ticker UI English: /Do I need to refresh the Ticker UI
    var isNeedUpdateSubscribeTickerUI = false
    var isNeedUnSubscribeTikcerUI = true
    var shouldUpdateUserConfig = false
    var updateRateCountdownTimer:Timer?
    var queryAssetAndPositionTimer:Timer?
    var queryPublicMarketInfoTimer:Timer?
    var currentDepthIdx = 0
    var firstQueryPosition = true //
    var tickDic = [String:EXCOTickerModel]()//为了控制更新频率.这里更新最新价格，每一秒从这里取价格 English: To control the update frequency, update the latest price here and take the price from here every second
//    var klineVM.wsService = EXSContractKLineService()
    var klineVM = EXContractFlutterKLineChartViewModel()
    var wsManager:EXSwapSocketManager {
        get {
           return EXSwapSocketManager.shared
        }
    }
    var asset :EXCItemCoinModel? {
        get {
            EXSwapPersonInfo.shared.getSwapAssetItem(withCoin: currentItemModel?.ex_contractInfo?.margin_coin ?? "")
        }
    }
    var canUseAmount:String {
        if let item = currentItemModel{
            var canuse = "0"
            if let a = asset{
                canuse = a.canUseAmount
            }
            return canuse.toValuePrecision(withContract:item.instrument_id)
        }
        return "0"
    }
    /// 当前显示合约模型 English: /Current display contract model
    var last: EXSwapItemModel?
    var currentLevel = "0"
    var currentItemModel: EXSwapItemModel? {
        didSet{
            guard let new = currentItemModel else{return}
            if last?.instrument_id != new.instrument_id{ //币对改变后不存在问题 English: There are no issues with the change of the currency pair
                self.currentLevel = "0"
                self.tickDic.removeAll() //清空最新价的缓存 English: Clear the cache of the latest price
                p_queryPublicMarketInfo() //资金费率慢处理 English: Slow handling of fund rates
                startWs()
                self.isNeedUpdateSubscribeDepthData = true
                ///请求用户的配置信息 发送updateItemModel English: /Requesting the user's configuration information to send an updateitemModel
                currentItemModelHasChanged()
                if self.isScrolling == true{return}
                wsEventSubject.onNext(.updateItemModel)
                self.klineVM.resetEntity(new)
            }
            last = currentItemModel
        }
    }
    //用户配置 English: User Configuration
    var currentUserConfig = SLUserConfig()
    /// socket事件信号 English: /Socket event signal
    private(set) var wsEventSubject: PublishSubject<EXContractEvent> = PublishSubject()
    
    
    var positionDatas: [EXSwapPositionModel] = [] //当前持仓 English: Current position
    var currentEntrustmentData: [EXContractOrderModel] = []//当前委托 English: Current commission
    var planEntrustmentData: [EXContractOrderModel] = [] //计划委托 English: Plan delegation
    var allCurrentPositionData: [EXSwapPositionModel] = [] //当前持仓-全部 English: Current position - all
    var currentEntrustmentDataCount: Int = 0//当前委托 English: Current commission
    var planEntrustmentDataCount: Int = 0//计划委托 English: Plan delegation
    deinit {
        NotificationCenter.default.removeObserver(self)
        stopTimers()
    }
}
//MARK: 小版本k线相关的 English: MARK: Small version K-line related
extension EXContractHomeViewModel{
    //订阅k线 English: Subscription to K-line
    func subscribeKline() {
        cancelSubscribeKline()
        //注册 English: register
        self.klineVM.wsService.register()
        //历史数据 English: historical data
        self.klineVM.wsService.getKlineHistory(isSmallKline: true)
        //最新价格 English: Latest prices
        self.klineVM.wsService.getTicker(isSmallKline: true)
    }
    //取消订阅 English: Unsubscribe
    func cancelSubscribeKline(){
        self.klineVM.wsService.canceSmallKlinel()
    }
}
//MARK: WS
extension EXContractHomeViewModel{
    
    func stopSubscribeData(){
        stopWs()
        stopTimers()
    }
    
    func reSubscribeData(){
        startWs()
        startQuery()
        if self.currentItemModel != nil {
            self.klineVM.resetEntity(self.currentItemModel!)
        }
       
    }
    @objc func startWs() {
         stopWs()
         klineVM.wsService.currentItemModel = self.currentItemModel
        if klineVM.isExpand{
            klineVM.registerSocket()
        }
         wsManager.currentItemModel = self.currentItemModel
         //MARK: 只订阅了当前币对的行情 和 深度 English: MARK: Only subscribed to the current currency pair's market and depth
         wsManager.getCurrentTicker()
         wsManager.currentBuySellFiveData(currentDepthIdx)
     }
    //订阅当前币对 English: Subscribe to the current currency pair
    @objc func reSubCurrentTicker(){
        wsManager.getCurrentTicker()
    }
   
    
     func stopWs() {
         wsManager.cancel()
         wsManager.cancellAlltaskObj()
         klineVM.wsService.cancelAll()
     }
    
    //开始刷数据仓位 English: Start flashing data slots
    func startQuery() {
        startChangeRateCountdownTimer()
        startQueryPublicMarketInfoTimer()
       
    }
    
    //销毁定时器 English: Destroy Timer
    func stopTimers() {
        stopQueryPublicMarketInfoTimer()
        stopChangeRateCountdownTimer()
    }
    
    //资金费率 - English: Fund rate-
    func startChangeRateCountdownTimer() {
        updateRateCountdownTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] _  in
            guard let newSelf = self else{return}
            // debugPrint(#function)
            guard let item = newSelf.currentItemModel else {
                return
            }
            if let interval = item.ex_contractInfo?.intervalForNextRateTime(), Int(interval) == 0 {
                newSelf.startQueryPublicMarketInfoTimer()
            }
            newSelf.updatePrice() //仓位需要实时刷 English: Positions need to be refreshed in real time
            if newSelf.isScrolling == true{return}
            newSelf.wsEventSubject.onNext(.updateRate)
            if newSelf.wsManager.isConnected() == true{
                newSelf.webSocketUpdateContractTicker()
                newSelf.webSocketUpdateContractDepth()
            }
           

        })
        //MARK:default  滑动页面上的时time暂停 English: MARK: Pause the time when sliding on the page by default
        RunLoop.main.add(updateRateCountdownTimer!, forMode: RunLoop.Mode.default)
        updateRateCountdownTimer?.fire()
    }
    
    func startQueryPublicMarketInfoTimer() {
        
        queryPublicMarketInfoTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true,block: {[weak self] _ in
            guard let newSelf = self else{return}
            if newSelf.isScrolling == true{return}
            newSelf.p_queryPublicMarketInfo()
            newSelf.queryData()
        })
        RunLoop.main.add(updateRateCountdownTimer!, forMode: RunLoop.Mode.default)
        queryPublicMarketInfoTimer?.fire()
    }
   
    func stopChangeRateCountdownTimer() {
        updateRateCountdownTimer?.invalidate()
        updateRateCountdownTimer = nil
    }
    
    func stopQueryPublicMarketInfoTimer() {
        queryPublicMarketInfoTimer?.invalidate()
        queryPublicMarketInfoTimer = nil
    }
    func setupWs() {
        ///最新价 English: /Latest price
        EXSwapSocketDataManager.shared.tickPriceData.subscribe(onNext: { [weak self] (item) in
            guard let newSelf = self else{
                return
            }
           
            if newSelf.isScrolling == true{return}
            if newSelf.isNeedUpdateSubscribeTickerUI {
                newSelf.tickDic[newSelf.tickKey] = item
//                self.webSocketUpdateContractTicker(item: item)
            }
            
        }).disposed(by: self.exs_disposeBag)
        ///深度数据 English: /Deep data
        EXSwapSocketDataManager.shared.depthData.subscribe(onNext: { (item) in
            if self.isScrolling == true{return}
            if self.isNeedUpdateSubscribeDepthData { //切换币对时需要立即刷 English: Immediate flashing is required when switching currency pairs
                self.wsEventSubject.onNext(.depthData)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.isNeedUpdateSubscribeDepthData = false
                }
            }

        }).disposed(by: self.exs_disposeBag)

    }
    func webSocketUpdateContractDepth(){
//            debug//print("=====> 深度depthData刷新") English: DebugPrint
            self.wsEventSubject.onNext(.depthData)
    }
    func webSocketUpdateContractTicker() {
        guard let item = self.tickDic[self.tickKey] else{
            return
        }
        guard let itemModel = self.currentItemModel else {
            return
        }
//        debug//print("=====> tickPriceData刷新") English: DebugPrint (TickPriceData refresh)
        itemModel.last_px = item.close
        itemModel.change_rate = item.rose
        self.wsEventSubject.onNext(.updateTicer)
    }
    func reloadData(){
        self.resetData()
        getFirstItemModel()
        if shouldUpdateUserConfig {
            updateUserConfig()
        }else {
            shouldUpdateUserConfig = true
        }
        // 重置为true English: Reset to true
        self.isNeedUpdateSubscribeDepthData = true
        self.isNeedUnSubscribeTikcerUI = true
        self.isNeedUpdateSubscribeTickerUI = true
        if !hasLogin() {
            refreshLogout()
        }
        self.wsEventSubject.onNext(.reloadData)
    }
}
//MARK: 通知 English: MARK: Notification
extension EXContractHomeViewModel{
   
    func setupNotes() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(willEnterForeground),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(reStartWs),
                                               name: NSNotification.Name(rawValue: NOTI_CONCTRACT_WS_RECONNECTED),
                                               object: nil)
      //   当接口请求Futures ticker数据更新时候获得通知,新合约也使用 English: Received notification when the interface requests Future ticket data updates, and new contracts are also used
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(setFuturesDataUpdata),
                                               name: NSNotification.Name(rawValue: EXContractLoadFuturesData_Notification),
                                               object: nil)
        // 监听登录成功 English: Listening login successful
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(refreshLoginSuccess),
                                               name: NSNotification.Name(rawValue: "EXLoginSuccess"),
                                               object: nil)
        
        // 添加退出登录通知 English: Add logout notification
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(refreshLogout),
                                               name: NSNotification.Name(rawValue: "Logout_notification_name"),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(kycLimitValite),
                                               name: NSNotification.Name(rawValue: EXContractKycLimitNotification),
                                               object: nil)
       
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(lineChange),
                                               name: NSNotification.Name(rawValue: EXContract_lineChange_Notification),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(wslineChange),
                                               name: NSNotification.Name(rawValue: EXContract_wslineChange_Notification),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(scaleKeyChange),
                                               name: NSNotification.Name(rawValue: ContractKTimeScakeyChanged),
                                               object: nil)
    }
    
    @objc func becomeActive(){
        
    }
    @objc func setFuturesDataUpdata(notification: NSNotification) {
        if notification.userInfo == nil || currentItemModel == nil {
            getFirstItemModel()
        }
    }
    
    @objc func sl_showOpenContractView(){
        wsEventSubject.onNext(.sl_showOpenContractView)
    }
    @objc func kycLimitValite(){
        wsEventSubject.onNext(.kycLimitValite)
    }
    @objc func lineChange(){
        if self.isScrolling == false{return}
        reloadData()
        startWs()
    }
    @objc func wslineChange(){
        if self.isScrolling == false{return}
        startWs()
    }
    
    @objc func scaleKeyChange(notification: NSNotification){
        let dic = notification.userInfo
        //print("dic = \(dic)")
        if let key = dic?["mklineScale"] as? String {
            self.klineVM.wsService.kcandleType = key
            self.klineVM.wsEventSubject.onNext(.bigKlineTimeKeyChange(itemKey: key))
        }
    }
    
    @objc func willEnterForeground(){
        //print("willEnterForeground")
        queryPubinfo(showErr: true, success: {
            [weak self] in
                guard let newSelf = self else{
                    return
                }
            newSelf.resetData()
            newSelf.getFirstItemModel()
        }, failure: { [weak self] in
            guard let newSelf = self else{
                return
            }
            newSelf.resetData()
        })
    }
    @objc func reStartWs(){
//        debug//print("====ws====重连通知-重新订阅") English: DebugPrint
        self.isScrolling = false
        startWs()
    }
    @objc func refreshLogout() {
        self.updatedOpenOrderUnit = false
//        debug//print("合约##退出通知--发送事件refreshLogout") English: DebugPrint ("Contract # # Exit Notification - Send Event refreshLogout")
        EXContractSDK.alreadLogout()
      //  stopQueryAssetAndPositionTimer()
        self.currentUserConfig  = SLUserConfig()
        self.wsEventSubject.onNext(.refreshLogout)
    }
    
    ///登录成功刷 English: /Login successful brushing
    @objc func refreshLoginSuccess(notification: NSNotification) {
       //清空数据 English: wipe data
        refreshLogout()
        shouldUpdateUserConfig = true
        self.wsEventSubject.onNext(.logSuccess)
        //更新数据 刷新数据 English: Update data refresh data
        reloadData()
        
        self.queryNoticeBarInfo()
        
    }
}
extension EXContractHomeViewModel{
    
    func upDatePubinfo(){
        EXContractNetwork.queryPublicInfo(success: { (public) in
            EXContractSDK.ex_loadFutureMarketData { (_, error) in
            }
        }, failure: { _ in
        }, showError: false)
    }
    
    func currentItemModelHasChanged() {
        if hasLogin() {
            updateUserConfig()
        }
    }
    //MARK: 数据重连 English: MARK: Data reconnection
    func queryPubinfo(showErr:Bool,success: @escaping () -> (), failure:@escaping () -> ()){
        self.klineVM.wsService.service.retryTime = 0
        if currentItemModel == nil {
            EXContractNetwork.queryPublicInfo(success: { (public) in
                EXContractSDK.ex_loadFutureMarketData { (_, error) in
                    if self.wsManager.isConnected() == false {
                        self.wsManager.connectServer()
                    }
                    success()
                }
            }, failure: { (error) in
                failure()
            }, showError: showErr)
        }else{ //ws处理 English: Ws processing
            self.upDatePubinfo()
            if self.wsManager.isConnected() == false {
                self.wsManager.connectServer()
                self.reStartWs()
                success()
                return
            }
            failure() //无需刷数据 English: No need to refresh data
        }
    }
    
    
    //MARK: 数据重连 English: MARK: Data reconnection
    func queryPubinfoOnly(success: @escaping () -> (), failure:@escaping () -> ()){
        if self.queryNextRateTime {
            return
        }
        self.queryNextRateTime = true
        
        EXContractNetwork.queryPublicInfoOnly { _ in
            self.queryNextRateTime = false
            success()
        } failure: { _ in
            self.queryNextRateTime = false
            failure()
        }
    }
    
    func getFirstItemModel() {
        let tickerArr = EXSwapPublicInfo.shared.getSortTickers(area: .CONTRACT_BLOCK_UNKOWN) ?? []
        if tickerArr.count == 0 {
           // self.queryPublicInfo(showErr: false)
            return
        }
        var instrument_id : Int64 = Int64(EXStoreData.storeObject(forKey: EXNewFuturesContractID) as? String ?? "0") ?? 0
        let firstItem = tickerArr[0]
        if instrument_id <= 0 && tickerArr.count > 0 {
            instrument_id = firstItem.instrument_id

            self.currentItemModel = firstItem
            EXStoreData.setStoreObjectAndKey(String(instrument_id), key: EXNewFuturesContractID)
        } else {
            for item in tickerArr {
                if item.instrument_id == instrument_id {
                    self.currentItemModel = item
                    break
                }
            }
            if self.currentItemModel == nil {
                self.currentItemModel = firstItem
                EXStoreData.setStoreObjectAndKey(String(instrument_id), key: EXNewFuturesContractID)
            }
        }
        if currentItemModel == nil {
            
            EXContractNetwork.queryPublicInfo { (public) in
                EXContractSDK.ex_loadFutureMarketData { (_, error) in
                    self.getFirstItemModel()
                    if self.wsManager.isConnected() == false {
                        self.wsManager.connectServer()
                    }
                }
            } failure: { (_) in
                
            }
        }
    }
}
//MARK:
extension EXContractHomeViewModel{
    //MARK: 重置数据 English: MARK: Reset data
    func resetData(){
        //self.updatedOpenOrderUnit = false 退出登录时处理 English: Self. updatedOpenOrderUnit=false Handle when logging out
        self.firstQueryPosition = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.isScrolling = false
            
        }
    }
    func passed() -> Bool {
        if !checkAndLogin(){
            return false
        }
        if !checkHasOpenContract(){
            return false
        }
        return true
    }
    func checkAndLogin() -> Bool {
        if !hasLogin() {
            EXSwapPlatformSDK.shared.loginCallBack?()
            return false
        }
        return true
    }
    
    func checkHasOpenContract() -> Bool {
        if !SLUserConfig.checkHasOpenContract {
            sl_showOpenContractView()
            return false
        }
        return true
    }
    
    func hasLogin() -> Bool {
        if EXSwapPlatformSDK.shared.activeAccount != nil { // 已经登录 English: already logged
            return true
        }
        return false
    }
    /**
     5秒刷新仓位 盈亏差异有点大 English: The profit and loss difference between refreshing positions in 5 seconds is a bit large
     后台改成秒级，压力大 English: Changing the backend to second level, high pressure
     每秒请求 币种价格，根据5秒前返回的数据，计算盈亏 刷新列表 English: Request currency prices per second, calculate profit and loss refresh list based on data returned 5 seconds ago
     */
    
    //MARK: 当前持仓 English: MARK: Current position
    func refreshPosition(priceList: [EXPricelistModel]){        //无数据也不用处理 English: No data or processing required
        if self.positionDatas.count == 0 {
            return
        }
        self.positionDatas = self.positionDatas.map { item in
            return item.localCalculate(pricelist: priceList)
        }
        self.wsEventSubject.onNext(.positionData)
    }
    
    //MARK: 更新指数价格 和 仓位价格 English: MARK: Update index prices and position prices
    func updatePrice(){
        if self.positionDatas.count == 0 {
            return
        }
        EXContractNetwork.getPriceList { priceList in
            for item in priceList {
                //更新标记价格 English: Update marked prices
                if item.icon == self.currentItemModel?.ex_contractInfo?.contractName{
                    self.wsEventSubject.onNext(.updateIndexPrice(item: item))
                    break
                }
            }
            if self.firstQueryPosition == true {
                self.queryData()
            }else{
                //刷新仓位数据 English: Refresh Bin Data
                self.refreshPosition(priceList: priceList)
            }
            self.firstQueryPosition = false
           
        } failure: { (_) in
        }.disposed(by: self.exs_disposeBag)
        
    }

    
    //MARK: 一键全平 English: MARK: One click full flat
    func oneKeyAllClose(){
        //MARK:
        if self.positionDatas.count == 0 {
            return
        }
        let alert =  EXCommonAlert() // EXSNormalAlert()
        let title = "cp_extra_text27".ex_localized()
        var content = "cl_close_3".ex_localized()
        let count = String(self.positionDatas.count)
        content = content.formatWithArguments(arguments: [count])
        alert.configAlert(title: title,message: content) { [weak self]  type in
            guard let strong = self else {return}
            if type == .sure {
                EXAlert.dismiss()
                EXTracking.shared.track(event: EXSwapTrackingEvent.app_futures_positions_close_all.rawValue)
                strong.closeAllPosition()
            }
        }
        EXAlert.showAlert(alertView: alert)
    }
    
    //MARK: 全部撤销 (当前和计划委托) English: MARK: Revoke All (Current and Planned Commissions)
    func cancelAllEntrustments(priceType: EXSwapTransactionPriceType){
        var contractId = self.currentItemModel?.instrument_id ?? 0
        if priceType == .plan{
            let planEntrustOnlyCurrent = EXStoreData.storeBool(forKey: planEntrustOnlyCurrentContract)
            if planEntrustOnlyCurrent == false{
                contractId = -1
            }
        }else{
            let currentEntrustOnlyCurrent = EXStoreData.storeBool(forKey: currentEntrustOnlyCurrentContract)
            if currentEntrustOnlyCurrent == false{
                contractId = -1
            }
        }
        let alert = EXCommonAlert()
        alert.configAlert(title: "cp_overview_text58".ex_localized()) { type in
            EXAlert.dismiss()
            if type == .sure{
                EXTracking.shared.track(event: EXSwapTrackingEvent.app_futures_orders_cancel_all.rawValue)
                self.cancelAllTransaction(contractId: contractId, orderId: nil, type: priceType)
            }
        }
        EXAlert.showAlert(alertView: alert)
    }
    
    
    
    //MARK: 仅显示当前合约 English: MARK: Display only the current contract
    func reloadCurrentPostion(){
        refreshData()
    }
    //仅限当前合约 - reloadList 刷新列表 English: Current contract only - reloadList refresh list
    func refreshData(reloadList: Bool = true) {
        self.positionDatas = self.allCurrentPositionData.filter({ (model) -> Bool in
            if onlyCurrentContarct {
                return model.instrument_id == self.currentItemModel?.instrument_id
            }else {
                return true
            }
        })
        if self.positionDatas.count == 0 { //平仓 需要立即清空数据刷新界面 English: Closing positions requires immediate clearing of data refresh interface
            self.wsEventSubject.onNext(.positionData)
            return
        }
        if (reloadList){
            //刷新列表 English: Refresh List
            self.wsEventSubject.onNext(.positionData)
        }
      
    }
    //当前委托 / 计划委托 English: Current/planned commission
    func refreshOnlyCurrentData(type: EXSwapTransactionPriceType) {
        //直接刷新接口 English: Directly refresh the interface
        let instrument_id = self.currentItemModel?.instrument_id ?? 0
        if type == .limit { //当前委托 English: Current commission
            requestCurrentTransactionData(instrument_id: instrument_id)
        }else{//计划委委托 English: Commissioned by the Planning Commission
            requestPlanTransactionData(instrument_id: instrument_id)
        }
    }
    //MARK:  全部撤单接口 English: MARK: All cancellation interfaces
    func cancelAllTransaction(contractId: Int64, orderId: Int64?, type: EXSwapTransactionPriceType) {
        EXContractNetwork.cancelOrder(contractId: contractId,
                                      orderId: orderId,
                                      isConditionOrder: type == .plan) {
            EXAlert.showSuccess(msg: "cp_content_text3".ex_localized())
            let instrument_id = self.currentItemModel?.instrument_id ?? 0
            if type == .limit {
                self.requestCurrentTransactionData(instrument_id: instrument_id)
            }else{
                self.requestPlanTransactionData(instrument_id: instrument_id)
            }
            self.queryAsset()
        } failure: { (error) in
            EXAlert.showFail(msg: "cp_content_text4".ex_localized())
        }
    }
    
    
    //MARK: 一键全平接口处理 English: MARK: One click full flat interface processing
    func closeAllPosition(){
        if self.positionDatas.count == 0 {
          return
        }
        let contractId:Int64? = onlyCurrentContarct ? (currentItemModel!.instrument_id) : nil
        networkApi.rx.request(.closeAllOrder(contractId: contractId)).exs_MJObjectMap(EXSVoidModel.self).subscribe { [weak self](_) in
            guard let strong = self else {return}
            strong.requestPositionData(new: true)
            //一键全平只平 当前持仓 English: One click full balance only balances current positions
           // strong.requestTransactionData(instrument_id:strong.itemModel?.instrument_id ?? 0)
            EXAlert.dismissEnd {
                EXAlert.showSuccess(msg: "cp_extra_text109".ex_localized())
                strong.queryAsset()
            }
            
        } onError: { (error) in
          
        }.disposed(by: self.exs_disposeBag)
    }
    //MARK: 持仓列表 English: MARK: Position List
    func requestPositionData(new: Bool? = false,updateAsset: Bool? = false) {//new 优化的后台新加的接口 English: New optimized backend interface added
        if  EXSwapPlatformSDK.shared.activeAccount == nil {
            return
        }
        if !SLUserConfig.checkHasOpenContract {
            return
        }
        networkApi.exs_hideAutoLoading()
        EXContractNetwork.getUserPositionOrAsset(onlyAccount: false, marginCoin: "",new: new) { (model) in
            self.allCurrentPositionData = model.positionList
            //平仓立即刷新 English: Close position and refresh immediately
            
            self.refreshData(reloadList: new ?? false)
            //标记价格刷新会更新仓位，这里不刷 English: The marked price refresh will update the position, so it will not be refreshed here
            if let update = updateAsset,update == true && new == false{
                self.wsEventSubject.onNext(.closePositionSuccess)
            }
        } failure: { (_) in
            
        }.disposed(by: self.exs_disposeBag)
    }
    
    //刷新资产 English: Refresh Assets
    func queryAsset(){
        if  EXSwapPlatformSDK.shared.activeAccount == nil {
            return
        }
        if !SLUserConfig.checkHasOpenContract {
            return
        }
        networkApi.exs_hideAutoLoading()
        EXContractNetwork.getUserPositionOrAsset(onlyAccount: true, marginCoin: "",new: false) { (model) in
            self.wsEventSubject.onNext(.updateAssetInfo)
        } failure: { (_) in
            
        }.disposed(by: self.exs_disposeBag)
        
    }


    func requestPlanTransactionData(instrument_id: Int64) {
        if !hasLogin() || instrument_id == 0 {
            return
        }
        if !SLUserConfig.checkHasOpenContract {
            return
        }
        let model = EXContractQueryCurrentOrderList()
        model.contractId = instrument_id
        let planEntrustOnlyCurrent = EXStoreData.storeBool(forKey: planEntrustOnlyCurrentContract)
        if planEntrustOnlyCurrent == false{
            model.contractId = -1
        }
        model.needTrigger = true
        model.limit = EXContactHomeOrderListViewMaxCount
        networkApi.exs_hideAutoLoading()
        EXContractNetwork.queryCurrentOrderList(model: model) { (orderlist,_,count)  in
            self.planEntrustmentDataCount = count
            self.planEntrustmentData = orderlist
            self.wsEventSubject.onNext(.planEntrustmentData)
        } failure: { (_) in
        }.disposed(by: self.exs_disposeBag)
    }
    
    //MARK: 资金费率/价格 English: MARK: Fund rate/price
    func p_queryPublicMarketInfo() {
        let instrumentId = self.currentItemModel?.instrument_id ?? 0
        let symbol = self.currentItemModel?.symbol ?? ""
        if instrumentId != 0, !symbol.isEmpty {
            networkApi.exs_hideAutoLoading()
            networkApi.rx.request(.publicMarketInfo(symbol: symbol, contractId: instrumentId)).exs_MJObjectMap(SLPublicMarketInfo.self).subscribe(onSuccess: {[weak self] (info) in
                if self?.currentItemModel?.instrument_id != instrumentId {
                    return
                }
                if self?.isScrolling == true{return}
                self?.wsEventSubject.onNext(.publicMarketData(info))
            }).disposed(by: self.exs_disposeBag)
        }
    }
    
    
    
    //当取消更新当前委托和计划委托 English: When canceling the update of the current and planned delegation
    func requestTransactionData() {
        let instrument_id = self.currentItemModel?.instrument_id ?? 0
        requestCurrentTransactionData(instrument_id: instrument_id)
        requestPlanTransactionData(instrument_id: instrument_id)
    }
    /// 获取当前委托列表 English: /Get the current delegation list
    func requestCurrentTransactionData(instrument_id: Int64) {
        if !hasLogin() || instrument_id == 0 {
            return
        }
        let model = EXContractQueryCurrentOrderList()
        model.contractId = instrument_id
        
        let currentEntrustOnlyCurrent = EXStoreData.storeBool(forKey: currentEntrustOnlyCurrentContract)
        if currentEntrustOnlyCurrent == false{
            model.contractId = -1
        }
        model.limit = EXContactHomeOrderListViewMaxCount
        networkApi.exs_hideAutoLoading()
        EXContractNetwork.queryCurrentOrderList(model: model) { (orderlist,_,count) in
            self.currentEntrustmentDataCount = count
            self.currentEntrustmentData = orderlist
//            //MARK: fix 测试 English: MARK: Fix test
//            for (index,item) in self.currentEntrustmentData.enumerated(){
//                if index == 0 {
//                    item.cum_qty = "30"
//                }else{
//                    item.cum_qty = "2"
//                }
//            }
            self.wsEventSubject.onNext(.currentEntrustmentData)
        } failure: { (_) in
        }.disposed(by: self.exs_disposeBag)
    }
    
    //取消订单 English: Cancel order
    func handleCancelOrder(_ order : EXContractOrderModel,isConditionOrder: Bool = false) {
        let orderIdstr = isConditionOrder ? order.triggerOrderId : order.orderId
        let orderId = Int64(orderIdstr) ?? 0
        EXContractNetwork.cancelOrder(contractId: order.instrument_id, orderId:orderId,isConditionOrder: isConditionOrder) {
            EXAlert.showSuccess(msg: "cp_content_text3".ex_localized())
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
                let instrument_id = self.currentItemModel?.instrument_id ?? 0
                if isConditionOrder {
                    self.requestPlanTransactionData(instrument_id: instrument_id)
                }else{
                    self.requestCurrentTransactionData(instrument_id: instrument_id)
                }
//                self.queryAsset() //请求资产并刷新可开多 English: Requesting Assets and Refreshing Multiple Openable Assets
                self.requestPositionData(updateAsset: true)//请求仓位 / 资产并刷新可开多 English: Requesting positions/assets and refreshing available open positions
            }
        } failure: { (error) in
            
            EXAlert.showFail(msg: "cp_content_text4".ex_localized())
        }
    }
    
    /// 退出登录时清空数据 English: /Clear data when logging out
    func cleanDataWhenLogout() {
        self.resetData()
//        debug//print("合约##--清空仓位数据") English: DebugPrint ("Contract # # - Clear Position Data")
        self.positionDatas = []
        self.currentEntrustmentData = []
        self.planEntrustmentData = []
        self.allCurrentPositionData = []
        self.currentUserConfig  = SLUserConfig()
        //MARK: 更新标题数量 ,清空底部3个列表 English: MARK: Update the number of titles, clear the bottom 3 lists
        self.wsEventSubject.onNext(.positionData)
        self.wsEventSubject.onNext(.currentEntrustmentData)
        self.wsEventSubject.onNext(.planEntrustmentData)
       
    }
    
    
    func updateUserConfig(completion:(()->())? = nil,fail:(()->())? = nil,sendEvent: Bool = true) {
       
        let instrumentId = self.currentItemModel?.instrument_id ?? 0
        if !hasLogin() ||  instrumentId == 0 {
            fail?()
            return
        }
        networkApi.rx
            .request(.getUserConfig(id: instrumentId))
            .exs_MJObjectMap(SLUserConfig.self)
            .retry(3)
            .subscribe(onSuccess: {[weak self] (config) in
                guard let `self` = self else {return}
                self.shouldUpdateUserConfig = true
                config.contractId = instrumentId
                //权限设置测试用 English: For testing permission settings
//                config.forceKycOpen = "0"
//                config.authLevel = "0"
                self.currentUserConfig = config
                self.currentItemModel?.ex_contractInfo?.leverAndMaxCoinDic = config.leverAndMaxCoinDic
                self.currentItemModel?.ex_contractInfo?.leverAndMaxValueDic = config.leverAndMaxValueDic
                if sendEvent {
                    self.wsEventSubject.onNext(.updateUserConfig)
                }
                
                if let info = self.currentItemModel?.ex_contractInfo,
                                   info.area == .CONTRACT_BLOCK_SIMULATION {
                                    self.queryCoupon()
                                }
                if completion != nil {
                    completion?()
                }
            }).disposed(by: self.exs_disposeBag)

    }
    
    func queryData() {
        if !hasLogin()  {
            return
        }
        //MARK: 这里主要通过 updateUserConfig 来处理账号被挤掉的情况 English: MARK: Here, we mainly use updateUserConfiguration to handle the situation of account being squeezed out
        queryUserConfig()
        //MARK: 未开通合约直接请求   会报未登录 English: MARK: Directly requesting without opening a contract will report as not logged in
         if SLUserConfig.checkHasOpenContract == false {
            return
        }
        //MARK: 刷新仓位 / 计划委托 历史委托  底部的列表 English: MARK: Refresh the list at the bottom of the position/plan delegation history delegation
        self.requestPositionData()
        self.requestTransactionData()
    }
    
    func queryUserConfig() {
        //updateUserConfig()
        let instrumentId = self.currentItemModel?.instrument_id ?? 0
        if !hasLogin() ||  instrumentId == 0 {
            return
        }
        networkApi.rx
            .request(.getUserConfig(id: instrumentId))
            .exs_MJObjectMap(SLUserConfig.self)
            .subscribe(onSuccess: {[weak self] (config) in
                self?.currentUserConfig = config
                guard let `self` = self else {return}
                if self.updatedOpenOrderUnit == false {
                    self.wsEventSubject.onNext(.updateOpenUnit)
                    self.updatedOpenOrderUnit = true
                }
            }).disposed(by: self.exs_disposeBag)
    }
    
    func queryCoupon() {
           if currentUserConfig.shouldQueryCoupon() {
               networkApi.rx
                   .request(.receiveCoupon)
                   .exs_MJObjectMap(EXSVoidModel.self)
                   .subscribe { (_) in
                   } onError: { (_) in
                   }.disposed(by: self.exs_disposeBag)
           }
       }
}
///公告栏相关 English: /Announcement board related
extension EXContractHomeViewModel{
    func queryNoticeBarInfo(){
        if self.hasLogin() &&  SLUserConfig.checkHasOpenContract == true{
            //MARK: 已登陆且开通 开通合约 English: MARK: Logged in and opened contract
            networkApi.rx
                .request(.getNoticeInfoLogined)
                .exs_customObjectMap(EXContractNotice.self)
                .subscribe(onSuccess: {[weak self] (notice) in
                    guard let `self` = self else {return}
                    self.wsEventSubject.onNext(.noticeInfo(info: notice))
                },onError: { [weak self] (_) in
                    guard let `self` = self else {return}
                    self.wsEventSubject.onNext(.noticeInfo(info: nil))
                }).disposed(by: self.exs_disposeBag)
        }else{
            networkApi.rx
                .request(.getNoticeInfoNotLogined)
                .exs_customObjectMap(EXContractNotice.self)
                .subscribe(onSuccess: {[weak self] (notice) in
                    guard let `self` = self else {return}
                    self.wsEventSubject.onNext(.noticeInfo(info: notice))
                },onError: { [weak self] (_) in
                    guard let `self` = self else {return}
                    self.wsEventSubject.onNext(.noticeInfo(info: nil))
                }).disposed(by: self.exs_disposeBag)
        }
       
    }
    ///登录才会调用 English: /Only when logged in will it be called
    func closeNoticeBar(){
       
        networkApi.rx
            .request(.closeNoticeBar)
            .exs_MJObjectMap(EXSVoidModel.self)
            .subscribe(onSuccess: {[weak self] (config) in
                guard let `self` = self else {return}
                self.wsEventSubject.onNext(.noticeClose)
            },onError: { [weak self] (_) in
              
            }).disposed(by: self.exs_disposeBag)
    }
}

