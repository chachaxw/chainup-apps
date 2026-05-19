//
//  EXKLineDetailVC.swift
//  Chainup
//
//  Created by liuxuan on 2020/10/13.
//  Copyright © 2020 Chainup. All rights reserved.
//

import UIKit
import RxSwift
import SwiftEventBus

class EXKLineDetailVC: BaseVC,NavigationPlugin {
    //UI
    internal lazy var navigation : EXNavigation = {
        let nav =  EXNavigation.init(affectScroll: nil, presenter: self)
        return nav
    }()
    
    lazy var detailTable : UITableView = {
        let tableView = UITableView()
        tableView.extUseAutoLayout()
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.estimatedRowHeight = 0
        tableView.estimatedSectionHeaderHeight = 0
        tableView.register(TransactionDetailsTC.classForCoder(), forCellReuseIdentifier: "TransactionDetailsTC")
        
        tableView.register(TransactionDepthTC.classForCoder(), forCellReuseIdentifier: "TransactionDepthTC")
       
        tableView.register(UINib.init(nibName: "EXMarketDetailRecordCell", bundle: nil), forCellReuseIdentifier: "EXMarketDetailRecordCell")
        tableView.register(UINib.init(nibName: "EXCoinIntroduceCell", bundle: nil), forCellReuseIdentifier: "EXCoinIntroduceCell")
        
        tableView.backgroundColor = UIColor.ThemekLine.viewBg
        tableView.mj_header = EXRefreshHeaderView (refreshingBlock: {[weak self] in
            guard let mySelf = self else{return}
            mySelf.wsService.reConnectAll()
        })
        return tableView
    }()
    
    lazy var footer:EXKlineFooter = {
        let footer = EXKlineFooter.init(type: self.kDetailType)
        return footer
    }()
    
    lazy var tableHeader:EXKlineDetailTableHeader = {
        let header = EXKlineDetailTableHeader.init(entity: self.entity)
        return header
    }()
    
    var customNaviItem = EXNaviDrawerView()
    var sectionHeader :EXMarketDetailSectionHeader = EXMarketDetailSectionHeader()
    var drawerHub:EXDrawerHub?
    
    //model
    var kDetailType:KLineAccountType = .coin
    var entity:CoinMapEntity =  CoinMapEntity()
    var infoType = TransactionDetailsType.depth
    var introduceModel :EXIntroduceModel = EXIntroduceModel()
    var userSymbolsVm = UserSymbolsVM()
    var menuModel = EXMenuSelectionModel.init()

    //datas
    var max:Float = 0
    var hasLoadedAllKline = false
    var tableViewRowDatas : [EXTickDataItem] = []
    var depthChartItems:[CHKDepthChartItem] = []
    var depthTableViewRowDatas : [TransactionDepthEntity] = []
    var depthChartPrice = ""
    var asksAlllength = "0"//Total selling depth
    var buysAlllength = "0"//Total depth of purchase
    
    //service
    var wsService:EXMarketKlineService = EXMarketKlineService()
    var netWorthTimer: Disposable? = nil
    var interfaceData:EXInterfaceData = EXInterfaceData.init(page: .kline, action: .subHistory)
    var track_begin:Date?
    var track_end:Date?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        reloadDepthTableViewRowDatas()
        prepareCurrentUI()
        registerSignals()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.entity.name.count > 0 {
            getHistoriesKline()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        wsService.cancelAll()
    }
    
    deinit {
        wsService.fetchDepthChartDataTimer?.invalidate()
        wsService.fetchDepthChartDataTimer = nil
    }
    
    @objc func handleInterfaceData() {
        if self.defineCurrentVcIsTopVc() == false {
            return
        }
        
        var duration = ""
        var errorType = "0"
        if let begin = self.track_begin,let end = self.track_end {
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
        if tableHeader.klineViewIsEmpty() {
            if wsService.service.isConnecting() == false {
                errorType = "1"
            }else if tableHeader.klineView.kLineDatas.count == 0 {
                errorType = "2"
            } else {
                errorType = "3"
            }
        }
        interfaceData.errorType = errorType
        interfaceData.duration = duration
        EXTracking.shared.uploadInterFaceData(model: interfaceData)
    }
}

//MARK: Listening
extension EXKLineDetailVC {
    
