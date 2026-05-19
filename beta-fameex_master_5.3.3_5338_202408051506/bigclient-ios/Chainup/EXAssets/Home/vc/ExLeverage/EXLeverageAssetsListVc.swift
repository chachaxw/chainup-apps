
//
//  EXLeverageAssetsListVc.swift
//  Chainup
//
//  Created by ljw on 2023/11/4.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import JXPagingView
import EXKit
class EXLeverageAssetsListVc: EXAssetBaseVc {
    @IBOutlet weak var tableView: UITableView!
    let toolbarHeader:EXAccountTableHeader = EXAccountTableHeader()
    let searchHeader:EXAssetSearchHeader = EXAssetSearchHeader()
    var assetVm:EXAssetsVm = EXAssetsVm()
    var accountModel:EXCommonAssetModel = EXCommonAssetModel()
    var searchotcRstModels:[EXLeverageCoinMapItem] = []
    var hideotcRstModels:[EXLeverageCoinMapItem] = []
    var searchkey:String = ""
    let LeverageVm = EXOTCVm.init()
    var hideZeroBalance:Bool = false
    var originDataArr = [EXLeverageCoinMapItem]()//The most primitive data
    var resultArr = [EXLeverageCoinMapItem]()//Real display data after searching or hiding
    override func viewDidLoad() {
        super.viewDidLoad()
        handleToolbar()
        bindSearch(searchHeader.searchBar, searchHeader.checkBox, .leverage)
        setupCell()
        loadData()
        self.tableView.reloadData()
        
        tableView.mj_header = EXRefreshHeaderView (refreshingBlock: {[weak self] in
            guard let mySelf = self else{return}
            mySelf.loadData()
        })
    }

