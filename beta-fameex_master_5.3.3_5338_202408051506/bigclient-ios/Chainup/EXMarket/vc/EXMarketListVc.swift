//
//  EXMarketListVc.swift
//  Chainup
//
//  Created by liuxuan on 2023/7/15.
//  Copyright © 2023 ChainUP. All rights reserved.
//

import UIKit
import RxSwift
import DZNEmptyDataSet
import SwiftEventBus
import DeepDiff
import JXSegmentedView
import EXKit
enum EXMarketSortType {
    case nameUp//First name order
    case nameDown//Name in reverse order
    case priceUp//Price positive order
    case priceDown//Reverse price order
    case rose//Positive order of fluctuations
    case falls//Reverse order of rise and fall
    case normal//default
}
let sortMenuBarHeight:CGFloat = (EXHomeViewModel.status() == EXHomeViewModelType.three) ? 0 : 37
///Ranking Currency Content List
class EXMarketListVc: BaseVC {
    var isCustomType:Bool = false
    var symbol:String = ""
    var marketCoins:[[CoinDetailsEntity]] = []
    var marketZones:[EXCoinZoneType] = []
    var sortedCoins:[CoinDetailsEntity] = []
    var currentSortType:EXMarketSortType = .normal
    var subIdxPaths:[IndexPath] = []
    var isRolling:Bool = false
    var subCoinNames:String = ""//Reserved for comparison and optimization
    var tickerReceiver:[String:EXTickerModel] = [:]
    var tickerDisposeBag: Disposable? = nil
    var track_begin:Date?
    var track_end:Date?
    var currentZoneIdx:Int = 0

    lazy var marketListTable : UITableView = {
        let tableView = UITableView()
        tableView.extUseAutoLayout()
        tableView.rowHeight = 56
        tableView.separatorStyle = .none
        tableView.register(HomePageTC.classForCoder(), forCellReuseIdentifier: "HomePageTC")
        tableView.backgroundColor = UIColor.ThemeView.card1
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        tableView.showsVerticalScrollIndicator = false
        
        tableView.mj_header = EXRefreshHeaderView (refreshingBlock: {[weak self] in
            guard let mySelf = self else{return}
            mySelf.handleReceiver()
        })
        
        return tableView
    }()
    
    var subtitles:[String] {
        //There's only one main area, when he doesn't
        if self.marketZones.count == 1,let zone = self.marketZones.safeObject(at: 0),zone == .main {
            return []
        }
        return self.marketZones.map({return $0.describe})
    }
    
    lazy var zoneBg: UIView = {
        let view  = UIView()
        view.backgroundColor = UIColor.ThemeView.bg
        return view
    }()
    
    lazy var subTitleView: SGPageTitleView = {
        let view  = SGPageTitleView.init(frame: .zero, delegate: self, titleNames: subtitles, configure: SGPageTitleViewConfigure.SecondLevel())!
        view.backgroundColor = UIColor.ThemeView.card1
//        view.selectedIndex = 0
        return view
    }()
    
    //The HomePageHV at the top has layout issues and needs to be optimized
    lazy var sortMenu : HomePageHV = {
        let view = HomePageHV.init()
        return view
    }()
    
    
    func handleTicker() {
        self.handleReceiver()
        self.tickerDisposeBag?.dispose()
#if DEBUG
        self.tickerDisposeBag = Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] (element) in
                guard let `self` = self else { return }
                self.handleReceiver()
            })
#else
        self.tickerDisposeBag = Observable<Int>.interval(.seconds(3), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] (element) in
                guard let `self` = self else { return }
                self.handleReceiver()
            })