    func registerSignals() {
        handleNotifi()
        handlekLineWs()
        //K-line flipping
        SwiftEventBus.onMainThread(self, name: EXEventBusConst.onKlinePrePageTrigger) {[weak self] result in
            guard let `self` = self else {return}
            if self.hasLoadedAllKline {
                return
            }
            self.wsService.wsHistoryKLinePre()
            self.tableHeader.klineView.showLoading()
        }
        tableHeader.onMenuActionCallback = {[weak self] (action,sender,key) in
            self?.handleMenuAction(action: action, sender: sender,key: key)
        }
    }
    
    
    func handleScale(key:String) {
        if self.menuModel.scaleKey == key {
            return
        }
        self.trackActionOn()
        self.hasLoadedAllKline = false
        self.menuModel.scaleKey = key
        self.wsService.candleScale.value = key
        tableHeader.klineView.showLoading()
        tableHeader.klineView.chartSerieSwitchToLineMode(on: (key == EXKlineWsVm.keyLine))
        tableHeader.klineView.updateMasterAlgorithm(to: tableHeader.klineView.menuModel.masterType)
    }
    ///Click on Menu
    func handleMenuAction(action:KLineFilterMenuAction,sender:UIButton,key:String) {
        if action == .changeScale {
//            guard let key = sender.titleLabel?.text  else {return}
            self.handleScale(key: key)
        }else if action == .zoom {
            let horizontal = EXMarketDetailHolzontalVc.instanceFromStoryboard(name: StoryBoardNameMarket)
            horizontal.accountType = self.kDetailType
            horizontal.menuModel = self.menuModel
            horizontal.coinMapEntity = self.entity
            //TODO: Shared menu
            horizontal.menuPublish
                .subscribe(onNext:{[weak self] model in
                    guard let `self` = self else {return}
                    self.changeMenuModel(menuModel: model)
                }).disposed(by: self.disposeBag)
            self.navigationController?.pushViewController(horizontal, animated: true)
        }
    }
    
    func changeMenuModel(menuModel:EXMenuSelectionModel) {
        self.menuModel = menuModel
        tableHeader.menuModel = menuModel
        tableHeader.menuBar.selectDefaultScaleType(type: menuModel.scaleKey)
        self.handleScale(key: menuModel.scaleKey)
    }
    
    func handlekLineWs() {
        //Subscribe to historical klines/historical orders/depth+tickers first (tickers can be uploaded from other pages before subscribing)
        //Later scheduled to be the latest on the K line/the latest on orders
        wsService.entity = entity
        wsService.register()
        wsService.startFetchDepthChartDataTimer()
        
        //History k and Latest k
        wsService.kLineHistroyDatas
            .subscribe(onNext:{[weak self] (historys,hasPrePage) in
                guard let `self` = self else {return}
                self.handleHistory(klineData: historys,prepage: hasPrePage)
            }).disposed(by: self.disposeBag)
        
        wsService.kLineHistroyFinish
            .subscribe(onNext:{[weak self] (finished) in
                guard let `self` = self else {return}
                if finished {
                    self.hasLoadedAllKline = true
                    self.tableHeader.klineView.hideLoading()
                }
            }).disposed(by: self.disposeBag)
        
        wsService.kLineNowDatas
            .subscribe(onNext:{[weak self] historys in
                guard let `self` = self else {return}
                self.handleNow(klineData: historys)
            }).disposed(by: self.disposeBag)
        
        // ticker
        wsService.tickPriceData
            .subscribe(onNext:{[weak self] item in
                guard let `self` = self else {return}
                self.handlePrice(item: item)
            }).disposed(by: self.disposeBag)
        
        //depth
        wsService.depthData
            .subscribe(onNext:{[weak self] depthInfo in
                guard let `self` = self else {return}
                let depthData = depthInfo.0
                let maxAmount = depthInfo.1
                self.handleDepth(depthItem: depthData, max: maxAmount)
            }).disposed(by: self.disposeBag)
        
        wsService.orderHistoryData
            .subscribe(onNext:{[weak self] item in
                guard let `self` = self else {return}
                self.tableViewRowDatas = item
            }).disposed(by: self.disposeBag)
        
        wsService.orderNowData
            .subscribe(onNext:{[weak self] item in
                guard let `self` = self else {return}
                self.handleOrderData(items: item)
            }).disposed(by: self.disposeBag)
        
        //Depth charts
        wsService.depthChartData
            .subscribe(onNext: { [weak self] deptchChartData in
                guard let `self` = self else {return}
                guard deptchChartData.0.count>0 else {return}
                //todo chart
                self.handleDepthChartView(item: deptchChartData)
            }).disposed(by: disposeBag)
    }
    
