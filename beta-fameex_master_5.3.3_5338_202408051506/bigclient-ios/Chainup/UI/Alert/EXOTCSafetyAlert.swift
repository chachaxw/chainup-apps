//
//  EXOTCSafetyAlert.swift
//  Chainup
//
//  Created by liuxuan on 2023/4/10.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

enum SafetyTypes:String {
    case nickName = "otcSafeAlert_action_nickname"
    case bindPhone = "otcSafeAlert_action_bindphone"
    case bindGoogle = "otcSafeAlert_action_bindGoogle" //Red envelope limit
    case bindGoolgeOrPhone = "otcSafeAlert_action_bindphoneOrGoogle"
    case reaName = "kyc_page_name"
    case paypwd = "otcSafeAlert_text_otcPwd"
    case payType = "noun_order_paymentTerm"
    case none = "none"
}

class SafeSetItem: NSObject{
    var isDone: Bool = false
    var title: String = ""
    var type: SafetyTypes = .none
    
    class func getItemList(safeItems:[SafetyTypes],hasPayment: Bool = false) -> [SafeSetItem]{
        let user = UserInfoEntity.sharedInstance()
        
        var temp = [SafeSetItem]()
        for (_,safeList)  in safeItems.enumerated() {
            let set = SafeSetItem()
            if safeList == .nickName {
                set.isDone = user.hasNickName()
            }else if safeList == .bindGoolgeOrPhone {
                set.isDone = (user.didBindPhone() || user.didBindGoolge())
            }else if safeList == .reaName {
                set.isDone = user.didpassRealName()
            }else if safeList == .paypwd {
                set.isDone = user.didSetPayPwd()
            }else if safeList == .payType {
                set.isDone = hasPayment
            }else if safeList == .bindGoogle {
                set.isDone = user.didBindGoolge()
            }else if safeList == .bindPhone {
                set.isDone = user.didBindPhone()
            }
            set.type = safeList
            set.title = safeList.rawValue.localized()
            temp.append(set)
        }
        return temp
    }
    
}

