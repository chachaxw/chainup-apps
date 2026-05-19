//
//  EXAccountBalanceManager.swift
//  Chainup
//
//  Created by liuxuan on 2023/5/8.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import RxSwift
import Swap
import EXKit
class EXAccountBalanceManager: NSObject {
    
    let disposeBag = DisposeBag()
    var accountModel = EXAccountBalanceModel()
    var otcAccountModel = EXOTCAccountListModel()
    var contractAccountModel = EXContractAccountModel()
    var swapAccountModels : [EXContractAccountModel] = []

    static let `manager` = EXAccountBalanceManager()
    
    var doRequestCompleted: (() -> ())?
    
    typealias AccountModelCallback = (EXAccountBalanceModel) -> ()
    var accountCallback:AccountModelCallback?
    
    typealias OTCAccountModelCallback = (EXOTCAccountListModel) -> ()
    var otcAccountCallback:OTCAccountModelCallback?
    
    typealias ContractAccountModelCallback = (EXContractAccountModel) -> ()
    var contractAccountCallback:ContractAccountModelCallback?
    
    typealias SwapAccountModelCallback = ([EXContractAccountModel]) -> ()
    var swapAccountCallback:SwapAccountModelCallback?
    
    typealias AllAccountModelCallback = (EXHomeAssetModel) -> ()
    var allAccountCallback:AllAccountModelCallback?
    
    typealias LeverAccountModelCallback = (EXLeverageAccountListModel) -> ()
    var leverAccountModelCallback : LeverAccountModelCallback?
    
    override init() {
        
        super.init()
    }
    
    func updateExchangeAccountBalance() {
        self.requestAccountBalance()
    }
    
    func updateOTCAccountBalance() {
        self.requestOtcAccountBalance()
    }
    
    func updateContractAccountBalance() {
        let accounts =  EXAppConfigManager.sharedInstance.getSupportAccounts()
        if accounts.contains(.contract) {
            if EXAppConfigManager.sharedInstance.getContractVersion() == .new {
                swapAccountModels = []
                requestNewCoBalance()
            }else {
                
                self.handleSwapAccountBalance()
            }
        }
    }
    
    func updateAllAccountBalance() {
        self.requestAllBlance()
    }
    
    func updateLeverAccountBalance(){
        self.requestleverAccountBalance()
    }
    
    //Obtain the list data of coins that can be recharged/withdrawn
    func getcoinList(sourceType:EXCoinSearchSourceType, completion: (@escaping (Bool) -> ()) )  {
        if XUserDefault.isOffLine(){
            return
        }
        appApi.hideAutoLoading()
        appApi.rx.request(.accountBalance(coinSymbols: nil))
            .MJObjectMap(EXAccountBalanceModel.self)
            .subscribe{[weak self] event in
                guard let mySelf = self else {return}
                switch event {
                case .success(let model):
                    mySelf.accountModel = model
                    let result = mySelf.hanlleResult(sourceType: sourceType)
                    completion(result)
                    break
                case .failure(_):
                    completion(false)
                    break
                }
            }.disposed(by: self.disposeBag)
    }
    
    
    func hanlleResult(sourceType:EXCoinSearchSourceType) -> Bool{
        let balanceMap = self.accountModel.allCoinMapList
        var result = [EXAccountCoinMapItem]()
        if sourceType == .sourceForDeposit {
            result = balanceMap.filter({ (item) -> Bool in
                return item.depositOpen == "1"
            })
        }else if sourceType == .sourceForWithdraw {
            result = balanceMap.filter({ (item) -> Bool in
                return item.withdrawOpen == "1"
            })
           
        }else if sourceType == .internalTransfer{
            result = balanceMap.filter({ (item) -> Bool in
                return item.isInnerTransferOpen()
            })
        }
        return result.count > 0
    }
}

//Coins
extension EXAccountBalanceManager  {
    private func requestAccountBalance() {
        appApi.hideAutoLoading()
        appApi.rx.request(.accountBalance(coinSymbols: nil))
            .MJObjectMap(EXAccountBalanceModel.self)
            .subscribe{[weak self] event in
                guard let mySelf = self else {return}
                self?.doRequestCompleted?()
                switch event {
                case .success(let model):
                    self?.handleCoinAssets(model)
                        
                    mySelf.updateFuturesIntersectList(originCoList: mySelf.swapAccountModels)
                    break
                case .failure(_):
                    break
                }
            }.disposed(by: self.disposeBag)
    }
    
    private func handleCoinAssets(_ model:EXAccountBalanceModel) {
        self.accountModel = model
        accountCallback?(model)
    }
    
    func getTotalBalance() -> String {
        return self.accountModel.totalBalance
    }
    
    func getTotalBalanceSymbol() ->String {
        return self.accountModel.totalBalanceSymbol
    }
    
    func getAllCoinMapItems()->[EXAccountCoinMapItem] {
        return self.accountModel.allCoinMapList
    }
    
    func getCoinMapItem(_ forSymbol:String)->EXAccountCoinMapItem? {
        for mapItem in self.accountModel.allCoinMapList {
            if mapItem.coinName == forSymbol {
                return mapItem
            }
        }
        return nil
    }
    func getCoAndCoinIntersectList(originCoList:[EXContractAccountModel]) -> [EXContractAccountModel] {
        if self.accountModel.allCoinMapList.count == 0 {
            return originCoList
        }
        var retList = [EXContractAccountModel]()
        for item in originCoList {
            if getCoinMapItem(item.quoteSymbol) != nil {
                retList.append(item)
            }
        }
        return retList
    }
}

