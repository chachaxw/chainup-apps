//
//  BusinessTools.swift
//  AppProject
//
//  Created by zewu wang on 2023/8/2.
//  Copyright © 2023年 zewu wang. All rights reserved.
//

import UIKit
import Alamofire
import EXKit

class BusinessTools: NSObject {
    
    static let instance = BusinessTools()
    
    public class func sharedInstance() -> BusinessTools {
        return instance
    }
    
    override init() {
        super.init()
        self.handleNoti()
    }
    
    static var count = 0
    typealias LoginSuccessClosure = () -> ()
    var loginSuccessBlock : LoginSuccessClosure?
    
    func handleNoti() {
        NotificationCenter.default.addObserver(self, selector: #selector(loginSuccess), name: Notification.Name(rawValue: "EXLoginSuccess"), object: nil)
    }
    
    @objc func loginSuccess() {
        loginSuccessBlock?()
    }
    
    func modalLoginVC(_ source : String = "", loginSuccess:@escaping LoginSuccessClosure) {
        
        if !XUserDefault.isOffLine() {
            loginSuccess()
            return
        }
        
        loginSuccessBlock = loginSuccess
        
        BusinessTools.modalLoginVC(source)
    }
    
    /// check need login or not, if need login , then modal login vc
    /// - Returns: true if need login, otherwise false
    class func loginIfNeeded() -> Bool {
        if XUserDefault.getToken() == nil{
            BusinessTools.modalLoginVC()
            return true
        }
        return false
    }
    
    //MARK: Modal pop-up login page
    class func modalLoginVC(_ source : String = ""){
        
        if count == 1{
            return
        }else if count == 0{
            count = 1
            XHUDManager.sharedInstance.loading()
        }
        
        let loginVC = EXAccountActionVc()
        //        let loginVC = UIViewController.createControllerFromStoryBoard(name: .accout, type: EXAccountActionVc.self)
        
        guard let appDelegate = UIApplication.shared.delegate else {
            return
        }
        let nav = NavController()
        let quickToken = XUserDefault.quickTokenValue ?? ""
        
        nav.modalPresentationStyle = .fullScreen
        nav.isNavigationBarHidden = true
        if source == "",quickToken != ""{
            let entity = UserInfoEntity.sharedInstance()
            
            if XUserDefault.getFaceIdOrTouchIdPassword() != "" {
                
                FingerPrintVerify.fingerIsSupportCallBack { (type) in
                    
                    if type == "1" || type == "2"{
                        
                        let login = EXReLoginVC()
                        nav.viewControllers = [login]
                        appDelegate.window??.rootViewController?.present(nav, animated: true, completion: nil)
                        
                    }else{
                        nav.viewControllers = [loginVC]
                        appDelegate.window??.rootViewController?.present(nav, animated: true, completion: nil)
                    }
                    
                    dismissLoginNet()
                }
            }
            
            //If a gesture password is set
            else if XUserDefault.getGesturesPassword() != nil || entity.gesturePwd != ""{
                
                
                
                var params : [String : Any] = [:]
                params["uid"] = entity.uid
                
                if let pwd = XUserDefault.getGesturesPassword(){
                    params["gesturePwd"] = pwd
                    
                }
                
                if  entity.gesturePwd.ch_length > 1{
                    params["gesturePwd"] = entity.gesturePwd
                    
                }
                
                let param = NetManager.sharedInstance.handleParamter(params)
                
                let url = NetManager.sharedInstance.url(EXNetworkDoctor.sharedManager.getAppAPIHost(), model: NetDefine.gesturePwd_is_same, action: "")
                NetManager.sharedInstance.sendRequest(url,parameters : param, success: { (result, response, entity) in
                    if let result = result as? [String : Any]{
                        
                        guard let data = result["data"] as? [String:Any] else {return}
                        
                        if let isPass = data["isPass"] as? Int{
                            if Int(isPass) == 1{
                                let vc = GestureValidationVC()
                                vc.type = GestureValidationType.login
                                nav.viewControllers = [vc]
                                appDelegate.window??.rootViewController?.present(nav, animated: true, completion: nil)
                            }else{
                                nav.viewControllers = [loginVC]
                                appDelegate.window??.rootViewController?.present(nav, animated: true, completion: nil)
                            }
                        }
                        
                    }
                    dismissLoginNet()
                    
                }, fail: { (state, error, any) in
                    nav.viewControllers = [loginVC]
                    appDelegate.window??.rootViewController?.present(nav, animated: true, completion: nil)
                    dismissLoginNet()
                })
                
                
            }
            
            else{
                nav.viewControllers = [loginVC]
                appDelegate.window??.rootViewController?.present(nav, animated: true, completion: nil)
                dismissLoginNet()
            }
        }
        else{
            nav.viewControllers = [loginVC]
            appDelegate.window??.rootViewController?.present(nav, animated: true, completion: nil)
            dismissLoginNet()
        }
        
    }
    
    class func dismissLoginNet(){
        count = 0
        XHUDManager.sharedInstance.dismissWithDelay {
        }
    }
    
    //Kicked
    class func logoutNet(dismissTopVC:Bool = true){
        if dismissTopVC {
            TopVC()?.dismiss(animated: true)
        }
        guard let nav = BusinessTools.getRootNavBar()else{
            return
        }
        if let tabbar = BusinessTools.getRootTabbar(){
            if XUserDefault.getToken() == nil{
                let vc = tabbar.getCurrentTabbarVC()
                if vc is EXAssetsVc{
                    tabbar.selectIndex(0 , showLogin:false)
                }
                //                if vc is ContractVC{
                //                    (vc as! ContractVC).reloadView()
                //                }
                nav.popToRootViewController(animated: true)
            }
        }
    }
    
    //MARK: Modal pop-up registration page
    //    class func modalRegistVC(){
    //        guard let appDelegate = UIApplication.shared.delegate else {
    //            return
    //        }
    //        let login = EXLoginAndRegistVC()
    //        login.changeView(EXLoginType.regist)
    //        let nav = NavController()
    //        nav.viewControllers = [login]
    //        nav.isNavigationBarHidden = true
    //        appDelegate.window??.rootViewController?.present(nav, animated: true, completion: nil)
    //    }
    
    //MARK: Get rootTabbar
    class func getRootTabbar() -> TabbarController?{
        return self.cyl_tabBarController() as? TabbarController
    }
    
    //MARK: Get rootNavBar
    class func getRootNavBar() -> NavController?{
        guard let appDelegate = UIApplication.shared.delegate else {
            return nil
        }
        if let navController = appDelegate.window??.rootViewController as? NavController{
            return navController
        }
        return nil
    }
    
    
    class func checkMyInviteSwitch(configuration: @escaping (_ config: EXInviteSwitchVoModel) -> Void) {
        let time = DateTools.getNowTimeInterval()
        let url = NetManager.sharedInstance.url(EXNetworkDoctor.sharedManager.getAppAPIHost(), model: NetDefine.myInvitationSwitch, action: "") + "?time=\(time)"
        NetManager.sharedInstance.sendRequest(url, parameters: nil,mothed:HTTPMethod.get, isShowLoading : false,success: { (result, response, nil) in
            if let dict = result as? [String: Any] {
                if let data = dict["data"] as? [String: Any] {
                    let model = EXInviteSwitchVoModel.mj_object(withKeyValues: data["switchVo"])
                    if (model != nil) {
                        configuration(model!)
                    } else {
                        ///
                    }
                } else {
                 ///
                }
            } else {
                ////
            }
        }, fail: { (state , error,nil) in
            ////
        })
        
    }
    
    class func checkVersionUpdate(isNeedUpdate :@escaping EXComBoolBlock){

        let time = DateTools.getNowTimeInterval()
        let url = NetManager.sharedInstance.url(EXNetworkDoctor.sharedManager.getAppAPIHost(), model: NetDefine.getVersionV1, action: "") + "?time=\(time)"
        NetManager.sharedInstance.sendRequest(url, parameters: nil,mothed:HTTPMethod.get, isShowLoading : false,success: { (result, response, nil) in
            if let dict = result as? [String:Any]{
                if let data = dict["data"] as? [String:Any]{
                    let info = Bundle.main.infoDictionary
                    let build  = data["build"] as? Int//Background configuration ID
                    var app:Int = 0//appid
                    if info?.keys.contains("exChainupBundleVersion") == true{
                        if let app_version = info!["exChainupBundleVersion"] as? String {
                            if let a = Int(app_version){
                                app =  a
                            }
                        }
                    }
                    //Currently not the latest version
                    if let b = build , b - app > 0{
                        isNeedUpdate(true)
                    }
                }
            }
            isNeedUpdate(false)
        }, fail: { (state , error,nil) in
            isNeedUpdate(false)
        })
        
        
    }
    //MARK: Detect version type 0, do not prompt for the latest version 1, prompt for the latest version
    class func checkVersion(_ type : String = "0"){
        
        let time = DateTools.getNowTimeInterval()
        let url = NetManager.sharedInstance.url(EXNetworkDoctor.sharedManager.getAppAPIHost(), model: NetDefine.getVersionV1, action: "") + "?time=\(time)"
        NetManager.sharedInstance.sendRequest(url, parameters: nil,mothed:HTTPMethod.get, isShowLoading : false,success: { (result, response, nil) in
            if EXAlert.isCurrentlyDisplaying(){
                return
            }
            if let dict = result as? [String:Any]{
                if let data = dict["data"] as? [String:Any]{
                    
                    let force = data["forceUpdate"] as? Int//Force upgrade identification
                    
                    let info = Bundle.main.infoDictionary
                    let build  = data["build"] as? Int//Background configuration ID
                    
                    var app:Int = 0//appid
                    if info?.keys.contains("exChainupBundleVersion") == true{
                        if let app_version = info!["exChainupBundleVersion"] as? String {
                            if let a = Int(app_version){
                                app =  a
                            }
                        }
                    }
                    
                    //Currently not the latest version
                    if let b = build , b - app > 0{
                        var title = ""
                        var content = ""
                        var downloadUrl = ""
                        if let title1 = data["title"] as? String{
                            title = title1
                        }
                        if let content1 = data["content"] as? String{
                            content = content1
                        }
                        if let downloadUrl1 = data["downloadUrl"] as? String {
                            downloadUrl = downloadUrl1
                        }
                        
                        let zan = UserDefaults.standard.object(forKey: "zanbugengxin") as? String//Do not upgrade identification temporarily
                        /// same version number, same day, non-manual update
                        if let lateTimeArr = zan?.components(separatedBy: "_"), lateTimeArr.count == 2 {
                            let lateAppVersion = lateTimeArr.first ?? ""
                            let lateTimeValue = lateTimeArr.last ?? ""
                            if let _lateTimeValue = Int(lateAppVersion),
                               _lateTimeValue == b,
                               EXKitStanders.isSameDay(timeInterval1: "\(time)", timeInterval2: lateTimeValue),
                               type == "0",
                               force == 0 {
                                return
                            }
                        }
                        
                        let alert = EXNewVersionUpateAlert()
                        alert.configAlert(title: title ,
                                          content: content,
                                          updateTitle:"update_now".localized(),
                                          cancelTitle: "delay_upgrade".localized(),
                                          forceUpdate: force == 1) { type in
                            if type == .cancel {
                                UserDefaults.standard.set("\(b)" + "_\(time)", forKey: "zanbugengxin")
                                UserDefaults.standard.synchronize()
                            }else{
                                if let url = URL.init(string: downloadUrl){
                                    if UIApplication.shared.canOpenURL(url) {
                                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                                    } else {
                                        EXAlert.dismissEnd {
                                            EXAlert.showFail(msg: "url_error".localized())
                                        }
                                    }
                                }
                            }
                        }
                        EXAlert.showAlert(alertView: alert)
                    }else{//Currently the latest version
                        if type == "1"{//Prompt the user that the current version is the latest
                            EXAlert.showSuccess(msg:  LanguageTools.getString(key: "common_tip_isNewVersion"))
                        }else if type == "0"{
                            return
                        }
                    }
                }
            }
        }, fail: { (state , error,nil) in
            
        })
        
        
    }
    
    //Determine if the length is greater than 8 digits before continuing to determine whether it contains both numbers and characters
    class func numberAndCharacter(_ str : String) -> Bool{
        var tmpresult = false

        var regex: NSRegularExpression = NSRegularExpression.init()

//        let linkPattern: String = "^(?![0-9]+$)(?![a-zA-Z]+$)[0-9A-Za-z~!@#$%^&*()]{8,20}$"
        let linkPattern: String = "^(?=.*\\d)(?=.*[a-zA-Z]).{8,20}$"
        
        //Constructing Regular Expressions
        do {
            regex = try NSRegularExpression.init(pattern: linkPattern, options: NSRegularExpression.Options.caseInsensitive)
        } catch {
            EXAlert.showFail(msg: "Problem with regular expressions")
        }
        
        //Traverse target string
        regex.enumerateMatches(in: str, options: NSRegularExpression.MatchingOptions.reportCompletion, range: NSMakeRange(0, str.count)) { (result, flags, stop) in
            if result == nil {
                return
            } else {
                tmpresult = true
                return
            }
        }
        return tmpresult
    }
    
    //Determine whether it is a pure number
    class func number(_ str : String) -> Bool{
        var tmpresult = false
        
        var regex: NSRegularExpression = NSRegularExpression.init()
        
        let linkPattern: String = "^\\d{0,}$"
        
        //Constructing Regular Expressions
        do {
            regex = try NSRegularExpression.init(pattern: linkPattern, options: NSRegularExpression.Options.caseInsensitive)
        } catch {
              EXAlert.showFail(msg: "Problem with regular expressions")
        }
        
        //Traverse target string
        regex.enumerateMatches(in: str, options: NSRegularExpression.MatchingOptions.reportCompletion, range: NSMakeRange(0, str.count)) { (result, flags, stop) in
            if result == nil {
                return
            } else {
                tmpresult = true
                return
            }
        }
        return tmpresult
    }
    
    //Determine if it is an email
    class func isEmail(_ str : String) -> Bool{
        var tmpresult = false
        if str.count < 5 || str.count > 100{
            return tmpresult
        }
        
        var regex: NSRegularExpression = NSRegularExpression.init()
        
        let linkPattern: String = "^([a-zA-Z0-9_\\-\\.]+)@((\\[[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.)|(([a-zA-Z0-9\\-]+\\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})(\\]?)$"
        
        //Constructing Regular Expressions
        do {
            regex = try NSRegularExpression.init(pattern: linkPattern, options: NSRegularExpression.Options.caseInsensitive)
        } catch {
              EXAlert.showFail(msg: "Problem with regular expressions")
        }
        
        //Traverse target string
        regex.enumerateMatches(in: str, options: NSRegularExpression.MatchingOptions.reportCompletion, range: NSMakeRange(0, str.count)) { (result, flags, stop) in
            if result == nil {
                return
            } else {
                tmpresult = true
                return
            }
        }
        return tmpresult
    }
    
    class func presentNav(_ vc : UIViewController){
        let nav = NavController()
        nav.isNavigationBarHidden = true
        nav.viewControllers = [vc]
        guard let appDelegate = UIApplication.shared.delegate else {
            return
        }
        appDelegate.window??.rootViewController?.present(nav, animated: true, completion: nil)
    }
    
    //Restart the app
    class func reloadWindow(){

        let window = UIApplication.shared.keyWindow
        let nav = AppDelegate().initNavBarV()
        window?.makeKeyAndVisible()
        window?.rootViewController = nav
    }
    
    class func unLoginPopBack(){
        
    }
}




public enum EXStoryBoardName: String {
    case assets = "EXAssets"
    case accout = "EXAccount"
    case quant = "EXQuant"
}

public extension UIViewController{
    
    class func createControllerFromStoryBoard<T>(name: EXStoryBoardName, type: T.Type) -> T {
        return UIStoryboard.init(name: name.rawValue, bundle: nil).instantiateViewController(withIdentifier: String(describing: type)) as! T
    }

}
