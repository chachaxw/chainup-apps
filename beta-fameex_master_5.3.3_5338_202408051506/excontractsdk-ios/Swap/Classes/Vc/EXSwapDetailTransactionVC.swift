//
//  EXSwapDetailTransactionVC.swift
//  Chainup
//
//  Created by KarlLichterVonRandoll on 2023/12/23.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit
/// 历史委托分区 English: /Historical commission partition
enum EXHistoryDetailSectionType {
    case tip
    case orderDetail
    case profirtAndLoss //止盈止损 English: Stop profit and stop loss
    case feelist //手续费列表 English: Fee List
}
//MARK: 历史委托详情 English: MARK: Historical commission details
class EXSwapDetailTransactionVC : EXSNavCustomVC {
    var itemMdoel: EXSwapItemModel?
    var orderModel: EXContractOrderModel?
    var tableViewRowDatas: [EXContractTradeDetailItem] = []
    let cellReUseID = "EXDetailTransactionCell_ID1"
    let cellHeaderReUseID = "EXDetailTransactionHeaderCell_ID1"
    let stopPLReUseID = "EXSwapStopPLDetailCell"
    let detailCellReUseID = "EXDetailTransactionCell_ID2"
    let sectionHeaderId = "EXSHistorySectionHeaderView"
    let sectionRoundId = "EXSHistorySectionRounderView"
    let emptyTCId = "EXSTransactionEmptyTC"
    var feeValue = ""
    var sections = [EXHistoryDetailSectionType]()
    var protiftAndLossData = [EXSwapHorThreeCellModel]()
    
    override func setNavCustomV() {
        self.setTitle("cp_order_text85".ex_localized())
        self.lastVC = true
        self.navtype = .listtitle
    }
     //MARK: lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initData()
        self.initLayout()
        self.requestHistoryData(instrument_id: orderModel?.instrument_id ?? 0, oid: self.orderModel?.oid ?? 0)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        EXNewTracking.shared.trackPage(name: .swapcommissiondetails, isEnter:true)
    }
    
    
    func initData(){
        if shouldShowMemoDesc(), let memoDisplay = self.orderModel?.memoDisplay {
            sections.append(.tip)
        }
        sections.append(.orderDetail)
        if shouldShowStopPL(){
            sections.append(.profirtAndLoss)
        }
        sections.append(.feelist)
        protiftAndLossData = getStopCellModels()
    }
  
    //MARK: lazy
    lazy var contentTableView: UITableView = {
        let tableView = UITableView(frame: CGRect.zero, style: .grouped)
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tableView.ext_SetTableView(self, self)
        tableView.register(cellType: EXSHistoryDetailWarningViewCell.self)
        tableView.ext_RegistCell([EXSHorizontalThreeLabelTableViewCell.classForCoder()], [cellReUseID])
        tableView.ext_RegistCell([EXSwapTransactionDetailHeaderCell.classForCoder()], [cellHeaderReUseID])
        tableView.ext_RegistCell([EXSwapStopPLDetailCell.classForCoder()], [stopPLReUseID])
        tableView.ext_RegistCell([EXSwapLimitOrderDetailCell.classForCoder()], [detailCellReUseID])
        tableView.ext_RegistCell([EXSTransactionEmptyTC.classForCoder()], [emptyTCId])
        tableView.register(EXSHistorySectionHeaderView.self, forHeaderFooterViewReuseIdentifier: sectionHeaderId)
        tableView.register(EXSHistorySectionRounderView.self, forHeaderFooterViewReuseIdentifier: sectionRoundId)
        let footer = UIView(frame: CGRect(x: 0, y: 0, width: Device_W, height: 60))
        footer.backgroundColor = UIColor.ThemeView.bg
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableFooterView = footer
        return tableView
    }()
}


// MARK: 请求历史数据 English: MARK: Request historical data
extension EXSwapDetailTransactionVC {
    private func requestHistoryData(instrument_id: Int64, oid: Int64) {
        if EXSwapPlatformSDK.shared.activeAccount == nil || instrument_id == 0 || oid == 0 {
            self.endRefresh()
            return
        }
        
        EXContractNetwork.queryTradeDetailList(contractId: instrument_id, orderId: oid) { (list) in
            
            self.feeValue = list.reduce("0") { fee,item in
                //先加再设置精度 English: Add first and then set the accuracy
                return fee.bigAdd(item.fee).toString(item.feeCoinPrecision)
            }
            if self.feeValue.isEmpty || self.feeValue.isZero() {
                self.feeValue = "0"
            }
            self.orderModel?.feeValue = self.feeValue
            self.tableViewRowDatas = list
            self.contentTableView.reloadData()
            self.endRefresh()
        } failure: { (error) in
            self.orderModel?.feeValue = "0"
            self.contentTableView.reloadData()
            self.endRefresh()

        }
    }
    
