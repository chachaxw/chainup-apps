//
//  SearchView.swift
//  AppProject
//
//  Created by zewu wang on 2023/8/6.
//  Copyright © 2023年 zewu wang. All rights reserved.
//

import UIKit
import RxSwift
import DZNEmptyDataSet
import EXKit
class SearchEntity: CoinMapEntity {
    var img = ""
    var state = "0"
}

enum SearchType {
    case addCoinMap//Add Coin Pairs
    case searchCoinMap//Search for currency pairs
    case searchCoinMapCashflow//Search for running currency pairs
}

class SearchView: UIView {
    
    typealias ClickCellBlock = (SearchEntity) -> ()
    typealias ClickCancelBtnBlock = () -> ()//Callback by clicking the cancel button

    var clickCellBlock : ClickCellBlock?//Click on the callback of the cell
    var clickCancelBtnBlock : ClickCancelBtnBlock?

    var tableViewRowDatas : [SearchEntity] = []
    var tmpArray : [SearchEntity] = []

    var searchType = SearchType.addCoinMap
    var searchKey:String = ""

    lazy var searchHeadV : SearchHeadV = {
        let view = SearchHeadV.init(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 24))
        view.clickCancelBlock = {[weak self] () in
            guard let mySelf = self else{return}
            mySelf.setTmpArray()
            mySelf.reloadSearchView(mySelf.tmpArray)
        }
        return view
    }()
    
    //Search bar
    lazy var searchBar1 : EXNaviSearchBar = {
        let searchBar = EXNaviSearchBar()
        searchBar.extUseAutoLayout()
        return searchBar
    }()
    
    //Display page
    lazy var tableView : UITableView = {
        let tableView = UITableView()
        tableView.extUseAutoLayout()
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.extRegistCell([SearchTC.classForCoder(),SearchChooseImgVTC.classForCoder(),SearchAddTC.classForCoder()], ["SearchTC","SearchChooseImgVTC","SearchAddTC"])
        tableView.backgroundColor = UIColor.ThemeView.bg
        return tableView
    }()
    
    @objc func customBack() {
        clickCancelBtnBlock?()
    }
    

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.ThemeView.bg
        addSubViews([searchBar1,tableView])
        addConstraints()
        configHotHeader()
        
        searchBar1.cancelBtn.addTarget(self, action: #selector(customBack), for: .touchUpInside)
        searchBar1.searchField.rx.text.orEmpty.asObservable()
            .distinctUntilChanged()
            .subscribe(onNext:{[weak self] text in
                self?.searchForKey(text)
            }).disposed(by: self.disposeBag)
        //Received notification of successful interface return
        EXAppMarketManager.sharedInstance.getHotCoins()
        EXAppMarketManager.sharedInstance.onMarketPublish
            .subscribe(onNext: {[weak self] (success) in
                guard let `self` = self else {return}
                if success {
                    if let text = self.searchBar1.searchField.text {
                        self.searchForKey(text)
                    }
                }
            }).disposed(by: self.disposeBag)
    }
    
    func addConstraints() {
        searchBar1.snp.makeConstraints { (make) in
            make.left.right.equalTo(self)
            make.top.equalTo(0)
            make.height.equalTo(NAV_SCREEN_HEIGHT)
        }
        
        tableView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(searchBar1.snp.bottom)
        }
    }
    
    func configHotHeader() {
        if searchKey.count > 0 && tableViewRowDatas.count == 0 {
            self.tableView.tableHeaderView = nil
            return
        }
        if let coins = EXAppCache.sharedCache.getHotCoins() {
            let hotCoinView = EXHotCoinHeader.init(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: EXHotCoinHeader.getHeight(hotCoins: coins)))
            hotCoinView.itemDidChangeBlock = {[weak self] coin in
                self?.searchBar1.searchField.text = coin
                self?.searchBar1.searchField.sendActions(for: .valueChanged)
//                self?.searchForKey(coin)
            }
            self.tableView.tableHeaderView = hotCoinView
        }
    }
    
    func reloadSearchView(_ arr : [SearchEntity]){
        self.tableViewRowDatas = arr
        configHotHeader()
        self.tableView.reloadData()
    }
    
    func setTmpArray(){
        let searchArray = XUserDefault.getSearchArray()
        var array : [CoinMapEntity] = []
        for name in searchArray{
            let entity = EXAppMarketManager.sharedInstance.getCoinMapEntityByName(name) 
            array.append(entity)
        }
        var arr : [SearchEntity] = []
        for item in array{
            let entity = SearchEntity()
            entity.name = item.name
            entity.img = item.coinListEntity().icon
            arr.append(entity)
        }
        tmpArray = arr
    }
    
    func getHotHeaderView() -> UIView? {
        return self.tableView.tableHeaderView
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension SearchView : UITableViewDelegate , UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let searchArray = XUserDefault.getSearchArray()
        return searchArray.count > 0 ? searchHeadV : nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if self.searchType == .addCoinMap{
            if self.searchBar1.searchField.text == ""{
                let searchArray = XUserDefault.getSearchArray()
                return searchArray.count > 0 ? 24 : 0
            }
        }
        return 0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewRowDatas.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 48
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let entity = tableViewRowDatas[indexPath.row]
        switch searchType {
        case .addCoinMap:
            let cell : SearchAddTC = tableView.dequeueReusableCell(withIdentifier: "SearchAddTC") as! SearchAddTC
            cell.setCellWithEntity(entity)
            return cell
        case .searchCoinMap:
            let cell : SearchTC = tableView.dequeueReusableCell(withIdentifier: "SearchTC") as! SearchTC
            cell.setCellWithEntity(entity)
            return cell
        case .searchCoinMapCashflow:
            let cell : SearchChooseImgVTC = tableView.dequeueReusableCell(withIdentifier: "SearchChooseImgVTC") as! SearchChooseImgVTC
            cell.setCellWithEntity(entity)
            return cell
        }
       
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.searchType == .addCoinMap{
            let entity = tableViewRowDatas[indexPath.row]
            XUserDefault.setSearchArray(entity.name)
            self.searchBar1.searchField.text = ""
            clickCellBlock?(entity)
        }else{
            let entity = tableViewRowDatas[indexPath.row]
            clickCellBlock?(entity)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.endEditing(true)
    }
    
}

extension SearchView {
    
    func searchForKey(_ searchText:String) {
        self.searchKey = searchText
        if searchType == .searchCoinMapCashflow{
            if searchText == ""{
                reloadSearchView(tmpArray)
            }else{
                var array : [SearchEntity] = []
                for item in  EXAppMarketManager.sharedInstance.getSearchCoinList(searchText){
                    let entity = SearchEntity()
                    entity.name = item.name
                    entity.img = item.icon
                    array.append(entity)
                }
                reloadSearchView(array)
            }
        }else{
            if searchText == ""{
                reloadSearchView(tmpArray)
            }else{
                var array : [SearchEntity] = []
                for item in  EXAppMarketManager.sharedInstance.getSearchCoinMapList(searchText){
                    let entity = SearchEntity()
                    entity.name = item.name
                    entity.img = item.coinListEntity().icon
                    entity.state = XUserDefault.whetherCollectionCoinMap(item.symbol) ? "1" : "0"
                    array.append(entity)
                }
                reloadSearchView(array)
            }
        }
    }
}

extension SearchView {
    
    func emptyDataSetShouldDisplay(_ scrollView: UIScrollView!) -> Bool {
        //Display a blank view when the search result is empty
        return (searchKey.count > 0 && tableViewRowDatas.count == 0)
    }
}

