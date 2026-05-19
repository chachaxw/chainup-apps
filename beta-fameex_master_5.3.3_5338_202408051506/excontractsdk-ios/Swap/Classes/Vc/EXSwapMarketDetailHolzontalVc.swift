////
////  EXSwapMarketDetailHolzontalVc.swift
////  Chainup
////
////  Created by 李超 on 2021/6/8.
////  Copyright © 2021 Chainup. All rights reserved.
////
//
//import UIKit
//import RxSwift
//import SwiftEventBus
//import EXKit
//// 带入指标/带入幅图开关/k线数据 English: Import indicators/Import map switches/K-line data
//
//class EXSwapMarketDetailHolzontalVc: UIViewController,StoryBoardLoadable {
//    
//    @IBOutlet weak var topbgView: UIView!
//    
//    @IBOutlet var leftSafeAreaWidth: NSLayoutConstraint!
//    @IBOutlet var rightSafeAreaWidth: NSLayoutConstraint!
//    //时间轴 English: time axis
//    @IBOutlet weak var topLeftConstraint: NSLayoutConstraint!
//    @IBOutlet var indexFooterView: EXCOHorizonlIndexContainer!
////    @IBOutlet var topSafeAreaWidth: NSLayoutConstraint!
////    @IBOutlet var topRSafeAreaWidth: NSLayoutConstraint!
//    @IBOutlet var klineView: EXCOKLineView!
//    
//    @IBOutlet var topLeftHeader: EXCOHorizontalTopLeft!
//    // 右侧指标-主 English: Right indicator - main
//    @IBOutlet var mainMenu: EXCOHorizontalMainMenu!
//    // 右侧指标-辅助 English: Right indicator - auxiliary
//    @IBOutlet var assistantMenu: EXCOHorizonAssistantMenu!
//    let menuPublish : PublishSubject<EXCOMenuSelectionModel> = PublishSubject.init()
//    @IBOutlet var closeBtn: UIButton!
//    var accountType:EXSKLineAccountType = .coin
//    var viewModel = EXCOMarketHorlzontalViewModel()
//    var coinMapEntity:EXSCoinMapEntity =  EXSCoinMapEntity()
//    var itemModel:EXSwapItemModel?
//    var newKlineDataCalculated = false
//    var lastklineData = EXSKLineChartItem()
//    var orderHistory = [EXContractOrderModel]() //历史订单数据 English: Historical order data
//    lazy var line: UIView = {
//        let v = UIView()
//        v.backgroundColor = .Ex.kLine.fill4 //UIColor.ThemeView.seperator
//        return v
//    }()
//    lazy var leftLine: UIView = {
//        let v = UIView()
//        v.backgroundColor = .Ex.kLine.fill4
//        return v
//    }()
//    lazy var rightline: UIView = {
//        let v = UIView()
//        v.backgroundColor = .Ex.kLine.fill4
//        return v
//    }()
//    lazy var rightBottomline: UIView = {
//        let v = UIView()
//        v.backgroundColor = .Ex.kLine.fill4
//        return v
//    }()
//    var hasLoadedAllKline = false
//
//    var menuModel:EXCOMenuSelectionModel = EXCOMenuSelectionModel(){
//        didSet {
//
//        }
//    }
//    var wsService:EXSContractKLineService = EXSContractKLineService()
////    var wsVm:EXNewKlineWsVm = EXNewKlineWsVm()
//    
//    override var prefersStatusBarHidden: Bool {
//        get {
//            return true
//        }
//    }
//    
//    override var prefersHomeIndicatorAutoHidden: Bool { return true }
//
//    
//    
//    func handleSafeArea(){
//        topLeftConstraint.constant =  EX_NAV_STATUS_HEIGHT
//        leftSafeAreaWidth.constant = EX_NAV_STATUS_HEIGHT
//        rightSafeAreaWidth.constant = EX_TABBAR_BOTTOM
//    }
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        self.handleSafeArea()
//        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
//        closeBtn.backgroundColor = .clear //UIColor.ThemeView.card1
//        topbgView.backgroundColor = .clear //UIColor.ThemeView.card1
//        self.indexFooterView.backgroundColor = .clear //UIColor.ThemeView.card1
//        self.mainMenu.backgroundColor = .clear //UIColor.ThemeView.card1
//        self.assistantMenu.backgroundColor = .clear //UIColor.ThemeView.card1
//        self.topLeftHeader.backgroundColor =  .clear //UIColor.ThemeView.card1
////        self.assistantMenu.containView.backgroundColor = .red// UIColor.ThemeView.card1
////        self.mainMenu.containerView.backgroundColor =  .red //UIColor.ThemeView.card1
//        self.mainMenu.configSwapStyle()
//        self.assistantMenu.configSwapStyle()
//        for item in self.mainMenu.menuBtns{
//            item.backgroundColor = .clear //UIColor.ThemeView.card1
//        }
//        for item in self.assistantMenu.menus{
//            item.backgroundColor = .clear //UIColor.ThemeView.card1
//        }
//        
//        self.handleNotifi()
////        self.handleKlinePrePage()
////        self.handlekLineWs()
////        self.handlekLineScale()
//        self.klineView.chartsView.style = HorizontalScreenlineStyle.lineStyle
//        self.handleMenu()
//        self.klineView.chartsView.backgroundColor = UIColor.ThemekLine.viewBg
//        self.klineView.isSwap = true
//        self.klineView.clipsToBounds = true
//        self.klineView.priceDecimal = coinMapEntity.price
//        self.klineView.volumeDecimal = coinMapEntity.volume
//        self.klineView.contactM = self.itemModel?.ex_contractInfo
//        closeBtn.setImage(UIImage.exs_themeImageNamed(imageName: "public_close"), for: .normal)
//        topLeftHeader.swapConfig()
//        self.handleScale(key: self.menuModel.scaleKey)
//        self.view.addSubview(line)
//        line.snp.makeConstraints { make in
//            make.top.equalTo(self.indexFooterView.snp.bottom)
//            make.left.equalTo(self.klineView)
//            make.right.equalTo(self.mainMenu.snp.right)
//            make.height.equalTo(0.5)
//        }
//        self.view.addSubview(leftLine) //最左侧的线 English: Leftmost line
//        self.view.addSubview(rightline) //最右侧的线 English: The rightmost line
//        self.view.addSubview(rightBottomline)
//        leftLine.snp.makeConstraints { make in
//            make.top.equalTo(self.indexFooterView.snp.bottom)
//            make.right.equalTo(self.klineView.snp.left)
//            make.width.equalTo(0.5)
//            make.bottom.equalTo(self.klineView.snp.bottom).offset(-16)
//        }
//        rightline.snp.makeConstraints { make in
//            make.top.equalTo(self.indexFooterView.snp.bottom)
//            make.left.equalTo(self.mainMenu.snp.right)
//            make.width.equalTo(0.5)
//            make.bottom.equalTo(self.klineView.snp.bottom).offset(-16)
//        }
//        rightBottomline.snp.makeConstraints { make in
//            make.top.equalTo(self.rightline.snp.bottom)
//            make.left.equalTo(self.klineView.snp.right)
//            make.right.equalTo(self.mainMenu.snp.right)
//            make.height.equalTo(0.5)
//        }
//    }
//    override func viewDidAppear(_ animated: Bool){
//        super.viewDidAppear(animated)
//        let show = EXStoreData.storeBool(forKey: swapKlineHistoryShow)
//        if show{
//            dealSellAndBuy(showBuySell: show)
//        }
//    }
//    override func viewDidDisappear(_ animated: Bool) {
//        super.viewDidDisappear(animated)
//        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
//    }
//    
//    //MARK:  sell buy 数据源 处理 English: MARK: sell buy data source processing
//    func dealSellAndBuy(showBuySell: Bool){
//        self.reloadKLineV(show: true)
//    }
//    //sell buy 处理 English: Sell buy processing
//    func reloadKLineV(show: Bool){
//        // 处理数据源 English: Processing data sources
//        let datas = self.klineView.kLineDatas
//        if datas.count == 0 {
//            return
//        }
//        if self.orderHistory.count == 0 {
//            return
//        }
//        DispatchQueue.global().async{ [weak self] in
//            guard let newSelf = self else{return}
//            var newklineData = datas
//            if show{
//               
//                newklineData = EXContractOrderModel.getHistoryBuySellKlineData(orderList: newSelf.orderHistory, timeInterval: newSelf.menuModel.scaleKey, orginKlinedData: datas)
//            }else{
//                newklineData = datas.map({ item in
//                    item.buySellPointShow = false
//                    return item
//                })
//            }
//            DispatchQueue.main.async{
//                // 刷新k线 English: Refresh K-line
//                newSelf.klineView.reloadData(data: newklineData)
//            }
//        }
//    }
//    
//    func handlekLineWs() {
//        self.wsService.register()
//        self.wsService.accountType = self.accountType
//        self.wsService.currentItemModel = self.itemModel
//        self.wsService.kLineHistroyDatas
//            .subscribe(onNext:{[weak self] (historys,hasPre) in
//                guard let `self` = self else {return}
//                self.handleHistory(klineData: historys,prepage: hasPre)
//        }).disposed(by: self.disposeBag)
//
//        self.wsService.kLineNowDatas
//            .subscribe(onNext:{[weak self] historys in
//                guard let `self` = self else {return}
//                self.handleNow(klineData: historys)
//            }).disposed(by: self.disposeBag)
//
//        self.wsService.tickPriceData
//            .subscribe(onNext:{[weak self] item in
//                guard let `self` = self else {return}
//                self.handlePrice(item: item)
//            }).disposed(by: self.disposeBag)
//        
//        wsService.kLineHistroyFinish
//               .subscribe(onNext:{[weak self] (finished) in
//                   guard let `self` = self else {return}
//                   if finished {
//                       self.hasLoadedAllKline = true
//                       self.klineView.hideLoading()
//                   }
//               }).disposed(by: self.disposeBag)
//    }
//    
//    func handleKlinePrePage() {
//        SwiftEventBus.onMainThread(self, name: EXCOEventBusConst.onKlinePrePageTrigger) {[weak self] result in
//            guard let `self` = self else {return}
//
//            if self.hasLoadedAllKline {
//                return
//            }
//            self.wsService.wsHistoryKLinePre()
//            self.klineView.showLoading()
//        }
//    }
//    
//    func handleMenu(){
//        
//        mainMenu.selectOn(type: menuModel.masterType)
//        self.klineView.updateMasterAlgorithm(to: menuModel.masterType)
//        mainMenu.masterAlgorithmCallback = {[weak self] type in
//            self?.menuModel.masterType = type
//            self?.klineView.updateMasterAlgorithm(to: type)
//            self?.klineView.hideSelection()
//        }
//        
//        assistantMenu.selectOn(type: menuModel.assitantType)
//        self.klineView.updateAssistantAlgorithm(to: menuModel.assitantType)
//
//        assistantMenu.assistantAlgorithmCallback = {[weak self] type in
//            self?.menuModel.assitantType = type
//            self?.klineView.updateAssistantAlgorithm(to: type)
//            self?.klineView.hideSelection()
//
//        }
//
//        
//    }
//    
//    func handlekLineScale(){
//        indexFooterView.loadItems(true)
//        indexFooterView.defaultScale(key:menuModel.scaleKey)
////        self.handleScale(key: menuModel.scaleKey)
//        indexFooterView.scaleDidChage = {[weak self] key in
//            if self?.menuModel.scaleKey == key {
//                return
//            }
//            self?.menuModel.scaleKey = key
//            self?.handleScale(key: key)
//            self?.klineView.hideSelection()
//            self?.hasLoadedAllKline = false
//            self?.klineView.showLoading()
//        }
//    }
//    
//    func handleHistory(klineData:[EXSKLineChartItem],prepage:Bool = false) {
//        
//        //MARK: b s 处理 English: MARK: b s processing
//        var newklineData = klineData
//        let show = EXStoreData.storeBool(forKey: swapKlineHistoryShow)
//        if show{
//            newklineData = EXContractOrderModel.getHistoryBuySellKlineData(orderList: self.orderHistory, timeInterval: self.menuModel.scaleKey, orginKlinedData: klineData)
//            if newklineData.count > 0 {
//                lastklineData = newklineData.last!
//            }
//        }
//        
//        self.klineView.hideLoading()
//        if prepage {
//            klineView.reloadPreData(data: newklineData)
//        }else {
//            klineView.reloadData(data: newklineData)
//        }
//    }
//    
//    
//    
//    func handleNow(klineData:EXSKLineChartItem) {
//        
//        //MARK: b s 处理 最新价不 English: MARK: b s processing the latest price not
//        // 最新的k线处理 会一直刷 -- 只计算一次就行// English: 
//        var newklineData = klineData
//        let show = EXStoreData.storeBool(forKey: swapKlineHistoryShow)
//        if show{
//            if self.orderHistory.count > 0{
//                if klineData.id > lastklineData.id{ //最新的k线已刷新了 English: The latest candlestick chart has been refreshed
//                    newKlineDataCalculated = false
//                }else if klineData.id == lastklineData.id{ //最后一根一样 English: The last one is the same
//                    newklineData.buySellPointShow = lastklineData.buySellPointShow
//                    newklineData.buySellKlineShowTop = lastklineData.buySellKlineShowTop
//                    newklineData.buySellKlineShowBottom = lastklineData.buySellKlineShowBottom
//                }
//                if newKlineDataCalculated == false {
//                    let listData = EXContractOrderModel.getHistoryBuySellKlineData(orderList: self.orderHistory, timeInterval: self.menuModel.scaleKey, orginKlinedData: [klineData])
//                    newklineData = listData[0]
//                    lastklineData = newklineData
//                    newKlineDataCalculated = true
//                }
//            }
//        }
//        klineView.appendData(data: newklineData)
//    }
//    
//    func handlePrice(item:EXSTickItem) {
//       
//        //处理高低价精度 English: Handling high and low price precision
//        item.vol = EXSwapItemModel.qty24VolumeDisplay(instrument_id: self.itemModel?.instrument_id ?? 0, qty24: item.vol)
//        item.precision = Int(self.coinMapEntity.price) ?? 2
//
//       // 更新价格人民币兑换 English: Update price for RMB exchange
//        
//        if let swap = self.itemModel{
//            swap.last_px = item.close
//            item.rmb = swap.showRatePrice()
//        }
//        topLeftHeader.updateSwapPrices(item: item,title:self.coinMapEntity.name)
//        klineView.chartsView.nowValue = CGFloat(Double(item.close)!)
//    }
//    
//    func handleScale(key:String) {
//        wsService.candleScale.accept(key)
//        klineView.chartSerieSwitchToLineMode(on: (key == EXNewKlineWsVm.keyLine))
//        klineView.updateMasterAlgorithm(to:menuModel.masterType)
//    }
//
//    @IBAction func close(_ sender: Any) {
//        menuPublish.onNext(self.menuModel)
//        UIDeviceManger.shared.blockRotation = .portrait
//        self.navigationController?.popViewController(animated: true)
//    }
//    
//}
//
//extension EXSwapMarketDetailHolzontalVc {
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        if #available(iOS 11.0, *) {
//            self.setNeedsUpdateOfHomeIndicatorAutoHidden()
//        } else {
//            // Fallback on earlier versions
//        }
//        self.handleKlinePrePage()
//        self.handlekLineWs()
//        self.handlekLineScale()
//        UIViewController.attemptRotationToDeviceOrientation()
//        wsService.getHistoriesAndTicker()
//    }
//    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        self.klineView.isHidden = true
//        wsService.cancelAll()
//    }
//    
//    func handleNotifi() {
//        _ = NotificationCenter.default.rx
//            .notification(UIApplication.didBecomeActiveNotification)
//            .takeUntil(self.rx.deallocated) //页面销毁自动移除通知监听 English: Page destruction automatically removes notification listening
//            .subscribe(onNext: {[weak self] noti in
//                self?.homeBtnAction(false)
//            })
//        
//        _ = NotificationCenter.default.rx
//            .notification(UIApplication.willResignActiveNotification)
//            .takeUntil(self.rx.deallocated) //页面销毁自动移除通知监听 English: Page destruction automatically removes notification listening
//            .subscribe(onNext: {[weak self] noti in
//                self?.homeBtnAction(true)
//            })
//        
//        _ = NotificationCenter.default.rx
//            .notification(Notification.Name(rawValue: NOTI_CONCTRACT_WS_RECONNECTED))
//            .takeUntil(self.rx.deallocated) //页面销毁自动移除通知监听 English: Page destruction automatically removes notification listening
//            .subscribe(onNext: {[weak self] noti in
//                self?.wsService.reConnectAll()
//            })
//    }
//    
//    func homeBtnAction(_ enterBackground:Bool) {
//        //注意当前控制器 English: Pay attention to the current controller
//        guard let top = AppService.topViewController() else {return}
//        if top == self {
//            if enterBackground {
//                wsService.cancelAll()
//            }else {
//                wsService.getHistoriesAndTicker()
//            }
//        }
//    }
//}

