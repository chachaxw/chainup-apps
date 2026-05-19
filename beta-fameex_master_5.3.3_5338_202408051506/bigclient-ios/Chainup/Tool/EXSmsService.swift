//
//  EXSmsService.swift
//  Chainup
//
//  Created by liuxuan on 2023/5/18.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

enum EXCodeTypes {
    case google
    case sms
    case mail
    case none
}

class EXSmsServiceModel:NSObject {
    var key = ""
    var codeType:EXCodeTypes = .none
}

class EXSmsService: NSObject {
    let disposeBag = DisposeBag()
    
    typealias ServiceDidFinishCallback = ([String:String])->()
    var onServiceFinishCallback:ServiceDidFinishCallback?

    func getOTCAddPaymentService() {
        let user = UserInfoEntity.sharedInstance()
        var verifycations:[EXOldInputSheetModel] = []
        
        if user.didBindPhone() {
            let phone = EXOldInputSheetModel.setModel(withTitle:user.mobileNumber,key:"smsAuthCode",placeHolder: "personal_tip_inputPhoneCode".localized(), type: .sms)
            verifycations.append(phone)
        }
        
        if user.didBindGoolge() {
            let google = EXOldInputSheetModel.setModel(withTitle:"personal_text_googleCode".localized(),key:"googleCode",placeHolder: "common_tip_googleAuth".localized(), type: .paste)
            verifycations.append(google)
        }
        
//        if user.didBindPhone() == false && user.didBindMail() == true {
//            let mail = EXOldInputSheetModel.setModel(withTitle:user.mobileNumber,key:"emailValidCode",placeHolder: "personal_text_mailCode".localized(), type: .sms)
//            verifycations.append(mail)
//        }
        
        let sheet = EXOldActionSheetView()
        sheet.itemBtnCallback = {[weak self] key in
            self?.handlePaymentAddSheetAction(key)
        }
        sheet.configTextfields(title: "login_action_fogetpwdSafety".localized(), itemModels:verifycations)
        sheet.actionFormCallback = {[weak self] formDic in
            self?.onServiceFinishCallback?(formDic)
        }
        EXAlert.showSheet(sheetView:sheet)
    }
    
    func getOTCAddAddressService(_ smsType:String = EXSendVerificationCode.addNewAddress) {
        let user = UserInfoEntity.sharedInstance()
        var verifycations:[EXOldInputSheetModel] = []
        
        if user.didBindPhone() {
            let phone = EXOldInputSheetModel.setModel(withTitle:user.mobileNumber,key:"smsAuthCode",placeHolder: "personal_text_smsCode".localized(), type: .sms)
            verifycations.append(phone)
        }
        //Adding an address requires Google verification. Delete unnecessary
        if smsType == EXSendVerificationCode.addNewAddress {
            if user.didBindGoolge() {
                let google = EXOldInputSheetModel.setModel(withTitle:"personal_text_googleCode".localized(),key:"googleCode",placeHolder: "common_tip_googleAuth".localized(), type: .paste)
                verifycations.append(google)
            }
        }
        
        let sheet = EXOldActionSheetView()
        sheet.itemBtnCallback = {[weak self] key in
            self?.handleAddressAddSheetAction(key,smsType)
        }
        sheet.configTextfields(title: "login_action_fogetpwdSafety".localized(), itemModels:verifycations)
        sheet.actionFormCallback = {[weak self] formDic in
            self?.onServiceFinishCallback?(formDic)
        }
        EXAlert.showSheet(sheetView:sheet)
    }
    
    func handlePaymentAddSheetAction(_ key:String) {
        if key == "smsAuthCode" {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.4) {
                appApi.hideAutoLoading()
                appApi.rx.request(.getsmsValidCode(token: "", operationType: EXSendVerificationCode.otcAddPayment, countryCode: "", mobile: ""))
                    .MJObjectMap(EXVoidModel.self)
                    .subscribe{event in
                        switch event {
                        case .success(_):
                            break
                        case .failure(_):
                            break
                        }
                    }.disposed(by: self.disposeBag)
            }
        }
    }
    
    func handleAddressAddSheetAction(_ key:String, _ smsType:String) {
        if key == "smsAuthCode" {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.4) {
                appApi.hideAutoLoading()
                appApi.rx.request(.getsmsValidCode(token: "", operationType: smsType, countryCode: "", mobile: ""))
                    .MJObjectMap(EXVoidModel.self)
                    .subscribe{event in
                        switch event {
                        case .success(_):
                            break
                        case .failure(_):
                            break
                        }
                    }.disposed(by: self.disposeBag)
            }
        }
    }

}

