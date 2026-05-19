//
//  EXSearchRecommedModel.swift
//  Chainup
//
//  Created by liuxuan on 2022/7/28.
//  Copyright © 2022 Chainup. All rights reserved.
//

import UIKit

class EXSearchRecommedModel: EXBaseModel {
    
    var recommendSymbolList :[EXHomeTicker] = []
    
    override func mj_keyValuesDidFinishConvertingToObject() {
        self.recommendSymbolList = EXHomeTicker.mj_objectArray(withKeyValuesArray: self.recommendSymbolList).copy() as! [EXHomeTicker]
    }

}
