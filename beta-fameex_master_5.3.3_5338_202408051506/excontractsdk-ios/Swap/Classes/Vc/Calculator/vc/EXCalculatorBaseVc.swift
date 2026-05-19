//
//  EXCalculatorBaseVc.swift
//  Chainup
//
//  Created by cwd on 2022/11/14.
//  Copyright © 2022 Chainup. All rights reserved.
//

import UIKit
import JXSegmentedView
import RxSwift
import RxCocoa
import EXKit
class EXCalculatorBaseVc: ListBaseViewController {
    
    private let iputCellID = "EXCalculatorCell"
    private let leverageReuseID = "EXSwapLeverageCell_ID"
    private let calculatorResultCell = "EXCalculatorResultCell"
    private let tipCell = "EXCalculatorTipCell"
    private let sectionHeaderId = "sectionHeaderId"
    var accountList = [EXContractAssetModel]()
    var transactionShowType : EXSwapTransationViewShowType = .showOpen
    var openMode: EXContractOpenMode = .isolated {
        didSet{
            if oldValue == openMode {
                return
            }
            //print("openMode = \(openMode)")
            upVcData()
        }
    }
    var inputdataLists = EXSInputItemModel.getAllInputList(vcType: .profirt, openMode: .isolated) // 输入区 English: Input area
    var resultdataLists = EXSInputItemModel.getresultShowList(vcType: .profirt) //展示区 English: Display area
    
    var vcType: CalculatorVCType = .profirt
    var viewModel = EXSwapDataViewModel() {
        didSet {
            upVcData()
            self.startCarculateBtn.isEnabled = false
        }
    }
     //MARK: lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configView()
        observerCaluteBtnEnable()
        viewModel.updateData = { [weak self] in //更新杠杆的值 English: Update the value of leverage
            self?.relaodLeveCell()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.vcType == .forceClose{
            self.getAvailableBalance()
        }
    }
    
    //MARK: lazy
    lazy var topBtnView: EXCalculatorTopButtonView = {
        let v = EXCalculatorTopButtonView(frame: CGRect(x: 0, y: 0, width: Device_W, height: EXCalculatorTopButtonView.viewHeight))
        v.btnClick = { [weak self] type in
            guard let newSelf = self else{
                return
            }
            newSelf.transactionShowType = type
        }
        return v
    }()
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = UIColor.ThemeView.bg
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.estimatedRowHeight = 0
        tableView.estimatedSectionHeaderHeight = 100
        tableView.register(EXCalculatorSecitonHeader.self, forHeaderFooterViewReuseIdentifier: sectionHeaderId)
        tableView.register(EXCalculatorInputCell.self, forCellReuseIdentifier: iputCellID)
        tableView.register(EXSCalcuLeverView.self, forCellReuseIdentifier: leverageReuseID)
        tableView.register(EXCalculatorResultCell.self, forCellReuseIdentifier: calculatorResultCell)
        tableView.register(EXCalculatorTipCell.self, forCellReuseIdentifier: tipCell)
        tableView.tableHeaderView = self.topBtnView
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        }
        return tableView
    }()
    
    lazy var startCarculateBtn: EXSButton = {
        let btn = EXSButton()
        btn.ext_UseAutoLayout()
        btn.ext_SetAddTarget(self, #selector(clickStartCarculateBtn))
        btn.setTitle("cp_calculator_text11".ex_localized(), for: .normal)
        btn.disabledColor = .Ex.fill5
        btn.color = .Ex.main1
        btn.setTitleColor(.Ex.text2, for: .disabled)
        btn.setTitleColor(.Ex.text4, for: .normal)
        return btn
    }()
}
extension EXCalculatorBaseVc{
    func getAvailableBalance(){
        if EXSwapPlatformSDK.shared.activeAccount?.token == nil {
            return
        }
        EXContractNetwork.getUserPositionOrAsset(onlyAccount: true, marginCoin: "") {[weak self] (model) in
            guard let mySelf = self else {return}
            mySelf.accountList = model.accountList
            DispatchQueue.main.async {
                mySelf.reloadAvailableBalanceCell()
            }
        } failure: { (error) in
        }.disposed(by: self.exs_disposeBag)
    }
    
}
extension EXCalculatorBaseVc{
    
