//
//  EXKitStanders.swift
//  DZNEmptyDataSet
//
//  Created by liuxuan on 2022/7/7.
//

import UIKit
//  按钮点击事件回调 Block
public typealias EXCombuttonBlock = (_ button :UIButton) ->()
//  无参无返回值 Block
public typealias EXComVoidBlock = () -> ()
//  无参无返回值 Block
public typealias EXComBoolBlock = (_ bool: Bool) -> ()
public typealias EXComIntBlock = (_ number: Int) -> ()
public typealias EXComStringBlock = (_ string: String?) -> ()
public typealias EXComStringArrayBlock = ([String]) -> ()

private let EXKit_Device_Width = UIScreen.main.bounds.width
private let EXKit_Device_Height = UIScreen.main.bounds.height
public let Device_W = min(EXKit_Device_Width, EXKit_Device_Height) //屏幕宽度
public let Device_H = max(EXKit_Device_Width, EXKit_Device_Height) //屏幕高度
public let NAV_H :CGFloat = isiPhonexType() ? 88 : 64 //导航栏高度
public let CONTENT_H :CGFloat = Device_H - NAV_H
public let TABBAR_H :CGFloat = isiPhonexType() ? 83 : 49 //tabbar高度
public let CONTENT_H_RM_TAB = CONTENT_H - TABBAR_H //tabbar contentview的高度

public var Margin_L:CGFloat = 16
public var Margin_LL:CGFloat = 32

public let EXSafeAreaTop = getSafeAreaTop()
public let EXSafeAreaBottom = getSafeAreaBottom()
public let EXNavBarHeight = getNavBarHeight()
public let EXTabBarHeight = getTabBarHeight()
public let EXSafeStatusHeight = getStatusHeight()

public let EX_Pixel_One = 1/UIScreen.main.scale
public let EX_Line_Width = EX_Pixel_One
public let EX_Line_Height = EX_Pixel_One

/// 设备顶部安全距离
/// - Returns: 距离
public func getSafeAreaTop() -> CGFloat{
    return EXSafeAreaInsets().top
}
/// 设备底部安全距离
public func getSafeAreaBottom() -> CGFloat{
    return EXSafeAreaInsets().bottom
}
/// 导航栏高度!!!!!
public func getNavBarHeight() -> CGFloat{
    return getStatusHeight() + 44
}

/// tabbar高度!!!!!
public func getTabBarHeight() -> CGFloat{
    return getSafeAreaBottom() + 49
}
/// 状态栏
public func getStatusHeight() -> CGFloat {
    var height : CGFloat  = 0
    if #available(iOS 13.0, *) {
        let statusBar : UIStatusBarManager? = UIApplication.shared.windows.first?.windowScene?.statusBarManager
        if let _height = statusBar?.statusBarFrame.height {
            height = _height
        }
    }else{
        height = UIApplication.shared.statusBarFrame.size.height
    }
    return height
}
/// 设备的安全边距
public func EXSafeAreaInsets() -> UIEdgeInsets{
    if #available(iOS 11, *) {
        let window = keywindow()
        return window?.safeAreaInsets ?? UIEdgeInsets.zero
    }
    return UIEdgeInsets.zero
}
public func isiPhonexType() -> Bool {
    if #available(iOS 11, *) {
        let window = keywindow()
        return window?.safeAreaInsets.bottom ?? 0 > 0
    } else {
        return false
    }
}

public func keywindow() -> UIWindow? {
    var window:UIWindow? = nil
    if #available(iOS 13.0, *) {
        for windowScene:UIWindowScene in ((UIApplication.shared.connectedScenes as?  Set<UIWindowScene>)!) {
           // print("windowScene.windowScene\(windowScene.activationState)")
           //打印出来结果 windowScene.activationState= foregroundInactive
            if windowScene.activationState == .foregroundActive || windowScene.activationState == .foregroundInactive{
                window = windowScene.windows.first
                break
            }
        }
        return window
    }else{
        return  UIApplication.shared.keyWindow
    }
}

