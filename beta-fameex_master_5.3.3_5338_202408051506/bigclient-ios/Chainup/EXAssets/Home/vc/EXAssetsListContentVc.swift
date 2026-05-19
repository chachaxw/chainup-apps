//
//  EXAssetsListContentVc.swift
//  Chainup
//
//  Created by liuxuan on 2023/4/27.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import JXPagingView
import EXKit
import Swap
class EXAssetsListContentVc: EXAssetBaseVc,StoryBoardLoadable, EXEmptyDataSetable {
    
    @IBOutlet var coinAssetTable: UITableView!
    let toolbarHeader:EXAccountTableHeader = EXAccountTableHeader()
    let searchHeader:EXAssetSearchHeader = EXAssetSearchHeader()
    var assetVm:EXAssetsVm = EXAssetsVm()
    let otcVm = EXOTCSafetyCheckVm()

    var accountModel:EXCommonAssetModel = EXCommonAssetModel()
    
    override func updatePrivacy() {
        toolbarHeader.assetsInfoView.bindAssetModel(self.accountModel)
        if self.coinAssetTable != nil {
            self.coinAssetTable.reloadData()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if searchHeader.checkBox != nil {
            assetVm.reloadZeroAccountSetting(searchHeader.checkBox)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        handleSearchHeader()
        handleToolbar()
        bindVm()
                
        self.exEmptyDataSet(self.coinAssetTable, attributeBlock: { () -> ([EXEmptyDataSetAttributeKeyType : Any]) in
            return [
                .verticalOffset:(CGFloat(100)),
            ]
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        requestBalalance()
    }
    
    func handleSearchHeader() {
        assetVm.bindSearch(searchHeader.searchBar, searchHeader.checkBox, .coin)
    }
    
    func getPieChartBtn() ->UIButton {
        return toolbarHeader.assetsInfoView.pieChartButton
    }
    
    func handleToolbar(){
        
        var totalHeight: CGFloat = 80
        toolbarHeader.assetsInfoView.isHidden = true
        if (EXAppConfigManager.sharedInstance.getSupportAccounts().count > 1) {
            totalHeight = 163
            toolbarHeader.assetsInfoView.isHidden = false
        }
        toolbarHeader.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: totalHeight)
        toolbarHeader.toolBar.bindToolBarItems(self.assetVm.getExchangeToolbars())
        toolbarHeader.toolBar.onToolBarSelected = {[weak self] action in
            self?.handleToolbarAction(action)
        }
        self.coinAssetTable.tableHeaderView = toolbarHeader
        
        toolbarHeader.assetsInfoView.pieChartButton.rx.tap.subscribe(onNext: { [weak self] in
            guard let self = `self` else { return }
            let pieChartData = self.assetVm.fetchAssetsPieChartData()
            if pieChartData.count > 0 {
                let alert = EXAssetsPieChartAlert()
                alert.setData(pieChartData)
                EXAlert.showAlert(alertView: alert)
            }
            else {
                let alert = EXNormalAlert()
                alert.configSigleAlert(title: nil, message: "assets_balance_zero_tips".localized(), lineHeight: 12)
                EXAlert.showAlert(alertView: alert)
            }
        }).disposed(by: self.disposeBag)
        
        toolbarHeader.assetsInfoView.pieChartButton.isHidden = false
    }
    
    func subSetCoins() -> [String] {
        var subsetCoins:[String] = []
        //Whether there are multiple accounts or one OTC, filter the currency of the OTC
        if EXAppConfigManager.sharedInstance.didOpenFiat() {
            let otccoins = EXAppMarketManager.sharedInstance.getAllOTCCoinList()
            for otcItem in otccoins {
                subsetCoins.append(otcItem.name)
            }
        }else {
            if EXAppConfigManager.sharedInstance.didOpenContract() {
                if let list = EXSwapPersonInfo.shared.getAllSwapAssetItem() {
                    
                    for item in list{
                        if !item.coin_code.isEmpty {
                            subsetCoins.append(item.coin_code.aliasName())
                        }
                    }
                }
            }
        }
        return subsetCoins
    }
    
    func handleToolbarAction(_ action:EXAssetToolBarAction) {
        if action == .transfer {
            let items = self.assetVm.originCoinModels
            if items.count > 0 {
                let subsets = subSetCoins()
                for item in items {
                    if subsets.contains(item.coinName) {
                        assetVm.handleToolbarAction(action, item,self, totalBalanceSymbol: accountModel.totalBalanceSymbol)
                        break
                    }
                }
                //Can't find the fiat currency, can't find the contract, give him leverage
                if subsets.count == 0, EXAppConfigManager.sharedInstance.didOpenLever() {
                    self.gotoLeverTransfer()
                }
            }
        }else {
            if action == .withdraw {
                if otcVm.checkDrawRequireForInternalTransfer(self) == false{
                    return
                }
            }
            let items = self.assetVm.originCoinModels
            if items.count > 0 {
                for item in items {
                    if assetVm.isCoinSupportAction(action, item.coinName) {
                        assetVm.handleToolbarAction(action, item, self, totalBalanceSymbol: accountModel.totalBalanceSymbol)
                        break
                    }
                }
            }
        }
    }
    
    func gotoLeverTransfer() {
        let searchVc = EXLeverageCoinSearchVc.init(nibName: "EXLeverageCoinSearchVc", bundle: nil)
        searchVc.type = .transfer
        self.navigationController?.pushViewController(searchVc, animated: true)
    }
    
    
    func bindVm() {
        self.assetVm.onAssetCallback = {[weak self] accountModel in
            self?.updateBalance(accountModel)
        }
        
        requestBalalance()
        bindTable()
    }
    
    func requestBalalance() {
        if XUserDefault.isOffLine() {
            self.assetVm.coinAssetsList.accept([])
        }else {
            self.assetVm.requestExchangeBalance()
        }
    }
    
    func updateBalance(_ model:EXCommonAssetModel){
        if (model.assetType != .coin){
            //Request after transfer
            return
        }
        self.accountModel = model
        self.onAssetupdate?(model)
        if EXHomeViewModel.isContractStatus() {
            model.title = "onlyCo_assets_text_exchange".localized() + "assets_text_total".localized()
        }else {
            model.title = "assets_crypto_asset_value".localized()
        }
        toolbarHeader.assetsInfoView.bindAssetModel(model)
    }
    
    func bindTable() {
//        coinAssetTable.register(UINib.init(nibName: "EXAssetInfoCell", bundle: nil), forCellReuseIdentifier: "EXAssetInfoCell")
        coinAssetTable.register(UINib.init(nibName: "EXJournalAccountListCell", bundle: nil), forCellReuseIdentifier: "EXJournalAccountListCell")

        coinAssetTable.register(UINib.init(nibName: "EXAssetSearchCell", bundle: nil), forCellReuseIdentifier: "EXAssetSearchCell")
        
        assetVm.coinAssetsList.asDriver()
            .drive(coinAssetTable.rx.items){(tableview,row,element) in
                let cell = tableview.dequeueReusableCell(withIdentifier: "EXJournalAccountListCell", for: IndexPath.init(row: row, section: 0)) as! EXJournalAccountListCell
                cell.bindExchangeModel(element,self.accountModel.totalBalanceSymbol)
                return cell
        }.disposed(by: self.disposeBag)
        
        coinAssetTable.rx.modelSelected(EXAccountCoinMapItem.self).subscribe(onNext: {[weak self] model in
            self?.handleModel(model)
        }).disposed(by: self.disposeBag)
        
        coinAssetTable.mj_header = EXRefreshHeaderView (refreshingBlock: {[weak self] in
            guard let mySelf = self else{return}
            mySelf.requestBalalance()
        })
        
        assetVm.fetchBalanceCompletedSubject.subscribe(onNext: { [weak self] _ in
            self?.coinAssetTable.mj_header.endRefreshing()
        }).disposed(by: self.disposeBag)
    }
    
    func handleModel(_ model:EXAccountCoinMapItem) {
        self.assetVm.handleExActionSheet(inVc: self, model)
    }
}

extension EXAssetsListContentVc : UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let items = assetVm.coinAssetsList.value
        if items.count > indexPath.row {
            let model = items[indexPath.row]
            if EXJournalAccountListCell.hasOverChargeAccount(symbol: model.coinName) {
                return 203
            }
        }
   
        return 152
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return searchHeader
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        listViewDidScrollCallback?(scrollView)
    }
}


extension EXAssetsListContentVc: JXPagingViewListViewDelegate {
    
    func listView() -> UIView {
        return self.view
    }
    
    func listScrollView() -> UIScrollView {
        return coinAssetTable
    }
    
    func listViewDidScrollCallback(callback: @escaping (UIScrollView) -> ()) {
        listViewDidScrollCallback = callback
    }
}

