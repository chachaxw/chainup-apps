//
//  EXOTCSafetyCheckVm.swift
//  Chainup
//
//  Created by liuxuan on 2023/5/29.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

class EXOTCSafetyCheckVm: NSObject {
    var currentVc:UIViewController?
    static let `manager` = EXOTCSafetyCheckVm()
    func checkDrawRequireForInternalTransfer(_ inVc:UIViewController) -> Bool {
        let pass = checkDrawRequire()
        if pass == false {
            self.currentVc = inVc
            
            EXAlert.showAlert(alertView: generateAlertView(getDrawRequireSafetyAlertParam(true)))
        }
        
        return pass
    }
    func checkDrawRequire() -> Bool {
        let user = UserInfoEntity.sharedInstance()
        return EXAppConfigManager.sharedInstance.isRequireGoogle() ? user.didBindGoolge() : user.didBindPhone() || user.didBindGoolge()
    }
    func checkRedpacketSafety(_ inVc:UIViewController) -> Bool {
        let user = UserInfoEntity.sharedInstance()
        
        if EXAppConfigManager.sharedInstance.isRequireGoogle() {
            if user.didpassRealName(),
                user.didBindGoolge(){
                return true
            }else {
                self.currentVc = inVc
                let safety = EXOTCSafetyAlert()
                safety.configAlert(title: "common_text_tip".localized(),
                                   message: "redpacket_click_prompt".localized(),
                                   safeItems: [.reaName,.bindGoogle])
                safety.alertCallback = {[weak self] type in
                    self?.handleAlertCallback(type)
                }
                EXAlert.showAlert(alertView: safety)
                return false
            }
        }else {
            if user.didpassRealName(),
                (user.didBindGoolge() || user.didBindPhone()){
                return true
            }else {
                self.currentVc = inVc
                let safety = EXOTCSafetyAlert()
                safety.configAlert(title: "common_text_tip".localized(),
                                   message: "redpacket_click_prompt".localized(),
                                   safeItems: [.reaName,.bindGoolgeOrPhone])
                safety.alertCallback = {[weak self] type in
                    self?.handleAlertCallback(type)
                }
                EXAlert.showAlert(alertView: safety)
                return false
            }
        }
    }
    
    func checkWithDrawRequire(_ inVc:UIViewController) -> Bool {
        let user = UserInfoEntity.sharedInstance()
        if EXAppConfigManager.sharedInstance.isRequireGoogle() {
            if user.didBindGoolge() {
                return true
            }else {
                self.currentVc = inVc
                let safety = EXOTCSafetyAlert()
                var safetyItems:[SafetyTypes] = []
                safetyItems.append(.bindGoogle)
                safety.configAlert(title: "common_text_tip".localized(),
                                   message: "withdraw_tip_bindGoogleFirst".localized(),
                                   safeItems:safetyItems)
                safety.alertCallback = {[weak self] type in
                    self?.handleAlertCallback(type)
                }
                EXAlert.showAlert(alertView: safety)
                return false
            }
        }else {
            if user.didBindPhone() || user.didBindGoolge() {
                return true
            }else {
                self.currentVc = inVc
                let safety = EXOTCSafetyAlert()
                var safetyItems:[SafetyTypes] = []
                safetyItems.append(.bindGoolgeOrPhone)
                safety.configAlert(title: "common_text_tip".localized(),
                                   message: "otcSafeAlert_action_bindphoneOrGoogle".localized(),
                                   safeItems:safetyItems)
                safety.alertCallback = {[weak self] type in
                    self?.handleAlertCallback(type)
                }
                EXAlert.showAlert(alertView: safety)
                return false
            }
        }
    }

    
    func checkOTCBasicRequire(_ inVc:UIViewController) -> Bool {
        let user = UserInfoEntity.sharedInstance()
        if user.otcBasicCheckPass() {
            return true
        }else {
            self.currentVc = inVc
           
            let safety =  EXOTCSafetyAlert()
            var safetyItems:[SafetyTypes] = []
            safetyItems.append(.nickName)
//            if EXAppConfigManager.sharedInstance.isRequireGoogle() {
////                safetyItems.append(.bindPhone)
//                safetyItems.append(.bindGoogle)
//            }else {
//                
////                safetyItems.append(.bindGoolgeOrPhone)
//            }
            safetyItems.append(.bindGoogle)
            safetyItems.append(.reaName)
            let message = "otcSafeAlert_text_title".localized()
//            if EXAppConfigManager.sharedInstance.didOpenB2C(){
//                message = "otcSafeAlert_text_title_forotc".localized()
//            }
            safety.configAlert(title: "personal_Center_text15".localized(),
                               message: message,
                               safeItems:safetyItems)
            safety.alertCallback = {[weak self] type in
                
                self?.handleAlertCallback(type)
//                EXAlert.dismissEnd(complete: {
//                    self?.handleAlertCallback(type)
//                }, delay: 0.2)
            }
            EXAlert.showSheet(sheetView: safety)
            return false
        }
    }
    
