//
//  EXForgetPWTwoView.swift
//  Chainup
//
//  Created by zewu wang on 2019/3/8.
//  Copyright © 2019 zewu wang. All rights reserved.
//

import UIKit
import RxSwift
import EXKit
class EXForgetPWTwoView: UIView {
    
    var account = ""
    
    var type = EXLoginTwoType.phone
    {
        didSet{
            self.setView()
        }
    }
    
    var token = ""
    {
        didSet{
            verificationText.resendCallback = {[weak self](_) in
                self?.clickVerification()
            }
            verificationText.justFire()
        }
    }
    
    typealias ClickNextBlock = (ForgetPWTwoEntity) -> ()
    var clickNextBlock : ClickNextBlock?
    
    lazy var logoLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.font = UIFont.ThemeFont.H1Bold
        label.textColor = UIColor.ThemeLabel.colorLite
        label.text = LanguageTools.getString(key: "common_text_safetyAuth")
        return label
    }()
    
    lazy var verificationText : EXCountField = {
        let text = EXCountField()
        text.extUseAutoLayout()
        text.layoutIfNeeded()
        text.input.keyboardType = UIKeyboardType.numberPad
        text.textfieldValueChangeBlock = {[weak self](str) in
            self?.showLoading(str.count >= 6)
        }
        text.input.font = UIFont().themeHNMediumFont(size: 16)
        return text
    }()

    lazy var nextBtn : EXButton = {
        let btn = EXButton()
        btn.extUseAutoLayout()
        btn.isEnabled = false
//        btn.extSetAddTarget(self, #selector(clickNextBtn))
        btn.setTitleColor(UIColor.ThemeLabel.white, for: UIControl.State.normal)
        btn.setTitle(LanguageTools.getString(key: "common_action_next"), for: UIControl.State.normal)
        return btn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubViews([logoLabel,verificationText,nextBtn])
        logoLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(30)
            make.top.equalToSuperview().offset(30)
            make.width.lessThanOrEqualTo(200)
            make.height.equalTo(28)
        }
        verificationText.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-30)
            make.left.equalToSuperview().offset(30)
            make.top.equalTo(logoLabel.snp.bottom).offset(50)
        }
        nextBtn.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-30)
            make.left.equalToSuperview().offset(30)
            make.top.equalTo(verificationText.snp.bottom).offset(50)
            make.height.equalTo(44)
        }
    }
    
    func setView(){
        
        if type == .phone{
            verificationText.setPlaceHolder(placeHolder: LanguageTools.getString(key: "personal_tip_inputPhoneCode"),font: 16)
        }else{
            verificationText.setPlaceHolder(placeHolder: LanguageTools.getString(key: "personal_tip_inputMailCode"),font: 16)
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension EXForgetPWTwoView{
    
    //点击发送验证码
    func clickVerification(){
        if self.type == .phone{//手机验证码
            appApi.rx.request(.getsmsValidCode(token: self.token, operationType: EXSendVerificationCode.moblieforget , countryCode: "", mobile: "")).MJObjectMap(EXVoidModel.self).subscribe(onSuccess: { (response) in
            }) { (error) in
                
                }.disposed(by: disposeBag)
        }else{//邮箱验证码
            appApi.rx.request(.getemailVallidCode(email: self.account, operationType: EXSendVerificationCode.emailforget,token : self.token)).MJObjectMap(EXVoidModel.self).subscribe(onSuccess: { (reponse) in
            }) { (error) in
                
                }.disposed(by: disposeBag)
        }
    }
    
    //
    func showLoading(_ b : Bool){
        if b == true{
            nextBtn.isEnabled = true
            nextBtn.showLoading()
            clickNextBtn()
        }else{
            nextBtn.isEnabled = false
            nextBtn.animationStopped()
        }
    }
    
    //点击下一步
    @objc func clickNextBtn(){
        var smsCode = ""
        var emailCode = ""
        verificationText.input.resignFirstResponder()
        verificationText.isUserInteractionEnabled = false
        if type == .phone{
            smsCode = verificationText.input.text ?? ""
        }else{
            emailCode = verificationText.input.text ?? ""
        }
//        appApi.rx.request(.forgetPwTwo(token: self.token, smsCode: smsCode, emailCode: emailCode)).subscribe(onSuccess: {[weak self] (response) in
//            self?.yy_viewController?.navigationController?.popViewController(animated: false)
//            self?.clickNextBlock?()
//        }) {[weak self] (error) in
//            self?.verificationText.isUserInteractionEnabled = true
//            }.disposed(by: disposeBag)
        appApi.rx.request(.forgetPwTwo(token: self.token, numberCode: verificationText.input.text ?? "")).MJObjectMap(ForgetPWTwoEntity.self).subscribe(onSuccess: {[weak self] (entity) in
            self?.yy_viewController?.navigationController?.popViewController(animated: false)
            self?.clickNextBlock?(entity)
        }) {[weak self] (error) in
            self?.verificationText.isUserInteractionEnabled = true
        }.disposed(by: disposeBag)
    }
    
}
