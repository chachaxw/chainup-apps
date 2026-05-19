//
//  EXSTransactionListView.swift
//  Chainup
//
//  Created by ZYJ on 2023/11/8.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import JXSegmentedView
import EXKit
enum EXSwapTransactionType: Int {
    /// 当前委托 English: /Current commission
    case current
    /// 历史委托 English: /Historical commission
    case history
    case detail
    case profitRecord
    
    var disPlayName: String{
        switch self {
        case .current:
            return "cp_order_text2".ex_localized()
        case .history:
            return "cp_order_text72".ex_localized()
        case .detail:
            return ""
        case .profitRecord:
            return "cp_order_text73".ex_localized()
        }
    }
}

enum EXSwapTransactionPriceType: Int {
    /// 限价委托-当前委托 English: /Limit Order - Current Order
    case limit
    /// 计划委托 English: /Plan delegation
    case plan
    case position
    
    var display: String{ //历史委托/筛选时用 English: Used for historical delegation/filtering
        switch self {
        case .limit:
            return "cp_extra_text20".ex_localized() //
        case .plan:
            return "cp_order_text3".ex_localized()
        case .position:
            return ""
        }
    }

}

/// 委托列表 English: /Delegation List
class EXSTransactionListView: UIView {
    /// 委托类型 English: /Entrustment type
    var transactionType = EXSwapTransactionType.current {
        didSet {
            self.contentTableView.reloadData()
        }
    }
    /// 普通委托/计划委托 English: /Regular commission/planned commission
    var transactionPriceType = EXSwapTransactionPriceType.limit
    
    /// 取消单个委托 English: /Cancel individual delegation
    var cancelTransactionCallback: ((EXContractOrderModel, EXSwapTransactionPriceType) -> ())?
    
    var tableViewRowDatas: [EXContractOrderModel] = []
    
    /// 点击历史委托 English: /Click on historical delegation
    var selectHistoryTransactionCallback: ((EXContractOrderModel) -> ())?
    private let currentOrderCellReUseID = "EXSwapCurrentTransactionCell_ID"
    private let limitCellReUseID = "EXSwapLimitTransactionCell_ID"
    private let planCellReUseID = "EXSwapPlanTransactionCell_ID"
    let profitRecordCellReUseID = "EXSwapTransactionCell_ID3"
    var positionArr : [EXSwapPositionModel] = []

    lazy var contentTableView: UITableView = {
        let tableView = UITableView(frame: self.bounds, style: UITableView.Style.plain)
        tableView.ext_UseAutoLayout()
        tableView.ext_SetTableView(self, self)
        tableView.backgroundColor = UIColor.ThemeView.card1
        tableView.ext_RegistCell([EXSwapLimitTransactionCell.classForCoder(), EXSwapPlanTransactionCell.classForCoder()], [limitCellReUseID, planCellReUseID])
        tableView.ext_RegistCell([EXSwapCurrentOrderTableViewCell.classForCoder()], [currentOrderCellReUseID])
        tableView.extRegistCell([EXSwapPositionHistoryCell.classForCoder()], [profitRecordCellReUseID])
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        if #available(iOS 11, *) {
            tableView.estimatedRowHeight = 0
        }
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
    func updateView(modelArray: [EXContractOrderModel]) {
        self.tableViewRowDatas = modelArray
        self.contentTableView.reloadData()
    }
    
    private func showDetailAlert(model: EXContractOrderModel, detailType: EXSwapMarketOrderType) {
        // 强平明细 English: Qiangping Details
        if detailType == .forceReducePosition {
            self.showForceDetailAlert(model: model)
        }else if detailType == .positionMerge {
            self.showMergeDetailAlert(model: model)
        }else if detailType == .ADL {
            self.showADLDetailAlert()
        }
    }
    
    private func showADLDetailAlert() {
        let alert = EXCommonAlert()
        alert.configAlert(title: "cp_order_adl1".ex_localized(),msgCommonPart:  "cp_order_adl2".ex_localized(), msgActionPart:"cp_adl_introduce".ex_localized() ,onlyOneBtnTitle: "cp_extra_text28".ex_localized(), bottomOnlyOneBtn: true) {  type in
            if type == .textAction {
                let url  = EXSTools.getAdlUrl()
                let title = ""
                EXSwapPlatformSDK.shared.goToH5?(url,title,self.yy_viewController,nil)
            }else{
                EXAlert.dismiss()
            }
        }
        EXAlert.showAlert(alertView: alert)
    }
    
