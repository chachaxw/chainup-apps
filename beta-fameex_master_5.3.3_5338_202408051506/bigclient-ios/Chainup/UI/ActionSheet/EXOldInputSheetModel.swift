//
//  EXOldInputSheetModel.swift
//  Chainup
//
//  Created by liuxuan on 2023/3/16.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit


enum EXSafetyCheckType{
    case fundPasswordSet
    case fundPasswordModify
    case fundPasswordForget
    case fundPasswordForgetToReset
    case fundPasswordUnbind
    case whiteListOpen
    case whiteListClose
    case addressAdd
    case addressDelete
    case c2csales
    case coinReleaseOrderVerification
    case withdrawal
    case directTransferWithinTheStation
    case phoneloginPwdForget
    case emialloginPwdForget
    
}

enum SheetFieldItemlStyle {
    case input //Pure input box
    case sms //Sender of verification code
    case paste //Sticking function
}

enum InputCodeType: String{
    case phone = "mobile"
    case email = "emailValidCode"
    case google = "googleCode"
    case fundPassWord = "fundPassWord"
    var submitKey: String{
        switch self {
        case .phone:
            return "mobile"
        case .email:
            return "emailValidCode"
        case .google:
            return "googleCode"
        case .fundPassWord:
            return "fundPassWord"
        }
    }
    var title: String{
        switch self {
        case .phone:
            return UserInfoEntity.sharedInstance().mobileNumber //.privateShow()
        case .email:
            return UserInfoEntity.sharedInstance().email//.privateShow()
        case .google:
            return "personal_text_googleCode"
        case .fundPassWord:
            return "otc_text_pwd"
        }
    }
    
    var placeHoder: String{
        switch self {
        case .phone:
            return "personal_text_phoneCode"
        case .email:
            return "personal_text_mailCode"
        case .google:
            return "personal_text_googleCode"
        case .fundPassWord:
            return "otc_text_pwd"
        }
    }
    
    var keyBoardType: UIKeyboardType{
        switch self {
        case .fundPassWord:
            return .default
        default:
            return .numberPad
        }
    }
    
    var actionType: SheetFieldItemlStyle{
        switch self {
        case .google:
            return .paste
        case .fundPassWord:
            return .input
        default:
            return .sms
        }
    }
}


extension String {
    func privateShow() -> String {
        if self.count > 2{
            var ttt = self
            if ttt.contains("@") == true{
                let endIndex = ttt.positionOf(sub: "@",backwards: true)
                ttt.coverStringWithString("*", startIndex: 2, endindex: endIndex)
            }else{
                ttt.coverStringWithString("*", startIndex: 2, endindex: ttt.count - 2)
            }
            return ttt
        }
        return self
    }
}

class EXOldInputSheetModel: NSObject {
    typealias ClickBlock = () -> ()//Click on block
    typealias inputValidBlock = (_ str: String) -> Bool//Legitimacy verification
    var validBlock : inputValidBlock? //Error prompt verification
    var validbtnEnableBlock : inputValidBlock? //Can the button be clicked
    var clickBlock : ClickBlock?
    var title:String = ""//The title of the input box is not written if it is not present
    var inputText:String = ""//The content of the input box
    var inputPlaceHoloder:String = ""//Placeholder for input box
    var type:SheetFieldItemlStyle = .input
    var keyboard:UIKeyboardType = UIKeyboardType.default
    var key:String = ""
    var enablePrivacy:Bool = false
    var enableTitleMode:Bool = false
    var unit = ""
    var errorTip: String = ""
    var errorTipShow: Bool = false
    var maxInput: Int = 0
    //new add
    var inputCodeKey: InputCodeType = .phone
    
    class func setModel(withTitle:String = "",
                        key:String,
                        inputText:String = "",
                        placeHolder:String = "",
                        type:SheetFieldItemlStyle = .input,
                        privacyMode:Bool = false,
                        keyBoard:UIKeyboardType = .default,
                        unit:String = "",
                        errorTip:String = "") -> EXOldInputSheetModel{
        let model = EXOldInputSheetModel.init()
        if withTitle.isEmpty {
            model.enableTitleMode = false
        }else {
            model.enableTitleMode = true
        }
        model.key = key
        model.title = withTitle
        model.inputText = inputText
        model.inputPlaceHoloder = placeHolder
        model.type = type
        model.enablePrivacy = privacyMode
        model.keyboard = keyBoard
        model.unit = unit
        model.errorTip = errorTip
        return model
    }
    
