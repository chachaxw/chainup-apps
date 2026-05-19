//
//  EXETFRecordModel.swift
//  Chainup
//
//  Created by youbin on 2023/6/9.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import EXKit

class EXETFRecordModel: EXBaseModel {
    
    var count = ""
    var etfPositionRecordList:[EXETFRecordListItem] = []
    
    override func mj_keyValuesDidFinishConvertingToObject() {
        self.etfPositionRecordList = EXETFRecordListItem.mj_objectArray(withKeyValuesArray: self.etfPositionRecordList).copy() as! [EXETFRecordListItem]
    }
    
}

class EXETFRecordListItem: EXBaseModel {
    var symbol              : String = ""
    var base                : String = ""
    var quote               : String = ""
    var netValue            : String = ""
    
    var beforeContractValue : String = ""
    var afterContractValue  : String = ""
    var beforeLever         : String = ""
    var afterLever          : String = ""
    var type                : String = ""  //0 irregular warehouse adjustment 1 timed warehouse adjustment
    var adjustTime          : String  = ""
    
    var adjustDate          : String {
        get {
            if adjustTime.count > 0 {
               return DateTools.strToTimeString(adjustTime)
            } else {
                return "--"
            }
        }
    }
    
    
}