    //MARK: UI
    func configView(){
        self.view.exs_addSubViews([self.tableView,startCarculateBtn])
        self.tableView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
        }
        startCarculateBtn.snp.makeConstraints { make in
            make.top.equalTo(tableView.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(44)
            make.bottom.equalToSuperview().offset(-44)
        }
    }
}
extension EXCalculatorBaseVc{
    //MARK: 按钮的监听 English: MARK: Listening to buttons
    func observerCaluteBtnEnable(){
        var canuse = true
        for item in inputdataLists{
            if item.value.count == 0 {
                canuse = false
                break
            }
        }
        self.startCarculateBtn.isEnabled = canuse
    }
    //MARK: 刷新杠杆 English: MARK: Refresh lever
    func relaodLeveCell(){
        let lever = self.viewModel.leverage
        let leverInput = self.inputdataLists[0]
        leverInput.value = lever
        let indexp = IndexPath(row: 0, section: 0)
        self.tableView.reloadRows(at: [indexp], with: .none)
    }
    //MARK: 刷新余额 English: MARK: Refresh balance
    func reloadAvailableBalanceCell(){
        if self.vcType != .forceClose{
            return
        }
        if self.openMode == .isolated {
            return
        }
        var account = EXContractAssetModel()
        account.canUseAmount = ""
        if let token = EXSwapPlatformSDK.shared.activeAccount?.token {
            for item in accountList{
                if item.originalCoin == self.viewModel.itemModel?.ex_contractInfo?.originalCoin{
                    account = item
                    break
                }
            }
        }
        if self.openMode == .isolated {
            return
        }
        //全仓才需要余额 English: Only the entire warehouse requires a balance
        let indexp = self.inputdataLists.firstIndex { item in
            return item.type == .availableBalance
        }
        if let ix = indexp {
            let model = inputdataLists[ix]
            model.value = account.canUseAmount.marketPriceVolPrecision(withContract: viewModel.contractModel?.instrument_id ?? 0)
            let indexPath = IndexPath(row: ix, section: 0)
            self.tableView.reloadRows(at: [indexPath], with: .none)
        }
    }
    
    
    //MARK: 更新界面的数据 English: MARK: Updating data on the interface
    func upVcData(){
        inputdataLists = EXSInputItemModel.getAllInputList(vcType: self.vcType, openMode: self.openMode) // 输入区 English: Input area
        resultdataLists = EXSInputItemModel.getresultShowList(vcType: self.vcType) //展示区 English: Display area
        updateFieldUnit()
        tableView.reloadData()
        self.reloadAvailableBalanceCell()
        
    }
    //MARK: 更新界面的数据 English: MARK: Updating data on the interface
    func updateFieldUnit() {
        let contract = viewModel.contractModel
        let config = viewModel.contractModel?.coinResultVo
        let symbolPricePrecision = Int(config?.symbolPricePrecision ?? "0") ?? 0
        var marginCoinPrecision = Int(config?.marginCoinPrecision ?? "0") ?? 0
        var availableBalancePrecision = Int(EXSTools.decimalValue(px_unit: viewModel.contractModel?.minOrderMoney_unit))
        var openOrderPrecision: Int = 0 //coin or coit
        if (contract?.isCoin ?? false) == true{
            openOrderPrecision = contract?.qty_unit.to_Precision() ?? 0
        }
//        //print("item.decimal = \(openOrderPrecision)")
//        //print("== contract px_unit = \(contract?.px_unit)" )
//        //print("== contract qty_unit = \(contract?.qty_unit)" )
//        //print("== contract qty_unit = \(contract?.value_unit)" )
//        //print("== contract minOrderMoney_unit = \(contract?.minOrderMoney_unit)" )
//        //print("== contract minOrderMoney = \(contract?.coinResultVo.minOrderMoney)" )
//        //print("== contract marginCoinPrecision = \(contract?.coinResultVo.marginCoinPrecision)" )
//        //print("== contract symbolPricePrecision = \(contract?.coinResultVo.symbolPricePrecision)" )

        for item in inputdataLists{
            if item.type == .lever {
                item.value = viewModel.leverage
                item.placeHoder = viewModel.maxCoinTipLabelText
            }else if item.type == .openPrice || item.type == .closePrice {
                item.unit = viewModel.priceUnit // price presion
                item.decimal = symbolPricePrecision
            }else if item.type == .amount {
                item.unit = viewModel.volumeUnit
                item.decimal = openOrderPrecision
            }else if item.type == .posiAmount{
                item.unit = viewModel.volumeUnit
                item.decimal = openOrderPrecision
            }else if item.type == .availableBalance{
                item.unit = viewModel.costUnit
                let deci = availableBalancePrecision
                item.decimal = deci
            }else if item.type == .reurnRate{
                item.unit = "%" //已实现盈亏 English: Realized profit and loss
                item.decimal = 2
            }
        }
    }
    
