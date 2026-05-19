//
//  EXHomePageListViewModel.swift
//  Chainup
//
//  Created by liuxuan on 2023/6/4.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import Foundation
import RxSwift

final class EXHomePageListViewModel {
    
    private let homepageService:EXHomePageServiceProtocol
    
    init(homepageService:EXHomePageServiceProtocol = EXHomePageService()) {
        self.homepageService = homepageService
    }
    
    func fetchHomePageViewModels() -> Observable<EXHomePageViewModel> {
        
        homepageService.fetchIndexV5().map{ EXHomePageViewModel(homepageModel: $0)}
    }
    
    func fetchHomeCachesPageViewModels() -> Observable<EXHomePageViewModel> {
        homepageService.fetchIndexV5Caches().map{ EXHomePageViewModel(homepageModel: $0)}
    }
    
    func getPersonRateData() -> Observable<PersonCenterBanner> {
        homepageService.getPersonRateData()
    }
}
