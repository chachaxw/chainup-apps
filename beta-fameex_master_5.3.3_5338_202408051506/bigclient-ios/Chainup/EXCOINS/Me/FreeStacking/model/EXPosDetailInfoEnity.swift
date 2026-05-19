//
//  EXPosDetailPostionEnity.swift
//  Chainup
//
//  Created by lcus on 2023/10/11.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit


class EXPosDetailPostionEnity: EXBaseModel {
    var tipMine: String = ""
    var userGainList: [UserGainList] = []
    var shortName: String = ""
    var totalGainAmount: Double = 0.0
    var gainCoin: String = ""
    var gainRate: Double = 0.0
    var url: String = ""
    var details: String = ""
    var title: String = ""
    var logo: String = ""
    var banner: String = ""
    var totalUserGainAmount: Double = 0.0
    var projectType: Int = 0
    var info: String = ""
    var name: String = ""
    var status: Int = 0
    
    override func mj_keyValuesDidFinishConvertingToObject() {
        self.userGainList = UserGainList.mj_objectArray(withKeyValuesArray: self.userGainList).copy() as! [UserGainList]
        
    }
    
}

class EXPosDetailProtocolEnity: EXBaseModel {
    var needAuth: Int = 0
    var userGainList: [UserGainList] = []
    var gainCoin: String = ""
    var lockDay : Int = 0
    var gainRate: Double = 0.0
    var projectType: Int = 0
    var buyAmountMin: Double = 0.0
    var title: String = ""
    var ltimeMillis: String = ""
    var ltime: String = ""
    var url: String = ""
    var status: Int = 0
    var activeStatus: Int = 0
    var balance: Double = 0.0
    var name: String = ""
    var info: String = ""
    var details: String = ""
    var progress: String = ""
    var progressNum:Double = 0.0
    var etimeMillis: String = ""
    var stimeMillis: String = ""
    var shortName: String = ""
    var banner: String = ""
    var isShowBuy: Int = 0
    var tipMine: String = ""
    var totalUserGainAmount: Double = 0.0
    var totalAmount: Double = 0
    var logo: String = ""
    var iasDateMillis: String = ""
    var buyAmountMax: Double = 0.0
    var raiseAmount: Double = 0.0
    var totalGainAmount: Double = 0.0
    var currencyExchangeRate:Double = 0.0
    var remainingTimeSeconds:String = ""
    var iasDateShow: String {
       return DateTools.strToTimeString(iasDateMillis,dateFormat: "yyyy-MM-dd HH:mm")
    }
    var ltimeShow: String {
       return DateTools.strToTimeString(ltimeMillis, dateFormat: "yyyy-MM-dd HH:mm")
    }
    var etimeShow: String {
       return DateTools.strToTimeString(etimeMillis, dateFormat: "yyyy-MM-dd HH:mm")
    }
    var stimeShow: String {
        return DateTools.strToTimeString(stimeMillis,dateFormat: "yyyy-MM-dd HH:mm")
     }
    
    override func mj_keyValuesDidFinishConvertingToObject() {
        self.userGainList = UserGainList.mj_objectArray(withKeyValuesArray: self.userGainList).copy() as! [UserGainList]
        
    }
}

class UserGainList: EXBaseModel {
    var special:String?
    var gainAmount:String = ""
    var gainTime:String = ""
    var gainTimeMillis: String = ""
    var timeShow: String {
        if gainTime == "pos_string_timeEarn".localized(){
            return gainTime
        }
       return DateTools.strToTimeString(gainTimeMillis,dateFormat: "yyyy-MM-dd")
    }
    
}
