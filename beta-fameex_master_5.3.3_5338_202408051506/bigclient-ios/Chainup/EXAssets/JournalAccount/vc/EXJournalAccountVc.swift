//
//  EXJournalAccountVc.swift
//  Chainup
//
//  Created by liuxuan on 2023/5/6.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit

class EXJournalAccountVc: BaseVC,StoryBoardLoadable,NavigationPlugin,EXEmptyDataSetable {

    @IBOutlet var journalTable: UITableView!
    @IBOutlet var topConstraint: NSLayoutConstraint!
    
    var sceneModel:EXJournalSceneModel?
    var selectScene:EXSceneItem = EXSceneItem()
    var page:Int = 1
    var assetType:EXAccountType?
    var journalVm:EXJournalVm = EXJournalVm()
    let filter = EXFilterView()
    var filterParam = [String:String]()
    var sceneKey = ""
    var symbol = ""//Used for B2C
    
    internal lazy var navigation : EXNavigation = {
        let nav =  EXNavigation.init(affectScroll: journalTable, presenter: self)
        nav.isLastNavigationStyle = true
        return nav
    }()
    
    func configNavigation(){
        
        self.navigation.setdefaultType(type: .list)
        if let accountType = self.assetType {
            if accountType == .contract {
                self.navigation.setTitle(title: "assets_action_contractNote".localized())
            }else {
                self.navigation.setTitle(title: "assets_action_journalaccount".localized())
            }
        }else {
            self.navigation.setTitle(title: "assets_action_journalaccount".localized())
        }
        self.navigation.configRightItems(["public_filter"])
        self.navigation.rightItemCallback = {[weak self] tag in
            self?.handleFilterAction()
        }
        
        let btn = self.navigation.rightItems.last
        btn?.setEnlargeEdgeWithTop(10, left: 60, bottom: 10, right: 20)
    }
    
    func handleFilterAction() {
        
        if filter.isShow {
            filter.dismissFilter()
        }
        else {
            guard let accountType = self.assetType else {return}
            if accountType == .coin {
                guard let _ = self.sceneModel else {return}
            }
            if filter.isShow {
                return
            }
            filter.delegate = self
            filter.filterParams = self.filterParam
            filter.show(inView: self.view)
        }
        
    }
    
