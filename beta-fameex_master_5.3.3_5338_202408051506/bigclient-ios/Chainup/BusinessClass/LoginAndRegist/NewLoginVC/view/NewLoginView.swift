//
//  NewLoginView.swift
//  Chainup
//
//  Created by zewu wang on 2018/11/19.
//  Copyright © 2018 zewu wang. All rights reserved.
//

import UIKit

class NewLoginView: UIView {
    
    var vm = NewLoginVM()
    
    var token = ""
    
    lazy var titleLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.extSetText(LanguageTools.getString(key: "login"), textColor: UIColor.ThemeView.bg, fontSize: 30)
        return label
    }()
    
    lazy var loginView : OneInputView = {
        let view = OneInputView()
        view.extUseAutoLayout()
        if let num = XUserDefault.getVauleForKey(key: XUserDefault.mobileNumber) as? String{
            view.textField.text = num
        }
        view.inputTextBlock = {[weak self](str) in
            guard let mySelf = self else{return}
            mySelf.setLoginBtn()
            view.setCancelBtn(str)
        }
        view.setPlaceHolderAtt(LanguageTools.getString(key: "toast_no_account"),labelStr : LanguageTools.getString(key: "mobile_or_email"))
        return view
    }()
    
    lazy var pwView : TwoInputView = {
        let view = TwoInputView()
        view.extUseAutoLayout()
        view.setPlaceHolderAtt(LanguageTools.getString(key: "toast_no_pass") , labelStr :LanguageTools.getString(key: "pwd"))
        view.inputTextBlock = {[weak self](str) in
            guard let mySelf = self else{return}
            view.setCancelBtn(str)
            mySelf.setLoginBtn()
        }
        return view
    }()
    
    lazy var gt3Tool : GT3Tool = {
        let gt3Tool = GT3Tool()
        gt3Tool.captchaButton.isHidden = true
        return gt3Tool
    }()
    
    lazy var loginBtn : UIButton = {
        let btn = UIButton()
        btn.extUseAutoLayout()
        btn.backgroundColor = UIColor.ThemeBtn.highlight
        btn.alpha = 0.6
        btn.isEnabled = false
        btn.extSetTitle(LanguageTools.getString(key: "login"), 16, UIColor.ThemeView.bg, UIControlState.normal)
        btn.extSetAddTarget(self, #selector(clickLoginBtn))
        return btn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubViews([titleLabel,loginView,pwView,gt3Tool.captchaButton,loginBtn])
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(20)
            make.height.equalTo(30)
            make.left.equalToSuperview().offset(30)
            make.right.equalToSuperview().offset(-30)
        }
        loginView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(30)
            make.right.equalToSuperview().offset(-30)
            make.top.equalTo(titleLabel.snp.bottom).offset(47)
            make.height.equalTo(70)
        }
        pwView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(30)
            make.right.equalToSuperview().offset(-30)
            make.top.equalTo(loginView.snp.bottom).offset(50)
            make.height.equalTo(70)
        }
        if PublicInfoEntity.sharedInstance.verificationType == "2"{
            gt3Tool.captchaButton.snp.makeConstraints { (make) in
                make.top.equalTo(pwView.snp.bottom).offset(30)
                make.left.equalToSuperview().offset(30)
                make.right.equalToSuperview().offset(-30)
                make.height.equalTo(45)
            }
            gt3Tool.captchaButton.isHidden = false
            loginBtn.snp.makeConstraints { (make) in
                make.left.equalToSuperview().offset(30)
                make.right.equalToSuperview().offset(-30)
                make.height.equalTo(45)
                make.top.equalTo(gt3Tool.captchaButton.snp.bottom).offset(50)
            }
            gt3Tool.start()
        }else{
            loginBtn.snp.makeConstraints { (make) in
                make.left.equalToSuperview().offset(30)
                make.right.equalToSuperview().offset(-30)
                make.height.equalTo(45)
                make.top.equalTo(pwView.snp.bottom).offset(50)
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setLoginBtn(){
        if loginView.textField.text == "" || pwView.textField.text == "" {
            loginBtn.alpha = 0.6
            loginBtn.isEnabled = false
        }else{
            loginBtn.alpha = 1
            loginBtn.isEnabled = true
        }
    }
    
    //Click on the login button
    @objc func clickLoginBtn(){
        gt3Tool.captchaButton.resetCaptcha()//Reset polar test
        
        var param = ["mobileNumber" : loginView.textField.text ?? "" , "loginPword" : pwView.textField.text ?? "","geetest_challenge":gt3Tool.geetest_challenge ?? "","geetest_seccode":gt3Tool.geetest_seccode ?? "","geetest_validate":gt3Tool.geetest_validate ?? ""]

//        showValidationV("1")
        if loginView.textField.text == ""{
            ProgressHUDManager.showFailWithStatus(LanguageTools.getString(key: "toast_no_account"))
            return
        }
        if  pwView.textField.text == ""{
            ProgressHUDManager.showFailWithStatus(LanguageTools.getString(key: "toast_no_pass"))
            return
        }

        if gt3Tool.geetest_challenge == nil && PublicInfoEntity.sharedInstance.verificationType  == "2" {
            ProgressHUDManager.showFailWithStatus(LanguageTools.getString(key: "toast_no_sliding_block"))
            return
        }
        
        if PublicInfoEntity.sharedInstance.verificationType  == "2" {
            if gt3Tool.geetest_challenge == nil{
                ProgressHUDManager.showFailWithStatus(LanguageTools.getString(key: "toast_no_sliding_block"))
                return
            }
            param["verificationType"] = "2"
        }
        
        vm.login(param).asObservable().subscribe(onNext: {[weak self] (dict) in
            guard let mySelf = self else{return}
            if let data = dict["data"] as? [String : Any]{
                var type = "0"
                if let googleAuth = data["googleAuth"] as? String{
                    type = googleAuth
                }//0 not on Google 1 on Google
                guard let token = data["token"] as? String else{return}
                mySelf.token = token//Store temporary tokens
                mySelf.showValidationV(type)
            }
        }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
    }
    
    //Display secondary validation
    func showValidationV(_ google : String){
        vm.vc?.showValidationV(google)
    }
    
    //Login Step 2
    func stepTwo(_ param : [String : Any]){
        vm.againLogin(param, token: self.token).asObservable().subscribe(onNext: {[weak self] (dict) in
            guard let mySelf = self else{return}
            XUserDefault.setLoginTime()//Login successful, save login time
            ProgressHUDManager.showSuccessWithStatus(LanguageTools.getString(key: "login_suc"))
            if let text = mySelf.loginView.textField.text{
                
                if let temp = XUserDefault.getVauleForKey(key: XUserDefault.mobileNumber) as? String{
                    
                    if text != temp{
                        XUserDefault.setFaceIdOrTouchId("")

                    }
                }
            }
            
            if let text = mySelf.loginView.textField.text{//Login successful, save login account
                XUserDefault.setValueForKey(text , key: XUserDefault.mobileNumber)
            }
            
            XUserDefault.setValueForKey(mySelf.token, key: XUserDefault.token)//The token will not be stored until the second login is successful
            UserInfoEntity.removeAllData()//Clean up previous personal information
            
            

            //Pull back personal information
            AccountVM().getPersonlInformation().subscribe(onNext: {(dict) in
                if let data = dict["data"] as? [String : Any]{
                    UserInfoEntity.sharedInstance().setEntityWithDict(data)
                    
//                    mySelf.yy_viewController?.dismiss(animated: true, completion: nil)
                    if let str = XUserDefault.getFaceIdOrTouchIdPassword(),str == "" && UserInfoEntity.sharedInstance().gesturePwd.ch_length < 3{
                        mySelf.yy_viewController?.dismiss(animated: true, completion: {
                            let vc = GesstureAlertVC()
                            if let nav = BusinessTools.getRootNavBar(){
                                nav.pushViewController(vc, animated: true)
                            }
                        })
                        
                    }else{
                        mySelf.yy_viewController?.dismiss(animated: true, completion: nil)
                    }

                    
//                    if let str = XUserDefault.getFaceIdOrTouchIdPassword(),str == "" && UserInfoEntity.sharedInstance().gesturePwd.ch_length < 3{
//
//                        NotificationCenter.default.post(name: Notification.Name("kuaijieshezhi"), object:nil)
//
//                    }

                    
                }
            }, onError: { (error) in
                 mySelf.yy_viewController?.dismiss(animated: true, completion: nil)
            }, onCompleted: nil, onDisposed: nil).disposed(by:mySelf.disposeBag)

        }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
    }
    
   
    
    
}

