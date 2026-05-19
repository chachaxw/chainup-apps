//
//  EXPosHistoryEnity.swift
//  Chainup
//
//  Created by lcus on 2023/10/14.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit
class EXPosHistoryBase: EXBaseModel {
    var count:Int = 0
    var pageSize:Int = 0
    var page:Int = 0
    var tipNormal:String = ""
    var tipLock:String = ""
    var tipStatus:String = ""
}



class EXPosHistoryEnity: EXPosHistoryBase {


    var posList:[EXPosHistoryItem] = []
   
    override func mj_keyValuesDidFinishConvertingToObject() {
        self.posList = EXPosHistoryItem.mj_objectArray(withKeyValuesArray: self.posList).copy() as! [EXPosHistoryItem]
        
    }
}

class EXPosHistoryPositonEnity: EXPosHistoryBase {

    var posList:[EXPosPositionHistoryItem] = []
    override func mj_keyValuesDidFinishConvertingToObject() {
        self.posList = EXPosPositionHistoryItem.mj_objectArray(withKeyValuesArray: self.posList).copy() as! [EXPosPositionHistoryItem]
        
    }
}



class EXPosHistoryItem: EXBaseModel {

    var totalUserGainAmount :String = ""
    var ltimeMillis:String = ""
    var totalAmount:String = ""
    var projectStatus:String = ""
    var baseCoin:String = ""
    var gainRate:String = ""
    var gainCoin: String = ""
    var userGainList:[UserGainList] = []
    
    var ltimetimeShow: String {
        return DateTools.strToTimeString(ltimeMillis,dateFormat: "yyyy-MM-dd")
    }
    
    override func mj_keyValuesDidFinishConvertingToObject() {
        self.userGainList = UserGainList.mj_objectArray(withKeyValuesArray: self.userGainList).copy() as! [UserGainList]
        
    }
}


class EXPosPositionHistoryItem: EXBaseModel {
    var gainCoin: String = ""
    var gainAmount :String = ""
    var revenueTimeMillis:String = ""
    var baseAmount:String = ""
    var gainRate:String = ""
    var baseCoin:String = ""
    var timeShow: String {
        return DateTools.strToTimeString(revenueTimeMillis,dateFormat: "yyyy-MM-dd")
    }
}
