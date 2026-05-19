//
//  EXSwapInsuranceFundViewController.swift
//  Chainup
//
//  Created by ZYJ on 2023/6/11.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import EXKit

class EXSwapInsuranceFundViewController: ListBaseViewController {
    
    var depositCoinList = EXSwapPublicInfo.shared.marginCoinList
    
    var viewModel = EXSwapDataViewModel()
    {
        didSet {
            coin = viewModel.itemModel?.ex_contractInfo?.marginCoin ?? ""
        }
    }
    var lastCoin: String? = ""
    //选中的保障金币种 English: Selected security coins
    var coin:String? {
        didSet(old){
            if !self.isViewLoaded {
                return
            }
            if coin == nil{
                return
            }
            if lastCoin == coin {return}
            lastCoin = coin!
            self.chartView.chartView.paoPaoNumber = self.getChartPaoToastPrecision()
            page = 1
            balanceView.coin = coin!
            requestInstruceBlanceInfoData()
            requestInstruceInfoData()
        }
    }
    //图标数据 English: Icon data
    var lineDataArray = [EXContractInfoDetailCellModel]()
    var page = 1
    var limit = 20
    //余额 English: balance
    lazy var balanceView: EXInsurancefundbalanceView = {
        let v = EXInsurancefundbalanceView()
        v.isHidden = true
        v.changeMarginCallBack = { [weak self] in
            guard let newSelf = self else{
                return
            }
            newSelf.selectMarginCoin()
        }
        return v
    }()
    lazy var insuranceFundListView: EXSwapInfoDetailListView = {
        let view = EXSwapInfoDetailListView()
        view.currentTabType = .insurance
//        view.selectionTitleBar.bindTitleBar(with: ["contract_action_historyRecord".localized(), "contract_action_profitAndLossDetails".localized()])
        return view
    }()
    lazy var chartView: EXSWaplineChartView = {
        let view = EXSWaplineChartView()
        view.type = .insurance
        return view
    }()
    
    lazy var tableHeaderView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.ThemeView.bg
        return v
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.view.addSubview(balanceView)
//        balanceView.snp.makeConstraints { make in
//            make.top.equalToSuperview()
//            make.left.right.equalToSuperview()
//            make.height.equalTo(EXInsurancefundbalanceView.viewHeight)
//            make.width.equalTo(EXSCREEN_WIDTH)
//        }
//        self.view.addSubview(chartView)
//        chartView.snp.makeConstraints { make in
//            make.top.equalTo(balanceView.snp.bottom).offset(2)
//            make.left.equalToSuperview().offset(5)
//            make.right.equalToSuperview().offset(-5)
//            make.height.equalTo(240)
//            make.width.equalTo(EXSCREEN_WIDTH)
//        }
        
        self.tableHeaderView.addSubViews([self.balanceView, self.chartView])
        self.balanceView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.right.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(EXInsurancefundbalanceView.viewHeight)
        }
        self.chartView.snp.makeConstraints { make in
            make.top.equalTo(self.balanceView.snp.bottom).offset(2)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(240)
        }
        self.tableHeaderView.snp.updateConstraints { make in
            make.width.equalTo(EXSCREEN_WIDTH)
            make.height.equalTo(EXInsurancefundbalanceView.viewHeight + 2 + 240)
        }
        
        self.insuranceFundListView.contentTableView.reloadData()
        
        self.insuranceFundListView.contentTableView.tableHeaderView = self.tableHeaderView
        
        self.view.addSubview(insuranceFundListView)
        insuranceFundListView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview() //.offset(-EX_TABBAR_BOTTOM)
        }
//        addRefresh()
        // Do any additional setup after loading the view.
    }
    
    func selectMarginCoin(){
        
        if coin == nil {
            return
        }
        let sheet = EXActionSheetView()
        let arr  = depositCoinList
        let idx =  depositCoinList.firstIndex(of: coin!) ?? 0
        sheet.configButtonTitles(buttons: arr,selectedIdx: idx)
        sheet.actionIdxCallback = {[weak self](idx) in
            guard let mySelf = self else{return}
            mySelf.coin = arr[idx]
        }
        sheet.actionCancelCallback =  {() in
        }
        EXAlert.showSheet(sheetView: sheet)
    }
    
    
    
    //
    //余额请求 English: Balance request
    private func requestInstruceBlanceInfoData() {
        let originCoin = EXSwapPublicInfo.shared.maiginOrignPair[self.coin!]
        guard originCoin != nil else {
            return
        }
        EXContractNetwork.queryRiskBalanceAccount(coinSymbol: originCoin!) { model in
            self.balanceView.isHidden = false
            self.balanceView.amount = model.amount.marginPrecision(marginCoin: self.coin)
        } failure: { (_) in
            
        }
    }
    private func requestInstruceInfoData() {
        let originCoin = EXSwapPublicInfo.shared.maiginOrignPair[self.coin!]
        guard originCoin != nil else {
            return
        }
        EXContractNetwork.queryRiskBalanceList(coinSymbol: originCoin!, page: page, limit: limit) { (model) in
            self.chartView.chartView.number = self.getChartYPrecision(instranceModel: model)
            self.chartView.lineDataArray = self.lineData(model)
            self.insuranceFundListView.updateDatas(page:self.page,limit:self.limit,historyArray: self.instranceHistoryCellData(model))
        } failure: { (_) in
            
        }
    }
    
    func instranceHistoryCellData(_ instranceModel:EXSInstranceModel) -> [EXContractInfoDetailCellModel] {
        if instranceModel.brokenLineList.count == 0 {
            return [EXContractInfoDetailCellModel]()
        }
        return instranceModel.brokenLineList.map({ (model) -> EXContractInfoDetailCellModel in
            let cellModel = EXContractInfoDetailCellModel()
            cellModel.left = DateTools.strToTimeString(model.ctime,dateFormat: "yyyy-MM-dd HH:mm:ss")
            cellModel.right = model.amount.marginPrecision(marginCoin: self.coin)
            return cellModel
        }).sorted(by: {$0.left > $1.left})
    }
    //未上拉下拉未处理 English: Unpulled and Unprocessed Dropdown
    func lineData(_ instranceModel:EXSInstranceModel) -> [EXContractInfoDetailCellModel] {
        if instranceModel.brokenLineList.count == 0 {
            return [EXContractInfoDetailCellModel]()
        }
        return instranceModel.brokenLineList.map({ (model) -> EXContractInfoDetailCellModel in
            let cellModel = EXContractInfoDetailCellModel()
            cellModel.left = DateTools.strToTimeString(model.ctime,dateFormat: "MM/dd HH:mm:ss")
            cellModel.right = model.amount.marginPrecision(marginCoin: self.coin)
            return cellModel
        })
    }

    func getChartPaoToastPrecision() -> NSString {
        var pre = "0"
        if let item = EXSwapPublicInfo.shared.getContractsModelWithMarginCoin(marginCoin: coin ?? ""){
            pre = item.coinResultVo.marginCoinPrecision
        }
        return NSString(string: pre)
    }
    
    func getChartYPrecision(instranceModel:EXSInstranceModel) -> NSString {
        if instranceModel.brokenLineList.count == 0 { //
            return NSString(string: "0")
        }
        var pre = "0"
        let info = instranceModel.brokenLineList.first
        if let m = info?.amount, m.lessThan("1"){ //greater than  set to "0"
            if let item = EXSwapPublicInfo.shared.getContractsModelWithMarginCoin(marginCoin: coin ?? ""){
                pre = item.coinResultVo.marginCoinPrecision
            }
        }
        return NSString(string: pre)
    }
    
}

