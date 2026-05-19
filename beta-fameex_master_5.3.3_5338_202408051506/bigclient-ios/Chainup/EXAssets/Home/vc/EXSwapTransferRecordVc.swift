//
//  EXSwapTransferRecordVc.swift
//  Chainup
//
//  Created by KarlLichterVonRandoll on 2023/1/8.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit 
import Swap
class EXSwapTransferRecordVc: NavCustomVC,EXEmptyDataSetable,NavigationPlugin {
    private let swapTransferCellID = "EXLeverageTransferRecordCell"
    var page = 1
    var symbol = ""//Coin pairs passed over
    
    var transactionType = "0" //1. Transfer in contract, 2. Transfer out contract
    var modelsArr = [SLSwapTransferListModel]()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect.zero, style: .plain)
        tableView.extSetTableView(self, self)
        return tableView
    }()
    let filter = EXFilterView()
    var filterParam = [String:String]()
    internal lazy var navigation : EXNavigation = {
        let nav =  EXNavigation.init(affectScroll: self.tableView, presenter: self)
        nav.isLastNavigationStyle = true
        return nav
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 11.0, *) {
            self.tableView.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        initLayout()
        handNavigationBar()
        bindCell()
        self.exEmptyDataSet(self.tableView, attributeBlock: { () -> ([EXEmptyDataSetAttributeKeyType : Any]) in
            return [
                .verticalOffset:(CGFloat(-110)),
            ]
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.filter.dismissFilter()
    }
    
    override func setNavCustomV() {
        self.xscrollView = self.tableView
    }
    
    func handNavigationBar() {
        self.navigation.setTitle(title:symbol + " " + "transfer_text_record".localized())
        self.navigation.setdefaultType(type: .list)
        navigation.configRightItems(["public_filter"])
        navigation.rightItemCallback = {[weak self] tag in
            self?.filterAction()
        }
    }
    private func initLayout() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(self.navCustomView.snp.bottom)
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
    func bindCell()  {
        self.tableView.backgroundColor = UIColor.ThemeView.bg
        tableView.register(UINib.init(nibName: "EXLeverageTransferRecordCell", bundle: nil), forCellReuseIdentifier: "EXLeverageTransferRecordCell")
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        tableView.rowHeight = UITableView.automaticDimension;
        tableView.estimatedRowHeight = 200
        let view = UIView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height: 0.001))
        tableView.tableHeaderView = view
        self.tableView.mj_header = EXRefreshHeaderView (refreshingBlock: {[weak self] in
            guard let mySelf = self else{return}
            mySelf.page = 1
            mySelf.loadData()
        })
        self.tableView.mj_footer = EXRefreshFooterView (refreshingBlock: {[weak self] in
            guard let mySelf = self else{return}
            mySelf.loadData()
        })
        loadData()
    }
}

extension EXSwapTransferRecordVc {
    
//    func
    
    fileprivate func updateList(model:SLSwapTransferModel) {
        if page == 1{
            modelsArr.removeAll()
        }
        var arrM : [SLSwapTransferListModel] = []
        for item in model.financeList {
            
            if EXAppConfigManager.sharedInstance.getContractVersion() == .new {
                
                item.setStatusText()
                item.setCreatAtTime()
            }
            
            if transactionType == "0" {
                arrM.append(item)
            } else {
                if item.status == transactionType {
                    arrM.append(item)
                }
            }
        }
        if arrM.count < 20 {
            self.tableView.mj_footer.endRefreshingWithNoMoreData()
        } else {
            self.tableView.mj_footer.resetNoMoreData()
        }
        modelsArr += arrM
        tableView.reloadData()
        page = page + 1
        endRefresh()
    }
    
    func loadData() {
        let start = self.filterParam["startTime"]
        let end = self.filterParam["endTime"]
      
        if EXAppConfigManager.sharedInstance.getContractVersion() == .new {
            EXContractNetwork.queryUserHasOpenAccount { (hasOpen) in

                if !hasOpen {
                    EXAlert.showFail(msg: "contract_user_hasnotOpen".localized())

                    self.endRefresh()
                    return
                }
                newContractApi.rx.request(.transferList(coinSymbol: self.symbol, transactionScene: "contract_transfer", startTime: start, endTime: end, page: String(self.page))).MJObjectMap(SLSwapTransferModel.self)
                    .subscribe{[weak self] event in
                        switch event {
                        case .success(let model):
                            guard let mySelf = self else{return}
                            mySelf.updateList(model: model)
                            break
                        case .failure(_):
                            break
                        }
                    }.disposed(by: self.exs_disposeBag)
            }
        }else {
            appApi.rx.request(.transferList(coinSymbol: self.symbol, transactionScene: "contract_transfer", startTime: start, endTime: end, page: String(page))).MJObjectMap(SLSwapTransferModel.self)
                .subscribe{[weak self] event in
                    switch event {
                    case .success(let model):
                         guard let mySelf = self else{return}
                        mySelf.updateList(model: model)
                        break
                    case .failure(_):
                        break
                    }
            }.disposed(by: self.exs_disposeBag)
        }
    }
    //End refresh
    func endRefresh(){
        self.tableView.mj_footer?.endRefreshing()
        self.tableView.mj_header?.endRefreshing()
    }
}

extension EXSwapTransferRecordVc:UITableViewDataSource,UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return modelsArr.count
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let element = modelsArr[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "EXLeverageTransferRecordCell", for: indexPath) as! EXLeverageTransferRecordCell
        cell.setSwapModel(model: element)
        return cell
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if modelsArr.count > 0 {
            let header = EXLeverageTransferRecordSectionHeader.loadFromNib()
            header.leftILab.text = "charge_text_date".localized()
            header.middleLab.text = "newCharge_text_volume".localized()
            header.rightLab.text = "common_type".localized()
            return header
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if modelsArr.count > 0 {
            return 12
        }
        return .leastNonzeroMagnitude
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

extension EXSwapTransferRecordVc :EXFilterViewDelegate  {
    func getTradTypeModel()-> EXFilterDataModel {
        let folditems = EXFilterItem.getItem(titles: ["common_action_sendall".localized(),"contract_bb_transfer_to_contract".localized(),"sl_str_contract_to_coin".localized()], valueKeys: ["0","1","2"])
        return EXFilterDataModel.getFoldModel(key: "tradeType", title: "common_type".localized(), contents: folditems)
    }
    func filterDataSource() -> [EXFilterDataModel] {
         let dateModel = EXFilterDataModel.getDateModel(beginDateKey: "startTime", endDateKey: "endTime", title: "charge_text_date".localized())
        return [self.getTradTypeModel(),dateModel]
    }
    
    func filterConfirm(params: [String : String]) {
        self.page = 1
        self.filterParam = params
        transactionType = params["tradeType"] ?? ""
        self.tableView.mj_header.beginRefreshing()
    }
}