    /// 显示强平明细 English: /Display Strong Ping Details
    private func showForceDetailAlert(model: EXContractOrderModel) {
        let alert = EXCommonAlert()
        let content = model.getNewliqPositionMsg()
        alert.configAlert(title: "cp_extra_text80".ex_localized(), message: content,bottomOnlyOneBtn: true) { _ in
            
        }
        EXAlert.showAlert(alertView: alert)
    
    }
    /// 显示合并明细 English: /Show merge details
    private func showMergeDetailAlert(model: EXContractOrderModel) {
        let alert = EXCommonAlert()
        let content = model.getNewliqPositionMsg()
        alert.configAlert(title: "cp_extra_text7".ex_localized(), message: content,bottomOnlyOneBtn: true) { _ in
            
        }
        EXAlert.showAlert(alertView: alert)
    }
}


// MARK: - <UITableViewDelegate & UITableViewDataSource>

extension EXSTransactionListView: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if transactionType == .profitRecord {
            return 155
        }
//        _ = tableViewRowDatas[indexPath.row]
        if transactionType == .current {
            if transactionPriceType == .limit {
                return 158
            }
        }
        //历史委托 English: Historical commission
        let model = tableViewRowDatas[indexPath.row]
        if model.isSpecialType() {
            if model.isLiquidate(){
                return 210 + 26
            }
            return 210 //强平 English: Qiangping
        }else{
            return 210 - 27 //减去 强平 English: Subtract Strong Ping
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if transactionType == .profitRecord {
            return positionArr.count
        }
        return tableViewRowDatas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if self.transactionPriceType == .limit { //普通委托 English: Ordinary entrustment
            
            if self.transactionType == .current {// --当前委托 English: --Current commission
                let cell = tableView.dequeueReusableCell(withIdentifier: currentOrderCellReUseID, for: indexPath) as! EXSwapCurrentOrderTableViewCell
                cell.transactionType = self.transactionType
                let model = tableViewRowDatas[indexPath.row]
                cell.updateCell(model: model)
               
                cell.cancelOrderCallback = { [weak self] orderModel in // 取消普通委托 English: Cancel ordinary commission
                    guard let mySelf = self else {return}
                    mySelf.cancelTransactionCallback?(orderModel, mySelf.transactionPriceType)
                }
                cell.showDetailCallback = { [weak self] orderModel, detailType in
                    self?.showDetailAlert(model: orderModel, detailType: detailType)
                }
                return cell
            }
            // --历史委托 English: --Historical commission
            let cell = tableView.dequeueReusableCell(withIdentifier: limitCellReUseID, for: indexPath) as! EXSwapLimitTransactionCell
            cell.transactionType = self.transactionType
            let model = tableViewRowDatas[indexPath.row]
            cell.updateCell(model: model)
            cell.showDetailCallback = { [weak self] orderModel, detailType in
                self?.showDetailAlert(model: orderModel, detailType: detailType)
            }
            return cell
        } else if transactionPriceType == .position { //盈亏记录cell English: Profit and loss record cell
            let cell = tableView.dequeueReusableCell(withIdentifier: profitRecordCellReUseID, for: indexPath) as! EXSwapPositionHistoryCell
            let positionModel = positionArr[indexPath.row]
            cell.type = self.transactionType
            cell.updateCell(model:positionModel)
            return cell
        } else { // 计划委托 English: Plan delegation
            let cell = tableView.dequeueReusableCell(withIdentifier: planCellReUseID, for: indexPath) as! EXSwapPlanTransactionCell
            cell.transactionType = self.transactionType
            let model = tableViewRowDatas[indexPath.row]
            cell.updateCell(model: model)
            cell.cancelOrderCallback = { [weak self] orderModel in // 取消计划委托 English: Cancel Plan Delegation
                guard let mySelf = self else {return}
                mySelf.cancelTransactionCallback?(orderModel, mySelf.transactionPriceType)
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 只有历史限价委托才能查看详情 English: Only historical price limit commissions can view details
        if self.transactionType == .history && self.transactionPriceType == .limit {
            self.selectHistoryTransactionCallback?(self.tableViewRowDatas[indexPath.row])
        }
    }
}
extension EXSTransactionListView: JXSegmentedListContainerViewListDelegate {
    func listView() -> UIView {
        return self
    }
}