    //止盈止损的数据 English: Stop profit and stop loss data
    func getStopCellModels() -> [EXSwapHorThreeCellModel] {
        var ret = [EXSwapHorThreeCellModel]()
        if orderModel?.otoOrder.takerProfitTrigger != "--" {
            let model = EXSwapHorThreeCellModel()
            model.leftTop = "cp_overview_text15".ex_localized()
            model.leftBottom = orderModel?.otoOrder.takerProfitTrigger
            model.middleTop = "cp_order_text36".ex_localized() //止盈委托价 English: Stop profit commission price
            model.middleBottom = orderModel?.otoOrder.takerProfitPriceDesc
            model.rightTop = "cp_order_text87".ex_localized() //"状态" English: "Status"
            model.rightBottom = orderModel?.otoOrder.takerProfitStatusDesc
            model.available = orderModel?.otoOrder.takerProfitStatus ?? false
            ret.append(model)
        }
        if orderModel?.otoOrder.stopLossTrigger != "--" {
            let model = EXSwapHorThreeCellModel()
            model.leftTop = "cp_overview_text16".ex_localized()
            model.leftBottom = orderModel?.otoOrder.stopLossTrigger
            model.middleTop = "cp_order_text37".ex_localized()
            model.middleBottom = orderModel?.otoOrder.stopLossPriceDesc
            model.rightTop = "cp_order_text87".ex_localized()
            model.rightBottom =  orderModel?.otoOrder.stopLossStatusDesc
            model.available = orderModel?.otoOrder.stopLossStatus ?? false
            ret.append(model)
        }
        
        return ret
    }
    
    func shouldShowStopPL() -> Bool {
        if let om = orderModel,!om.shouldHiddenOtoOrderDetailView {
            return true
        }
        return false
    }
    private func endRefresh(){
        self.contentTableView.mj_header?.endRefreshing()
    }
    func shouldShowMemoDesc() -> Bool {
//        if let memoDisplay = self.orderModel?.memoDisplay,!memoDisplay.isEmpty {
//            return true
//        }
        if self.orderModel?.orderStatus == 4 {
            return true
        }
        return false
    }
    //MARK: UI布局 English: MARK: UI Layout
    private func initLayout() {
//        if shouldShowMemoDesc(), let memoDisplay = self.orderModel?.memoDisplay {
//            let tip = EXSHistoryDetailWarningViewCell(frame: CGRect(x: 0, y: 0, width: Device_W, height: 36))
//            tip.tipLabel.text = memoDisplay
//            self.contentTableView.tableHeaderView = tip
//        }
        if #available(iOS 11.0, *) {
            self.contentTableView.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        
        self.contentView.addSubview(self.contentTableView)
        self.contentTableView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(self.navCustomView.snp.bottom)
            make.bottom.equalToSuperview().offset(-(EX_TABBAR_BOTTOM))
        }
    }
}


// MARK: - UITableViewDelegate & UITableViewDataSource

extension EXSwapDetailTransactionVC : UITableViewDelegate, UITableViewDataSource {
   
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sec = sections[section]
        