    func checkOTCSafeRequire(_ inVc:UIViewController , hasPayment : Bool) -> Bool{
        if UserInfoEntity.sharedInstance().otcSafetyCheckPass() && hasPayment == true{
            return true
        }else{
            self.currentVc = inVc
            let safety = EXOTCSafetyAlert()
            safety.hasPayment = hasPayment
            var message = "otcSafeAlert_text_settingDesc".localized()
            if EXAppConfigManager.sharedInstance.didOpenB2C(){
                message = "otcSafeAlert_text_settingDesc_forotc".localized()
            }
            safety.configAlert(title: "common_text_tip".localized(),
                               message: message,
                               safeItems: [.paypwd,.payType])
            safety.alertCallback = {[weak self] type in
                self?.handleAlertCallback(type)
            }
            EXAlert.showAlert(alertView: safety)
            return false
        }
    }
    
    func checkKycRequire(_ inVc:UIViewController,type : String = "0") -> Bool{
        if UserInfoEntity.sharedInstance().didpassRealName(){
            return true
        }else{
            self.currentVc = inVc
            let safety = EXOTCSafetyAlert()
            var message = "common_kyc_chargeAndwithdraw".localized()
            if type == "1"{//transaction
                message = "common_kyc_trading".localized()
            }
            safety.configAlert(title: "common_text_tip".localized(),
                               message: message,
                               safeItems: [.reaName],
                               positiveBtnTitle:"common_text_btnSetting".localized())
            safety.alertCallback = {[weak self] type in
                self?.handleAlertCallback(type)
            }
            EXAlert.showAlert(alertView: safety)
            return false
        }
    }
    func generateAlertView(_ para: (SafetyTypes,String)) -> EXOTCSafetyAlert {
        let safety = EXOTCSafetyAlert()
        var safetyItems:[SafetyTypes] = []
        safetyItems.append(para.0)
        safety.configAlert(title: "common_text_tip".localized(),
                           message: para.1.localized(),
                           safeItems:safetyItems)
        safety.alertCallback = {[weak self] type in
            self?.handleAlertCallback(type)
        }
        return safety
    }
    
    func getDrawRequireSafetyAlertParam(_ isInternalTransfer:Bool) -> (SafetyTypes,String) {
    
        if maskBindGoogle() {
            return  (.bindGoogle, isInternalTransfer ? "internalTransfer_tip_bindGoogleFirst" : "withdraw_tip_bindGoogleFirst")
        }
        if maskBindPhoneOrGoogle() {
            return (.bindGoolgeOrPhone,"otcSafeAlert_action_bindphoneOrGoogle")
        }
        return (.none,"")
    }
    func maskBindGoogle() -> Bool {
        let user = UserInfoEntity.sharedInstance()

        return EXAppConfigManager.sharedInstance.isRequireGoogle() && !user.didBindGoolge()
    }
    
    func maskBindPhoneOrGoogle() -> Bool {
        let user = UserInfoEntity.sharedInstance()
        return !EXAppConfigManager.sharedInstance.isRequireGoogle() && !user.didBindPhone() && !user.didBindGoolge()
    }
    private func handleAlertCallback(_ safeType:SafetyTypes) {
        guard let vc = currentVc else {return}
        
        switch safeType {
        case .bindGoolgeOrPhone:
            let phone = EXSecurityCenterVC()
            vc.navigationController?.pushViewController(phone, animated: true)
            break
        case .nickName:
            let info = EXMyInfoVC()
            vc.navigationController?.pushViewController(info, animated: true)
            break
        case .reaName:
//            let user = UserInfoEntity.sharedInstance()
//            if user.authLevel == UserAuthLevel.pending.rawValue {
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                    EXAlert.showWarning(msg: "noun_login_pending".localized())
//                }
//               
//            }else {
                let realName = EXIDAuthenticViewController()
                vc.navigationController?.pushViewController(realName, animated: true)
//            }
            break
        case .paypwd:
            let pwd = EXChangeOTCPWVC()
            vc.navigationController?.pushViewController(pwd, animated: true)
            break
        case .payType:
            let listVc = EXOTCSupportPaymentMethodVc.instanceFromStoryboard(name: StoryBoardNameAsset)
            vc.navigationController?.pushViewController(listVc, animated: true)
            break
        case .bindGoogle:
            let listVc = EXGoogleBindingVC()
            vc.navigationController?.pushViewController(listVc, animated: true)
            break
        case .bindPhone:
            let bindPhone = EXMoblieBindingVC()
            vc.navigationController?.pushViewController(bindPhone, animated: true)
            break
        case .none:
            break
        }
    }

}

