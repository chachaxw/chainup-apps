//
//  EXLeverageJournalVc.swift
//  Chainup
//
//  Created by ljw on 2023/11/6.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit

class EXLeverageJournalVc:  BaseVC,NavigationPlugin,EXEmptyDataSetable {
    let filter = EXFilterView()
    var filterParam = [String:String]()
    var coinMapfilterModel = EXFilterDataModel()
    
    var coinMapName = ""
    var type = "1"//1 Current, 2 History, 3 Transfer Record
    var currentModelsArr = [EXCurrentBorrowListModel]()
    var historyModelsArr = [EXCurrentBorrowListModel]()
    var transModelsArr = [EXLeveTransferListModel]()
    var page = 1
    var pageSize: UInt8 = 20
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var topMarginCon: NSLayoutConstraint!
    internal lazy var navigation : EXNavigation = {
        let nav =  EXNavigation.init(affectScroll: self.tableView, presenter: self)
        nav.isLastNavigationStyle = true
        return nav
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        handNavigationBar()
        bindCell()
        self.exEmptyDataSet(self.tableView, attributeBlock: { () -> ([EXEmptyDataSetAttributeKeyType : Any]) in
            return [
                .verticalOffset:(CGFloat(-110)),
            ]
        })
    }
    func handNavigationBar() {
        self.navigation.setTitle(title:"assets_action_journalaccount".localized())
        self.navigation.setdefaultType(type: .list)
        navigation.configRightItems(["public_filter"])
        navigation.rightItemCallback = {[weak self] tag in
            self?.filterAction()
        }
    }
    func filterAction() {
        if filter.isShow {
            return
        }
        filter.delegate = self
        filter.filterParams = self.filterParam
        filter.show(inView: self.view)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
         self.filter.dismissFilter()
    }
    func largeTitleValueChanged(height: CGFloat) {
        topMarginCon.constant = height
    }
    func bindCell()  {
        self.tableView.backgroundColor = UIColor.ThemeView.bg
        tableView.register(UINib.init(nibName: "EXLeverageJournalCell", bundle: nil), forCellReuseIdentifier: "EXLeverageJournalCell")
        tableView.rowHeight = UITableView.automaticDimension;
        tableView.estimatedRowHeight = 200;
        self.tableView.mj_header = EXRefreshHeaderView (refreshingBlock: {[weak self] in
              guard let mySelf = self else{return}
              mySelf.page = 1
              mySelf.getListData()
          })
          self.tableView.mj_footer = EXRefreshFooterView (refreshingBlock: {[weak self] in
              guard let mySelf = self else{return}
              mySelf.getListData()
          })
        self.tableView.mj_footer.isHidden = true
          getListData()
    }
}
extension EXLeverageJournalVc {
    func getListData() {
        
        if type == "1" {
            appApi.rx.request(.leverCurrentBorrow(symbol:(coinMapName as NSString).replacingOccurrences(of: "/", with: "").uppercased(), startTime: nil, endTime: nil, page:String(page), pageSize: String(pageSize)))
                .MJObjectMap(EXCurrentBorrowModel.self)
                .subscribe{[weak self] event in
                    switch event {
                    case .success(let model):
                    guard let mySelf = self else{return}
                    if mySelf.page == 1{
                        mySelf.currentModelsArr.removeAll()
                    }
                        mySelf.tableView.mj_footer.isHidden = false
                        if model.financeList.count < mySelf.pageSize {
                            mySelf.tableView.mj_footer.endRefreshingWithNoMoreData()
                        } else {
                            mySelf.tableView.mj_footer.resetNoMoreData()
                        }
                    mySelf.currentModelsArr += model.financeList
                    mySelf.tableView.reloadData()
                    
                    mySelf.endRefresh()
                        break
                    case .failure(_):
                        break
                    }
            }.disposed(by: self.disposeBag)
        }else if type == "2" {
             self.tableView.mj_footer.isHidden = false
            appApi.rx.request(.leverBorrowHistory(symbol: (coinMapName as NSString).replacingOccurrences(of: "/", with: "").uppercased(), startTime: nil, endTime: nil, page: String(self.page), pageSize: nil))
                .MJObjectMap(EXCurrentBorrowModel.self)
                .subscribe{[weak self] event in
                    switch event {
                    case .success(let model):
                        guard let mySelf = self else{return}
                        if mySelf.page == 1{
                            mySelf.historyModelsArr.removeAll()
                        }
                        mySelf.tableView.mj_footer.isHidden = false
                        if model.financeList.count < mySelf.pageSize {
                            mySelf.tableView.mj_footer.endRefreshingWithNoMoreData()
                        } else {
                            mySelf.tableView.mj_footer.resetNoMoreData()
                        }
                        mySelf.historyModelsArr += model.financeList
                        mySelf.tableView.reloadData()
                        mySelf.page = mySelf.page + 1
                        mySelf.endRefresh()
                        break
                    case .failure(_):
                        break
                    }
            }.disposed(by: self.disposeBag)
        }else if type == "3" {
            self.tableView.mj_footer.isHidden = false
            appApi.rx.request(.leverTransferRecord(symbol: (coinMapName as NSString).replacingOccurrences(of: "/", with: "").uppercased(),coinSymbol:"", transactionType:"", page: String(page), pageSize: nil))
                       .MJObjectMap(EXLeveTransferModel.self)
                       .subscribe{[weak self] event in
                           switch event {
                           case .success(let model):
                                guard let mySelf = self else{return}
                                  if mySelf.page == 1{
                                      mySelf.transModelsArr.removeAll()
                                  }
                               mySelf.tableView.mj_footer.isHidden = false
                               if model.financeList.count < mySelf.pageSize {
                                   mySelf.tableView.mj_footer.endRefreshingWithNoMoreData()
                               } else {
                                   mySelf.tableView.mj_footer.resetNoMoreData()
                               }
                                  mySelf.transModelsArr += model.financeList
                                  mySelf.tableView.reloadData()
                                  mySelf.page = mySelf.page + 1
                                  mySelf.endRefresh()
    
                               break
                           case .failure(_):
                               break
                           }
                   }.disposed(by: self.disposeBag)
        }
    }
    
