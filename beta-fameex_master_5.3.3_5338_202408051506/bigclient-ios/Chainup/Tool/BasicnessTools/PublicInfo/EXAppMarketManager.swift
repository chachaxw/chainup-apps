//
//  EXAppMarketManager.swift
//  Chainup
//
//  Created by liuxuan on 2023/9/7.
//  Copyright © 2023 ChainUP. All rights reserved.
//

import UIKit
import RxSwift
import Swap
class EXCurrencyModel:EXBaseModel {
    var lang_coin = "USD"//Abbreviation of legal currency
    var lang_logo = "$"//Legal currency symbol
    var coin_precision = "4"//Currency and fiat currency accuracy
    var coin_fiat_precision = "2"//Off exchange fiat currency accuracy
}

class EXAppMarketManager: NSObject {
    let disposeBag = DisposeBag()
    var marketVm:EXAppMarketVM = EXAppMarketVM()
    let defaultCoinPrecision :Int = 8
    let defaultRate :Int = 2//Rate object, default precision
    let defaultFiatRate:Int = 2//Rate object, default precision for fiat currency
    var onMarketPublish : BehaviorSubject<Bool> = BehaviorSubject.init(value: false)
    var recommendCoins:[EXHomeTicker] = []
    let userFiatSymbol:String = "userFiatSymbol"

    var timer : Timer?
    
    func resetBehaviorSubject(){
        self.onMarketPublish = BehaviorSubject.init(value: false)
    }
    //Obtain Exchange Rate
    func getRate(){
        self.refreshRate()
        if timer == nil {
            timer = Timer.init(timeInterval: 60, repeats: true, block: {(timer) in
                self.refreshRate()
            })
            RunLoop.main.add(timer!, forMode: RunLoop.Mode.common)
        }
    }

    static let sharedInstance: EXAppMarketManager = {
        let instance = EXAppMarketManager()
        if let cacheMarket = EXAppCache.sharedCache.getPbMarketCache() {
            instance.marketVm.appMarketVmWith(config: cacheMarket)
        }
        return instance
    }()
    
    func hasCache()->Bool {
        if let _ = EXAppCache.sharedCache.getPbMarketCache() {
            return true
        }else {
            return false
        }
    }
    
    func fetchMarket() {
        print("fetchMarket")
        appApi.hideAutoLoading()
        appApi.rx.request(.publicInfoMarket)
            .MJObjectMap(EXAppMarketModel.self, false)
            .subscribe{[weak self] event in
                switch event {
                case .success(let model):
                    self?.handleAppMarket(model: model)
                    break
                case .failure(_):
                    break
                }
        }.disposed(by:self.disposeBag)
        getRate()
        getHotCoins()
    }
    
    func getHotCoins() {
        appApi.hideAutoLoading()
        appApi.rx.request(.appRecommendCoin)
            .MJObjectMap(EXRecommendCoinModel.self, false)
            .subscribe{[weak self] event in
                switch event {
                case .success(let model):
                    self?.updateRecommendCoins(coins: model.recommendCoin)
                    break
                case .failure(_):
                    break
                }
        }.disposed(by:self.disposeBag)
    }
    
    func updateRecommendCoins(coins:String) {
        EXAppCache.sharedCache.updateHotCoins(coin: coins)
    }
    
    func refreshRate(_ fiat:String = "") {
        var symbol = fiat
        if fiat.count == 0 {
            if let fiatSymbol = UserDefaults.standard.value(forKey: userFiatSymbol) as? String {
                symbol = fiatSymbol
            }else {
                symbol = self.getFiatCoinSymbol()
            }
        }
        
        appApi.hideAutoLoading()
        appApi.rx.request(.publicRate(symbol))
            .MJObjectMap(CoinRateEntity.self,false)
            .subscribe{[weak self] event in
                switch event {
                case .success(let model):
                    self?.updateRate(model.rate,fiatSymbol: symbol)
                    break
                case .failure(_):
                    break
                }
        }.disposed(by:self.disposeBag)
    }
    
    func handleAppMarket(model:EXAppMarketModel) {
        self.marketVm.appMarketVmWith(config: model)
        //Update cache
        EXAppCache.sharedCache.updatePbMarketCache(model: model)
        self.onMarketPublish.onNext(true)
    }
    
//    func updateLan() {
//        self.marketVm.updateLanguage()
//    }
}

