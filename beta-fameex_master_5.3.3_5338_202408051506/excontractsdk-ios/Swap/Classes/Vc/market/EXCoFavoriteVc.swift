//
//  EXCoFavoriteVc.swift
//  Chainup
//
//  Created by cwd on 2022/7/19.
//  Copyright © 2022 Chainup. All rights reserved.
//

import UIKit
import JXSegmentedView
import EXKit
import RxSwift
let EXSortMenuBarHeight:CGFloat = 37

enum EXCOMarketSortType {
    case nameUp//名字正序 English: Name in proper order
    case nameDown//名字倒序 English: Name in reverse order
    case priceUp//价格正序 English: Price positive order
    case priceDown//价格倒序 English: Price in reverse order
    case rose//涨跌幅正序 English: Positive order of price fluctuations
    case falls//涨跌幅倒序 English: Reverse order of price fluctuations
    case normal//默认 English: default
}


///Ranking Currency Content List
public class EXCoFavoriteVc: EXSBaseVC {
    var rowDatas:[EXSwapItemModel] = [] {
        didSet{
            subcirDatas = rowDatas.map({ item in
                return item.ex_contractInfo ?? EXContractsModel()
            })
        }
    }
    public var wsEventSubject: PublishSubject<Int> = PublishSubject()
    public var isEmptyDisplay: Bool = true
    var subcirDatas = [EXContractsModel]()
    var vm = EXContractUserVm()
    var isRolling: Bool = false
    var currentSortType:EXCOMarketSortType = .normal
    var currentCell: EXSHomePageTC?
    //record
    var tickerReceiver:[String:EXCOTickerModel] = [:]
    var tickerDisposeBag: Disposable? = nil
    var subIdxPaths:[IndexPath] = []
    lazy var sortMenu : EXSHomePageHV = {
        let view = EXSHomePageHV.init()
        return view
    }()
    ///Recommended view
    lazy var remmondView: EXRecommendView = {
        let v = EXRecommendView()
        v.backgroundColor = .Ex.fill2
        v.btnStyle = .sure
        v.btnTitle = "market_recommand_selet".ex_localized()
        v.btnClick = { [weak self] selected in
            guard let weakSelf = self else { return }
            weakSelf.remmondView.isHidden = true
            print(selected)
            weakSelf.vm.handleCoFavorite(actionType: .other, swapIds: selected,callback: { [weak weakSelf] success in
                if success{
                    weakSelf?.wsEventSubject.onNext(1)
                    let datas = weakSelf?.vm.getLocalFavoriteList()
                    if datas != nil {
                        weakSelf?.rowDatas = datas!
                        weakSelf?.marketListTable.reloadData()
                        weakSelf?.subcriber()
                    }
                }
            })
        }
        return v
    }()
    
    lazy var marketListTable : UITableView = {
        let tableView = UITableView()
        tableView.extUseAutoLayout()
        tableView.rowHeight = 56
        tableView.separatorStyle = .none
        tableView.register(EXSFavoriteTC.classForCoder(), forCellReuseIdentifier: "EXSFavoriteTC")
//        tableView.register(HomePageTC.classForCoder(), forCellReuseIdentifier: "HomePageTC")
        tableView.backgroundColor = UIColor.ThemeView.bg
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        tableView.delegate = self
        tableView.dataSource = self
        tableView.mj_header = EXRefreshHeaderView (refreshingBlock: {[weak self] in
            guard let mySelf = self else{return}
            mySelf.isRolling = true
            mySelf.getlist()
        })
        return tableView
    }()
    
