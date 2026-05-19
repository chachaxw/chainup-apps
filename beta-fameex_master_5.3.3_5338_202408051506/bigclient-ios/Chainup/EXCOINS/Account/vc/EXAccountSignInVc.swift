//
//  EXAccountSignInVc.swift
//  Chainup
//
//  Created by wangdong on 2023/9/17.
//  Copyright © 2023 ChainUP. All rights reserved.
//

import UIKit
import YYText
import RxSwift
import RxCocoa
import SwiftEntryKit
import YYWebImage
import EXKit
import JXSegmentedView
class EXAccountSignInVc: BaseVC {
    var loginType: EXAccountSignUpType = .none
    var countryCode: String? = nil   
     //MARK: lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configSubView()
        setContryToDefault()
        self.accountTextfield.leadingView.isHidden = true
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let num = XUserDefault.mobileNumberValue, num.count > 0 {
//            accountInputView.set(value: num)
            accountTextfield.textField.text = num
            accountTextfield.textField.sendActions(for: .editingChanged)

        }
    }
    
    
    //MARK: lazy
    let tipsLabel: YYLabel = YYLabel.init()
    
    let navBar = EXAccountNavigationBar()
    
    lazy var logoImgV: UIImageView = {
        let v = UIImageView()
        v.contentMode = .scaleAspectFit
        return v
    }()
    
    lazy var welcomeLabel: EXLabel = {
        let v = EXLabel()
        v.font = .Ex.medium(28)
        v.textColor = .Ex.text1
        v.text = "login_action_login".localized()
        return v
    }()
    
    lazy var accounLabel: EXLabel = {
        let v = EXLabel()
        v.font = .Ex.medium(12)
        v.textColor = .Ex.text2
        v.text = "userinfo_text_account".localized()
        return v
    }()
    
    lazy var passwordLabel: EXLabel = {
        let v = EXLabel()
        v.font = .Ex.medium(12)
        v.textColor = .Ex.text2
        v.text = "login_text_pwd".localized()
        return v
    }()
    
    
//    lazy var accountTextfield: EXCommonTextField = {
//        let v = EXCommonTextField()
//        v.topLabel.text = "register_text_phone".localized()
//        v.setAttributedPlaceholder(text: "common_tip_inputPhoneOrMail".localized())
//        v.keyboardType = .phonePad
//        v.basicTextField.leadingView.addArrangedSubviews([nationCodeButton])
//        v.basicTextField.leadingView.addArrangedSubviews([nationCodeInditorImgV])
//        v.basicTextField.contentInset = .init(top: 11, left: 16, bottom: 11, right: 16)
//        v.basicTextField.highlightColor = .Ex.main1
//        return v
//    }()
    
    
    lazy var accountTextfield: EXBasicTextField = {
        let v = EXBasicTextField()
        v.textField.setModifyClearButton()
        v.textAlignment = .left
        v.extSetCornerRadius(4)
        v.highlightColor = .Ex.main1
        v.contentInset = .init(top: 11, left: 16, bottom: 11, right: 16)
        v.textField.setPlaceHolderAtt("common_tip_inputPhoneOrMail".localized())
        v.leadingView.addArrangedSubviews([nationCodeButton])
        v.leadingView.addArrangedSubviews([nationCodeInditorImgV])
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
        return v
    }()
    
    lazy var nationCodeInditorImgV: UIButton = {
        let v = UIButton(type: .custom)
        v.setImage(EXKitBundle.image(named: "public_arrow_down"), for: .normal)
        return v
    }()
    
    
    lazy var passwordTextfield: EXSecureTextField = {
        let v = EXSecureTextField()
        v.highlightColor = .Ex.main1
        v.trailingView.snp.makeConstraints { make in
            make.width.equalTo(20)
        }
        v.setAttributedPlaceholder(text: "register_tip_inputPassword".localized())
        return v
    }()
    
    lazy var loginButton: EXButton = {
        let v = EXButton(type: .custom)
        v.setTitle("login_action_login".localized(), for: .normal)
        v.setTitleColor(.Ex.text4, for: .normal)
        v.setTitleColor(.Ex.text2, for: .disabled)
        v.setFont(UIFont.Ex.Harmony(size: 14, weight: .medium))
        return v
    }()
    
    lazy var forgetPwdButton: EXButton = {
        let v = EXButton(type: .custom)
        v.selectStyle = .blueTextColor
        v.setFont(.Ex.medium(12))
        v.enlargeInteractionEdge(with: 4)
        v.setTitle("login_action_fogotPassword".localized(), for: .normal)
        return v
    }()
}

