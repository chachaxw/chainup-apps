//
//  EXOTCHistoryListVc.swift
//  Chainup
//
//  Created by liuxuan on 2023/4/3.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit

class EXOTCHistoryListVc: BaseVC,StoryBoardLoadable,NavigationPlugin,EXEmptyDataSetable {
    
    @IBOutlet var historyTable: UITableView!
    @IBOutlet var topConstaraint: NSLayoutConstraint!
    @IBOutlet weak var lineView: UIView!
    var page:Int = 1
    var historyModel:EXOTCHistoryModel = EXOTCHistoryModel()
    let filter = EXFilterView()
    var filterParam = [String:String]()

    
    internal lazy var navigation : EXNavigation = {
        let nav =  EXNavigation.init(affectScroll: historyTable, presenter: self)
        return nav
    }()

    func configNavi() {
        self.navigation.configRightItems(["public_filter"])
        self.navigation.setdefaultType(type: .list)
        self.navigation.setTitle(title: "otc_text_myOrder".localized())
        self.navigation.rightItemCallback = {[weak self] tag in
            self?.filterAction()
        }
        self.navigation.backgroundColor = UIColor.Ex.fill2
    }
    
    func filterAction() {
        if filter.isShow {
            return
        }
        filter.delegate = self
        filter.filterParams = self.filterParam
        filter.show(inView: self.view)
    }
    
    func configRefresh(){
        self.historyTable.mj_header = EXRefreshHeaderView (refreshingBlock: {[weak self] in
            guard let mySelf = self else{return}
            mySelf.page = 1
            mySelf.requestHistoryList(at: mySelf.page)
        })
        
        self.historyTable.mj_footer = EXRefreshFooterView (refreshingBlock: {[weak self] in
            guard let mySelf = self else{return}
            mySelf.page += 1
            mySelf.requestHistoryList(at: mySelf.page)
        })
    }
    
    func configCells(){
        //ios10
        self.automaticallyAdjustsScrollViewInsets = false
        self.historyTable.register(UINib.init(nibName: "EXOTCHistoryListCell", bundle: nil), forCellReuseIdentifier: "EXOTCHistoryListCell")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.historyTable.adjustBehaviorDisable()
        self.configNavi()
        self.configRefresh()
        self.configCells()
        self.historyTable.mj_header.beginRefreshing()
        self.navigation.bindFilter(filter: filter)
        self.exEmptyDataSet(self.historyTable, attributeBlock: { () -> ([EXEmptyDataSetAttributeKeyType : Any]) in
            return [
                .verticalOffset:0,
                ]
        })
    }
    
    func requestHistoryList(at page:Int) {
        var symbol = self.filterParam["coinSymbol"] ?? ""
        let status = self.filterParam["status"]
        let tradeType = self.filterParam["tradeType"]
        let currency = self.filterParam["payCoin"]
        let begin = self.filterParam["startTime"]
        let end = self.filterParam["endTime"]
        let entity = EXAppMarketManager.sharedInstance.getCoinEntityWithAliasName(symbol)
        if entity.name != "" {
            symbol = entity.name
        }

        appApi.hideAutoLoading()
        
        appApi
            .rx
            .request(.otcOrderHistory(page: ("\(page)"),
                                      type: tradeType,
                                      symbol: symbol,
                                      currency: currency,
                                      status: status,
                                      begin:begin,
                                      end:end,
                                      pageSize: "20"))
            .MJObjectMap(EXOTCHistoryModel.self)
            .subscribe{[weak self] event in
                guard let myself = self else {return}
                switch event {
                case .success(let model):
                    myself.handleHistory(with: model)
                    break
                case .failure(let error):
                    self?.resetLoading()
                    break
                }
            }.disposed(by: self.disposeBag)
    }
    
    func resetLoading(){
        self.historyTable.mj_header.endRefreshing()
        self.historyTable.mj_footer.endRefreshing()
    }
    
    func handleHistory(with model:EXOTCHistoryModel) {
        self.historyTable.mj_header.endRefreshing()
        if self.page == 1 {
            self.historyModel = model
        }else {
            if model.orderList.count > 0 {
                self.historyModel.orderList = self.historyModel.orderList + model.orderList
            }
        }
        
        if model.orderList.count < 20 {
            self.historyTable.mj_footer.endRefreshingWithNoMoreData()
        }else {
            self.historyTable.mj_footer.endRefreshing()
        }
        self.historyTable.reloadData()
    }
    
