//
//  EXBTwoCAssetListVc.swift
//  Chainup
//
//  Created by ljw on 2023/10/22.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit

class EXBTwoCAssetListVc: EXAssetBaseVc {

    @IBOutlet weak var tableView: UITableView!
    let toolbarHeader:EXAccountTableHeader = EXAccountTableHeader()
    let searchHeader:EXAssetSearchHeader = EXAssetSearchHeader()
    var assetVm:EXAssetsVm = EXAssetsVm()
    var accountModel:EXCommonAssetModel = EXCommonAssetModel()
    var searchotcRstModels:[B2CCoinMapItem] = []
    var hideotcRstModels:[B2CCoinMapItem] = []
    var searchkey:String = ""
    let b2cVm = EXOTCVm.init()
    var hideZeroBalance:Bool = false
    var originDataArr = [B2CCoinMapItem]()//The most primitive data
    var resultArr = [B2CCoinMapItem]()//Real display data after searching or hiding
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCell()
        handleToolbar()
        bindSearch(searchHeader.searchBar, searchHeader.checkBox, .b2c)
        loadData()
    }
    override func viewWillAppear(_ animated: Bool) {
           super.viewWillAppear(animated)
          
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
        if self.tableView != nil  {
            self.tableView.reloadData()
        }
    }
}

