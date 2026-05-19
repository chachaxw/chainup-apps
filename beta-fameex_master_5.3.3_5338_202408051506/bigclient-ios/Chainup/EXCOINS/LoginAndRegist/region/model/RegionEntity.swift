//
//  RegionEntity.swift
//  Chainup
//
//  Created by zewu wang on 2023/8/17.
//  Copyright © 2023年 zewu wang. All rights reserved.
//

import UIKit

class RegionEntity: SuperEntity {
    
    var enName = ""
    
    var cnName = ""
    
    var dialingCode = ""
    
    var numberCode = ""
    
    var showName = ""
    
    var pinyin = ""
    
    var dialingNumber = ""
    
    override func setEntityWithDict(_ dict : [String : Any]){
        super.setEntityWithDict(dict)
        enName = dictContains("enName")
        cnName = dictContains("cnName")
        dialingCode = dictContains("dialingCode")
        numberCode = dictContains("numberCode")
        showName = dictContains("showName")
        dialingNumber = dictContains("dialingCode") + "+" + dictContains("numberCode")
    }
    
}
class RegionManager : NSObject{
    //MARK: Single Example
    public static var sharedInstance : RegionManager{
        struct Static {
            static let instance : RegionManager = RegionManager()
        }
        return Static.instance
    }
    
    var regionEntity = RegionEntity()
    
}

