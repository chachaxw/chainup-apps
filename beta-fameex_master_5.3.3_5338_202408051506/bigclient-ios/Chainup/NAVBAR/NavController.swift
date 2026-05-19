//
//  NavController.swift
//  AppProject
//
//  Created by zewu wang on 2023/7/31.
//  Copyright © 2023年 zewu wang. All rights reserved.
//

import UIKit

class NavController: UINavigationController , UIGestureRecognizerDelegate {

    override public func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
    }
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override public func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if self.topViewController != viewController {
            super.pushViewController(viewController, animated: animated)
        }
    }
    
    override public var shouldAutorotate: Bool{
        return self.viewControllers.last!.shouldAutorotate
    }
    
    override public var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        return self.viewControllers.last!.supportedInterfaceOrientations
    }
    
    override public var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation{
        return self.viewControllers.last!.preferredInterfaceOrientationForPresentation
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
