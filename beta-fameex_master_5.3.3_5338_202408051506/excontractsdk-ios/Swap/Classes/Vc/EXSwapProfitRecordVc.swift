////
////  EXSwapProfitRecordVc.swift
////  Chainup
////
////  Created by ZYJ on 2023/12/18.
////  Copyright © 2023 Chainup. All rights reserved.
////
//
//import UIKit
enum EXSPositionType:Int {
    case all = 0
    case openMore
    case openEmpty

    var introduce:String {
        switch self {
        case .all:
            return "cp_order_text98".ex_localized()
        case .openMore:
           return "cp_order_text6".ex_localized()
        case .openEmpty:
           return "cp_order_text15".ex_localized()
        }
    }

    var parm:String {
        switch self {
        case .all:
            return ""
        case .openMore:
            return "BUY"
        case .openEmpty:
            return "SELL"
        }
    }
}
