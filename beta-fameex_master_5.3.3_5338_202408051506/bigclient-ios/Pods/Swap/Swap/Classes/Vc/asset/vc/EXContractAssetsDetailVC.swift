//
//  EXContractAssetsDetailVC.swift
//  Chainup
//
//  Created by ZYJ on 2023/11/7.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import EXKit

class EXContractAssetsDetailVC: EXSNavCustomVC,EXEmptyDataSetable {
    
    private let headerCellReUseID = "EXAssetRecordCell_describe_ID"
    private let cellReUseID = "EXAssetRecordCell_ID"
    
    var lastRecordWay: EXSwapTransactionRecordType = .all
    var currentRecordWay : EXSwapTransactionRecordType = .all
    
    var queryModel = EXSQueryTransactionRecordList()
    private var tableViewRowDatas: [EXContractAssetRecordModel] = []
    
    var property = EXContractAssetModel()
    var currentContractsModel : EXContractsModel? {
        return EXSwapPublicInfo.shared.getContractsModelWithMarginCoin(marginCoin: property.symbol)
    }

    var positionArr : [EXSwapPositionModel] = []
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel(text: "newContract_profit_record".ex_localized(), font: UIFont.ThemeFont.HeadBold, textColor: UIColor.ThemeLabel.colorLite, alignment: .left)
        
        return label
    }()
    
    lazy var sectionHeaderView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 52))
        view.backgroundColor = UIColor.ThemeNav.bg
        view.addSubview(self.screeningView)
        let line = UIView()
        line.backgroundColor = UIColor.ThemeView.bgGap
        view.addSubview(line)
        line.snp.makeConstraints { make in
            make.bottom.leading.trailing.equalToSuperview()
            make.height.equalTo(0.5)
        }
        return view
    }()
    
    lazy var screeningView: EXSwapScreeningView = {
        let view = EXSwapScreeningView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 52))
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.centerY.equalToSuperview()
        }
        return view
    }()
    
    lazy var tableHeaderView: ESAssetsDetailSectionHeader = {
        let view = ESAssetsDetailSectionHeader(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 108))
        view.backgroundColor = UIColor.ThemeView.bg
        return view
    }()
    
    lazy var contentTableView: UITableView = {
        let tableView = UITableView(frame: CGRect.zero, style: .plain)
        tableView.ext_SetTableView(self, self)
        tableView.ext_RegistCell([EXContractAssetRecordHeaderCell.classForCoder(),EXContractAssetRecordCell.classForCoder()], [headerCellReUseID,cellReUseID])
        tableView.tableHeaderView = self.tableHeaderView
        
        if #available(iOS 11, *) {
            tableView.estimatedRowHeight = 0
        }
        tableView.mj_header = EXRefreshHeaderView(refreshingBlock: {
            [weak self] in
            guard let mySelf = self else { return }
            mySelf.requestAssetsRecordData(way: mySelf.currentRecordWay)
        })
        let footerView = EXRefreshFooterView(refreshingBlock: {
            [weak self] in
            guard let mySelf = self else { return }
            mySelf.requestAssetsRecordData(way: mySelf.currentRecordWay)
        })