    //MARK: 按钮 计算 English: MARK: button calculation
    @objc func clickStartCarculateBtn() {
         if viewModel.itemModel == nil {
             return
         }
        
        if self.vcType == .profirt {
            calculateProftAndLoss()
        }else if self.vcType == .forceClose{
            forceClose()
        }else{
            close()
        }
        tableView.scroll(to:.bottom, animated: true)
     }
     
     // //MARK: 收益 English: MARK: Revenue
     func calculateProftAndLoss() {
         var qty = "0"
         var px = "0"
         var closePx = "0"
         for item in inputdataLists{
             if item.type == .amount {
                 qty = item.value
             }else if item.type == .openPrice{
                 px = item.value
             }else if item.type == .closePrice{
                 closePx = item.value
             }
         }
         // 数量 /价格 English: Quantity/Price
         if let model = viewModel.contractModel {
             if !model.isCoin {
                 qty = EXFormula.ticket(toCoin: qty, contract: model)
             }

             var profit = "0"
             if self.transactionShowType == .showOpen {
                 profit = EXFormula.calculateCloseLongProfitAmount(qty, holdAvgPrice: px, markPrice: closePx, contractInfo: model)
             }else {
                 profit = EXFormula.calculateCloseShortProfitAmount(qty, holdAvgPrice: px, markPrice: closePx, contractInfo: model)
             }
             let orderAvai = EXFormula.calculateContractValue(withCoinVol: qty, price: px, contractModel: model)
             let deposit = orderAvai.bigDiv(viewModel.leverage).bigDiv(model.marginRate)
             let rate = profit.bigDiv(deposit).toPercentString(2)
             let results = [deposit.toValuePrecision(withContract: model.instrument_id) + viewModel.costUnit,
                     profit.toValuePrecision(withContract: model.instrument_id) + viewModel.costUnit,
                     rate]
             for (index,value) in results.enumerated(){
                let show = resultdataLists[index]
                 show.value = value
             }
             tableView.reloadSections([1], with: .none)
         }
     }
    
    //MARK:  强平 English: MARK: Qiangping
    func forceClose(){
        var px = "0"
        var qty = "0"
        var im = "0"
        for item in inputdataLists{
            if item.type == .posiAmount {
                qty = item.value
            }else if item.type == .openPrice{
                px = item.value
            }else if item.type == .availableBalance{
                im = item.value
            }
        }
        
        let order = EXContractOrderModel()
        order.instrument_id = viewModel.itemModel!.instrument_id
        order.leverage = viewModel.leverage
        if transactionShowType == .showOpen {
            order.side = BTContractOrderWay.buy_OpenLong
        } else {
            order.side = BTContractOrderWay.sell_OpenShort
        }
        order.px =  px//openPriceField.input.text ?? "0"
        order.qty = qty //positionVolume.input.text ?? "0"
        ///张需要处理为币,然后再计算 English: /Zhang needs to be processed into coins before calculating
        if let model = viewModel.contractModel, !model.isCoin {
            order.qty = EXFormula.ticket(toCoin:  order.qty, contract: model)
        }
        order.im = im //availableBalance
        var closePx = ""
        if self.openMode == .isolated {
            closePx = EXFormula.isolatedCalculateOrderLiquidatePrice(order, assets: nil, contractInfo: viewModel.contractModel)
        }else{
            let canopen = EXFormula.canOpenOrder(order, contractInfo: viewModel.contractModel, canUse: im)
            if canopen == false {
                return
            }
            closePx = EXFormula.newCalculateOrderLiquidatePrice(order, assets: nil, contractInfo: viewModel.contractModel)
        }
       
        if closePx.lessThanOrEqual(BTZERO) {
            EXAlert.showFail(msg: "cp_extra_text39".ex_localized())
            return
        }       
        let result = resultdataLists[0]
        result.value = closePx + viewModel.priceUnit
        tableView.reloadSections([1], with: .none)
        
    }
    