    func configTableView() {
        self.journalTable.register(UINib.init(nibName: "EXJournalAccountListCell", bundle: nil), forCellReuseIdentifier: "EXJournalAccountListCell")
        self.journalTable.register(EXJournalAccountOtcListCell.self, forCellReuseIdentifier: "EXJournalAccountOtcListCell")
        self.journalTable.register(EXAssetsHistoryCell.self, forCellReuseIdentifier: "EXAssetsHistoryCell")
        if let scene = self.assetType,scene == .coin{
            self.journalTable.estimatedRowHeight = 106
            self.journalTable.rowHeight = UITableView.automaticDimension
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configNavigation()
        configTableView()
        configRefresh()
        configJournalList()
        navigation.bindFilter(filter: filter)
        self.exEmptyDataSet(self.journalTable, attributeBlock: { () -> ([EXEmptyDataSetAttributeKeyType : Any]) in
            return [
                .verticalOffset:0,
            ]
        })
    }
    
    func updateSelectScene(_ model:EXSceneItem) {
        self.selectScene = model
        self.sceneKey = model.key
    }
    
    private func handleRefresh() {
        guard let scene = self.assetType else {return}
        if scene == .contract {
            journalVm.contractJournalRefresh()
        }else if scene == .b2c {
            if self.sceneKey == EXJournalListSceneKey.withdraw.rawValue {
              self.journalVm.getB2cJournalList(scene: EXJournalListSceneKey.withdraw, symbol: self.symbol, isFirstPage: true,startTime: self.journalVm.commonSearchModel?.startTime ?? "",endTime: self.journalVm.commonSearchModel?.endTime ?? "")
            }else {
              self.journalVm.getB2cJournalList(scene: EXJournalListSceneKey.deposit, symbol: self.symbol, isFirstPage: true,startTime: self.journalVm.commonSearchModel?.startTime ?? "",endTime: self.journalVm.commonSearchModel?.endTime ?? "")
            }
        }else {
            journalVm.exJournalRefresh()
        }
    }
    
    private func handleNextPage() {
        guard let scene = self.assetType else {return}
        if scene == .contract {
            journalVm.contractJounralNextPage()
        }else if scene == .b2c {
            if self.sceneKey == EXJournalListSceneKey.withdraw.rawValue {
              self.journalVm.getB2cJournalList(scene: EXJournalListSceneKey.withdraw, symbol: self.symbol, isFirstPage: false,startTime: self.journalVm.commonSearchModel?.startTime ?? "",endTime: self.journalVm.commonSearchModel?.endTime ?? "")
            }else {
              self.journalVm.getB2cJournalList(scene: EXJournalListSceneKey.deposit, symbol: self.symbol, isFirstPage: false,startTime: self.journalVm.commonSearchModel?.startTime ?? "",endTime: self.journalVm.commonSearchModel?.endTime ?? "")
            }
        }else {
            journalVm.exJounralNextPage()
        }
    }
    
    func configRefresh(){
        self.journalTable.mj_header = EXRefreshHeaderView (refreshingBlock: {[weak self] in
            guard let mySelf = self else{return}
            mySelf.handleRefresh()
        })
        
        self.journalTable.mj_footer = EXRefreshFooterView (refreshingBlock: {[weak self] in
            guard let mySelf = self else{return}
            mySelf.handleNextPage()
        })
        
        self.journalVm.bindTable(self.journalTable)
    }
    
    
    func journalAccountDetail (_ model:FinanceItem) {
        if self.assetType == .b2c {
              let detail = EXBTwoCJournalDetailVc.init(nibName: "EXBTwoCJournalDetailVc", bundle: nil)
              detail.financeItem = model
              detail.sceneKey = self.sceneKey
              detail.onCancelSuccessCallback = {[weak self] in
                guard let mySelf = self else {
                    return
                }
                  if mySelf.sceneKey == EXJournalListSceneKey.withdraw.rawValue {
                    mySelf.journalVm.getB2cJournalList(scene: EXJournalListSceneKey.withdraw, symbol: mySelf.symbol, isFirstPage: true,startTime: mySelf.journalVm.commonSearchModel?.startTime ?? "",endTime: mySelf.journalVm.commonSearchModel?.endTime ?? "")
                  }else {
                    mySelf.journalVm.getB2cJournalList(scene: EXJournalListSceneKey.deposit, symbol: mySelf.symbol, isFirstPage: true,startTime: mySelf.journalVm.commonSearchModel?.startTime ?? "",endTime: mySelf.journalVm.commonSearchModel?.endTime ?? "")
                  }
              }
              self.navigationController?.pushViewController(detail, animated: true)
        }else {
            //product delete
//               let detail = EXJournalAccountDetailVc.instanceFromStoryboard(name: StoryBoardNameAsset)
//               detail.financeItem = model
//               detail.sceneKey = self.sceneKey
//               detail.onCancelSuccessCallback = {[weak self] in
//                   self?.reloadJournalList()
//               }
//               self.navigationController?.pushViewController(detail, animated: true)
        }
       
    }
    
    func reloadJournalList() {
        self.journalTable.mj_header.beginRefreshing()
    }
    
    func handleScene(_ model:EXJournalSceneModel) {
        self.sceneModel = model
        self.configFirstSceneModel()
        self.journalVm.getSceneList(model)
    }
    
    func configFirstSceneModel() {
        guard let rstSceneModel = self.sceneModel else {
            return
        }
        if rstSceneModel.sceneList.count > 0 {
            let model = rstSceneModel.sceneList.first!
            self.updateSelectScene(model)
        }
    }
    
    func updateSceneItem(_ key:String ) {
        guard let rstSceneModel = self.sceneModel else {
            return
        }
        if rstSceneModel.sceneList.count > 0 {
            for sceneItem in rstSceneModel.sceneList {
                if sceneItem.key == key {
                    self.updateSelectScene(sceneItem)
                }
            }
        }
    }
    //Direct push
    func configJournalList() {
        guard let scene = self.assetType else {return}
        if scene == .coin {
            self.journalVm.getExJournalList()
            journalVm.onSceneCallback = {[weak self] model in
                self?.handleScene(model)
            }
            
            journalVm.exjournalList.asDriver()
                .drive(journalTable.rx.items){(tableview,row,element) in
                    let cell = tableview.dequeueReusableCell(withIdentifier: "EXAssetsHistoryCell", for: IndexPath.init(row: row, section: 0)) as! EXAssetsHistoryCell
                    element.transactionScene = self.selectScene.key_text
                    cell.bindContainerModel(element,.coin,self.selectScene.key_text)
                    return cell
                }.disposed(by: self.disposeBag)
            
            journalTable.rx.modelSelected(FinanceItem.self)
                .subscribe(onNext: {[weak self] model in
                    self?.journalAccountDetail(model)
            }).disposed(by: self.disposeBag)
            
        }else if scene == .b2c {
            self.journalVm.accountType = .b2c
            self.sceneKey = EXJournalListSceneKey.deposit.rawValue
            self.journalVm.getB2cJournalList(scene: EXJournalListSceneKey.deposit, symbol: "", isFirstPage: true)
//            journalVm.onSceneCallback = {[weak self] model in
//                self?.handleScene(model)
//            }
            
            journalVm.b2cjournalList.asDriver()
                .drive(journalTable.rx.items){(tableview,row,element) in
                    let cell = tableview.dequeueReusableCell(withIdentifier: "EXJournalAccountListCell", for: IndexPath.init(row: row, section: 0)) as! EXJournalAccountListCell
                    var title = ""
                    if self.sceneKey == EXJournalListSceneKey.withdraw.rawValue {
                        title = "b2c_text_withdraw".localized()
                    }else {
                        title = "b2c_text_recharge".localized()
                    }
                    cell.bindContainerModel(element,.b2c,title)
                    return cell
                }.disposed(by: self.disposeBag)
            
            journalTable.rx.modelSelected(FinanceItem.self)
                .subscribe(onNext: {[weak self] model in
                    self?.journalAccountDetail(model)
            }).disposed(by: self.disposeBag)
            
        }else if scene == .otc {
            self.sceneKey = EXJournalListSceneKey.otctransfer.rawValue
            self.journalVm.getOTCJournalList()
            journalVm.otcjournalList.asDriver()
                .drive(journalTable.rx.items){(tableview,row,element) in
                    let cell = tableview.dequeueReusableCell(withIdentifier: "EXJournalAccountOtcListCell", for: IndexPath.init(row: row, section: 0)) as! EXJournalAccountOtcListCell
                    cell.bindContainerModel(element)
                    return cell
                }.disposed(by: self.disposeBag)
            
            journalTable.rx.modelSelected(FinanceItem.self)
                .subscribe(onNext: {[weak self] model in
                    self?.journalAccountDetail(model)
                }).disposed(by: self.disposeBag)
            
        }else {
            self.journalVm.getContractJournalList()
            self.journalVm.contractJournalList.asDriver()
                .drive(journalTable.rx.items){(tableview,row,element) in
                    let cell = tableview.dequeueReusableCell(withIdentifier: "EXJournalAccountListCell", for: IndexPath.init(row: row, section: 0)) as! EXJournalAccountListCell
                    cell.bindContractModel(element)
                    return cell
                }.disposed(by: self.disposeBag)

        }
    }
    
    func largeTitleValueChanged(height: CGFloat) {
        topConstraint.constant = height
    }
    
}

extension EXJournalAccountVc : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let scene = self.assetType else {return 106}
        if scene == .contract {
            return 152
        }else if scene == .coin{
            return UITableView.automaticDimension
        }else {
            return 106
        }
       
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
}

