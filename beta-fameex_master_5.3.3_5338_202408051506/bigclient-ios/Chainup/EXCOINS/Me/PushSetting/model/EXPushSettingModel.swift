//
//  EXPushSettingModel.swift
//  Chainup
//
//  Created by liuxuan on 2023/5/22.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

class EXPushListItem: EXBaseModel {
    var title:String = ""
    var type:String = ""
    var value:String = ""
}

class EXPushSettingModel: EXBaseModel {
    var list:[EXPushListItem] = []
    var status:String = ""
    
    override func mj_keyValuesDidFinishConvertingToObject() {
        self.list = EXPushListItem.mj_objectArray(withKeyValuesArray: self.list).copy() as! [EXPushListItem]
    }
}
