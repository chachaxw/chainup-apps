
//
//  EXDrawerHub.swift
//  Chainup
//
//  Created by liuxuan on 2020/10/10.
//  Copyright © 2020 Chainup. All rights reserved.
//

import UIKit
import EXKit
import JXSegmentedView

class EXDrawerHub: UIView {
    typealias ClickCellBlock = (CoinDetailsEntity) -> ()
    var clickCellBlock : ClickCellBlock? {
        didSet {
            listViewControllers.forEach { (key: Int, value: EXDrawerHubSubViewController) in
                value.clickCellBlock = clickCellBlock
            }
        }
    }
    var drawerType :HubNavType = .trade
    
    lazy var markets: [String] = {
        var array:[String] = ["market_text_customZone".localized()]
        if drawerType == .trade {
            array.append(contentsOf: EXAppMarketManager.sharedInstance.getMarketSorts())
        }else if drawerType == .lever {
            array.append(contentsOf: EXAppMarketManager.sharedInstance.getAllLeverMarketArray())
        }else if drawerType == .quant {
            array.append(contentsOf: EXAppMarketManager.sharedInstance.getAllQuantMarketNameArray())
        }
        return array
    }()
    
    lazy var menubarDataSource: JXSegmentedTitleDataSource = {
        let dataSource = JXSegmentedTitleDataSource()
        dataSource.titleNormalColor = colorModule.text2
        dataSource.titleSelectedColor = colorModule.text1
        dataSource.titleNormalFont = .Ex.regular(14)
        dataSource.titleSelectedFont = .Ex.medium(14)
        dataSource.titles = markets.map({ $0.aliasName() })
        dataSource.itemSpacing = 10
        dataSource.itemWidthIncrement = 5
        dataSource.isItemSpacingAverageEnabled = false
        return dataSource
    }()
    
    lazy var menubarIndicator: EKIndicatorSegmentIndicator = {
        let indicator = EKIndicatorSegmentIndicator()
        indicator.indicatorWidth = 24
        indicator.indicatorColor = colorModule.main1
        return indicator
    }()
    