    public  override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(marketListTable)
        configTable()
        updateSubIdxPaths()
        subcriberCallBack()
        handleTicker()
        
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getlist()
        EXSwapItemModel.refreshMaketInfo(list: rowDatas)
        self.marketListTable.reloadData()
    }
    func getlist(){
        self.vm.getFavoriteList { [weak self] items in
            guard let weakSelf = self else { return }
            weakSelf.isRolling = false
            weakSelf.marketListTable.mj_header.endRefreshing()
            if items == nil || items?.count == 0{ //If
                weakSelf.remmondView.isHidden = false
                weakSelf.remmondView.items = EXContractsModel.getSwapRecommandList()
            }else{
                weakSelf.remmondView.isHidden = true
                weakSelf.rowDatas = items!
                weakSelf.marketListTable.reloadData()
                weakSelf.subcriber()
            }
            
        }
    }
    public override func viewDidAppear(_ animated: Bool){
        super.viewDidAppear(animated)
        subcriber()
       
    }
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        cancelSubcriber()
    }
    
    func configTable() {
        marketListTable.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.width.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        sortMenu.clickBtnBlock = {[weak self] sender in
            guard let mySelf = self else{return}
            mySelf.handleMenuBarAction(sender: sender)
        }
        self.view.addSubview(remmondView)
        remmondView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
//Subscription related
extension EXCoFavoriteVc{
    
    func subcriberCallBack(){
        EXSwapSocketManager.shared.onwsEventCallback
            .subscribe(onNext: {[weak self] (event,datas,symbol) in
                guard let mySelf = self else { return }
//                print("event =>\(event)\ndatas =>\(datas)\n,symbol=>\(symbol)")
                if event == .ticker {
                    let tick =  datas.tick
                    mySelf.webSocketUpdateContractTicker(ticker: tick, symbol: datas.channel)
                }
            }).disposed(by: self.exs_disposeBag)
    }
    func cancelSubcriber(){
        EXSwapSocketManager.shared.subscribeTickers(datas: nil,cancel: true)
    }
    func subcriber(){
        cancelSubcriber()
        if self.subcirDatas.count == 0 {
            return
        }
        EXSwapSocketManager.shared.subscribeTickers(datas: self.subcirDatas)
     
    }
    //MARK: - websocket Ticker refresh
    @objc func webSocketUpdateContractTicker(ticker:EXCOTickerModel,symbol:String) {
        tickerReceiver[symbol] = ticker //Record Currency Update
    }
    
    //MARK: Processing subscription information
    func handleTicker() {
        self.handleReceiver()
        self.tickerDisposeBag?.dispose()
        self.tickerDisposeBag = Observable<Int>.interval(.seconds(3), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] (element) in
                guard let `self` = self else { return }
                self.handleReceiver()
            })
    }
    
    //Processing subscription information
    func handleReceiver() {
        let tickers = tickerReceiver
        if self.subIdxPaths.count == 0 {
            updateSubIdxPaths()
        }
        if tickers.count > 0 {
            var updateIdxs:[IndexPath] = [] //Record updated cells
            self.tickerReceiver.removeAll()
//Print ("Contract Timer,  (tickers. count),  (Date())")
            for (symbolkey, ticker) in tickers{
                //Update data
                for (row,obj) in self.rowDatas.enumerated() {
                    if let info = obj.ex_contractInfo, symbolkey.contains(info.wsSymbol() + "_"){
                        updateIdxs.append(IndexPath(row: row, section: 0))
                        obj.change_rate = ticker.rose
                        obj.last_px = ticker.close
                        obj.qty24 = ticker.vol
                    }
                }
            }
            //Refresh UI
            for idxpath in updateIdxs {
                if self.subIdxPaths.contains(idxpath) {
                    if let cell = self.marketListTable.cellForRow(at: idxpath) as? EXSFavoriteTC{
                        let item = self.rowDatas[idxpath.row]
                        cell.bindSwapModel(model: item)
                    }
                }
            }
        }
    }
    func updateSubIdxPaths() {
        if let idxPaths = self.marketListTable.indexPathsForVisibleRows {
            self.subIdxPaths = idxPaths
        }
    }
}

extension EXCoFavoriteVc : UITableViewDelegate, UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rowDatas.count
    }
    
    public  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if rowDatas.count > 0 {
            sortMenu.frame = CGRect(x: 0, y: 0, width: EXSCREEN_WIDTH, height: EXSortMenuBarHeight)
            return self.sortMenu
        }
        return UIView()
    }
    
    public  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return rowDatas.count > 0 ? EXSortMenuBarHeight : CGFloat.leastNonzeroMagnitude
    }
    
    public  func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    public  func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
    
    public  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let entity = rowDatas[indexPath.row]
        let cell : EXSFavoriteTC = tableView.dequeueReusableCell(withIdentifier: "EXSFavoriteTC") as! EXSFavoriteTC
        cell.bindSwapModel(model: entity)
        cell.longCellBlock = { [weak self, weak cell]  in
            guard let c = cell else { return }
            self?.currentCell = c
            self?.popMenu(cell: c)
        }
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let entity = rowDatas[indexPath.row]
        let vc = EXSwapKLineDetailVC()
        vc.itemModel = entity
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

