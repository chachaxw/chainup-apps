//
//  EXAccountPasswordActionVc.swift
//  Chainup
//
//  Created by wangdong on 2023/9/18.
//  Copyright © 2023 ChainUP. All rights reserved.
//

import UIKit
import YYText
import RxSwift
import RxCocoa
import IQKeyboardManagerSwift
import EXKit

enum EXAccountPasswordIntent {
    case set
    case forgot
    case reset
}

class EXAccountNewPasswordVc: UIViewController {
    var countryCode: String? = nil
    var accountContext: EXAccountContext!
    var passwordIntent: EXAccountPasswordIntent!
    let tipsLabel: YYLabel = YYLabel.init()
    var authAlert: EXSecurityAuthAlertView?
    
     //MARK: lifecycle
   
    override var preferredStatusBarStyle: UIStatusBarStyle{
        if EXThemeManager.isNight() == true{
            return .lightContent
        }else{
            return .default
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let _ = passwordIntent, let _ = accountContext else { return }
       
        configUI()
        configWaringTipLabel()
      
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.shared.enableAutoToolbar = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared.enableAutoToolbar = true
    }
    
    //MARK: lazy
    let navBar = EXAccountNavigationBar()
    lazy var warnningLabel: EXAttributedTextLabel = {
        let v = EXAttributedTextLabel()
        v.extUseAutoLayout()
        v.isHideEdgeWithEmptyText = true
        v.edgeInset = .init(top: 7, left: 16, bottom: 7, right: 16)
        return v
    }()
    
    
    
    lazy var topTextfield: EXAccountTextField = {
        let v = EXAccountTextField()
        v.highlightColor = .Ex.main1
        v.basicTextField.backgroundColor = .Ex.special2
        v.isSecureEntry = false
        return v
    }()
    
    lazy var bottomTextfield: EXAccountTextField = {
        let v = EXAccountTextField()
        v.highlightColor = .Ex.main1
        v.basicTextField.backgroundColor = .Ex.special2
        v.isSecureEntry = true
        return v
    }()
    
    lazy var nextButton: EXButton = {
        let v = EXButton(type: .custom)
        v.setTitleColor(.Ex.text4, for: .normal)
        v.setTitleColor(.Ex.text2, for: .disabled)
        return v
    }()
    
    
    
    lazy var nationCodeButton: EXLabel = {
        let v = EXLabel()
        v.extUseAutoLayout()
        v.isUserInteractionEnabled = true
        v.font = .Ex.medium(14)
        v.textColor = .Ex.text1
        v.textAlignment = .left
        v.setContentCompressionResistancePriority(.required, for: .horizontal)
        v.setContentHuggingPriority(.required, for: .horizontal)
        let tap = UITapGestureRecognizer(target: self, action: #selector(countryCodeAction))
        v.addGestureRecognizer(tap)
        return v
    }()
    
    lazy var nationCodeInditorImgV: UIButton = {
        let v = UIButton(type: .custom)
        v.setImage(EXKitBundle.image(named: "public_arrow_down"), for: .normal)
        v.rx.tap.subscribe(onNext: {[weak self] _ in
            guard let self = self else { return  }
            self.countryCodeAction()
        }).disposed(by: disposeBag)
        return v
    }()
    
}


extension EXAccountNewPasswordVc{
    func configUI(){
        view.backgroundColor = .Ex.fill2
        view.addSubview(navBar)
        navBar.setLeftClose()
        navBar.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(GH_NavStatusBarHeight)
        }
        
        if passwordIntent == .set {
            setPasswordScene()
        }else if passwordIntent == .forgot {
            topTextfield.text = accountContext.account
            forgotPasswordScene()
            topTextfield.basicTextField.leadingView.addArrangedSubviews([nationCodeButton,nationCodeInditorImgV])
            setContryToDefault()
        }else if passwordIntent == .reset {
            resetPasswordScene()
        }
        
    }
    func configWaringTipLabel(){
        
        let hour = EXAppConfigManager.sharedInstance.getUpdateWithDrawHour()
        let tip = String(format: "password_reset_tips".localized(), hour)
        
        let attributedText = NSMutableAttributedString(string: " " + tip)
        attributedText.yy_color = .Ex.warning1
        let attachment = NSAttributedString.yy_attachmentString(withContent: EXKitBundle.image(named: "public_point"),
                                                                contentMode: .scaleAspectFit,
                                                                attachmentSize: CGSize(width: 12, height: 12),
                                                                alignTo: .Ex.regular(12), alignment: .center)
        attributedText.insert(attachment, at: 0)
        attributedText.yy_font = .Ex.regular(12)
        attributedText.yy_lineSpacing = 2
        warnningLabel.attributedText = attributedText
        
        tipsLabel.attributedText = String.makeTipsAttributedString(content: "register_tip_agreement".localized(), actionContent: "register_action_agreement".localized()) { [weak self] in
            guard let self = `self` else { return }
            let statementVC = StatementVC()
            statementVC.titleStr = LanguageTools.getString(key:"register_action_agreement")
            self.navigationController?.pushViewController(statementVC, animated: true)
        }
    }
    
    
    
    
    @objc func countryCodeAction() {
        let vc = RegionVC()
        vc.clickRegionCellBlock = {[weak self] entity in
            guard let self = `self` else { return }
            self.configContryInfo(entity: entity)
        }
        EXAlert.showVc(controller: vc,ratio: 0.9)
    }
    
    func configContryInfo(entity: RegionEntity){
        let country = LanguageTools.isHan() == true ? entity.cnName : entity.enName
        let countryCode = entity.dialingCode
        self.nationCodeButton.text = country + "  " + countryCode
        self.countryCode = entity.dialingCode
    }
    
    func setContryToDefault(){
        if let region = EXAppConfigManager.sharedInstance.getRegionInfo(){
            self.configContryInfo(entity: region)
        }
    }
    
    func resetView(type:EXAccountSignUpType){
        if self.accountContext.signType == type {
            return
        }
        if type == .phone {
            self.topTextfield.basicTextField.leadingView.isHidden = false
        }else{
            self.topTextfield.basicTextField.leadingView.isHidden = true
        }
        self.accountContext.signType = type
    }
    
    
}


extension EXAccountNewPasswordVc{
    private func setPasswordScene() {
        for subview in view.subviews {
            if subview != navBar {
                subview.isHidden = true
                subview.removeFromSuperview()
            }
        }
        view.addSubViews([topTextfield, bottomTextfield, nextButton, tipsLabel])
        topTextfield.snp.makeConstraints { make in
            make.top.equalTo(navBar.snp.bottom).offset(32)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
        }
        
        topTextfield.secureTextField.trailingView.alignment = .lastBaseline
        
        bottomTextfield.snp.makeConstraints { make in
            make.top.equalTo(topTextfield.snp.bottom).offset(28)
            make.left.equalToSuperview().offset(16)
            make.height.equalTo(topTextfield.snp.height)
            make.right.equalToSuperview().offset(-16)

        }
        nextButton.snp.makeConstraints { make in
            make.top.equalTo(bottomTextfield.snp.bottom).offset(28)
            make.right.equalToSuperview().offset(-16)
            make.left.equalToSuperview().offset(16)
            make.height.equalTo(44)
        }
        tipsLabel.snp.makeConstraints { make in
            make.top.equalTo(nextButton.snp.bottom).offset(28)
            make.left.equalToSuperview().offset(16)
            make.right.lessThanOrEqualToSuperview().offset(-16)
        }
        
        navBar.title = "register_action_setPassword".localized()
        topTextfield.topLabel.text = "personal_text_newPwd".localized()
        
        let inviteCodeNess = accountContext.invitationCode_required == "1"
        var inviteCodeTitle = "register_text_inviteCode".localized() + "regitser_tip_inputOptional".localized()
        if inviteCodeNess {
            inviteCodeTitle = "common_tip_inviteCodeRequired".localized()
        }
        bottomTextfield.topLabel.text = inviteCodeTitle
        topTextfield.isSecureEntry = true
        bottomTextfield.isSecureEntry = false
        topTextfield.setAttributedPlaceholder(text: "password_input_rule_tips".localized())
        bottomTextfield.setAttributedPlaceholder(text: "common_tip_inputInviteCode".localized())
        nextButton.setTitle("register_action_register".localized(), for: .normal)
       
        let passwordSignal = topTextfield.textField.rx.text.orEmpty.asObservable()
        let inviteCodeSignal = bottomTextfield.textField.rx.text.orEmpty.asObservable()
        let combine = Observable.combineLatest(passwordSignal, inviteCodeSignal)
        
        
        combine.map { (password, inviteCode) in
            let inviteCodePass  = inviteCodeNess ? inviteCode.isValidTransactionpPwd() : true
            return inviteCodePass && password.isValidTransactionpPwd()
        }.subscribe(onNext:{[weak self] isEnabled in
            guard let self = self else { return }
            self.nextButton.isEnabled = isEnabled
        }).disposed(by: disposeBag)
        
        nextButton.rx.tap.withLatestFrom(combine).subscribe(onNext:{[weak self] (password, inviteCode) in
            guard let self = self else { return }
            self.requestRegisterThree(password: password, inviteCode: inviteCode)
        }).disposed(by: disposeBag)
    }
    
   
    
