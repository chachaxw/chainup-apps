//
//  EXFavoritesMarketVC.swift
//  Chainup
//
//  Created by liuxuan on 2023/9/22.
//  Copyright © 2023 ChainUP. All rights reserved.
//

import UIKit
import DZNEmptyDataSet
import RxSwift
import JXSegmentedView
import EXKit
import Swap
///Coin selection
class EXFavoritesMarketVC: BaseVC {
    
    var favoriteSymbols:String = "" //Record your favorite currencies to reduce refresh. In the future, we need to reconstruct the collection logic
    var userColletctorVm = UserSymbolsVM() //Collect the VM and stay still for now
    var marketCoins:[CoinDetailsEntity] = []
    var subIdxPaths:[IndexPath] = []
    var wsEventSubject: PublishSubject<Int> = PublishSubject()
    var currentSortType:EXMarketSortType = .normal
    
    var tickerReceiver:[String:EXTickerModel] = [:]
    var tickerDisposeBag: Disposable? = nil
    var currentCell: HomePageTC?
    //The HomePageHV at the top has layout issues and needs to be optimized
    lazy var sortMenu : HomePageHV = {
        let view = HomePageHV.init()
        return view
    }()
    
    lazy var marketListTable : UITableView = {
        let tableView = UITableView()
        tableView.extUseAutoLayout()
        tableView.rowHeight = 56
        tableView.separatorStyle = .none
        tableView.register(FavoriteTC.classForCoder(), forCellReuseIdentifier: "FavoriteTC")
        tableView.backgroundColor = UIColor.ThemeView.bg
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        tableView.delegate = self
        tableView.dataSource = self
        tableView.mj_header = EXRefreshHeaderView (refreshingBlock: {[weak self] in
            guard let mySelf = self else{return}
            mySelf.reloadData()
        })
        return tableView
    }()
    ///Recommended view
    lazy var remmondView: EXRecommendView = {
        let v = EXRecommendView()
        v.btnTitle = "market_recommand_selet".localized()
        v.btnStyle = .sure
        v.btnClick = { [weak self] selected in
            guard let weakSelf = self else { return }
            weakSelf.remmondView.isHidden = true
            print(selected)
            let arr = selected.map { str -> CoinMapEntity in
               let it = CoinMapEntity()
                it.symbol = str
                return it
            }
            weakSelf.userColletctorVm.handleFavorite(actionType: .other, coinMaps: arr,callback: { [weak weakSelf] success in
                if success{
                    weakSelf?.updateCollections()
                    weakSelf?.wsEventSubject.onNext(1)
                }
            })
        }
        return v
    }()
    
