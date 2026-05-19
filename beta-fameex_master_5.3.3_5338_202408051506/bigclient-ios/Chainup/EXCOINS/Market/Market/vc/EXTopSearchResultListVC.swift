//
//  EXTopSearchResultListVC.swift
//  Chainup
//
//  Created by liuxuan on 2022/7/25.
//  Copyright © 2022 Chainup. All rights reserved.
//

import UIKit
import EXKit
import JXSegmentedView
import Swap
class EXTopSearchResultListVC: BaseVC {
    var vcType: EXMarketSegmentType = .exchange
    private var dataSources:[CoinMapEntity] = []
    private var contractDataSources:[EXSwapItemModel] = []
    //Process Selection
    private let contractUsrWm = EXContractUserVm()
    private let coinUsrWm = UserSymbolsVM()
    lazy var searchTable : UITableView = {
        let v = UITableView(frame: .zero, style: .plain)
        v.backgroundColor = .clear
        v.separatorStyle = .none
        v.register(EXTopSearchCell.classForCoder(), forCellReuseIdentifier: "EXTopSearchCell")
        v.emptyDataSetSource = self
        v.emptyDataSetDelegate = self
        v.delegate = self
        v.dataSource = self
        return v
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareWs()
        self.view.addSubview(searchTable)
        searchTable.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.goSubBatch()
        debugPrint("\(self)\n viewWillAppear")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        debugPrint("\(self)\n viewDidAppear")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        debugPrint("\(self)\n viewWillDisappear")
        if vcType == .coExchange{
            cancelContractSubcriber()
        }else{
            EXWebSocket.marketService.cancel()
        }
    }
    
    
    func reloadResults(rsts:[CoinMapEntity]) {
//        print("Updated search results")
        self.dataSources = rsts
        self.goSubBatch()
        self.searchTable.reloadData()
    }
    
    func reloadContractResults(rsts:[EXSwapItemModel]?) {
        if rsts == nil{
            self.contractDataSources.removeAll()
        }else{
            self.contractDataSources = rsts!
        }
        self.searchTable.reloadData()
        //When I first entered the interface and came out, I received empty data
        contractSubcriber()
    }
    
    func prepareWs() {
        if vcType == .coExchange{
            EXSwapSocketManager.shared.onwsEventCallback
                .subscribe(onNext: {[weak self] (event,datas,symbol) in
                    guard let mySelf = self else { return }
//                    print("swap ==event =>\(event)\ndatas =>\(datas)\n,symbol=>\(symbol)")
                    if event == .ticker {
                        let tick = EXTickerModel.getNewInstanceFromModel(tick: datas.tick)
                        mySelf.webSocketUpdateContractTicker(ticker: tick, symbol: datas.channel)
                    }
                }).disposed(by: self.exs_disposeBag)
            
        }else{
            EXWebSocket.marketService.onwsEventCallback
                .subscribe(onNext: {[weak self] (event,datas,symbol) in
                    guard let mySelf = self else { return }
                    if event == .ticker {
                        mySelf.updateRecommedCell(tick: datas.tick, symbol: symbol)
                    }
                }).disposed(by: self.disposeBag)
        }
    }
    
    func goSubBatch() {
        if self.dataSources.count > 0 {
            let symbols = self.dataSources.map({return $0.symbol})
            EXWebSocket.marketService.cancel()
            var tickers :[String] = []
            for symbol in symbols {
                tickers.append("market_\(symbol)_ticker")
            }
            let prepareCoins = tickers.joined(separator: ",")
//Print ("Coming to subscribe")
//            print(prepareCoins)
            EXWebSocket.marketService.addwsTaskSub(event:"sub_batch", channel:prepareCoins, cbid: "")
        }else {
            EXWebSocket.marketService.cancel()
        }
    }
    
    func updateRecommedCell(tick:EXTickerModel,symbol:String) {
        let symbols = self.dataSources.map({return $0.symbol})
        if let idx = symbols.firstIndex(of: symbol) {
            if let recommendCell = self.searchTable.cellForRow(at: IndexPath.init(row: idx, section: 0)) as? EXTopSearchCell {
                let item = dataSources[idx]
                if let entity = EXHomeTicker.mj_object(withKeyValues: item) {
                    entity.updateModelWithTicker(ticker: tick)
                    recommendCell.updatePriceAndRate(ticker: entity)
                }
            }
        }
    }

}

