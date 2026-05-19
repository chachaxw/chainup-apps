//
//  EXLanguageTools.swift
//  CoNetworkTest
//
//  Created by ZYJ on 2023/1/12.
//

import UIKit
import EXKit
public let EXSCREEN_WIDTH = Device_W//Screen width
public let EXISIPhoneX = iSIPhonexType()
public let EXNAV_TOP : CGFloat = EXISIPhoneX ? 24 : 0//Distance from top
public let EXTABBAR_HEIGHT :CGFloat = EXISIPhoneX ? 83 : 49//Tabbar height
//MARK: -- Navigation and status bar height
public let EX_TABBAR_BOTTOM : CGFloat = EXISIPhoneX ? 34 : 0//Distance from bottom
public let EX_NAV_STATUS_HEIGHT :CGFloat = getStatusHeight()//Navigation bar height
public let EXS_SCREEN_HEIGHT = Device_H//Screen height
public let EX_NAV_SCREEN_HEIGHT :CGFloat = getNavBarHeight()//Navigation bar height
class EXBasicParameter: NSObject {
    //Version number
    class func getVersion() -> String{
        let dict = Bundle.main.infoDictionary
        if dict != nil{
            if let appVersion = dict!["CFBundleShortVersionString"] as? String{
                return appVersion
            }
        }
        return ""
    }
    //Get app name
    class func getAppName() -> String{
        let bundle = EXLanguageTools.shareInstance.bundle
        let dict = bundle?.localizedInfoDictionary
        if dict != nil{
            if let appDisplay = dict!["CFBundleDisplayName"] as? String{
                return appDisplay
            }
        }
        return ""
    }
    //MARK: Get UDID
    class func getUUID()-> String {
        var str = ""
        
        if let uuid = EXStoreData.storeObject(forKey: EX_XUUID) as? String{
            str = uuid
        }
        
        if str == ""{
            if let uuid = UIDevice.current.identifierForVendor{
                EXStoreData.setStoreObjectAndKey(String(describing:uuid), key: EX_XUUID)
            }
        }
        
        return str
    }
    //MARK: Obtain device model
    class func getPhoneModel() -> String{
        return UIDevice.current.model
    }
    //MARK: Get deviceVersion
    class func getDeviceVersion() -> String{
        return UIDevice.current.systemVersion
    }
    //MARK: Get device system
    class func getPhoneOS() -> String{
        return UIDevice.current.systemName
    }
    //MARK: Get the phone language, ignore using Greek instead of traditional Chinese on the server
//    class func getPhoneLanguage(ignoreServer:Bool = false) -> String{
//    
//        var string:String = UserDefaults.standard.value(forKey: EXS_UserLanguage) as! String? ?? ""
//        
//        if string == "" {
//            
//            let languages = UserDefaults.standard.object(forKey: EXS_AppleLanguages) as? NSArray
//            
//            if languages?.count != 0 {
//                
//                let current = languages?.object(at: 0) as? String
//                
//                if current != nil {
//                    string = current!
//                    string = string.replacingOccurrences(of: "-", with: "_")
//                    return string
//                }
//            }
//        }
//        
//        var phoneLanguage = ""
//        if (string.range(of: "zh") != nil){
//            if (string.range(of: "zh-Hant") != nil){
//                if ignoreServer {
//                    phoneLanguage = "zh-Hant"
//                }else {
//                    phoneLanguage = EXLanguageTools.el
//                }
//            }else{
//                phoneLanguage = EXLanguageTools.ch
//            }
//            
//        }else if (string.range(of: "en") != nil){
//            phoneLanguage = EXLanguageTools.en
//        }else if (string.range(of: "ko") != nil){
//            phoneLanguage = EXLanguageTools.ko
//        }else if (string.range(of: "ja") != nil){
//            phoneLanguage = EXLanguageTools.jp
//        }else if (string.range(of: "vi") != nil){
//            phoneLanguage = EXLanguageTools.vi
//        }else if (string.range(of: "es") != nil){
//            phoneLanguage = EXLanguageTools.es
//        }else{
//            if EXLanguageTools.shareInstance.supportLan(string) {
//                var key = string
//                key = key.replacingOccurrences(of: "-", with: "_")
//                phoneLanguage = key
//            }else {
//                phoneLanguage = EXLanguageTools.en
//            }
//        }
//
//        return phoneLanguage
//    }
}
//extension EXBasicParameter {
//    class func getKlineScale() -> [String] {
//        return ["1min","1min", "5min", "15min", "30min", "60min", "1day", "1week", "1month"]
//    }
//}


func iSIPhonexType() -> Bool {
    if #available(iOS 11, *) {
        let window = newKeyWindow()
        return window?.safeAreaInsets.bottom ?? 0 > 0
    } else {
        return false
    }
}

func newKeyWindow() -> UIWindow? {
    var window:UIWindow? = nil
    if #available(iOS 13.0, *) {
        for windowScene:UIWindowScene in ((UIApplication.shared.connectedScenes as?  Set<UIWindowScene>)!) {
           // //print("windowScene.windowScene\(windowScene.activationState)")
           //Print out the result windowScene. activationState=foregroundInactive
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