//        footerView.setup()
        
        tableView.mj_footer = footerView
        return tableView
    }()
    /// 获取资金记录 English: /Obtain funding records
    private func requestAssetsRecordData(way: EXSwapTransactionRecordType = .all) {
        let s = property.symbol
        let sym = EXSwapPublicInfo.shared.maiginOrignPair[s] ?? s
        queryModel.type = way.rawValue
        queryModel.symbol = sym
        EXContractNetwork.getTransactionRecordList(model: queryModel) { (recordList) in
            if self.lastRecordWay == self.currentRecordWay {
                self.queryModel.page += 1
                self.tableViewRowDatas += recordList
                if recordList.count < self.queryModel.limit {
                    self.contentTableView.mj_footer.removeFromSuperview()
                }
            }else {
                self.lastRecordWay = self.currentRecordWay
                self.tableViewRowDatas = recordList
            }
            
            self.contentTableView.reloadData()
            
            self.endRefresh()
        } failure: { (error) in
            self.endRefresh()
        }
    }
    
    private func endRefresh() {
        self.contentTableView.mj_header?.endRefreshing()
        self.contentTableView.mj_footer.endRefreshing()
    }
    var vm = EXContractAssetRecordVM()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.contentView.exs_addSubViews([self.contentTableView])
        self.setTitle(property.symbol)
        
        self.initLayout()
        tableHeaderView.updateInfo(property,instrument_id: currentContractsModel?.instrument_id ?? 0)
        self.exEmptyDataSet(self.contentTableView, attributeBlock: { () -> ([EXEmptyDataSetAttributeKeyType : Any]) in
                 return [
                     .verticalOffset:(CGFloat(0)),
                 ]
             })
        contentTableView.mj_header.beginRefreshing()

        var orderTypeArray:[EXSwapTransactionRecordType] {
            return vm.orderTypeArray
        }
        self.screeningView.orderTypeArray = orderTypeArray.map{$0.introduce}
        
        self.screeningView.screeningValueChanged = {[weak self]
            (swapNameIndex: Int, pirceTypeIndex: Int, orderTypeIndex: Int) in
            guard let mySelf = self else { return }
            
            let orderTypeArray = mySelf.vm.orderTypeArray
            var recordWay = EXSwapTransactionRecordType.all
            if orderTypeIndex < orderTypeArray.count {
                
                recordWay = orderTypeArray[orderTypeIndex]
            }

            if recordWay == mySelf.currentRecordWay {
                return
            }
            
            mySelf.currentRecordWay = recordWay
            mySelf.queryModel.page = 1
            mySelf.requestAssetsRecordData(way: mySelf.currentRecordWay)
        }
    }
    override func setNavCustomV() {
        self.navtype = .normal

    }
    
    private func initLayout() {
        self.contentTableView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(self.navCustomView.snp.bottom).offset(18)
        }
    }
}
// MARK: - UITableViewDelegate & UITableViewDataSource

extension EXContractAssetsDetailVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if self.tableViewRowDatas.count > 0 {
            
            return self.tableViewRowDatas.count  //+ 1
        }
        return 0
    }
    //
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
            let cell = tableView.dequeueReusableCell(withIdentifier: cellReUseID, for: indexPath) as! EXContractAssetRecordCell

            let model = self.tableViewRowDatas[indexPath.row]
            cell.setCell(leftTop: model.type,
                         leftBottom: model.contractName,
                         rightTop: model.amount.toValuePrecision(withContract:currentContractsModel?.instrument_id ?? 0),
                         rightBottom: model.timeShow)
           
            return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        return self.sectionHeaderView
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 67
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 52
    }
}

class ESAssetsDetailSectionHeader: UIView {
    /// 账户权益 总资产 English: /Total equity assets of the account
    lazy var accountEquityView: SLSwapVerDetailView = {
        let view = SLSwapVerDetailView()
        view.setTopText("cp_total_asset_str".ex_localized())
        //        view.showDashline = true
        view.clickMiddleBtnBlock = { [weak self] in
            let alert = EXSNormalAlert()
            alert.configSigleAlert(title: "common_text_tip".ex_localized(), message: "contract_equalit_equitytips".ex_localized() )
            EXAlert.showAlert(alertView: alert)
        }
        return view
    }()
    ///可用 English: /Available
    lazy var avivable: SLSwapVerDetailView = {
        let view = SLSwapVerDetailView()
        view.contentAlignment = .right
        view.setTopText("cp_calculator_text43".ex_localized())
        return view
    }()
    /// 冻结保证金 English: /Freeze margin
    lazy var unrealisedPNLView: SLSwapVerDetailView = {
        let view = SLSwapVerDetailView()
        view.setTopText("cp_coaccount_lockmargin".ex_localized())
        return view
        
    }()
    /// 全仓保证金 English: /Full warehouse margin
    lazy var walletBalanceView: SLSwapVerDetailView = {
        let view = SLSwapVerDetailView()
        view.contentAlignment = .center
        view.topLabel.textAlignment = .center
        view.bottomLabel.textAlignment = .center
        view.setTopText("cp_cross_balance_str".ex_localized())
        view.contentAlignment = .center
        
        return view
    }()
    
