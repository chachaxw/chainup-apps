//
//  EXJournalSceneModel.swift
//  Chainup
//
//  Created by liuxuan on 2023/5/6.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

class EXSceneItem:EXBaseModel {
    var key_text:String = ""
    var key:String = ""
}

class EXJournalSceneModel: EXBaseModel {
    var sceneList:[EXSceneItem] = []
    
    override func mj_keyValuesDidFinishConvertingToObject() {
        self.sceneList = EXSceneItem.mj_objectArray(withKeyValuesArray: self.sceneList).copy() as! [EXSceneItem]
    }
    
}