    class func newSetModel(withTitle:String = "",
                           inputText:String = "",
                           placeHolder:String = "",
                           inputCodeKey:InputCodeType = .phone,
                           type:SheetFieldItemlStyle = .input,
                           privacyMode:Bool = false,
                           keyBoard:UIKeyboardType = .default,
                           unit:String = "",
                           errorTip:String = "") -> EXOldInputSheetModel{
        let model = EXOldInputSheetModel()
        if withTitle.isEmpty {
            model.enableTitleMode = false
        }else {
            model.enableTitleMode = true
        }
        model.maxInput = 0
        model.inputCodeKey = inputCodeKey
        model.title = withTitle
        model.inputText = inputText
        model.inputPlaceHoloder = placeHolder
        model.type = type
        model.enablePrivacy = privacyMode
        model.keyboard = keyBoard
        model.unit = unit
        if model.inputCodeKey == .email || model.inputCodeKey == .phone || model.inputCodeKey == .google{
            model.maxInput = 6
            model.errorTip = "security_verification_tips1".localized()
            model.validbtnEnableBlock = { str -> Bool in
                return str.count == 6
            }
        }
        
        
        
        return model
    }
   class func getSafeVertifcationModels()->[EXOldInputSheetModel] {
        var models : [EXOldInputSheetModel] = []

        if UserInfoEntity.sharedInstance().isOpenMobileCheck != "0"{//Mobile email
            let model = EXOldInputSheetModel.setModel(withTitle:UserInfoEntity.sharedInstance().mobileNumber,key:"mobile",placeHolder: "personal_tip_inputPhoneCode".localized(), type: .sms , keyBoard : .numberPad)
            models.append(model)
        }
       if UserInfoEntity.sharedInstance().didBindMail() {  //mailbox
           let mail = EXOldInputSheetModel.setModel(withTitle:UserInfoEntity.sharedInstance().email,key:"emailValidCode",placeHolder: "personal_text_mailCode".localized(), type: .sms, keyBoard : .numberPad)
           models.append(mail)
       }
       
        if UserInfoEntity.sharedInstance().googleStatus != "0"{//Google
            let model = EXOldInputSheetModel.setModel(withTitle:"personal_text_googleCode".localized(),key:"googleCode",placeHolder: "common_tip_googleAuth".localized(), type: .paste, keyBoard : .numberPad)
            models.append(model)
        }
        return models
    }
    
    
    
}


extension EXOldInputSheetModel{
    
    class func getSafeCheckList(safeType: EXSafetyCheckType) -> [EXOldInputSheetModel]{
       
        switch safeType {
        case .fundPasswordSet,.fundPasswordModify,.fundPasswordForgetToReset:
            return getInputItemRule1()
        case .fundPasswordForget,.fundPasswordUnbind,.whiteListOpen,.whiteListClose,.addressAdd,.addressDelete:
            return getInputItemRule2()
        case .c2csales,.coinReleaseOrderVerification:
            return getInputItemRule3()
        case .withdrawal,.directTransferWithinTheStation:
            return getInputItemRule4()
        default:
            return [EXOldInputSheetModel]()
        }
       
    }
    
    
    
    class func getInputItem(type: InputCodeType) -> EXOldInputSheetModel{
        let model = EXOldInputSheetModel.newSetModel(
            withTitle:type.title.localized(),
            placeHolder:type.placeHoder.localized(), 
            inputCodeKey: type,
            type: type.actionType,
            keyBoard: type.keyBoardType)
        return model
        
    }
  
//    class func getTest() -> [EXOldInputSheetModel]{
//        var models : [EXOldInputSheetModel] = []
//       
//        let model = EXOldInputSheetModel.getInputItem(type: .google)
//        models.append(model)
//       
//        let model1 = EXOldInputSheetModel.getInputItem(type: .phone)
//        models.append(model1)
//         
//        let model2 = EXOldInputSheetModel.getInputItem(type: .email)
//        models.append(model2)
//        
//        let model3 = EXOldInputSheetModel.getInputItem(type: .fundPassWord)
//        models.append(model3)
//
//        return models
//    }
    
    /**
     
     A. 先校验是否绑定谷歌，已绑定谷歌，则展示谷歌验证码验证；
     B. 未绑定谷歌，校验是否绑定手机号，已绑定手机，则展示短信验证码验证；
     C. 未绑定谷歌和手机，则展示邮箱验证码验证。
     只取其一
     
     A. First, verify whether it is bound to Google. If it is already bound to Google, display the Google verification code for verification;
     B. If it is not bound to Google, verify whether it is bound to a phone number. If it is already bound to a phone, display the SMS verification code for verification;
     C. If Google and mobile are not bound, email verification code verification will be displayed.
     Take only one of them
     
     */
    class func getInputItemRule1() -> [EXOldInputSheetModel]{
        var models : [EXOldInputSheetModel] = []
        if UserInfoEntity.sharedInstance().didBindGoolge() {//Google
            let model = EXOldInputSheetModel.getInputItem(type: .google)
            models.append(model)
            return models
        }
        
        if UserInfoEntity.sharedInstance().didBindPhone(){//Mobile
            let model = EXOldInputSheetModel.getInputItem(type: .phone)
            models.append(model)
            return models
        }
        if UserInfoEntity.sharedInstance().didBindMail() {  //mailbox
           let model = EXOldInputSheetModel.getInputItem(type: .email)
           models.append(model)
           return models
        }
       
        return models
    }
    