    func configTable() {
        marketListTable.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.width.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        self.view.addSubview(remmondView)
        remmondView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        sortMenu.clickBtnBlock = {[weak self] sender in
            guard let mySelf = self else{return}
            mySelf.handleMenuBarAction(sender: sender)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateData()
        handleTicker()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tickerDisposeBag?.dispose()
        self.tickerReceiver.removeAll()
    }
    
    func reloadData() {
        tryToGetCurrentVisibleCells()
        checkFavoritesChangesOrNot()
        self.marketListTable.mj_header.endRefreshing()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        EXTracking.shared.trackFirebase(firebaseKey: FirebaseKey.Market_Favorites_click)
        self.view.addSubview(marketListTable)
        self.view.addSubview(remmondView)
        configTable()
        favoriteSymbols = XUserDefault.getCollectionCoinMap().joined(separator: ",")
        EXAppMarketManager.sharedInstance.onMarketPublish.subscribe (onNext: {[weak self] (success) in
            guard let `self` = self else {return}
            if success {
                self.updateCollections()
            }
        }).disposed(by: self.disposeBag)
    }
    //Get Autolist
    func updateData(){
        if XUserDefault.isOffLine(){ //Not logged in
            updateCollections()
        }else{ //Logged in
            userColletctorVm.syncUserSysmbols()
            //After logging in, I got my favorite list
            userColletctorVm.didComplete = {[weak self] () in
                self?.updateCollections()
            }
            updateCollections()
        }
    }
   
    func handleTicker() {
        self.handleReceiver()
        self.tickerDisposeBag?.dispose()
        self.tickerDisposeBag = Observable<Int>.interval(.seconds(3), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] (element) in
                guard let `self` = self else { return }
                self.handleReceiver()
            })
    }
    
    func handleReceiver() {
        let tickers = tickerReceiver
        self.tickerReceiver.removeAll()
        //Update recommended options
        if tickers.count > 0 {
//            print("Timer,\(tickers.count),\(Date())")
            for (key,ticker) in tickers {
                updateTicker(key: key, ticker: ticker)
            }
        }
    }
    
    func updateTicker(key:String, ticker:EXTickerModel) {
        var rowIdx = 0
        var hasLocated:Bool = false
        for (row,item) in marketCoins.enumerated() {
            if hasLocated {
                break
            }
            if item.symbol == key {
                rowIdx = row
                item.updateModelWithTicker(ticker: ticker)
                hasLocated = true
                break
            }
        }
        
        if hasLocated {
            if marketCoins.count > rowIdx {
                let entity = marketCoins[rowIdx]
                if let cell = marketListTable.cellForRow(at: IndexPath.init(row: rowIdx, section: 0)) as? FavoriteTC {
                    cell.setCellWithEntity(entity)
                    cell.ws_setCellWithEntity(entity)
                }
            }
        }
    }
    
    func distributeTicker(_ ticker:EXTickerModel,symbol:String) {
        tickerReceiver[symbol] = ticker
    }
    
    func updateSubIdxPaths() {
        if let idxPaths = self.marketListTable.indexPathsForVisibleRows {
            self.subIdxPaths = idxPaths
        }
    }
}

//MARK: Optional
extension EXFavoritesMarketVC {
    
    func checkFavoritesChangesOrNot() {
        //Every time you return to the current collection view, try synchronizing the collection currency
        let tmpFavorites = XUserDefault.getCollectionCoinMap().joined(separator: ",")
        if tmpFavorites != favoriteSymbols {
            userColletctorVm.syncUserSysmbols()
            self.updateCollections()
            favoriteSymbols = tmpFavorites
        }
    }
    
    func updateCollections() {
        let historyCollection = XUserDefault.getCollectionCoinMap()
        if historyCollection.count == 0{
            remmondView.isHidden = false
            remmondView.items =  EXFavoriteRecommend.getCoinRecommandList()
        }else{
            remmondView.isHidden = true
        }
        self.marketCoins = EXAppMarketManager.sharedInstance.getCollectionCoinDetails(historyCollection)
        self.marketListTable.reloadData()
        updateSubIdxPaths()
    }
    
    func getUserConfig() -> [CoinDetailsEntity]  {
        let historyCollection = XUserDefault.getCollectionCoinMap()
        let arr = EXAppMarketManager.sharedInstance.getCollectionCoinDetails(historyCollection)
        return arr
    }
}

extension EXFavoritesMarketVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return marketCoins.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if marketCoins.count > 0 {
            sortMenu.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: sortMenuBarHeight)
            return self.sortMenu
        }
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return marketCoins.count > 0 ? sortMenuBarHeight : CGFloat.leastNonzeroMagnitude
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let entity = marketCoins[indexPath.row]
        let wsDataInfo = EXMarketReqVm.shared().wsReviewData
        if let reviewV2Item = wsDataInfo[entity.symbol] {
            if let ticker = EXTickerModel.mj_object(withKeyValues: reviewV2Item) {
                entity.updateModelWithTicker(ticker: ticker)
            }
        }
        let cell : FavoriteTC = tableView.dequeueReusableCell(withIdentifier: "FavoriteTC") as! FavoriteTC
        cell.setCellWithEntity(entity)
        cell.ws_setCellWithEntity(entity)