    lazy var menubar: JXSegmentedView = {
        let menubar = JXSegmentedView()
        menubar.contentEdgeInsetLeft = 20
        menubar.contentEdgeInsetRight = 20
        menubar.dataSource = menubarDataSource
        menubar.indicators = [menubarIndicator]
        menubar.delegate = self
        let lineView = UIView()
        lineView.backgroundColor = colorModule.fill4
        menubar.addSubview(lineView)
        lineView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(EX_Line_Height)
        }
        menubar.defaultSelectedIndex = 0
        menubar.listContainer = pageContentView
        menubar.reloadData()
        return menubar
    }()
    
    lazy var pageContentView = {
        return JXSegmentedListContainerView(dataSource: self)
    }()
    
    var listViewControllers:[Int:EXDrawerHubSubViewController] = [:]
    
    let menuBarHeight:CGFloat = 44 //顶部滑动高度
    var currentIdx:Int = 0
    var rowDatas:[CoinDetailsEntity] = []
    var titleNames:[String] = []
    var symbol:String = ""
    var searchKey:String = "" {
        didSet {
            listViewControllers.values.forEach { $0.searchKey = searchKey }
        }
    }
    var symbolsAry:[String] = []

    var colorModule:UIColor.Ex { fromKline ? .kLine : .global }
    
    lazy var titleLabel:UILabel = {
        let title = UILabel()
        title.font = .Ex.medium(20)
        title.textColor = colorModule.text1
        return title
    }()
    
    lazy var drawerSearchBar: EXSearchBarView = {
        let v = EXSearchBarView()
        v.placeHolder = "market_search_ex".localized()
        return v
    }()
    
    //传入币对symbol
    convenience init(type:HubNavType  = .trade,symbol:String = "",fromKline:Bool = false) {
        self.init()
        self.fromKline = fromKline
        self.backgroundColor = colorModule.fill6
        self.drawerType = type
        self.symbol = symbol
        prepareSubViews()
        drawerSearchBar.textDidChange = {[weak self] value in
            guard let self else { return }
            self.searchForKey(value ?? "")
        }
        
        EXWebSocket.marketService.onwskLineEventCallback
            .subscribe(onNext: {[weak self] (event,datas,symbol) in
                guard let mySelf = self else { return }
                if event == .ticker {
//                    print("抽屉symbol，\(symbol)")
                    guard let tickerModel = EXMarketWsModel.mj_object(withKeyValues: datas) else { return }
                    mySelf.handleMarketWsData(datas: tickerModel, symbol: symbol)
                }
            }).disposed(by: self.disposeBag)
    }
    
    func searchForKey(_ key:String) {
        searchKey = key.lowercased()
        currentController?.searchForKey(searchKey)
        if !fromKline, !key.isEmpty {
            let events = [
                HubNavType.trade:"search_input_spot_left",
                HubNavType.quant:"search_input_grid_left",
                HubNavType.lever:"search_input_lever_left",
            ]
            EXTracking.shared.track(event: events[drawerType] ?? "", parameters: ["keyword":key])
        }
    }
    
    func handleMarketWsData(datas:EXMarketWsModel,symbol:String) {
        listViewControllers.forEach { (key: Int, controller: EXDrawerHubSubViewController) in
            controller.handleMarketWsData(datas: datas, symbol: symbol)
        }
    }
    
    func prepareSubViews() {
        
        if drawerType == .trade  {
            titleLabel.text = "mainTab_text_transaction".localized()
        }else if drawerType == .lever {
            titleLabel.text = "contract_action_lever".localized()
        }else if drawerType == .quant {
            titleLabel.text = "quant_grid_title".localized()
        }
        
        self.addSubview(self.titleLabel)
        self.addSubview(self.drawerSearchBar)
        self.addSubview(self.menubar)
        self.addSubview(self.pageContentView)
        
        self.titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(EXSafeStatusHeight + 20)
            make.left.equalToSuperview().offset(16)
        }
        
        self.drawerSearchBar.snp.makeConstraints({ (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(32)
        })
        
        self.menubar.snp.makeConstraints({ (make) in
            make.top.equalTo(drawerSearchBar.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(menuBarHeight)
        })
   
        self.pageContentView.snp.makeConstraints({ (make) in
            make.top.equalTo(menubar.snp.bottom).offset(16)
            make.left.right.bottom.equalToSuperview()
        })
    }
    
    func reloadSubCoins() {
        if XUserDefault.getCollectionCoinMap().count == 0 {
            self.menubar.selectItemAt(index: 1)
        } else {
            self.menubar.selectItemAt(index: 0)
        }
        currentController?.reloadSubCoins()
    }
    
    func cancelAllSubCoins() {
        currentController?.cancelAllSubCoins()
    }
    
    var currentController: EXDrawerHubSubViewController? { listViewControllers[menubar.selectedIndex] }
}

extension EXDrawerHub {
    override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        guard newWindow != nil else { return }
        searchKey = ""
        drawerSearchBar.clear()
//        drawerSearchBar.text = searchKey
    }
}

extension EXDrawerHub: JXSegmentedViewDelegate, JXSegmentedListContainerViewDataSource {
    func numberOfLists(in listContainerView: JXSegmentedListContainerView) -> Int {
        return markets.count
    }
    func listContainerView(_ listContainerView: JXSegmentedListContainerView, initListAt index: Int) -> JXSegmentedListContainerViewListDelegate {
        if let obj = listViewControllers[index] { return obj }
        let market = markets.safeObject(at: index) ?? ""
        let obj = EXDrawerHubSubViewController(fromKline: fromKline, type: drawerType, market: market, exclusionSymbols: symbolsAry, exclusionSymbol: symbol)
        obj.clickCellBlock = clickCellBlock
        obj.searchKey = searchKey
        listViewControllers[index] = obj
        return obj
    }
}


