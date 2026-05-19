//
//  EXChangeOTCEntity.swift
//  Chainup
//
//  Created by zewu wang on 2023/4/13.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
enum EXPasswordType{
    case old
    case new
    case newConfrim
}
class EXChangeOTCEntity: NSObject {

    var name = ""
    
    var placeHolder = ""
    
    var info = ""
    
    var type: EXPasswordType = .new
    
    
    class func getItemWithType(type: EXPasswordType) -> EXChangeOTCEntity{
        let v = EXChangeOTCEntity()
        var name = ""
        var placeHolder = ""
        var info = ""
        switch type {
        case .old:
            name = "original_assets_pass".localized()
            placeHolder = "hint_assets_pass_old".localized()
        case .new:
            name = "otcSafeAlert_text_otcPwd".localized()
            placeHolder = "personal_Center_text21".localized()
        case .newConfrim:
            name = "safety_text_confrimPasswod".localized()
            placeHolder = "safety_tip_inputOtcPassword".localized()
        }
        v.name = name
        v.placeHolder = placeHolder
        v.type = type
        return v
    }
    
}