extension EXAccountSignInVc{
    func configSubView(){
        self.view.addSubViews([logoImgV,welcomeLabel,accounLabel, accountTextfield,
                          passwordLabel, passwordTextfield, loginButton,
                         forgetPwdButton, tipsLabel])
        logoImgV.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.left.equalToSuperview().offset(16)
            make.height.equalTo(30)
            make.width.equalTo(180)
        }
        welcomeLabel.snp.makeConstraints { make in
            make.left.centerY.equalTo(logoImgV)
        }
        accounLabel.snp.makeConstraints { make in
            make.top.equalTo(logoImgV.snp.bottom).offset(32)
            make.left.equalTo(logoImgV)
            make.right.lessThanOrEqualToSuperview().offset(-16)
            make.height.equalTo(14)
        }
        accountTextfield.snp.makeConstraints { make in
            make.top.equalTo(accounLabel.snp.bottom).offset(8)
            make.left.equalTo(accounLabel)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(44)
        }
        ///
        passwordLabel.snp.makeConstraints { make in
            make.top.equalTo(accountTextfield.snp.bottom).offset(28)
            make.left.equalTo(accountTextfield)
            make.right.lessThanOrEqualToSuperview().offset(-16)
            make.height.equalTo(14)
        }
        passwordTextfield.snp.makeConstraints { make in
            make.top.equalTo(passwordLabel.snp.bottom).offset(8)
            make.centerX.width.height.equalTo(accountTextfield)
        }
        ///
        loginButton.snp.makeConstraints { make in
            make.top.equalTo(passwordTextfield.snp.bottom).offset(28)
            make.centerX.width.equalTo(passwordTextfield)
            make.height.equalTo(44)
        }
        ///
        forgetPwdButton.snp.makeConstraints { make in
            make.top.equalTo(loginButton.snp.bottom).offset(28)
            make.left.equalTo(loginButton)
            make.height.equalTo(14)
            make.right.lessThanOrEqualToSuperview().offset(-16)
        }
        tipsLabel.snp.makeConstraints { make in
            make.top.equalTo(forgetPwdButton.snp.bottom).offset(26)
            make.left.equalTo(forgetPwdButton)
            make.right.lessThanOrEqualToSuperview().offset(-16)
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(countryCodeAction))
        nationCodeButton.addGestureRecognizer(tap)
        nationCodeInditorImgV.rx.tap.subscribe(onNext: {[weak self] _ in
            guard let self = self else { return  }
            self.countryCodeAction()
        }).disposed(by: disposeBag)
        
        /// action event
        let combine = Observable.combineLatest(accountTextfield.textField.rx.text.orEmpty.asObservable(), passwordTextfield.textField.rx.text.orEmpty.asObservable())
     
        forgetPwdButton.rx.tap.subscribe(onNext: {[weak self] in
            guard let self = self else { return }
            self.onFogotPasswordAction()
        }).disposed(by: disposeBag)
        
        
        _ = combine.map { [weak self] tuple -> Bool in
            guard let self = `self` else { return false}
            let (account, password) = tuple
            if account.count > 3 && account.isNumber() == true{
                self.resetView(type: .phone)
            }else {
                self.resetView(type: .mail)
            }
            return account.count > 0 && password.count > 0
        }.subscribe(onNext: { [weak self] isEnabled in
            guard let self = `self` else { return }
            self.loginButton.isEnabled = isEnabled
        })
        
        loginButton.rx.tap.withLatestFrom(combine).subscribe(onNext: { [weak self] tuple in
            guard let self = `self` else { return }
            let (account, password) = tuple
            EXCaptchaMananger.shared.showCaptcha(inVc: self) { success in
                if success {
                    self.requestLoginOne(account: account, password: password)
                }
            }

        }).disposed(by: self.disposeBag)
        
