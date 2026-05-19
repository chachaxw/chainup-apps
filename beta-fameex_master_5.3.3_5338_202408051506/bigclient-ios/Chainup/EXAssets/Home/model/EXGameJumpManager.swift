//
//  EXGameJumpManager.swift
//  Chainup
//
//  Created by ljw on 2023/3/15.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit
class EXGameJumpManager: EXBaseModel {
    var paraDic : [String : String]?
    static let shareInstance : EXGameJumpManager = EXGameJumpManager()
    //Game login authorization
    func presentAuthorVc() {
        if self.paraDic != nil && XUserDefault.getToken() != nil && UserInfoEntity.sharedInstance().mobileNumber.count > 0{
             let vc = EXGameAuthorVc()
             vc.providesPresentationContextTransitionStyle = true
             vc.definesPresentationContext = true
             vc.modalPresentationStyle = .overCurrentContext
              guard let appDelegate = UIApplication.shared.delegate else {
                  return
              }
            appDelegate.window??.rootViewController?.present(vc, animated: true, completion:nil)
        }
       
    }
}

