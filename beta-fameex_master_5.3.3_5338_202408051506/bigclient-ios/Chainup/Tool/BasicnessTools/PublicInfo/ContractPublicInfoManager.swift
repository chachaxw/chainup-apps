//
//  ContractPublicInfoManager.swift
//  Chainup
//
//  Created by zewu wang on 2023/1/18.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Moya
class ContractPublicInfoManager: NSObject {
    let kContractPublicInfo = "kContractPublicInfo"
    let kContractLastClosePriceSymbol = "kContractLastClosePriceSymbol"
    let kContractContentModel = "kContractContentModel"

    let kNotificationRefreshPublicInfo = "kNotificationRefreshPublicInfo"

    static let `manager` = ContractPublicInfoManager()
    let disposebag = DisposeBag()
    var publicinfo: ContractPublicInfo?
    var selectedModel = ContractContentModel() {
        didSet {
            let modelData = selectedModel.mj_JSONData()
            if let data =  modelData{
                UserDefaults.standard.set(data, forKey:kContractContentModel)
            }
        }
    }

    override init() {
        super.init()
        loadPublicInfo()
    }
    
    func setClosePrice(price:String,symbol:String) {
        UserDefaults.standard.set(price, forKey: symbol)
    }
    
    private func getlastPrice(symbol:String) ->String {
        guard let price = UserDefaults.standard.string (forKey:symbol) else {return ""}
        return price
    }
    
    func loadPublicInfo() {
        guard let dataStr = UserDefaults.standard.data(forKey:kContractPublicInfo) else {return}
        guard let model = ContractPublicInfo.mj_object(withKeyValues: dataStr) else {
            return
        }
        publicinfo = model
    }
    
//    func  requestContractPublicInfo() {
//        contractApi.hideAutoLoading()
//        contractApi.rx.request(ContractAPIEndPoint.contractPublicInfo)
//            .MJObjectMap(ContractPublicInfo.self)
//            .subscribe{[weak self] event in
//                switch event {
//                case .success(let response):
//                    self?.archivePublic(publicInfo: response)
//                case .error(): break
//                    //Todo retry mechanism
//                }
//            }.disposed(by: disposebag)
//    }
    
    func archivePublic(publicInfo:ContractPublicInfo) {
        guard let pubInfoTemp = publicInfo.mj_JSONData() else {return}
        UserDefaults.standard.set(pubInfoTemp, forKey:kContractPublicInfo)
        self.publicinfo = ContractPublicInfo.mj_object(withKeyValues: pubInfoTemp)
        notifyPublicInfo()
    }
    
    func notifyPublicInfo(){
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationRefreshPublicInfo), object: nil)
    }
    
    func getSelectedContractModel() -> ContractContentModel {
        if let selectedModelData = UserDefaults.standard.data(forKey:kContractContentModel) {
            if let model = ContractContentModel.mj_object(withKeyValues: selectedModelData) {
                let contracts = self.getContractIds()
                if contracts.contains(model.id) {
                    return model
                }
            }
        }
        return self.getDefaultContractModel()
    }
    
    func marketSymbol()->String {
        guard let model = self.publicinfo else {
            return ""
        }
        return model.marketSymbol
    }
    
    func marketContractId() -> String {
        guard let model = self.publicinfo else {
            return ""
        }
        for item in model.marketItems {
            if item.symbol == self.marketSymbol() {
                return item.id
            }
        }
        return ""
    }
    
    func marketContractBetLevel() -> String {
        guard let model = self.publicinfo else {
            return ""
        }
        //MARK: Unify with h5 first, take the maximum
        for item in model.marketItems {
            return item.maxLeverageLevel
            
//            if item.symbol == self.marketSymbol() {
//                let levels = item.leverTypes.components(separatedBy:",")
//                if levels.count > 0 {
//                    return levels.last
//                }
//                return ""
//            }
        }
        return ""
    }
    
    func getContractTypes() -> Array<[ContractContentModel]> {
        guard let model = self.publicinfo else {
            return []
        }
        if model.marketItems.count > 0 {
            var sections:Array<[ContractContentModel]> = []
            let sortedModels:Array<ContractContentModel> = model.marketItems.sorted { (modela, modelb) -> Bool in
                let nsIdx = modelb.sort as NSString
                return nsIdx.isBig(modela.sort)
            }
            
            let baseSymbols:Array<String> = sortedModels
                .compactMap({ (itemModel) -> String in
                return itemModel.baseSymbol
            })
            
            for (_,sectionName) in baseSymbols.enumerated() {
                let rows = model.marketItems.filter { (model) -> Bool in
                    return model.baseSymbol == sectionName
                }
                let sortedRows = rows.sorted { (modela, modelb ) -> Bool in
                    let sortType = modela.contractType as NSString
                    return sortType.isBig(modelb.contractType)
                }
                sections .append(sortedRows)
            }
            return sections
        }
        return []
    }
    
    func getContractTypeTitles() -> Array<String> {
        guard let model = self.publicinfo else {
            return []
        }
        if model.marketItems.count > 0 {
            let sortedModels:Array<ContractContentModel> = model.marketItems.sorted { (modela, modelb) -> Bool in
                let nsIdx = modelb.sort as NSString
                return nsIdx.isBig(modela.sort)
            }
            let baseSymbols:Array<String> = sortedModels
                .compactMap({ (itemModel) -> String in
                    return itemModel.baseSymbol
                })
            return baseSymbols
        }
        return []
    }
    
    func getContractIds() -> Array<String> {
        guard let model = self.publicinfo else {
            return []
        }
        if model.marketItems.count > 0 {
            let baseSymbols:Array<String> = model.marketItems
                .compactMap({ (itemModel) -> String in
                    return itemModel.id
                })
            return baseSymbols
        }
        return []
    }
    
    func getDefaultContractModel()->ContractContentModel {
        guard let info = self.publicinfo else {
            return ContractContentModel()
        }
        for (_,marketItem) in info.marketItems.enumerated() {
            if marketItem.symbol == self.marketSymbol() {
                return marketItem
            }
        }
        return ContractContentModel()
    }
    
    //if newPrice > oldPrice return true
    func isLastPriceUp(symbol:String,newPrice:String)->Bool {
        let oldprice = self.getlastPrice(symbol: symbol)
        if !oldprice.isEmpty {
            let nsPrice = newPrice as NSString
            if (nsPrice.isBig(oldprice)) {
                return true
            }
        }
        return false
    }
}

