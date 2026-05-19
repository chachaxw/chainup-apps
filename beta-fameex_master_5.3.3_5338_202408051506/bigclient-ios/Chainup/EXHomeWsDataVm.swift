//
//  EXHomeWsDataVm.swift
//  Chainup
//
//  Created by liuxuan on 2023/7/23.
//  Copyright © 2023 ChainUP. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
//First, add the ws related logic here, and then refactor the homepage with

//The homepage adopts recommended currency pairs (up to 20)+increase/decrease (up to 10), with a maximum of 30 sub_ Batch, redistribute

class EXHomeWsDataVm: NSObject {
    var homedisposeBag = DisposeBag()
    
    private static var _sharedInstance:EXHomeWsDataVm?
    //All currency pairs obtained from the entire homepage
    //The homepage adopts recommended currency pairs (up to 20)+increase/decrease (up to 10), with a maximum of 30 sub_ Batch, redistribute
    var combinedSymbols:[String] = []
    var currentSubCoins:[String] = []
    
    var recommended : [HomeRecommendedEntity] {
        get {
            return rx_recommended.value
        }
        set {
            rx_recommended.accept(newValue)
        }
    }

    var ranking : [HomeListEntity] {
        get {
            return rx_ranking.value
        }
        set {
            rx_ranking.accept(newValue)
        }
    }
    
    var recommendedV2 : [EXHomeTicker] {
        get {
            return rx_recommendedV2.value
        }
        set {
            rx_recommendedV2.accept(newValue)
        }
    }
    
    var rankingV2 : [EXHomeTicker] {
        get {
            return rx_rankingV2.value
        }
        set {
            rx_rankingV2.accept(newValue)
        }
    }
    
    
    private var rx_recommended = BehaviorRelay<[HomeRecommendedEntity]>(value: [])
    private var rx_recommendedV2 = BehaviorRelay<[EXHomeTicker]>(value: [])
    
    private var rx_ranking = BehaviorRelay<[HomeListEntity]>(value:[])
    private var rx_rankingV2 = BehaviorRelay<[EXHomeTicker]>(value:[])
    
    //Destroy single instance objects
    class func destroy() {
        _sharedInstance = nil
    }
    
    open class func shared() -> EXHomeWsDataVm {
        guard let instance = _sharedInstance else {
            _sharedInstance = EXHomeWsDataVm()
            return _sharedInstance!
        }
        return instance
    }
    
    func reConnect() {
        goSubBatch()
    }
    
    func registerHomeCoins() {
        let rankingSymbols = rx_ranking.asObservable().map { (list) -> [String] in
            return list.flatMap { (entity) -> [String] in
                return [entity.symbol]
            }
        }
        let recommendSymbols = rx_recommended.asObservable().map { (list) -> [String] in
            return list.flatMap { (entity) -> [String] in
                return [entity.symbol]
            }
        }
        
        Observable.of(rankingSymbols,recommendSymbols)
            .merge()
            .subscribe(onNext: {[weak self] symbols in
                guard let `self` = self else {return}
                self.handleCommingSymbols(symbols: symbols)
                }, onError: { (error) in
                    
            })
            .disposed(by: homedisposeBag)
    }
    
    func registerHomeCoinsV2() {
        let rankingSymbols = rx_rankingV2.asObservable().map { (list) -> [String] in
            return list.flatMap { (entity) -> [String] in
                return [entity.symbol]
            }
        }
        let recommendSymbols = rx_recommendedV2.asObservable().map { (list) -> [String] in
            return list.flatMap { (entity) -> [String] in
                return [entity.symbol]
            }
        }
        
        Observable.of(rankingSymbols,recommendSymbols)
            .merge()
            .subscribe(onNext: {[weak self] symbols in
                guard let `self` = self else {return}
                self.handleCommingSymbols(symbols: symbols)
                }, onError: { (error) in
            })
            .disposed(by: homedisposeBag)
    }
    
    func handleCommingSymbols(symbols:[String]) {
        
        if combinedSymbols.count == 0 {
            if symbols.count == 0 {
                return
            }
//            print("symbols -> \(symbols)")
            combinedSymbols = symbols
            tryStartwsSubBatch(symbols: combinedSymbols)
        }else {
            if symbols.count == 0 {
                let original = Set(combinedSymbols)
                let new = recommended.flatMap{ (entity) -> [String] in
                    return [entity.symbol]
                }
                let newCombined = original.intersection(new)
                combinedSymbols = Array(newCombined)
//Print ("Latest Intersection Merge -> (newCombined)")
                tryStartwsSubBatch(symbols:combinedSymbols)
            }else {
                let original = Set(combinedSymbols)
                let new = Set(symbols)
//Print ("Last Record -> (combinedSymbols)")
//Print ("New -> (symbols)")
                //The original set content contains a new set
                if original.isSuperset(of: new) {
//Print ("Original Inclusion Relationship -> (combinedSymbols)")
                    tryStartwsSubBatch(symbols: combinedSymbols)
                }else {
                    let newCombined = original.union(new)
//Print ("Latest Merge -> (newCombined)")
                    combinedSymbols = Array(newCombined)
                    tryStartwsSubBatch(symbols:combinedSymbols)
                }
            }
            
        }
    }
    
    func tryStartwsSubBatch(symbols:[String]) {
        if currentSubCoins.count > 0 {
            let original = Set(currentSubCoins)
            let new = Set(symbols)
            if original != new {
                currentSubCoins = symbols
                goSubBatch()
            }
        }else {
            currentSubCoins = symbols
            goSubBatch()
        }
        
    }
    
    func goSubBatch() {
        
        EXWebSocket.marketService.cancel()
        
        var tickers :[String] = []
        for symbol in currentSubCoins {
            tickers.append("market_\(symbol)_ticker")
        }
        let prepareCoins = tickers.joined(separator: ",")
//        print("currentSubCoins = \(currentSubCoins)")
//        print("prepareCoins = \(prepareCoins)")
        EXWebSocket.marketService.addwsTaskSub(event:"sub_batch", channel:prepareCoins, cbid: "")
    }
}