//        cell.longCellBlock = {[weak self] entity in
//            self?.handleCustomZoneCollectionRemove(idxPath: indexPath)
//        }
        cell.longCellBlock = { [weak self, weak cell] _ in
            guard let c = cell else { return }
            self?.currentCell = c
            self?.popMenu(cell: c)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let nameStr = marketCoins[indexPath.row].name
        let entity = EXAppMarketManager.sharedInstance.getCoinMapEntityByName(nameStr)
        let vc = EXKlineDetailNewVC(entity: entity)
        self.navigationController?.pushViewController(vc, animated: true )
    }
    
    
    func handleCustomZoneCollectionRemove(idxPath:IndexPath) {
        if marketCoins.count > idxPath.row {
            let entity = marketCoins[idxPath.row]
            let mapEntity = EXAppMarketManager.sharedInstance.getCoinMapEntityByName(entity.name)
            self.userColletctorVm.handleFavorite(actionType:.singleDelete,coinMaps:[mapEntity], callback: nil)

//            let entity = marketCoins[idxPath.row]
//            XUserDefault.cancelCollectionCoinMap(entity.name)
            marketCoins.remove(at: idxPath.row)
            self.marketListTable.reloadData()
//            userColletctorVm.handSysmbols(operationType: "2", symbols: entity.symbol)
            let hasLeftCoinsCount = self.getCustomCollections().count
            if hasLeftCoinsCount > 0 {
                tryToGetCurrentVisibleCells()
            }
            
            
        }
    }
    
    
    func getCustomCollections() -> [String] {
        return XUserDefault.getCollectionCoinMap()
    }
    
}

extension EXFavoritesMarketVC {
    
    func sortCoins() {
        var sorted:[CoinDetailsEntity] = []
        switch currentSortType {
        case .normal:
            sorted = getUserConfig()
//            sorted = marketCoins.sorted(by: { (a, b) -> Bool in
//                return a.app_serial_number < b.app_serial_number
//            })
        case .nameUp:
            sorted = marketCoins.sorted(by: { (a, b) -> Bool in
                return a.name < b.name
            })
        case .nameDown:
            sorted = marketCoins.sorted(by: { (a, b) -> Bool in
                return a.name > b.name
            })
        case .priceUp:
            sorted = marketCoins.sorted(by: { (a, b) -> Bool in
                return a.doubleClose < b.doubleClose
            })
        case .priceDown:
            sorted = marketCoins.sorted(by: { (a, b) -> Bool in
                return a.doubleClose > b.doubleClose
            })
        case .falls:
            sorted = marketCoins.sorted(by: { (a, b) -> Bool in
                return a.rose1 > b.rose1
            })
        case .rose:
            sorted = marketCoins.sorted(by: { (a, b) -> Bool in
                return a.rose1 < b.rose1
            })
        }
        
        self.marketCoins = sorted
        marketListTable.reloadData()
        tryToGetCurrentVisibleCells()
    }
    
    func tryToGetCurrentVisibleCells() {
        updateSubIdxPaths()
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(tryToSubCoins), object: nil)
        self.perform(#selector(tryToSubCoins), with: nil, afterDelay: 0.3)
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
        sortCoins()
    }
}

extension EXFavoritesMarketVC  {
    
    override func verticalOffset(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
        return -174
    }
    
