//
//  EXInvitationPageModel.swift
//  Chainup
//
//  Created by chainup on 2023/8/28.
//  Copyright © 2023 ChainUP. All rights reserved.
//

import UIKit

///
class EXInvitationPublicConfigModel: EXBaseModel {
    var inviteUrl: String = ""
    var inviteCode: String = ""
    var inviteUserDirectCount: String = ""
    var inviteUserSubOneCount: String = ""
    
    var inviteUserSubTwoCount: String = ""
    var inviteRewardUsdtSum: String = ""
    var topReferrerRewardAmount: String = ""
    var config: EXInvitationConfigModel = EXInvitationConfigModel()
    
    var inviteUserCount: String? {
       return inviteUserDirectCount.bigAdd(inviteUserSubOneCount).bigAdd(inviteUserSubTwoCount)
    }
}


class EXInvitationConfigModel: EXBaseModel {
    var id: Int?
    var langKey: String?
    var appBannerImg: String?
    var pcHeaderIndexImg: String?
    var faceToFaceImg: String?
    var posterOneImg: String?
    var posterTwoImg: String?
    var headingText: String?
    var subheadingText: String?
    var invitationRuleUrl: String?
    var coBrokerRuleUrl:String? //Contract Broker Rule Explanation Link
    var exchangeBrokerRuleUrl:String = ""//S
    var brokerId: Int?
    var `operator`: Int?
}

class EXMyInvitationModel: EXBaseModel {
    
    // 我的奖励
    var rewardList: [EXMyInvitationsItemModel] = []
    // 我的邀请
    var invitationList: [EXMyInvitationsItemModel] = []

    override func mj_keyValuesDidFinishConvertingToObject() {
        
        self.rewardList = EXMyInvitationsItemModel.mj_objectArray(withKeyValuesArray: self.rewardList).copy() as! [EXMyInvitationsItemModel]
        
        self.invitationList = EXMyInvitationsItemModel.mj_objectArray(withKeyValuesArray: self.invitationList).copy() as! [EXMyInvitationsItemModel]
    }
}



class EXMyInvitationsItemModel: EXBaseModel{
    
    // my invite
    var levelZeroRegisterUid: String?
    var levelOneInvitationUid: String?
    var registerTime: String = ""
    var levelZeroRegisterAccount: String?
    var levelOneInvitationAccount: String?
    var levelStr: String?
    
    // invite rewards
    var conversionAmount: String?
    var rewardUid: String?
    var sendTime: String = ""
    var userAccountNum: String?
    var rewardAmount: String?
    var rewardCoin: String?
    
}







class EXInvitationPageModel: EXBaseModel {
    
    var inviteUrl:String = ""
    var invitationUserCount:String = ""
    var inviteCode:String = ""
    var invitationRewardUsdtSum:String = ""
    var inviteQECode:String = ""
    var pageConfig:EXInvitationPageConfigModel = EXInvitationPageConfigModel()
}

class EXInvitationPageConfigModel: EXBaseModel {
    
    var coBrokerRuleUrl:String = ""//Contract Broker Rule Explanation Link
    var exchangeBrokerRuleUrl:String = ""//Spot Homo economicus rule description link
    var faceToFaceImg:String = ""//Face to face sharing of base map address
    var headerIndexImg:String = ""//Share the banner base image address on the homepage
    var invitationRuleUrl:String = ""//Invitation Registration Reward Rules Explanation
    var langKey:String = ""//
    var posterOneImg:String = ""//Poster 1 Image Address
    var posterTwoImg:String = ""//Poster 2 Image Address
}

class EXInvitationSpotDataModel: EXBaseModel {
    var userCount:String = "" //Total number of invitations
    
    var oneLevelScale:String = "" //First level commission rebate ratio
    
    var allBonusCoin:String = "" //Rebate currency
    
    var allBonusAmount:String = "" //Accumulated commission rebate
    
    var inviteNum:String = ""//Number of second level rebate users (not currently used)
    var agent_data_query_url = ""//Return commission record URL
    
    func scaleOfDecimal() -> String {
        return oneLevelScale.formatAmountUseDecimal("2")
    }
    
    func recordUrl() -> String {
        if agent_data_query_url.isEmpty {
            return ""
        }
        if URL(string: agent_data_query_url) != nil {
            
            if agent_data_query_url.hasPrefix("http://") {
                return agent_data_query_url;
            }else {
                return "http://" + agent_data_query_url
            }
        }
        return ""
    }
}

