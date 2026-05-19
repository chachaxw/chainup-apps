//
//  BasicParameter.swift
//  AppProject
//
//  Created by zewu wang on 2018/7/31.
//  Copyright © 2018年 zewu wang. All rights reserved.
//

import UIKit
import YYText
import RxSwift


//Button click event callback block
typealias EXCombuttonBlock = (_ button :UIButton) ->()
//Block without parameters and return value
typealias EXComVoidBlock = () -> ()
//Block without parameters and return value
typealias EXComBoolBlock = (_ bool: Bool) -> ()
typealias EXComIntBlock = (_ number: Int) -> ()
typealias EXComStringBlock = (_ string: String?) -> ()




///Obtain the current activity window
///- Returns: window
@inline(__always) func KKCurrentWindow() -> UIWindow?{
    var window : UIWindow? = nil
    if #available(iOS 13.0, *) {
        for scene : UIWindowScene in ((UIApplication.shared.connectedScenes as? Set<UIWindowScene>)!) {
            window = scene.windows.first
        }
    }else{
        if let _window = UIApplication.shared.delegate?.window {
            window = _window
        }
    }
    return window
}

///The height of the status bar
///- Returns: Height
@inline(__always) func KKSafeStatusHeight() -> CGFloat {
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

///Safety margin of equipment
///- Returns: safe margin
@inline(__always) func KKSafeAreaInsets() -> UIEdgeInsets{
    if #available(iOS 11.0, *) {
        return KKCurrentWindow()?.safeAreaInsets ?? UIEdgeInsets.zero
    } else {
       return UIEdgeInsets.zero
        // Fallback on earlier versions
    }
}

///Is the device a Liu Haiping
///- Returns: true: Liu Haiping otherwise false
@inline(__always) func KKIsPhoneSeries() -> Bool{
    return KKSafeAreaInsets().bottom > 0 ? true : false
}

///Safety distance at the top of the equipment
///- Returns: distance
@inline(__always) func KKSafeAreaTop() -> CGFloat{
    return KKSafeAreaInsets().top
}

///Safety distance at the bottom of the equipment
///- Returns: distance
@inline(__always) func KKSafeAreaBottom() -> CGFloat{
    return KKSafeAreaInsets().bottom
}

/////////////////////////////////////////////////////////////
///Navigation bar height!!!!!
///- Returns: Height
@inline(__always) func KKNavBarHeight() -> CGFloat{
    return KKSafeStatusHeight() + 44
}


///Tabbar height!!!!!
///- Returns: Height
@inline(__always) func KKTabBarHeight() -> CGFloat{
    return KKSafeAreaBottom() + 49
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
        return _topVC((vc as? UINavigationController)?.topViewController)
    } else if vc is UITabBarController {
        return _topVC((vc as? UITabBarController)?.selectedViewController)
    } else {
        return vc
    }
}
let kAppdelegate: AppDelegate? = UIApplication.shared.delegate as? AppDelegate
public let isiPhoneX = KKIsPhoneSeries()


  


//(UIScreen.main.bounds.size.height == 812 || UIScreen.main.bounds.size.height == 896) ? true : false

public let SCREEN_WIDTH = UIScreen.main.bounds.width//Screen width

public let SCREEN_HEIGHT = UIScreen.main.bounds.height//Screen height

public let NAV_TOP : CGFloat = isiPhoneX ? 24 : 0//Distance from top

public let NAV_SCREEN_HEIGHT :CGFloat = isiPhoneX ? 88 : 64//Navigation bar height
public let NAV_SAFEAERA_HEIGHT :CGFloat = isiPhoneX ? 44 : 44//Navigation bar height
public let NAV_STATUS_HEIGHT :CGFloat = isiPhoneX ? 44 : 20//Navigation bar height

public let TABBAR_BOTTOM : CGFloat = isiPhoneX ? 34 : 0//Distance from bottom
public let BANG_HEIGHT : CGFloat = isiPhoneX ? 44 : 0

public let CONTENTVIEW_HEIGHT :CGFloat = SCREEN_HEIGHT - NAV_SCREEN_HEIGHT

public let TABBAR_HEIGHT :CGFloat = isiPhoneX ? 83 : 49//Tabbar height