extension EXBTwoCAssetListVc {
    func loadData() {
        appApi.rx.request(.b2cBalance(symbol: ""))
            .MJObjectMap(EXB2CAccountListModel.self)
            .subscribe{[weak self] event in
                switch event {
                case .success(let model):
                    self?.handleB2cAssets(model)
                    break
                case .failure(_):
                    break
                }
        }.disposed(by: self.disposeBag)
    }
}
extension EXBTwoCAssetListVc {
        private func handleB2cAssets(_ model:EXB2CAccountListModel) {
            EXB2CAccountListModel.shareInstance.allCoinMap = model.allCoinMap
            let assetModel = EXCommonAssetModel()
            assetModel.totalBalance = model.totalBtcValue
            assetModel.totalBalanceSymbol = model.totalBalanceSymbol
            assetModel.assetType = .b2c
            self.accountModel = assetModel
            self.originDataArr = model.allCoinMap
            self.resultArr = self.originDataArr
            
            let hideZeroBalance = XUserDefault.zeroAssetsSetting()
            self.assetVm.reloadZeroAccountSetting(searchHeader.checkBox)
            self.hideZeroBalance(hideZeroBalance, .b2c)
           
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() , execute: {
                self.tableView.reloadData()
                self.onAssetupdate?(assetModel)
            })
            
        }
        func filterZeroOTCs(source:[B2CCoinMapItem]) ->[B2CCoinMapItem] {
            var filterResult: [B2CCoinMapItem] = []
            for coinMapModel in source {
                let balance = coinMapModel.btcValue as NSString
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
                    self.hideZeroBalance(true, .otc)
                }else {
                    self.resultArr = originDataArr
                }
            }else {
                var searchResult: [B2CCoinMapItem] = []
                for coinMapModel in originDataArr {
                    if let _ = coinMapModel.symbol.range(of: key, options:.caseInsensitive, range: nil, locale: nil) {
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
                var searchResult: [B2CCoinMapItem] = []
                for coinMapModel in baseModels {
                    let balance = coinMapModel.btcValue as NSString
                    if balance.isBig(limitValue()) {
                        searchResult.append(coinMapModel)
                    }
                }
                hideotcRstModels = searchResult
                self.resultArr = searchResult
            }else {
                self.searchFor(key: self.searchkey, type: .otc )
            }
            tableView.reloadData()
        }
       
        func handleB2CActionSheet(inVc:UIViewController, _ selectedItemModel:B2CCoinMapItem) {
            if selectedItemModel.withdrawOpen == "0" && selectedItemModel.depositOpen == "0"{
                return
            }
            let sheetsItem = self.getB2CSheets(selectedItemModel: selectedItemModel)
            var titles:[String] = []
            for sheet in sheetsItem {
                titles.append(sheet.title)
            }
            let sheet = EXOldActionSheetView()
            sheet.configButtonTitles(buttons: titles)
            sheet.actionIdxCallback = {[weak self] tag in
                let item = sheetsItem[tag]
                self?.handleB2CSheetAction(itemAction: item.action, selectedModel: selectedItemModel)
            }
            EXAlert.showSheet(sheetView:sheet)
        }
    func handleB2CSheetAction(itemAction:EXAssetToolBarAction,selectedModel:B2CCoinMapItem) {
            if itemAction == .B2CRecharge {
                if UserInfoEntity.sharedInstance().didpassRealName() == false {
                    b2cVm.b2cRealNameSet(self, typeStr: "kyc_page_require_identity".localized())
                    return;
                }
                if selectedModel.depositOpen == "0" {
                    return
                }
                let vc = EXBtoCrechargeVC()
                vc.entity = selectedModel
                self.navigationController?.pushViewController(vc, animated: true)
            }else if itemAction == .B2CWithdraw {
                if UserInfoEntity.sharedInstance().didpassRealName() == false {
                    b2cVm.b2cRealNameSet(self, typeStr: "kyc_page_require_identity".localized())
                    return;
                }
                if selectedModel.withdrawOpen == "0" {
                    return
                }
                let vc = EXBtoCWithDrawVC()
                vc.entity = selectedModel
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        func getB2CSheets(selectedItemModel:B2CCoinMapItem) ->[EXAssetToolBarItem] {
            var items = [EXAssetToolBarItem]()
            if selectedItemModel.depositOpen == "1" {
                //Enable coin charging
                  let item = EXAssetToolBarItem()
                  item.action = .B2CRecharge
                  item.title = "assets_action_chargeCoin".localized()
                  items.append(item)
            }
            if selectedItemModel.withdrawOpen == "1" {
               //Enable coin withdrawal
                 let itemB = EXAssetToolBarItem()
                 itemB.action = .B2CWithdraw
                 itemB.title = "assets_action_withdraw".localized()
                 items.append(itemB)
            }
            return items
        }
         //B2C
        func handleB2CSheetAction(itemAction:EXAssetToolBarAction) {
            
            if itemAction == .B2CRecharge {//Recharge
                if UserInfoEntity.sharedInstance().didpassRealName() == false {
                    
                    b2cVm.b2cRealNameSet(self, typeStr: "kyc_page_require_identity".localized())
                    return;
                }
               let searchVc = EXCoinSearchListVc.instanceFromStoryboard(name: StoryBoardNameAsset)
                searchVc.subsetCoinAccountType = .b2c
                searchVc.sourceType = .sourceForDeposit
                searchVc.needPush = true
                self.navigationController?.pushViewController(searchVc, animated: true)
            }else if itemAction == .B2CWithdraw {//Withdrawal of currency
                if UserInfoEntity.sharedInstance().didpassRealName() == false {
                    b2cVm.b2cRealNameSet(self, typeStr: "kyc_page_require_identity".localized())
                    return;
                }
               let searchVc = EXCoinSearchListVc.instanceFromStoryboard(name: StoryBoardNameAsset)
               searchVc.subsetCoinAccountType = .b2c
               searchVc.sourceType = .sourceForWithdraw
               searchVc.needPush = true
               self.navigationController?.pushViewController(searchVc, animated: true)
            }else if itemAction == .B2CJournalAccount {//Capital flow
                let journalVc = EXJournalAccountVc.instanceFromStoryboard(name: StoryBoardNameAsset)
                journalVc.assetType = .b2c
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
            tableView.register(UINib.init(nibName: "EXAssetInfoCell", bundle: nil), forCellReuseIdentifier: "EXAssetInfoCell")
            tableView.separatorStyle = UITableViewCell.SeparatorStyle.none

        }
        func handleToolbar(){
            toolbarHeader.frame = CGRect(x: 0, y: 0, width: Device_W, height: 103)
            toolbarHeader.toolBar.bindToolBarItems(self.assetVm.getB2CToolbars())
            toolbarHeader.toolBar.onToolBarSelected = {[weak self] action in
             self?.handleB2CSheetAction(itemAction: action)
            }
            self.tableView.tableHeaderView = toolbarHeader
        }
}
extension EXBTwoCAssetListVc : UITableViewDelegate,UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultArr.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let element = resultArr[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "EXAssetInfoCell", for: indexPath) as! EXAssetInfoCell
        cell.bindB2CInfo(element,self.accountModel.totalBalanceSymbol)
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return self.searchHeader
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let element = resultArr[indexPath.row]
        self.handleB2CActionSheet(inVc: self, element)
    }
}