#endif

    }
    
    func updateCellUI(entity:CoinDetailsEntity,idxPath:IndexPath) {
        if let cell = self.marketListTable.cellForRow(at: idxPath) as? HomePageTC {
            cell.setCellWithEntity(entity)
            cell.ws_setCellWithEntity(entity)
        }
    }
    
    func handleReceiver() {
        let tickers = tickerReceiver
        if self.subIdxPaths.count == 0 {
            updateSubIdxPaths()
        }
        if tickers.count > 0 {
            self.tickerReceiver.removeAll()
//DebugPrint ("Currency Timer,  (self. symbol), * *  (tickers. count), * *  (Date())")
            var updateIdxs:[IndexPath] = []
            DispatchQueue.global().async {
                //Update Model
                for (key,ticker) in tickers {
                    if self.currentSortType == .normal {
                        if let zone = self.marketCoins.safeObject(at: self.currentZoneIdx) {
                            for (row,zone) in zone.enumerated() {
                                if zone.symbol == key {
                                    updateIdxs.append(IndexPath.init(row: row, section: 0))
                                    zone.updateModelWithTicker(ticker: ticker)
                                }
                            }
                        }
                    }else {
                        for (row,item) in self.sortedCoins.enumerated() {
                            if item.symbol == key {
                                updateIdxs.append(IndexPath.init(row: row, section: 0))
                                item.updateModelWithTicker(ticker: ticker)
                            }
                        }
                    }
                }
                DispatchQueue.main.async {
                    //Update non sorted UI
                    if self.currentSortType == .normal {
                        for idxpath  in updateIdxs {
                            if self.subIdxPaths.contains(idxpath) {
                                if let zone = self.marketCoins.safeObject(at: self.currentZoneIdx),zone.count > idxpath.row {
                                    let entity = zone[idxpath.row]
//                                    debugPrint("find->\(entity.symbol),update=>\(idxpath.row)")
                                    self.updateCellUI(entity: entity, idxPath: idxpath)
                                }
                            }
                        }
                    }else {
                        //Update 4 sorting UI options with order changes
                        if  self.currentSortType == .falls   ||
                                self.currentSortType == .rose    ||
                                self.currentSortType == .priceUp ||
                                self.currentSortType == .priceDown
                        {
                            let sortRst = self.getReSortCoins()
                            let diffChanges = diff(old: self.sortedCoins, new: sortRst)
                            if diffChanges.count > 0 {
                                //Add idxpath with positional changes
                                for change in diffChanges {
                                    if let moveItem = change.move {
                                        let idxPath = IndexPath.init(row: moveItem.fromIndex, section: 0)
                                        if !updateIdxs.contains(idxPath) {
                                            updateIdxs.append(idxPath)
                                        }
                                    }
                                }
                                //Refresh all visible cells
                                for idxpath  in updateIdxs {
                                    if self.subIdxPaths.contains(idxpath) {
                                        let entity = sortRst[idxpath.row]
                                        self.updateCellUI(entity: entity, idxPath: idxpath)
                                    }
                                }
                                self.sortedCoins = sortRst
                            }else {
                                //No position to move, update UI
                                for idxpath  in updateIdxs {
                                    if self.subIdxPaths.contains(idxpath) {
                                        let entity = self.sortedCoins[idxpath.row]
                                        self.updateCellUI(entity: entity, idxPath: idxpath)
                                    }
                                }
                            }
                        }else {
                            //Sort names and update UI
                            for idxpath  in updateIdxs {
                                if self.subIdxPaths.contains(idxpath) {
                                    let entity = self.sortedCoins[idxpath.row]
                                    self.updateCellUI(entity: entity, idxPath: idxpath)
                                }
                            }
                        }
                    }
                }
            }
        }
        self.marketListTable.mj_header.endRefreshing()
    }
    
    
    func updateTicker(ticker:EXTickerModel,symbol:String) {
        //Update recommended options
        if track_end == nil {
            print("Record End Time ->")
            track_end = Date()
        }
        tickerReceiver[symbol] = ticker
    }
    
    deinit {
        print("(self) has been released")
    }
}


//MARK: Period