public let TABBAR_CONTENTVIEW_HEIGHT = CONTENTVIEW_HEIGHT - TABBAR_HEIGHT//The height of the tabbar content view
public var CUSTOM_LABEL_SIZE : CGFloat = 18//Default text size
public var CUSTOM_LABEL_FONT : UIFont = UIFont.systemFont(ofSize: CUSTOM_LABEL_SIZE)

public var HEIGHT_PROPORTION = SCREEN_HEIGHT / 667
public var WIDTH_PROPORTION = SCREEN_WIDTH / 375


public let StoryBoardNameMarket = "Market"
public let StoryBoardNameOTC = "EXOTC"
public let StoryBoardNameAsset = "EXAssets"
public let StroyBoardNameGrid = "EXGrid"


let proportion1 :CGFloat = 215 / 375

public var MARGIN_LEFT:CGFloat = 16
public var MARGIN_LEFT_DOUBLE:CGFloat = 32
typealias EXBlock = () ->()
typealias EXIndexPathBlock = (_ index:IndexPath) ->()
typealias EXBoolBlock = (_ isTrue: Bool) ->()
typealias EXStringBlock = (_ str: String?) ->()
@objcMembers class BasicParameter: NSObject {
    //CFBundleDisplayName app name CFBundleShortVersionString app version CFBundleVersion appbuild version
    //Obtain appVersion
    class func getAppVersion() -> String{
        let dict = Bundle.main.infoDictionary
        if dict != nil{
            if let appVersion = dict!["CFBundleVersion"] as? String{
                return appVersion
            }
        }
        return ""
    }
    
    class func getRealAppVersion()-> String {
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
    
    class func getChannel() -> String {
        guard let provision = Bundle.main.path(forResource: "embedded", ofType: "mobileprovision")  else {
            return "TestFlight"
        }
        if provision.isEmpty {
            return "TestFlight"
        }
        return "Enterprise"
    }

    
    class func isOverSeasVersion() -> Bool {
        let info = Bundle.main.infoDictionary
        if info?.keys.contains("appoverseas") == true{
            if let appoverseas = info!["appoverseas"] as? String,appoverseas == "1" {
                return true
            }
        }
        return false
    }

    
    class func getBundleIdentifier() ->String {
        let bundleID = Bundle.main.bundleIdentifier
        return bundleID ?? ""
    }
    
    //MARK: Get deviceVersion
    class func getDeviceVersion() -> String{
        return UIDevice.current.systemVersion
    }
    
    //MARK: Get bundleid
    class func getBundleId() -> String{
        return Bundle.main.bundleIdentifier ?? ""
    }
    
    //MARK: Obtain device model
    class func getPhoneModel() -> String{
        return UIDevice.current.model
    }
    
    //MARK: Get device system
    class func getPhoneOS() -> String{
        return UIDevice.current.systemName
    }
    
    @objc  static var phoneLanguage = ""
    
    //MARK: Get the phone language, ignore using Greek instead of traditional Chinese on the server
    
    
    
    //To add a new language, the key of the language must be added with an underline as the standard
    class func getPhoneLanguage(ignoreServer:Bool = false) -> String{
    
        var string:String = UserDefaults.standard.value(forKey: UserLanguage) as! String? ?? ""
        
        if string == "" {
            
            let languages = UserDefaults.standard.object(forKey: AppleLanguages) as? NSArray
            
            if languages?.count != 0 {
                
                let current = languages?.object(at: 0) as? String
                
                if current != nil {
                    string = current!
                    string = string.replacingOccurrences(of: "-", with: "_")
                    return string
                }
            }
        }
        

        if (string.range(of: "zh") != nil){
            if (string.range(of: "zh-Hant") != nil){
                if ignoreServer {
                    phoneLanguage = "zh-Hant"
                }else {
                    phoneLanguage = LanguageTools.el
                }
            }else{
                phoneLanguage = LanguageTools.ch
            }
            
        }else if (string.range(of: "en") != nil){
            phoneLanguage = LanguageTools.en
        }else if (string.range(of: "ko") != nil){
            phoneLanguage = LanguageTools.ko
        }else if (string.range(of: "ja") != nil){
            phoneLanguage = LanguageTools.jp
        }else if (string.range(of: "vi") != nil){
            phoneLanguage = LanguageTools.vi
        }else if (string.range(of: "es") != nil){
            phoneLanguage = LanguageTools.es
        }else if (string.range(of: "tr") != nil){
            phoneLanguage = LanguageTools.tr
        }else{
            
//            if LanguageTools.shareInstance.supportLan(string) {
//                var key = string
//                key = key.replacingOccurrences(of: "-", with: "_")
//                phoneLanguage = key
//            }else {
//                phoneLanguage = LanguageTools.en
//            }
            phoneLanguage = string
        }

