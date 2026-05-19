//
//  RegionEntity.swift
//  Chainup
//
//  Created by zewu wang on 2018/8/17.
//  Copyright © 2018年 zewu wang. All rights reserved.
//

import UIKit

class RegionEntity: SuperEntity {
    
    var enName = "enName"
    
    var cnName = "cnName"
    
    var dialingCode = "dialingCode"
    
    var numberCode = "numberCode"
    
    var showName = "showName"
    
    var pinyin = ""
    
    override func setEntityWithDict(_ dict : [String : Any]){
        super.setEntityWithDict(dict)
        enName = dictContains(enName)
        cnName = dictContains(cnName)
        dialingCode = dictContains(dialingCode)
        numberCode = dictContains(numberCode)
        showName = dictContains(showName)
    }
    
}
