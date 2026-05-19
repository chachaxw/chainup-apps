//
//  EXJournalVm.swift
//  Chainup
//
//  Created by liuxuan on 2023/5/6.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class JournalCommonSearchModel: NSObject {
    var startTime:String = ""
    var endTime:String = ""
    var symbol:String = ""
    var scene:String = ""
    var contractItem:String = ""//The key for the CVS contract filtering type is passed by default
    var contractChildItem:String = ""//cvs key
}


class EXJournalVm: NSObject {
    let disposeBag = DisposeBag()
    
    let exjournalList = BehaviorRelay<[FinanceItem]>(value: [])
    let otcjournalList  = BehaviorRelay<[FinanceItem]>(value: [])
    let b2cjournalList  = BehaviorRelay<[FinanceItem]>(value: [])
    let contractJournalList  = BehaviorRelay<[ContractTransactionItem]>(value: [])

    typealias SceneCallback = (EXJournalSceneModel) -> ()
    var onSceneCallback:SceneCallback?
    
    var page:Int = 1
    var sceneKey = ""
    var bindTable:UITableView?
    var accountType:EXAccountType = .coin
    
    var commonSearchModel:JournalCommonSearchModel?
    
    func bindTable(_ tableview:UITableView) {
        self.bindTable = tableview
    }
}
extension EXJournalVm {
    func getB2cJournalList(scene:EXJournalListSceneKey,symbol:String,isFirstPage:Bool,startTime : String? = nil , endTime : String? = nil){
        if isFirstPage {
            self.page = 1
        }
        //Recharge
        if scene == EXJournalListSceneKey.deposit{
            appApi.rx.request(AppAPIEndPoint.getFiatDepoistList(symbol: symbol, page: "\(page)", pageSize: "20",startTime:startTime,endTime:endTime) ).MJObjectMap(EXJournalListModel.self).subscribe(onSuccess: {[weak self] (model) in
                self?.setData(model)
            }) {[weak self] (error) in
                self?.endRefresh()
            }.disposed(by: disposeBag)
            //Withdrawal
        }else{
            appApi.rx.request(AppAPIEndPoint.getFiatWithdrawList(symbol: symbol, page: "\(page)", pageSize: "20",startTime:startTime,endTime:endTime)).MJObjectMap(EXJournalListModel.self).subscribe(onSuccess: {[weak self] (model) in
                self?.setData(model)
            }) {[weak self] (error) in
                self?.endRefresh()
                }.disposed(by: disposeBag)
        }
    }


    func setData(_ model : EXJournalListModel){
         if self.page == 1 {
           self.b2cjournalList.accept(model.financeList)
         }else {
           let lists = self.b2cjournalList.value
           self.b2cjournalList.accept(lists + model.financeList)
         }
        self.endRefresh()
        self.page = self.page + 1
        if model.financeList.count < 20 {
            self.bindTable?.mj_footer.endRefreshingWithNoMoreData()
        }
    }
}
// handle otc journal
extension EXJournalVm {
    
    func getOTCJournalList() {
        commonSearchModel = JournalCommonSearchModel()
        commonSearchModel?.scene = EXJournalListSceneKey.otctransfer.rawValue
        self.requestJournalSearch(.otc)
    }
    
    func otcJounralNextPage() {
        self.page += 1
        self.requestJournalSearch(.otc)
    }
    
    func otcJournalRefresh() {
        self.page = 1
        self.requestJournalSearch(.otc)
    }
}

// handle ex journal
extension EXJournalVm {
    
    func getExJournalList() {
        configScenceRequest()
    }
    
    func getSceneList(_ sceneModel:EXJournalSceneModel) {
        self.handleSceneJournalList(sceneModel)
    }
    
    func exJounralNextPage() {
        self.page += 1
        self.requestJournalSearch(self.accountType)
    }
    
    func exJournalRefresh() {
        self.page = 1
        self.requestJournalSearch(self.accountType)
    }
    
    private func configScenceRequest() {
        appApi.hideAutoLoading()
        appApi.rx.request(.transferScene)
            .MJObjectMap(EXJournalSceneModel.self,false)
            .subscribe{[weak self] event in
                switch event {
                case .success(let model):
                    self?.sceneSuceess(model)
                    break
                case .failure(_):
                    break
                }
            }.disposed(by: self.disposeBag)
    }
    
