////
////  EXToast.swift
////  Chainup
////
////  Created by 柴伟东 on 2022/2/28.
////  Copyright © 2022 Chainup. All rights reserved.
////


import UIKit

class EXToast {
    
    static func makeLoading() {
        DispatchQueue.main.async {
            TopVC()?.view.makeLoading()
        }
    }
    
    static func makeToast(_ title: String, completion:(() -> Void)? = nil) {
        DispatchQueue.main.async {
            TopVC()?.view.makeToast(title, completion: completion)
        }
    }
    
    static func hideProgressHUD(_ animated: Bool = true) {
        DispatchQueue.main.async {
            TopVC()?.view.hideProgressHUD(animated)
        }
    }
    
}
