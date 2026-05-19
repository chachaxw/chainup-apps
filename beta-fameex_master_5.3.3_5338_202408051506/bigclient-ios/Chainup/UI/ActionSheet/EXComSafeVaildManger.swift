//
//  EXComSafeVaildManger.swift
//  Chainup
//
//  Created by cwd on 2023/11/23.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import RxSwift
import EXKit
/**
 所有的安全校验
 All security checks
 */

class EXCodeResult: NSObject{
    var phoneCode: String?
    var emailCode: String?
    var googleCode: String?
    var fundPassWord: String?
    class func getResultFormList(list: [EXOldInputSheetModel]) -> EXCodeResult{
        let result = EXCodeResult()
        for item in list {
            switch item.inputCodeKey {
            case .phone:
                result.phoneCode = item.inputText
            case .email:
                result.emailCode = item.inputText
            case .google:
                result.googleCode = item.inputText
            case .fundPassWord:
                result.fundPassWord = item.inputText
            }
        }
        return result
    }
}
class EXComSafeVaildManger: NSObject{
    
    typealias ResultCallBack  = (EXCodeResult) -> ()
    var resultCallBack: ResultCallBack?
    var actionCancelCallback: EXComVoidBlock?
    let disposeBag = DisposeBag()
    /**
     验证码类型
     需要发送验证码
     
     Verification code type
     When a verification code needs to be sent, it must be transmitted
     */
    
    /**
     安全验证场景，不同的场景需要验证项的多少不一样
     Security verification scenarios require varying numbers of verification items for different scenarios
     */
    var safeCheck: EXSafetyCheckType = .fundPasswordSet {
        didSet{
            self.configSendCodeOperate()
        }
    }
    
    
    
    
    
    private var sendPhoneVerificationCodeType: String?

    private var sendEmailVerificationCodeType: String?

    /*
     * list
     */
    func startSafeAlert(list:[EXOldInputSheetModel]? = nil){
        var checkList = EXOldInputSheetModel.getSafeCheckList(safeType: self.safeCheck)
        if let list = list,list.isEmpty == false {
            checkList = list
        }
        let sheet = EXOldActionSheetView()
        sheet.configTextfields(title: "common_text_safetyAuth".localized(), itemModels:checkList)
        sheet.autoDismiss = false
    //        sheet.autoSendMsg()
        sheet.actionCancelCallback = { [weak self] in
            guard let `self` = self else { return }
            self.actionCancelCallback?()
        }
        sheet.newResultCallBack = { () in
//            for item in checkList {
//                print("item = \(item.title)  value = \(item.inputText)")
//            }
            
            let result = EXCodeResult.getResultFormList(list: checkList)
            EXAlert.dismissEnd {
                self.resultCallBack?(result)
            }
        }
        sheet.newItemBtnCallback = { model in
            
            switch model.inputCodeKey{
            case .email:
                self.getemailVallidCode()
            case .phone:
                self.getsmsValidCode()
            default:
                break
            }
        }
        EXAlert.showSheet(sheetView:sheet,bgTapCancel: false)
    }
    
}
extension EXComSafeVaildManger{
    
    func configSendCodeOperate(){
        switch safeCheck {
        case .fundPasswordSet,.fundPasswordForgetToReset:
            sendPhoneVerificationCodeType = EXSendVerificationCode.changeotcpw
            sendEmailVerificationCodeType = EXSendVerificationCode.changeotcpw
        case .fundPasswordModify:
            sendPhoneVerificationCodeType = EXSendVerificationCode.modifyFundPwd
            sendEmailVerificationCodeType = EXSendVerificationCode.modifyFundPwd
        case .fundPasswordForget:
            sendPhoneVerificationCodeType = EXSendVerificationCode.forgetFundPwd
            sendEmailVerificationCodeType = EXSendVerificationCode.forgetFundPwd
        case .fundPasswordUnbind:
            sendPhoneVerificationCodeType = EXSendVerificationCode.unbindFundPwd
            sendEmailVerificationCodeType = EXSendVerificationCode.unbindFundPwd
        case .whiteListOpen:
            sendPhoneVerificationCodeType = EXSendVerificationCode.whiteListOpen
            sendEmailVerificationCodeType = EXSendVerificationCode.whiteListOpen
        case .whiteListClose:
            sendPhoneVerificationCodeType = EXSendVerificationCode.whiteListClose
            sendEmailVerificationCodeType = EXSendVerificationCode.whiteListClose
        case .addressAdd:
            sendPhoneVerificationCodeType = EXSendVerificationCode.addNewAddress
            sendEmailVerificationCodeType = EXMailVerificationCode.addCoinAddr
        case .addressDelete:
            sendPhoneVerificationCodeType = EXSendVerificationCode.deleteAddress
            sendEmailVerificationCodeType = EXSendVerificationCode.deleteAddress
        case .c2csales:
            sendPhoneVerificationCodeType = EXSendVerificationCode.c2cSell
            sendEmailVerificationCodeType = nil
        case .coinReleaseOrderVerification:
            sendPhoneVerificationCodeType = EXSendVerificationCode.coinReleaseConfirm
            sendEmailVerificationCodeType = nil
        case .withdrawal:
            sendPhoneVerificationCodeType = EXSendVerificationCode.Withdrawal
            sendEmailVerificationCodeType = EXMailVerificationCode.Withdrawal
        case .directTransferWithinTheStation:
            sendPhoneVerificationCodeType = EXSendVerificationCode.internalTransfer
            sendEmailVerificationCodeType = EXMailVerificationCode.internalTransfer
        case .phoneloginPwdForget:
            sendPhoneVerificationCodeType = EXSendVerificationCode.moblieforget
        case .emialloginPwdForget:
            sendEmailVerificationCodeType = EXSendVerificationCode.emailforget
        default:
            break
        }
    }
    
    
}
extension EXComSafeVaildManger{
    //Obtain mobile verification code
    func getsmsValidCode(){
        print("com sms verification code")
        appApi.rx.request(.getsmsValidCode(token: XUserDefault.getToken() ?? "", operationType:  self.sendPhoneVerificationCodeType, countryCode: "", mobile: "")).MJObjectMap(EXVoidModel.self).subscribe(onSuccess: { (m) in
            EXAlert.showSuccess(msg: LanguageTools.getString(key: "login_tip_didSendCode"))
        }) { (erro) in
            
            }.disposed(by: disposeBag)
    }
    
    
    //Obtain email verification code
        func getemailVallidCode(){
            print("com email verification code")
            appApi.rx.request(.getemailVallidCode(email: "", operationType: self.sendEmailVerificationCodeType,token: "")).MJObjectMap(EXVoidModel.self).subscribe(onSuccess: { (m) in
                EXAlert.showSuccess(msg: LanguageTools.getString(key: "login_tip_didSendCode"))
            }) { (erro) in
                
                }.disposed(by: disposeBag)
        }
}