    func largeTitleValueChanged(height: CGFloat) {
        topConstaraint.constant = height
    }
}

extension EXOTCHistoryListVc:UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        orderDetail(indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func orderDetail(_ idxPath:IndexPath) {
        let item = self.historyModel.orderList[idxPath.row]
        let detail = EXOTCOrderDetailVC.instanceFromStoryboard(name: StoryBoardNameOTC)
        detail.isFromOrderList = true
        detail.sequenceId = item.sequence
        detail.tradeType = (item.side == OTCTradeSideKey.otcBuy.rawValue) ? .otcbuy : .otcsell
        detail.rx_orderStatus.asObservable()
        .skip(2)
        .distinctUntilChanged()
        .subscribe(onNext:{[weak self] _ in
            self?.historyTable.mj_header.beginRefreshing()
        }).disposed(by: self.disposeBag)
        
        self.navigationController?.pushViewController(detail, animated: true)
    }

}

extension EXOTCHistoryListVc:UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return historyModel.orderList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = self.historyModel.orderList[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "EXOTCHistoryListCell", for: indexPath) as! EXOTCHistoryListCell
        cell.bindItem(historyListItem: item)
        return cell
    }
}

extension EXOTCHistoryListVc :EXFilterViewDelegate  {
    
    func getTradTypeModel()-> EXFilterDataModel {
        let folditems = EXFilterItem.getItem(titles: ["common_action_sendall".localized(),"otc_action_buy".localized(),"otc_action_sell".localized()], valueKeys: ["ALL","buy","sell"])
        return EXFilterDataModel.getFoldModel(key: "tradeType", title: "common_type".localized(), contents: folditems)
    }

    func getStatusModel()-> EXFilterDataModel {
        //All, Pending Payment, Paid, Coining, Transaction Completed, Cancelled, Appeal Pending, Appeal Processing Completed, Appeal Cancelled
        let titles = ["common_action_sendall".localized(),
                      "filter_otc_waitPay".localized(),
                      "filter_otc_didPay".localized(),
                      "filter_otc_complete".localized(),
                      "filter_otc_cancel".localized(),
                      "filter_otc_appeal".localized(),
                      "filter_otc_appealDone".localized(),
                      "filter_otc_appealCancel".localized()]
        
        let folditems = EXFilterItem.getItem(titles:titles,
                                             valueKeys: [
                                                OTCOrderStatusKey.All.rawValue,
                                                EXOTCOrderDetailStatus.orderPay.rawValue,
                                                EXOTCOrderDetailStatus.orderDidPay.rawValue,
                                                EXOTCOrderDetailStatus.orderComplete.rawValue,
                                                EXOTCOrderDetailStatus.orderCanceled.rawValue,
                                                EXOTCOrderDetailStatus.orderComplain.rawValue,
                                                EXOTCOrderDetailStatus.orderComplainDone.rawValue,
                                                EXOTCOrderDetailStatus.orderAppealCancel.rawValue])
        
        return EXFilterDataModel.getFoldModel(key: "status", title: "filter_fold_orderState".localized(), contents: folditems)

    }
    
    func filterDataSource() -> [EXFilterDataModel] {
        let tradeTypeModel = self.getTradTypeModel()
        let statusModel = self.getStatusModel()
        let coinUnitModel = EXFilterDataModel.getMixModel(title: "filter_fold_tradeUnit".localized(),
                                                          leftKey: "coinSymbol",
                                                          rightKey: "payCoin",
                                                          leftplaceHolder: "filter_input_coinsymbol".localized(),
                                                          rightItems: OTCPulbicManager.sharedInstance.otcPayCoinItems())
        
        let dateModel = EXFilterDataModel.getDateModel(beginDateKey: "startTime",
                                                       endDateKey: "endTime",
                                                       title: "charge_text_date".localized())
        return [tradeTypeModel,coinUnitModel,statusModel,dateModel]
    }
    
    func filterConfirm(params: [String : String]) {
        self.page = 1
        self.filterParam = params
        self.historyTable.mj_header .beginRefreshing()
    }
}

