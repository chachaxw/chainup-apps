//
//  EXAccountSignUpVc.swift
//  Chainup
//
//  Created by wangdong on 2023/9/17.
//  Copyright © 2023 ChainUP. All rights reserved.
//

import UIKit
import YYText
import RxSwift
import RxCocoa
import EXKit
import JXSegmentedView
import YYWebImage
enum EXAccountSignUpType: Int {
    case phone
    case mail
    case none
}

class EXAccountSignUpVc: UIViewController {

    lazy var signUpTypeSignal: BehaviorRelay<EXAccountSignUpType?> = { .init(value: .phone) }()
    var signUpType: EXAccountSignUpType? {
        get { signUpTypeSignal.value }
        set { signUpTypeSignal.accept(newValue) }
    }
     //MARK: lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        configData()
    }
    
    
   
    
    //MARK: lazy
    
    //////////////////////////////////////////////////////
    ///
    let tipsLabel: YYLabel = YYLabel.init()
    lazy var welcomeLabel: EXLabel = {
        let v = EXLabel()
        v.font = .Ex.medium(28)
        v.textColor = .Ex.text1
        v.text = "register_action_title".localized()
        return v
    }()
    
    lazy var logoImgV: UIImageView = {
        let v = UIImageView()
        v.contentMode = .scaleAspectFit
        v.isHidden = true
        return v
    }()
    
    lazy var phoneButton: EXCustomButton = {
        let v = EXCustomButton()
        v.extSetCornerRadius(2)
        v.text = "register_action_phone".localized()
        v.edgeInset = .init(top: 4, left: 8, bottom: 4, right: 8)
        v.selectedBackgroundColor = .Ex.fill3
        v.textColor = .Ex.text2
        v.selectedTextColor = .Ex.text1
        v.isSelected = true
        v.font = .Ex.medium(14)
        v.onTap = {[weak self]  in
            EXLogger.debug(message: "phone button tapped")
            guard let self = self else { return }
            self.signUpType = EXAccountSignUpType.phone
        }
        return v
    }()
    
    lazy var emailButton: EXCustomButton = {
        let v = EXCustomButton()
        v.extSetCornerRadius(2)
        v.text = "register_action_mail".localized()
        v.edgeInset = .init(top: 4, left: 8, bottom: 4, right: 8)
        v.selectedBackgroundColor = .Ex.fill3
        v.textColor = .Ex.text2
        v.selectedTextColor = .Ex.text1
        v.font = .Ex.medium(14)
        v.onTap = {[weak self]  in
            EXLogger.debug(message: "email button tapped")
            guard let self = self else { return }
            self.signUpType = EXAccountSignUpType.mail
        }
        return v
    }()
    
    lazy var nationalFlagImgV: UIImageView = {
        let v = UIImageView()
        v.contentMode = .scaleAspectFit
        v.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 24, height: 24))
        }
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
    
    lazy var phoneTextField: EXCommonTextField = {
        let v = EXCommonTextField()
        v.topLabel.text = "register_text_phone".localized()
        v.setAttributedPlaceholder(text: "userinfo_tip_inputPhone".localized())
        v.keyboardType = .phonePad
        v.basicTextField.leadingView.addArrangedSubviews([nationCodeButton])
        v.basicTextField.leadingView.addArrangedSubviews([nationCodeInditorImgV])
        v.basicTextField.contentInset = .init(top: 11, left: 16, bottom: 11, right: 16)
        v.basicTextField.highlightColor = .Ex.main1
        return v
    }()
    
    lazy var emailTextField: EXCommonTextField = {
        let v = EXCommonTextField()
        v.topLabel.text = "register_text_mail".localized()
        v.setAttributedPlaceholder(text: "safety_tip_inputMail".localized())
        v.keyboardType = .emailAddress
        v.basicTextField.contentInset = .init(top: 13, left: 16, bottom: 13, right: 16)
        v.basicTextField.highlightColor = .Ex.main1
        v.isHidden = true
        return v
    }()
    
    lazy var nextButton: EXButton = {
        let v = EXButton(type: .custom)
        v.setTitleColor(.Ex.text4, for: .normal)
        v.setTitleColor(.Ex.text2, for: .disabled)
        v.setTitle("common_action_next".localized(), for: .normal)
        v.isEnabled = false
        return v
    }()
}

extension EXAccountSignUpVc{
    