    func customView(forEmptyDataSet scrollView: UIScrollView!) -> UIView! {
        let text = "market_text_customZoneAdd".localized()
        let font = UIFont.ThemeFont.BodyBold
        let icon = EXKitBundle.svgImage(named: "public_increase")
        let view = EXFavoritesEmptyView.init(frame: .zero)
        view.iconImgView.image = EXKitBundle.svgImage(named: "public_nocontentyet")
        view.actionBtn.setTitle(text, for: .normal)
        view.actionBtn.titleLabel?.font = font
        view.actionBtn.setTitleColor(UIColor.ThemeView.highlight, for: .normal)
        view.actionBtn.addTarget(self, action: #selector(beginSearch), for: .touchUpInside)
        view.actionBtn.setImage(icon, for: .normal)
        view.actionBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 0)
        let heightConstraint = NSLayoutConstraint(item: view, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 116)
        view.addConstraints([heightConstraint])
        return view
    }
    
    @objc func beginSearch() {
        EXNavigationHandler.sharedHandler.commonJumpCommand(EXRouterActionKey.appSearch.rawValue)
    }
}

extension EXFavoritesMarketVC {
    
    @objc func tryToSubCoins() {
        if self.subIdxPaths.count > 0 {
            //Unsubscribe from unsub
            EXWebSocket.marketService.cancel()
        }else {
            return
        }
        
        var coinNames:[String] = []
        
        for idxpath in subIdxPaths {
            if marketCoins.count > idxpath.row {
                let entity = marketCoins[idxpath.row]
                coinNames.append("market_\(entity.symbol)_ticker")
                
            }
        }
        let prepareCoins = coinNames.joined(separator: ",")
        debugPrint("############——————>")
        debugPrint(subIdxPaths.count)
        debugPrint("->",prepareCoins.util_subString(end: 300))
        debugPrint("#########################")
        
        EXWebSocket.marketService.addwsTaskSub(event:"sub_batch", channel:prepareCoins, cbid: "")
    }
}

extension EXFavoritesMarketVC{
    
    public func popMenu(cell: HomePageTC){
        cell.contentView.backgroundColor = UIColor.ThemeView.card2
        let v = EXPopMenuView.shared
        let  top = PopMenuItem()
        top.name = "market_edit_like_type_top".localized()
        top.type = .top
        
        let  delete = PopMenuItem()
        delete.name = "market_str_1".localized()
        delete.type = .delete
        v.pop(fromView: cell,acionItem: [top,delete]) {[weak self] menu in
            if menu.type == .top {
                self?.goTop()
            }else{
                self?.andOrDelete()
            }
        }
        v.dismissend = { [weak self] in
            self?.currentCell!.contentView.backgroundColor = UIColor.ThemeView.card1
        }
    }
    
    @objc func andOrDelete(){
        if self.currentCell == nil{
            return
        }
        self.currentCell?.updataCollection(isCollecion: true, iswap: false)
        updateCollections()
        
    }
    @objc func goTop(){
        if self.currentCell == nil{
            return
        }
        handleCellTopAction(symbol: self.currentCell?.entity.symbol ?? "")
    }
    
    
    func handleCellTopAction(symbol:String) {
        let origin = marketCoins.map({return $0.symbol})
        if let moveRow = origin.firstIndex(of: symbol) {
            self.moveRow(fromIdx: IndexPath.init(row: moveRow, section: 0), toIdx: IndexPath.init(row: 0, section: 0))
           let arr = self.marketCoins.map { item -> CoinMapEntity in
                let a = CoinMapEntity()
                a.symbol = item.symbol
                return a
            }
            self.userColletctorVm.handleFavorite(actionType: .other, coinMaps: arr,callback: { [weak self] success in
                if success{
                    self?.updateCollections()
                }
            })
            
//            confirmUpdateAll(false)
        }
    }
    func moveRow(fromIdx:IndexPath,toIdx:IndexPath) {
        let item = marketCoins[fromIdx.row]
        marketCoins.remove(at: fromIdx.row)
        marketCoins.insert(item, at: toIdx.row)
        self.marketListTable.moveRow(at: fromIdx, to: toIdx)
    }
}



extension EXFavoritesMarketVC: JXSegmentedListContainerViewListDelegate {
    func listView() -> UIView {
        return self.view
    }
}

