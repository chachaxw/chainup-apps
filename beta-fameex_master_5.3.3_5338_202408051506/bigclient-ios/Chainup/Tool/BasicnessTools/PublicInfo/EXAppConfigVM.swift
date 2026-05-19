//
//  EXAppConfigVM.swift
//  Chainup
//
//  Created by liuxuan on 2023/9/7.
//  Copyright © 2023 ChainUP. All rights reserved.
//

import UIKit
import EXKit


class AppConfigLan : EXBaseModel{
    var defLan:String = ""
    var lanList:[AppCfgLanListItem] = []
    
    override func mj_keyValuesDidFinishConvertingToObject() {
        self.lanList = AppCfgLanListItem.mj_objectArray(withKeyValuesArray: lanList).copy() as! [AppCfgLanListItem]
    }
}

class AppPersonalTitleItem:EXBaseModel {
    var assets:String = ""
    var contract:String = ""
    var fiat:String = ""
    var exchange:String = ""
    var home:String = ""
    var quotes:String = ""
}

class EXAppConfigVM: NSObject {
    var cfgModel:EXAppConfigModel = EXAppConfigModel()
    var languageModel:AppConfigLan?
    var registTypes:[String] = []
    var leverProtocolUrl:String = ""
    var tabbarTitleItem:AppPersonalTitleItem?
    
    func appConfigVmWith(config:EXAppConfigModel) {
        self.cfgModel = config
        self.languageModel = AppConfigLan.mj_object(withKeyValues: config.lan)
        let lan = LanguageHandler.priviatePhoneLanguage
        self.registTypes.removeAll()
        if let allregTypes = config.user_reg_type.mj_JSONObject() as? [String:Any] {
            for (key,value) in allregTypes {
                if key == lan {
                    if let types = value as? [Int] {
                        self.registTypes = types.map({ (item) -> String in
                            return "\(item)"
                        })
                    }
                }
            }
        }
        
        if let leverUrl = config.protocol_url_list[lan] as? String {
            self.leverProtocolUrl = leverUrl
        }
        
        if let titleInfo = config.app_personal_title[lan] as? [String:Any] {
            self.tabbarTitleItem = AppPersonalTitleItem.mj_object(withKeyValues: titleInfo)
        }
        
    }
}
