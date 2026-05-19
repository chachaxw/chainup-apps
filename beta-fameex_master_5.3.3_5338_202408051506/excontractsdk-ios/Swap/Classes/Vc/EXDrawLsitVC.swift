//
//  EXDrawLsitVC.swift
//  Chainup
//
//  Created by cwd on 2022/11/2.
//  Copyright © 2022 Chainup. All rights reserved.
//

import UIKit
import RxSwift
import JXSegmentedView
import EXKit

class EXDrawLsitVC: EXSBaseVC, EXEmptyDataSetable {
    static let tickerInterval: Int =  1
    var isUserLike = false
    var firstTime = true
    var colorModle = UIColor.Ex.global
    let useLike = EXContractUserVm()
    var searchkey = ""
    var vm = EXDrawViewModel() {
        didSet{
            eventSub()
        }
    }
    var orinDatas: [EXSwapItemModel] = []
    var rowDatas:[EXSwapItemModel] = [] {
        didSet{
            subcirDatas = rowDatas.map({ item in
                return item.ex_contractInfo ?? EXContractsModel()
            })
            marketListTable.reloadData()
        }
    }
    var timeInval = 0
    var subcirDatas = [EXContractsModel]()
    var isRolling: Bool = true //By default, there is no need to brush the interface before it appears
    var subIdxPaths:[IndexPath] = []
    //record
    var tickerReceiver:[String:EXCOTickerModel?] = [:]
    var tickerDisposeBag: Disposable? = nil
    private let cellId = "EXDrawerListCell"
    //MARK: When the lifecycle first appears, all interfaces will appear before subscribing to events
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(marketListTable)
        configTable()
        self.view.backgroundColor = colorModle.fill6
        if self.isUserLike{
            getUserLike()
        }
        handleTicker()
//        //MARK: Market search subscriptions cannot be placed here. There are three interfaces: A/B/C, and only when all three interfaces have been loaded can there be subscriptions
//        self.vm.eventSubject.subscribe(onNext: { [weak self] type in
//            switch type{
//            case .updateTicker(let ticker, let symbol):
//                self?.tickerReceiver[symbol] = ticker
//            case .searchKey(let keyWord):
//                self?.updateData(key: keyWord)
//            default:
//                break
//            }
//        }).disposed(by: disposeBag)
    }
    
    func eventSub(){
        //MARK: Market data subscription
        self.vm.eventSubject.subscribe(onNext: { [weak self] type in
            switch type{
            case .updateTicker(let ticker, let symbol):
                self?.tickerReceiver[symbol] = ticker
            case .searchKey(let keyWord):
                self?.updateData(key: keyWord)
            default:
                break
            }
        }).disposed(by: disposeBag)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        EXSwapItemModel.refreshMaketInfo(list: rowDatas)
        self.marketListTable.reloadData()

    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        isRolling = false
        ///Delaying acquisition or incorrect data acquisition
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { [weak self] in
            self?.updateSubIdxPaths()
        }
        if self.subIdxPaths.count > 0 { //Update self selection
            self.marketListTable.reloadRows(at: self.subIdxPaths, with: .none)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        isRolling = true
        
    }
    
    //MARK: Method
    func configTable() {
        marketListTable.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    //MARK: lazy
    lazy var marketListTable : UITableView = {
        let tableView = UITableView()
        tableView.extUseAutoLayout()
        tableView.rowHeight = 54
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none
        tableView.register(EXDrawerListCell.self, forCellReuseIdentifier: cellId)
        tableView.backgroundColor =  .clear// colorModle.fill6//UIColor.ThemeView.alertBg
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()
    
}
//Subscription related
extension EXDrawLsitVC{
    //MARK: Processing subscription information
    func handleTicker() {
        self.handleReceiver()
        self.tickerDisposeBag?.dispose()
        self.tickerDisposeBag = Observable<Int>.interval(.seconds(EXDrawLsitVC.tickerInterval), scheduler: MainScheduler.instance)
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
        if isRolling {
            return
        }
        if tickers.count > 0 {
            var updateIdxs:[IndexPath] = [] //Record updated cells
            self.tickerReceiver.removeAll() //Clear data every 3 seconds
//Print ("Contract Timer,  (tickers. count),  (Date())")
            for (symbolkey, tickerModel) in tickers{
                guard let ticker = tickerModel else { continue }
                //Update data
                for (row,obj) in self.rowDatas.enumerated() {
                    if let info = obj.ex_contractInfo, symbolkey.contains(info.wsSymbol() + "_"){
                        updateIdxs.append(IndexPath(row: row, section: 0))
                        obj.change_rate = ticker.rose
                        obj.last_px = ticker.close
                        obj.qty24 = ticker.vol
                       //Print ("Update data r,  (tickers. count),  (Date())")
                    }
                }
            }
            //Refresh UI
            for idxpath in updateIdxs {
                if self.subIdxPaths.contains(idxpath) {
                    if let cell = self.marketListTable.cellForRow(at: idxpath) as? EXDrawerListCell{
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

extension EXDrawLsitVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rowDatas.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let entity = rowDatas[indexPath.row]
        let cell : EXDrawerListCell = tableView.dequeueReusableCell(withIdentifier: cellId) as! EXDrawerListCell
        cell.colorModue  = self.colorModle
        cell.bindSwapModel(model: entity)
        cell.userliker = self.isUserLike
        cell.needRefreshList = { [weak self] in  //Self selected deletion requires refreshing the list
            self?.getUserLike()
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let entity = rowDatas[indexPath.row]
        self.vm.eventSubject.onNext(.selectFinsh(item: entity))
    }
}
extension EXDrawLsitVC{
    func updateData(key: String){
        //print("updateData = ====")
        self.searchkey = key
        if key == "" {
            self.rowDatas = self.orinDatas
        }else{
            self.rowDatas = self.orinDatas.filter({ item  in
             //   //print("key == \(key) -- name=\(item.ex_contractInfo?.showName())")
                if let name = item.ex_contractInfo?.showName(),name.uppercased().contains(key.uppercased()){
                    //print("key == \(key.uppercased()) -- name=\(name.uppercased())")
                    return true
                }
                return false
            })
        }
        updateSubIdxPaths()
    }
    
    func getUserLike(){
        useLike.getFavoriteList { [weak self] userList in
            guard userList != nil else{
                return
            }
            guard let newSelf = self else { return }
           //MARK: After completing the self selected network request, refresh and search for key
//            //print("Refresh Selection")
            newSelf.rowDatas = userList!
            newSelf.orinDatas = userList!
            newSelf.updateData(key: newSelf.searchkey)
        }
    }
}
extension EXDrawLsitVC{
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
        isRolling = false
        updateSubIdxPaths()
    }
    
    func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        isRolling = false
        updateSubIdxPaths()
    }
}

extension EXDrawLsitVC: JXSegmentedListContainerViewListDelegate {
    func listView() -> UIView {
        return self.view
    }
    //MARK:
    func listWillAppear(){
        if firstTime == false{
            return
        }
        firstTime = true
        //MARK: Process the first search of the market
        //print("listWillAppear")
        self.updateData(key: searchkey)
    }
    override func verticalOffset(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
        return  -135
    }
}


