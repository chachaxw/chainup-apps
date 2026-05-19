//
//  EXInvitationDetailModel.swift
//  Chainup
//
//  Created by chainup on 2023/8/31.
//  Copyright © 2023 ChainUP. All rights reserved.
//

import UIKit

class EXInvitationPerson: EXBaseModel {
    
    var levelZeroRegisterUid:String = ""//Registrant uid
    
    var registerTime:String = ""//Registration timestamp (full time, format required for front-end processing)
    var email = ""
    var mobileNumber:String = ""//Account phone number/email desensitization display
    
    func accountName() -> String {
        if !mobileNumber.isEmpty {
            return mobileNumber
        }
        return email
    }
}

class EXInvitationPersonsModel:EXBaseModel {
    
    var invitationList:[EXInvitationPerson] = []
    override func mj_keyValuesDidFinishConvertingToObject() {
        self.invitationList = EXInvitationPerson.mj_objectArray(withKeyValuesArray: self.invitationList).copy() as! [EXInvitationPerson]
    }
}


class EXInvitationRewardDetailsModel: EXBaseModel {
    var rewardList:[EXInvitationRewardDetail] = []
    override func mj_keyValuesDidFinishConvertingToObject() {
        self.rewardList = EXInvitationRewardDetail.mj_objectArray(withKeyValuesArray: self.rewardList).copy() as! [EXInvitationRewardDetail]
    }
}
class EXInvitationRewardDetail:EXBaseModel {
    var conversionAmount:String = ""//Equivalent USDT amount
    
    var rewardUid:String = ""//The recipient of the reward, which is the current login uid
    
    var sendTime:String = ""//Complete timestamp, intercepted by the front-end itself

    var userAccountNum:String = ""//Register an account for desensitization
}