    private func sceneSuceess(_ withModel:EXJournalSceneModel) {
        onSceneCallback?(withModel)
    }
    
    private func handleSceneJournalList(_ model:EXJournalSceneModel) {
        if let sceneitem = model.sceneList.first {
            commonSearchModel = JournalCommonSearchModel()
            commonSearchModel?.scene = sceneitem.key
            self.requestJournalSearch(self.accountType)
        }
    }
    

    func requestJournalSearch(_ forType:EXAccountType)
    {
        guard let scene = commonSearchModel?.scene else {return}
        var symbol = commonSearchModel?.symbol ?? ""
        let entity = EXAppMarketManager.sharedInstance.getCoinEntityWithAliasName(symbol)
        if entity.name != ""{
            symbol = entity.name
        }
        
        appApi.rx.request(.transferList(coinSymbol:symbol,
                                        transactionScene:scene,
                                        startTime: commonSearchModel?.startTime,
                                        endTime: commonSearchModel?.endTime,
                                        page: "\(self.page)"))
            .MJObjectMap(EXJournalListModel.self,false)
            .subscribe{[weak self] event in
                switch event {
                case .success(let listModel):
                    self?.handleJournalList(listModel,forType)
                    break
                case .failure(_):
                    self?.endRefresh()
                    break
                }
            }.disposed(by: self.disposeBag)
    }
    
    
    private func endRefresh() {
        self.bindTable?.mj_header.endRefreshing()
        self.bindTable?.mj_footer.endRefreshing()
    }
    
    private func handleJournalList(_ model:EXJournalListModel, _ type:EXAccountType) {
        self.endRefresh()
        if model.financeList.count < 20 {
            self.bindTable?.mj_footer.endRefreshingWithNoMoreData()
        } else {
            self.bindTable?.mj_footer.resetNoMoreData()
        }
        
        if type == .coin {
            if self.page == 1 {
                self.exjournalList.accept(model.financeList)
            }else {
                let lists = self.exjournalList.value
                self.exjournalList.accept(lists + model.financeList)
            }
        }else if type == .b2c {
//            if self.page == 1 {
//                self.b2cjournalList.accept(model.financeList)
//            }else {
//                let lists = self.b2cjournalList.value
//                self.b2cjournalList.accept(lists + model.financeList)
//            }
        }else if type == .otc {
            if self.page == 1 {
                self.otcjournalList.accept(model.financeList)
            }else {
                let lists = self.otcjournalList.value
                self.otcjournalList.accept(lists + model.financeList)
            }
        }
    }
}


// handle contract journal
extension EXJournalVm {
    
    func contractJounralNextPage() {
        self.page += 1
        self.getContractJournalList()
    }
    
    func contractJournalRefresh() {
        self.page = 1
        self.getContractJournalList()
    }
    
    func getContractJournalList() {
        var scenes = ""
        var childs = ""
        if let searchModel = self.commonSearchModel {
            scenes = searchModel.contractItem
            childs = searchModel.contractChildItem
        }else {
           scenes =  ContractPublicInfoManager.manager.getAllSceneKey()
        }
      
        contractApi.rx.request(.businessTxList(item: scenes,
                                               childItem: childs,
                                               start: commonSearchModel?.startTime,
                                               end: commonSearchModel?.endTime,
                                               pageSize: "20",
                                               page:"\(self.page)"))
            
        .MJObjectMap(EXContractJournalModel.self)
        .subscribe{[weak self] event in
            switch event {
            case .success(let listModel):
                self?.handleContractJournalList(listModel)
                break
            case .failure(_):
                self?.endRefresh()
                break
            }
        }.disposed(by: self.disposeBag)
    }
    
    func handleContractJournalList(_ model:EXContractJournalModel) {
        self.endRefresh()
        if model.transactionsList.count < 20 {
            self.bindTable?.mj_footer.endRefreshingWithNoMoreData()
        }
        if self.page == 1 {
            self.contractJournalList.accept(model.transactionsList)
        }else {
            let lists = self.contractJournalList.value
            self.contractJournalList.accept(lists + model.transactionsList)
        }
    }
}


// handle b2c journal
extension EXJournalVm {
    
//    func getB2CJournalList() {
//        commonSearchModel = JournalCommonSearchModel()
//        commonSearchModel?.scene = EXJournalListSceneKey.otctransfer.rawValue
//        self.requestJournalSearch(.b2c)
//    }
//
}