//MARK: Coin pair operation
extension EXAppMarketManager {
    
    func hasLoaded() -> Bool {
        if marketVm.market.count > 0 ,getMarketSorts().count > 0 {
            return true
        }
        return false
    }
    
    //ETF rate
    func getFundRate(_ symbol:String) ->String {
        let entity = self.getCoinMapEntityBySymbol(symbol)
        return entity.fundRate
    }
    
    //Obtain information on all currency pairs in the market based on its name.
    //Example: To BTC, return all BTC currency pair information
    func getCoinPairsBy(marketName:String) -> [CoinMapEntity] {
        return marketVm.market[marketName] ?? []
    }
    
    //Obtain currency pair information based on the name of the currency pair.
    //For example, give BTC/USDT to obtain this object
    func getCoinMapEntityByName(_ coinPairName : String) -> CoinMapEntity {
        for item in marketVm.marketList{
            if coinPairName == item.name{
                return item
            }
        }
        return CoinMapEntity()
    }
    
    //Obtain currency pair information based on the currency pair symbol.
    //Example: For btcusdt, return currency pair information
    func getCoinMapEntityBySymbol(_ symbol:String) -> CoinMapEntity {
        for item in marketVm.marketList {
            //Old logic, uncertain why name is empty
            if symbol.lowercased() == item.symbol.lowercased() && item.name != "" {
                return item
            }
        }
        return CoinMapEntity()
    }
    
    //Obtain currency pair entities based on aliases
    func getCoinMapEntityByAliaName(_ name : String) -> CoinMapEntity{
        var coinmapEntity = CoinMapEntity()
        for entity in marketVm.marketList{
            if entity.showName.replacingOccurrences(of: "/", with: "").lowercased() == name{
                coinmapEntity = entity
                break
            }
        }
        return coinmapEntity
    }
    
    func getMarketRight(_ coinPair:String) -> String{
        let arr = coinPair.components(separatedBy: "/")
        if arr.count > 1{
            return arr[1]
        }
        return coinPair
    }
    
    func getMarketLeft(_ coinPair:String) -> String{
        let arr = coinPair.components(separatedBy: "/")
        if arr.count > 1{
            return arr[0]
        }
        return coinPair
    }
    
    //Obtain all market names
    func getMarketSorts() -> [String] {
        return marketVm.marketModel.marketSort
    }
    
    //Obtain the searched currency pairs
    func getSearchCoinMapList(_ name:String) -> [CoinMapEntity]{
        var array : [CoinMapEntity] = []
        for item in marketVm.marketList {
            if item.isShow == "1", item.showName.lowercased().contains(name.lowercased()){
                array.append(item)
            }
        }
        return array
    }
    
    func getAllCoinMapInfo() -> [CoinMapEntity]{
        return marketVm.marketList
    }
    func getAllShowCoinMapInfo() -> [CoinMapEntity]{
        let list = marketVm.marketList.filter { item in
            return item.isShow == "1"
        }
        return list
    }
    
    //Obtain the default currency for leverage, if there is btcusdt used, do not take the first one
    func getDefaultExchangeMap() -> CoinMapEntity{
        let homeCoins = getMarketSorts()
        if homeCoins.count > 0 {
            for market in homeCoins {
                let markets = getCoinPairsBy(marketName: market)
                if markets.count > 0 {
                    return markets[0]
                }
            }
        }
        return CoinMapEntity()
    }
}

//MARK: Currency operation
extension EXAppMarketManager {
    
    func getCoinMarketTag(_ symbol:String) ->String {
   
        for item in marketVm.followCoinList{
            if item.name == symbol{
                return (item.coinTag)
            }
        }
        for item in marketVm.coinList {
            if item.name == symbol{
                return (item.coinTag)
            }
        }
        return ""
    }
    
    //Obtain currency information based on currency name
    //Example to BTC, returning currency information
    func getCoinEntity(_ coinName:String) -> CoinListEntity? {
        let allcoins = marketVm.coinList + marketVm.followCoinList
        for item in allcoins {
            if item.name == coinName{
                return item
            }
        }
        return nil
    }
    
    //Is it necessary to display a label bar to obtain currency based on name
    func coinNeedTag(_ coinName:String) -> Bool {
        let allcoins = marketVm.coinList + marketVm.followCoinList
        for item in allcoins{
            if item.name == coinName{
                return (item.tagType == "1" || item.tagType == "2")
            }
        }
        return false
    }
    
