//
//  UserSysmbolsVM.swift
//  Chainup
//
//  Created by lcus on 2023/9/19.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import RxSwift
import EXKit
enum EXFavoritesActionType {
    case singleAdd //Add 1 favorite
    case singleDelete //Delete a favorite
    case addBatch //Batch addition (scrapping)
    case other //Other, batch add, delete, and adjust the order.
}

class UserSymbolsVM: NSObject {
    
    let disposBag = DisposeBag()
    typealias completeCallBacK = ()->()
    var didComplete:completeCallBacK?
    typealias Handler = (Bool) -> Void
    
    
    func handleFavorite(actionType:EXFavoritesActionType,coinMaps:[CoinMapEntity],callback:Handler?,in view:UIView? = nil) {
        handleFavorite(actionType: actionType, coinMapSymbols: coinMaps.map({ $0.symbol }), callback: callback, in: view)
    }
    
    func handleFavorite(actionType:EXFavoritesActionType,coinMapSymbols:[String],callback:Handler?,in view:UIView? = nil) {
        if actionType == .other {
            let results = coinMapSymbols.joined(separator: ",")
            XUserDefault.renewFavorites(coinMapSymbols)
            
            if XUserDefault.isOffLine() {
                callback?(true)
                return
            }
            appApi.rx.request(.updateAllSymbol(symbols: results))
                .MJObjectMap(EXVoidModel.self,false)
                .subscribe(onSuccess: {(arr) in
                    callback?(true)
                }, onFailure: { error in
                    callback?(false)
                }).disposed(by: disposBag)
        }else {
            var operationType:String = ""
            var symbol:String = ""
            
            if actionType == .addBatch {
                let symbols = coinMapSymbols.joined(separator: ",")
                operationType = "0"
            }else {
                if coinMapSymbols.count == 1 {
                    symbol = coinMapSymbols[0]
                    if actionType == .singleAdd {
                        operationType = "1"
                        XUserDefault.collectionCoinMap(symbol,in: view)
                    }else if actionType == .singleDelete {
                        operationType = "2"
                        XUserDefault.cancelCollectionCoinMap(symbol,in: view)
                    }
                }
            }
            if XUserDefault.isOffLine() {
                tip(actionType: actionType,in: view)
                callback?(true)
                return
            }
            if symbol.isEmpty {
                return
            }
            appApi.rx.request(.update_symbol(operationType: operationType, symbols:symbol))
                .MJObjectMap(EXVoidModel.self,false)
                .subscribe(onSuccess: { [weak self, weak view](arr) in
                    self?.tip(actionType: actionType, in: view)
                    callback?(true)
                }, onFailure: { _ in
                    callback?(false)
                }).disposed(by: disposBag)
        }
    }
    
    func tip(actionType:EXFavoritesActionType,in view:UIView? = nil){
        if actionType == .singleDelete {
            EXAlert.showSuccess(msg: "kline_tip_removeCollectionSuccess".localized(),in: view)
        }else {
            EXAlert.showSuccess(msg: "kline_tip_addCollectionSuccess".localized(),in: view)
        }
    }
    
    func syncUserSysmbols()  {
        
        if XUserDefault.getToken() == nil { return }
        appApi.rx.request(.listSymbal)
            .subscribe(onSuccess: { [weak self] (Response) in
                
                let json = try? JSONSerialization.jsonObject(with: Response.data, options: .allowFragments)
                as? [String: Any]
                if let data = json?["data"] as? [String:Any]{
                    let symbols = data["symbols"] as? [String]
                    if let sync_status = data["sync_status"] as? String {
                        if sync_status == "0" {
                            self?.storeUserSymbolList(data: symbols ?? [])
                        }else if sync_status == "1" {
                            self?.overlayLocaldata(data: symbols ?? [])
                        }
                    }
                }}, onFailure: { error in
                    print("error--",error)
                }).disposed(by: disposBag)
    }
    
    private func overlayLocaldata (data:[String]) {
        //Overwrite local data
        let isNeed  = isEqual(data: data)
        if isNeed == true { return }
        
        let originInfo = getOriginCoininfos(data: data)
        let symbols = originInfo.filter({return $0.symbol.count > 0}).map({return $0.symbol})
        
        XUserDefault.setValueForKey(symbols, key: XUserDefault.collectionCoinMap)
        
        if didComplete != nil {
            didComplete!()
        }
    }
    
    private func storeUserSymbolList(data:[String]) {
        //After synchronizing the local diff once, it will not be synchronized again
        
        let localInfo = getlocalSymbols()
        let originInfo = getOriginCoininfos(data: data)
        
        let originSymbolSet = Set(originInfo.map{$0.symbol})
        let localSymbolsSet = Set(localInfo.localSymbols)
        let storeInfo = localSymbolsSet.union(originSymbolSet)
        
        XUserDefault.setValueForKey(Array(storeInfo), key: XUserDefault.collectionCoinMap)
        if didComplete != nil {
            didComplete!()
        }
        let postInfo = localSymbolsSet.subtracting(originSymbolSet)
        
        let symbols = postInfo.count == 0 ? "" : postInfo.joined(separator: ",")
        if symbols.isEmpty {
            return
        }
        appApi.rx.request(.update_symbol(operationType: "0", symbols:symbols))
            .subscribe(onSuccess: { (Response) in
                
            }).disposed(by: disposBag)
        
        
    }
    //Perhaps the local storage of currency pairs names maps out all information, takes symbols, and returns tuples
    func getlocalSymbols() -> (localNames:[String],localSymbols:[String]) {
        
        let localNames:[String] = XUserDefault.getCollectionCoinMap()
        let localCoinMapEntity: [CoinMapEntity] =  EXAppMarketManager.sharedInstance.getCollectionCoinMapList(localNames)
        let localSymbols = localCoinMapEntity.map{$0.symbol}
        
        return (localNames:localNames,localSymbols:localSymbols)
    }
    
    //Based on the remote return of all syms map currency pair information
    func getOriginCoininfos(data:[String]) -> [CoinMapEntity] {
        var array = [CoinMapEntity]()
        for item in data {
            let tempItem = EXAppMarketManager.sharedInstance.getCoinMapEntityBySymbol(item)
            array.append(tempItem)
        }
        return array
    }
    
    func isEqual(data:[String]) -> Bool {
        let localInfo = getlocalSymbols()
        let originInfo = getOriginCoininfos(data: data)
        let originSymbolSet = Set(originInfo.map{$0.symbol})
        let localSymbolsSet = Set(localInfo.localSymbols)
        return originSymbolSet == localSymbolsSet
    }
    
}

