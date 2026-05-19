//
//  UIViewControllerExt.swift
//  Chainup
//
//  Created by zewu wang on 2018/8/18.
//  Copyright © 2018年 zewu wang. All rights reserved.
//

import UIKit

public extension UIViewController{
    
    func popBack(_ animated : Bool = true, _ backToRoot:Bool = false ){
        if let vcs = self.navigationController?.viewControllers ,  vcs.count > 1 {
            if backToRoot {
                self.navigationController?.popToRootViewController(animated: animated)
            }else {
                self.navigationController!.popViewController(animated: animated)
            }
        } else {
            self.dismiss(animated: animated, completion: nil)
        }
    }
}
