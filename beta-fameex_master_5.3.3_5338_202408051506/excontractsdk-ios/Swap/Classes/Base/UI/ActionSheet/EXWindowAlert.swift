//
//  EXWindowAlert.swift
//  Chainup
//
//  Created by cwd on 2022/11/22.
//  Copyright © 2022 Chainup. All rights reserved.
//

import UIKit
import EXKit
class EXWindowAlert {
    /** alert level
     多个弹窗需要并存时，使用这个控件 English: When multiple pop ups need to coexist, use this control
     */
    static let `manager` = EXWindowAlert()
    open class var shared: EXWindowAlert {
        return manager
    }
   
    var alertContentView = UIView()
   
    lazy var alertWindow: UIWindow = {
        let alertWindow = UIWindow()
        alertWindow.frame = UIApplication.shared.keyWindow!.frame
        alertWindow.backgroundColor = UIColor.ThemeView.mask
        alertWindow.windowLevel = UIWindow.Level.alert
        alertWindow.makeKeyAndVisible()
        return alertWindow
    }()
    
    func show(view: UIView){
        self.alertContentView = view
        self.alertWindow.isHidden = false
        self.alertWindow.addSubview(view)
    }
    
    func dissmiss(){
        self.alertContentView.removeFromSuperview()
        self.alertWindow.isHidden = true
    }
}


class EXWindowNormal {
    /** normal level
     多个弹窗需要并存时，使用这个控件 English: When multiple pop ups need to coexist, use this control
     */
    static let `manager` = EXWindowNormal()
    open class var shared: EXWindowNormal {
        return manager
    }
    var alertContentView = UIView()
    lazy var normalWindow: UIWindow = {
        let alertWindow = UIWindow()
        alertWindow.frame = UIApplication.shared.keyWindow!.frame
        alertWindow.backgroundColor = UIColor.ThemeView.mask
        alertWindow.windowLevel = UIWindow.Level.normal
        alertWindow.makeKeyAndVisible()
        return alertWindow
    }()
    func show(view: UIView){
        self.alertContentView = view
        self.normalWindow.isHidden = false
        self.normalWindow.addSubview(view)
    }
    
    func dissmiss(){
        self.alertContentView.removeFromSuperview()
        self.normalWindow.isHidden = true
    }
}


