//
//  EXPosHomeTypesEntity.swift
//  Chainup
//
//  Created by lcus on 2023/10/10.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit




class EXPosHomeTypesEntity: EXBaseModel {

    var banner: String = ""
    var footTitle:String = ""
    var typeConfig: [EXPosHomeTypeItem] = []
    var detail: String = ""
    var url: String = ""
    var footBanner: String = ""
    var tipMine: String = ""
    var faqUrl:String = ""
    var contact:String = ""
    
    override func mj_keyValuesDidFinishConvertingToObject() {
        self.typeConfig = EXPosHomeTypeItem.mj_objectArray(withKeyValuesArray: self.typeConfig).copy() as! [EXPosHomeTypeItem]
        
    }
    
}

class EXPosHomeTypeItem: EXBaseModel {
    
    var langType = ""
    var typeName = ""
    var typeSn = ""
}
