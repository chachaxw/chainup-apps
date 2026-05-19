//
//  EXAuthenticManagerTool.swift
//  Chainup
//
//  Created by cwd on 2023/11/3.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import EXKit
import IdensicMobileSDK
import RxSwift

class UserAuthInfo:NSObject {
    var kycRight: EXKycUserWithdrawAmountInfo?
    static let shared = UserAuthInfo()
    private override init() {}
}


class EXAuthenticManagerTool {
    
//    static let `manager` = EXAuthenticManagerTool()
//    open class var shared: EXAuthenticManagerTool {
//        return manager
//    }
//    private init(){}
//    var sumSubDissCallBack: EXComVoidBlock?
    static let keySumsubKey = "SNSMobileSDK"
    static func gotoKyc(authModel: EXIDAuthenticItemModel){
        if authModel.kycType == .SUMSUB{
            getLevelName(name: authModel.sumsubLevel)
        }else{
            let v =  EXRealNameCertificationChooseVC()
            TopVC()?.navigationController?.pushViewController(v, animated: true)
        }
    }
    
    static private func getLevelName(name:String) {
        let _ = appApi.rx.request(.getSumSubAccessToken(level: name))
            .autoShowLoadingOnController(context: TopVC() ?? UIViewController())
            .MJObjectMap(CommonStringModel.self).subscribe(onSuccess: {  model in
                self.gotoSumsubKyc(accessToken: model.msg,sumsubLevel: name)
            }, onFailure: {  _ in
                
            }, onDisposed: {
                
            })
    }
    static private func gotoSumsubKyc(accessToken: String,sumsubLevel: String){
        
        let sdk = SNSMobileSDK(
            accessToken: accessToken
        )
        
        sdk.theme = KycTheme()
        if EXTheme.current == .dark {
            sdk.theme.colors.backgroundCommon =  .black  //.white
        }else{
            sdk.theme.colors.backgroundCommon =  .white  //.white
        }

        guard sdk.isReady else {
            print("Initialization failed: " + sdk.verboseStatus)
            return
        }
       // 当它过期时，您必须提供另一个
        sdk.tokenExpirationHandler { (onComplete) in
//            get_token_from_your_backend { (newToken) in
//                onComplete(newToken)
//            }
        }
        
        if let top = TopVC(){
            sdk.present(from: top)
        }
        
        sdk.verificationHandler { (isApproved) in
            print("verificationHandler: Applicant is " + (isApproved ? "approved" : "finally rejected"))
        }
        
        sdk.logLevel = .debug
        
//        sdk.locale = Locale.current.identifier
        
        sdk.locale = LanguageHandler.priviatePhoneLanguage
        
        sdk.strings = [
          "sns_oops_network_title": "Oops! Seems like the network is down.",
          "sns_oops_network_html": "Please check your internet connection and try again.",
          "sns_oops_action_retry": "Try again",
        ]
        
        sdk.addSupportItem { (item) in
            item.title = NSLocalizedString("URL Item", comment: "")
            item.subtitle = NSLocalizedString("Tap me to open an url", comment: "")
            item.icon = UIImage(named: "AppIcon")
            item.actionURL = URL(string: "https://google.com")
        }

        sdk.addSupportItem { (item) in
            item.title = NSLocalizedString("Callback Item", comment: "")
            item.subtitle = NSLocalizedString("Tap me to get callback fired", comment: "")
            item.icon = UIImage(named: "AppIcon")
            item.actionHandler { (supportVC, item) in
                print("[\(item.title)] tapped")
            }
        }
        
        sdk.onStatusDidChange { (sdk, prevStatus) in

            print("onStatusDidChange: [\(sdk.description(for: prevStatus))] -> [\(sdk.description(for: sdk.status))]")

            switch sdk.status {

            case .ready:
                // Technically .ready couldn't ever be passed here, since the callback has been set after `status` became .ready
                break

            case .failed:
                print("failReason: [\(sdk.description(for: sdk.failReason))] - \(sdk.verboseStatus)")

            case .initial:
                print("No verification steps are passed yet")

            case .incomplete:
                print("Some but not all of the verification steps have been passed over")

            case .pending:
                print("Verification is pending")
                kycSumsubSubmit(level: sumsubLevel)
                NotificationCenter.default.post(name: NSNotification.Name.init(EXAuthenticManagerTool.keySumsubKey), object: nil)

            case .temporarilyDeclined:
                print("Applicant has been temporarily declined")

            case .finallyRejected:
                print("Applicant has been finally rejected")

            case .approved:
                print("Applicant has been approved")

            case .actionCompleted:
                print("Applicant action has been completed")
            }
        }
        
        
        sdk.onDidDismiss { (sdk) in
            print("onDidDismiss sdk.status = \(sdk.status)")
            switch sdk.status {
            case .failed:
                print("failReason: [\(sdk.description(for: sdk.failReason))] - \(sdk.verboseStatus)")

            case .actionCompleted:
                // the action was performed or cancelled

                if let result = sdk.actionResult {
                    print("Last action result: actionId=\(result.actionId) answer=\(result.answer ?? "<none>")")
                } else {
                    print("The action was cancelled")
                }

            default:
                // in case of an action level, the other statuses are not used for now,
                // but you could see them if the user closes the sdk before the level is loaded
                break
            }
        }
        
        sdk.actionResultHandler { (sdk, result, onComplete) in
//            kycSumsubSubmit(level: sumsubLevel)
//            NotificationCenter.default.post(name: NSNotification.Name.init(EXAuthenticManagerTool.keySumsubKey), object: nil)
            print("actionResultHandler: actionId=\(result.actionId) answer=\(result.answer ?? "<none>")")
            // you are allowed to process the result asynchronously, just don't forget to call `onComplete` when you finish,
            // you could pass `.cancel` to force the user interface to close, or `.continue` to proceed as usual
            onComplete(.continue)
        }
    }
    
    
    static func kycRightPassed(right: KYCRIGHT) -> Bool{
        var pass = false
        switch right {
        case .c2c:
            pass = UserAuthInfo.shared.kycRight?.canC2C ?? false
        case .deposit:
            pass = UserAuthInfo.shared.kycRight?.candeposit ?? false
        case .withdraw:
            pass = UserAuthInfo.shared.kycRight?.canWithdraw ?? false
        case .licai:
            pass = UserInfoEntity.sharedInstance().authLevel == "1"
        }
        if pass {
            return true
        }
        let alert = EXCommonAlert()
        alert.configAlert(title: "kyc_common_title".localized(), message: "kyc_common_content".localized(),cancelBtnTitle: "kyc_common_button_later".localized(),sureBtnTitle: "kyc_common_button_verify".localized(), alertCallBack:{ type in
            if type == .cancel {
                    switch right {
                    case .c2c:
                        break
                    case .deposit:
                        gotoAsset()
                    case .withdraw:
                        gotoAsset()
                    case .licai:
                        break
                    }
            }else if type == .sure{
                let realName = EXIDAuthenticViewController()
                    TopVC()?.navigationController?.pushViewController(realName, animated: true)
            }
        })
        EXAlert.showAlert(alertView: alert)
        return false
    }
        