    //MARK: 平仓 English: MARK: Closing positions
    func close(){
        
        var px = "0"
        var returnRate = "0"
        for item in inputdataLists{
            if item.type == .reurnRate {
                returnRate = item.value
            }else if item.type == .openPrice{
                px = item.value
            }
        }
        
        let order = EXContractOrderModel()
        order.instrument_id = viewModel.itemModel!.instrument_id;
        order.leverage = viewModel.leverage
        if transactionShowType == .showOpen {
            order.side = BTContractOrderWay.buy_OpenLong
        } else {
            order.side = BTContractOrderWay.sell_OpenShort
        }
        order.px = px// openPriceField.input.text ?? "0"
        let roi = returnRate //RIOField.input.text ?? "0"
        var closePrice = EXFormula.calculateClosePrice(order, ROI: roi.bigMul("0.01"), contractInfo: viewModel.contractModel)
        closePrice = closePrice.toPricePrecision(withContractID: viewModel.contractModel?.instrument_id ?? 0)
        if closePrice.lessThanOrEqual(BTZERO) {
            EXAlert.showFail(msg: "cp_extra_text118".ex_localized())
            return
        }
        let result = resultdataLists[0]
        result.value = closePrice + viewModel.priceUnit
        tableView.reloadSections([1], with: .none)
    }
    
    //MARK: /杠杆cell的处理 English: MARK:/Handling of lever cells
    func leverFieldValueHasChange(leverV: EXSCalcuLeverView) {
        if var value = leverV.input.input.text,!value.isEmpty {
            value = value.removeAllSapce
            if let maxValue = self.viewModel.contractModel?.maxLever, value.greaterThan(maxValue) {
                leverV.input.input.text = maxValue
            }
            if let minValue = self.viewModel.contractModel?.minLever, value.lessThanOrEqual(minValue) {
                leverV.input.input.text = minValue
            }
        }
        self.viewModel.leverage = leverV.input.input.text ?? ""
        leverV.vauleLabel.text = self.viewModel.maxCoinTipLabelText
    }
    //change Mode to reload
    func reloadViewWithOpenMode(){
        upVcData()
    }
}




extension EXCalculatorBaseVc: UITableViewDelegate,UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int{
        return 2 // 第个输入框区，第二个区计算结果展示区 English: The second input box area and the calculation result display area
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return inputdataLists.count
        }else{
            return resultdataLists.count
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let input = inputdataLists[indexPath.row]
            if input.type == .lever {
                let cell = tableView.dequeueReusableCell(withIdentifier: leverageReuseID, for: indexPath) as! EXSCalcuLeverView
                cell.inputFieldValueChangedBlock = { [weak self] in
                    self?.leverFieldValueHasChange(leverV:cell)
                }
                cell.inputModel = input
                return cell
            }else if input.type == .tip{
                let cell = tableView.dequeueReusableCell(withIdentifier: tipCell, for: indexPath) as! EXCalculatorTipCell
                return cell
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: iputCellID, for: indexPath) as! EXCalculatorInputCell
                cell.inputModel = input
                cell.textChageBlock = { [weak self] in
                    self?.observerCaluteBtnEnable()
                }
                return cell
            }
        }else{ //结果展示区 English: Result display area
            let input = resultdataLists[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: calculatorResultCell, for: indexPath) as! EXCalculatorResultCell
            cell.inputModel = input
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if section == 1 { //第一个区不要区头 English: The first district does not have a header
            let v:EXCalculatorSecitonHeader = tableView.dequeueReusableHeaderFooterView(withIdentifier: sectionHeaderId) as! EXCalculatorSecitonHeader
            return v
        }
        return  UIView()
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        }else{
            return UITableView.automaticDimension
        }
//        return section == 0 ? 0 : 120
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            let input = inputdataLists[indexPath.row]
            if input.type == .lever {
               return 16 + 66 + 8 + 16
            }else if input.type == .tip{
                return EXCalculatorTipCell.getCellHeight()
            }else{
               return 16 + 66
            }
        }else{ //结果展示区 English: Result display area
           return 32
        }
    }
}


   

