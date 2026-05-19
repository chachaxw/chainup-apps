//
//  EXAppMarketVM.swift
//  Chainup
//
//  Created by liuxuan on 2023/9/8.
//  Copyright © 2023 ChainUP. All rights reserved.
//

import UIKit
import EXKit
import Swap
class CoinRateEntity:EXBaseModel {
    var rate:[String:Any] = [:]
}

//Currency information
class CoinListEntity : EXBaseModel{
    var showPrecision = "0"
    var otcOpen = ""
    var depositOpen = ""//Recharge currency
    var icon = ""
    var name = ""
    var longName = ""
    var sort:Int = 0
    var tokenBase = ""
    var tagType = ""//0 is not filled in, 1 is optional, and 2 is required
    var showName = ""//alias
    var isOvercharge = "0"//Is it a markup currency pair
    var isOverchargeMsg : [String : Any] = [:]
    var mainChainType = ""//Currency master-slave configuration 0 defaults to 1 master currency and 2 slave currencies
    var mainChainSymbol = ""//Main currency
    var mainChainName = ""
    var coinTag = ""
    var withdrawOpen = "" //Withdrawal of currency
    var originCoin = ""
    //Get Mode Description
    func getOverchargeMsg() -> String{
        var str = ""
        if let s = self.isOverchargeMsg[LanguageHandler.priviatePhoneLanguage] as? String{
            str = s
        }
        return str
    }
    
}

//Currency pair
class CoinMapEntity: EXBaseModel {
    
    var app_serial_number:Int = -1
    
    var volume = ""//Quantity accuracy of sales
    
    var symbol = ""
    
    var name = ""//Coin pair name
    
    var limitPriceMin = ""//Lowest price
    
    var marketSellMin = ""//Minimum price
    
    var sort = ""
    
    var doubleSort : Double = 1000
    
    var price = ""//Purchase price accuracy
    
    var marketBuyMin = ""
    
    var limitVolumeMin = ""
    
    var depth = ""
    
    var depthArray : [Int] = []
    var depthArrayShow : [String] = []

    var coinName = ""//Base Currency Name
    
    var marketName = ""//Market name
    
    var newcoinFlag = "0"//0 main area 1 innovation area 2 observation area 3 halved area
    
    var isShow = "1"//List display 1 Yes 0 No
    
    var showName = ""//alias
    
    var multiple = ""//Default leverage multiple
    
    var isOpenLever = ""//Lever switch, 0 closed, 1 open
    var isOpenCross = ""
    
    var etfOpen = ""//Is it ETF market currency pair 0, not 1? Yes
    var icon = ""
    var is_grid_open = ""//Grid switch, 0 off, 1 on
    var fundRate = ""//Fund rate
    var longName = "" //full name
    var etfBase:String = ""
    var etfMultiple:String = ""
    var etfSide:String = ""
    var etfUpAndDown:[String] = []
    
    func getAllSymbolsAndETFs() -> [String] {
        var tickers = self.symbol
        if self.etfUpAndDown.count > 0 {
            let etf = etfUpAndDown.joined(separator: ",")
            tickers.append(",\(etf)")
        }
        return tickers.components(separatedBy: ",")
    }
    
    func marketEntity() -> CoinListEntity {
        return EXAppMarketManager.sharedInstance.getCoinEntity(marketName) ?? CoinListEntity()
    }
    
    func coinListEntity() -> CoinListEntity {
        return EXAppMarketManager.sharedInstance.getCoinEntity(coinName) ?? CoinListEntity()
    }
    
    override func mj_keyValuesDidFinishConvertingToObject() {
        if showName == "" {
            showName = name
        }
        if let double = Double(sort){
            doubleSort = double
        }
        truncationDepth(depth)

        let array = self.name.components(separatedBy: "/")
        if array.count > 0{
            coinName = array[0]
//            coinListEntity = EXAppMarketManager.sharedInstance.getCoinEntity(coinName) ?? CoinListEntity()
        }
        if array.count > 1{
            marketName = array[1]
//            marketEntity = PublicInfoManager.sharedInstance.getCoinEntity(marketName) ?? CoinListEntity()
        }
        
        if self.depthArray.count > 0 {
            self.depthArrayShow = self.depthArray.map({ item -> String in
                return "1".mapPrecision(String(item) )
            })
        }
    }
    
    //truncation
    func truncationDepth(_ depth : String){
        let array = depth.components(separatedBy: ",")
        for item in array{
            let s = item.replacingOccurrences(of: ".", with: "")
            depthArray.append(s.count - 1)
        }
    }
    