    private func forgotPasswordScene() {
        
        
        for subview in view.subviews {
            if subview != navBar {
                subview.isHidden = true
                subview.removeFromSuperview()
            }
        }
        view.addSubViews([warnningLabel, topTextfield, nextButton])
        warnningLabel.snp.makeConstraints { make in
            make.top.equalTo(self.navBar.snp.bottom)
            make.centerX.width.equalToSuperview()
        }
        topTextfield.snp.makeConstraints { make in
            make.top.equalTo(warnningLabel.snp.bottom).offset(32)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
        }
        nextButton.snp.makeConstraints { make in
            make.top.equalTo(topTextfield.snp.bottom).offset(28)
            make.centerX.width.equalTo(topTextfield)
            make.height.equalTo(44)
        }
        

        self.navBar.title = "login_action_fogotPassword".localized()
        let attributedText = NSMutableAttributedString(string: " " + "password_reset_tips".localized())
        attributedText.yy_color = .Ex.warning1
        let attachment = NSAttributedString.yy_attachmentString(withContent: EXKitBundle.image(named: "public_point"),
                                                                contentMode: .scaleAspectFit,
                                                                attachmentSize: CGSize(width: 12, height: 12),
                                                                alignTo: .Ex.regular(12), alignment: .center)
        attributedText.insert(attachment, at: 0)
        attributedText.yy_font = .Ex.regular(12)
        attributedText.yy_lineSpacing = 2
        warnningLabel.attributedText = attributedText
        topTextfield.topLabel.text = "userinfo_text_account".localized()
        topTextfield.setAttributedPlaceholder(text: "common_tip_inputPhoneOrMail".localized())
        nextButton.setTitle("common_action_next".localized(), for: .normal)
        
        let accountSignal = topTextfield.textField.rx.text.orEmpty.asObservable()
        accountSignal.map { [weak self] text -> Bool in
            guard let self = self else { return  false}
            if text.count > 3 && text.isNumber() == true{
                self.resetView(type: .phone)
            }else {
                self.resetView(type: .mail)
            }
            return (text.count > 0) && (text.isEmail() || text.isPhone())
        }.subscribe(onNext: { [weak self] isEnabled in
            guard let self = self else { return }
            self.nextButton.isEnabled = isEnabled
        }).disposed(by: self.disposeBag)
        
        nextButton.rx.tap.withLatestFrom(accountSignal).subscribe(onNext: { [weak self] account in
            guard let self = self else { return }
            EXCaptchaMananger.shared.showCaptcha(inVc: self) { success in
                if success {
                    self.requestResetPasswordStepOne()
                }
            }
        }).disposed(by: self.disposeBag)
        
    }
    
