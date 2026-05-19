//
//  EXContactHomeListView.swift
//  Chainup
//
//  Created by cwd on 2022/10/8.
//  Copyright © 2022 Chainup. All rights reserved.
//
import UIKit
import JXPagingView
import EXKit

let EXContactHomeOrderListViewMaxCount: Int = 100
//底部的仓位列表 当前持仓 计划委托 English: The current position plan delegation in the bottom position list
class EXContactHomeOrderListView: EXTableView {
    var isShowing = false //当前是否显示 English: Is it currently displayed
    var transactionPriceType: EXSwapTransactionPriceType = .position
    var itemModel: EXSwapItemModel?
    var closeAlert: UIView?
    var closePositionSuccess: EXComVoidBlock?
    var cancelSuccess: EXComVoidBlock?
    //MARK: 更新预估盈亏 English: MARK: Update estimated profit and loss
    var alertModel: EXSwapPositionModel? {
        didSet{
            guard let m = alertModel else {return}
            guard let alert = closeAlert else {return}
            if alert is EXSClosePositionSheet{
                let new = alert as! EXSClosePositionSheet
                new.positionM = m
            }else if alert is EXSpeedClosePositionSheet{
                let new = alert as! EXSpeedClosePositionSheet
                new.positionModel = m
            }
        }
    }
    
    
    private let limitCellReUseID = "EXSwapLimitTransactionCell_ID"
    private let planCellReUseID = "EXSwapPlanTransactionCell_ID"
    private let cellReUseID = "SLSwapPositionCell_ID"
    var viewModel: EXContractHomeViewModel?
    lazy var showAllView: EXSPositionShowAllView = {
        let v = EXSPositionShowAllView(frame: CGRect(x: 0, y: 0, width: EXSCREEN_WIDTH, height: 36))
        //仅显示当前合约 English: Display only the current contract
        v.onlyShowCurrentContract = {[weak self] onlyCur in
            guard let mySelf = self else {return}
            mySelf.onlyCurrentClick(onlyCurent: onlyCur)
        }
        //一键全平 English: One click full flat
        v.closeAllPositionCallback = { [weak self]  in
            guard let mySelf = self else {return}
            mySelf.allClose()
            
        }
        return v
        
    }()
    required init(viewModel: EXViewModelProtocol?) {
        self.viewModel = viewModel as? EXContractHomeViewModel
        super.init(viewModel: viewModel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupView() {
        super.setupView()
        self.backgroundColor = UIColor.ThemeView.card1
        tableView.ext_RegistCell([EXSwapPositionCell.classForCoder()], [cellReUseID])
        tableView.ext_RegistCell([EXSwapCurrentOrderTableViewCell.classForCoder(), EXSwapPlanTransactionCell.classForCoder(), EXSTransactionEmptyTC.classForCoder()], [limitCellReUseID, planCellReUseID, "EXTransactionEmptyTC"])
    }
    
    override func bindViewModel() {
        super.bindViewModel()

        self.viewModel?.wsEventSubject.subscribe(onNext: { [weak self] event in
            guard let `self` = self else { return }
            if self.isShowing == false {
                return
            }
            switch event {
            //MARK: 每个列表根据类型只听自己的,否则数据会乱 English: MARK: Each list only listens to its own type, otherwise the data will be messy
            case .positionData:
                if self.transactionPriceType == .position{
                    self.tableView.reloadData()
//                    debug//print("合约##==更新持仓") English: DebugPrint ("Contract # #==Update Position")
                    if self.closeAlert != nil{ //平仓弹框 English: Closing Box
                        self.updateEstimatedProfitAndLoss()
                    }
                    break
                }
               
            case .currentEntrustmentData:
               
                if self.transactionPriceType == .limit{
//                    debug//print("合约##==更新当前委托") English: DebugPrint ("Contract # #==Update Current Delegation")
                    self.tableView.reloadData()
                   
                }
                
            case .planEntrustmentData:
               
                if self.transactionPriceType == .plan{
//                    debug//print("合约##==更新计划委托") English: DebugPrint ("Contract # #==Update Plan Delegation")
                    self.tableView.reloadData()
                }
            default:
                break
            }
        }).disposed(by: self.disposeBag)

    }
}

//MARK: 仅当前持仓处理 English: MARK: Only current position processing
extension EXContactHomeOrderListView{
    // 仅当前合约 English: Only the current contract
    func onlyCurrentClick(onlyCurent: Bool){
        if self.transactionPriceType == .position {
            //MARK: fix 这个地方得确认下 English: MARK: Fix, this place needs to be confirmed
            EXNewTracking.shared.trackPage(name: .showAll, isEnter:true)
            self.viewModel?.onlyCurrentContarct = onlyCurent
            self.viewModel?.refreshData()
            EXStoreData.setStoreObjectAndKey(onlyCurent, key: positionOnlyCurrentContract)
        }else if self.transactionPriceType == .limit{
            //MARK: 待处理 English: MARK: To be processed
            EXStoreData.setStoreObjectAndKey(onlyCurent, key: currentEntrustOnlyCurrentContract)
            self.viewModel?.refreshOnlyCurrentData(type: .limit)
        }else{//计划 English: plan
            //MARK: 待处理 English: MARK: To be processed
            EXStoreData.setStoreObjectAndKey(onlyCurent, key: planEntrustOnlyCurrentContract)
            self.viewModel?.refreshOnlyCurrentData(type: .plan)
        }
    }
    // 一键全平/全部撤单 English: One click all flat/cancel all orders
    func allClose(){
        if self.transactionPriceType == .position {
            EXNewTracking.shared.trackPage(name: .onekeyClose, isEnter:true)
            self.viewModel?.oneKeyAllClose()
        }else {
            self.viewModel?.cancelAllEntrustments(priceType: self.transactionPriceType)
        }
    }
    
    
}
extension EXContactHomeOrderListView{
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var btnTitle = "cp_order_text52".ex_localized() //全部撤单 English: Cancel All Orders
        var count: Int = 0
        if transactionPriceType == .position { //当前仓位 English: Current position
            btnTitle = "cl_close_2".ex_localized()
            count = self.viewModel?.positionDatas.count ?? 0
        }else if transactionPriceType == .limit{ //当前委托 English: Current commission
            count = self.viewModel?.currentEntrustmentData.count ?? 0
            let currentEntrustOnlyCurrent = EXStoreData.storeBool(forKey: currentEntrustOnlyCurrentContract)
            self.showAllView.switchButton.isSelected = currentEntrustOnlyCurrent
        }else{ //计划委托 English: Plan delegation
            let planEntrustOnlyCurrent = EXStoreData.storeBool(forKey: planEntrustOnlyCurrentContract)
            self.showAllView.switchButton.isSelected = planEntrustOnlyCurrent
            count = self.viewModel?.planEntrustmentData.count ?? 0
        }
        self.showAllView.allCloseButton.setTitle(btnTitle, for: .normal)
        self.showAllView.allCloseButton.isHidden = (count == 0)
        return self.showAllView
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        var count: Int = 0
        if transactionPriceType == .position { //当前仓位 English: Current position
            return nil
        }else if transactionPriceType == .limit{ //当前委托 English: Current commission
            count = self.viewModel?.currentEntrustmentDataCount ?? 0
        }else{ //计划委托 English: Plan delegation
            count = self.viewModel?.planEntrustmentDataCount ?? 0
        }
        if count > EXContactHomeOrderListViewMaxCount {
            return EXSPositionBottomTipView()
        }
        return nil
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 36 //仅当前合约 English: Only the current contract
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        var count: Int = 0
        if transactionPriceType == .position { //当前仓位 English: Current position
            return 0
        }else if transactionPriceType == .limit{ //当前委托 English: Current commission
            count = self.viewModel?.currentEntrustmentDataCount ?? 0
        }else{ //计划委托 English: Plan delegation
            count = self.viewModel?.planEntrustmentDataCount ?? 0
        }
        if count > EXContactHomeOrderListViewMaxCount {
            return 76
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var data: Int = 0
        if transactionPriceType == .position {
            data = self.viewModel?.positionDatas.count ?? 0
        }else if transactionPriceType == .limit {
            data = self.viewModel?.currentEntrustmentData.count ?? 0
        }else{
            data = self.viewModel?.planEntrustmentData.count ?? 0
        }
        return data > 0 ? data : 1
    }
    
    override  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if transactionPriceType == .position {
            if self.viewModel?.positionDatas.count == 0 {
                return 160
            }
            return 256
        }
        var data = [EXContractOrderModel]()
        if self.viewModel != nil  {
            if transactionPriceType == .limit {
                data = self.viewModel!.currentEntrustmentData
            }else{
                data = self.viewModel!.planEntrustmentData
            }
        }
       
       if  data.count == 0 {
            return 160
        }
//        let model = data[indexPath.row]
        
        if transactionPriceType == .limit {
            return 158
        }else{
            return  185
        }
        
        
//        if !model.shouldHiddenOtoOrderDetailView {
//            return 160 + 32 + 15
//        }else {
//            if transactionPriceType == .limit {
//                return 158
//            }
//            return  175
//        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if transactionPriceType == .position {
            if self.viewModel?.positionDatas.count == 0 {
                let cell: EXSTransactionEmptyTC = tableView.dequeueReusableCell(withIdentifier: "EXTransactionEmptyTC") as! EXSTransactionEmptyTC
                return cell
            }
           
            let cell = tableView.dequeueReusableCell(withIdentifier: cellReUseID, for: indexPath) as! EXSwapPositionCell
            let model = self.viewModel?.positionDatas[indexPath.row]
            if model != nil{
                cell.updateCell(model: model!)
                //MARK: 平仓 English: MARK: Closing positions
                cell.CloseBlock = {[weak self] pm in
                    guard let newSelf = self else{
                        return
                    }
                    EXTracking.shared.track(event: EXSwapTrackingEvent.app_futures_positions_close.rawValue)
                    newSelf.normalClosePosition(model: pm)
                    
                }
                //MARK: 闪电平仓 English: MARK: Flash liquidation
                cell.SpeedCloseBlock = {[weak self] pm in
                    guard let newSelf = self else{
                        return
                    }
                    newSelf.seedClosePosition(model: pm)
                }
                //MARK: 止盈止损 English: MARK: Stop profit and stop loss
                cell.StopPLBlock = {[weak self] pm in
                    guard let newSelf = self else{
                        return
                    }
                    EXTracking.shared.track(event: EXSwapTrackingEvent.app_futures_positions_tpsl.rawValue)
                    newSelf.stopLoss(model: pm)
                    
                }
            }
            cell.willPushVcBlock = {[weak self] in
//                self?.willPushVcBlock?()
                self?.viewModel?.queryAsset()
            }
          
            return cell
        }
        
       else if self.transactionPriceType == .limit {
           
           if self.viewModel?.currentEntrustmentData.count == 0 {
               let cell: EXSTransactionEmptyTC = tableView.dequeueReusableCell(withIdentifier: "EXTransactionEmptyTC") as! EXSTransactionEmptyTC
               return cell
           }
           let model = self.viewModel?.currentEntrustmentData[indexPath.row]

            let cell = tableView.dequeueReusableCell(withIdentifier: limitCellReUseID, for: indexPath) as! EXSwapCurrentOrderTableViewCell
           if model != nil{
               cell.updateCell(model: model!)
               cell.cancelOrderCallback = { [weak self] orderModel in // 取消普通委托 English: Cancel ordinary commission
                   guard let mySelf = self else {return}
                   EXTracking.shared.track(event: EXSwapTrackingEvent.app_futures_orders_cancel.rawValue)
                   mySelf.viewModel?.handleCancelOrder(orderModel)
               }
           }

            return cell
        } else if self.transactionPriceType == .plan {
            if self.viewModel?.planEntrustmentData.count == 0 {
                let cell: EXSTransactionEmptyTC = tableView.dequeueReusableCell(withIdentifier: "EXTransactionEmptyTC") as! EXSTransactionEmptyTC
                return cell
            }
            let model = self.viewModel?.planEntrustmentData[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: planCellReUseID, for: indexPath) as! EXSwapPlanTransactionCell
            cell.transactionType = .current
            if model != nil{
                cell.updateCell(model: model!)
                cell.cancelOrderCallback = { [weak self] orderModel in // 取消计划委托 English: Cancel Plan Delegation
                    guard let mySelf = self else {return}
                    mySelf.viewModel?.handleCancelOrder(orderModel,isConditionOrder: true)
                }
            }
           
            return cell
        }
        return UITableViewCell()
    }
    
}
//MARK: 平仓/处理 English: MARK: Closing/Processing
extension EXContactHomeOrderListView{
    private func getDecimal(unit: String) -> Int {
        let arr = unit.components(separatedBy: ".")
        var count = 0
        if arr.count == 2 {
            count = arr.last?.count ?? 8
        }
        return count
    }
    func updateData(){
        self.viewModel?.queryAsset() //刷新资产 English: Refresh Assets
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.viewModel?.requestPositionData(new: true)
//            self.viewModel?.queryAsset() //刷新资产 English: Refresh Assets
            self.viewModel?.requestTransactionData()
        }
       
    }
    func handleCloseOrder(price:String,priceType:EXSwapMarketOrderPriceType = .limitPrice,volume:String, model: EXSwapPositionModel?) {
        if priceType == .limitPrice, price.lessThanOrEqual(BTZERO) {
            EXAlert.showFail(msg:  "cp_extra_text181".ex_localized())
            return
        }
        if volume.lessThanOrEqual(BTZERO) {
            EXAlert.showFail(msg:  "cp_extra_text182".ex_localized())
            return
        }
        guard let m = self.alertModel else{
            return
        }
        var way : BTContractOrderWay
        if m.side == .openMore {
            way = .sell_CloseLong
        } else {
            way = .buy_CloseShort
        }
        
//        //print("提交参数self.positionModel=\(self.positionModel!.side)") English: Print ("Submit parameter self. positionModel=\ (self. positionModel!. side)")
        var category:BTContractOrderCategory
        if priceType == .marketPrice {
            category = .market
        }else {
            category = .normal
        }
         let orderModel = EXContractOrderModel.newContractCloseOrder(withContractId: m.instrument_id, category: category, way: way, positionID: m.pid, price: price, vol: volume)
            
        orderModel.priceType = priceType
        let isCoin = EXStoreData.storeBool(forKey: EXS_UNIT_VOL)
        //订单单位：0:张，1:价值，2:币 English: Order unit: 0: sheet, 1: value, 2: coin
        orderModel.orderUnit = isCoin ? 2 : 0
        orderModel.position_type = m.position_type
        orderModel.leverage = m.leverageLevel ?? ""
        orderModel.closePosition = true
        if EXStoreData.getOnComfirmSwapAlert() {
            let alert = EXSwapDoubleComfirmAlertView()
            alert.config(orderModel)
            alert.confimModelCallBack = { [weak self]  in
                
                self?.submit(orderModel: orderModel)
            }
            EXAlert.showAlert(alertView: alert)
        }else {
            
            submit(orderModel: orderModel)
        }
    }
    func submit(orderModel:EXContractOrderModel) {
        EXContractNetwork.creatOrder(order: orderModel) {
            EXAlert.showSuccess(msg: "cp_extra_text109".ex_localized())
            self.updateData()
        } failure: { (error) in
        }
        
    }
    //止盈止损界面 English: Stop profit and stop loss interface
    func stopLoss(model: EXSwapPositionModel){
        let profitLossVc = EXStopProfitLossVc()
        profitLossVc.positionModel = model
        self.ex_viewController()?.navigationController?.pushViewController(profitLossVc, animated: true)
    }
    //普通平仓 English: Ordinary liquidation
    func normalClosePosition(model: EXSwapPositionModel){
        let pm = model
        self.alertModel = pm
        //高度给够，否则底部有间隙 English: Give enough height, otherwise there will be a gap at the bottom
        let sheet = EXSClosePositionSheet(frame:.zero)
        self.closeAlert = sheet
      //  sheet.viewModel = self.viewModel
//        sheet.backgroundColor = UIColor.ThemeView.alertBg
        
        var color = UIColor.ThemekLine.down
        if pm.side == .openMore {
            color = UIColor.ThemekLine.up
        }
       
        sheet.dealTypeLabel.text = pm.side.introduce
        sheet.dealTypeLabel.textColor = color
        sheet.dealTypeLabel.titleResizeSize()
        sheet.dealTypeLabel.backgroundColor = color.withAlphaComponent(0.15)
        sheet.nameLabel.text = pm.ex_contractInfo?.showName() ?? ""
        sheet.contractTypeLabel.text = pm.position_type.introduce + "\(pm.leverageLevel)X "
        sheet.contractTypeLabel.titleResizeSize()
        sheet.priceInput.decimal = "\(self.getDecimal(unit: pm.ex_contractInfo?.px_unit ?? "0.00000001"))"
        sheet.priceInput.input.text = pm.indexPxDisplay()
        if let x = sheet.priceInput.input.text{
            if x == "" || x.isEmpty{
                sheet.priceInput.input.text = pm.index_px.toPricePrecision(withContractID: pm.ex_contractInfo?.instrument_id ?? 0)
            }
        }
        
        
        sheet.priceInput.unitLabel.text = pm.ex_contractInfo?.quote_coin ?? "-"
        sheet.positionM = pm
        sheet.subscribeBtnEnable()
        sheet.closePositionCallback = {[weak self](price,priceType, position,model) in // 平仓 English: Closing position
            guard let mySelf = self else { return }
            mySelf.handleCloseOrder(price: price,priceType: priceType, volume: position, model: model)
            mySelf.closeAlert!.removeFromWindow()
            mySelf.closeAlert = nil
           
        }
        sheet.dissmiss = { [weak self] in
            guard let mySelf = self else { return }
            mySelf.viewModel?.updateUserConfig()
            mySelf.closeAlert!.removeFromWindow()
            mySelf.closeAlert = nil
            
        }
        sheet.show()
        EXNewTracking.shared.track(event: .swapPositionClose, info: [:])
    }
    //闪电 English: lightning
    func seedClosePosition(model: EXSwapPositionModel){
        let pm = model
        var color = UIColor.ThemekLine.down
        if pm.side == .openMore {
            color = UIColor.ThemekLine.up
        }
        self.alertModel = pm
        let sheet = EXSpeedClosePositionSheet(frame:.zero)
        self.closeAlert = sheet
        sheet.dealTypeLabel.text =  pm.side.introduce
        sheet.dealTypeLabel.textColor = color
        sheet.dealTypeLabel.backgroundColor = color.withAlphaComponent(0.15)
        sheet.dealTypeLabel.titleResizeSize()
        sheet.positionModel = pm
//        sheet.viewModel = self.viewModel
        sheet.closePositionCallback = { [weak self] in
            guard let newSelf = self else{return}
            if newSelf.alertModel == nil{
                return
            }
            EXTracking.shared.track(event: EXSwapTrackingEvent.app_futures_positions_light_close.rawValue)
           let p = newSelf.alertModel!
            var way : BTContractOrderWay
            if p.side == .openMore {
                way = .sell_CloseLong
            } else {
                way = .buy_CloseShort
            }
            networkApi.rx.request(.speedCloseOrder(contractId: p.instrument_id, open:"CLOSE" , side: way.parmDescForSideWay(), positionType: p.positionType)).exs_MJObjectMap(EXSVoidModel.self,true).subscribe { (_) in
                EXAlert.showSuccess(msg: "cp_extra_text109".ex_localized())
                newSelf.updateData()
               
            } onError: { (error) in
              
            }.disposed(by: newSelf.exs_disposeBag)
            newSelf.closeAlert!.removeFromWindow()
            newSelf.closeAlert = nil
            
        }
        sheet.dissmiss = { [weak self] in
            guard let mySelf = self else { return }
            mySelf.closeAlert!.removeFromWindow()
            mySelf.closeAlert = nil
            mySelf.viewModel?.queryUserConfig()
        }
        sheet.show()
        EXNewTracking.shared.track(event: .swapPositionMarketPrice, info: [:])
    }
    
    
    //更新预期盈亏 English: Update expected profit and loss
    func updateEstimatedProfitAndLoss(){
        if self.alertModel == nil{
            return
        }
        for item in self.viewModel!.positionDatas {
            if item.instrument_id == self.alertModel!.instrument_id && item.side == self.alertModel!.side{
                self.alertModel = item // 更新 English: update
                break
            }
        }
    }
}

///////////////////////////////////////////////////////////////
extension EXContactHomeOrderListView: JXPagingViewListViewDelegate{
    func listView() -> UIView {
        return self
    }
    
    func listScrollView() -> UIScrollView {
        return self.tableView
    }
    
    func listViewDidScrollCallback(callback: @escaping (UIScrollView) -> ()) {
        self.scrollCallback = callback
    }
    func listWillAppear() {
        isShowing = true
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }
            self.tableView.reloadData()
        }
    }
    func listDidAppear(){
//        //print("====>>>>>>>>>listDidAppear %@", transactionPriceType)
    }
    
    func listDidDisappear() {
        isShowing = false
//        //print("====>>>>>>>>>listDidDisappear %@", transactionPriceType)
    }
}


