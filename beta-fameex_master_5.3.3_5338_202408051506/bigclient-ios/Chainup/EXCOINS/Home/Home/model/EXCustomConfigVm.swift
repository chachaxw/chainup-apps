//
//  EXCustomConfigVm.swift
//  Chainup
//
//  Created by liuxuan on 2023/4/1.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import RxSwift
import EXKit
enum EXHomeFunctionDirection {
    case horizontal
    case vertical
}

class EXCustomConfigVm: NSObject {
    
    var customModel:EXCustomConfigModel = EXCustomConfigModel()
    let disposeBag = DisposeBag()

    
    class func shared() -> EXCustomConfigVm {
        return sharedConfig
    }
    
    private static var sharedConfig: EXCustomConfigVm = {
        let configManager = EXCustomConfigVm()
        if let cfgModel = EXCustomConfigModel.mj_object(withKeyValues: XUserDefault.getHomeCustomConfig()) {
            configManager.customModel  = cfgModel
        }
        return configManager
    }()
    
    func registerCustomConfig() {
        //Received notification of successful interface return
        EXAppConfigManager.sharedInstance.onPbV5Publish
            .subscribe(onNext: {[weak self] success in
                guard let mySelf = self else{return}
                if success {
                    mySelf.updateConfig()
                }
            }).disposed(by: disposeBag)
    }
    
    private func updateConfig() {
        let cfgStr = EXAppConfigManager.sharedInstance.getCustomConfig()
        if let cfgModel = EXCustomConfigModel.mj_object(withKeyValues: cfgStr) {
            self.customModel = cfgModel
            XUserDefault.setValueForKey(cfgStr, key:XUserDefault.homeCustomConfig)
        }
    }
    
    func showAccountUI() -> Bool  {
        if self.customModel.appIndex_assets_open == "0" {
            return false
        }
        return true
    }
    
    func customAds() -> [EXAdItem] {
        return self.customModel.appIndex_ad
    }
}

