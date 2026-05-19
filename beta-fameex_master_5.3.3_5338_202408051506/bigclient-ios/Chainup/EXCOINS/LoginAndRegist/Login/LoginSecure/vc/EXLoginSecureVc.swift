//
//  EXLoginSecureVc.swift
//  Chainup
//
//  Created by liuxuan on 2020/5/9.
//  Copyright © 2020 zewu wang. All rights reserved.
//

import UIKit
import RxSwift
import EXKit
enum EXLoginSecureType:String {
    case google = "1"
    case phone = "2"
    case mail = "3"
    case idCard = "4"
}

class EXLoginSecureVc: UIViewController,NavigationPlugin {
    var types:[EXLoginSecureType] = []
    
    var token:String?
    var account:String?
    var loginPwd:String? 
    
    var smsCode:String?
    var mailCode:String?
    var googleCode:String?
    var idcardCode:String?
    var inVerification = false

    internal lazy var navigation : EXNavigation = {
        let nav =  EXNavigation.init(affectScroll: nil, presenter: self)
        nav.backView.backgroundColor = UIColor.clear
        return nav
    }()
    
    //login Title
    lazy var loginTitleLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.font = UIFont.ThemeFont.H1Bold
        label.text = "login_action_fogetpwdSafety".localized()
        label.textColor = UIColor.ThemeLabel.colorLite
        return label
    }()
    
    //容器
    lazy var container:UIStackView = {
        let container = UIStackView()
        container.axis = .vertical
        return container
    }()
    
    //身份证输入框
    lazy var idCardText : EXTextField = {
        let text = EXTextField()
        text.extUseAutoLayout()
        text.layoutIfNeeded()
        text.textfieldValueChangeBlock = {[weak self](str) in
            self?.idcardCode = str
        }
        text.input.font = UIFont().themeHNMediumFont(size: 16)
        text.setPlaceHolder(placeHolder: LanguageTools.getString(key: "personal_tip_inputIdnumber"),font : 16)
        return text
    }()
        
    
    //验证码
    lazy var smsText : EXCountField = {
        let text = EXCountField()
        text.extUseAutoLayout()
        text.layoutIfNeeded()
        text.input.keyboardType = UIKeyboardType.numberPad
        text.textfieldValueChangeBlock = {[weak self](str) in
            self?.smsCode = str
        }
        text.input.font = UIFont().themeHNMediumFont(size: 16)
        text.setPlaceHolder(placeHolder: LanguageTools.getString(key: "personal_tip_inputPhoneCode"),font : 16)
        return text
    }()
    
    //验证码
    lazy var mailText : EXCountField = {
        let text = EXCountField()
        text.extUseAutoLayout()
        text.layoutIfNeeded()
        text.input.keyboardType = UIKeyboardType.numberPad
        text.textfieldValueChangeBlock = {[weak self](str) in
            self?.mailCode = str
        }
        text.input.font = UIFont().themeHNMediumFont(size: 16)
        text.setPlaceHolder(placeHolder: LanguageTools.getString(key: "personal_tip_inputMailCode"),font : 16)
        return text
    }()
    
    //google验证
    lazy var googleText : EXPasteField = {
        let text = EXPasteField()
        text.extUseAutoLayout()
        text.layoutIfNeeded()
        text.input.keyboardType = UIKeyboardType.numberPad
        text.textfieldValueChangeBlock = {[weak self](str) in
            self?.googleCode = str
        }
        text.input.font = UIFont().themeHNMediumFont(size: 16)
        text.setPlaceHolder(placeHolder: LanguageTools.getString(key: "common_tip_googleAuth"),font : 16)
        return text
    }()
    
    lazy var sumbitBtn : EXButton = {
        let btn = EXButton()
        btn.extUseAutoLayout()
        btn.addTarget(self, action:#selector(clickConfimBtn), for: .touchUpInside)
        btn.isEnabled = false
        btn.setTitleColor(UIColor.ThemeLabel.white, for: UIControl.State.normal)
        btn.setTitle("common_text_btnConfirm".localized(), for: UIControl.State.normal)
        btn.titleLabel?.font = UIFont.ThemeFont.HeadRegular
        return btn
    }()
    
    func handNavigationBar() {
       self.navigation.setdefaultType(type: .normal)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.ThemeView.bg
        handNavigationBar()
        self.view.addSubview(loginTitleLabel)
        self.view.addSubview(container)
        self.view.addSubview(sumbitBtn)
        
        container.backgroundColor = UIColor.ThemeView.bg
        
        loginTitleLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(NAV_SCREEN_HEIGHT + 44)
            make.left.equalToSuperview().offset(30)
            make.height.equalTo(28)
            make.right.equalToSuperview().offset(-30)
        }
        
        container.snp.makeConstraints { (make) in
            make.top.equalTo(loginTitleLabel.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(30)
            make.right.equalToSuperview().offset(-30)
        }
        
        sumbitBtn.snp.makeConstraints { (make) in
            make.top.equalTo(container.snp.bottom).offset(50)
            make.left.equalTo(30)
            make.right.equalTo(-30)
            make.height.equalTo(44)
        }
        createInputViews()
    }
    
    func createInputViews(){
        
        var inputsAry:[Observable<String>] = []

        for type in types  {
            if type == .phone {
                let bgView = UIView()
                bgView.backgroundColor = UIColor.ThemeView.bg
                bgView.addSubview(smsText)
                smsText.snp.makeConstraints { (make) in
                    make.left.right.bottom.equalToSuperview()
                }
                container.addArrangedSubview(bgView)
                smsText.resendCallback = {[weak self](_) in
                    self?.getVerificationCode(.phone)
                }
                bgView.snp.makeConstraints { (make) in
                    make.height.equalTo(74)
                }
                let smsInput = smsText.input.rx.text.orEmpty.asObservable()
                inputsAry.append(smsInput)
            }else if type == .mail {
                let bgView = UIView()
                bgView.backgroundColor = UIColor.ThemeView.bg
                bgView.addSubview(mailText)
                mailText.snp.makeConstraints { (make) in
                    make.left.right.bottom.equalToSuperview()
                }
                container.addArrangedSubview(bgView)
                mailText.resendCallback = {[weak self](_) in
                    self?.getVerificationCode(.mail)
                }
                bgView.snp.makeConstraints { (make) in
                    make.height.equalTo(74)
                }
                let mailInput = mailText.input.rx.text.orEmpty.asObservable()
                inputsAry.append(mailInput)
            }else if type == .google {
                let bgView = UIView()
                bgView.backgroundColor = UIColor.ThemeView.bg
                bgView.addSubview(googleText)
                googleText.snp.makeConstraints { (make) in
                    make.left.right.bottom.equalToSuperview()
                }
                container.addArrangedSubview(bgView)
                bgView.snp.makeConstraints { (make) in
                    make.height.equalTo(74)
                }
                let googleInput = googleText.input.rx.text.orEmpty.asObservable()
                inputsAry.append(googleInput)
            }else if type == .idCard {
                let bgView = UIView()
                bgView.backgroundColor = UIColor.ThemeView.bg
                bgView.addSubview(idCardText)
                idCardText.snp.makeConstraints { (make) in
                    make.left.right.bottom.equalToSuperview()
                }
                container.addArrangedSubview(bgView)
                bgView.snp.makeConstraints { (make) in
                    make.height.equalTo(74)
                }
                let idInput = idCardText.input.rx.text.orEmpty.asObservable()
                inputsAry.append(idInput)
            }
        }
        
        Observable.combineLatest(inputsAry)
        .distinctUntilChanged()
        .map({ strary in
            var count = 0
            for str in strary {
                if str.count > 0 {
                    count += 1
                }
            }
            return (count == inputsAry.count)
        })
        .bind(to:sumbitBtn.rx.isEnabled)
        .disposed(by: self.disposeBag)
    }
    
    func getVerificationCode(_ type:EXLoginTwoType) {
        if type == .phone{//手机验证码
            appApi.rx.request(.getsmsValidCode(token: self.token ?? "",
                                               operationType: EXSendVerificationCode.moblielogin ,
                                               countryCode: "",
                                               mobile: ""))
                .MJObjectMap(EXVoidModel.self)
                .subscribe(onSuccess: { (response) in
                    
               }) { (error) in
                   
               }.disposed(by: disposeBag)
           }else if type == .mail {//邮箱验证码
            appApi.rx.request(.getemailVallidCode(email:self.account ?? "",
                                                     operationType: EXSendVerificationCode.emaillogin,
                                                     token :self.token ?? ""))
                .MJObjectMap(EXVoidModel.self)
                .subscribe(onSuccess: { (reponse) in
                    
                }) { (error) in
               }.disposed(by: disposeBag)
           }
           
       }
    
}


