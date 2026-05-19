//
//  EXTradeOrderHandler.swift
//  Chainup
//
//  Created by liuxuan on 2023/10/30.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import RxSwift
import EXKit
class EXTradeOrderHandler: NSObject {
    let disposeBag = DisposeBag()
    var onCreateSuccessCallback:((EXCurrentEntrustEntity)->())?
    var onCancelSuccessCallback:((EXCurrentEntrustEntity)->())?
    var onErrorCallback:(()->())?
    var requesting = false

    func createOrder(side: String, type: String, volume: String, price: String, entity: CoinMapEntity,isLever:Bool =  false ) {
        if type == "1"{//Limit trading
            if NSString.init(string: price).subtracting(entity.limitPriceMin, decimals: 18).contains("-"){
                EXAlert.showFail(msg: LanguageTools.getString(key: "common_tip_limitMinTransactionPrice") + " " + String(describing: NSString.init(string: entity.limitPriceMin).decimalString(18)!))
                return
            }
            if NSString.init(string: volume).subtracting(entity.limitVolumeMin, decimals: 18).contains("-"){
                EXAlert.showFail(msg: LanguageTools.getString(key: "common_tip_limitMaxTransactionVolume") + " " + String(describing: NSString.init(string: entity.limitVolumeMin).decimalString(18)!))
                return
            }
        }else{//Market value trading
            if side == "BUY"{
                if NSString.init(string: volume).subtracting(entity.marketBuyMin, decimals: 18).contains("-"){
                    EXAlert.showFail(msg: LanguageTools.getString(key: "common_tip_limitMinTransactionPrice") + " " +  String(describing: NSString.init(string: entity.marketBuyMin).decimalString(18)!))
                    return
                }
            }else{
                if NSString.init(string: volume).subtracting(entity.marketSellMin, decimals: 18).contains("-"){
                    EXAlert.showFail(msg: LanguageTools.getString(key: "common_tip_limitMaxTransactionVolume") + " " + String(describing: NSString.init(string: entity.marketSellMin).decimalString(18)!))
                    return
                }
            }
        }
        if requesting {
            return
        }
        requesting = true
        let params:[String:String] = ["side":side,"type":type,"volume":volume,"price":price,"symbol":entity.symbol]
        if isLever {
            EXTracking.shared.track(event: .trackLeverCreate, info: params)
            appApi.rx.request(.creatLeverOrder(side: side,
                                               type: type,
                                               volume: volume,
                                               price: price,
                                               symbol:entity.symbol))
                .MJObjectMap(EXCurrentEntrustEntity.self)
                .subscribe(onSuccess: {[weak self] (m) in
                    guard let mySelf = self else {return}
                    mySelf.preAddOrder(symbol: entity.symbol, model: m,isLever: true)
                    mySelf.requesting = false
                }) {[weak self] (error) in
                    guard let mySelf = self else {return}
                    mySelf.requesting = false
                    mySelf.onErrorCallback?()
                }.disposed(by: disposeBag)
        }else {
            EXTracking.shared.track(event: .trackOrderCreate, info: params)
            appApi.rx.request(.createOrder(side: side ,
                                           type: type ,
                                           volume: volume ,
                                           price: price ,
                                           symbol: entity.symbol))
                .MJObjectMap(EXCurrentEntrustEntity.self)
                .subscribe(onSuccess: {[weak self] (m) in
                    guard let mySelf = self else {return}
                    mySelf.preAddOrder(symbol: entity.symbol, model: m)
                    mySelf.requesting = false
                }){[weak self] (error) in
                    guard let mySelf = self else {return}
                    mySelf.onErrorCallback?()
                    mySelf.requesting = false
                }.disposed(by: self.disposeBag)
        }
    }
    
    func preAddOrder(symbol:String,model:EXCurrentEntrustEntity,isLever:Bool = false) {
        cancelOrderRequest(isLever)
        EXAlert.showSuccess(msg: LanguageTools.getString(key: "contract_tip_submitSuccess"))
        self.onCreateSuccessCallback?(model)
    }
    
    func cancelOrderRequest(_ isLever:Bool = false) {
//        appApi.session.getTasksWithCompletionHandler { dataTasks, uploadTasks, downloadTasks in
//            dataTasks.forEach {
//                //Only cancel requests for the specified URL
//                if isLever {
//                    let url = EXNetworkDoctor.sharedManager.getAppAPIHost() + "lever/order/list/new"
//                    if ($0.originalRequest?.url?.absoluteString == url) {
//                        $0.cancel()
//                    }
//                }else {
//                    let url = EXNetworkDoctor.sharedManager.getAppAPIHost() + "order/list/new"
//                    if ($0.originalRequest?.url?.absoluteString == url) {
//                        $0.cancel()
//                    }
//                }
//            }
//        }
    }
    
    func cancelOrder(entity: EXCurrentEntrustEntity,isLever:Bool = false ) {
        if entity.status == "0" || entity.status == "1" || entity.status == "3"{
            
            let params:[String:String] = ["orderId":entity.id,
                                          "symbol":(entity.baseCoin + entity.countCoin).lowercased()]

            if isLever {
                EXTracking.shared.track(event: .trackLeverCancel, info: params)

                appApi.rx.request(.cancelLeverOrder(orderId: entity.id,
                                               symbol: (entity.baseCoin + entity.countCoin).lowercased()))
                    .MJObjectMap(EXVoidModel.self)
                    .subscribe(onSuccess: {[weak self] (m) in
                        guard let mySelf = self else {return}
                        mySelf.cancelOrderSuccess(model: entity)
                    }) {[weak self] (error) in
                        guard let mySelf = self else {return}
                        mySelf.onErrorCallback?()
                    }.disposed(by: disposeBag)
            }else {
                EXTracking.shared.track(event: .trackOrderCancel, info: params)
                appApi.rx.request(.cancelOrder(orderId: entity.id,
                                                    symbol: (entity.baseCoin + entity.countCoin).lowercased()))
                    .MJObjectMap(EXVoidModel.self)
                    .subscribe(onSuccess: {[weak self] (m) in
                        guard let mySelf = self else {return}
                        mySelf.cancelOrderSuccess(model: entity)
                    }) {[weak self] (error) in
                        guard let mySelf = self else {return}
                        mySelf.onErrorCallback?()
                    }.disposed(by: disposeBag)
            }

        }
    }
    
    func cancelOrderSuccess(model:EXCurrentEntrustEntity) {
        cancelOrderRequest()
        EXAlert.showSuccess(msg: LanguageTools.getString(key: "common_tip_cancelSuccess"))
        self.onCancelSuccessCallback?(model)
    }
    
}