    func configData(){
        if let region = EXAppConfigManager.sharedInstance.getDefaultCountry() {
            if LanguageTools.isHan() == true{
                nationCodeButton.text = region.cnName + " " + region.dialingCode
            }else{
                nationCodeButton.text = region.enName + " " + region.dialingCode
            }
        }
        let phoneTextFieldSignal = phoneTextField.textField.rx.text.orEmpty.asObservable()
        let mailTextFieldSignal  = emailTextField.textField.rx.text.orEmpty.asObservable()
        
        let combine = Observable.combineLatest(phoneTextFieldSignal, mailTextFieldSignal, signUpTypeSignal)
        
        signUpTypeSignal.subscribe(onNext: {[weak self] event in
            guard let self = self else { return }
            switch event {
            case .phone:
                self.phoneButton.isSelected = true
                self.phoneTextField.isHidden = false
                self.emailButton.isSelected = false
                self.emailTextField.isHidden = true
                self.phoneTextField.basicTextField.leadingView.isHidden = false
            case .mail:
                self.emailButton.isSelected = true
                self.emailTextField.isHidden = false
                self.phoneButton.isSelected = false
                self.phoneTextField.isHidden = true
                self.phoneTextField.basicTextField.leadingView.isHidden = true
                break
            default: break
            }
        }).disposed(by: disposeBag)
        
        combine.subscribe(onNext: {[weak self] tuple in
            guard let self = self else { return }
            let (phone, email, loginTypeValue) = tuple
            var canSubmit = false
            if loginTypeValue == .phone && phone.count > 0 && phone.isPhone() {
                canSubmit = true
            }
            else if loginTypeValue == .mail && email.count > 0 && email.isEmail() {
                canSubmit = true
            }
            self.nextButton.isEnabled = canSubmit
        }).disposed(by: self.disposeBag)
        
     
        nextButton.rx.tap.withLatestFrom(combine).subscribe(onNext: { [weak self] tuple in
            guard let self = `self` else { return }
            let (phone, mail, type) = tuple
            EXCaptchaMananger.shared.showCaptcha(inVc: self) {[weak self] success in
                if success {
                    self?.request(phone: phone, mail: mail, type: type ?? .none)
                }
            }
        }).disposed(by: self.disposeBag)
        
        getStatus()
        
        
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
    
    func configUI(){
        view.addSubViews([welcomeLabel, logoImgV, phoneButton, emailButton,
                          phoneTextField, emailTextField, nextButton, tipsLabel])
        
        welcomeLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.left.equalToSuperview().offset(16)
            make.height.equalTo(32)
            make.right.lessThanOrEqualToSuperview().offset(-16)
        }
        logoImgV.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.left.equalToSuperview().offset(16)
            make.height.equalTo(32)
        }
        
        phoneButton.snp.makeConstraints { make in
            make.top.equalTo(welcomeLabel.snp.bottom).offset(28)
            make.top.equalTo(logoImgV.snp.bottom).offset(28).priority(.high)
            make.left.equalToSuperview().offset(16)
        }
        emailButton.snp.makeConstraints { make in
            make.left.equalTo(phoneButton.snp.right).offset(8)
            make.centerY.height.equalTo(phoneButton)
        }
        phoneTextField.snp.makeConstraints { make in
            make.top.equalTo(phoneButton.snp.bottom).offset(30)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
        }
        emailTextField.snp.makeConstraints { make in
            make.top.equalTo(emailButton.snp.bottom).offset(30)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
        }
        nextButton.snp.makeConstraints { make in
            make.top.equalTo(phoneTextField.snp.bottom).offset(30)
            make.top.equalTo(emailTextField.snp.bottom).offset(30).priority(.high)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(44)
        }
        tipsLabel.snp.makeConstraints { make in
            make.top.equalTo(nextButton.snp.bottom).offset(24)
            make.left.equalToSuperview().offset(16)
            make.height.equalTo(16)
            make.right.lessThanOrEqualToSuperview().offset(-16)
        }
        
        
//        phoneButton.onTap = {[weak self]  in
//            guard let self = self else { return }
//            self.signUpType = EXAccountSignUpType.phone
//        }
//        
//        emailButton.onTap = {[weak self]  in
//            guard let self = self else { return }
//            self.signUpType = EXAccountSignUpType.mail
//        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(onCountryCodeAction))
        nationCodeButton.addGestureRecognizer(tap)
        
        nationCodeInditorImgV.rx.tap.subscribe(onNext: {[weak self] _ in
            guard let self = self else { return  }
            self.onCountryCodeAction()
        }).disposed(by: disposeBag)
        
    }
}
extension EXAccountSignUpVc{
    func request(phone: String, mail: String, type: EXAccountSignUpType) {
        var country = ""
        if type == EXAccountSignUpType.phone {
            if let arr = self.nationCodeButton.text?.components(separatedBy: "+") , arr.count > 1{
                country = "+" + arr[1]
            }else{
                country = self.nationCodeButton.text ?? ""
            }
            self.registerByPhone(phone: phone, contryCode: country)
        }
        else if type == EXAccountSignUpType.mail {
            self.registerByMail(mail: mail)
        }
    }
    
