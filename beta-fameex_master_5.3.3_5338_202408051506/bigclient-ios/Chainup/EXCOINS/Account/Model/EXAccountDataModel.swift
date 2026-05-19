//
//  EXAccountDataModel.swift
//  Chainup
//
//  Created by wangdong on 2023/9/24.
//  Copyright © 2023 ChainUP. All rights reserved.
//

import UIKit

class EXResetPasswordStepOneDataModel: EXBaseModel {
    var isCertificateNumber = "0"
    var isGoogleAuth = "0"
    var token = ""
}

class EXUserConfirmPwdDataModel: EXBaseModel {
    var token = ""
    var quicktoken = ""
}
