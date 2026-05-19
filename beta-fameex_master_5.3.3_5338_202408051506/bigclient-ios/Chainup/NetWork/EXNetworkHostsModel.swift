//
//  EXNetworkHostsModel.swift
//  Chainup
//
//  Created by liuxuan on 2023/11/6.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

class EXSpecialModel:EXBaseModel {
    var host:String = ""
    var force_domain:String = ""
    var cer:String = ""
    var isRoot:Bool = true
}

class EXTestModel:EXBaseModel {
    var host:String = ""
    var saas_domain:String = ""
    var saas_cer_fileName:String = ""
}

class EXLinkModel: EXBaseModel {
    var hostName:String = ""
    var hostFileName:String = ""
}

class EXNetworkHostsModel: EXBaseModel {
    var special_list:[EXSpecialModel] = []
    var test_list:[EXTestModel] = []
    var links:[EXLinkModel] = []
    var ws_links:[EXLinkModel] = []

    var saas_domain:String = ""
    var saas_cer_fileName:String = ""
    var android_on:Bool = false
    var ios_on:Bool = true
    var retryCount: Int = 5
    var retryInterval: Int = 10
    var differance: Int = 500
    var merge_open:String = "0"
    
    override func mj_keyValuesDidFinishConvertingToObject() {
        self.special_list = EXSpecialModel.mj_objectArray(withKeyValuesArray: self.special_list).copy() as! [EXSpecialModel]
        self.test_list = EXTestModel.mj_objectArray(withKeyValuesArray: self.test_list).copy() as! [EXTestModel]
        self.links = EXLinkModel.mj_objectArray(withKeyValuesArray: self.links)?.copy() as! [EXLinkModel]
        self.ws_links = EXLinkModel.mj_objectArray(withKeyValuesArray: self.ws_links)?.copy() as! [EXLinkModel]
    }
}