    private func resetPasswordScene() {
        
        for subview in view.subviews {
            if subview != navBar {
                subview.isHidden = true
                subview.removeFromSuperview()
            }
        }
        view.addSubViews([warnningLabel, topTextfield, bottomTextfield, nextButton])
        warnningLabel.snp.makeConstraints { make in
            make.top.equalTo(self.navBar.snp.bottom)
            make.centerX.width.equalToSuperview()
        }
        topTextfield.snp.makeConstraints { make in
            make.top.equalTo(warnningLabel.snp.bottom).offset(34)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
        }
        topTextfield.secureTextField.trailingView.alignment = .lastBaseline

        bottomTextfield.snp.makeConstraints { make in
            make.top.equalTo(topTextfield.snp.bottom).offset(28)
            make.centerX.width.equalTo(topTextfield)
        }
        nextButton.snp.makeConstraints { make in
            make.top.equalTo(bottomTextfield.snp.bottom).offset(28)
            make.centerX.width.equalTo(bottomTextfield)
            make.height.equalTo(44)
        }
        
        self.navBar.title = "login_action_resetPassword".localized()
       
        
        ///
        topTextfield.topLabel.text = "personal_text_newPwd".localized()
        bottomTextfield.topLabel.text = "personal_text_confirmPwd".localized()
        topTextfield.isSecureEntry = true
        topTextfield.setAttributedPlaceholder(text: "password_input_rule_tips".localized())
        bottomTextfield.setAttributedPlaceholder(text: "register_tip_repeatPassword".localized())
        nextButton.setTitle("common_text_btnConfirm".localized(), for: .normal)
        
        ///
        let combineSigal = Observable.combineLatest(topTextfield.textField.rx.text.orEmpty.asObservable(), bottomTextfield.textField.rx.text.orEmpty.asObservable())
        combineSigal.map { (password, confirmPassword) in
            return password.count > 0 && confirmPassword.count > 0 && password.isValidTransactionpPwd()
            //&& password == confirmPassword
        }.subscribe(onNext: { [weak self] isEnabled in
            guard let self = self else { return }
            self.nextButton.isEnabled = isEnabled
        }).disposed(by: disposeBag)
        
        nextButton.rx.tap.withLatestFrom(combineSigal).subscribe(onNext: {[weak self] (password, confirmPassword) in
            guard let self = self else { return }
            if password != confirmPassword {
                EXAlert.showFail(msg: "common_tip_inputsNotMatch".localized())
                return
            }
            self.requestResetPasswordStepThree(password: password)
        }).disposed(by: disposeBag)
    }
}
//MARK: request
extension EXAccountNewPasswordVc{
    func requestSendCode() {
        if self.accountContext.account.isPhone() {
            self.accountContext.signType = .phone
            _ = appApi
                .rx
                .request(.getsmsValidCode(token: self.accountContext.token,
                                          operationType: EXSendVerificationCode.moblieforget,
                                          countryCode:"",
                                          mobile: ""))
                .MJObjectMap(EXVoidModel.self)
                .autoShowLoadingOnController(context: self)
                .subscribe(onSuccess: { (response) in
                    
                }) { _ in
                    
            }.disposed(by: disposeBag)
        }
        else if self.accountContext.account.isEmail() {
            self.accountContext.signType = .mail
            _ = appApi
                .rx
                .request(.getemailVallidCode(email: self.accountContext.account, operationType: EXSendVerificationCode.emailforget,token : self.accountContext.token))
                .MJObjectMap(EXVoidModel.self)
                .autoShowLoadingOnController(context: self)
                .subscribe(onSuccess: { (response) in
                    
                }) { _ in
                    
            }.disposed(by: disposeBag)
        }
    }
    
    
    func requestResetPasswordStepOne(){
        if self.accountContext.signType == .phone {
            self.accountContext.countryCode = self.countryCode ?? ""
        }
        self.accountContext.account = topTextfield.text ?? ""
        _ = appApi.rx.request(.userResetPasswordStepOne(accountContext: self.accountContext))
            .MJObjectMap(EXResetPasswordStepOneDataModel.self).autoShowLoadingOnController(context: self)
            .subscribe(onSuccess: { [weak self] dataModel in
                guard let self = `self` else { return }
                self.securityAuthAlert(dataModel: dataModel)
            }, onFailure: { [weak self] error in
                self?.view.hideLoading1()
            })
    }
    
