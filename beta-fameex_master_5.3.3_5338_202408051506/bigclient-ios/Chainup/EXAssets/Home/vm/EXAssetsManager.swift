//
//  EXAssetsManager.swift
//  Chainup
//
//  Created by wangdong on 2023/10/10.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import RxSwift

class EXAssetsManager: NSObject {
    
    let coBalance = BehaviorSubject.init(value: "0")
    
    static let manager: EXAssetsManager = {
        let instance = EXAssetsManager()
        return instance
    }()
    
    override init() {
        super.init()
        
        if EXAppConfigManager.sharedInstance.getContractVersion() == .old {
            
            let notificationName = Notification.Name(rawValue: "SLSwapBalanceRefresh")
            _ = NotificationCenter.default.rx
                .notification(notificationName)
                .takeUntil(self.rx.deallocated)
                .subscribe(onNext: {[weak self] notification in
                    guard let `self` = self else {return}
                    guard let rst = notification.object as? String else {return}
                    self.coBalance.onNext(rst)
                })
        }
    }

    func allAssetsSignal() -> Observable<EXHomeAssetModel> {
        
        if EXAppConfigManager.sharedInstance.getContractVersion() == .old {

            return oldAssetsSignal()
        }else {
            return ttBalanceIncludeFeaturesSingle()
        }
    }
    
    private func oldAssetsSignal() -> Observable<EXHomeAssetModel> {
        
        if EXAppConfigManager.sharedInstance.didOpenContract() {
            return Observable.zip(totalAccountBalanceSingal(), coBalance).timeout(.seconds(5), scheduler: MainScheduler.instance).flatMap { tuple in
                return Observable<EXHomeAssetModel>.create { observer in
                    let (assetModel, coBalance) = tuple
                    assetModel.updateTotalBalanceWithCoBalance(cobalance: coBalance)
                    observer.onNext(assetModel)
                    observer.onCompleted()
                    return Disposables.create()
                }
            }
        }
        else {
            return totalAccountBalanceSingal()
        }
    }
    
   private func totalAccountBalanceSingal() -> Observable<EXHomeAssetModel> {
        appApi.hideAutoLoading()
        return appApi.rx.request(AppAPIEndPoint.totalAccountBalanceV5).MJObjectMap(EXHomeAssetModel.self).asObservable()
    }
    
   private func ttBalanceIncludeFeaturesSingle() -> Observable<EXHomeAssetModel> {
        appApi.hideAutoLoading()
        return appApi.rx.request(.totalAccountBalanceInduceFeatures).MJObjectMap(EXHomeAssetModel.self).asObservable()
    }
}