extension EXJournalAccountVc :EXFilterViewDelegate  {
    
    func inputModel() ->EXFilterDataModel {
        return EXFilterDataModel.getInputModel(key: "coinSymbol", title: "common_text_coinsymbol".localized(), placeHolder:"market_search_ex".localized(), unit: "")
    }
    
    func journalTypeModel() ->EXFilterDataModel {
        guard let rstSceneModel = self.sceneModel else {
            return  EXFilterDataModel.getFoldModel(key: "transactionScene", title: "common_type".localized(), contents: [])
        }
        
        var keys:[String] = []
        var values:[String] = []
        
        for item in rstSceneModel.sceneList {
            keys.append(item.key)
            values.append(item.key_text)
        }
        
        let folditems = EXFilterItem.getItem(titles: values, valueKeys: keys)
        let fold = EXFilterDataModel.getFoldModel(key: "transactionScene", title: "common_type".localized(), contents: folditems)
        return fold
    }
    
    func dateModel() -> EXFilterDataModel {
        let dateModel = EXFilterDataModel.getDateModel(beginDateKey: "startTime", endDateKey: "endTime", title: "charge_text_date".localized())
        return dateModel
    }
    
    
    func filterDataSource() -> [EXFilterDataModel] {
        guard let accountType = self.assetType else {return []}
        if accountType == .coin {
            let input = self.inputModel()
            let folds = self.journalTypeModel()
            let date = self.dateModel()
            return [input,folds,date]
        }else if accountType == .b2c {
            let input = self.inputModel()
            let date = self.dateModel()
//            var childTitles:[String] = ["common_action_sendall".localized()]
//            var childKeys:[String] = ["ALL"]
            var childTitles:[String] = [String]()
            var childKeys:[String] = [String]()
            childKeys.append(EXJournalListSceneKey.deposit.rawValue)
            childTitles.append("assets_action_chargeCoin".localized())
            childKeys.append(EXJournalListSceneKey.withdraw.rawValue)
            childTitles.append("assets_action_withdraw".localized())
            let folditems = EXFilterItem.getItem(titles: childTitles, valueKeys:childKeys)
            let fold = EXFilterDataModel.getFoldModel(key: "transactionScene", title: "common_type".localized(), contents: folditems)
            return [input,fold,date]
        } else if accountType == .otc{
            let input = self.inputModel()
            let date = self.dateModel()
            let folditems = EXFilterItem.getItem(titles: ["transfer_text_otc".localized()], valueKeys:[EXJournalListSceneKey.otctransfer.rawValue])
            
            let fold = EXFilterDataModel.getFoldModel(key: "transactionScene", title: "common_type".localized(), contents: folditems)
            return [input,fold,date]
        } else if accountType == .contract {
            let scenes = ContractPublicInfoManager.manager.getsceneLists()
            var dataModels:[EXFilterDataModel] = []
            for scene in scenes {
                var childTitles:[String] = ["common_action_sendall".localized()]
                var childKeys:[String] = ["ALL"]
                for child in scene.childItem {
                    childTitles.append(child.langTxt)
                    childKeys.append(child.item)
                }
                let folditems = EXFilterItem.getItem(titles: childTitles, valueKeys:childKeys)
                let fold = EXFilterDataModel.getFoldModel(key: scene.item, title: scene.langTxt, contents: folditems)
                dataModels.append(fold)
            }
            let dateModel = self.dateModel()
            dataModels.append(dateModel)
            return dataModels
        }
        return []
    }
    