    func securityAuthAlert(dataModel :EXResetPasswordStepOneDataModel){
        self.accountContext.token = dataModel.token
        self.requestSendCode()
        self.authAlert = EXSecurityAuthAlertView()
        self.authAlert?.needInputGoogleCode = dataModel.isGoogleAuth == "1"
        self.authAlert?.needInputCertifcateCode = false
        self.authAlert?.codeInputViewTitle = self.accountContext.desensitizedAccount
        if self.accountContext.signType == .phone {
            self.authAlert?.codeInputViewPlaceholder = "personal_tip_inputPhoneCode".localized()
        }
        else if self.accountContext.signType == .mail {
            self.authAlert?.codeInputViewPlaceholder = "personal_tip_inputMailCode".localized()
        }
        
        self.authAlert?.didSubmit = { a, b, c in
            self.requestResetPasswordStepTwo(code: a, googleCode: b, certifcateCode: c)
        }
        
        self.authAlert?.codeInputAction = {
            self.requestSendCode()
        }
        
        if self.authAlert != nil {
            EXAlert.showAlertFollowKeyboard(alertView: self.authAlert!)
        }
        
    }
    
    func requestResetPasswordStepTwo(code: String?, googleCode: String?, certifcateCode: String?) {
        _ = appApi
            .rx
            .request(.userResetPasswordStepTwo(accountContext: self.accountContext,
                                               code: code,
                                               googleCode: googleCode,
                                               certifcateCode: certifcateCode))
            .MJObjectMap(EXVoidModel.self)
            .autoShowLoadingOnButton(button: self.authAlert?.submitButton)
            .subscribe(onSuccess: { [weak self] _ in
                guard let self = `self` else { return }
                self.authAlert?.hide()
                EXAlert.dismissEnd {
                    let passwordVc = EXAccountNewPasswordVc()
                    passwordVc.accountContext = self.accountContext
                    passwordVc.passwordIntent = EXAccountPasswordIntent.reset
                    self.navigationController?.pushViewController(passwordVc, animated: true)
                }
            }, onFailure: { error in
                  
            })
    }
    