    func handleDepthChartView(item:([CHKDepthChartItem],String)) {
        self.depthChartItems = item.0
        self.depthChartPrice = item.1
        tableHeader.updateItems(depthItems: depthChartItems, max: self.max, price: depthChartPrice, entity: self.entity)
        self.detailTable.mj_header.endRefreshing()
    }
    
    func handleHistory(klineData:[KLineChartItem],prepage:Bool = false) {
        if self.track_end == nil {
            self.track_end = Date()
        }
        tableHeader.klineView.hideLoading()
        if prepage {
            tableHeader.klineView.reloadPreData(data: klineData)
        }else {
            tableHeader.klineView.reloadData(data: klineData)
        }
        self.detailTable.mj_header.endRefreshing()
    }
    
    func handleNow(klineData:KLineChartItem) {
        tableHeader.klineView.appendData(data: klineData)
        self.detailTable.mj_header.endRefreshing()
    }
    
    func handlePrice(item:TickItem) {
        tableHeader.updateTicker(withItem: item)
        self.detailTable.mj_header.endRefreshing()
    }
    
    func handleOrderData(items:[EXTickDataItem]) {
        self.tableViewRowDatas = items + self.tableViewRowDatas
        if tableViewRowDatas.count > 20 {
            tableViewRowDatas.removeSubrange(20...tableViewRowDatas.count - 1)
        }
        if infoType == .deal {
            for (idx,item) in tableViewRowDatas.enumerated() {
                if let cell = detailTable.cellForRow(at: IndexPath.init(row: idx + 1, section: 0)) as? TransactionDetailsTC {
                    cell.setCellWithEntity(item, volDecimal:entity.volDecimal(), priceDecimal: entity.priceDecimal())
                }
            }
        }
        self.detailTable.mj_header.endRefreshing()
    }
    
    func handleDepth(depthItem:[CHKDepthChartItem],max:Float) {
        asksAlllength = "0"
        buysAlllength = "0"
        
        self.max = max
        
        let pricedecimals = Int(entity.price) ?? 8
        let voldecimals = Int(entity.volume) ?? 8
        
        let bidAry = depthItem.reversed().filter { item -> Bool in
            return item.type == .bid
        }
        let askAry = depthItem.filter { item -> Bool in
            return item.type == .ask
        }
        let asksN = min(20, askAry.count)
        let buysN = min(20, bidAry.count)
        reloadDepthTableViewRowDatas()
        
        for i in 0..<asksN {
            let item = askAry[i]
            depthTableViewRowDatas[i].asks = NSString.init(string:  "\(item.value)").decimalString1(pricedecimals)
            depthTableViewRowDatas[i].asksNum = NSString.init(string:  "\(item.amount)").decimalString1(voldecimals)
            asksAlllength = NSString.init(string: asksAlllength).adding(depthTableViewRowDatas[i].asksNum, decimals: voldecimals)
            depthTableViewRowDatas[i].askslength = asksAlllength
        }
        for i in 0..<buysN{
            let item = bidAry[i]
            depthTableViewRowDatas[i].buys = NSString.init(string:  "\(item.value)").decimalString1(pricedecimals)
            depthTableViewRowDatas[i].buysNum = NSString.init(string:  "\(item.amount)").decimalString1(voldecimals)
            buysAlllength = NSString.init(string: buysAlllength).adding(depthTableViewRowDatas[i].buysNum, decimals: voldecimals)
            depthTableViewRowDatas[i].buyslength = buysAlllength
        }
        if infoType == .depth {
            for (idx,item) in depthTableViewRowDatas.enumerated() {
                if let cell = detailTable.cellForRow(at: IndexPath.init(row: idx + 1, section: 0)) as? TransactionDepthTC {
                    cell.setCell(item, index: idx, asksAlllength: asksAlllength, buysAlllength: buysAlllength)
                }
            }
        }
        self.detailTable.mj_header.endRefreshing()
    }
}

//MARK:Action Buy & Sell & introduce & etf & etc.
extension EXKLineDetailVC {
    //business
    @objc func buyAction() {
        if self.kDetailType == .coin{
            EXNavigationHandler.sharedHandler.commandTradingCoin(entity.symbol, "buy")
        }else if self.kDetailType == .lever{
            EXNavigationHandler.sharedHandler.commandTradingCoin(entity.symbol, "leverBuy")
        }
    }
    