    func priceDecimal() ->Int {
        return Int(price) ?? 8
    }
    
    func volDecimal() ->Int {
        return Int(volume) ?? 8
    }

    
    func getETFNotesAttributes(_ note: String = "etf_notes_explain_tips") -> NSMutableAttributedString {
        var multiple = ""
        if self.etfSide == "S" {
            multiple = String.init(format: "etf_notes_multipleS".localized(), self.etfMultiple)
        }else {
            multiple = String.init(format: "etf_notes_multipleL".localized(), self.etfMultiple)
        }
        let etfname = "\(self.etfBase)\(self.etfMultiple)\(self.etfSide)"
        if etfBase.isEmpty || etfMultiple.isEmpty || self.etfSide.isEmpty {
            let mutableAttributedString = NSMutableAttributedString.init(string: "")
            return mutableAttributedString
        }else {
            let fullStr = String.init(format: note.localized(), etfname,self.etfBase,multiple)

            let rangeETF = fullStr.nsRanges(of: etfname)
            let rangeBase = fullStr.nsRanges(of: self.etfBase)
            let rangeMutiple = fullStr.nsRanges(of: multiple)
            
            let allranges = rangeETF+rangeBase+rangeMutiple
            let mutableAttributedString = NSMutableAttributedString.init(string: fullStr)
            for range in allranges {
                mutableAttributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.ThemeView.highlight, range: range)
            }
            return mutableAttributedString
        }
    }
    
    func getEtfRishNotes() -> String {
        var text = ""
        if etfOpen != "1" {
            return text
        }
        var multiple = ""
        if etfSide == "S" {
            multiple = String.init(format: "etf_notes_multipleS".localized(), etfMultiple)
        }else {
            multiple = String.init(format: "etf_notes_multipleL".localized(), etfMultiple)
        }
        text = String(format: "etf_notes_explain_tips".localized(), coinName, etfBase, multiple)
        return text
    }

    
    func getLeverSupportType() ->EXLeverSupportType {
        if self.isOpenCross == "1",self.isOpenLever == "1" {
            if EXAppConfigManager.sharedInstance.didOpenIsolatedLever(),
               EXAppConfigManager.sharedInstance.didOpenCrossLever() {
                return .all
            }else if EXAppConfigManager.sharedInstance.didOpenCrossLever() {
                return .onlyCross
            }else {
                return .onlyIsolated
            }
        }else if self.isOpenLever == "1" {
            if EXAppConfigManager.sharedInstance.didOpenIsolatedLever() {
                return .onlyIsolated
            }else {
                return .none
            }
        }else if self.isOpenCross == "1" {
            if EXAppConfigManager.sharedInstance.didOpenCrossLever() {
                return .onlyCross
            }else {
                return .none
            }
        }else {
            return .none
        }
    }
    
}



class EXAppMarketVM: NSObject {
    
    var marketModel :EXAppMarketModel = EXAppMarketModel()
    var marketList:[CoinMapEntity] = []
    var leverMarketList:[CoinMapEntity] = []
    var etfMarketList : [CoinMapEntity] = []
    var quantMarketList : [CoinMapEntity] = []

    var market:[String:[CoinMapEntity]] = [:]
    var leverMarket:[String:[CoinMapEntity]] = [:]
    var quantMarket:[String:[CoinMapEntity]] = [:]

    var coinList:[CoinListEntity] = []
    var otcCoinList:[CoinListEntity] = []
    var followCoinList : [CoinListEntity] = []
    var followCoinDict : [String : [CoinListEntity]] = [:]//From coin list
    var appCoinRate:[String:Any] = [:]
    var currentRateMap:[String:Any] = [:]
    var fiatSymbol:String = ""
    
//    func updateLanguage() {
//        if let rates = appCoinRate as? [String:[String :Any]] {
//            //Historical logic, if the rate object of the current language cannot be retrieved, default to en_ US, if we cannot obtain it again, it will be empty
//            if currentRateMap.count == 0 {
//                if let tmpRateMap = rates[LanguageTools.phoneLanguage] {
//                    self.currentRateMap = tmpRateMap
//                }else if let tmpRateMap = rates["en_US"] {
//                    self.currentRateMap = tmpRateMap
//                }
//            }
//        }
//    }
//
    func updateRate(rate:[String:Any],fiat:String = "") {
        self.fiatSymbol = fiat
        self.appCoinRate = rate
        if let rates = appCoinRate as? [String:[String :Any]] {
            //Historical logic, if the rate object of the current language cannot be retrieved, default to en_ US, if we cannot obtain it again, it will be empty
            if let tmpRateMap = rates[LanguageHandler.priviatePhoneLanguage] {
                self.currentRateMap = tmpRateMap
            }else if let tmpRateMap = rates["en_US"] {
                self.currentRateMap = tmpRateMap
            }else if let tmpRateMap = rates[fiatSymbol] {
                self.currentRateMap = tmpRateMap
            }
            NotificationCenter.default.post(name: NSNotification.Name.init("AppRateUpdated"), object: nil)
        }
    }
    