    /**
     A.校验是否绑定手机和邮箱，两者均绑定或绑定手机号没绑定邮箱则使用短信验证，如没绑定手机，则使用邮箱验证；
     B.校验是否绑定谷歌,若绑定则验证，若没绑定则不验证。
     按顺序判断
     
     
     A. Verify whether the phone and email are bound. If both are bound or if the phone number is not bound to the email, use SMS verification. If the phone is not bound, use email verification;
     B. Verify whether it is bound to Google. If it is bound, verify it. If it is not bound, do not verify it.
     Judging in order
     
    */
    class  func getInputItemRule2() -> [EXOldInputSheetModel]{
        var models : [EXOldInputSheetModel] = []
        let phoneModel = EXOldInputSheetModel.getInputItem(type: .phone)
        if UserInfoEntity.sharedInstance().didBindPhone(){//Mobile
            models.append(phoneModel)
        }else{
            if UserInfoEntity.sharedInstance().didBindMail(){//mailbox
                let emailModel = EXOldInputSheetModel.getInputItem(type: .email)
                models.append(emailModel)
            }
        }
        if UserInfoEntity.sharedInstance().didBindGoolge() {//Google
            let model = EXOldInputSheetModel.getInputItem(type: .google)
            models.append(model)
        }
        return models
    }
    
    // force google > phone or google
    
    /**
     已设置【资金密码】，仅进行资金密码验证
     
     未设置【资金密码】：
     -判断是否开启了强制谷歌验证，如果开启了则弹窗进行谷歌验证；
     -如果未开启，则判断是否绑定手机、谷歌。如果二者均绑定则均验证，如果只绑定其一，则验证已绑定项。
     
     
     The 'Fund Password' has been set, only for fund password verification
     No fund password set:
     -Determine whether mandatory Google verification is enabled, and if it is enabled, pop up a window for Google verification;
     -If it is not enabled, determine whether to bind to the phone or Google. If both are bound, both are validated. If only one is bound, the bound item is validated.
     
     
     */
    class func getInputItemRule3() -> [EXOldInputSheetModel]{
        var models : [EXOldInputSheetModel] = []
        
        if UserInfoEntity.sharedInstance().didSetPayPwd() {//Fund Password
            let model = EXOldInputSheetModel.getInputItem(type: .fundPassWord)
            models.append(model)
            return models
        }
        let google = EXOldInputSheetModel.getInputItem(type: .google)
        if EXAppConfigManager.sharedInstance.isRequireGoogle() {
            if UserInfoEntity.sharedInstance().didBindGoolge() {//Google
                models.append(google)
            }
            return models
        }else{
            if UserInfoEntity.sharedInstance().didBindPhone(){//Mobile
                let model = EXOldInputSheetModel.getInputItem(type: .phone)
                models.append(model)
            }
           
            if UserInfoEntity.sharedInstance().didBindGoolge() {//Google
                models.append(google)
            }
        }
        
        return models
    }
    
    
    /**
     判断是否开启强制谷歌验证：
     -若开启，则弹窗验证谷歌
     -若未开启
       A.校验是否绑定手机号和邮箱，两者均绑定或绑定手机号没绑定邮箱则使用短信验证，如没绑定手机，则使用邮箱验证；
       B.校验是否绑定谷歌，绑定则验证，没绑定则不验证；
       C.交易资金密码是否设置，已设置则验证，未设置则不验证。
     按顺序判断
     
     Determine whether to enable mandatory Google verification:
     -If enabled, pop up to verify Google
     -If not turned on
     A. Verify whether the phone number and email are bound. If both are bound or if the phone number is not bound to the email, use SMS verification. If the phone number is not bound, use email verification;
     B. Verify if it is bound to Google, verify if it is bound, and do not verify if it is not bound;
     C. Is the transaction fund password set? If it is set, it will be verified; if it is not set, it will not be verified.
     Judging in order
     
     
     
     
     */
    class func getInputItemRule4() -> [EXOldInputSheetModel]{
        var models : [EXOldInputSheetModel] = []
        let google = EXOldInputSheetModel.getInputItem(type: .google)
        if EXAppConfigManager.sharedInstance.isRequireGoogle() {
            if UserInfoEntity.sharedInstance().didBindGoolge() {//Google
                models.append(google)
            }
            return models
        }else{
            if UserInfoEntity.sharedInstance().didBindPhone(){//Mobile
                let model = EXOldInputSheetModel.getInputItem(type: .phone)
                models.append(model)
            }else{
                if UserInfoEntity.sharedInstance().didBindMail(){//mailbox
                    let emailModel = EXOldInputSheetModel.getInputItem(type: .email)
                    models.append(emailModel)
                }
            }
            
            if UserInfoEntity.sharedInstance().didBindGoolge() {//Google
                let model = EXOldInputSheetModel.getInputItem(type: .google)
                models.append(model)
            }
            if UserInfoEntity.sharedInstance().didSetPayPwd() {//fundPassWord
                let model = EXOldInputSheetModel.getInputItem(type: .fundPassWord)
                models.append(model)
            }
        }
        return models
    }
    
    
}