public class EXKitStanders: NSObject {
    static let XUUID = "XUUID"//设备id

    public class func setValueForKey(_ value : Any? , key : String){
         if value == nil || value is NSNull{//容错
             return
         }
         UserDefaults.standard.set(value, forKey: key)
         UserDefaults.standard.synchronize()
     }
     
     //获取，如没有返回空字符串
     public class func getVauleForKey(key : String) -> Any{
         return UserDefaults.standard.object(forKey: key) ?? ""
     }
     
     
     public class func getAppVersion() -> String{
         let dict = Bundle.main.infoDictionary
         if dict != nil{
             if let appVersion = dict!["CFBundleVersion"] as? String{
                 return appVersion
             }
         }
         return ""
     }
    
    public class func getRealAppVersion()-> String {
        guard let info = Bundle.main.infoDictionary else { return "" }
        if info.keys.contains("exChainupBundleVersion") == true{
            if let originVersion = info["exChainupBundleVersion"] as? String,originVersion.count > 0 {
                return originVersion
            }else {
                if let appVersion = info["CFBundleVersion"] as? String {
                    return appVersion
                }
            }
        }else {
            if let appVersion = info["CFBundleVersion"] as? String {
                return appVersion
            }
        }
        return ""
    }
    
    public class func getChannel() -> String {
        guard let provision = Bundle.main.path(forResource: "embedded", ofType: "mobileprovision")  else {
            return "TestFlight"
        }
        if provision.isEmpty {
            return "TestFlight"
        }
        return "Enterprise"
    }
    
    public class func isOverSeasVersion() -> Bool {
        let info = Bundle.main.infoDictionary
        if info?.keys.contains("appoverseas") == true{
            if let appoverseas = info!["appoverseas"] as? String,appoverseas == "1" {
                return true
            }
        }
        return false
    }
    
    
    public class func getBundleIdentifier() ->String {
        let bundleID = Bundle.main.bundleIdentifier
        return bundleID ?? ""
    }
    
    //MARK:获取deviceVersion
    public class func getDeviceVersion() -> String{
        return UIDevice.current.systemVersion
    }
    
    //MARK:获取bundleid
    public class func getBundleId() -> String{
        return Bundle.main.bundleIdentifier ?? ""
    }
    
    //MARK:获取设备型号
    public class func getPhoneModel() -> String{
        return UIDevice.current.model
    }
    
    //MARK:获取设备系统
    public class func getPhoneOS() -> String{
        return UIDevice.current.systemName
    }
    
    //获取app名字
    public class func getAppName() -> String{
        let bundle = LanguageHandler.shareInstance.bundle
        let dict = bundle?.localizedInfoDictionary
        if dict != nil{
            if let appDisplay = dict!["CFBundleDisplayName"] as? String{
                return appDisplay
            }
        }
        return ""
    }
    
    //MARK:获取UDID
    public class func getUUID()-> String {
        var str = ""
        if let uuid = EXKitStanders.getVauleForKey(key: EXKitStanders.XUUID) as? String{
            str = uuid
        }
        if str == "" {
            if let uuid = UIDevice.current.identifierForVendor{
                EXKitStanders.setValueForKey(String(describing:uuid),key:EXKitStanders.XUUID)
            }
        }
        return str
    }
    
}

public func TopVC() -> UIViewController? {
    var resultVC: UIViewController?
    resultVC = _topVC(UIApplication.shared.keyWindow?.rootViewController)
    while resultVC?.presentedViewController != nil {
        resultVC = _topVC(resultVC?.presentedViewController)
    }
    return resultVC
}

public func _topVC(_ vc: UIViewController?) -> UIViewController? {
    if vc is UINavigationController {
        return _topVC((vc as? UINavigationController)?.visibleViewController)
    } else if vc is UITabBarController {
        return _topVC((vc as? UITabBarController)?.selectedViewController)
    } else {
        return vc
    }
}