extension EXTopSearchResultListVC : UITableViewDelegate , UITableViewDataSource{

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if vcType == .coExchange{
            return contractDataSources.count
        }
        return dataSources.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell : EXTopSearchCell = tableView.dequeueReusableCell(withIdentifier: "EXTopSearchCell") as! EXTopSearchCell
        cell.vcType = self.vcType
        if vcType == .coExchange {
            let contract = self.contractDataSources[indexPath.row]
            cell.model = contract
        }else {
            let entity = dataSources[indexPath.row]
            if let ticker = EXHomeTicker.mj_object(withKeyValues: entity) {
                cell.bindSymbols(ticker: ticker, isFavorite: XUserDefault.whetherCollectionCoinMap(ticker.symbol) ? true : false)
            }
        }
        cell.favorateBlock = { [weak self] symolId, btn in
            self?.updateFavotate(symboId: symolId, btn: btn)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if vcType == .coExchange{
            let vc = EXSwapKLineDetailVC()
            let itemModel = self.contractDataSources[indexPath.row]
            if let symbol = itemModel.ex_contractInfo?.showName(){
                XUserDefault.setSearchArray(symbol)
            }
            vc.itemModel = itemModel
            self.navigationController?.pushViewController(vc, animated: true)
        }else{
            let entity = dataSources[indexPath.row]
            XUserDefault.setSearchArray(entity.coinName)
            let vc = EXKlineDetailNewVC(entity:entity)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

}


extension EXTopSearchResultListVC:JXSegmentedListContainerViewListDelegate {
    func listView() -> UIView {
        return self.view
    }
    
}

//Self selected logic processing
extension EXTopSearchResultListVC{
    
    func updateFavotate(symboId: String, btn: UIButton){
        let toCollection = btn.isSelected //Select ->Favorite
        self.light()
        let actionType:EXFavoritesActionType = toCollection ? .singleAdd : .singleDelete
        let contractAction: EXContractFavoritesActionType = toCollection ? .singleAdd : .singleDelete
        if vcType == .coExchange{
            contractUsrWm.handleCoFavorite(actionType: contractAction, swapIds: [symboId]) { [weak self] success in
                if success{
                }else{
                    btn.isSelected = !btn.isSelected //Request failed, button restored to - Unfavored state
                }
            }
        }else{
           
            let newEntity = CoinMapEntity()
            newEntity.symbol = symboId
            coinUsrWm.handleFavorite(actionType: actionType,
                              coinMaps: [newEntity],
                              callback:{[weak self] success in
                if success{
                }else{
                    btn.isSelected = !btn.isSelected
                }
            })
        }
    }
}

extension EXTopSearchResultListVC{
    
    //contract
    func cancelContractSubcriber(){
        EXSwapSocketManager.shared.subscribeTickers(datas: nil,cancel: true)
    }
    
    func contractSubcriber(){
        if self.contractDataSources.count == 0 { //Unable to search
            cancelContractSubcriber()
            return
        }
        let subcirDatas = self.contractDataSources.map({ item in
            return item.ex_contractInfo ?? EXContractsModel()
        })
        EXSwapSocketManager.shared.subscribeTickers(datas: subcirDatas)
        
    }
    
    
    //MARK: - websocket Ticker refresh
    func webSocketUpdateContractTicker(ticker:EXTickerModel,symbol:String) {
        for obj in self.contractDataSources {
            if let info = obj.ex_contractInfo,  symbol.contains(info.wsSymbol() + "_"){
                obj.change_rate = ticker.rose
                obj.last_px = ticker.close
                updateTicker(itemModel: obj)
                break
            }
        }
        
    }
    
    private func updateTicker(itemModel:EXSwapItemModel) {
        var changeIdx:Int?
        for (idx,item) in self.contractDataSources.enumerated() {
            if item.instrument_id == itemModel.instrument_id {
                changeIdx = idx
                break
            }
        }
        guard let rowIdx = changeIdx else {return}
        contractDataSources[rowIdx] = itemModel
        if let cell = searchTable.cellForRow(at: IndexPath.init(row: rowIdx, section: 0)) as? EXTopSearchCell {
            //Update only the currently visible cells
            if (!self.searchTable.visibleCells.contains(cell)){
                return
            }
            cell.model = itemModel
        }
    }
}

