//
//  EXTopSearchVC.swift
//  Chainup
//
//  Created by liuxuan on 2022/7/25.
//  Copyright © 2022 Chainup. All rights reserved.
//

import UIKit
import JXSegmentedView
import EXKit
import RxSwift

class EXTopSearchVC: BaseVC {
    
    var searchHistorys:[String] = []
    let tagSignal : BehaviorSubject<String> = BehaviorSubject.init(value: "")
    private let coinUsrWm = UserSymbolsVM()

    lazy var titleV:JXSegmentedView = {
        let segment = JXSegmentedView.init(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 44))
        segment.dataSource = self.segmentedDataSource
        segment.indicators = [self.indicatorLienView]
        return segment
    }()

    var topSearchList:[EXHomeTicker] = []

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
    
    lazy var searchHistory:EXTopSearchHistoryV = {
        let h = EXTopSearchHistoryV()
        return h
    }()
    
    lazy var segmentedDataSource: EKIndicatorSegmentDatasource = {
        let source = EKIndicatorSegmentDatasource()
        source.titles = ["search_topSearch_title".localized()]
        return source
    }()
    
    lazy var indicatorLienView: EKIndicatorSegmentIndicator = {
        let view = EKIndicatorSegmentIndicator()
        return view
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        debugPrint("\(self)\n viewWillAppear")
        configHistories()
        goSubBatch()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        debugPrint("\(self)\n viewDidAppear")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        debugPrint("\(self)\n viewWillDisappear")
        EXWebSocket.marketService.cancel()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        debugPrint("\(self)\n viewDidDisappear")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchSearchRecommends()
        self.view.addSubview(self.searchTable)
        self.searchTable.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        prepareWs()

    }
    
    func configHistories() {
        self.searchHistorys = XUserDefault.getSearchArray()
        if self.searchTable.tableHeaderView == nil,searchHistorys.count > 0{
            self.searchHistory.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: EXTopSearchHistoryV.heightForHeader(searchHistorys))
            self.searchHistory.historyContainer.onTagIdxCallback = {[weak self] tagIdx in
                self?.tagSelected(atIdx: tagIdx)
            }
            self.searchHistory.removeBtn.addTarget(self, action: #selector(removeHistories), for: .touchUpInside)
            self.searchTable.tableHeaderView = self.searchHistory
        }
        self.searchHistory.bindingHistorys(coinSymbols: searchHistorys)
    }
    
    @objc func removeHistories() {
        XUserDefault.removeSearchArray()
        self.searchTable.tableHeaderView = nil
    }
    
    func prepareWs() {
        EXWebSocket.marketService.onwsEventCallback
            .subscribe(onNext: {[weak self] (event,datas,symbol) in
                guard let mySelf = self else { return }
                if event == .ticker {
                    mySelf.updateRecommedCell(tick: datas.tick, symbol: symbol)
                }
            }).disposed(by: self.disposeBag)
    }
    
    func fetchSearchRecommends() {
        appApi.rx.request(.recommendSearchSymbol)
            .MJObjectMap(EXSearchRecommedModel.self)
            .subscribe(onSuccess: {[weak self] (model) in
                guard let mySelf = self else{return}
                mySelf.configRecommends(tickers: model.recommendSymbolList)
            }, onFailure: { _ in
                
            }).disposed(by: disposeBag)
    }
    
    func configRecommends(tickers:[EXHomeTicker]) {
        self.topSearchList = tickers
        goSubBatch()
        self.searchTable.reloadData()
    }
    
    func tagSelected(atIdx:Int) {
        if searchHistorys.count > atIdx {
            let tag = searchHistorys[atIdx]
            self.tagSignal.onNext(tag)
        }
    }
    
    func goSubBatch() {
        if self.topSearchList.count > 0 {
            let symbols = self.topSearchList.map({return $0.symbol})
            EXWebSocket.marketService.cancel()
            var tickers :[String] = []
            for symbol in symbols {
                tickers.append("market_\(symbol)_ticker")
            }
            let prepareCoins = tickers.joined(separator: ",")
            //print("Coming to subscribe")
            // print(prepareCoins)
            EXWebSocket.marketService.addwsTaskSub(event:"sub_batch", channel:prepareCoins, cbid: "")
        }
    }
    
    func updateRecommedCell(tick:EXTickerModel,symbol:String) {
        let symbols = self.topSearchList.map({return $0.symbol})
        if let idx = symbols.firstIndex(of: symbol) {
            if let recommendCell = self.searchTable.cellForRow(at: IndexPath.init(row: idx, section: 0)) as? EXTopSearchCell {
                let item = topSearchList[idx]
                item.updateModelWithTicker(ticker: tick)
                recommendCell.updatePriceAndRate(ticker: item)
            }
        }
    }
    
    override func userGoHomeScreen(_ to: Bool) {
        guard let top = AppService.topViewController(),top == self else {return}
        if to {
            EXWebSocket.marketService.cancel()
        }else {
            goSubBatch()
        }
    }
    
}

extension EXTopSearchVC : UITableViewDelegate , UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if topSearchList.count > 0 {
            let v = UIView.init(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 44))
            v.backgroundColor = .Ex.fill2
            v.addSubview(self.titleV)
            return v
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return topSearchList.count > 0 ? 44 : CGFloat.leastNonzeroMagnitude
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return topSearchList.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let entity = topSearchList[indexPath.row]
        let cell : EXTopSearchCell = tableView.dequeueReusableCell(withIdentifier: "EXTopSearchCell") as! EXTopSearchCell
        cell.bindSymbols(ticker: entity, isFavorite: XUserDefault.whetherCollectionCoinMap(entity.symbol), rankIdx: indexPath.row + 1)
        cell.favorateBlock = { [weak self] symolId, btn in
            self?.updateFavotate(symboId: symolId, btn: btn)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let entity = topSearchList[indexPath.row]
        let coinMapItem = EXAppMarketManager.sharedInstance.getCoinMapEntityByName(entity.name)
        XUserDefault.setSearchArray(entity.coinName)
        let vc = EXKlineDetailNewVC(entity:coinMapItem)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
    
}

//Self selected logic processing
extension EXTopSearchVC{
    func updateFavotate(symboId: String, btn: UIButton){
        self.light()
        let toCollection = btn.isSelected //Select ->Favorite
        let actionType:EXFavoritesActionType = toCollection ? .singleAdd : .singleDelete
        let newEntity = CoinMapEntity()
        newEntity.symbol = symboId
        coinUsrWm.handleFavorite(actionType: actionType,
                                 coinMaps: [newEntity],
                                 callback:{ success in
            if !success {
                btn.isSelected = !btn.isSelected
            }
        })
        
    }
}

