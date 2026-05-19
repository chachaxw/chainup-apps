//
//  EXContranctInfoDetailVc.swift
//  Chainup
//
//  Created by ZYJ on 2023/11/18.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import EXKit


class EXContranctInfoDetailVc: ListBaseViewController, EXEmptyDataSetable {

    lazy var currentContractModel:EXSwapItemModel? = {
    
        return contractArray.first
    }()
    
    var contractArray: [EXSwapItemModel] {
       
        var arrM = [EXSwapItemModel]()
        for obj in EXSwapPublicInfo.shared.getSortTickers(area: self.currentArea) ?? [] where obj.ex_contractInfo != nil {
            arrM.append(obj)
        }
       
        return arrM
    }
    let marginCoinList:[String] = {
        return EXSwapPublicInfo.shared.marginCoinList
    }()
    var page = 1
    var limit = 20
    lazy var currentMarginCoin:String = {
        return marginCoinList.first ?? ""
    }()
    
    let areaArray:[BTContract_Block_Type] = {
        var ret = [BTContract_Block_Type]()
        
        let tickers = EXSwapPublicInfo.shared.getAllSwapInfo()
        if let array = tickers {
            
            for info in array {
                if !ret.contains(info.area) {
                    ret.append(info.area)
                }
            }
        }
        return ret
    }()
    
    lazy var currentArea:BTContract_Block_Type = {
        return areaArray.first ?? .CONTRACT_BLOCK_UNKOWN
    }()
    
//    lazy var insuranceFundSelectButton: UIButton = {
//        let button = UIButton(buttonType: .custom, title: "contract_text_insuranceFund".localized(), titleFont: UIFont.ThemeFont.H1Bold, titleColor: UIColor.ThemeLabel.colorMedium)
//        button.setTitleColor(UIColor.ThemeLabel.colorLite, for: .selected)
//        button.extSetAddTarget(self, #selector(clickInsuranceFundButton))
//        return button
//    }()
//
//    lazy var fundRateSelectButton: UIButton = {
//        let button = UIButton(buttonType: .custom, title: "contract_text_marginRate".localized(), titleFont: UIFont.ThemeFont.HeadRegular, titleColor: UIColor.ThemeLabel.colorMedium)
//        button.setTitleColor(UIColor.ThemeLabel.colorLite, for: .selected)
//        button.extSetAddTarget(self, #selector(clickFundRateButton))
//        return button
//    }()
//
//    lazy var fundRateScreeningView = EXSwapScreeningView()
//    lazy var instranceScreenView = EXSwapScreeningView()
    lazy var insuranceFundListView: EXSwapInfoDetailListView = {
        let view = EXSwapInfoDetailListView()
        view.currentTabType = .insurance
//        view.selectionTitleBar.bindTitleBar(with: ["contract_action_historyRecord".localized(), "contract_action_profitAndLossDetails".localized()])

        return view
    }()
    
    lazy var fundRateListView: EXSwapInfoDetailListView = {
        let view = EXSwapInfoDetailListView()
//        view.selectionTitleBar.bindTitleBar(with: ["contract_action_historyRecord".localized()])
        return view
    }()
    
    lazy var contentScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isPagingEnabled = true
        
        let container = UIView()
        scrollView.addSubview(container)
        container.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
            make.height.equalToSuperview()
        }
        
        container.addSubViews([insuranceFundListView, fundRateListView])
//        self.exEmptyDataSet(insuranceFundListView.contentTableView)
//        self.exEmptyDataSet(fundRateListView.contentTableView)
//
        insuranceFundListView.snp.makeConstraints { (make) in
            make.left.top.bottom.equalToSuperview()
            make.width.equalTo(scrollView)
        }
        fundRateListView.snp.makeConstraints { (make) in
            make.left.equalTo(insuranceFundListView.snp.right)
            make.width.top.bottom.equalTo(insuranceFundListView)
            make.right.equalToSuperview()
        }
        return scrollView
    }()

}

extension EXContranctInfoDetailVc {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 11.0, *) {
            self.contentScrollView.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        
        if let gesArr = self.navigationController?.view.gestureRecognizers {
            for ges in gesArr {
                if ges is UIScreenEdgePanGestureRecognizer {
                    self.contentScrollView.panGestureRecognizer.require(toFail: ges)
                }
            }
        }
        
        self.initLayout()
//        setupScreenView()
        addRefresh()
        p_selectedInsuranceFundButton()
//        bindSubViews()
//        self.contentScrollView.delegate = self
    }
}