//MARK: -- empty
extension EXCoFavoriteVc {
    public func emptyDataSetShouldDisplay(_ scrollView: UIScrollView!) -> Bool {
        return isEmptyDisplay
    }
}

extension EXCoFavoriteVc{
    public  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        isRolling = false
    }
    
    public  func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        isRolling = true
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        isRolling = true
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        isRolling = true
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
//        tryToGetCurrentVisibleCells()
        isRolling = false
    }
    
    public  func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
//        tryToGetCurrentVisibleCells()
        isRolling = false
    }
}
extension EXCoFavoriteVc {
    func handleMenuBarAction(sender:EXCODoubleArrorwIconButton) {
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
        self.rowDatas = getSortCoins()
        marketListTable.reloadData()
    }
    
    func getSortCoins() -> [EXSwapItemModel] {
        var sorted:[EXSwapItemModel] = []
        switch currentSortType {
        case .normal:
            sorted = self.vm.getLocalFavoriteList() ?? [EXSwapItemModel]()
//            sorted = rowDatas.sorted { (a, b) -> Bool in
//                return a.instrument_id < b.instrument_id
//            }
            break
        case .nameUp:
            sorted = rowDatas.sorted { (a, b) -> Bool in
                return a.symbol < b.symbol
            }
        case .nameDown:
            sorted = rowDatas.sorted { (a, b) -> Bool in
                return a.symbol > b.symbol
            }
        case .priceUp:
            sorted = rowDatas.sorted { (a, b) -> Bool in
                let doubleA:Double = Double(a.last_px) ?? 0
                let doubleB:Double = Double(b.last_px) ?? 0
                return doubleA < doubleB
            }
        case .priceDown:
            sorted = rowDatas.sorted { (a, b) -> Bool in
                let doubleA:Double = Double(a.last_px) ?? 0
                let doubleB:Double = Double(b.last_px) ?? 0
                return doubleA > doubleB
            }
        case .falls:
            sorted = rowDatas.sorted { (a, b) -> Bool in
                let doubleA:Double = Double(a.change_rate) ?? 0
                let doubleB:Double = Double(b.change_rate) ?? 0
                return doubleA > doubleB
            }
        case .rose:
            sorted = rowDatas.sorted { (a, b) -> Bool in
                let doubleA:Double = Double(a.change_rate) ?? 0
                let doubleB:Double = Double(b.change_rate) ?? 0
                return doubleA < doubleB
            }
        }
        return sorted
    }
}


///Long press and hold operations written in the cell are not effective
extension EXCoFavoriteVc{
    
    public func popMenu(cell: EXSHomePageTC){
        cell.contentView.backgroundColor = UIColor.ThemeView.card2
        let v = EXPopMenuView.shared
        let  top = PopMenuItem()
        top.name = "market_edit_like_type_top".ex_localized()
        top.type = .top
        
        let  delete = PopMenuItem()
        delete.name = "market_str_1".ex_localized()
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
        self.currentCell?.updataCollection(isCollecion: true, iswap: true,callBack: {
            [weak self] in
            self?.getlist()
        })
    }
    @objc func goTop(){
        if self.currentCell == nil{
            return
        }
        handleCellTopAction(swap: self.currentCell!.swapItem ?? EXSwapItemModel())
    }
    
    
    func handleCellTopAction(swap:EXSwapItemModel) {
        let origin = rowDatas
        if let moveRow = origin.firstIndex(of: swap) {
            self.moveRow(fromIdx: IndexPath.init(row: moveRow, section: 0), toIdx: IndexPath.init(row: 0, section: 0))
           let arr = self.rowDatas.map { item -> String in
               return String(item.instrument_id)
            }
            self.vm.handleCoFavorite(actionType: .other, swapIds: arr,callback: { [weak self] success in
                if success{
                   // self?.updateCollections()
                }
            })
            
//            confirmUpdateAll(false)
        }
    }
    func moveRow(fromIdx:IndexPath,toIdx:IndexPath) {
        let item = rowDatas[fromIdx.row]
        rowDatas.remove(at: fromIdx.row)
        rowDatas.insert(item, at: toIdx.row)
        self.marketListTable.moveRow(at: fromIdx, to: toIdx)
    }
}


extension EXCoFavoriteVc: JXSegmentedListContainerViewListDelegate {
    public func listView() -> UIView {
        return self.view
    }
}