    @objc func sellAction() {
        if self.kDetailType == .coin{
            EXNavigationHandler.sharedHandler.commandTradingCoin(entity.symbol, "sell")
        }else if self.kDetailType == .lever{
            EXNavigationHandler.sharedHandler.commandTradingCoin(entity.symbol, "leverSell")
        }
    }
    
    //Get Introduction
    func requestCoinIntroduce() {
        if EXAppConfigManager.sharedInstance.isCoinIntroduceSupport(entity.coinName) {
            let item = EXAppMarketManager.sharedInstance.getCoinMapEntityBySymbol(entity.symbol)
            appApi.hideAutoLoading()
            appApi.rx.request(.coinIntroduce(coinSymbol: item.coinListEntity().name))
                .MJObjectMap(EXIntroduceModel.self,false)
                .subscribe{[weak self] event in
                    guard let myself = self else {return}
                    switch event {
                    case .success(let model):
                        myself.introduceSuccess(model)
                        break
                    case .error(_):
                        break
                    }
            }.disposed(by: self.disposeBag)
        }else {
            sectionHeader.hideIntroduce()
        }
    }
    
    func introduceSuccess(_ model:EXIntroduceModel) {
        sectionHeader.showIntroduce()
        self.introduceModel = model
        if infoType == .introduce {
            if let cell = detailTable.cellForRow(at: IndexPath.init(row: 0, section: 0)) as? EXCoinIntroduceCell {
                cell.bindModel(model)
            }
        }
    }
    
    //Obtain Net Worth
    func getNetWorth(){
        if entity.etfOpen != "1"{
            return
        }
        appApi.hideAutoLoading()
        appApi.rx.request(.etfNetValue(base: entity.coinName, quote: entity.marketName))
            .MJObjectMap(EXETFNetValueModel.self,false)
            .subscribe(onSuccess: {[weak self] (model) in
                self?.tableHeader.setNetWorth(model:model)
            }) { (error) in
                
            }.disposed(by: disposeBag)
    }
    
    func reloadDetailWithCoinPairName(_ name:String) {
        if self.entity.name == name {
            return
        }
        self.wsService.cancelAll()
        self.hasLoadedAllKline = false
        self.entity = EXAppMarketManager.sharedInstance.getCoinMapEntityByName(name)
        self.prepareETFHeader()
        tableHeader.coinEntity = entity
        self.wsService.entity = entity
        self.wsService.cancelAll()
        self.getHistoriesKline()
        self.wsService.startFetchDepthChartDataTimer()

        if kDetailType == .lever {
            customNaviItem.bind(entity.name.aliasCoinMapName() + " " + self.entity.multiple + "X")
        }else {
            customNaviItem.bind(entity.name.aliasCoinMapName())
        }
        customNaviItem.showTag(entity.name)
        requestCoinIntroduce()
        self.reloadDepthTableViewRowDatas()
        
        self.depthChartItems = []
        self.max = 0
        self.infoType = .depth
        sectionHeader.type = .depth
        self.detailTable.reloadData()
        updateRightItems()
    }
    
    func updateRightItems() {
        self.navigation.configRightItems(self.isCollect() ? ["quotes_share","quotes_favorites"] : ["quotes_share","quotes_notfavorited"])
    }
    
    func reloadDepthTableViewRowDatas(){
        var array : [TransactionDepthEntity] = []
        for _ in 0..<20{
            let entity = TransactionDepthEntity()
            array.append(entity)
        }
        depthTableViewRowDatas = array
    }
    
    func isCollect() ->Bool {
        let isCollect = XUserDefault.whetherCollectionCoinMap(entity.symbol)
        return isCollect
    }
}



//MARK:UI
extension EXKLineDetailVC {
    