class EXDrawerHubSubViewController: BaseVC, JXSegmentedListContainerViewListDelegate {
    var clickCellBlock : ((CoinDetailsEntity) -> ())?
    let fromKline: Bool
    let type: HubNavType
    let market: String
    var dataSource:[CoinDetailsEntity] = []
    var wsChannel:String = ""
    var currentDataSource:[CoinDetailsEntity] = []
    let exclusionSymbols:[String] = []
    let exclusionSymbol:String = ""
    var searchKey:String = ""
    lazy var favoriteVM: UserSymbolsVM = { UserSymbolsVM() }()
    let isSelfCollection:Bool
    
    var selectedSymbol:String?
    
    lazy var tableView : UITableView = {
        let tableView = UITableView()
        tableView.fromKline = self.fromKline
        tableView.rowHeight = 54
        tableView.extUseAutoLayout()
        tableView.extSetTableView(self, self)
        tableView.backgroundColor = .clear
        tableView.extRegistCell([EXTransactionDrawerTC.classForCoder()], ["EXTransactionDrawerTC"])
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.mj_insetB = TABBAR_BOTTOM
        tableView.exemptyAttributeDict = [.verticalOffset:-15 - TABBAR_BOTTOM]
        let long = UILongPressGestureRecognizer()
        long.minimumPressDuration = 0.6
        tableView.addGestureRecognizer(long)
        long.addTarget(self, action: #selector(EXDrawerHubSubViewController.longPressed(gestureRecognizer:)))
        return tableView
    }()
    
    init(fromKline:Bool,type:HubNavType,market:String,exclusionSymbols:[String] = [], exclusionSymbol:String = "") {
        self.fromKline = fromKline
        self.type = type
        self.market = market
        self.isSelfCollection = market == "market_text_customZone".localized()
        super.init(nibName: nil, bundle: nil)
        view.backgroundColor = .clear
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    func listWillAppear() {
        searchForKey(searchKey)
        reloadSubCoins()
    }
    
    func listWillDisappear() {
        cancelAllSubCoins()
    }
    
    func updateWsChannel() {
        let validSymbols = dataSource.filter { (entity) -> Bool in
            if exclusionSymbols.count > 0 {
                return !(exclusionSymbols.contains(entity.symbol))
            }else {
                return entity.symbol != exclusionSymbol
            }
        }.map({return "market_\($0.symbol)_ticker"})
        wsChannel = validSymbols.joined(separator: ",")
    }
    
    func reloadSubCoins() {
        cancelAllSubCoins()
        let item = WSRecordItem.init(event: "sub_batch", channels: wsChannel,cbid: "drawerHubSubBatch")
        EXWebSocket.marketService.addRecordObject(recordItem: item)
    }
    
    func cancelAllSubCoins() {
        EXWebSocket.marketService.cancelTaskSubObject(channel: wsChannel)
    }
    
    func updateDataSource(reload:Bool = true) {
        var array:[CoinMapEntity] = []
        if isSelfCollection {
            let coinMap:[String] = XUserDefault.getCollectionCoinMap()
            if type == .trade {
                array = EXAppMarketManager.sharedInstance.getCollectionCoinMapList(coinMap)
            }else if type == .lever {
                array = EXAppMarketManager.sharedInstance.getLeverCoinMapList(coinMap)
            }else if type == .quant {
                array = EXAppMarketManager.sharedInstance.getQuantCoinMapList(coinMap)
            }
        }else{
            if type == .trade {
                if market.lowercased() == "etf" {
                    array = EXAppMarketManager.sharedInstance.getAllETFCoinMap()
                }else {
                    array = EXAppMarketManager.sharedInstance.getCoinPairsBy(marketName: market)
                }
            }else if type == .lever {
                array = EXAppMarketManager.sharedInstance.getLeverMarketMaps(market)
            }else if type == .quant {
                array = EXAppMarketManager.sharedInstance.getQuantMarketMaps(market)
            }
        }
        array.removeAll(where: { $0.isShow != "1" })
        dataSource = array.map({ item in
            let entity = CoinDetailsEntity()
            entity.name = item.name
            entity.symbol = item.symbol
            entity.precision = Int(item.price) ?? 8
            return entity
        })
        currentDataSource = dataSource
        updateWsChannel()
        if reload { tableView.reloadData() }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func searchForKey(_ keyword:String) {
        updateDataSource(reload: false)
        if keyword.isEmpty {
            currentDataSource = dataSource
        }else{
            currentDataSource = dataSource.filter({
                $0.name.aliasCoinMapName().lowercased().contains(keyword) ||
                $0.name.lowercased().contains(keyword) ||
                $0.symbol.lowercased().contains(keyword)
            })
        }
        tableView.reloadData()
    }
    
    func handleMarketWsData(datas:EXMarketWsModel,symbol:String) {
        guard let index = dataSource.firstIndex(where: { $0.symbol == symbol }),
            let item = dataSource.safeObject(at: index) else {
            return
        }
        item.updateModelWithTicker(ticker: datas.tick)
        tableView.reloadData()
    }
    func listView() -> UIView { view }
}

extension EXDrawerHubSubViewController : UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentDataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let entity = currentDataSource[indexPath.row]
        if entity.close == "--" {
            let wsDataInfo = EXMarketReqVm.shared().wsReviewData
            if let reviewV2Item = wsDataInfo[entity.symbol] {
                if let ticker = EXTickerModel.yy_model(withJSON: reviewV2Item) {
                    entity.updateModelWithTicker(ticker: ticker)
                }
            }
        }
        let cell : EXTransactionDrawerTC = tableView.dequeueReusableCell(withIdentifier: "EXTransactionDrawerTC") as! EXTransactionDrawerTC
        cell.fromKline = fromKline
        cell.isSelfCollection = isSelfCollection
        cell.setCell(entity,showMultiple: type == .lever)
        cell.isShowingPopover = (entity.symbol == selectedSymbol) == true
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let entity = self.currentDataSource[indexPath.row]
        selectedSymbol = entity.symbol
        tableView.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {[weak self] in
            self?.selectedSymbol = nil
            self?.tableView.reloadData()
        }
        clickCellBlock?(entity)
        if !fromKline {
            let events = [
                HubNavType.trade:"click_token_pair_spot",
                HubNavType.quant:"click_token_pair_grid",
                HubNavType.lever:"click_token_pair_lever",
            ]
            EXTracking.shared.track(event: events[type] ?? "", parameters: ["symbol":entity.symbol])
        }
    }
    
    @objc func longPressed(gestureRecognizer:UILongPressGestureRecognizer) {
        guard gestureRecognizer.state == .began else { return }
        let point = gestureRecognizer.location(in: tableView)
        guard let indexPath = tableView.indexPathForRow(at:point) else { return }
        guard let cell = tableView.cellForRow(at: indexPath) as? EXTransactionDrawerTC else { return }
        let entity = cell.entity
        selectedSymbol = entity.symbol
        tableView.reloadData()
        //
        let added = XUserDefault.whetherCollectionCoinMap(entity.symbol)
        //
        let popupView = EXPopMenuView.shared
        let item = PopMenuItem()
        item.name = added ? "market_str_1".localized() : "market_str_2".localized()
        popupView.pop(fromView: cell,acionItem: [item]) {[weak self] item in
            guard let `self` = self else { return }
            let newEntity = CoinMapEntity()
            newEntity.symbol = entity.symbol
            self.favoriteVM.handleFavorite(actionType: added ? .singleDelete : .singleAdd,
                                           coinMaps: [newEntity], callback: nil, in: UIApplication.shared.keyWindow)
            if self.market == "market_text_customZone".localized() && added {
                self.dataSource.removeAll { $0.symbol == newEntity.symbol }
                self.currentDataSource.removeAll { $0.symbol == newEntity.symbol }
            }
            self.selectedSymbol = nil
            self.tableView.reloadData()
        }
        popupView.willDismissHandler = {[weak self] in
            self?.selectedSymbol = nil
            self?.tableView.reloadData()
        }
    }
}
