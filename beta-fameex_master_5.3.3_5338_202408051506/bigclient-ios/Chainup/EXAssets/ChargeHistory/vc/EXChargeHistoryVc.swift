//
//  EXChargeHistoryVc.swift
//  Chainup
//
//  Created by liuxuan on 2023/5/5.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit

//Cash withdrawal records
class EXChargeHistoryVc: BaseVC,NavigationPlugin,StoryBoardLoadable,EXEmptyDataSetable {
    
    @IBOutlet var historyTable: UITableView!
    @IBOutlet var scrollTopConstraint: NSLayoutConstraint!
    var page:Int = 1
    var symbol:String = ""
    let filter = EXFilterView()
    var filterParam = [String:String]()
//    var isTransferList:Bool = false //The default is the recharge record page, which can also be the transfer record page
    var historyScene:EXJournalListSceneKey = .none
    var financeLists:[FinanceItem] = []
    var sectionHeader:EXChargeHistorySectionHeader = EXChargeHistorySectionHeader()
    var journalVm:EXJournalVm = EXJournalVm()
    var sceneModel:EXJournalSceneModel = EXJournalSceneModel()
    
    internal lazy var navigation : EXNavigation = {
        let nav =  EXNavigation.init(affectScroll: self.historyTable, presenter: self)
        return nav
    }()
    
    
    func handleNavigation() {
//        self.navigation.isLastNavigationStyle = true
//        if historyScene == EXJournalListSceneKey.deposit {
//            self.navigation.setTitle(title: "charge_action_chargeHistory".localized())
//        }else if historyScene == EXJournalListSceneKey.otctransfer {
//            navigation.configRightItems(["public_filter"])
//            navigation.rightItemCallback = {[weak self] tag in
//                self?.handleFilter()
//            }
//            self.navigation.setTitle(title: "transfer_text_record".localized())
//        }else if historyScene == EXJournalListSceneKey.withdraw {
//            self.navigation.setTitle(title: "withdraw_action_withdrawHistory".localized())
//        }
        var title = ""
        if historyScene == EXJournalListSceneKey.deposit {
            title = "charge_action_chargeHistory".localized()
        }else if historyScene == EXJournalListSceneKey.otctransfer {
            title = "transfer_text_record".localized()
        }else if historyScene == EXJournalListSceneKey.withdraw {
            title = "withdraw_action_withdrawHistory".localized()
        }else if historyScene == EXJournalListSceneKey.internalTransfer {
            title = "internalTransfer_action_History".localized()
        }
//        self.navigation.setTitle(title: self.symbol + " " + title)
        self.navigation.setTitle(title: title)
        //Hide Filter Criteria
        navigation.configRightItems(["public_filter"])
        navigation.rightItemCallback = {[weak self] tag in
            self?.handleFilter()
        }
    }
    
    func handleFilter() {
        if filter.isShow {
            return
        }
        filter.delegate = self
        filter.filterParams = self.filterParam
        filter.show(inView: self.view)
    }
    
    func largeTitleValueChanged(height: CGFloat) {
        scrollTopConstraint.constant = height
    }
    
    func handleTable(){
        self.historyTable.estimatedRowHeight = 90
        self.historyTable.register(cellType: EXChargeHistoryCell.self)
        configRefresh()
    }
    
    func configRefresh(){
        self.historyTable.mj_header = EXRefreshHeaderView (refreshingBlock: {[weak self] in
            guard let mySelf = self else{return}
            mySelf.page = 1
            mySelf.handlerequest()
        })
        
        self.historyTable.mj_footer = EXRefreshFooterView (refreshingBlock: {[weak self] in
            guard let mySelf = self else{return}
            mySelf.page += 1
            mySelf.handlerequest()
        })
    }
    
    func handlerequest() {
        let start = self.filterParam["startTime"]
        let end = self.filterParam["endTime"]

        appApi.rx.request(.transferList(coinSymbol:self.symbol,
                                        transactionScene:historyScene.rawValue,
                                        startTime: start,
                                        endTime: end,
                                        page: "\(self.page)"))
            .MJObjectMap(EXJournalListModel.self,false)
            .autoShowLoadingOnController(context: self)
            .subscribe{[weak self] event in
                switch event {
                case .success(let listModel):
                    self?.handleJournalList(listModel)
                    break
                case .failure(_):
                    self?.endRefresh()
                    break
                }
            }.disposed(by: self.disposeBag)
    }
    
    func handleJournalList(_ listModel:EXJournalListModel) {
        self.endRefresh()
        if listModel.financeList.count < 20 {
            self.historyTable.mj_footer.endRefreshingWithNoMoreData()
        }
        if self.page == 1 {
            self.financeLists = listModel.financeList
        }else {
            self.financeLists = self.financeLists + listModel.financeList
        }
        self.historyTable.reloadData()
    }
    
