//
//  EXSAssetsRecordVC.swift
//  Chainup
//
//  Created by ZYJ on 2023/11/8.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import EXKit
///Fund records
public class EXSAssetsRecordVC: EXSNavCustomVC,EXEmptyDataSetable {
    var marginCoinArray: [String] {
        
        return EXSwapPublicInfo.shared.marginCoinList
    }
    var currentMarginCoin = "" {
        didSet {
            currentContractsModel = EXSwapPublicInfo.shared.getContractsModelWithMarginCoin(marginCoin: currentMarginCoin)
        }
    }
    var menuTitleArray: [[String]]{
        return [
            self.marginCoinArray,
            vm.orderTypeArray.map{$0.introduce}
        ]
    }
    var currentRecordWay : EXSwapTransactionRecordType = .all
    var currentContractsModel : EXContractsModel?
    
    public var isBouns = false
    var queryModel = EXSQueryTransactionRecordList()
    var vm = EXContractAssetRecordVM()
    private var tableViewRowDatas: [EXContractAssetRecordModel] = []
    
    private let headerCellReUseID = "EXAssetRecordCell_describe_ID"
    private let cellReUseID = "EXAssetRecordCell_ID"
    
    
    let menu : YDMenu = {
        let retV = YDMenu(origin: CGPoint(x: 0, y: 0),width: Device_W, menuheight: 35)
        /// 横线 English: /Horizontal line
        let horLineView = UIView()
        horLineView.ext_UseAutoLayout()
        horLineView.backgroundColor = .Ex.fill4
        retV.addSubview(horLineView)
        horLineView.snp.makeConstraints { (make) in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(0.5)
        }
        return retV
    }()

    
    lazy var footer :EXRefreshFooterView? =  {
        let footer = EXRefreshFooterView(refreshingBlock: {
            [weak self] in
            guard let mySelf = self else { return }
            mySelf.requestAssetsRecordData(way: mySelf.currentRecordWay, coinCode: mySelf.currentMarginCoin)
        })
//        footer.setup()

        return footer
    }()
    lazy var contentTableView: UITableView = {
        let tableView = UITableView(frame: CGRect.zero, style: .plain)
        tableView.ext_SetTableView(self, self)
        tableView.ext_RegistCell([EXContractAssetRecordHeaderCell.classForCoder(),EXContractAssetRecordCell.classForCoder()], [headerCellReUseID,cellReUseID])
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        tableView.mj_header = EXRefreshHeaderView(refreshingBlock: {
            [weak self] in
            guard let mySelf = self else { return }
            mySelf.queryModel.page = 1
            mySelf.requestAssetsRecordData(way: mySelf.currentRecordWay, coinCode: mySelf.currentMarginCoin)
        })
        
        tableView.mj_footer = self.footer
        if #available(iOS 11, *) {
            tableView.estimatedRowHeight = 0
        }
        return tableView
    }()

    public override func viewDidLoad() {
        super.viewDidLoad()
        setSubView()
        configData()
        self.exEmptyDataSet(self.contentTableView)
        
    }

    public override func setNavCustomV() {

        self.setTitle("cp_extra_text143".ex_localized())
        self.lastVC = true
        self.xscrollView = self.contentTableView
    }
    
    private func setSubView() {
        menu.delegate = self
        menu.dataSource  = self
        self.contentView.backgroundColor = UIColor.ThemeView.card1
        self.contentView.addSubview(menu)
        self.contentView.addSubview(contentTableView)
        self.menu.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
            make.height.equalTo(35)
        }
        self.contentTableView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(self.menu.snp.bottom).offset(10)
        }
    }
    private func configData(){
        if self.currentMarginCoin.isEmpty {
            if self.marginCoinArray.contains("USDT") {
                self.currentMarginCoin = "USDT"
                let index = self.marginCoinArray.firstIndex(of:"USDT")
                guard let newIndex = index else {
                    return
                }
                //标题 English: title
                let menuIndex = YDMenu.Index(column: 0, row: newIndex)
                self.menu.selectedAtIndex(menuIndex)
            }else {
                self.currentMarginCoin = self.marginCoinArray.first ?? ""
                //为空需要请求 English: Empty request required
                self.requestAssetsRecordData(way: self.currentRecordWay, coinCode: self.currentMarginCoin)
            }
        }else{ //默认选中 English: Default selection
            let index = self.marginCoinArray.firstIndex(of: self.currentMarginCoin)
            guard let newIndex = index else {
                return
            }
            //标题 English: title
            let menuIndex = YDMenu.Index(column: 0, row: newIndex)
            self.menu.selectedAtIndex(menuIndex)
        }
    }

}

