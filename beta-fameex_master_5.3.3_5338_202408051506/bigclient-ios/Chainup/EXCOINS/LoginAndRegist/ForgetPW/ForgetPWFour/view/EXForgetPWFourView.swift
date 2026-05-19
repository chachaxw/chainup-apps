//
//  EXForgetPWThreeView.swift
//  Chainup
//
//  Created by zewu wang on 2019/3/8.
//  Copyright © 2019 zewu wang. All rights reserved.
//

import UIKit
import RxSwift
import EXKit

class EXForgetPWFourView: UIView {
    
    var token = ""

    lazy var logoLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.font = UIFont.ThemeFont.H1Bold
        label.textColor = UIColor.ThemeLabel.colorLite
        label.text = LanguageTools.getString(key: "login_action_resetPassword")
        return label
    }()
    
    lazy var pwText : EXTextField = {
        let text = EXTextField()
        text.extUseAutoLayout()
        text.layoutIfNeeded()
        text.enablePrivacyModel = true
        text.input.font = UIFont().themeHNMediumFont(size: 16)
        text.setPlaceHolder(placeHolder: LanguageTools.getString(key: "register_tip_inputPassword"),font: 16)
        text.textfieldValueChangeBlock = {[weak self](str) in
            self?.confimBtnType()
        }
        return text
    }()
    
    lazy var nextPWText : EXTextField = {
        let text = EXTextField()
        text.extUseAutoLayout()
        text.layoutIfNeeded()
        text.enablePrivacyModel = true
        text.input.font = UIFont().themeHNMediumFont(size: 16)
        text.setPlaceHolder(placeHolder: LanguageTools.getString(key: "register_tip_repeatPassword"),font: 16)
        text.textfieldValueChangeBlock = {[weak self](str) in
            self?.confimBtnType()
        }
        return text
    }()
    
    lazy var confimBtn : EXButton = {
        let btn = EXButton()
        btn.extUseAutoLayout()
        btn.setTitleColor(UIColor.ThemeLabel.white, for: UIControl.State.normal)
        btn.setTitle(LanguageTools.getString(key: "common_text_btnConfirm"), for: UIControl.State.normal)
        btn.isEnabled = false
        btn.extSetAddTarget(self, #selector(clickConfimBtn))
        return btn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubViews([logoLabel,pwText,nextPWText,confimBtn])
        logoLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(30)
            make.top.equalToSuperview().offset(30)
            make.width.lessThanOrEqualTo(200)
            make.height.equalTo(28)
        }
        pwText.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-30)
            make.left.equalToSuperview().offset(30)
            make.top.equalTo(logoLabel.snp.bottom).offset(36)
        }
        nextPWText.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-30)
            make.left.equalToSuperview().offset(30)
            make.top.equalTo(pwText.snp.bottom).offset(36)
        }
        confimBtn.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-30)
            make.left.equalToSuperview().offset(30)
            make.top.equalTo(nextPWText.snp.bottom).offset(50)
            make.height.equalTo(44)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension EXForgetPWFourView{
    
    func confimBtnType(){
        if let t = pwText.input.text , t.count > 0 , let n = nextPWText.input.text , n.count > 0{
            confimBtn.isEnabled = true
        }else{
            confimBtn.isEnabled = false
        }
    }
    
    //点击确认
    @objc func clickConfimBtn(){
        
        if pwText.input.text == ""{
            EXAlert.showFail(msg: LanguageTools.getString(key: "register_tip_inputPassword"))
            return
        }else if pwText.input.text!.count < 8 || pwText.input.text!.count > 20{
            
            EXAlert.showFail(msg: LanguageTools.getString(key: "login_tip_passwordRequire"))
            return
        }else if BusinessTools.numberAndCharacter(pwText.input.text!) == false{
            EXAlert.showFail(msg: LanguageTools.getString(key: "login_tip_passwordRequire"))
            return
        }else if nextPWText.input.text != pwText.input.text {
            EXAlert.showFail(msg: LanguageTools.getString(key: "login_tip_passwordNotMatch"))
            return
        }
        
        appApi.rx.request(.forgetPwFour(token: self.token, loginPword: pwText.input.text ?? "", newPassword: nextPWText.input.text ?? "")).MJObjectMap(EXVoidModel.self).subscribe(onSuccess: {[weak self] (response) in
            EXAlert.showSuccess(msg: LanguageTools.getString(key: "common_tip_editSuccess"))
            self?.yy_viewController?.navigationController?.popToRootViewController(animated: true)
        }) { (error) in
            
        }.disposed(by: disposeBag)
        
    }
    
}
