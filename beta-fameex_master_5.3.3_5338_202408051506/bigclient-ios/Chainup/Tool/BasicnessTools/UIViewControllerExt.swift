//
//  UIViewControllerExt.swift
//  Chainup
//
//  Created by zewu wang on 2018/8/18.
//  Copyright © 2018年 zewu wang. All rights reserved.
//

import UIKit

enum EXStoryBoardName: String {
    case assets = "EXAssets"
    case accout = "EXAccount"
    case quant = "EXQuant"
}

extension UIViewController{
    
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
    
    class func createControllerFromStoryBoard<T>(name: EXStoryBoardName, type: T.Type) -> T {
        return UIStoryboard.init(name: name.rawValue, bundle: nil).instantiateViewController(withIdentifier: String(describing: type)) as! T
    }

}

extension UIViewController {
    
    func addChild(_ child:UIViewController) {
        addChildViewController(child)
        view.addSubview(child.view)
        child.didMove(toParentViewController: self)
    }
    
    func removeChild() {
        guard parent != nil else { return }
        willMove(toParentViewController: nil)
        view.removeFromSuperview()
        removeFromParentViewController()
    }
}