extension EXMarketListVc {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(sortMenu)
        self.view.addSubview(marketListTable)
        configTable()
        configSortBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateSubIdxPaths()
        if self.subIdxPaths.count > 0 { //Update self selection
            self.marketListTable.reloadRows(at: self.subIdxPaths, with: .none)
        }
        EXWebSocket.marketService.fetchLatestTicker()
        handleTicker()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateSubIdxPaths()
        if EXAppCache.sharedCache.getAppGuideFirstShow(byType: .market){
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.marketListTable.reloadData()
                if let cell = self.marketListTable.cellForRow(at: IndexPath(row: 0, section: 0)){
                    let obj = ["cell": cell]
                    NotificationCenter.default.post(name: NSNotification.Name.init(bibiViewDidAppear), object: obj)
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tickerDisposeBag?.dispose()
        self.tickerReceiver.removeAll()
    }
    
    func prepareDefaultPrices(_ reload:Bool) {
        
        let wsDataInfo = EXMarketReqVm.shared().wsReviewData
        for sections in marketCoins {
            for rowItem in sections {
                if let wsData = wsDataInfo[rowItem.symbol] as? [String:Any] {
                    rowItem.setEntityWithDict(wsData)
                }
            }
        }
        if reload {
            self.marketListTable.reloadData()
        }
    }
    
    func updateCoins(key:String, coins:[[CoinDetailsEntity]],zones:[EXCoinZoneType]) {
        if self.symbol == key {
            self.marketCoins = coins
            self.marketZones = zones
            handleZones()
            self.marketListTable.reloadData()
            updateSubIdxPaths()
        }
    }
    
    func handleZones() {
        //In some merchant markets, the currency pair is empty
        if zoneBg.superview == nil,subtitles.count > 0 {
            if  marketZones.count > 1 {
                //zone >1  zone add all,coins add all
                self.marketZones.insert(.all, at: 0)
                let sorted =  marketCoins.flatMap({return $0}).sorted { (a, b) -> Bool in
                    return a.doubleSort < b.doubleSort
                }
                self.marketCoins.insert(sorted, at: 0)
            }
            zoneBg.addSubview(self.subTitleView)
            self.view.addSubview(zoneBg)
            zoneBg.snp.makeConstraints { make in
                make.top.equalToSuperview()
                make.left.equalToSuperview()
                make.right.equalToSuperview()
                make.height.equalTo(22 + 12)
            }
            subTitleView.snp.makeConstraints { make in
                make.centerY.equalToSuperview()
                make.left.equalToSuperview().offset(16)
                make.right.equalToSuperview().offset(-16)
                make.height.equalTo(22 )
            }
        }
    }
}

//MARK: UI

extension EXMarketListVc {
    
    func configTable() {
        marketListTable.delegate = self
        marketListTable.dataSource = self

        if subtitles.count > 0 {
    
            sortMenu.snp.makeConstraints { (make) in
                make.top.equalToSuperview().offset(34)
                make.left.equalToSuperview()
                make.width.equalTo(SCREEN_WIDTH)
                make.height.equalTo(sortMenuBarHeight)
            }
        }else {
            sortMenu.snp.makeConstraints { (make) in
                make.top.equalToSuperview()
                make.left.equalToSuperview()
                make.width.equalTo(SCREEN_WIDTH)
                make.height.equalTo(sortMenuBarHeight)
            }
        }
        marketListTable.snp.makeConstraints { (make) in
            make.top.equalTo(sortMenu.snp.bottom)
            make.left.equalToSuperview()
            make.width.equalToSuperview()
            make.bottom.equalToSuperview()
        }

    }
    
    func configSortBar() {
        sortMenu.clickBtnBlock = {[weak self] sender in
            guard let mySelf = self else{return}
            mySelf.handleMenuBarAction(sender: sender)
        }
    }
}

//MARK:Method

extension EXMarketListVc {
    
    func getReSortCoins() -> [CoinDetailsEntity] {
        var sorted:[CoinDetailsEntity] = []
        switch currentSortType {
        case .priceUp:
            sorted = sortedCoins.sorted { (a, b) -> Bool in
                return a.doubleClose < b.doubleClose
            }
        case .priceDown:
            sorted = sortedCoins.sorted { (a, b) -> Bool in
                return a.doubleClose > b.doubleClose
            }
        case .falls:
            sorted = sortedCoins.sorted { (a, b) -> Bool in
                return a.rose1 > b.rose1
            }
        case .rose:
            sorted = sortedCoins.sorted { (a, b) -> Bool in
                return a.rose1 < b.rose1
            }
        case .nameUp,
                .nameDown,
                .normal:
            return sortedCoins
        }
        return sorted
    }
    
