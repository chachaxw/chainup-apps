//
//  EXMarketsHandler.swift
//  Chainup
//
//  Created by liuxuan on 2023/7/16.
//  Copyright © 2023 ChainUP. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

enum EXCoinZoneType:String,CaseIterable {
    case all = "-1" //whole
    case main = "0"//Main area
    case innovation = "1"//Innovation Zone
    case observation = "2"//Observation area
    case halve = "3" //Halved area
    case overCharge = "isOverCharge"//Fantastic Zone, Unlock Zone
    
    var describe: String{
        var name = ""
        switch self {
        case .main:
            name = "transaction_text_mainZone".localized()
        case .innovation:
            name = "market_text_innovationZone".localized()
        case .halve:
            name = "common_text_halveZone".localized()
        case .observation:
            name = "market_text_observeZone".localized()
        case .overCharge:
            name = "market_text_unlockZone".localized()
        case .all:
            name = "common_action_sendall".localized()
        }
        return name
    }
}

var customZoneKey = "market_text_customZone".localized()

//Process Market data, update
class EXMarketsDataHandler: NSObject {
    
    private static var _sharedInstance:EXMarketsDataHandler?
    
//    let onFullMarketsPublish : PublishSubject<([String:[[CoinDetailsEntity]]],[String:[EXCoinZoneType]])> = PublishSubject.init()
    let onFullMarketsPublish : BehaviorSubject<([String:[[CoinDetailsEntity]]],[String:[EXCoinZoneType]])> = .init(value: ([:], [:]))

    let onMarketPublish:PublishSubject<(String,[[CoinDetailsEntity]],[EXCoinZoneType])> = PublishSubject.init()
    let disposeBag = DisposeBag()
    
    //[Currency Pair]=>[Main Area], [Innovation Area], [Observation Area], [Half Reduction Area]
    var marketCoins:[String:[[CoinDetailsEntity]]] = [:]
    //Market: [main area, innovation area, observation area, halved area]
    var marketZones:[String:[EXCoinZoneType]] = [:]
    
    //Destroy single instance objects
    class func destroy() {
        customZoneKey = "market_text_customZone".localized()
        _sharedInstance = nil
    }

    open class func shared() -> EXMarketsDataHandler {
        guard let instance = _sharedInstance else {
            _sharedInstance = EXMarketsDataHandler()
            return _sharedInstance!
        }
        return instance
    }
    
    func registerPubLicInfoSignal() {
        
        EXAppMarketManager.sharedInstance.onMarketPublish
             .subscribe(onNext: {[weak self] (success) in
                 guard let `self` = self else {return}
                 if success {
                     self.handleMarketClassification()
                 }
             }).disposed(by: self.disposeBag)
    }
    
    func marketNames() -> [String]{
        //[Optional]+Names of all market currency pairs
        let markets = EXAppMarketManager.sharedInstance.getMarketSorts()
        return markets
    }
    
    func marketNamesShow() -> [String]{
        return self.marketNames().map({return $0.aliasName()})
    }
    
    //Sort=halve>main area>innovation area>observation area>unlock area
    func handleMarketClassification() {
        
        DispatchQueue.global().async {[weak self] in
            //Market: [currency pair]
            guard let mySelf = self else { return }

            var tempMarketCoins:[String:[CoinMapEntity]] = [:]
            let markets = mySelf.marketNames()
            //Obtain the corresponding currency array of market currency pairs
            for market in markets {
                if market.lowercased() == "etf" {
                    tempMarketCoins[market] = EXAppMarketManager.sharedInstance.getAllETFCoinMap()
                }else {
                    tempMarketCoins[market] = EXAppMarketManager.sharedInstance.getCoinPairsBy(marketName: market)
                }
                mySelf.handleCoinDatas(tempMarketCoins)
            }
            DispatchQueue.main.async {//Serial, asynchronous
                //All processed, use the distribution page
            
                mySelf.onFullMarketsPublish.onNext((EXMarketsDataHandler.shared().marketCoins,EXMarketsDataHandler.shared().marketZones))
            }
        }
    }
    