extension EXContranctInfoDetailVc {
    
//    private func updateFundRateScreenView() {
//        self.fundRateScreeningView.orderTypeArray = contractArray.map{$0.ex_contractInfo?.showName() ?? ""}
//    }
    
//    fileprivate func initFundRateScreenView() {
//        // 设置合约类型 English: Set contract type
//        self.fundRateScreeningView.isHiddenPriceType = true
//        // 设置合约数组 English: Set contract array
//        self.fundRateScreeningView.swapNameArray = areaArray.map{EXContractArea.generateBy(blockType: $0).introduce}
//        // 设置初始选中的合约 English: Set the initially selected contract
//        if areaArray.first != nil {
//            self.fundRateScreeningView.initialSwapName = EXContractArea.generateBy(blockType: currentArea).introduce
//        }
//        updateFundRateScreenView()
//        // 切换筛选条件 English: Switch filtering criteria
//        self.fundRateScreeningView.screeningValueChanged = {[weak self]
//            (areaIndex: Int, _, contractTypeIndex: Int) in
//            guard let mySelf = self else { return }
//
//            if areaIndex < mySelf.areaArray.count {
//
//                mySelf.currentArea = mySelf.areaArray[areaIndex]
//            }
//            if contractTypeIndex < mySelf.contractArray.count {
//                mySelf.currentContractModel = mySelf.contractArray[contractTypeIndex]
//            }
//            mySelf.page = 1
//            mySelf.requestFundingRateList()
//        }
//        self.fundRateScreeningView.swapNameValueChanged = {[weak self] in
//            guard let mySelf = self else { return }
//
//            mySelf.updateFundRateScreenView()
//        }
//    }
    
//    func setupScreenView() {
//        initFundRateScreenView()
//        initInstranceScreenView()
//        updateSwapScreeningView()
//    }
    
//    func initInstranceScreenView() {
//
//        self.instranceScreenView.isHiddenPriceType = true
//        self.instranceScreenView.orderTypeButton.isHidden = true
//        self.instranceScreenView.swapNameArray = marginCoinList
//        if marginCoinList.first != nil {
//            self.instranceScreenView.initialSwapName = marginCoinList.first
//        }
//        self.instranceScreenView.screeningValueChanged = {
//            [weak self] (firstIndex, _,_) in
//            guard let mySelf = self else { return }
//            mySelf.page = 1
//            if firstIndex < mySelf.marginCoinList.count {
//                mySelf.currentMarginCoin = mySelf.marginCoinList[firstIndex]
//            }
//            mySelf.requestInstruceInfoData()
//        }
//    }
    /// 更改筛选条件 English: /Change filtering criteria
//    private func updateSwapScreeningView() {
//
//        self.fundRateScreeningView.isHidden = !self.fundRateSelectButton.isSelected
//        self.instranceScreenView.isHidden = !self.insuranceFundSelectButton.isSelected
//    }
    func currentMarginCoinContractsModel() -> EXContractsModel? {
        return EXSwapPublicInfo.shared.getContractsModelWithMarginCoin(marginCoin: currentMarginCoin)
    }
    func fundRateHistoryCellData(_ inModel:[EXSFundingRateDetailModel]) -> [EXContractInfoDetailCellModel] {
        if inModel.count == 0 {
            return [EXContractInfoDetailCellModel]()
        }
        return inModel.map({ (model) -> EXContractInfoDetailCellModel in
            let cellModel = EXContractInfoDetailCellModel()
            cellModel.left = DateTools.strToTimeString(model.ctime,dateFormat: "yyyy-MM-dd HH:mm:ss")
            cellModel.right = model.amount.toValuePrecision(withContract: currentContractModel?.instrument_id ?? 0)
            return cellModel
        })
    }
    
    func instranceHistoryCellData(_ instranceModel:EXSInstranceModel) -> [EXContractInfoDetailCellModel] {
        if instranceModel.brokenLineList.count == 0 {
            return [EXContractInfoDetailCellModel]()
        }
        return instranceModel.brokenLineList.map({ (model) -> EXContractInfoDetailCellModel in
            let cellModel = EXContractInfoDetailCellModel()
            cellModel.left = DateTools.strToTimeString(model.ctime,dateFormat: "MM/dd HH:mm:ss")
            cellModel.right = model.amount.toValuePrecision(withContract: currentMarginCoinContractsModel()?.instrument_id ?? 0)
            return cellModel
        })
    }
    func profitAndLossCellData(_ instranceModel:EXSInstranceModel) -> [EXContractInfoDetailCellModel] {
        if instranceModel.historyList.count == 0 {
            return [EXContractInfoDetailCellModel]()
        }
        return instranceModel.historyList.map({ (model) -> EXContractInfoDetailCellModel in
            let cellModel = EXContractInfoDetailCellModel()
            cellModel.left = DateTools.strToTimeString(model.ctime,dateFormat: "MM/dd HH:mm:ss")
            cellModel.middle = model.typeDisplay
            cellModel.right = model.hisAmount.toValuePrecision(withContract: currentMarginCoinContractsModel()?.instrument_id ?? 0)
            return cellModel
        })
    }
    private func requestInstruceInfoData() {
        EXContractNetwork.queryRiskBalanceList(coinSymbol: currentMarginCoin, page: page, limit: limit) { (model) in

//            self.insuranceFundListView.updateDatas(page:self.page,limit:self.limit,historyArray: self.instranceHistoryCellData(model), profitAndLossArray: self.profitAndLossCellData(model))
            self.page += 1
        } failure: { (_) in
            
        }
    }
    private func requestFundingRateList() {
        EXContractNetwork.queryFundingRateList(contractId: currentContractModel?.instrument_id ?? 0, page: page, limit: limit) { (model) in
//            self.fundRateListView.updateDatas(page:self.page,limit:self.limit,historyArray: self.fundRateHistoryCellData(model.historyList), profitAndLossArray: nil)
        } failure: { (_) in
            
        }
    }
   
}