    func getSortCoins() -> [CoinDetailsEntity] {
        var sorted:[CoinDetailsEntity] = []
        let  currenZoneCoins:[CoinDetailsEntity] = marketCoins[currentZoneIdx]
        switch currentSortType {
        case .normal:
            break
        case .nameUp:
            sorted = currenZoneCoins.sorted { (a, b) -> Bool in
                return a.name < b.name
            }
        case .nameDown:
            sorted = currenZoneCoins.sorted { (a, b) -> Bool in
                return a.name > b.name
            }
        case .priceUp:
            sorted = currenZoneCoins.sorted { (a, b) -> Bool in
                return a.doubleClose < b.doubleClose
            }
        case .priceDown:
            sorted = currenZoneCoins.sorted { (a, b) -> Bool in
                return a.doubleClose > b.doubleClose
            }
        case .falls:
            sorted = currenZoneCoins.sorted { (a, b) -> Bool in
                return a.rose1 > b.rose1
            }
        case .rose:
            sorted = currenZoneCoins.sorted { (a, b) -> Bool in
                return a.rose1 < b.rose1
            }
        }
        return sorted
    }
    
    func handleMenuBarAction(sender:EXDoubleArrorwIconButton) {
        switch sender.dirState {
        case .ascending:
            if sender == sortMenu.nameBtn {
                currentSortType = .nameUp
            }else if sender == sortMenu.newpriceBtn {
                currentSortType = .priceUp
            }else if sender == sortMenu.amplitudeBtn {
                currentSortType = .rose
            }
            break
        case .descending:
            if sender == sortMenu.nameBtn {
                currentSortType = .nameDown
            }else if sender == sortMenu.newpriceBtn {
                currentSortType = .priceDown
            }else if sender == sortMenu.amplitudeBtn {
                currentSortType = .falls
            }
            break
        case .none:
            currentSortType = .normal
            break
        }
        self.sortedCoins = getSortCoins()
        marketListTable.reloadData()
        tryToGetCurrentVisibleCells()
        getTracking()
    }
    
    func getTracking() {
        if currentSortType == .nameUp || currentSortType == .nameDown {
            EXTracking.shared.trackFirebase(firebaseKey: FirebaseKey.Market_Name_click)
        }else if currentSortType == .priceUp || currentSortType == .priceDown {
            EXTracking.shared.trackFirebase(firebaseKey: FirebaseKey.Market_Lastprice_click)
        }else if currentSortType == .rose ||  currentSortType == .falls {
            EXTracking.shared.trackFirebase(firebaseKey: FirebaseKey.Market_Change_click)
        }
    }
}



//MARK: TableViewDelegate & DataSource

extension EXMarketListVc : UITableViewDelegate, UITableViewDataSource {
    
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return (currentSortType == .normal) ? marketCoins.count : 1
//    }
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return (currentSortType == .normal) ? marketCoins[section].count : sortedCoins.count
//    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if currentSortType == .normal {
            if marketCoins.count > currentZoneIdx {
                return marketCoins[currentZoneIdx].count
            }
            return 0
        }else {
            return sortedCoins.count
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var entity:CoinDetailsEntity?
        if currentSortType == .normal {
            entity = marketCoins[currentZoneIdx][indexPath.row]
        }else {
            entity = sortedCoins[indexPath.row]
        }

        
        if entity?.rose == "--" {
            let wsDataInfo = EXMarketReqVm.shared().wsReviewData
            if let reviewV2Item = wsDataInfo[entity!.symbol] {
                if let ticker = EXTickerModel.mj_object(withKeyValues: reviewV2Item) {
                    entity!.updateModelWithTicker(ticker: ticker)
                }
            }
        }
        let cell : HomePageTC = tableView.dequeueReusableCell(withIdentifier: "HomePageTC") as! HomePageTC
        cell.setCellWithEntity(entity!)
        cell.ws_setCellWithEntity(entity!)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var name:String?
        if currentSortType == .normal {
            name = marketCoins[currentZoneIdx][indexPath.row].name
        }else {
            name = sortedCoins[indexPath.row].name
        }
        guard let nameStr = name  else { return }
        let entity = EXAppMarketManager.sharedInstance.getCoinMapEntityByName(nameStr)
        
        let vc = EXKlineDetailNewVC(entity: entity)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}


//MARK: scrollview delegate

extension EXMarketListVc {
    
