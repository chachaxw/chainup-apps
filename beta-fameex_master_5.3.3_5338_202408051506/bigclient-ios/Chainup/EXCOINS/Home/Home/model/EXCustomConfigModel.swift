//
//  EXCustomConfigModel.swift
//  Chainup
//
//  Created by liuxuan on 2023/4/1.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

class EXAdItem: EXBaseModel {
    var url = ""
    var img = ""
}

class EXCustomConfigModel: EXBaseModel {
    var kyc_singapore_open:String = ""
    var appIndex_assets_open:String = "" //If the configuration is 0, do not display the homepage asset module
    var home_tool_vertical:String = "" //Configure 0, sort horizontally
    var appIndex_ad:[EXAdItem] = []
    
    override func mj_keyValuesDidFinishConvertingToObject() {
        self.appIndex_ad = EXAdItem.mj_objectArray(withKeyValuesArray: self.appIndex_ad).copy() as! [EXAdItem]
    }
}

class EXCustomJsonModel : EXBaseModel {
    var custom_congfig:String = ""
    var customModel:EXCustomConfigModel = EXCustomConfigModel()
    
    override func mj_keyValuesDidFinishConvertingToObject() {
        self.customModel = EXCustomConfigModel.mj_object(withKeyValues: self.custom_congfig)
    }
    
}

