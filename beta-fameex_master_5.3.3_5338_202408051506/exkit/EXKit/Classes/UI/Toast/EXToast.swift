////
////  EXToast.swift
////  Chainup
////
////  Created by 柴伟东 on 2022/2/28.
////  Copyright © 2022 Chainup. All rights reserved.
////


import UIKit

public class EXToast {
    
    public static func makeLoading() {
        DispatchQueue.main.async {
            TopVC()?.view.makeLoading()
        }
    }
    
    public static func makeToast(_ title: String, completion:(() -> Void)? = nil) {
        DispatchQueue.main.async {
            TopVC()?.view.makeToast(title, completion: completion)
        }
    }
    
    public static func hideProgressHUD(_ animated: Bool = true) {
        DispatchQueue.main.async {
            TopVC()?.view.hideProgressHUD(animated)
        }
    }
    
}