// MARK: - Update Data

extension EXSAssetsRecordVC {
    /// 获取资金记录 English: /Obtain funding records
    private func requestAssetsRecordData(way: EXSwapTransactionRecordType, coinCode: String) {
        let sym = EXSwapPublicInfo.shared.maiginOrignPair[coinCode] ?? coinCode
        queryModel.type = way.rawValue
        queryModel.symbol =  sym
        EXContractNetwork.getTransactionRecordList(model: queryModel) { (recordList) in
            
            if self.queryModel.page == 1 {
                
                self.tableViewRowDatas = recordList
            }else {
                self.tableViewRowDatas += recordList
            }
            self.queryModel.page += 1
            if recordList.count < self.queryModel.limit {
                self.contentTableView.mj_footer.endRefreshingWithNoMoreData()
            }
            self.contentTableView.reloadData()
            
            self.endRefresh()
        } failure: { (error) in
            if self.queryModel.page == 1 {
                self.tableViewRowDatas.removeAll()
                self.contentTableView.reloadData()
            }
            self.endRefresh()
        }
    }
    
    private func endRefresh() {
        self.contentTableView.mj_header?.endRefreshing()
        self.contentTableView.mj_footer?.endRefreshing()
    }
}


// MARK: - UITableViewDelegate & UITableViewDataSource

extension EXSAssetsRecordVC : UITableViewDelegate, UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if self.tableViewRowDatas.count > 0 {
            
            return self.tableViewRowDatas.count + 1
        }
        return 0
    }
    //
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: headerCellReUseID, for: indexPath) as! EXContractAssetRecordHeaderCell
            cell.setCell(left: "cp_order_text93".ex_localized(), right: "cp_content_text30".ex_localized() + "（\(currentContractsModel?.marginCoin ?? ""))")
            return cell

        }else {
            let cell = tableView.dequeueReusableCell(withIdentifier: cellReUseID, for: indexPath) as! EXContractAssetRecordCell

            let model = self.tableViewRowDatas[indexPath.row-1]
          
            cell.setCell(leftTop: model.type,
                         leftBottom: model.contractName,
                         rightTop: model.amount.toValuePrecision(withContract:currentContractsModel?.instrument_id ?? 0),
                         rightBottom: model.timeShow)
            return cell
        }
    }

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 30
        }
        return 68.5
    }
}

extension EXSAssetsRecordVC:YDMenuDataSource {
    /// 有多少个column，默认为1列 English: /How many columns are there, default to 1 column
    func numberOfColumnsInMenu(_ menu: YDMenu) -> Int {
        return menuTitleArray.count
    }
    
    ///每个column有多少行 English: /How many lines are there in each column
    func menu(_ menu: YDMenu, numberOfRowsInColumn column: Int) -> Int {
        return menuTitleArray[column].count
    }
    
    ///每个column中每行的title English: /The title of each row in each column
    func menu(_ menu: YDMenu, titleForRowAtIndexPath indexPath: YDMenu.Index) -> String {
        let titels = menuTitleArray[indexPath.column]
        if titels.count > 0 {
            return titels[indexPath.row]
        }
        return ""
    }
    
}
extension EXSAssetsRecordVC:YDMenuDelegate {
    func menu(_ menu: YDMenu, willSelectMenuAtMenu currentMenu: Int) {
        
    }
    func menu(_ menu: YDMenu, didSelectRowAtIndexPath indexPath: YDMenu.Index) {
        //print("indexPath.column = \(indexPath.column) row =\(indexPath.row) item =\(indexPath.item)")
        let data = self.menuTitleArray[indexPath.column][indexPath.row]
        switch indexPath.column {
        case 0:
            self.currentMarginCoin = data
        default:
            self.currentRecordWay = self.vm.orderTypeArray[indexPath.row]
        }
        self.queryModel.page = 1
        self.contentTableView.mj_header.beginRefreshing()
    }
}