    private func handleCoinDatas(_ tempMarketCoins:[String:[CoinMapEntity]] ) {
        //[Coin Pair]=>[Half Reduction Zone], [Main Zone], [Innovation Zone], [Observation Zone], [Unlock Zone]
        //Processed into an array of market corresponding areas, each area item has its own original serial number
        //Sort each area in a fixed order
//        print("tempMarketCoins=>\(tempMarketCoins)")
        //[Currency Pair]=>[Main Area], [Innovation Area], [Observation Area], [Half Reduction Area]
        var tmpMarketCoins:[String:[[CoinDetailsEntity]]] = [:]
        //Market: [main area, innovation area, observation area, halved area]
        var tmpMarketZones:[String:[EXCoinZoneType]] = [:]
        for (key,value) in tempMarketCoins {
            //Regardless of the previous data assembly, optimize it later.
            var tmpMain : [CoinDetailsEntity] = []
            var mainIdx:Int = 0
            var tmpInnovation : [CoinDetailsEntity] = []
            var innovationIdx:Int = 0
            var tmpObservation : [CoinDetailsEntity] = []
            var observationIdx:Int = 0
            var tmpHalve : [CoinDetailsEntity] = []
            var halveIdx:Int = 0
            var tmpOvercharge : [CoinDetailsEntity] = []
            var overchargeIdx:Int = 0
            //Distinguish different zones for currency pairs
            for (_,item) in value.enumerated() {
                if item.isShow == "1" {
                    let detailEntity = CoinDetailsEntity()
                    detailEntity.symbol = item.symbol
                    detailEntity.name = item.name
                    detailEntity.doubleSort = item.doubleSort
                    detailEntity.handleNameAndTags()
                    //                detailEntity.updateModelWithTicker(ticker: <#T##EXTickerModel#>)
                    if let i = Int(item.price){
                        detailEntity.precision = i
                    }
                    if let i = Int(item.volume){
                        detailEntity.volprecision = i
                    }
                    
                    if item.coinListEntity().isOvercharge == "1"{
                        detailEntity.app_serial_number = overchargeIdx
                        tmpOvercharge.append(detailEntity)
                        overchargeIdx += 1
                    }else{
                        if item.newcoinFlag == EXCoinZoneType.main.rawValue {
                            detailEntity.app_serial_number = mainIdx
                            tmpMain.append(detailEntity)
                            mainIdx += 1
                        }else if item.newcoinFlag == EXCoinZoneType.innovation.rawValue {
                            detailEntity.app_serial_number = innovationIdx
                            tmpInnovation.append(detailEntity)
                            innovationIdx += 1
                        }else if item.newcoinFlag == EXCoinZoneType.observation.rawValue {
                            detailEntity.app_serial_number = observationIdx
                            tmpObservation.append(detailEntity)
                            observationIdx += 1
                        }else if item.newcoinFlag == EXCoinZoneType.halve.rawValue {
                            detailEntity.app_serial_number = halveIdx
                            tmpHalve.append(detailEntity)
                            halveIdx += 1
                        }
                    }
                }
            }
            
            //Excluding blank areas, the order is client controlled, sorted=>[Half reduction area], [Main area], [Innovation area], [Observation area], [Unlock area]]
            let tmpZone = [tmpHalve,tmpMain,tmpInnovation,tmpObservation,tmpOvercharge]
            var existZone:[EXCoinZoneType] = []
            var zones:[[CoinDetailsEntity]] = []
            for (idx,zone) in tmpZone.enumerated() {
                if zone.count > 0 {
                    switch idx {
                    case 0:
                        existZone.append(.halve)
                    case 1:
                        existZone.append(.main)
                    case 2:
                        existZone.append(.innovation)
                    case 3:
                        existZone.append(.observation)
                    case 4:
                        existZone.append(.overCharge)
                    default:
                        break
                    }
                    zones.append(zone)
                }
            }
            //Sort=halve>main area>innovation area>observation area>unlock area
            tmpMarketCoins[key] = zones
            tmpMarketZones[key] = existZone
        }
        EXMarketsDataHandler.shared().marketCoins = tmpMarketCoins
        EXMarketsDataHandler.shared().marketZones = tmpMarketZones
    }
}