extension EXLoginSecureVc {
    
     @objc func clickConfimBtn(){
        if inVerification {
            return
        }
        inVerification = true
        
        sumbitBtn.showLoading()

        appApi.rx.request(.loginTwo(token: self.token ?? "",
                                    checkType: "",
                                    authCode: "",
                                    googleCode: self.googleCode,
                                    smsCode: self.smsCode,
                                    emailCode: self.mailCode,
                                    idCardCode: self.idcardCode))
            .MJObjectMap(EXLoginSuccessEntity.self)
            .subscribe(onSuccess: {[weak self] (entity) in
                self?.loginSuccess(entity: entity)
            }) {[weak self] (error) in
                self?.loginFail()
        }.disposed(by: disposeBag)
    }
    
    func loginSuccess(entity:EXLoginSuccessEntity) {
        UserInfoEntity.sharedInstance().loginSuccess(self.token ?? "",quickToken: entity.quicktoken, account: self.account ?? "", loginPwd: self.loginPwd ?? "")
        UserInfoEntity.sharedInstance().getUserInfo ({
            self.sumbitBtn.isEnabled = true
            self.inVerification = false
            self.sumbitBtn.hideLoading()
            EXAlert.showSuccess(msg: LanguageTools.getString(key: "login_tip_loginsuccess"))
            self.showRiskView()
        }) {
            
        }
    }
    
