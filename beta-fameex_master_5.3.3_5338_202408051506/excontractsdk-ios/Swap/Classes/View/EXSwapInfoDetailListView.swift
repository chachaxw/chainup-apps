//
//  EXSwapInfoDetailListView.swift
//  Chainup
//
//  Created by ZYJ on 2023/6/16.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import EXKit
enum EXContractInfoDetailTab:Int {
    case insurance = 0
    case fundsrate //资金费率 English: Fund rate
}

class EXContractInfoDetailCellModel {
    var left = ""
    var middle = ""
    var right = ""
    
   
}

class EXSwapInfoDetailListView: UIView {
    
    private let historyReUseID = " EXContractInfoDetailHistoryReUseID"
    private let profitAndLossReUseID = " EXContractInfoDetailProfitAndLossReUseID"
    var tableViewRowDatas: [EXContractInfoDetailCellModel] = []
    var historyDatas = [EXContractInfoDetailCellModel]()
//    var profitAndLossDatas = [EXContractInfoDetailCellModel]()
    
    var currentTabType = EXContractInfoDetailTab.insurance
    
    private var isFirst: Bool = true
    lazy var headerView: UIView = {
        let view = UIView.init(frame: CGRect.init(x: 0, y: 0, width: Device_W, height: 471))
        return view
    }()
    lazy var contentTableView: UITableView = {
        let tableView = UITableView(frame: self.bounds, style: UITableView.Style.plain)
        tableView.extUseAutoLayout()
        tableView.extSetTableView(self, self)
        tableView.backgroundColor = UIColor.ThemeView.bg
        tableView.extRegistCell([EXhorizontalTwoLabelTableViewCell.classForCoder(), EXCOhorizontalThreeLabelTableViewCell.classForCoder(),EXSTransactionEmptyTC.classForCoder()], [historyReUseID, profitAndLossReUseID,"EXTransactionEmptyTC"])
        if #available(iOS 11, *) {
            tableView.estimatedRowHeight = 0
        }
        tableView.separatorStyle = .none
        
        return tableView
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(contentTableView)
        self.contentTableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Data
    func updateDatas(page:Int,limit:Int,historyArray: [EXContractInfoDetailCellModel]) {
        self.isFirst = false
        updateFundRateRefresh(page: page, limit: limit, historyArray: historyArray)
        reloadData()
        endRefresh()
    }
    func updateFooterViewState() {
        if self.contentTableView.mj_footer != nil {
            if currentTabType == .insurance {
                
                
                if self.historyDatas.count < 20 {
                    self.contentTableView.mj_footer.endRefreshingWithNoMoreData()
                }else {
                    self.contentTableView.mj_footer.resetNoMoreData()
                }
            }
          
        }
    }
    func updateFundRateRefresh(page:Int,limit:Int,historyArray: [EXContractInfoDetailCellModel]) {
        
        if page > 1 {
            if currentTabType == .insurance {
                
                self.historyDatas += historyArray
            }
        }else {
            if historyArray.count > 0 {
                
                self.historyDatas = historyArray
            }else {
                self.historyDatas = []
            }
        }
     
        updateFooterViewState()
    }
    
    private func endRefresh() {
    
        if contentTableView.mj_header != nil {
            
            contentTableView.mj_header.endRefreshing()
        }
    }
    
    private func selectData() {
        self.tableViewRowDatas = self.historyDatas
    }
    
    private func reloadData() {
        selectData()
        self.contentTableView.reloadData()
    }
}
extension EXSwapInfoDetailListView: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
       
        let headerCell = EXCOhorizontalThreeLabelView(user: .header)
        headerCell.isHidden = self.isFirst
        if self.currentTabType == .insurance {
            headerCell.secondLabel.isHidden = true
            headerCell.secondLabel.snp.remakeConstraints { (make) in
                make.top.bottom.equalToSuperview()
                make.leading.equalTo(headerCell.firstLabel.snp_trailing)
                make.trailing.equalTo(headerCell.thirdLabel.snp_leading)
                make.width.equalTo(1)
            }
            headerCell.setData(left: "cp_contract_data_text6".ex_localized(),
                           middle: "",
                           right: "cp_contract_info_text4".ex_localized())
        }else {

            headerCell.setData(left: "cp_contract_data_text6".ex_localized(),
                           middle: "",
                           right: "cp_overview_text26".ex_localized())
        }
        let headerView = UIView()
        headerView.backgroundColor = UIColor.ThemeView.bg

        let label = UILabel()
        label.font = UIFont.ThemeFont.H3Medium
        label.textColor = UIColor.ThemeLabel.colorLite
        label.text = "cp_contract_data_text5".ex_localized()
        label.isHidden = self.isFirst
        headerView.addSubview(label)
        label.snp.makeConstraints { make in
            make.leading.equalTo(16)
            make.centerY.equalToSuperview()
        }
        headerView.addSubview(headerCell)
        headerCell.snp.makeConstraints { (make) in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(label.snp.bottom).offset(12)
        }
        
     
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 76
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableViewRowDatas.count == 0 {
            return 160
        }
        return 44
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableViewRowDatas.count == 0 {
            return 1
        }
        return tableViewRowDatas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableViewRowDatas.count == 0 {
            let cell: EXSTransactionEmptyTC = tableView.dequeueReusableCell(withIdentifier: "EXTransactionEmptyTC") as! EXSTransactionEmptyTC
            return cell
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: historyReUseID, for: indexPath) as! EXhorizontalTwoLabelTableViewCell
        let model = tableViewRowDatas[indexPath.row]
        let detailValue = self.currentTabType == .fundsrate ? (model.right + "%") : model.right
        cell.setCell(left: model.left, middle: "", right: detailValue)
        cell.mainView.thirdLabel.textColor = UIColor.extColorWithHex("#00B595")
        cell.horLineView.isHidden = true
        return cell
    }
    
}
class EXhorizontalTwoLabelTableViewCell:UITableViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    lazy var mainView:EXCOhorizontalThreeLabelView = {
        
        let v = EXCOhorizontalThreeLabelView(user: .cell)
        v.secondLabel.isHidden = true
        v.secondLabel.snp.remakeConstraints { (make) in
            make.top.bottom.equalToSuperview()
            make.leading.equalTo(v.firstLabel.snp_trailing)
            make.trailing.equalTo(v.thirdLabel.snp_leading)
            make.width.equalTo(1)
        }
        
        return v
    }()
    /// 横线 English: /Horizontal line
    lazy var horLineView: UIView = {
        let view = UIView()
        view.extUseAutoLayout()
        view.backgroundColor = UIColor.ThemeView.seperator
        return view
    }()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubViews([mainView,horLineView])
        mainView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        horLineView.snp.makeConstraints { (make) in
            make.height.equalTo(0.5)
            make.left.right.bottom.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setCell(left:String, middle:String, right:String) {
        mainView.setData(left: left, middle: middle, right: right)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}

