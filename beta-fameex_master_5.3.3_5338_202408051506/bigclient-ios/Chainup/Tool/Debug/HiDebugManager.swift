//
//  HiDebugManager.swift
//  Chainup
//
//  Created by liuxuan on 2023/2/27.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

struct HiDebugNotification {
    static let HiDebugDidShakingNotification = "com.hiex.ShakingNotification"
}



class HiDebugManager: NSObject {
    static let `manager` = HiDebugManager()
    open class var sharedManager: HiDebugManager {
        return manager
    }
    
    func startListeningShake() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleShake),
            name: NSNotification.Name(rawValue: HiDebugNotification.HiDebugDidShakingNotification),
            object: nil)
    }
    
    @objc func handleShake(_ notification: Foundation.Notification) {
        
        let test = HiDebugHubController .instanceFromStoryboard(name: "HiDebug")
        
        var presented = UIApplication.shared.keyWindow?.rootViewController
        
        while let vc = presented?.presentedViewController {
            presented = vc
        }
        
        let nav = UINavigationController.init(rootViewController: test)
        nav.modalTransitionStyle = .crossDissolve
        nav.modalPresentationStyle = .fullScreen
        if presented?.isKind(of: UINavigationController.self) == true {
            let rootvc: UIViewController = (presented as! UINavigationController).viewControllers[0]
            if !(rootvc .isKind(of: HiDebugHubController.self)) {
                presented?.present(nav, animated: true, completion: nil)
            }
        } else if !((presented?.isKind(of: HiDebugHubController.self))!) {
            presented?.present(nav, animated: true, completion: nil)
        }
    }
}