extension ContractPublicInfoManager{
    
//    func getAllContract(){
//
//    }
    
    func getsceneLists() ->[SceneItem] {
        return publicinfo?.sceneList ?? []
    }
    
    func getAllSceneKey() ->String {
        var scenekeys = ""
        let allScene = self.getsceneLists()
        var sceneItems:[String] = []
        for scene in allScene {
            sceneItems.append(scene.item)
        }
        if sceneItems.count == 1 {
            scenekeys = sceneItems[0]
        }else if sceneItems.count > 1 {
            scenekeys = sceneItems.joined(separator: ",")
        }
        return scenekeys
    }
    
    func getAllSceneKeysAry() ->[String] {
        let allScene = self.getsceneLists()
        var sceneItems:[String] = []
        for scene in allScene {
            sceneItems.append(scene.item)
        }
        return sceneItems
    }
    
    
    //Obtain contracts for all corresponding markets
    func getAllContractForMarket() -> [String : [ContractContentModel]]{
        return publicinfo?.marketModels ?? [:]
    }
    
    //Obtain contracts sorted by name
    func getAllContractFromResultMarketModels() -> [(String,[ContractContentModel])]{
        return publicinfo?.resultMarketModels ?? []
        
    }
    
    //Obtain the first valid contract
    func getFirstContract() -> ContractContentModel{
        if let models = publicinfo?.marketModels{
            for key in models.keys{
                if let values = models[key]{
                    if values.count > 0{
                        return values[0]
                    }
                }
            }
        }
        return ContractContentModel()
    }
    
    //Obtain the default contract transmitted in the background. If it cannot be found, take the first one in the dictionary
    func getDefaultContract()-> ContractContentModel{
        let marketSymbol = publicinfo?.marketSymbol
        if let models = publicinfo?.marketModels{
            for key in models.keys{
                if let values = models[key]{
                    if values.count > 0{
                        for model in values{
                            if model.symbol == marketSymbol{
                                return model
                            }
                        }
                    }
                }
            }
        }
        return getFirstContract()
    }
    
    //Obtain contract information based on contract ID
    func getContractWithContractId(_ id : String) -> ContractContentModel{
        if let models = publicinfo?.marketModels{
            for key in models.keys{
                if let values = models[key]{
                    for value in values{
                        if value.id == id{
                            return value
                        }
                    }
                }
            }
        }
        return ContractContentModel()
    }
    
    func getContractTimeRangeTitle(_ contractID: String) -> String {
        let model = self.getContractWithContractId(contractID)
        return model.getContractTitle()
    }
    
    //Obtain currency accuracy based on currency name
    func getCoinList(_ coinName : String) -> ContractCoinListModel{
        var model = ContractCoinListModel()
        let coinlist = publicinfo?.coinListModel
        for entity in coinlist ?? []{
            if entity.key.lowercased() == coinName.lowercased(){
                model = entity
            }
        }
        return model
    }
    
    //Obtain btc contract accuracy
    func getBtcPrecision() -> Int{
        var btcPrecision = 4
        if let bp = Int(ContractPublicInfoManager.manager.getCoinList("BTC").showPrecision){
            btcPrecision = bp
        }
        return btcPrecision
    }
    
    //Obtain the net position 0, sub position 1 status of the contract
    func getContractPositionType() -> String{
        return publicinfo?.switchModel.is_more_position ?? "0"
    }
    
}

