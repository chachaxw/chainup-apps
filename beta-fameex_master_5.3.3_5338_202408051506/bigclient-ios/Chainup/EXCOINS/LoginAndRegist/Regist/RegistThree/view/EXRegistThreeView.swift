//
//  EXRegistThreeView.swift
//  Chainup
//
//  Created by zewu wang on 2019/3/7.
//  Copyright © 2019 zewu wang. All rights reserved.
//

import UIKit
import YYText
import RxSwift
import EXKit

class EXRegistThreeView: UIView {
    
    var entity = EXRegistTwoEntity()
    {
        didSet{
            if entity.invitationCode_required == "0"{//非必填邀请码
                inviteCodeView.setPlaceHolder(placeHolder:"register_text_inviteCode".localized() + "regitser_tip_inputOptional".localized(),font: 16)
            }else{//必填邀请码
                inviteCodeView.setPlaceHolder(placeHolder: LanguageTools.getString(key: "common_tip_inviteCodeRequired"),font : 16)
            }
        }
    }
    
    var account = ""

    lazy var logoLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.font = UIFont.ThemeFont.H1Bold
        label.textColor = UIColor.ThemeLabel.colorLite
        label.text = LanguageTools.getString(key: "register_action_setPassword")
        return label
    }()
    
    lazy var setPWText : EXTextField = {
        let text = EXTextField()
        text.extUseAutoLayout()
        text.layoutIfNeeded()
        text.enablePrivacyModel = true
        text.textfieldValueChangeBlock = {[weak self](str) in
            self?.reloadBtnType()
        }
        text.input.font = UIFont().themeHNMediumFont(size: 16)
        text.setPlaceHolder(placeHolder: LanguageTools.getString(key: "register_tip_inputPassword"),font: 16)
        return text
    }()
    
    lazy var nextSetPWText : EXTextField = {
        let text = EXTextField()
        text.extUseAutoLayout()
        text.layoutIfNeeded()
        text.enablePrivacyModel = true
        text.textfieldValueChangeBlock = {[weak self](str) in
            self?.reloadBtnType()
        }
        text.input.font = UIFont().themeHNMediumFont(size: 16)
        text.setPlaceHolder(placeHolder: LanguageTools.getString(key: "register_tip_repeatPassword"),font: 16)
        return text
    }()
    
    lazy var serviceLabel : YYLabel = {
        let label = YYLabel()
        label.extUseAutoLayout()
        return label
    }()
    
    lazy var confimBtn : EXButton = {
        let btn = EXButton()
        btn.layoutIfNeeded()
        btn.extUseAutoLayout()
        btn.extSetAddTarget(self, #selector(clickConfimBtn))
        btn.setTitle(LanguageTools.getString(key: "register_action_register"), for: UIControl.State.normal)
        btn.setTitleColor(UIColor.ThemeLabel.white, for: UIControl.State.normal)
        btn.titleLabel?.font = UIFont.ThemeFont.HeadRegular
        btn.isEnabled = false
        return btn
    }()
    
    lazy var inviteCodeView : EXTextField = {
        let text = EXTextField()
        text.extUseAutoLayout()
        text.layoutIfNeeded()
        text.textfieldValueChangeBlock = {[weak self](str) in
            self?.reloadBtnType()
        }
        text.input.font = UIFont().themeHNMediumFont(size: 16)
        text.setPlaceHolder(placeHolder: LanguageTools.getString(key: "register_tip_inputPassword"),font : 16)
        return text
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubViews([logoLabel,setPWText,nextSetPWText,serviceLabel,confimBtn,inviteCodeView])
        logoLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(30)
            make.top.equalToSuperview().offset(44)
            make.width.lessThanOrEqualTo(200)
            make.height.equalTo(28)
        }
        setPWText.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-30)
            make.left.equalToSuperview().offset(30)
            make.top.equalTo(logoLabel.snp.bottom).offset(50)
        }
        nextSetPWText.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-30)
            make.left.equalToSuperview().offset(30)
            make.top.equalTo(setPWText.snp.bottom).offset(36)
        }
        inviteCodeView.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-30)
            make.left.equalToSuperview().offset(30)
            make.top.equalTo(nextSetPWText.snp.bottom).offset(36)
        }
        serviceLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-30)
            make.left.equalToSuperview().offset(30)
            make.top.equalTo(inviteCodeView.snp.bottom).offset(50)
            make.height.equalTo(20)
        }
        confimBtn.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-30)
            make.left.equalToSuperview().offset(30)
            make.top.equalTo(serviceLabel.snp.bottom).offset(10)
            make.height.equalTo(44)
        }
        addAttTap()
    }
    
    //添加手势
    func addAttTap(){
        let accatt = NSMutableAttributedString.init().add(string: LanguageTools.getString(key: "register_tip_agreement") + " ", attrDic: [NSAttributedString.Key.foregroundColor : UIColor.ThemeLabel.colorMedium , NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16)]).add(string:  LanguageTools.getString(key: "register_action_agreement"), attrDic: [NSAttributedString.Key.foregroundColor : UIColor.ThemeLabel.colorHighlight , NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16)])
        //服务条款
        accatt.highLightTap((accatt.string as NSString).range(of: LanguageTools.getString(key: "register_action_agreement")), {[weak self] (view, attstr, range, rect) in
            guard let mySelf = self else{return}
            let statementVC = StatementVC()
            statementVC.titleStr = LanguageTools.getString(key:"register_action_agreement")
            mySelf.yy_viewController?.navigationController?.pushViewController(statementVC, animated: true)
        })
        serviceLabel.attributedText = accatt
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension EXRegistThreeView{
    
    func reloadBtnType(){
        
        if setPWText.input.text == ""{
            return
        }
        if nextSetPWText.input.text == ""{
            return
        }
        if self.entity.invitationCode_required == "1" {//如果
            if inviteCodeView.input.text == "" {
                return
            }
        }
        confimBtn.isEnabled = true
    }
    
    //点击服务条款
    func clickServiceLabel(){
        let vc = StatementVC()
        self.yy_viewController?.navigationController?.pushViewController(vc, animated: true)
    }
    
    //点击确认按钮
    @objc func clickConfimBtn(){
        
        if setPWText.input.text == ""{
            EXAlert.showFail(msg: LanguageTools.getString(key: "register_tip_inputPassword"))
            return
        }else if setPWText.input.text!.count < 8 || setPWText.input.text!.count > 20{
            EXAlert.showFail(msg: LanguageTools.getString(key: "login_tip_passwordRequire"))
            return
        }else if BusinessTools.numberAndCharacter(setPWText.input.text!) == false{
            EXAlert.showFail(msg: LanguageTools.getString(key: "login_tip_passwordRequire"))
            return
        }else if nextSetPWText.input.text != setPWText.input.text {
            EXAlert.showFail(msg: LanguageTools.getString(key: "login_tip_authRepeatePwd"))
            return
        }
        
        if self.entity.invitationCode_required == "1" {//如果
            if inviteCodeView.input.text == "" {
                EXAlert.showFail(msg: LanguageTools.getString(key: "common_tip_inputInviteCode"))
                return
            }
        }
        
        confimBtn.showLoading()
        appApi.rx.request(.registerThree(registerCode: self.account, loginPword: setPWText.input.text ?? "", newPassword: nextSetPWText.input.text ?? "", invitedCode: inviteCodeView.input.text ?? ""))
            .MJObjectMap(EXVoidModel.self)
            .subscribe(onSuccess: {[weak self] (response) in
            EXAlert.showSuccess(msg: LanguageTools.getString(key: "common_tip_registerSuccess"))
            NotificationCenter.default.post(name: NSNotification.Name.init("EXRegistSuccess"), object: nil)
            self?.endEditing(true)
            self?.yy_viewController?.navigationController?.popToRootViewController(animated: true)
            self?.confimBtn.hideLoading()
        }) {[weak self] (error) in
            self?.confimBtn.hideLoading()
        }.disposed(by: disposeBag)
       
    }
    
}
