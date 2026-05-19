//
//  EXEmailResultModel.swift
//  Chainup
//
//  Created by cwd on 2023/10/11.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit

class EXEmailResultModel: EXBaseHanyJsonModel {

    var smsCodeVerifyPass: Int?//
    var emailCodeVerifyPass: Int?
    var currentEditEmailCodeVerifyPass: Int?
    var googleCodeVerifyPass: Int?
    var pass: Bool = true
    var smsCodePass: Bool {
        if let code = smsCodeVerifyPass, code == 0{
            return false
        }
        return true
    }
    var oldEmailPass: Bool {
        if let code = emailCodeVerifyPass, code == 0{
            return false
        }
        return true
    }
    var curEmailPass: Bool {
        if let code = currentEditEmailCodeVerifyPass, code == 0{
            return false
        }
        return true
    }
    var googleCodePass: Bool {
        if let code = googleCodeVerifyPass, code == 0{
            return false
        }
        return true
    }
    
    var email_ver_msg: String {
        return "email_ver_msg".localized()
    }
    var mobile_ver_msg: String {
        return "mobile_ver_msg".localized()
    }
    var google_ver_msg: String {
        return "google_ver_msg".localized()
    }
}