    private func clearData() {
        self.marketList.removeAll()
        self.leverMarketList.removeAll()
        self.etfMarketList.removeAll()
        self.coinList.removeAll()
        self.otcCoinList.removeAll()
        self.followCoinList.removeAll()
        self.quantMarketList.removeAll()
    }

    func appMarketVmWith(config:EXAppMarketModel) {
        self.marketModel = config
        self.updateRate(rate: config.rate)
        clearData()
        
        //Processing Currency CoinList
        for(_,value) in config.coinList {
            if let map = CoinListEntity.mj_object(withKeyValues: value) {
                EXSwapPrivateConfig.shared.coinPrecisionMap[map.name] = map.showPrecision
                self.coinList.append(map)
                if map.otcOpen == "1" {
                    self.otcCoinList.append(map)
                }
            }
        }
        
        self.coinList.sort { (a, b) -> Bool in
            return b.sort > a.sort
        }
        
        //Processing followCoinList
        var array : [CoinListEntity] = []
        for(key,value) in config.followCoinList {
            if let coinPair = value as? [String:Any] {
                var coinMaps:[CoinListEntity] = []
                for (_,value1) in coinPair {
                    if let coinMap = CoinListEntity.mj_object(withKeyValues: value1) {
                        coinMaps.append(coinMap)
                        array.append(coinMap)
                    }
                }
                coinMaps.sort { (a, b) -> Bool in
                    return b.sort > a.sort
                }
                self.followCoinDict[key] = coinMaps
            }
            //Old logic, I don't understand why the order is this way
            array.sort { (a, b) -> Bool in
                return b.sort > a.sort
            }
            self.followCoinList = array
        }
        
        //Process all currency pairs, leveraged currency pairs
        var tmplist : [CoinMapEntity] = []
        for(key,value) in config.market {
            
            if let coinPair = value as? [String:Any] {
                var coinMaps:[CoinMapEntity] = []
                var tmpLeverMaps :[CoinMapEntity] = []
                var tmpQuantMaps :[CoinMapEntity] = []
                for (_,value1) in coinPair {
                    if let coinMap = CoinMapEntity.mj_object(withKeyValues: value1) {
                        coinMaps.append(coinMap)
                        tmplist.append(coinMap)
                        if  coinMap.isOpenLever == "1" {
                            tmpLeverMaps.append(coinMap)
                            self.leverMarketList.append(coinMap)
                        }
                        if coinMap.etfOpen == "1" {
                            self.etfMarketList.append(coinMap)
                        }
                        if coinMap.is_grid_open == "1" {
                            tmpQuantMaps.append(coinMap)
                            self.quantMarketList.append(coinMap)
                        }
                    }
                }
                coinMaps.sort { (a, b) -> Bool in
                    return b.doubleSort > a.doubleSort
                }
                tmpLeverMaps.sort { (a, b) -> Bool in
                    return b.doubleSort > a.doubleSort
                }
                tmpQuantMaps.sort { (a, b) -> Bool in
                    return b.doubleSort > a.doubleSort
                }

                self.market[key] = coinMaps
                if tmpLeverMaps.count > 0 {
                    self.leverMarket[key] = tmpLeverMaps
                }
                if tmpQuantMaps.count > 0 {
                    self.quantMarket[key] = tmpQuantMaps
                }
            }
        }
        self.marketList = tmplist.filterDuplicates({$0.symbol})
        self.marketList.sort { (a, b) -> Bool in
            return b.doubleSort > a.doubleSort
        }
        self.etfMarketList = self.etfMarketList.filterDuplicates({$0.symbol})
        self.etfMarketList.sort { (a, b) -> Bool in
            return b.doubleSort > a.doubleSort
        }
        self.leverMarketList = leverMarketList.filterDuplicates({$0.symbol})
        self.leverMarketList.sort { (a, b) -> Bool in
            return b.doubleSort > a.doubleSort
        }
        self.quantMarketList = quantMarketList.filterDuplicates({$0.symbol})
        self.quantMarketList.sort { (a, b) -> Bool in
            return b.doubleSort > a.doubleSort
        }
    }
}

