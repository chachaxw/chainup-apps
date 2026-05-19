//
//  EXAccountDeleteController.swift
//  Chainup
//
//  Created by cwd on 2023/2/8.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import EXKit
import Swap
class EXAccountDeleteController: NavCustomVC {

    var successMsg = ""
    var vm =  EXAccountDeleteViewModel()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configSubView()
        self.updateAssets()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    //MARK: UI
    
    func configSubView(){
        self.view.addSubview(mainView)
        mainView.snp.makeConstraints { make in
            make.top.equalTo(NAV_SCREEN_HEIGHT)
            make.left.right.bottom.equalToSuperview()
        }
    }
    
    
    lazy var mainView: EXAccountDeleteMainView = {
        let m = EXAccountDeleteMainView()
        m.updatebottomTip(money: "")
        m.deleteBtnClickBlock = { [weak self] in
            guard let newSelf = self else{
                return
            }
            
            
            newSelf.vm.getCancelVerfication {
                newSelf.alert.resultList = newSelf.vm.result.getResult()
                EXAlert.showAlert(alertView: newSelf.alert,offset: 31~)
            } errorBlock: {
                
            }

            
        }
        return m
    }()
    
    lazy var alert: EXAccountAlertView = {
        
        let view = EXAccountAlertView(frame: .zero)
        view.sureDeleteBlock = { [weak self] in
            guard let newSelf = self else{
                return
            }
          //Print ("logout")
            newSelf.getMsgAlert()
        }
        return view
    }()
  
    
}
//Security verification bullet box
extension EXAccountDeleteController{
    func goHome(){
        EXAlert.dismissEnd {
            EXAlert.showSuccess(msg: self.successMsg)
        }
        //Clear Quick Login
        XUserDefault.setFaceIdOrTouchId("")
        XUserDefault.setGesturesPassword("")
        XUserDefault.quickTokenValue = nil
        XUserDefault.tokenValue = nil
        EXSwapPlatformSDK.shared.activeAccount = nil
        EXSwapPlatformSDK.shared.inviteUrl = nil
        BusinessTools.logoutNet()
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            BusinessTools.modalLoginVC()
        }
       
       
    }
    func updateAssets() {
        _ = EXAssetsManager.manager.allAssetsSignal().subscribe(onNext: { [weak self] model in
            guard let self = `self` else { return }
//            print("item = \(model.totalBalance)")
            self.mainView.updatebottomTip(money: model.totalBalance + model.assetSymbol)
        })
    }
    func getMsgAlert(){
        let sheet = EXOldActionSheetView()
        sheet.configTextfields(title: "common_text_safetyAuth".localized(), itemModels:EXOldInputSheetModel.getSafeVertifcationModels())
        sheet.autoDismiss = false
//        sheet.autoSendMsg()
        sheet.actionFormCallback = { formDic in
//            guard let mySelf = self else{return}
            var googleCode:String? = nil//Google verification code
            var mobile:String? = nil//Mobile number verification
            var email:String? = nil//Email verification
            if UserInfoEntity.sharedInstance().googleStatus != "0"{
                if let google = formDic["googleCode"]{
                    googleCode = google
                }
                if googleCode == ""{
                    EXAlert.showFail(msg: LanguageTools.getString(key: "common_tip_googleAuth".localized()))
                    return
                }
            }
            if UserInfoEntity.sharedInstance().didBindMail(){
                if let em = formDic["emailValidCode"]{
                    email = em
                }
                if email == ""{
                    EXAlert.showFail(msg: LanguageTools.getString(key: "personal_text_mailCode"))
                    return
                }
            }
            if UserInfoEntity.sharedInstance().isOpenMobileCheck != "0"{
                if let moblie = formDic["mobile"]{
                    mobile = moblie
                }
                if mobile == ""{
                    EXAlert.showFail(msg: LanguageTools.getString(key: "personal_tip_inputPhoneCode"))
                    return
                }
            }
            
            //MARK: Delete account
            self.vm.deleteAccountRequset(smsAuthCode: mobile, emailAuthCode: email, googleCode: googleCode, success: {
                [weak self] in
                guard let newSelf = self else{
                    return
                }
                newSelf.goHome()
            }, errorBlock: {
                
            },successMsg: {  [weak self] str in
                guard let newSelf = self else{
                    return
                }
                newSelf.successMsg = str ?? ""
            })
        }
        sheet.itemBtnCallback = {key in
//            guard let mySelf = self else{return}
            switch key {
            case "mobile":
                self.getsmsValidCode()
            default: //mailbox
                self.getemailVallidCode()
                break
            }
        }
        EXAlert.showSheet(sheetView:sheet)
        
    }
    
    
    //Obtain mobile verification code
    func getsmsValidCode(){
        appApi.rx.request(.getsmsValidCode(token: XUserDefault.getToken() ?? "", operationType: EXSendVerificationCode.accountdeletephone, countryCode: "", mobile: "")).MJObjectMap(EXVoidModel.self).subscribe(onSuccess: { (m) in
            EXAlert.showSuccess(msg: LanguageTools.getString(key: "login_tip_didSendCode"))
        }) { (erro) in
            
            }.disposed(by: disposeBag)
    }
    
    
    //Obtain email verification code
        func getemailVallidCode(){
            appApi.rx.request(.getemailVallidCode(email: "", operationType: EXSendVerificationCode.accountdeleteEmail,token: "")).MJObjectMap(EXVoidModel.self).subscribe(onSuccess: { (m) in
                EXAlert.showSuccess(msg: LanguageTools.getString(key: "login_tip_didSendCode"))
            }) { (erro) in
                
                }.disposed(by: disposeBag)
        }
}

