//
//  EXAgentIndexModel.swift
//  Chainup
//
//  Created by liuxuan on 2023/5/3.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

class EXAgentChildInfo: EXBaseModel {
    var count_agent:String = ""//Number of sub brokers
    var count_total:String = ""//Total quantity
    var count_bonus:String = ""//Total number of commission rebates
    var count_common:String = ""//Number of direct customers
}

class EXAgentBonusInfo: EXBaseModel {
    var amount_b_yesterday_rate:String = ""//Increase compared to the previous day
    var amount_b_yesterday:String = ""//Amount of the previous day
    var amount_total:String = ""//Total amount
    var amount_yesterday_rate:String = ""//Yesterday's increase compared to the previous day
    var amount_yesterday:String = ""//Yesterday's amount
}

class EXAgentUserReturn: EXBaseModel {
    var amount:String = ""//Increase compared to the previous day
    var username:String = ""//Amount of the previous day
}

class EXBounsWeek: EXBaseModel {
    var amount:String = ""//amount
    var time:String = ""//time stamp
}

class EXScaleInfo: EXBaseModel {
    var scale_return:String = ""//Rebate sharing ratio
    var scale_sub:String = ""//Proportion of commission sharing
    var scale_second:String = ""//Secondary rebates
}

class EXUserSub:EXBaseModel {
    var amount:String = ""
    var username:String = ""
}

enum CoAgentScaleType {
    case scaleReturn
    case scaleSub
    case scaleSecond
}


class EXAgentIndexModel: EXBaseModel {
    var child_info:EXAgentChildInfo = EXAgentChildInfo()//Subordinate situation
    var bonus_info:EXAgentBonusInfo = EXAgentBonusInfo()//Refund of commission situation
    var user_return:[EXAgentUserReturn] = []//Direct customer ranking
    var bonus_week:[EXBounsWeek] = []//Share ratio
    var scale_info:EXScaleInfo = EXScaleInfo()//Share ratio
    var user_sub:[EXUserSub] = [] //Ranking of sub brokers
    var role_name:String = ""
    
    override func mj_keyValuesDidFinishConvertingToObject() {
        self.user_return = EXAgentUserReturn.mj_objectArray(withKeyValuesArray: self.user_return).copy() as! [EXAgentUserReturn]
        self.bonus_week = EXBounsWeek.mj_objectArray(withKeyValuesArray: self.bonus_week).copy() as! [EXBounsWeek]
        self.user_sub = EXUserSub.mj_objectArray(withKeyValuesArray: self.user_sub).copy() as! [EXUserSub]
    }
    
    func getScaleTypes() -> [CoAgentScaleType]{
        var types:[CoAgentScaleType] = [.scaleReturn]
        if scale_info.scale_sub.count > 0, scale_info.scale_sub != "0" {
            types.append(.scaleSub)
        }
        if scale_info.scale_second.count > 0, scale_info.scale_second != "0" {
            types.append(.scaleSecond)
        }
        return types
    }
}


class EXAgentContractModel: EXBaseHanyJsonModel {
    var scaleReturn :String = "" //Direct push commission rebate (if it is a very poor broker, then the commission rebate ratio)
    var scaleSecond :String = ""//Secondary rebates
    var scaleSub :String = "" //Sub brokerage commission
    var countAgent :String = ""//Number of customers
    var amountTotal :String = "" //Accumulated commission conversion (USDT)
    var amountYesterday :String = ""//Yesterday's commission conversion (USDT)
    var amountBYesterday :String = ""//Previous day's commission conversion (USDT)
    var roleName :String = "" //Role Name
    var scaleInfo: [ScalceInfoItem]? //Rebate ratio
    var roleType :Int = 0 //Role Type (0: Proportional Broker, 1: Extreme Broker)
    
    func rebateRate() -> String { //Rebate ratio
        if var arr = scaleInfo, arr.count > 0 {
            arr = arr.sorted(by: { a, b in
                return a.scale < b.scale
            })
            if let first = arr.first,let last = arr.last{
                //Max==Min
                if first.scale != last.scale {
                    return first.scale.bigMul("100") + "%～" + last.scale.bigMul("100") + "%"
                }else{
                    return first.scale.bigMul("100") + "%"
                }
            }
        }
        return ""
    }
    
}
class EXAgentStatus: EXBaseModel{ ///Is it a contract broker and does not return any data
    var uid: Int = 0
    var pid: Int = 0 //Superior uid
    var roleId: Int = 0 //Contract Broker Role ID
    var roleName: String = "" //Contract Broker Role Name
    var status: Int = -1//Status 0. Invalid 1. Valid
}


class ScalceInfoItem: EXBaseHanyJsonModel{
    var level: String = ""
    var scale: String = ""
}



class EXInviteSwitchVoModel: EXBaseModel {
    
    var invitationSwitch: String = "0" // 邀请奖励总开关 0 关， 1 开
    
    var isOpenInvitation : Bool {
        return invitationSwitch == "1"
    }
    
}


