//
//  EXSwapNewFundsRateViewController.swift
//  Chainup
//
//  Created by ZYJ on 2023/6/11.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import EXKit

//Fund rate
class EXSwapNewFundsRateViewController: ListBaseViewController{
    var lastId:Int64  =  0
    var viewModel = EXSwapDataViewModel(){
        didSet{
            if !self.isViewLoaded {
                return //未加载，不请求 English: Not loaded, not requested
            }
            guard let contractid = viewModel.contractModel?.instrument_id else { return }
            //Same ID twice, no request
            if contractid ==  lastId{
                return
            }
            lastId = contractid
            page = 1
            requestFundingRateList()
        }
    }
    var page = 1
    var limit = 20
    
    lazy var tableHeaderView: UIView = {
        let v = UIView()
        return v
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.view.addSubview(chartView)
        self.tableHeaderView.addSubview(self.chartView)
        self.chartView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 16, left: 0, bottom: 10, right: 16))
            make.height.equalTo(240)
        }
        self.tableHeaderView.snp.updateConstraints { make in
            make.width.equalTo(EXSCREEN_WIDTH)
            make.height.equalTo(240 + 16 + 10)
        }
    
        
        self.fundRateListView.contentTableView.reloadData()
       
        self.view.addSubview(self.fundRateListView)
        self.fundRateListView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview() //.offset(-EX_TABBAR_BOTTOM)
        }

    }
    lazy var chartView: EXSWaplineChartView = {
        let view = EXSWaplineChartView()
        view.type = .fundsrate
        view.chartView.showPrecent = true
        view.chartView.number = NSString(string: "5")
        return view
    }()
    lazy var fundRateListView: EXSwapInfoDetailListView = {
        let view = EXSwapInfoDetailListView()
//        view.selectionTitleBar.bindTitleBar(with: ["contract_action_historyRecord".localized()])
        view.currentTabType = .fundsrate
        view.contentTableView.tableHeaderView = self.tableHeaderView
        return view
    }()
//    func addRefresh() {
//        self.fundRateListView.contentTableView.mj_header = EXRefreshHeaderView(refreshingBlock: {[weak self] in
//            guard let mySelf = self else { return }
//            mySelf.page = 1
//            mySelf.requestFundingRateList()
//        })
//
//        self.fundRateListView.contentTableView.mj_footer = EXRefreshFooterView(refreshingBlock: {[weak self] in
//            guard let mySelf = self else { return }
//            mySelf.requestFundingRateList()
//        })
//    }
    func fundRateHistoryCellData(_ inModel:[EXSFundingRateDetailModel]) -> [EXContractInfoDetailCellModel] {
        if inModel.count == 0 {
            return [EXContractInfoDetailCellModel]()
        }
        return inModel.map({ (model) -> EXContractInfoDetailCellModel in
            let cellModel = EXContractInfoDetailCellModel()
            cellModel.left = DateTools.strToTimeString(model.ctime,dateFormat: "yyyy-MM-dd HH:mm:ss")
            
            let newValue = String(Double(model.amount)! * 100)
            cellModel.right =  newValue.exs_formatAmountUseDecimal("5")
//            cellModel.right =  model.amount.exs_formatAmountUseDecimal("6")
//                model.amount.toValuePrecision(withContract: viewModel.contractModel?.instrument_id ?? 0)
           
            return cellModel
        }).sorted(by: {$0.left > $1.left})
    }
    func lindeData(_ inModel:[EXSFundingRateDetailModel]) -> [EXContractInfoDetailCellModel] {
        if inModel.count == 0 {
            return [EXContractInfoDetailCellModel]()
        }
        return inModel.map({ (model) -> EXContractInfoDetailCellModel in
            let cellModel = EXContractInfoDetailCellModel()
            cellModel.left = DateTools.strToTimeString(model.ctime,dateFormat: "MM/dd HH:mm:ss")
                let newValue = String(Double(model.amount)! * 100)
                cellModel.right =  newValue.exs_formatAmountUseDecimal("5")
            return cellModel
        })
    }
  
    private func requestFundingRateList() {
        EXContractNetwork.queryFundingRateList(contractId: viewModel.contractModel?.instrument_id ?? 0, page: page, limit: limit) { (model) in
            self.fundRateListView.updateDatas(page:self.page,limit:self.limit,historyArray: self.fundRateHistoryCellData(model.historyList))
            self.chartView.lineDataArray = self.lindeData(model.historyList)
        } failure: { (_) in
            
        }
    }

}


