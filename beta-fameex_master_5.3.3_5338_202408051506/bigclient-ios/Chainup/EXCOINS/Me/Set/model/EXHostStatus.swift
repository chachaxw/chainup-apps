//
//  EXHostStatus.swift
//  Chainup
//
//  Created by chainup on 2023/6/17.
//  Copyright © 2023 ChainUP. All rights reserved.
//

import UIKit
import EXKit
enum EXHostStatus {

    case none
    case testing
    case success
    case unusable
}

struct EXHostEntity {
    var status:EXHostStatus = .none {
        didSet {
            if status == .unusable {
                apiRtt = "customSetting_action_unusable".localized()
                rttColor = UIColor.ThemeState.fail
                wsRtt = "customSetting_action_unusable".localized()
                wsrttColor = UIColor.ThemeState.fail
            }else if status == .testing {
                apiRtt = "customSetting_action_testing".localized()
                rttColor = UIColor.ThemeLabel.colorMedium
                wsRtt = "customSetting_action_testing".localized()
                wsrttColor = UIColor.ThemeLabel.colorMedium
            }

        }
    }
    var host = ""
    var responseTimeStr = ""
    var selected:Bool = false
    var wsSelected:Bool = false
    var apiRtt:String = "--"
    var wsRtt:String = "--"
    var rttColor:UIColor = UIColor.ThemeLabel.colorMedium
    var wsrttColor:UIColor = UIColor.ThemeLabel.colorMedium
    var apiTime:String = "--"
    var wsTime:String = "--"

    func statusStr() ->String {
        switch status {
        case .testing:
            return LanguageTools.getString(key: "customSetting_action_testing")
        case .success:
            return "\(LanguageTools.getString(key: "customSetting_action_response"))\(responseTimeStr)"
        case .unusable:
            return LanguageTools.getString(key: "customSetting_action_unusable")
        default:
           return ""
        }
    }
}
