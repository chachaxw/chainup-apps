//
//  LoginTwoView.swift
//  Chainup
//
//  Created by zewu wang on 2019/3/7.
//  Copyright © 2019 zewu wang. All rights reserved.
//

import UIKit
import RxSwift
import EXKit

class LoginTwoView: UIView {
    
    var token = ""
    
    var type = EXLoginTwoType.google
    {
        didSet{
            setView(type)
        }
    }
    
    var account = ""//账号
    
    var loginPwd = ""//密码
    
    var inVerification = false

    lazy var loginLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.font = UIFont.ThemeFont.H1Bold
        label.textColor = UIColor.ThemeLabel.colorLite
        label.text = LanguageTools.getString(key: "otc_phone_cert")
        return label
    }()
    
    lazy var loginDetailLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.bodyRegular()
        label.textColor = UIColor.ThemeLabel.colorMedium
        label.text = LanguageTools.getString(key: "login_tip_didSendCode")
        return label
    }()
    
    //验证码
    lazy var validationText : EXCountField = {
        let text = EXCountField()
        text.extUseAutoLayout()
        text.layoutIfNeeded()
        text.input.keyboardType = UIKeyboardType.numberPad
        text.textfieldValueChangeBlock = {[weak self](str) in
            self?.sumbitType(str.count == 6)
        }
        text.input.font = UIFont().themeHNMediumFont(size: 16)
        text.setPlaceHolder(placeHolder: LanguageTools.getString(key: "login_tip_inputCode"),font : 16)
        return text
    }()
    
    //google验证
    lazy var googleText : EXPasteField = {
        let text = EXPasteField()
        text.extUseAutoLayout()
        text.layoutIfNeeded()
        text.input.keyboardType = UIKeyboardType.numberPad
        text.textfieldValueChangeBlock = {[weak self](str) in
            self?.sumbitType(str.count >= 6)
        }
        text.input.font = UIFont().themeHNMediumFont(size: 16)
        text.setPlaceHolder(placeHolder: LanguageTools.getString(key: "common_tip_googleAuth"),font : 16)
        return text
    }()
    
    lazy var sumbitBtn : EXButton = {
        let btn = EXButton()
        btn.extUseAutoLayout()
        btn.isEnabled = false
        btn.setTitleColor(UIColor.ThemeLabel.white, for: UIControl.State.normal)
        btn.setTitle("common_text_btnConfirm".localized(), for: UIControl.State.normal)
        btn.titleLabel?.font = UIFont.ThemeFont.HeadRegular
//        btn.extSetAddTarget(self, #selector(clickConfimBtn))
        return btn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubViews([loginLabel,loginDetailLabel,validationText,sumbitBtn,googleText])
        loginLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(44)
            make.left.equalToSuperview().offset(30)
            make.height.equalTo(28)
            make.right.equalToSuperview().offset(-30)
        }
        loginDetailLabel.snp.makeConstraints { (make) in
            make.top.equalTo(loginLabel.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(30)
            make.height.equalTo(20)
            make.right.equalToSuperview().offset(-10)
        }
        validationText.snp.makeConstraints { (make) in
            make.top.equalTo(loginDetailLabel.snp.bottom).offset(36)
            make.left.equalToSuperview().offset(30)
            make.right.equalToSuperview().offset(-30)
        }
        googleText.snp.makeConstraints { (make) in
            make.edges.equalTo(validationText)
        }
        sumbitBtn.snp.makeConstraints { (make) in
            make.height.equalTo(44)
            make.left.equalToSuperview().offset(30)
            make.right.equalToSuperview().offset(-30)
            make.top.equalTo(validationText.snp.bottom).offset(50)
        }
    }
    
    func setView(_ type : EXLoginTwoType){
        googleText.isHidden = type != .google
        validationText.isHidden = !googleText.isHidden
        switch type {
        case .phone:
            validationText.resendCallback = {[weak self](_) in
                self?.getVerificationCode()
            }
            validationText.justFire()
            loginLabel.text = LanguageTools.getString(key: "safety_text_phoneAuth")
        case .mail:
            validationText.resendCallback = {[weak self](_) in
                self?.getVerificationCode()
            }
            validationText.justFire()
            loginLabel.text = LanguageTools.getString(key: "safety_text_mailAuth")
        case .google:
            loginLabel.text = LanguageTools.getString(key: "safety_text_googleAuth")
            loginDetailLabel.isHidden = true
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension LoginTwoView{
    
    @objc func sumbitType(_ b : Bool){
        sumbitBtn.isEnabled = b
        if b == true{
            clickConfimBtn()
            inVerification = true
        }else{
            sumbitBtn.hideLoading()
        }
    }
    
    @objc func getVerificationCode(){
        
        if self.type == .phone{//手机验证码
            appApi.rx.request(.getsmsValidCode(token: self.token, operationType: EXSendVerificationCode.moblielogin , countryCode: "", mobile: "")).MJObjectMap(EXVoidModel.self).subscribe(onSuccess: { (response) in
            }) { (error) in
                
            }.disposed(by: disposeBag)
        }else{//邮箱验证码
            appApi.rx.request(.getemailVallidCode(email: self.account, operationType: EXSendVerificationCode.emaillogin,token : self.token)).MJObjectMap(EXVoidModel.self).subscribe(onSuccess: { (reponse) in
            }) { (error) in
                
            }.disposed(by: disposeBag)
        }
        
    }
    
    //点击下一步
    @objc func clickConfimBtn(){
        if inVerification {
            return
        }
        
        sumbitBtn.showLoading()
        var checkType = "1"
        var authCode = ""
        switch self.type {
        case .google:
            checkType = "1"
            authCode = googleText.input.text ?? ""
        case .phone:
            checkType = "2"
            authCode = validationText.input.text ?? ""
        case .mail:
            checkType = "3"
            authCode = validationText.input.text ?? ""
        }

        appApi.rx.request(.loginTwo(token: self.token, checkType: checkType, authCode: authCode, googleCode: nil, smsCode: nil, emailCode: nil, idCardCode: nil))
            .MJObjectMap(EXLoginSuccessEntity.self)
            .subscribe(onSuccess: {[weak self] (entity) in
                UserInfoEntity.sharedInstance().loginSuccess(self?.token ?? "",quickToken: entity.quicktoken, account: self?.account ?? "", loginPwd: self?.loginPwd ?? "")
            UserInfoEntity.sharedInstance().getUserInfo ({
                EXAlert.showSuccess(msg: LanguageTools.getString(key: "login_tip_loginsuccess"))
                if let str = XUserDefault.getFaceIdOrTouchIdPassword(),str == "" &&
                    UserInfoEntity.sharedInstance().gesturePwd.ch_length < 3{
                    self?.yy_viewController?.navigationController?.dismiss(animated: true, completion: {
                        let vc = GesstureAlertVC()
                        if let nav = BusinessTools.getRootNavBar(){
                            nav.pushViewController(vc, animated: true)
                        }
                        self?.presentGameAuthor()
                    })
                }else{
                    self?.yy_viewController?.navigationController?.dismiss(animated: true, completion: nil)
                    self?.presentGameAuthor()
                }
            }) {
                
                }
        }) {[weak self] (error) in
            self?.inVerification = false
            self?.sumbitBtn.isEnabled = false
            self?.sumbitBtn.hideLoading()
        }.disposed(by: disposeBag)
    }
    
    //未登录，再登录以后弹出游戏授权页面
    func presentGameAuthor() {
        EXGameJumpManager.shareInstance.presentAuthorVc()
       
    }
    
    
}