        return phoneLanguage
    }
    
    //Is it Chinese
    class func isHan()->Bool{
        if BasicParameter.getPhoneLanguage() == LanguageTools.ch || BasicParameter.getPhoneLanguage() == LanguageTools.el{
            return true
        }else{
            return false
        }
    }
    
    //MARK: Get UDID
    class func getUUID()-> String {
        var str = ""
        
        if let uuid = XUserDefault.getVauleForKey(key: XUserDefault.XUUID) as? String{
            str = uuid
        }
        
        if str == ""{
            if let uuid = UIDevice.current.identifierForVendor{
                XUserDefault.setValueForKey(String(describing:uuid),key:XUserDefault.XUUID)
            }
        }
        
        return str
    }
    
    //MARK: Get network status
    class func getNetStatus() -> String{
        var str = ""
//        let remoteHostName = "www.baidu.com"
//
//        let reachability  = Reachability(hostName: remoteHostName)
//        if let networkStatus = reachability?.currentReachabilityStatus(){
//            switch networkStatus {
//            case ReachableViaWiFi:
//                str = "WIFI"
//            case ReachableViaWWAN:
//                str = "WWAN"
//            default:
//                str = "NONE"
//            }
//        }
        return str
    }
    
    //Obtain contact phone number
    class func getContactPhoneNumber()->String{
        return "010-88888888"
    }
    
    class func handleDouble(_ a : Any) -> Double{
        switch a {
        case let val as Double:
            //Print (" (val) is a numeric type")
            return Double(val)
        case let val as String:
            //Print (" (val) is a string")
            return (val as NSString).doubleValue
        case let val as Int:
            //Print (" (val) is int")
            return Double(val)
            
        case let val as Float:
            //Print (" (val) is a float")
            return Double(val)
        case let val as CGFloat:
            //Print (" (val) is a float")
            return Double(val)
        default:
Print ("nothing")
        }
        return 0
    }
    
    //Get app name
    class func getAppName() -> String{
        let bundle = LanguageTools.shareInstance.bundle
        let dict = bundle?.localizedInfoDictionary
        if dict != nil{
            if let appDisplay = dict!["CFBundleDisplayName"] as? String{
                return appDisplay
            }
        }
        return ""
    }
    
    class func depthToDouble(_ i : Int) -> String{
        var d = "0."
        if i > 0{
            for _ in 0..<i-1{
                d = d + "0"
            }
            d = d + "1"
        }else{
            d = "1"
        }
        return d
    }
    
    //Precision of processing quantity - dedicated for coil mouth
    class func dealPanKouVolume(_ str:String) -> String {
        let decimals = 8
        //If 0, return 0
        if Double(str) == 0{
            return "0.0000"
        }
        //If less than 0.0001, return 0
        if let poor = (str as NSString).subtracting("0.0001", decimals: decimals) , poor.contains("-"){
            return "0.0000"
        }else if let f = Float((str as NSString).dividing(by: "1000", decimals: 2)) , f > 1 {
            return dealDataFormate(str)
        }else{
            return BasicParameter.dealDecimalPoint(str,digits: 6, precision: 4)
        }
    }
    
    //Processing quantity accuracy
    class func dealVolumFormate(_ str : String) -> String{
        let decimals = 8
        //If 0, return 0
        if Double(str) == 0{
            return "0"
        }
        //If less than 0.001, return 0
        if let poor = (str as NSString).subtracting("0.001", decimals: decimals) , poor.contains("-"){
            return "0.000"
        }else if let f = Float((str as NSString).dividing(by: "1000", decimals: 2)) , f > 1 {
            return dealDataFormate(str)
        }else{
            return BasicParameter.dealDecimalPoint(str)
        }
    }
    
    //Processing data formats
    class func dealDataFormate(_ str : String) -> String{
        
        if let millionStr = NSString.init(string: str).dividing(by: "1000000000", decimals: 2){
            if let m = Float(millionStr) , m > 1{
                return BasicParameter.dealDecimalPoint(millionStr,digits:4) + "B"
            }
        }
        