        switch sec{
        case .tip:
            return 1
        case .orderDetail:
            return 1
        case .profirtAndLoss:
            return protiftAndLossData.count
        case .feelist:
            return tableViewRowDatas.count + 1 //标题一列 English: Title column
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let sec = sections[indexPath.section]
        if sec == .tip {
            let cell = tableView.dequeueReusableCell(for: indexPath,cellType: EXSHistoryDetailWarningViewCell.self)
            
//            tableView.dequeueReusableCell(for: EXSHistoryDetailWarningViewCell.self)
            cell.tipLabel.text = self.orderModel?.memoDisplay
            return cell
        }else if sec == .orderDetail {
            let cell = tableView.dequeueReusableCell(withIdentifier: detailCellReUseID, for: indexPath) as! EXSwapLimitOrderDetailCell
            cell.orderModel = orderModel
            return cell
        }else if sec == .profirtAndLoss {
            let cell = tableView.dequeueReusableCell(withIdentifier: stopPLReUseID) as! EXSwapStopPLDetailCell
            cell.contentView.backgroundColor = UIColor.ThemeView.newbg
            let model = protiftAndLossData[indexPath.row]
            cell.setData(data: model)
            return cell
        }else {//手续费 English: Handling fees
            if self.tableViewRowDatas.count == 0 { //空的时候需要占位图 English: When empty, it is necessary to occupy a bitmap
                let cell = tableView.dequeueReusableCell(withIdentifier: emptyTCId, for: indexPath)
                return cell
            }
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: cellHeaderReUseID, for: indexPath) as! EXSwapTransactionDetailHeaderCell
                cell.contentView.backgroundColor = UIColor.ThemeView.newbg
                cell.mainView.backgroundColor = UIColor.ThemeView.newbg
                if let info = orderModel?.ex_contractInfo {
                    //成交价-成交数量 手续费 English: Transaction price - transaction quantity handling fee
                    cell.setCell(left: "cp_extra_text31".ex_localized() + "(\(info.quote_coin ))",
                                 middle: "cp_extra_text8".ex_localized() + " (\(info.volumeUnit))",
                                 right: "cp_position_text2".ex_localized() + "(\(info.margin_coin ))")
                }
                cell.selectionStyle = .none
                return cell
            }else {
                let cell = tableView.dequeueReusableCell(withIdentifier: cellReUseID, for: indexPath) as! EXSHorizontalThreeLabelTableViewCell
                cell.contentView.backgroundColor = UIColor.ThemeView.newbg
                cell.mainView.backgroundColor = UIColor.ThemeView.newbg
                cell.selectionStyle = .none
                let item = self.tableViewRowDatas[indexPath.row - 1]
                var vol = item.volume
                if let contract =  EXSwapPublicInfo.shared.getSwapInfo(Int64(item.contractId) ?? 0 ){
                    vol = contract.volumeDisplay(vol: vol)
                }
                var fee = item.fee.toString(item.feeCoinPrecision)
                if item.isAdd {
                    fee = "+" + fee
                }
                cell.setCell(left: item.price.toPricePrecision(withContractID: orderModel?.instrument_id ?? 0),
                             middle: vol,
                             right: fee)
                return cell
            }
        }
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        let sec = sections[section]
        if sec == .tip || sec == .orderDetail{  //第一个区不要区头 English: The first district does not have a header
            return  0.01
        }
        if sec == .feelist { //手续费列表 English: Fee List
            if self.tableViewRowDatas.count > 0 {
                return EXSHistorySectionRounderView.viewHeight
            }
        }else { //止盈止损 English: Stop profit and stop loss
            if self.protiftAndLossData.count > 0 {
                return EXSHistorySectionRounderView.viewHeight
            }
        }
        return 0
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let sec = sections[section]
        
        if sec == .tip || sec == .orderDetail{  //第一个区不要区头 English: The first district does not have a header
            return  UIView()
        }
        
        if sec == .feelist { //手续费列表 English: Fee List
            if self.tableViewRowDatas.count > 0 {
                let v: EXSHistorySectionRounderView = tableView.dequeueReusableHeaderFooterView(withIdentifier: sectionRoundId) as! EXSHistorySectionRounderView
                return v
            }
        }else { //止盈止损 English: Stop profit and stop loss
            if self.protiftAndLossData.count > 0 {
                let v: EXSHistorySectionRounderView = tableView.dequeueReusableHeaderFooterView(withIdentifier: sectionRoundId) as! EXSHistorySectionRounderView
                return v
            }
        }
        
        return UIView()
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let sec = sections[section]
        if sec == .tip || sec == .orderDetail{  //第一个区不要区头 English: The first district does not have a header
            return  UIView()
        }
        
        var showTopRounder = false
        if sec == .feelist{
            showTopRounder = self.tableViewRowDatas.count > 0
        }else{
            showTopRounder = self.protiftAndLossData.count > 0
        }
        let title = sec == .profirtAndLoss ? "cp_overview_text12".ex_localized() : "cp_order_text86".ex_localized()
        let v:EXSHistorySectionHeaderView = tableView.dequeueReusableHeaderFooterView(withIdentifier: sectionHeaderId) as! EXSHistorySectionHeaderView
        v.tipLabel.text = title
        v.showTopRounder = showTopRounder
        return v
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let sec = sections[section]
        if sec == .tip || sec == .orderDetail{  //第一个区不要区头 English: The first district does not have a header
            return  0.01
        }
        var showTopRounder = false
        if sec == .feelist{
            showTopRounder = self.tableViewRowDatas.count > 0
        }else{
            showTopRounder = self.protiftAndLossData.count > 0
        }
        return EXSHistorySectionHeaderView.getViewHeight(showRonder: showTopRounder)
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let sec = sections[indexPath.section]
        if sec == .tip {
            return UITableView.automaticDimension
        }else if sec == .orderDetail {
            return EXSwapLimitOrderDetailCell.cellHeight(model: orderModel)
        }else if sec == .profirtAndLoss {
            return 132
        }else if sec == .feelist{
            if self.tableViewRowDatas.count == 0 {
                return  180//占位图 English: Occupy Bitmap
            }
            
            if indexPath.row == 0 { //标题 35 高一点 English: Title 35 Higher
                return 30
            }else if indexPath.row == self.tableViewRowDatas.count {
                //最后一行 要有底部间隙 English: The last line should have a bottom gap
                return 30 + 13
            }else{
                return 30 //中间正常的cell高度 English: Normal cell height in the middle
            }
        }
        return 0
    }
}
