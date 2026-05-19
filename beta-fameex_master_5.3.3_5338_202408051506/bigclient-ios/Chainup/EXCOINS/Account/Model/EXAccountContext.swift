//
//  EXAccountContext.swift
//  Chainup
//
//  Created by wangdong on 2023/9/23.
//  Copyright © 2023 ChainUP. All rights reserved.
//

import UIKit

enum EXAccountContextType {
    case regist
    case login
    case reset
}

class EXAccountContext: NSObject {
    var account = ""
    var countryCode = ""
    var signType: EXAccountSignUpType?
    var type: EXAccountContextType
    var token = ""
    var password = ""
    var invitationCode_required = "0"


//    var verifyCode = ""
//    var isCertificateNumber = "0"
//    var isGoogleAuth = "0"
    
//    var resetPasswordStepOneDataModel :EXResetPasswordStepOneDataModel?
    
    var desensitizedAccount: String {
        if signType == .mail {
            return account.desensitizedMail()
        }
        else if signType == .phone {
            return account.desensitizedPhone()
        }
        else {
            return account
        }
    }

    var mailAccount: String {
        if signType == .mail {
            return account
        }
        else {
            return ""
        }
    }
    
    var phoneAccount: String {
        if signType == .phone {
            return account
        }
        else {
            return ""
        }
    }
    
    required init(type: EXAccountContextType) {
        self.type = type
    }
}