        EXAppConfigManager.sharedInstance.onPbV5Publish
            .subscribe(onNext: {[weak self] (success) in
                guard let mySelf = self else {return}
                if success {
                    if EXThemeManager.isNight() == true{
                        if let url = URL.init(string: EXAppConfigManager.sharedInstance.getAppLogo().logo_black){
                            mySelf.logoImgV.yy_setImage(with: url, options: YYWebImageOptions.allowBackgroundTask)
                            mySelf.welcomeLabel.isHidden = true
                        }
                    }else{
                        if let url = URL.init(string: EXAppConfigManager.sharedInstance.getAppLogo().logo_white){
                            mySelf.logoImgV.yy_setImage(with: url, options: YYWebImageOptions.allowBackgroundTask)
                            mySelf.welcomeLabel.isHidden = true
                        }
                    }
                }
            }).disposed(by: disposeBag)
    }
}
extension EXAccountSignInVc{
    func resetView(type:EXAccountSignUpType){
        if type == loginType {
            return
        }
        
        if type == .phone {
            self.accountTextfield.leadingView.isHidden = false
        }else{
            self.accountTextfield.leadingView.isHidden = true
        }
        loginType = type
    }
    @objc func countryCodeAction() {
        let vc = RegionVC()
        vc.clickRegionCellBlock = {[weak self] entity in
            guard let self = `self` else { return }
            self.configContryInfo(entity: entity)
        }
        EXAlert.showVc(controller: vc,ratio: 0.9)
    }
    
    
    func onFogotPasswordAction() {
        let passwordVc = EXAccountNewPasswordVc()
        let context = EXAccountContext.init(type: .reset)
        context.account = accountTextfield.text ?? ""
        passwordVc.passwordIntent = EXAccountPasswordIntent.forgot
        passwordVc.accountContext = context
        navigationController?.pushViewController(passwordVc, animated: true)
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
}

//MARK: request
extension EXAccountSignInVc{
    func requestLoginOne(account: String, password: String) {
        let verificationType = EXCaptchaMananger.shared.captchaType()
        let context = EXAccountContext.init(type: .login)
        context.account = account
        context.password = password
        context.countryCode = self.countryCode ?? ""
        var countryCode:String? = self.countryCode
        if loginType == .mail{
            countryCode = nil
        }
        appApi
            .rx
            .request(.loginOne(countryCode: countryCode, mobileNumber: account, loginPword: password))
            .MJObjectMap(EXLoginEntity.self)
            .autoShowLoadingOnController(context: self)
            .subscribe(onSuccess: {[weak self] (entity) in
                guard let `self` = self else { return }
                self.didLoginOneRequestSucceeded(entity, context: context)
            }) {[weak self] (error) in
                if (error as NSError).code == 10019 {
                    
                    self?.passwordTextfield.textField.becomeFirstResponder()
                    self?.passwordTextfield.showBorderLayerError()
                }
                else if (error as NSError).code == 10011 {
                    self?.accountTextfield.textField.becomeFirstResponder()
                    self?.accountTextfield.showBorderLayerError()
                }
        }.disposed(by: disposeBag)
    }
        
    func didLoginOneRequestSucceeded(_ loginModel: EXLoginEntity, context: EXAccountContext){
        
        context.token = loginModel.token
        
        let codeInputVc = UIViewController.createControllerFromStoryBoard(name: .accout, type: EXCodeInputVc.self)
        if loginModel.googleAuth == "1" {
            codeInputVc.inputType = .gooleCode
        }else{
            if let text = accountTextfield.textField.text {
                if text.isEmail() {
                    codeInputVc.inputType = .emailCode
                    context.signType = .mail
                }
                else {
                    context.signType = .phone
                    codeInputVc.inputType = .phoneCode
                    context.countryCode = self.countryCode ?? ""
                }
            }
        }
        
        codeInputVc.accountContext = context
        navigationController?.pushViewController(codeInputVc, animated: true)
    }
}

extension EXAccountSignInVc: JXSegmentedListContainerViewListDelegate {
    func listView() -> UIView {
        return self.view
    }
}