        if let millionStr = NSString.init(string: str).dividing(by: "1000000", decimals: 2){
            if let m = Float(millionStr) , m > 1{
                return BasicParameter.dealDecimalPoint(millionStr,digits:4) + "M"
            }
        }
        
        if let kStr = NSString.init(string: str).dividing(by: "1000", decimals: 2){
            if let k = Float(kStr) , k > 1{
                return BasicParameter.dealDecimalPoint(kStr,digits:4) + "K"
            }
        }
        
//        print("str == \(str)")
//        let newStr = str.bigAdd("0", decimals: 2)
//        print("newstr= \(newStr)")
        return str
    }
    
    //Digits must be greater than 0
    //Understood, digits is the total length of the string, and precision is the default precision
    //Always maintain consistent overall length
    class func dealDecimalPoint(_ str : String,digits : Int = 5 , precision : Int = 3) -> String{
        var tmpStr = (str as NSString).decimalString1(precision)
        if let s = tmpStr , s.count > digits{
            tmpStr = s[0...digits]
        }
        if let last = tmpStr?.last, last == "."{
            tmpStr?.removeLast()
        }

        if tmpStr != nil{
            return tmpStr!
        }
        return str
    }
    
    //Process the color of numbers
    class func dealNumColor(_ num : String) -> UIColor{
        var color = UIColor.ThemeLabel.colorLite
        if num.contains("-"){
            color = UIColor.ThemekLine.down
        }else{
            if let n = Int(num) , n > 0{
                color = UIColor.ThemekLine.up
            }
        }
        return color
    }
    
    //Convert precision to decimals
    class func strToPrecision(_ str : String) -> String{
        var precision = "0"
        let num = Int(BasicParameter.handleDouble(str))
        if num == 0{
            return "1"
        }else{
            precision = precision + "."
            for _ in 0..<num{
               precision = precision + "0"
            }
            return precision + "1"
        }
    }
    
    static let dispose = DisposeBag()
    
    //Obtain version number and request publicinfo
    class func getVersionForPublicInfo(){
        
        appApi.hideAutoLoading()
        appApi.rx.request(.getUpdateVersion)
            .MJObjectMap(EXVersionModel.self,false)
            .subscribe(onSuccess: { (model) in
                //Returns false when not saved. The first request for updateversion should not request public again_ Info
                let hasVersion = XUserDefault.getVauleForKey(key: XUserDefault.updateVersion) as? String
                if hasVersion == nil {
                    XUserDefault.setValueForKey(model.updateVersion, key: XUserDefault.updateVersion)
                }else {
                    if XUserDefault.setUpdateVersion(model.updateVersion) == true{
                        EXAppMarketManager.sharedInstance.fetchMarket()
                    }
                }
            }) { (error) in
                
        }.disposed(by: BasicParameter.dispose)
    }
    
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
                if let vc = appDelegate.window??.rootViewController?.childViewControllers.last{
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

class EXVersionModel : EXBaseModel{
    var updateVersion = ""
}

extension NSMutableAttributedString{
    
    func highLightTap(_ range : NSRange , _ tapAction : @escaping ((UIView, NSAttributedString, NSRange, CGRect) -> ())){
        let highLightOfReplyUser = YYTextHighlight()
        highLightOfReplyUser.tapAction = tapAction
        self.yy_setTextHighlight(highLightOfReplyUser, range:range)
    }
    
    func add(attString : NSAttributedString) -> NSMutableAttributedString{
        self.append(attString)
        return self
    }
    
    func add(string : String, attrDic : [NSAttributedStringKey : Any])-> NSMutableAttributedString{
        //        if let imageBoundsAttributeName = attrDic["NSImageAttributeName"] as? String , let imageAttributeName =  attrDic["NSImageBoundsAttributeName"] as? UIImage{
        //            let attach = NSTextAttachment.init(data: nil, ofType: nil)
        //            let rect = CGRectFromString(imageBoundsAttributeName)
        //            attach.bounds = rect
        //            attach.image = imageAttributeName
        //            self.append(NSAttributedString.init(attachment: attach))
        //        }else{
        self.append(NSAttributedString.init(string: string, attributes: attrDic))
        //        }
        return self
    }
    
    func appendAttributedString(_  att : NSAttributedString) -> NSMutableAttributedString{
        self.append(att)
        return self
    }
    
}