    func filterConfirm(params: [String : String]) {
        self.filterParam = params
        if self.assetType! == .coin {
            if let scene = params["transactionScene"] {
                self.sceneKey = scene
                self.updateSceneItem(scene)
                let temp = JournalCommonSearchModel()
                var symbol = params["coinSymbol"] ?? ""
                let entity = EXAppMarketManager.sharedInstance.getCoinMapEntityByAliaName(symbol)
                if entity.name != "" {
                    symbol = entity.symbol
                }
                temp.endTime = params["endTime"] ?? ""
                temp.startTime =  params["startTime"] ?? ""
                temp.scene =  scene
                temp.symbol = symbol
                journalVm.commonSearchModel = temp
                journalVm.exJournalRefresh()
            }
        }else if self.assetType! == .b2c {
            if let scene = params["transactionScene"] {
                self.sceneKey = scene
                self.updateSceneItem(scene)
                let temp = JournalCommonSearchModel()
                temp.endTime = params["endTime"] ?? ""
                temp.startTime =  params["startTime"] ?? ""
                temp.scene =  scene
                temp.symbol = params["coinSymbol"] ?? ""
                self.symbol = temp.symbol
                journalVm.commonSearchModel = temp
                if self.sceneKey == EXJournalListSceneKey.withdraw.rawValue {
                    journalVm.getB2cJournalList(scene: EXJournalListSceneKey.withdraw, symbol: temp.symbol, isFirstPage: true,startTime:temp.startTime,endTime: temp.endTime)
                }else {
                    journalVm.getB2cJournalList(scene: EXJournalListSceneKey.deposit, symbol: temp.symbol, isFirstPage: true,startTime:temp.startTime,endTime: temp.endTime)
                }
            }
        }else if self.assetType! == .otc {
            let temp = JournalCommonSearchModel()
            temp.endTime = params["endTime"] ?? ""
            temp.startTime =  params["startTime"] ?? ""
            var symbol = params["coinSymbol"] ?? ""
            let entity = EXAppMarketManager.sharedInstance.getCoinEntityWithAliasName(symbol)
            if entity.name != "" {
                symbol = entity.name
            }
            temp.symbol = symbol
            temp.scene =  EXJournalListSceneKey.otctransfer.rawValue
            journalVm.commonSearchModel = temp
            journalVm.otcJournalRefresh()
        }else if self.assetType! == .contract {
            let temp = JournalCommonSearchModel()
            temp.endTime = params["endTime"] ?? ""
            temp.startTime =  params["startTime"] ?? ""
            if params.count > 0 {
                var itemKeys:[String] = []
                var childKeys:[String] = []
                for (key,value) in params {
                    if key != "startTime", key != "endTime", value != "ALL" {
                        itemKeys.append(key)
                        childKeys.append(value)
                    }
                }
                //If a certain option is selected, the key of the parent type needs to be killed
                let allfatherKeys = ContractPublicInfoManager.manager.getAllSceneKeysAry()
                let a = Set(itemKeys)
                let b = Set(allfatherKeys)
                let rstSet = b.subtracting(a)
                let rstkeys = Array(rstSet)
                temp.contractItem = rstkeys.joined(separator: ",")
                temp.contractChildItem = childKeys.joined(separator: ",")
            }
            journalVm.commonSearchModel = temp
            journalVm.contractJournalRefresh()
        }
    }
    

}

