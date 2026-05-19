//
//  EXConst.swift
//  Chainup
//
//  Created by cwd on 2023/8/23.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit

enum EXNoti: String {
    case logOut = "logOut"
    case lanDownloadSuccess = "lanDownloadSuccess"
    case lanDownloadFail = "lanDownloadFail"
    case loginSuccess = "EXLoginSuccess"
    case logout  = "Logout_notification_name"
    case getUserInfoSuccess = "EXGetUserInfoSuccess"
    case cancelLogin = "EXCancelLogin"
    var notiName: Notification.Name {
        return Notification.Name(rawValue: self.rawValue)
    }
}

class NotificationCenterTool{
    static func postNoti(noti: EXNoti){
        NotificationCenter.default.post(name: EXNoti.logOut.notiName, object: nil)
    }
    
    
    
}
