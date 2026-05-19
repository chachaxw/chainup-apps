//
//  EXAgreementEtfModel.swift
//  Chainup
//
//  Created by liuxuan on 2023/5/25.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit

enum ETFAgreementState:String {
    case notAgree = "0"
    case pendingKyc = "1"
    case needKYC = "2"
    case notAllowedCountry = "3"
    case success = "4"
}

class EXAgreementEtfModel: EXBaseModel {
    /*
0 unread
1 KYC certification in progress
2 requires kyc
3 Restricted Areas Prohibited Transactions
4 Direct transactions*/
    var status:String = ""
}