    //Force Tag
    func isCoinForceWithdrawTag(_ coinName:String) -> Bool {
        let allcoins = marketVm.coinList + marketVm.followCoinList
        for item in allcoins{
            if item.name == coinName{
                return  item.tagType == "2"
            }
        }
        return false
    }
    
    //Calculate accuracy based on currency
    func getCoinPrecision(_ coinName:String) -> Int {
        let entity = getCoinEntity(coinName)
        if let tmp = entity?.showPrecision {
            if let pre = Int(tmp) {
                return pre
            }
        }
        return defaultCoinPrecision
    }
    //Currency - Precision
    func getCoinPrecisionMap() -> [String: Int]{
        let allcoins = marketVm.coinList + marketVm.followCoinList
        var keyValues = [String: Int]()
        for item in allcoins {
            keyValues[item.name] = Int(item.showPrecision)
        }
        return keyValues
    }
    
    //List of currencies within the search
    func getSearchCoinList(_ names : String) -> [CoinListEntity]{
        var array : [CoinListEntity] = []
        let allcoins = marketVm.coinList + marketVm.followCoinList
        for item in allcoins {
            if item.showName.lowercased().contains(names.lowercased()) {
                array.append(item)
            }
        }
        return array
    }
    
    func getCoinEntityWithAliasName(_ name :String) -> CoinListEntity {
        let allcoins = marketVm.coinList + marketVm.followCoinList
        for item in allcoins {
            if item.showName.lowercased() == name.lowercased() {
                return item
            }
        }
        return CoinListEntity()
    }
    
    func getAllCoinList() -> [CoinListEntity]{
        //There is duplicate currency data between two arrays
        var allcoins:[CoinListEntity] = []
        let followCoinSymbols = marketVm.followCoinList.map({return $0.name})
        if followCoinSymbols.count > 0 {
            for entity in marketVm.coinList {
                if !followCoinSymbols.contains(entity.name) {
                    allcoins.append(entity)
                }
            }
            for entity in marketVm.followCoinList {
                allcoins.append(entity)
            }
            return allcoins
        }else {
            return marketVm.coinList
        }
    }
}

//MARK: Slave currency related operations
extension EXAppMarketManager {
    //Obtain an array from the currency dictionary based on the name of the main currency
    func getFollowCoinList(_ mainCoinSymbol : String,type: EXAssetToolBarAction = EXAssetToolBarAction.none) -> [CoinListEntity]{
        var arr : [CoinListEntity] = []
        for (key,value) in marketVm.followCoinDict{
            if key.lowercased() == mainCoinSymbol.lowercased(){
                arr = value
                break
            }
        }
        if EXAppConfigManager.sharedInstance.configVm.cfgModel.usdt_open_omni != "1" {
            arr = arr.filter({ item in
                return item.mainChainName.uppercased() != "OMNI"
            })
        }
        if type == .withdraw {//Withdrawal
            arr = arr.filter({ item in
                return item.withdrawOpen == "1"
            })
        }else if type == .recharge {//Recharge
            arr = arr.filter({ item in
                return item.depositOpen == "1"
            })
        }
        return arr
    }
    
    //Obtain information about the slave currency based on its name
    func getFollowCoin(_ coinName : String) -> CoinListEntity{
        var entity = CoinListEntity()
        for item in marketVm.followCoinList {
            if item.name.lowercased() == coinName.lowercased(){
                entity = item
            }
        }
        return entity
    }
}

//MARK:ETF
extension EXAppMarketManager {
    //Obtain all ETF currency pairs
    func getAllETFCoinMap() -> [CoinMapEntity]{
        return marketVm.etfMarketList
    }
}

//MARK: lever
extension EXAppMarketManager {
    //Obtain all currency pairs that support leverage
    func getAllLeverArray() -> [CoinMapEntity]{
        return marketVm.leverMarketList
    }
    
    func getIsolatedLevers() -> [CoinMapEntity]{
        if EXAppConfigManager.sharedInstance.didOpenIsolatedLever() {
            return marketVm.leverMarketList.filter({return $0.isOpenLever == "1"})
        }else {
            return []
        }
    }
    