extension EXAccountBalanceManager {
   
    
    private func requestNewCoBalance() {
        
        EXContractNetwork.queryUserHasOpenAccount { (hasOpen) in
            
            if hasOpen {
                
                EXContractNetwork.getUserPositionOrAsset(onlyAccount: false, marginCoin: nil) {[weak self] (model) in
                    
                    self?.handleSwapAccountBalance()
                } failure: { (_) in
                    
                }.disposed(by: self.disposeBag)
            }
        }
    }
}

//otc
extension EXAccountBalanceManager  {
    
    private func requestOtcAccountBalance() {
        appApi.hideAutoLoading()
        appApi.rx.request(.financeAccountList)
            .MJObjectMap(EXOTCAccountListModel.self)
            .subscribe{[weak self] event in
                self?.doRequestCompleted?()
                switch event {
                case .success(let model):
                    self?.handleOtcAssets(model)
                    break
                case .failure(_):
                    break
                }
            }.disposed(by: self.disposeBag)
    }
    
    private func handleOtcAssets(_ model:EXOTCAccountListModel) {
        self.otcAccountModel = model
        otcAccountCallback?(model)
    }
    
    func getOtcAccountItem(_ forSymbol:String)->CoinMapItem? {
        for mapItem in self.otcAccountModel.allCoinMap {
            if mapItem.coinSymbol == forSymbol {
                return mapItem
            }
        }
        return nil
    }
    
    func getSwapAccountItem(_ forSymbol:String)->EXContractAccountModel? {
        
        for mapItem in self.swapAccountModels {
             if mapItem.quoteSymbol == forSymbol {
                 return mapItem
             }
         }
         return nil
     }
}

//contract

extension EXAccountBalanceManager {
    
    private func requestContractAccountBalance() {
        contractApi.hideAutoLoading()
        contractApi.rx.request(.accountBalance)
            .MJObjectMap(CommonAryModel.self)
            .subscribe{[weak self] event in
                switch event {
                case .success(let model):
                    self?.handleContractAccount(model)
                    break
                case .failure(_):
                    break
                }
            }.disposed(by: self.disposeBag)
    }
    
    private  func handleContractAccount(_ aryModel:CommonAryModel) {
        //The contract may have multiple accounts, currently only one is used
        var contractItems:[EXContractAccountModel] = []
        for item in  aryModel.dictAry {
            let listItem = EXContractAccountModel.mj_object(withKeyValues: item)
            if let contractItem = listItem {
                contractItems.append(contractItem)
            }
        }
        if contractItems.count > 0 {
            let accountModel = contractItems[0]
            self.contractAccountModel = accountModel
            contractAccountCallback?(accountModel)
        }
    }
    
    private func handleSwapAccountBalance(){
        var contractItems:[EXContractAccountModel] = []

        for item in EXSwapPersonInfo.shared.getAllSwapAssetItem() ?? [] {
            let listItem = EXContractAccountModel()
            listItem.originalCoin = item.originalCoin
            listItem.canUseBalance = item.canUseAmount
            listItem.quoteSymbol = item.coin_code
//            listItem.grantsAmount = item.grantsAmount
//            listItem.canTansfer = item.canTansfer
            contractItems.append(listItem)
        }
        if contractItems.count > 0 {
            updateFuturesIntersectList(originCoList: contractItems)
        }
       
//Print ("contract")
//        for item in contractItems {
//            print("item.originalCoin =>\(item.originalCoin)")
//        }
//        for a in self.accountModel.allCoinMapList{
//            print("a.coinName =>\(a.coinName)")
//        }
        
    }
    
    //Obtain the intersection of coins and contracts
    func updateFuturesIntersectList(originCoList:[EXContractAccountModel]) {
        self.swapAccountModels = getCoAndCoinIntersectList(originCoList: originCoList)
        if self.swapAccountModels.count > 0 {
            self.contractAccountModel = self.swapAccountModels[0]
        }
        swapAccountCallback?(self.swapAccountModels)
    }
}

//total assets
extension EXAccountBalanceManager{
    
    //Obtain all assets
    private func requestAllBlance(){
        appApi.rx.request(AppAPIEndPoint.totalAccountBalanceV5).MJObjectMap(EXHomeAssetModel.self).subscribe(onSuccess: {[weak self] (model) in
            self?.allAccountCallback?(model)
        }) { (error) in
            
            }.disposed(by: disposeBag)
    }
}

//lever
extension EXAccountBalanceManager  {
    
    private func requestleverAccountBalance() {
        appApi.hideAutoLoading()
        appApi.rx.request(.leverageBalance)
            .MJObjectMap(EXLeverageAccountListModel.self)
            .subscribe{[weak self] event in
                self?.doRequestCompleted?()
                switch event {
                case .success(let model):
                    self?.handleLeverAssets(model)
                    break
                case .failure(_):
                    break
                }
            }.disposed(by: self.disposeBag)
    }
    
    private func handleLeverAssets(_ model:EXLeverageAccountListModel) {
        leverAccountModelCallback?(model)
    }
}

