//
//  EXForgetPWThreeView.swift
//  Chainup
//
//  Created by zewu wang on 2019/4/23.
//  Copyright © 2019 zewu wang. All rights reserved.
//

import UIKit
import RxSwift
import EXKit

class EXForgetPWThreeView: UIView {
    
    var token = ""
    
    var entity = ForgetPWTwoEntity()
    {
        didSet{
            self.reloadView()
        }
    }

    lazy var logoLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.font = UIFont.ThemeFont.H1Bold
        label.textColor = UIColor.ThemeLabel.colorLite
        label.text = LanguageTools.getString(key: "common_text_safetyAuth")
        return label
    }()
    
    lazy var idText : EXTextField = {
        let text = EXTextField()
        text.extUseAutoLayout()
        text.isHidden = true
        text.layoutIfNeeded()
        text.input.font = UIFont().themeHNMediumFont(size: 16)
        text.setPlaceHolder(placeHolder: LanguageTools.getString(key: "personal_tip_inputIdnumber"),font: 16)
        text.textfieldValueChangeBlock = {[weak self]str in
            self?.reloadNextBtnType()
        }
        return text
    }()
    
    lazy var googleText : EXPasteField = {
        let text = EXPasteField()
        text.extUseAutoLayout()
        text.isHidden = true
        text.layoutIfNeeded()
        text.input.keyboardType = .numberPad
        text.input.font = UIFont().themeHNMediumFont(size: 16)
        text.setPlaceHolder(placeHolder: LanguageTools.getString(key: "common_tip_googleAuth"),font: 16)
        text.textfieldValueChangeBlock = {[weak self]str in
            self?.reloadNextBtnType()
        }
        return text
    }()
    
    lazy var nextBtn : EXButton = {
        let btn = EXButton()
        btn.extUseAutoLayout()
        btn.isEnabled = false
        btn.extSetAddTarget(self, #selector(clickNextBtn))
        btn.setTitleColor(UIColor.ThemeLabel.white, for: UIControl.State.normal)
        btn.setTitle(LanguageTools.getString(key: "common_action_next"), for: UIControl.State.normal)
        return btn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubViews([logoLabel,idText,googleText,nextBtn])
        logoLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(30)
            make.top.equalToSuperview().offset(30)
            make.width.lessThanOrEqualTo(200)
            make.height.equalTo(28)
        }
        idText.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-30)
            make.left.equalToSuperview().offset(30)
            make.top.equalTo(logoLabel.snp.bottom).offset(50)
            make.height.equalTo(32)
        }
        googleText.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-30)
            make.left.equalToSuperview().offset(30)
            make.top.equalTo(idText.snp.bottom).offset(36)
            make.height.equalTo(32)
        }
        nextBtn.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-30)
            make.left.equalToSuperview().offset(30)
            make.top.equalTo(googleText.snp.bottom).offset(50)
            make.height.equalTo(44)
        }
    }
    
    func reloadView(){
        idText.isHidden = entity.isCertificateNumber == "0"
        googleText.isHidden = entity.isGoogleAuth == "0"
        if entity.isCertificateNumber != "0" && entity.isGoogleAuth != "0"{
            
        }else if entity.isCertificateNumber != "0"{
            nextBtn.snp.remakeConstraints { (make) in
                make.right.equalToSuperview().offset(-30)
                make.left.equalToSuperview().offset(30)
                make.top.equalTo(idText.snp.bottom).offset(50)
                make.height.equalTo(44)
            }
        }else if entity.isGoogleAuth != "0"{
            googleText.snp.remakeConstraints { (make) in
                make.right.equalToSuperview().offset(-30)
                make.left.equalToSuperview().offset(30)
                make.top.equalTo(logoLabel.snp.bottom).offset(50)
                make.height.equalTo(57)
            }
        }
    }
    
    func reloadNextBtnType(){
        if entity.isCertificateNumber != "0"{
            if idText.input.text == ""{
                nextBtn.isEnabled = false
                return
            }
        }
        if entity.isGoogleAuth != "0"{
            if googleText.input.text == ""{
                nextBtn.isEnabled = false
                return
            }
        }
         nextBtn.isEnabled = true
    }
    
    //点击下一步按钮
    @objc func clickNextBtn(){
        if entity.isCertificateNumber != "0"{
            let idtext = idText.input.text
            if idtext == ""{
                EXAlert.showFail(msg: LanguageTools.getString(key: "personal_tip_inputIdnumber"))
                return
            }
        }
        if entity.isGoogleAuth != "0"{
            let googleText = self.googleText.input.text
            if googleText == ""{
                EXAlert.showFail(msg: LanguageTools.getString(key: "common_tip_googleAuth"))
                return
            }
        }
      
        appApi.rx.request(AppAPIEndPoint.forgetPwThree(token: self.token, certifcateNumber: idText.input.text ?? "", googleCode: googleText.input.text ?? "")).MJObjectMap(EXBaseModel.self).subscribe(onSuccess: {[weak self] (model) in
            guard let mySelf = self else{return}
            let vc = EXForgetPWFourVC()
            vc.mainView.token = mySelf.token
            mySelf.yy_viewController?.navigationController?.pushViewController(vc, animated: true)
        }) { (error) in
            
        }.disposed(by: disposeBag)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