    func getCrossLevers() -> [CoinMapEntity]{
        if EXAppConfigManager.sharedInstance.didOpenCrossLever() {
            return marketVm.leverMarketList.filter({return $0.isOpenCross == "1"})
        }else {
            return []
        }
    }
    
    func getLeverMarketMaps(_ marketName:String) -> [CoinMapEntity] {
        return marketVm.leverMarket[marketName] ?? []
//        if EXLeverService.service.isSupportAllLevers() {
//            return marketVm.leverMarket[marketName] ?? []
//        }else if EXAppConfigManager.sharedInstance.didOpenIsolatedLever() {
//            let levers = marketVm.leverMarket[marketName] ?? []
//            return levers.filter({return $0.isOpenLever == "1" })
//        }else {
//            let levers = marketVm.leverMarket[marketName] ?? []
//            return levers.filter({return $0.isOpenCross == "1" })
//        }
    }
    
    //Obtain the default currency for leverage, if there is btcusdt used, do not take the first one
    func getDefaultLeverCoin() -> CoinMapEntity{
        let arr = marketVm.leverMarketList
        if arr.count > 0{
            for item in arr{
                if item.symbol == "btcusdt"{
                    return item
                }
            }
            return arr[0]
        }
        return CoinMapEntity()
    }
    
    func getLeverMapModel(marketName:String) -> CoinMapEntity{
        let arr = marketVm.leverMarketList
        if arr.count > 0{
            for item in arr{
                if item.name == marketName || item.symbol == marketName.lowercased() {
                    return item
                }
            }
        }
        return CoinMapEntity()
    }
    
    //Obtain a market for all leveraged currency pairs
    func getAllLeverMarketArray() -> [String] {
        return marketVm.leverMarket.map( {return $0.key} )
    }
}

extension EXAppMarketManager {
    
    func getAllQuantMarketNameArray() ->[String] {
        return marketVm.quantMarket.map({return $0.key})
    }
    
    func getQuantMarketMaps(_ marketName:String) -> [CoinMapEntity] {
        return marketVm.quantMarket[marketName] ?? []
    }
    
    func getDefaultQuantCoin() -> CoinMapEntity{
        
        let arr = marketVm.quantMarketList
        if arr.count > 0{
            for item in arr{
                if item.symbol == "btcusdt"{
                    return item
                }
            }
            return arr[0]
        }
        return CoinMapEntity()
    }
    
    
    //Obtain Favorite Grid Coin Pairs
    //Transfer currency pair array, return currency pair object array
    func getQuantCoinMapList(_ names:[String]) -> [CoinMapEntity] {
        var array : [CoinMapEntity] = []
        for name in names{
            let entity = getCoinMapEntityBySymbol(name)
            if entity.name != "",entity.is_grid_open == "1"{
                array.append(entity)
            }
        }
        return array
    }
    
}


//MARK: Legal currency operation
extension EXAppMarketManager {
    
    //Obtain default OTC currency object
    func getDefaultOTCCoinEntity(_ defCoin:String) -> CoinListEntity {
        for item in marketVm.otcCoinList {
            if item.name.uppercased() == defCoin.uppercased() {
                return item
            }
        }
        if marketVm.otcCoinList.count > 0 {
            return marketVm.otcCoinList[0]
        }else {
            return CoinListEntity()
        }
    }
    
    func getAllOTCCoinList() -> [CoinListEntity]{
        return marketVm.otcCoinList
    }
}

//MARK: Transaction currency pair

extension EXAppMarketManager {
    
    func getDealEntity(_ name:String) -> CoinMapEntity {
        
        let dftEntity = getCoinMapEntityByName("BTC/USDT")
        if name == "USDT"{
            return dftEntity
        }else {
            for str in getMarketSorts() {
                if let markets = marketVm.market[str] {
                    for item in markets{
                        let temp = item.name.components(separatedBy: "/")
                        if temp.count > 1 {
                            if temp[0] == name {
                                return item
                            }
                        }
                    }
                }
            }
            return dftEntity
        }
    }
}

//MARK: Collection
extension EXAppMarketManager {
    //Obtain Favorite Coin Pairs
    //Transfer currency pair array, return currency pair object array
    func getCollectionCoinMapList(_ names:[String]) -> [CoinMapEntity] {
        var array : [CoinMapEntity] = []
        for name in names{
            let entity = getCoinMapEntityBySymbol(name)
            if entity.name != ""{
                array.append(entity)
            }
        }
        return array
    }
    