extension EXContranctInfoDetailVc {
    
    func addRefresh() {
        self.fundRateListView.contentTableView.mj_header = EXRefreshHeaderView(refreshingBlock: {[weak self] in
            guard let mySelf = self else { return }
            mySelf.page = 1
            mySelf.requestFundingRateList()
        })
        
        self.insuranceFundListView.contentTableView.mj_footer = EXRefreshFooterView(refreshingBlock: {[weak self] in
            guard let mySelf = self else { return }
            mySelf.requestInstruceInfoData()
        })
        self.insuranceFundListView.contentTableView.mj_header = EXRefreshHeaderView(refreshingBlock: {[weak self] in
            guard let mySelf = self else { return }
            mySelf.page = 1
            mySelf.requestInstruceInfoData()
        })
        
        self.fundRateListView.contentTableView.mj_footer = EXRefreshFooterView(refreshingBlock: {[weak self] in
            guard let mySelf = self else { return }
            mySelf.requestFundingRateList()
        })
    }
    
    private func initLayout() {
        
        
        self.view.addSubview(self.contentScrollView)
     
//        topView.addSubViews([self.insuranceFundSelectButton, self.fundRateSelectButton, self.fundRateScreeningView, self.instranceScreenView])

       
//        let marginView = UIView()
//        marginView.backgroundColor = UIColor.ThemeNav.bg
//
//
//        marginView.snp.makeConstraints { (make) in
//            make.left.right.bottom.equalToSuperview()
//            make.top.equalTo(self.fundRateScreeningView.snp.bottom)
//        }
//        self.insuranceFundSelectButton.snp.makeConstraints { (make) in
//            make.left.equalTo(15)
//            make.height.equalTo(40)
//            make.top.equalTo(10)
//        }
//        self.fundRateSelectButton.snp.makeConstraints { (make) in
//            make.left.equalTo(self.insuranceFundSelectButton.snp.right).offset(15)
//            make.bottom.equalTo(self.insuranceFundSelectButton)
//            make.height.equalTo(28)
//        }
//        self.fundRateScreeningView.snp.makeConstraints { (make) in
//            make.top.equalTo(self.insuranceFundSelectButton.snp.bottom).offset(10)
//            make.left.right.equalToSuperview()
//            make.height.equalTo(36)
//        }
//        self.instranceScreenView.snp.makeConstraints { (make) in
//            make.edges.equalTo(self.fundRateScreeningView)
//        }
       
        self.contentScrollView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(self.view)
        }
    }
}

extension EXContranctInfoDetailVc {
    
    private func p_selectedFundRateButton() {
        
//        if !fundRateSelectButton.isSelected {
//            fundRateSelectButton.isSelected = true
//            insuranceFundSelectButton.isSelected =  false
//            self.insuranceFundSelectButton.titleLabel?.font = UIFont.ThemeFont.HeadRegular
//            self.fundRateSelectButton.titleLabel?.font = UIFont.ThemeFont.H1Bold
//            self.fundRateSelectButton.snp_updateConstraints { (make) in
//
//                make.height.equalTo(40)
//
//            }
//            self.insuranceFundSelectButton.snp_updateConstraints { (make) in
//
//                make.height.equalTo(28)
//                make.top.equalTo(22)
//            }
            page = 1
//            updateSwapScreeningView()
            requestFundingRateList()
//        }
    }
    
    private func p_selectedInsuranceFundButton() {
        
//        if !insuranceFundSelectButton.isSelected {
//            insuranceFundSelectButton.isSelected = true
//            fundRateSelectButton.isSelected = false
//            self.insuranceFundSelectButton.titleLabel?.font = UIFont.ThemeFont.H1Bold
//            self.fundRateSelectButton.titleLabel?.font = UIFont.ThemeFont.HeadRegular
//            self.insuranceFundSelectButton.snp_updateConstraints { (make) in
//
//                make.height.equalTo(40)
//                make.top.equalTo(10)
//            }
//            self.fundRateSelectButton.snp_updateConstraints { (make) in
//
//                make.height.equalTo(28)
//            }
            page = 1
//            updateSwapScreeningView()
            requestInstruceInfoData()
//        }
    }
    
    @objc func clickInsuranceFundButton() {

        p_selectedInsuranceFundButton()
        
//        self.contentScrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    }
    
    @objc func clickFundRateButton() {
        
        p_selectedFundRateButton()
        
//        self.contentScrollView.setContentOffset(CGPoint(x: self.contentScrollView.width, y: 0), animated: true)
    }
}



