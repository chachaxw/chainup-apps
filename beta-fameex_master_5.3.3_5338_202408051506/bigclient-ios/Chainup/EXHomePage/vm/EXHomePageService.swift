//
//  EXHomePageService.swift
//  Chainup
//
//  Created by liuxuan on 2023/6/4.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import Foundation
import RxSwift
import EXKit
protocol EXHomePageServiceProtocol {
    func fetchIndexV5() -> Observable<EXHomeIndexModel>
    func fetchIndexV5Caches() -> Observable<EXHomeIndexModel>
    func getPersonRateData() -> Observable<PersonCenterBanner>
}

class EXHomePageService:EXHomePageServiceProtocol {
    let disposeBag = DisposeBag()
    var tmpModel:EXHomeIndexModel?
    var personData: PersonCenterBanner?
    func fetchIndexV5() -> Observable<EXHomeIndexModel> {
        return Observable.create {[weak self] observer -> Disposable in
            guard let self = `self` else {return Disposables.create() }
            
            if self.tmpModel == nil {
                if let cache = EXHomeCache.sharedManager.getHomeCache() {
                     observer.onNext(cache)
                }
            }
            appApi.hideAutoLoading()
            appApi.rx.request(.getHome)
                .MJObjectMap(EXHomeIndexModel.self)
                .subscribe{ event in
                    switch event {
                    case .success(let model):
                        EXHomeCache.sharedManager.updateIndexModel(model: model)
                        self.tmpModel = model
                        observer.onNext(model)
                        observer.onCompleted()
                        break
                    case .failure(let err):
                        observer.onError(err)
                        break
                    }
            }.disposed(by:self.disposeBag)
            return Disposables.create()
        }
    }
    
    
    func fetchIndexV5Caches() -> Observable<EXHomeIndexModel> {
        return Observable.create { observer -> Disposable in
            if let cache = EXHomeCache.sharedManager.getHomeCache() {
                observer.onNext(cache)
            }
            return Disposables.create()
        }
    }
    
    func getPersonRateData() -> Observable<PersonCenterBanner>{
        return Observable.create {[weak self] observer -> Disposable in
            guard let self = `self` else {return Disposables.create() }
            appApi.hideAutoLoading()
            var userId: String? = nil
            if XUserDefault.getToken() != nil {
                userId = UserInfoEntity.sharedInstance().uid
            }
            appApi.rx.request(AppAPIEndPoint.getRateDiscout(userId: userId))
                .MJObjectMap(PersonCenterBanner.self,false)
                .subscribe(onSuccess: { (personData) in
                    self.personData = personData
                    observer.onNext(personData)
                    observer.onCompleted()
                }) { (error) in
                    observer.onError(error)
                }.disposed(by: self.disposeBag)
            return Disposables.create()
        }
    }
}