    func requestResetPasswordStepThree(password: String) {
        _ =  appApi
            .rx
            .request(.userResetPasswordStepThree(accountContext: self.accountContext,
                                                 password: password))
            .MJObjectMap(EXVoidModel.self, true, customHandleCode: { () -> (String) in
                return "10021"
            })
            .autoShowLoadingOnController(context: self)
            .subscribe(onSuccess: { [weak self] _ in
                guard let self = `self` else { return }
                XUserDefault.mobileNumberValue = self.accountContext.account
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.navigationController?.popToRootViewController(animated: true)
                }
            }, onFailure: { [weak self] error in
                    //Token has expired, please try again
                    if let customError = (error as? CustomNetworkError), customError == .ExpireTokenError {
                        EXAlert.showFail(msg: "account_action_token_expire_tip".localized())
                        self?.navigationController?.popToRootViewController(animated: true)
                    }
            })
    }
    
    
    
    private func requestRegisterThree(password: String, inviteCode: String) {
        appApi
            .rx
            .request(.registerThree(registerCode: self.accountContext.account,
                                    loginPword: password,
                                    newPassword: password,
                                    invitedCode: inviteCode))
            .MJObjectMap(EXUserConfirmPwdDataModel.self)
            .autoShowLoadingOnController(context: self)
            .subscribe(onSuccess: {[weak self] (dataModel) in
                guard let self = `self` else { return }
//                print(" \(self.accountContext.countryCode)")
                if (self.accountContext.countryCode.isEmpty == false){
                    XUserDefault.setValueForKey(self.accountContext.countryCode, key: XUserDefault.countryNumber)
                }
                UserInfoEntity.sharedInstance().loginSuccess(dataModel.token,
                                                             quickToken: dataModel.token,
                                                             account: self.accountContext.account,
                                                             loginPwd: "")
                UserInfoEntity.sharedInstance().getUserInfo({
                    EXAlert.showSuccess(msg: LanguageTools.getString(key: "login_tip_loginsuccess"))
                    if let str = XUserDefault.getFaceIdOrTouchIdPassword(),str == "" &&
                        UserInfoEntity.sharedInstance().gesturePwd.ch_length < 3 {
                        self.dismiss(animated: true) {
                            let vc = GesstureAlertVC()
                            if let nav = BusinessTools.getRootNavBar(){
                                nav.pushViewController(vc, animated: true)
                            }
                            EXGameJumpManager.shareInstance.presentAuthorVc()
                        }
                    }else{
                        self.dismiss(animated: true, completion: nil)
                        EXGameJumpManager.shareInstance.presentAuthorVc()
                    }
                }) {
                    UserInfoEntity.sharedInstance().logout()
                    self.dismiss(animated: true, completion: nil)
                    EXAlert.showFail(msg: "get_userinfo_failed_tip".localized())
                }
            }) { _ in
                
        }.disposed(by: self.disposeBag)
    }
}
