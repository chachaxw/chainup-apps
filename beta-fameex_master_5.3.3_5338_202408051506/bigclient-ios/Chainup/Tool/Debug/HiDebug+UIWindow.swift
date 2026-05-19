//
//  HiDebug+UIWindow.swift
//  Chainup
//
//  Created by liuxuan on 2023/2/27.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

/// Post shaking notification while fetching motion event.
public extension UIWindow {
    
    open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        
        if let event = event {
            if event.type == UIEvent.EventType.motion && event.subtype == .motionShake {
                NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: HiDebugNotification.HiDebugDidShakingNotification), object: self)
            }
        }
    }
}