    class func gotoAsset() {
        if let controllers = TopVC()?.navigationController?.viewControllers {
            for controller in controllers {
                if controller.isKind(of: EXAssetsVc.self) || controller.isKind(of: TabbarController.self) {
                    TopVC()?.navigationController?.popToViewController(controller, animated: true)
                }
            }
        }
    }
    
    
}

extension EXAuthenticManagerTool{
   static func getUserKysRight(symbol: String?,success :@escaping (EXKycUserWithdrawAmountInfo) -> ()){
        if XUserDefault.isOffLine(){
            return
        }
        let _ = appApi.rx.request(.getKycRightInfo(symbol: symbol))
            .customObjectMap(EXKycUserWithdrawAmountInfo.self).subscribe(onSuccess: { model in
                success(model)
                UserAuthInfo.shared.kycRight = model
            }, onFailure: {  _ in
                
            }, onDisposed: {
                
            })
    }
    
    static func kycSumsubSubmit(level: String){
        let _ = appApi.rx.request(.sumsubSubmit(level: level))
            .MJObjectMap(EXVoidModel.self).subscribe(onSuccess: { model in
               
            }, onFailure: {  _ in
                
            }, onDisposed: {
                
            })
    }
}



class KycTheme: SNSTheme {
    override init() {
        super.init()
        colors.backgroundCommon = .Ex.fill1
        colors.backgroundNeutral = .Ex.fill3
        colors.contentWeak =  .Ex.text3
        colors.contentLink = .Ex.main1
        colors.primaryButtonBackground = .Ex.main1
        colors.primaryButtonContentHighlighted = .Ex.main1
        colors.primaryButtonContent = .white
        colors.fieldBackground = .Ex.special2
        colors.fieldPlaceholder = .Ex.text3
        colors.fieldContent = .Ex.text1
        
    }
}

   
      
