//
//  EXAppUIDefines.swift
//  Chainup
//
//  Created by liuxuan on 2022/7/18.
//  Copyright © 2022 Chainup. All rights reserved.
//

import UIKit
import EXKit
let kAppdelegate: AppDelegate? = UIApplication.shared.delegate as? AppDelegate

public let isiPhoneX = iPhoneX()
public let SCREEN_WIDTH = UIScreen.main.bounds.width//Screen width
public let SCREEN_HEIGHT = UIScreen.main.bounds.height//Screen height
public let NAV_TOP : CGFloat = iPhoneX() ? 24 : 0//Distance from top
public let NAV_SCREEN_HEIGHT :CGFloat = getNavBarHeight()//UIDevice.vg_navigationFullHeight() //iPhoneX() ? 88 : 64//Navigation bar height
public let NAV_STATUS_HEIGHT :CGFloat = getStatusHeight()//UIDevice.vg_statusBarHeight() //iPhoneX() ? 44 : 20//Navigation bar height
public let TABBAR_BOTTOM : CGFloat = UIDevice.vg_safeDistanceBottom() //iPhoneX() ? 34 : 0//Distance from bottom
public let BANG_HEIGHT : CGFloat = iPhoneX() ? 44 : 0
public let CONTENTVIEW_HEIGHT :CGFloat = SCREEN_HEIGHT - NAV_SCREEN_HEIGHT
public let TABBAR_HEIGHT :CGFloat =  UIDevice.vg_tabBarFullHeight()//iPhoneX() ? 83 : 49//Tabbar height
public let TABBAR_CONTENTVIEW_HEIGHT = CONTENTVIEW_HEIGHT - TABBAR_HEIGHT//tabbar
public var MARGIN_LEFT:CGFloat = 16
public var MARGIN_LEFT_DOUBLE:CGFloat = 32


public let StoryBoardNameMarket = "Market"
public let StoryBoardNameOTC = "EXOTC"
public let StoryBoardNameAsset = "EXAssets"
public let StroyBoardNameGrid = "EXGrid"



func iPhoneX() -> Bool {
    if #available(iOS 11, *) {
        let window = _keywindow()
        return window?.safeAreaInsets.bottom ?? 0 > 0
    } else {
        return false
    }
}

func _keywindow() -> UIWindow? {
    return  UIApplication.shared.windows.first
//    if #available(iOS 13.0, *) {
//        for windowScene:UIWindowScene in ((UIApplication.shared.connectedScenes as?  Set<UIWindowScene>)!) {
//            if windowScene.activationState == .foregroundActive {
//                window = windowScene.windows.first
//                break
//            }
//        }
//        return window
//    }else{
//        return  UIApplication.shared.keyWindow
//    }
}

@inline(__always) func TopVC() -> UIViewController? {
    var resultVC: UIViewController?
    resultVC = _topVC(UIApplication.shared.keyWindow?.rootViewController)
    while resultVC?.presentedViewController != nil {
        resultVC = _topVC(resultVC?.presentedViewController)
    }
    return resultVC
}

@inline(__always) func _topVC(_ vc: UIViewController?) -> UIViewController? {
    if vc is UINavigationController {
        return _topVC((vc as? UINavigationController)?.visibleViewController)
    } else if vc is UITabBarController {
        return _topVC((vc as? UITabBarController)?.selectedViewController)
    } else {
        return vc
    }
}

class EXAppUIDefines: NSObject {
    
    class func firstVCDismiss(){
        guard let appDelegate  = UIApplication.shared.delegate else {
            return
        }
        if appDelegate.window != nil   {
            let vc = appDelegate.window??.rootViewController?.presentedViewController
            vc?.popBack()
        }
    }
    
    //Get the first VC
    class func getFirstVC(_ type : String = "push") -> UIViewController?{
        guard let appDelegate  = UIApplication.shared.delegate else {
            return nil
        }
        if type == "push"{
            if appDelegate.window != nil   {
                if let vc = appDelegate.window??.rootViewController?.children.last{
                    return vc
                }
            }
        }else{
            if appDelegate.window != nil   {
                if let vc = appDelegate.window??.rootViewController?.presentedViewController{
                    return vc
                }
            }
        }
        return nil
    }
    
}
extension UIDevice{
    
    static func vg_safeDistanceTop() -> CGFloat {
        if #available(iOS 13.0, *) {
            let scene = UIApplication.shared.connectedScenes.first
            guard let windowScene = scene as? UIWindowScene else { return 0 }
            guard let window = windowScene.windows.first else { return 0 }
            return window.safeAreaInsets.top
        } else if #available(iOS 11.0, *) {
            guard let window = UIApplication.shared.windows.first else { return 0 }
            return window.safeAreaInsets.top
        }
        return 0;
    }
    
    
    static func vg_safeDistanceBottom() -> CGFloat {
        if #available(iOS 13.0, *) {
            let scene = UIApplication.shared.connectedScenes.first
            guard let windowScene = scene as? UIWindowScene else { return 0 }
            guard let window = windowScene.windows.first else { return 0 }
            return window.safeAreaInsets.bottom
        } else if #available(iOS 11.0, *) {
            guard let window = UIApplication.shared.windows.first else { return 0 }
            return window.safeAreaInsets.bottom
        }
        return 0;
    }
    
    
    static func vg_statusBarHeight() -> CGFloat {
        var statusBarHeight: CGFloat = 0
        if #available(iOS 13.0, *) {
            let scene = UIApplication.shared.connectedScenes.first
            guard let windowScene = scene as? UIWindowScene else { return 0 }
            guard let statusBarManager = windowScene.statusBarManager else { return 0 }
            statusBarHeight = statusBarManager.statusBarFrame.height
        } else {
            statusBarHeight = UIApplication.shared.statusBarFrame.height
        }
        return statusBarHeight
    }
    
    
    static func vg_navigationBarHeight() -> CGFloat {
        return 44.0
    }
    
    
    static func vg_navigationFullHeight() -> CGFloat {
        return UIDevice.vg_statusBarHeight() + UIDevice.vg_navigationBarHeight()
    }
    
    
    static func vg_tabBarHeight() -> CGFloat {
        return 49.0
    }
    
    
    static func vg_tabBarFullHeight() -> CGFloat {
        return UIDevice.vg_tabBarHeight() + UIDevice.vg_safeDistanceBottom()
    }
}

