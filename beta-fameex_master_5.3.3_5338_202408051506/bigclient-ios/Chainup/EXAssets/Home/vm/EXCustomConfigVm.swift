//
//  EXCustomConfigVm.swift
//  Chainup
//
//  Created by liuxuan on 2020/4/1.
//  Copyright © 2020 zewu wang. All rights reserved.
//

import UIKit

class EXCustomConfigVm: NSObject {
    
    var customModel:EXCustomConfigModel = EXCustomConfigModel()
    
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