    func prepareCurrentUI() {
        if #available(iOS 11.0, *) {
            detailTable.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        self.view.addSubview(detailTable)
        self.view.addSubview(footer)
        footer.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview()
            make.height.equalTo(isiPhoneX ? TABBAR_BOTTOM + 74 : 74)
            make.left.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        detailTable.snp.makeConstraints { (make) in
            make.top.equalTo(NAV_SCREEN_HEIGHT)
            make.left.equalToSuperview()
            make.bottom.equalTo(footer.snp.top)
            make.width.equalToSuperview()
        }
        self.detailTable.tableHeaderView = self.tableHeader
        footer.buyBtn.addTarget(self, action: #selector(buyAction), for: .touchUpInside)
        footer.sellBtn.addTarget(self, action: #selector(sellAction), for: .touchUpInside)
        handleScale(key: menuModel.scaleKey)
        handleNavigation()
        prepareETFHeader()
        requestCoinIntroduce()
    }
    
    func handleNavigation() {
        navigation.isLastNavigationStyle = true
        navigation.backView.backgroundColor = UIColor.ThemekLine.viewBg
        navigation.setdefaultType(type: .listtitle)
        if kDetailType == .coin || kDetailType == .lever {
            self.updateRightItems()
            navigation.rightItemCallback = {[weak self] tag in
                self?.handleRightAction(tag)
            }
        }
        
        let custom = EXNaviDrawerView()
        custom.backgroundColor = UIColor.ThemekLine.viewBg
        custom.titleLabel.textColor = UIColor.ThemekLine.labcolorLite
        navigation.addSubview(custom)
        if kDetailType == .lever {
            custom.bind(entity.name.aliasCoinMapName() + " " + self.entity.multiple + "X")
            custom.showTag(entity.name)
        }else {
            custom.bind(entity.name.aliasCoinMapName())
            custom.showTag(entity.name)
        }
        custom.tapBtn.addTarget(self, action: #selector(customBtnClick), for: .touchUpInside)
        custom.snp.makeConstraints { (make) in
            make.left.equalTo(navigation.popBtn.snp.right).offset(15)
            make.centerY.equalTo(navigation.popBtn)
            make.height.equalTo(38)
        }
        customNaviItem = custom
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        if EXThemeManager.current == EXThemeManager.day {
            return .default
        }else{
            return .lightContent
        }
    }
    
    @objc func customBtnClick(){
        self.view.isUserInteractionEnabled = false
        let vc = EXDrawerVC()
        if self.drawerHub == nil {
            if kDetailType == .coin{
                drawerHub = EXDrawerHub.init(type: .trade,symbol: self.entity.symbol,fromKline: true)
            }else if kDetailType == .lever {
                drawerHub = EXDrawerHub.init(type: .lever,symbol: self.entity.symbol,fromKline: true)
            }
        }
        drawerHub?.symbol = self.entity.symbol
        vc.addView(drawerHub!)
        vc.pullBlock = {[weak self] in
            self?.drawerHub?.cancelAllSubCoins()
            self?.view.isUserInteractionEnabled = true
        }
        
        drawerHub?.clickCellBlock = {[weak self](entity) in
            guard let mySelf = self else{return}
            mySelf.reloadDetailWithCoinPairName(entity.name)
            vc.pullAnimation()
        }
        drawerHub?.reloadSubCoins()
    }
    
    //Details page processing optional
    func handleRightAction(_ tag : Int){
        if tag == 0{
            let view = EXMarketShareView()
            view.vc = self 
            let height = 483 * SCREEN_WIDTH / 315
            if let img = self.view.screenShotwithFrame(CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height: height)) {
                view.setImg(img)
                EXAlert.showCenterView(view: view)
//                view.show(self)
            }
        }else if tag == 1{
            userSymbolsVm.handleFavorite(actionType: self.isCollect() ? .singleDelete : .singleAdd ,
                                         coinMaps: [self.entity],
                                         callback:{[weak self] success in
                                            guard let `self` = self else {return}
                                            self.updateRightItems()
                                         })
        }
    }
    
    func prepareETFHeader() {
        if entity.etfOpen == "1" {
            fetchNetWorthEveryThreeSeconds()
            detailTable.tableHeaderView?.frame =  CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height: EXKlineDetailTableHeader.getHeightHasETF(true))
        }else {
            endingNetworthFetch()
            detailTable.tableHeaderView?.frame =  CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height:  EXKlineDetailTableHeader.getHeightHasETF(false))
        }
    }
    
    func endingNetworthFetch() {
        netWorthTimer?.dispose()
    }
    
    func fetchNetWorthEveryThreeSeconds() {
        netWorthTimer?.dispose()
        getNetWorth()
        netWorthTimer = Observable<Int>.interval(3, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] (element) in
                guard let `self` = self else { return }
                self.getNetWorth()
            })
    }

}