    //Obtain Favorite Leveraged Coin Pairs
    //Transfer currency pair array, return currency pair object array
    func getLeverCoinMapList(_ names:[String]) -> [CoinMapEntity] {
        var array : [CoinMapEntity] = []
        for name in names{
            let entity = getCoinMapEntityBySymbol(name)
            if entity.name != "",entity.isOpenLever == "1"{
                array.append(entity)
            }
        }
        return array
    }
    
    
    func getCollectionCoinDetails(_ names:[String]) -> [CoinDetailsEntity] {
        var arr : [CoinDetailsEntity] = []
        for (idx,name) in names.enumerated(){
            let coinMap = getCoinMapEntityBySymbol(name)
            if coinMap.name != ""{
                let entity = CoinDetailsEntity()
                entity.symbol = coinMap.symbol
                entity.name = coinMap.name
                entity.handleNameAndTags()
                if let i = Int(coinMap.price){
                    entity.precision = i
                }
                if let i = Int(coinMap.volume){
                    entity.volprecision = i
                }
                entity.app_serial_number = idx
                arr.append(entity)
            }
        }
        return arr
    }
}


//MARK: Exchange rate operation
extension EXAppMarketManager {
    
    //Obtain legal currency units such as CNY USD
    func getFiatCoinUnit() -> String {
        return (self.marketVm.currentRateMap["lang_logo"] as? String) ?? ""
    }
    
    //Obtain legal currency symbol CNY USD, etc
    func getFiatCoinSymbol() -> String {
        return (self.marketVm.currentRateMap["lang_coin"] as? String) ?? ""
    }
    
    func updateRate(_ dict: [String:Any],fiatSymbol:String) {
        
        if fiatSymbol.count > 0 {
            UserDefaults.standard.set(fiatSymbol, forKey: userFiatSymbol)
        }
        self.marketVm.updateRate(rate: dict,fiat:fiatSymbol)
    }
    
    //Obtain the exchange rate of currency with 0 symbols and 1 exchange rate with 2 digits
    func getCoinExchangeRate(_ coinName:String) -> (String,String,Int) {
        var t : (String , String,Int) = ("","",defaultRate)
        if let rate = marketVm.currentRateMap[coinName.uppercased()] {
            t.0 = (marketVm.currentRateMap["lang_logo"] as? String) ?? ""
            t.1 = "\(rate)"
            if let rate = marketVm.currentRateMap["coin_precision"] as? String {
                t.2 = Int(rate) ?? defaultRate
            }else {
                t.2 = defaultRate
            }
        }else {
            t.1 = "0"
        }
        return t
    }
    
    func getRatePrecision() -> Int {
        if let rate = marketVm.currentRateMap["coin_precision"] as? String {
            return Int(rate) ?? defaultRate
        }else {
            return defaultRate
        }
    }
    
    //Pass in symbols such as CNY and USD to return the accuracy of the currency
    func getCurrencyModel(_ fiatUnit:String) -> EXCurrencyModel {
        for (_,value) in marketVm.appCoinRate {
            if let model = EXCurrencyModel.mj_object(withKeyValues: value) {
                if model.lang_coin == fiatUnit {
                    return model
                }
            }
        }
        return EXCurrencyModel()
    }
    
}

//MARK: ws, dismantle the channel and put it here first
extension EXAppMarketManager {
    
    func dealChannel(_ channel : String) -> String{
        let arr1 = channel.components(separatedBy: "_")
        if arr1.count > 1{
            let channel1 = arr1[1]
            let arr2 = channel1.components(separatedBy: "_")
            if arr2.count > 0 {
                return arr2[0]
            }
        }
        return channel
    }
}


//MARK: For the contract team
extension EXAppMarketManager {
    
    ///Obtain exchange rate for currency USD
    ///- Parameter name: Currency name, return tuple 0: Exchange rate 1: Exact digits
    func sl_getCoinExchangeRate(_ name : String) -> (String, Int) {
        var t: (String, Int) = ("", 2)
        if let rate = marketVm.appCoinRate["en_US"] as? [String:Any],let r = rate[name.uppercased()] {
            t.0 = "\(r)"
            t.1 = (rate["coin_precision"] as? Int) ?? defaultRate
        }else {
            t.0 = "0"
        }
        return t
    }
    

    
}