    func showRiskView() {
        var models:[EXConfirmPayAlertModel] = []
        let model = EXConfirmPayAlertModel()
        model.title = "safety_action_changeLoginPassword".localized()
        models.append(model)
        
        if self.types.contains(.google) {
            let model2 = EXConfirmPayAlertModel()
            model2.title = "login_success_action_alert_google".localized()
            models.append(model2)
        }else {
            let model2 = EXConfirmPayAlertModel()
            model2.title = "".localized()
            models.append(model2)
        }
        
        let model3 = EXConfirmPayAlertModel()
         model3.title = "".localized()
         models.append(model3)
         
        let payConfirmAlert = EXConfirmPayAlert()
        payConfirmAlert.messageLabel.textColor = UIColor.ThemeState.warning
        payConfirmAlert.configAlert(title: "login_success_action_alert_title".localized(),
                                    message:"login_success_action_alert_message".localized(),
                                    confirmPayInfo: models,
                                    passiveBtnTitle:"common_text_btnCancel".localized(),
                                    positiveBtnTitle:"common_text_btnSetting".localized())
        payConfirmAlert.alertCallback = { [weak self] idx in
            guard let `self` = self else { return }
            if idx == 0 {
                self.navigationController?.dismiss(animated: true, completion:{
                    if let topVc = AppService.topViewController() {
                        if !(topVc .isMember(of: EXMEVC.self)) {
                            let vc = EXMEVC()
                            if let nav = BusinessTools.getRootNavBar(){
                                nav.pushViewController(vc, animated: true)
                            }
                        }
                    }
             
                })
            }else {
                self.navigationController?.dismiss(animated: true, completion: nil)
            }
        }
        EXAlert.showAlert(alertView: payConfirmAlert)
    }
    
    func loginFail() {
        self.inVerification = false
        self.sumbitBtn.isEnabled = true
        self.sumbitBtn.hideLoading()
    }
}