//MARK: tableViewDelegate & datasource
extension EXKLineDetailVC :UITableViewDelegate,UITableViewDataSource {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //TODO turn off filtering
        tableHeader.hideMenu()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch infoType {
        case .introduce:
            return EXCoinIntroduceCell.getHeightByContent(self.introduceModel.introduction)
        case .deal:
            return (indexPath.row == 0) ? 36 : 30
        case .depth:
            return (indexPath.row == 0) ? 36 : 30
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 43
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        sectionHeader.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height:43)
        sectionHeader.headerActionCallback = {[weak self] type in
            guard let `self` = self else {return}
            self.infoType = type
            self.detailTable.reloadData()
        }
        return sectionHeader
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.infoType == .introduce {
            return 1
        }else {
            return 21
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch infoType {
        case .depth:
            if indexPath.row == 0 {
                let volumeTitle = "charge_text_volume".localized()+"(\(EXAppMarketManager.sharedInstance.getMarketLeft(self.entity.name).aliasName()))"
                let priceTitle = "contract_text_price".localized() + "(\(EXAppMarketManager.sharedInstance.getMarketRight(self.entity.name).aliasName()))"

                let cell : EXMarketDetailRecordCell = tableView.dequeueReusableCell(withIdentifier: "EXMarketDetailRecordCell") as! EXMarketDetailRecordCell
                cell.bindNames(leftTitle: volumeTitle, middleTitle: priceTitle, rightTitle: volumeTitle)
                return cell
            }else {
                let cell : TransactionDepthTC = tableView.dequeueReusableCell(withIdentifier: "TransactionDepthTC") as! TransactionDepthTC
                if indexPath.row - 1 < depthTableViewRowDatas.count{
                    cell.setCell(depthTableViewRowDatas[indexPath.row - 1],index : indexPath.row,asksAlllength:asksAlllength , buysAlllength : buysAlllength)
                }
                return cell
            }
        case .deal:
            if indexPath.row == 0 {
                
                let volumeTitle = "charge_text_volume".localized()+"(\(EXAppMarketManager.sharedInstance.getMarketLeft(self.entity.name).aliasName()))"
                let priceTitle = "contract_text_price".localized() + "(\(EXAppMarketManager.sharedInstance.getMarketRight(self.entity.name).aliasName()))"
                
                let cell : EXMarketDetailRecordCell = tableView.dequeueReusableCell(withIdentifier: "EXMarketDetailRecordCell") as! EXMarketDetailRecordCell
                cell.bindNames(leftTitle: "kline_text_dealTime".localized(), middleTitle: priceTitle, rightTitle: volumeTitle)

                return cell
            }else {
                let cell : TransactionDetailsTC = tableView.dequeueReusableCell(withIdentifier: "TransactionDetailsTC") as! TransactionDetailsTC
                if indexPath.row - 1 < tableViewRowDatas.count{
                    let cellEntity = tableViewRowDatas[indexPath.row - 1]
                    cell.setCellWithEntity(cellEntity, volDecimal:entity.volDecimal(), priceDecimal: entity.priceDecimal())
                }else {
                    cell.setCellWithEntity(nil)
                }
                return cell
            }
        case .introduce:
            let cell : EXCoinIntroduceCell = tableView.dequeueReusableCell(withIdentifier: "EXCoinIntroduceCell") as! EXCoinIntroduceCell
            cell.bindModel(self.introduceModel)
            return cell
        }
    }
}

//MARKL: NOTIFICATION
extension EXKLineDetailVC {
    
    func handleNotifi() {
        _ = NotificationCenter.default.rx
            .notification(NSNotification.Name.UIApplicationDidBecomeActive)
            .takeUntil(self.rx.deallocated) //Page destruction automatic removal notification listening
            .subscribe(onNext: {[weak self] noti in
                self?.homeBtnAction(false)
            })
        
        _ = NotificationCenter.default.rx
            .notification(NSNotification.Name.UIApplicationWillResignActive)
            .takeUntil(self.rx.deallocated) //Page destruction automatic removal notification listening
            .subscribe(onNext: {[weak self] noti in
                self?.homeBtnAction(true)
            })
        
        _ = NotificationCenter.default.rx
            .notification(Notification.Name(rawValue: NOTI_WS_RECONNECTED))
            .takeUntil(self.rx.deallocated) //Page destruction automatic removal notification listening
            .subscribe(onNext: {[weak self] noti in
                self?.wsService.reConnectAll()
            })
    }
    
    func homeBtnAction(_ enterBackground:Bool) {
        //Pay attention to the current controller
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
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(handleInterfaceData), object: nil)
        self.perform(#selector(handleInterfaceData), with: nil, afterDelay: 3)
    }
    
    func getHistoriesKline() {
        trackActionOn()
        wsService.getHistoriesAndTicker()
    }
}

