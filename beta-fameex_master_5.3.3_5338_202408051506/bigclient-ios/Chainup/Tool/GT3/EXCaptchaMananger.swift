//
//  EXCaptchaMananger.swift
//  Chainup
//
//  Created by liuxuan on 2023/6/9.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit

class EXAliCaptchaModel:EXBaseModel {
    var token:String = ""
    var sig:String = ""
    var scene:String = "other"
    var sessionId:String = ""
}

class EXGeetestCaptchaModel:EXBaseModel {
    var geetest_challenge:String = ""
    var geetest_seccode:String = ""
    var geetest_validate:String = ""
}

enum APPValidationType {
    case jiyan
    case cloundFlare
    case aliyun
}


class EXAPPValidationConfig: EXBaseHanyJsonModel{
    var geetest:GeetestConfig?
    var cloudflare: CloudflareConfig?
    
    
    var geetestPassed: Bool {
        if let geetest = geetest,geetest.success == 1{
            return true
        }
        return false
    }
    var cloudflarePassed: Bool {
        if let a = cloudflare,let key = a.siteKey,key.isEmpty == false{
            return true
        }
        return false
    }
}

class GeetestConfig:EXBaseHanyJsonModel{
    var success: Int = 0
    var new_captcha: String?
    var challenge: String?
    var gt: String?
    
}

class CloudflareConfig:EXBaseHanyJsonModel{
    var siteKey: String?
    var domain: String?
}


class EXCaptchaMananger: NSObject {
    
    static let shared: EXCaptchaMananger = {
        let instance = EXCaptchaMananger()
        return instance
    }()
    
    var validationType = APPValidationType.jiyan
    
//    lazy var gt3Tool : GT3Tool = {
//        let gt3Tool = GT3Tool()
////        gt3Tool.captchaButton.isHidden = true
////        gt3Tool.start()
//        return gt3Tool
//    }()
    
    var gt3Tool = GT3Tool()
    var aliCaptchaModel:EXAliCaptchaModel = EXAliCaptchaModel()
    var cloudFlareToken:String?
    
//    func showCaptcha(inVc:UIViewController, completion:@escaping (Bool) ->() ) {
//        if EXAppConfigManager.sharedInstance.isJiYanVerifactionType() {
//            inVc.showLoading()
//            self.gt3Tool.start(succeededBlock: {
//                inVc.dismissLoading()
//                completion(true)
//            }, failedBlock: { err in
//                inVc.dismissLoading()
//                if err?.code == -1 {
//                }else{
//                    var errorMsg = err?.gtDescription
//                    errorMsg =  "cp_extra_text10".ex_localized()
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                        EXAlert.showFail(msg: errorMsg ?? "")
//                    }
//                }
//                completion(false)
//            })
//        }else if EXAppConfigManager.sharedInstance.isAliVerifactionType() {
//            let alicaptcha = EXCapchaView()
//            alicaptcha.onAliCallback = {[weak self] model in
//                self?.aliCaptchaModel = model
//                EXAlert.dismiss()
//                completion(true)
//            }
//            alicaptcha.onAliCancel = {[weak self]  in
//                self?.aliCaptchaModel = EXAliCaptchaModel()
//                EXAlert.dismiss()
//                var errorMsg =  "cp_extra_text10".ex_localized()
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                    EXAlert.showFail(msg: errorMsg)
//                }
//                completion(false)
//            }
//            EXAlert.showAlert(alertView: alicaptcha)
//        }else {
//            //No verification has been initiated
//            completion(true)
//        }
//    }
    func showCaptcha(inVc:UIViewController, completion:@escaping (Bool) ->() ) {
        let _ = appApi.rx.request(.getAPPValidationConfig)
            .autoShowLoadingOnController(context: inVc)
            .customObjectMap(EXAPPValidationConfig.self).subscribe(onSuccess: { [weak self] model in
                guard let `self` = self else { return }
                self.startWork(config: model, inVc: inVc, completion: completion)
            }, onFailure: {  _ in
                
            }, onDisposed: {
                
            })
    }
     
