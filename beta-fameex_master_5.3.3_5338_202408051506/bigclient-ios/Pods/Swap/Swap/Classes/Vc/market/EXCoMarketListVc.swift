//
//  EXCoMarketListVc.swift
//  Chainup
//
//  Created by liuxuan on 2023/9/23.
//  Copyright © 2023 ChainUP. All rights reserved.
//

import UIKit
import RxSwift
import DeepDiff
import JXSegmentedView
import EXKit
class EXCoMarketListVc: EXSBaseVC {
    var rowDatas:[EXSwapItemModel] = [] {
        didSet{
            subcirDatas = rowDatas.map({ item in
                return item.ex_contractInfo ?? EXContractsModel()
            })
            updateSubIdxPaths()
            
        }
    }
    var timeInval = 0
    var subcirDatas = [EXContractsModel]()
    var isRolling: Bool = false
    var currentSortType:EXCOMarketSortType = .normal
    var subIdxPaths:[IndexPath] = []
    var tickerReceiver:[String:EXCOTickerModel] = [:]
    var tickerDisposeBag: Disposable? = nil
    
    lazy var sortMenu : EXSHomePageHV = {
        let view = EXSHomePageHV.init()
        return view
    }()
    
    lazy var marketListTable : UITableView = {
        let tableView = UITableView()
        tableView.extUseAutoLayout()
        tableView.rowHeight = 56
        tableView.separatorStyle = .none
        tableView.register(EXSHomePageTC.classForCoder(), forCellReuseIdentifier: "EXSHomePageTC")
        tableView.backgroundColor = UIColor.ThemeView.bg
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        tableView.delegate = self
        tableView.dataSource = self
        tableView.mj_header = EXRefreshHeaderView (refreshingBlock: {[weak self] in
            guard let mySelf = self else{return}
            mySelf.handleReceiver()
        })
        
        return tableView
    }()
    
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        EXSwapItemModel.refreshMaketInfo(list: rowDatas)
        self.marketListTable.reloadData()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        subcriber()
        handleTicker()
        updateSubIdxPaths()

        EXSwapItemModel.refreshMaketInfo(list: rowDatas)
        if self.subIdxPaths.count > 0 { //Update self selection
            self.marketListTable.reloadRows(at: self.subIdxPaths, with: .none)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        cancelSubcriber()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(marketListTable)
        configTable()
        updateSubIdxPaths()
        EXSwapItemModel.refreshMaketInfo(list: rowDatas)
        self.marketListTable.reloadData()

    }
}
//订阅相关 English: Subscription related
extension EXCoMarketListVc{
    func cancelSubcriber(){
        EXSwapSocketManager.shared.subscribeTickers(datas: nil,cancel: true)
    }
    func subcriber(){
        EXSwapSocketManager.shared.subscribeTickers(datas: self.subcirDatas)
        EXSwapSocketManager.shared.onwsEventCallback
            .subscribe(onNext: {[weak self] (event,datas,symbol) in
                guard let mySelf = self else { return }
//                //print("event =>\(event)\ndatas =>\(datas)\n,symbol=>\(symbol)")
                if event == .ticker {
                    mySelf.webSocketUpdateContractTicker(ticker: datas.tick, symbol: datas.channel)
                }
            }).disposed(by: self.exs_disposeBag)
    }
    // MARK: - websocket Ticker 刷新 English: MARK: - websocket Ticker refresh
    @objc func webSocketUpdateContractTicker(ticker:EXCOTickerModel,symbol:String) {
        tickerReceiver[symbol] = ticker //
    }
    
    //MARK:
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
        if self.subIdxPaths.count == 0 {
            updateSubIdxPaths()
        }
        if tickers.count > 0 {
            var updateIdxs:[IndexPath] = [] //
            self.tickerReceiver.removeAll()
//            //print("Timer,\(tickers.count),\(Date())")
            for (symbolkey, ticker) in tickers{
               
                for (row,obj) in self.rowDatas.enumerated() {
                    if let info = obj.ex_contractInfo, symbolkey.contains(info.wsSymbol() + "_"){
                        updateIdxs.append(IndexPath(row: row, section: 0))
                        obj.change_rate = ticker.rose
                        obj.last_px = ticker.close
                        obj.qty24 = ticker.vol
                    }
                }
            }
         
            for idxpath in updateIdxs {
                if self.subIdxPaths.contains(idxpath) {
                    if let cell = self.marketListTable.cellForRow(at: idxpath) as? EXSHomePageTC{
                        let item = self.rowDatas[idxpath.row]
                        cell.bindSwapModel(model: item)
                    }
                }
            }
        }
        self.marketListTable.mj_header.endRefreshing()
    }
    func updateSubIdxPaths() {
        if let idxPaths = self.marketListTable.indexPathsForVisibleRows {
            self.subIdxPaths = idxPaths
        }
    }
}

extension EXCoMarketListVc : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rowDatas.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if rowDatas.count > 0 {
            sortMenu.frame = CGRect(x: 0, y: 0, width: EXSCREEN_WIDTH, height: EXSortMenuBarHeight)
            return self.sortMenu
        }
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return rowDatas.count > 0 ? EXSortMenuBarHeight : CGFloat.leastNonzeroMagnitude
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let entity = rowDatas[indexPath.row]
        let cell : EXSHomePageTC = tableView.dequeueReusableCell(withIdentifier: "EXSHomePageTC") as! EXSHomePageTC
        cell.bindSwapModel(model: entity)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let entity = rowDatas[indexPath.row]
        let vc = EXSwapKLineDetailVC()
        vc.itemModel = entity
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
extension EXCoMarketListVc{
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        isRolling = false
        updateSubIdxPaths()
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
//        tryToGetCurrentVisibleCells()
        isRolling = false
    }
    
    func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
//        tryToGetCurrentVisibleCells()
        isRolling = false
    }
}
extension EXCoMarketListVc {
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
            sorted = rowDatas.sorted { (a, b) -> Bool in
                return a.instrument_id < b.instrument_id
            }
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


extension EXSwapItemModel:DiffAware{}
extension EXCoMarketListVc: JXSegmentedListContainerViewListDelegate {
    func listView() -> UIView {
        return self.view
    }
}

