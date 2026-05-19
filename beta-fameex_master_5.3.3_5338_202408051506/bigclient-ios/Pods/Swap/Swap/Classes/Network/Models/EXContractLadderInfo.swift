//
//  EXContractLadderInfo.swift
//  Chainup
//
//  Created by ZYJ on 2023/11/6.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
class EXContractLadderItem:EXCOBaseModel {
    // 当前阶梯等级 English: Current ladder level
    var level:String = ""
   
   //最小仓位价值 English: Minimum Position Value
   var minPositionValue = ""
  
    //最大仓位价值 English: Maximum Position Value
   var maxPositionValue = ""
    
    //维持保证金率 English: Maintain margin ratio
   var minMarginRate = ""
    
}

class EXContractLeverInfo:EXCOBaseModel {

    var lever = ""
    var minLever = ""
    var maxLever = ""
    var maxHoldAmount = ""
}

class EXContractLadderListInfo:EXCOBaseModel {
    var ladderList = [EXContractLadderItem]()

    static func modelContainerPropertyGenericClass() -> [String : Any]? {
        return ["ladderList":EXContractLadderItem.self]
    }
}

class EXContractLeverListInfo:EXCOBaseModel {
    var leverList = [EXContractLeverInfo]()
    static func modelContainerPropertyGenericClass() -> [String : Any]? {
        return ["leverList":EXContractLeverInfo.self]
    }
}

class EXContractLadderInfo: EXCOBaseModel {

    var ladderList = EXContractLadderListInfo()
    var leverCeiling = [String:NSNumber]()
    var leverList = EXContractLeverListInfo()
}