    func registerByPhone(phone: String, contryCode: String) {
        if let context = make() {
            context.account = phone
            context.countryCode = contryCode
            context.signType = .phone
            registerOne(context: context)
        }
    }
    
    func registerByMail(mail: String) {
        if let context = make() {
            context.account = mail
            context.signType = .mail
            registerOne(context: context)
        }
    }
    
    func make() -> EXAccountContext? {
        let context = EXAccountContext.init(type: .regist)
        return context
    }
    
    
    @objc func onCountryCodeAction() {
       let vc = RegionVC()
       vc.clickRegionCellBlock = {[weak self] entity in
           guard let self = `self` else { return }
           if LanguageTools.isHan() == true{
               self.nationCodeButton.text = entity.cnName + entity.dialingCode
           }else{
               self.nationCodeButton.text = entity.enName + entity.dialingCode
           }
       }
       EXAlert.showVc(controller: vc,ratio: 0.9)
   }
   
    
    func getStatus(){
        var arr : [String] = ["2","1"]
        let newArr = EXAppConfigManager.sharedInstance.getSupportRegistTypes()
        if newArr.count > 0 {
            arr = newArr
        }
        if arr.count > 0{
            let style = arr[0]
            if style == "1" {
                signUpType = EXAccountSignUpType.phone
            }
            else {
                signUpType = EXAccountSignUpType.mail
            }
            
            if arr.count == 1 { //only one,hidden the other
                configRegisterType()
            }
        }
    }
    
    func configRegisterType(){
        if signUpType == .mail {
            phoneButton.isHidden = true
            emailButton.snp.remakeConstraints { make in
                make.edges.equalTo(phoneButton)
            }
        }else{
            emailButton.isHidden = true
        }
    }
    
}

//MARK: request
extension EXAccountSignUpVc{
    func registerOne(context: EXAccountContext) {
        _ = appApi
            .rx
            .request(.registerOne(email: context.mailAccount,
                                  mobile: context.phoneAccount,
                                  country: context.countryCode))
            .MJObjectMap(EXVoidModel.self)
            .autoShowLoadingOnController(context: self)
            .subscribe(onSuccess: {  [weak self] _ in
                guard let `self` = self else { return }
                self.didRequestRegisterOneSucceed(context: context)
            },onFailure: { [weak self] error in
                guard let `self` = self, let parentVc = self.parent as? EXAccountActionVc else { return }
                if (error as NSError).code == 10013 || (error as NSError).code == 10023 {
                    
                    let alert = EXCommonAlert()
                    alert.configAlert(title: "account_has_benn_registered_tip".localized()) { type in
                        if type == .sure {
                            parentVc.pageOne()
                        }
                    }
                    //show
                    EXAlert.showAlert(alertView: alert)
                }
            })
        
        
//        _ = appApi
//            .rx
//            .request(.registerOne(email: context.mailAccount,
//                                  mobile: context.phoneAccount,
//                                  country: context.countryCode))
//            .MJObjectMap(EXVoidModel.self)
//            .autoShowLoadingOnController(context: self)
//            .subscribe(onSuccess: {[weak self] (repsonse) in
//                self?.didRequestRegisterOneSucceed(context: context)
//            }) { [weak self] error in
//                guard let `self` = self, let parentVc = self.parent as? EXAccountActionVc else { return }
//                if (error as NSError).code == 10013 || (error as NSError).code == 10023 {
//                    
//                    let alert = EXCommonAlert()
//                    alert.configAlert(title: "account_has_benn_registered_tip".localized()) { type in
//                        if type == .sure {
//                            parentVc.pageOne()
//                        }
//                    }
//                    //show
//                    EXAlert.showAlert(alertView: alert)
//                }
//        }
    }
    
    func didRequestRegisterOneSucceed(context: EXAccountContext) {
        let codeInputVc = UIViewController.createControllerFromStoryBoard(name: .accout, type: EXCodeInputVc.self)
        codeInputVc.accountContext = context
        navigationController?.pushViewController(codeInputVc, animated: true)
    }
    
}
extension EXAccountSignUpVc: JXSegmentedListContainerViewListDelegate {
    func listView() -> UIView {
        return self.view
    }
}
