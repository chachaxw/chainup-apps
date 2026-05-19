//
//  EXLeverageTransferRecordVc.swift
//  Chainup
//
//  Created by ljw on 2023/11/7.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit 

class EXLeverageTransferRecordVc:  BaseVC,NavigationPlugin,EXEmptyDataSetable {
    var page = 1
    var symbol = ""//Coin pairs passed over
    var coinName = ""//Transfer currency
    
    var transactionType = ""//1. Transfer lever, 2. Transfer lever
    var modelsArr = [EXLeveTransferListModel]()
    
    private let pageSize = 20
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var topCon: NSLayoutConstraint!
    let filter = EXFilterView()
    var filterParam = [String:String]()
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
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
         self.filter.dismissFilter()
    }
    func handNavigationBar() {
        self.navigation.setTitle(title:coinName + "transfer_text_record".localized())
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
    func largeTitleValueChanged(height: CGFloat) {
        topCon.constant = height
    }
    func bindCell()  {
        self.tableView.backgroundColor = UIColor.ThemeView.bg
        tableView.register(UINib.init(nibName: "EXLeverageTransferRecordCell", bundle: nil), forCellReuseIdentifier: "EXLeverageTransferRecordCell")
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        tableView.rowHeight = UITableView.automaticDimension;
        tableView.estimatedRowHeight = 200;
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
extension EXLeverageTransferRecordVc {
    func loadData() {
        appApi.rx.request(.leverTransferRecord(symbol: (self.symbol as NSString).replacingOccurrences(of: "/", with: "").uppercased(),coinSymbol:coinName.uppercased(), transactionType:transactionType, page: String(page), pageSize: String(pageSize)))
            .MJObjectMap(EXLeveTransferModel.self)
            .subscribe{[weak self] event in
                switch event {
                case .success(let model):
                     guard let mySelf = self else{return}
                       if mySelf.page == 1{
                           mySelf.modelsArr.removeAll()
                       }
                       mySelf.modelsArr += model.financeList
                    if model.financeList.count < mySelf.pageSize {
                        mySelf.tableView.mj_footer.endRefreshingWithNoMoreData()
                    } else {
                        mySelf.tableView.mj_footer.resetNoMoreData()
                    }
                       mySelf.tableView.reloadData()
                       mySelf.page = mySelf.page + 1
                       mySelf.endRefresh()
                    break
                case .failure(_):
                    break
                }
        }.disposed(by: self.disposeBag)
    }
    //End refresh
    func endRefresh(){
        self.tableView.mj_footer.endRefreshing()
        self.tableView.mj_header.endRefreshing()
    }
}
extension EXLeverageTransferRecordVc:UITableViewDataSource,UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return modelsArr.count
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         let element = modelsArr[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "EXLeverageTransferRecordCell", for: indexPath) as! EXLeverageTransferRecordCell
        cell.setModel(model: element)
        return cell
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if modelsArr.count == 0 {
            return nil
        }
        let header = EXLeverageTransferRecordSectionHeader.loadFromNib()
        header.leftILab.text = "charge_text_date".localized()
        header.middleLab.text = "charge_text_volume".localized()
        header.rightLab.text = "contract_text_type".localized()
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if modelsArr.count == 0 {
            return CGFLOAT_MIN
        }
        return 12
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
     
    }
}
 extension EXLeverageTransferRecordVc :EXFilterViewDelegate  {
    
    func getTradTypeModel()-> EXFilterDataModel {
        let folditems = EXFilterItem.getItem(titles: ["common_action_sendall".localized(),"coin_to_leverage".localized(),"leverage_to_coin".localized()], valueKeys: ["","1","2"])
        
        return EXFilterDataModel.getFoldModel(key: "tradeType", title: "common_type".localized(), contents: folditems)
    }
    func filterDataSource() -> [EXFilterDataModel] {
        return [self.getTradTypeModel()]
    }
    
    func filterConfirm(params: [String : String]) {
        self.page = 1
        self.filterParam = params
        transactionType = params["tradeType"] ?? ""
        self.tableView.mj_header.beginRefreshing()
    }
}