    func endRefresh() {
        historyTable.mj_header.endRefreshing()
        historyTable.mj_footer.endRefreshing()
    }
    
    func handleScene(){
        self.journalVm.getExJournalList()
        journalVm.onSceneCallback = {[weak self] model in
            self?.handleScene(model)
        }
    }
    
    func handleScene(_ model:EXJournalSceneModel) {
        self.sceneModel = model
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        handleNavigation()
        handleScene()
        handleTable()
        self.navigation.bindFilter(filter: self.filter)
        self.exEmptyDataSet(self.historyTable, attributeBlock: { () -> ([EXEmptyDataSetAttributeKeyType : Any]) in
            return [
                .verticalOffset:0,
            ]
        })
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.page = 1
        handlerequest()
    }
}

extension EXChargeHistoryVc : UITableViewDelegate {
    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 60
//    }
//
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        sectionHeader.frame = CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height: 27)
//        sectionHeader.updateTitle(left: "charge_text_date".localized(),
//                                  middle: "charge_text_volume".localized(),
//                                  right: "charge_text_state".localized())
//        return sectionHeader
//    }
//
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
}

extension EXChargeHistoryVc : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return financeLists.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = financeLists[indexPath.row]
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: EXChargeHistoryCell.self)
        cell.bindListData(item)
        var title = historyScene.display
        //Transfer prompt Transfer
        if historyScene == EXJournalListSceneKey.otctransfer || historyScene == EXJournalListSceneKey.internalTransfer{
            title = "assets_action_transfer".localized()
        }
        cell.titleLabel.text = title
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    //https://jira.dw2nn.com/browse/CUSTOMER-30051
//        let item = financeLists[indexPath.row]
//        item.transactionScene = self.historyScene.display
////        for (_,sceneItem) in sceneModel.sceneList.enumerated() {
////            if sceneItem.key == self.historyScene.rawValue {
////                item.transactionScene = sceneItem.key_text
////                break
////            }
////        }
//        let detail = EXJournalAccountDetailVc.instanceFromStoryboard(name: StoryBoardNameAsset)
//        detail.financeItem = item
//        detail.sceneKey = self.historyScene.rawValue
////        detail.onCancelSuccessCallback = {[weak self] in
////            self?.reloadJournalList()
////        }
//        self.navigationController?.pushViewController(detail, animated: true)
        
    }
    
}

extension EXChargeHistoryVc :EXFilterViewDelegate  {
    
    func getTradTypeModel()-> EXFilterDataModel {
        let folditems = EXFilterItem.getItem(titles: ["common_action_sendall".localized(),"otc_action_buy".localized(),"otc_action_sell".localized()], valueKeys: ["ALL","buy","sell"])
        return EXFilterDataModel.getFoldModel(key: "tradeType", title: "common_type".localized(), contents: folditems)
    }
    
    func getStatusModel()-> EXFilterDataModel {
        //All, to be paid, to be released, in appeal, to be received, to be received, completed, cancelled
        let titles = ["common_action_sendall".localized(),
                      "otc_text_orderWaitPay".localized(),
                      "otc_text_orderWaitSendCoin".localized(),
                      "otc_text_orderAppeal".localized(),
                      "otc_text_orderWaitMoney".localized(),
                      "otc_text_waitReceiveCoin".localized(),
                      "otc_text_orderComplete".localized(),
                      "otc_text_orderCancel".localized()]
        
        let folditems = EXFilterItem.getItem(titles:titles,
                                             valueKeys: [
                                                OTCOrderStatusKey.All.rawValue,
                                                OTCOrderStatusKey.Pending.rawValue,
                                                OTCOrderStatusKey.PayCoin.rawValue,
                                                OTCOrderStatusKey.Appeal.rawValue,
                                                OTCOrderStatusKey.DidPay.rawValue,
                                                OTCOrderStatusKey.Complete.rawValue,
                                                OTCOrderStatusKey.Cancel.rawValue])
        
        return EXFilterDataModel.getFoldModel(key: "status", title: "filter_fold_orderState".localized(), contents: folditems)
        
    }
    
    func filterDataSource() -> [EXFilterDataModel] {
        let dateModel = EXFilterDataModel.getDateModel(beginDateKey: "startTime", endDateKey: "endTime", title: "charge_text_date".localized())
        return [dateModel]
    }
    
    func filterConfirm(params: [String : String]) {
        self.page = 1
        self.filterParam = params
        self.historyTable.mj_header.beginRefreshing()
    }
}