    func trackActionOn() {
        debugPrint("--->")
        track_begin = Date()
        track_end = nil
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector:#selector(handleInterfaceData), object: nil)
        self.perform(#selector(handleInterfaceData), with: nil, afterDelay: 3)
    }
    
    @objc func handleInterfaceData() {
        //        if self.defineCurrentVcIsTopVc() == false {
        //            return
        //        }
        if let cell = marketListTable.cellForRow(at: IndexPath.init(row: 0, section: 0)) as? HomePageTC {
            
            let interfaceData:EXInterfaceData = EXInterfaceData.init(page: .market, action: .subBatch)
            var duration = ""
            var errorType = "0"
            if let begin = self.track_begin,let end = self.track_end {
                let interval = end.timeIntervalSince(begin)
                let millisecond = CLongLong(round(interval*1000))
                duration = "\(millisecond)"
            }
            if cell.isEmptyUI() {
                if EXWebSocket.marketService.isConnecting() == false {
                    errorType = "1"
                }else if cell.isEmptyData(){
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
    
    func fetchwsDatas() {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(tryToSubCoins), object: nil)
        self.perform(#selector(tryToSubCoins), with: nil, afterDelay: 0.3)
    }
    
    @objc func tryToSubCoins() {
        var coinNames:[String] = []
        
        if currentSortType == .normal {
            let coinsymbols = marketCoins.flatMap({return $0}).map({return $0.symbol})
            for symbol in coinsymbols {
                coinNames.append("market_\(symbol)_ticker")
            }
        }else {
            let coinsymbols = sortedCoins.map({return $0.symbol})
            for symbol in coinsymbols {
                coinNames.append("market_\(symbol)_ticker")
            }
        }
        trackActionOn()
        let prepareCoins = coinNames.joined(separator: ",")
        debugPrint("############\n——————>############")
        debugPrint(symbol,subIdxPaths.count)
        debugPrint("—————>",prepareCoins.util_subString(end: 300))
        debugPrint("#######################################")
        EXWebSocket.marketService.addwsTaskSub(event:"sub_batch", channel:prepareCoins, cbid: "")
    }
    
    func bindMarketsAndZone(markets:[[CoinDetailsEntity]],zones:[EXCoinZoneType]) {
        print("Cwd bindMarketsAndZone= markets =\(markets.count) zone = \(zones.count)")
        if self.marketCoins.count == 0,self.marketZones.count == 0 {
            self.marketCoins = markets
            self.marketZones = zones
            handleZones()
            marketListTable.reloadData()
        }
    }
    
    func updateSubIdxPaths() {
        if let idxPaths = self.marketListTable.indexPathsForVisibleRows {
            self.subIdxPaths = idxPaths
        }
    }
    
    func tryToGetCurrentVisibleCells() {
        updateSubIdxPaths()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        tryToGetCurrentVisibleCells()
        isRolling = false
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        isRolling = true
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        isRolling = true
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        isRolling = true
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        tryToGetCurrentVisibleCells()
        isRolling = false
    }
    
    func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        tryToGetCurrentVisibleCells()
        isRolling = false
    }
}


//DZN EMPTY DataSet

extension EXMarketListVc {
    
    func backgroundColor(forEmptyDataSet scrollView: UIScrollView!) -> UIColor! {
        return UIColor.ThemeView.bg
    }
    
    func emptyDataSetShouldDisplay(_ scrollView: UIScrollView!) -> Bool {
        return true
    }
    
    func emptyDataSetShouldAllowTouch(_ scrollView: UIScrollView!) -> Bool {
        return true
    }
    
    override func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView!) -> Bool {
        return false
    }
}

extension CoinDetailsEntity:DiffAware{}
///Main area/unlock area
extension EXMarketListVc: SGPageTitleViewDelegate {
    
    func pageTitleView(_ pageTitleView: SGPageTitleView!, selectedIndex: Int) {
        if currentZoneIdx != selectedIndex {

            self.currentZoneIdx = selectedIndex
            if  self.currentSortType != .normal {
                self.sortedCoins = getSortCoins()
            }
            self.marketListTable.reloadData()
        }
    }
}

extension EXMarketListVc: JXSegmentedListContainerViewListDelegate {
    func listView() -> UIView {
        return self.view
    }
    
    func listDidDisappear() {
//        print("listDidDisappear,\(self.symbol)")
    }
    
    func listWillDisappear() {
//        print("listDidDisappear,\(self.symbol)")
    }
    
    func listWillAppear() {
//        print("Almost displayed,  (self. symbol)")
    }
    
    func listDidAppear() {
//        print("already displayed,  (self. symbol)")
    }
}