    //End refresh
     func endRefresh(){
         self.tableView.mj_footer.endRefreshing()
         self.tableView.mj_header.endRefreshing()
     }
}
extension EXLeverageJournalVc :UITableViewDataSource,UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if type == "1" {
            return currentModelsArr.count
        }else if type == "2" {
            return historyModelsArr.count
        }else if type == "3" {
            return transModelsArr.count
        }
        return 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EXLeverageJournalCell", for: indexPath) as! EXLeverageJournalCell
        if type == "1" {
            let model = currentModelsArr[indexPath.row]
            cell.setCurrentBorrowModel(model: model)
        }else if type == "2" {
            let model = historyModelsArr[indexPath.row]
            cell.setHistoryModel(model: model)
        }else if type == "3" {
            let model = transModelsArr[indexPath.row]
            cell.setTransModel(model: model)
        }
    
        return cell
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

extension EXLeverageJournalVc :EXFilterViewDelegate  {
    
    func getTradTypeModel()-> EXFilterDataModel {
        let folditems = EXFilterItem.getItem(titles: ["leverage_current_borrow".localized(),"leverage_history_borrow".localized(),"transfer_text_record".localized()], valueKeys: ["1","2","3"])//Self defined numbers, distinguishing between three types
        return EXFilterDataModel.getFoldModel(key: "type", title: "common_type".localized(), contents: folditems)
    }
    func didSelectAtIdxPath(idx: IndexPath) {
        let vc = EXLeverageCoinSearchVc.init(nibName: "EXLeverageCoinSearchVc", bundle: nil)
        vc.type = .journal
        vc.backCoinNameBlock = {[weak self] str in
            guard let mySelf = self else {
                return
            }
            if str.contains("/") {
                mySelf.coinMapName = str
            }else {
                mySelf.coinMapName = ""
            }
           mySelf.filterParam["coin"] = mySelf.coinMapName.count > 0 ? mySelf.coinMapName : "leverage_all_coinMap".localized()
           mySelf.filterAction()
        }
       
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func getSelectionModel(key:String,
                        title:String,
                        placeHolder:String) ->EXFilterDataModel {
        coinMapfilterModel = EXFilterDataModel()
        coinMapfilterModel.leftKey = key
        coinMapfilterModel.title = title
        coinMapfilterModel.filterType = .selection
        let item = EXFilterItem()
        item.inputPlaceHolder = placeHolder.localized()
        item.valueKey = key
        coinMapfilterModel.items = [item]
        return coinMapfilterModel
    }

    func filterDataSource() -> [EXFilterDataModel] {
        return [getSelectionModel(key: "coin", title: "leverage_coinMap".localized(), placeHolder: coinMapName.count > 0 ? coinMapName : "leverage_all_coinMap".localized()),self.getTradTypeModel()]
    }

    func filterConfirm(params: [String : String]) {
        transModelsArr.removeAll()
        historyModelsArr.removeAll()
        currentModelsArr.removeAll()
        self.tableView.reloadData()
        type = params["type"] ?? ""
        if (params["coin"] ?? "").contains("/") {
            coinMapName = params["coin"] ?? ""
        }else {
            coinMapName = ""
        }
        self.filterParam = params
        self.page = 1
        self.tableView.mj_header.beginRefreshing()
    }
    func resetBtnAction() {
        self.filter.updateFilterData(0, getSelectionModel(key: "coin", title: "leverage_coinMap".localized(), placeHolder:"leverage_all_coinMap".localized()))
    }
    
}