    override func viewWillAppear(_ animated: Bool) {
           super.viewWillAppear(animated)
            loadData()
           if searchHeader.checkBox != nil {
            self.reloadZeroAccountSetting(searchHeader.checkBox)
           }
       }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.global().asyncAfter(deadline: DispatchTime.now()+0.5) { [weak self] in
            self?.loadData()
        }
    }
    override func updatePrivacy() {
        toolbarHeader.assetsInfoView.bindAssetModel(self.accountModel)
        if self.tableView != nil  {
            self.tableView.reloadData()
        }
    }

}
extension EXLeverageAssetsListVc {
    func loadData() {
        //Obtaining leverage
        if XUserDefault.isOffLine(){
            return
        }
        let manager = EXAccountBalanceManager.manager
        manager.updateLeverAccountBalance()
        manager.leverAccountModelCallback = {[weak self] accountModel in
            self?.handleLeverageAssets(accountModel)
        }
        
        manager.doRequestCompleted = { [weak self] () in
             self?.tableView.mj_header.endRefreshing()
         }
    }
    func handleLeverageAssets(_ model:EXLeverageAccountListModel) {
        let assetModel = EXCommonAssetModel()
        assetModel.totalBalance = model.netAssetBalance.formatAmountUseDecimal("8")
        assetModel.totalBalanceSymbol = model.totalBalanceSymbol
        assetModel.assetType = .leverage
        self.accountModel = assetModel
        self.originDataArr = model.leverCoinMapListArr
        EXLeverageAccountListModel.shareInstance.memoryLeverCoinMapListArr = self.originDataArr
        self.resultArr = self.originDataArr

        let hideZeroBalance = XUserDefault.zeroAssetsSetting()
        self.assetVm.reloadZeroAccountSetting(searchHeader.checkBox)
        self.hideZeroBalance(hideZeroBalance, .leverage)

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() , execute: {
            self.tableView.reloadData()
            self.onAssetupdate?(assetModel)
            
            assetModel.title = "assets_margin_account_value".localized()
            self.toolbarHeader.assetsInfoView.bindAssetModel(assetModel)
        })

    }
        func filterZeroOTCs(source:[EXLeverageCoinMapItem]) ->[EXLeverageCoinMapItem] {
            var filterResult: [EXLeverageCoinMapItem] = []
            for coinMapModel in source {
                let balance = coinMapModel.symbolBalance as NSString
                if balance.isBig(limitValue()) {
                    filterResult.append(coinMapModel)
                }
            }
            return filterResult
        }

        private func searchFor(key:String,type:EXAccountType) {
            searchotcRstModels.removeAll()
            searchkey = key
            if key.isEmpty {
                if hideZeroBalance {
                    self.hideZeroBalance(true, .leverage)
                }else {
                    self.resultArr = originDataArr
                }
            }else {
                var searchResult: [EXLeverageCoinMapItem] = []
                for coinMapModel in originDataArr {
                    if let _ = coinMapModel.name.aliasCoinMapName().range(of: key, options:.caseInsensitive, range: nil, locale: nil) {
                        searchResult.append(coinMapModel)
                    }
                }
                searchotcRstModels = hideZeroBalance ? self.filterZeroOTCs(source: searchResult) : searchResult
                self.resultArr = searchotcRstModels
            }
            tableView.reloadData()
        }

        func limitValue() -> String {
            return String.limitSatoshi()
        }

        private func hideZeroBalance(_ isHide:Bool, _ type:EXAccountType) {
            hideotcRstModels.removeAll()
            hideZeroBalance = isHide
            XUserDefault.switchZeroAssets(isHide)
            let baseModels = searchotcRstModels.count > 0 ? searchotcRstModels : originDataArr

            if isHide {
                var searchResult: [EXLeverageCoinMapItem] = []
                for coinMapModel in baseModels {
                    let balance = coinMapModel.symbolBalance as NSString
                    if balance.isBig(limitValue()) {
                        searchResult.append(coinMapModel)
                    }
                }
                hideotcRstModels = searchResult
                self.resultArr = searchResult
            }else {
                self.searchFor(key: self.searchkey, type: .leverage )
            }
            tableView.reloadData()
        }

        func gotoBorrow() {
            let searchVc = EXLeverageCoinSearchVc.init(nibName: "EXLeverageCoinSearchVc", bundle: nil)
                    searchVc.type = .borrow
            searchVc.isfromAsset = true
            self.navigationController?.pushViewController(searchVc, animated: true)
        }
     
        func gotoTransfer() {
            let searchVc = EXLeverageCoinSearchVc.init(nibName: "EXLeverageCoinSearchVc", bundle: nil)
                           searchVc.type = .transfer
            searchVc.isfromAsset = true
            self.navigationController?.pushViewController(searchVc, animated: true)
        }
    
         //Leverage
        func handleLeverageSheetAction(itemAction:EXAssetToolBarAction) {
            let flag = UserDefaults.standard.bool(forKey: "EXLeverageAlertView")
            if itemAction == .borrow {//Lending
                if !flag && EXAppConfigManager.sharedInstance.getLeverProtocolURL().count > 0{
                    let alertView = EXLeverageAlertView.show()
                    alertView?.confirmBlock = {
                        self.gotoBorrow()
                    }
                }else {
                    gotoBorrow()
                }
            }else if itemAction == .transfer {//Transfer
              if !flag && EXAppConfigManager.sharedInstance.getLeverProtocolURL().count > 0{
                  let alertView = EXLeverageAlertView.show()
                  alertView?.confirmBlock = {
                      self.gotoTransfer()
                  }
              }else {
                  gotoTransfer()
              }
            }else if itemAction == .journalAccount {//Capital flow
               let journalVc = EXLeverageJournalVc.init(nibName: "EXLeverageJournalVc", bundle: nil)
                self.navigationController?.pushViewController(journalVc, animated: true)
            }
        }
       func reloadZeroAccountSetting(_ checkBox:EXCheckBox) {
              let setting = XUserDefault.zeroAssetsSetting()
              checkBox.checked(check:setting)
        }

      func bindSearch(_ textField:UITextField, _ checkBox:EXCheckBox, _ type:EXAccountType) {
          reloadZeroAccountSetting(checkBox)
          textField.rx.text.orEmpty.asObservable()
              .distinctUntilChanged()
              .subscribe(onNext:{[weak self] text in
                  self?.searchFor(key: text, type: type)
              }).disposed(by: self.disposeBag)

          checkBox.rx.checkState.asObservable()
              .distinctUntilChanged()
              .subscribe(onNext:{[weak self] checked in
                  self?.hideZeroBalance(checked,type)
              }).disposed(by: self.disposeBag)
      }
    
        func setupCell() {
            tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
            tableView.register(UINib.init(nibName: "EXLeverageAssetListCell", bundle: nil), forCellReuseIdentifier: "EXLeverageAssetListCell")
            self.tableView.backgroundColor = UIColor.ThemeView.bg
            tableView.estimatedRowHeight = 200;
            tableView.rowHeight = UITableView.automaticDimension;
        }
        func handleToolbar(){
            toolbarHeader.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 163)
            toolbarHeader.toolBar.bindToolBarItems(self.assetVm.getLeverageToolbars())
            toolbarHeader.toolBar.onToolBarSelected = {[weak self] action in
             self?.handleLeverageSheetAction(itemAction: action)
            }
            self.tableView.tableHeaderView = toolbarHeader
        }
}

extension EXLeverageAssetsListVc : UITableViewDelegate,UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = resultArr[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "EXLeverageAssetListCell", for: indexPath) as! EXLeverageAssetListCell
        cell.totalBalanceSymbol = self.accountModel.totalBalanceSymbol
        cell.setModel(model: model)
        return cell
    }

    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return self.searchHeader
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let element = resultArr[indexPath.row]
        let vc = EXCoinBorrowRecordVc.init(nibName: "EXCoinBorrowRecordVc", bundle: nil)
        vc.model = element
        vc.totalBalanceSymbol = self.accountModel.totalBalanceSymbol
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        listViewDidScrollCallback?(scrollView)
    }
}

extension EXLeverageAssetsListVc: JXPagingViewListViewDelegate {
    func listView() -> UIView {
        return self.view
    }
    
    func listScrollView() -> UIScrollView {
        return tableView
    }
    
    func listViewDidScrollCallback(callback: @escaping (UIScrollView) -> ()) {
        listViewDidScrollCallback = callback
    }
}