    /// 逐仓保证金 English: /Margin for each warehouse
    lazy var marginBalanceView: SLSwapVerDetailView = {
        let view = SLSwapVerDetailView()
        view.contentAlignment = .right
        view.setTopText("cp_isolated_balance_str".ex_localized())
        view.topLabel.textAlignment = .right
        view.bottomLabel.textAlignment = .right
        return view
    }()
    
   
    
//    /// 仓位保证金 English: /Position margin
//    lazy var positionMarginView: SLSwapVerDetailView = {
//        let view = SLSwapVerDetailView()
//        view.isHidden = true
//        view.setTopText("contract_text_positionMargin".localized())
//        return view
//    }()
//
//    /// 委托保证金 English: /Entrusted deposit
//    lazy var orderMarginView: SLSwapVerDetailView = {
//        let view = SLSwapVerDetailView()
//        view.setTopText("contract_text_orderMargin".localized())
//        view.topLabel.textAlignment = .right
//        view.bottomLabel.textAlignment = .right
//        view.isHidden = true
//        return view
//    }()
    
    /// 分隔线 English: /Divider line
    lazy var bottomMarginView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.ThemeNav.bg
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.exs_addSubViews([
                accountEquityView, avivable,
                unrealisedPNLView,walletBalanceView,marginBalanceView,
                bottomMarginView]
        )
        
        self.initLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initLayout() {
        let horMargin: CGFloat = 15.0
        let width = (EXSCREEN_WIDTH - horMargin * 2) / 3
        self.accountEquityView.snp.makeConstraints { (make) in
            make.left.equalTo(horMargin)
            make.width.equalTo(width)
            make.height.equalTo(34)
            make.top.equalTo(0)
        }
        
        self.avivable.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-horMargin)
            make.width.equalTo(self.accountEquityView)
            make.height.equalTo(self.accountEquityView)
            make.top.equalTo(self.accountEquityView)
        }
        
        self.unrealisedPNLView.snp.makeConstraints { (make) in
            make.left.equalTo(self.accountEquityView)
            make.width.equalTo(width)
            make.height.equalTo(34)
            make.top.equalTo(self.accountEquityView.snp.bottom).offset(15)
        }
        self.walletBalanceView.snp.makeConstraints { (make) in
            make.left.equalTo(self.unrealisedPNLView.snp.right)
            make.width.equalTo(width)
            make.height.equalTo(self.unrealisedPNLView)
            make.top.equalTo(self.unrealisedPNLView)
        }
        self.marginBalanceView.snp.makeConstraints { (make) in
            make.left.equalTo(self.walletBalanceView.snp.right)
            make.width.equalTo(width)
            make.height.equalTo(self.unrealisedPNLView)
            make.top.equalTo(self.unrealisedPNLView)
        }
       
//        self.positionMarginView.snp.makeConstraints { (make) in
//            make.left.equalTo(self.unrealisedPNLView.snp.right)
//            make.width.equalTo(self.unrealisedPNLView)
//            make.height.equalTo(self.unrealisedPNLView)
//            make.top.equalTo(self.unrealisedPNLView)
//        }
//        self.orderMarginView.snp.makeConstraints { (make) in
//            make.left.equalTo(self.positionMarginView.snp.right)
//            make.width.equalTo(self.positionMarginView)
//            make.height.equalTo(self.positionMarginView)
//            make.top.equalTo(self.positionMarginView)
//        }
        self.bottomMarginView.snp.makeConstraints { (make) in
            make.left.width.bottom.equalToSuperview()
            make.height.equalTo(10)
        }
    }
    
    func updateInfo(_ property : EXContractAssetModel,instrument_id:Int64 = 0) {
        avivable.bottomLabel.text =  property.canUseAmount.toValuePrecision(withContract:instrument_id)
        accountEquityView.bottomLabel.text = property.totalAmount.toValuePrecision(withContract:instrument_id)
        walletBalanceView.bottomLabel.text = property.totalMargin.toValuePrecision(withContract:instrument_id)
        marginBalanceView.bottomLabel.text = property.isolateMargin.toValuePrecision(withContract:instrument_id)
        unrealisedPNLView.bottomLabel.text = property.lockAmount.toValuePrecision(withContract:instrument_id)
    }
}