    func startWork(config: EXAPPValidationConfig,inVc:UIViewController, completion:@escaping (Bool) ->()){
        let type = EXAppConfigManager.sharedInstance.configVm.cfgModel.verificationType
        switch type{
        case "0":
            let randomNumber = Int(arc4random_uniform(3))
            print(randomNumber)
            if randomNumber == 1 {
                validationType = .jiyan
            }else{
                validationType = .cloundFlare
            }
            break
        case "1":
            validationType = .aliyun
            break
        case "2":
            validationType = .jiyan
            break
        case "3":
            validationType = .cloundFlare
        default:
            break
        }
        
        switch validationType {
        case .jiyan:
            JiYan(config: config,inVc: inVc, completion: completion)
        case .cloundFlare:
            cloundFlare(config: config,inVc: inVc, completion: completion)
        case .aliyun:
            aliyun(config: config,inVc: inVc, completion: completion)
        }
        
        
    }
    
    func JiYan(config: EXAPPValidationConfig,inVc:UIViewController, completion:@escaping (Bool) ->() ) {
        if config.geetestPassed == false {
            EXAlert.showFail(msg: "verifyEroor".localized())
            return
        }
        inVc.showLoading()
        let dc = NSMutableDictionary()
        dc["gt"] = config.geetest?.gt ?? ""
        dc["success"] = config.geetest?.success ?? 1
        dc["challenge"] = config.geetest?.challenge ?? ""
        dc["new_captcha"] = config.geetest?.new_captcha ?? ""
        
        self.gt3Tool = GT3Tool()
        self.gt3Tool.captchaButton.isHidden = true
        self.gt3Tool.data = dc as? [AnyHashable : Any]
        self.gt3Tool.start(succeededBlock: {
            inVc.dismissLoading()
            completion(true)
        }, failedBlock: { err in
            inVc.dismissLoading()
            if err?.code == -1 {
            }else{
                var errorMsg = err?.gtDescription
                errorMsg =  "cp_extra_text10".ex_localized()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    EXAlert.showFail(msg: errorMsg ?? "")
                }
            }
            completion(false)
        })
    }
    
    
    func cloundFlare(config: EXAPPValidationConfig,inVc:UIViewController, completion:@escaping (Bool) ->() ) {
        if config.cloudflarePassed == false {
            EXAlert.showFail(msg: "verifyEroor".localized())
            return
        }
        
        let alicaptcha = EXCloundFlareView()
        alicaptcha.clareConfig = config
        alicaptcha.startWork(key: config.cloudflare?.siteKey ?? "")
        alicaptcha.onSuccessCallBack = {[weak self] token in
            self?.cloudFlareToken = token
            EXAlert.dismiss()
            completion(true)
        }
//        alicaptcha.onAliCancel = {[weak self]  in
//            EXAlert.dismiss()
//            var errorMsg =  "cp_extra_text10".ex_localized()
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                EXAlert.showFail(msg: errorMsg)
//            }
//            completion(false)
//        }
        EXAlert.showAlert(alertView: alicaptcha,offset: 32)
    }
    
    
    func aliyun(config: EXAPPValidationConfig,inVc:UIViewController, completion:@escaping (Bool) ->() ) {
        let alicaptcha = EXCapchaView()
        alicaptcha.onAliCallback = {[weak self] model in
            self?.aliCaptchaModel = model
            EXAlert.dismiss()
            completion(true)
        }
        alicaptcha.onAliCancel = {[weak self]  in
            self?.aliCaptchaModel = EXAliCaptchaModel()
            EXAlert.dismiss()
            var errorMsg =  "cp_extra_text10".ex_localized()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                EXAlert.showFail(msg: errorMsg)
            }
            completion(false)
        }
        EXAlert.showAlert(alertView: alicaptcha)
    }
    
    func getCaptchaInfo() ->[String:String] {
        
        switch validationType {
        case .jiyan:
            return ["geetest_challenge":gt3Tool.geetest_challenge,
                    "geetest_seccode":gt3Tool.geetest_seccode,
                    "geetest_validate":gt3Tool.geetest_validate]
        case .cloundFlare:
            if let token = cloudFlareToken{
                return ["cloudFlareToken": token]
            }
            return [:]
        case .aliyun:
            return [:]
        }
    }
    
    func captchaType() ->String {
        
        switch validationType {
        case .jiyan:
            return "2"
        case .cloundFlare:
            return "3"
        case .aliyun:
            return "1"
        }
        return ""
    }
    


    
}

