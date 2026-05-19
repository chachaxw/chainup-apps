//
//  EXHomeCache.swift
//  Chainup
//
//  Created by liuxuan on 2023/8/17.
//  Copyright © 2023 ChainUP. All rights reserved.
//

import UIKit
import EXKit
class EXHomeCache: NSObject {
    
    static let `manager` = EXHomeCache()
    open class var sharedManager: EXHomeCache {
        return manager
    }
    
    func getHomeCache()-> EXHomeIndexModel? {
        let indexData = XUserDefault.getVauleForKey(key: XUserDefault.homeCache)
        if let indexModel = EXHomeIndexModel.mj_object(withKeyValues: indexData) {
            return indexModel
        }
        return nil
    }
    
    func updateIndexModel(model:EXHomeIndexModel) {
        let savedModel = model.copyable()
        if let jsondata =  savedModel.mj_JSONData() {
            XUserDefault.setValueForKey(jsondata, key: XUserDefault.homeCache)
        }
    }
    
    func removeHomeCache() {
        XUserDefault.removeKey(key: XUserDefault.homeCache)
    }
}

      
