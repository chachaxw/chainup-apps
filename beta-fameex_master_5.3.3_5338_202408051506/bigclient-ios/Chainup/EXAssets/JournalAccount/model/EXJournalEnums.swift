//
//  EXJournalEnums.swift
//  Chainup
//
//  Created by liuxuan on 2023/5/18.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

enum EXJournalListSceneKey : String {
    case withdraw = "withdraw"
    case internalTransfer = "inner_withdraw"
    case deposit = "deposit"
    case otctransfer = "otc_transfer"
    case none = "noscene"
    
    var display: String{
        switch self {
        case .withdraw:
            return "assets_action_withdraw".localized()
        case .internalTransfer:
            return "assets_action_internalTransfer".localized()
        case .deposit:
            return "assets_action_chargeCoin".localized()
        default:
            return ""
        }
    }
}

enum EXWithDrawVerifyStep : String {
    case notStated = "0" //Unaudited
    case verified = "1" //Reviewed
    case reject = "2" //Audit Reject
    case duringPayment = "3" //Payment in progress
    case paymentFail = "4" //Payment failed
    case complete = "5" //Completed
    case canceled = "6" //rescinded

}


