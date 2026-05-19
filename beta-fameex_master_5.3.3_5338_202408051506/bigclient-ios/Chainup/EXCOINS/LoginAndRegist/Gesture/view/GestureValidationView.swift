//
//  GestureValidationView.swift
//  Chainup
//
//  Created by zewu wang on 2023/8/14.
//  Copyright © 2023年 zewu wang. All rights reserved.
//

import UIKit
import EXKit

class GestureValidationView: UIView {
    
    var width_left = 60
    
    var type = GestureValidationType.EnterAgain
    
    var vm : GestureValidationVM?

    var passwordErrorNum = "0"
    
    lazy var headImgV : UIImageView = {
        let view = UIImageView()
        view.extUseAutoLayout()
        view.image = UIImage.themeImageNamed(imageName: "headportrait1")
        return view
    }()
    
    lazy var accountLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.h2Medium()
        label.textColor = UIColor.ThemeLabel.colorLite
        label.textAlignment = .center
        if let t = XUserDefault.mobileNumberValue {
            label.text = t
            if let tt = label.text , tt.count > 2{
                var ttt = tt
                if ttt.contains("@") == true{
                    let endIndex = ttt.positionOf(sub: "@",backwards: true )
                    let range = ttt.index(ttt.startIndex, offsetBy: 1)..<ttt.index(ttt.startIndex, offsetBy: endIndex)
                    ttt.replaceSubrange(range, with: "****")
                }else{
                    ttt.coverStringWithString("*", startIndex: 2, endindex: ttt.count - 2)
                }
                label.text = ttt
            }
        }
        return label
    }()
    
    //prompt
    lazy var promptLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.text = LanguageTools.getString(key: "safety_text_gesturePassword")
        label.textColor = UIColor.ThemeLabel.colorLite
        label.font = UIFont.ThemeFont.H1Bold
        label.textAlignment = .center
        return label
    }()
    
    //Subtitle
    lazy var promptDetailLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.text = LanguageTools.getString(key: "safety_action_setGesturePassword")
        label.textColor = UIColor.ThemeLabel.colorMedium
        label.bodyRegular()
        label.textAlignment = .center
        return label
    }()
    
    //Account login
    lazy var loginBtn : UIButton = {
        let btn = UIButton()
        btn.extUseAutoLayout()
        btn.setTitleColor(UIColor.ThemeBtn.highlight, for: .normal)
//        btn.extSetTitle(LanguageTools.getString(key: "go_login"), 14, UIColor.ThemeView.bg, .normal)
        btn.extSetAddTarget(self, #selector(clickLoginBtn))
        return btn
    }()
    
    //Gesture password
    lazy var gHGPasswordView : GHGPasswordView = {
        let view = GHGPasswordView()
        view.extUseAutoLayout()
        view.backgroundColor = UIColor.ThemeView.bg
        view.gpviewDelegate = self
        return view
    }()
    
    lazy var actionButton: UIButton = {
        let button = UIButton.init(type: .custom)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.setTitle("safety_action_faceIdNextTime".localized(), for: .normal)
        button.setTitleColor(UIColor.ThemeBtn.highlight, for: .normal)
        button.extSetAddTarget(self, #selector(clickLoginBtn))
        return button
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        if let num = XUserDefault.getVauleForKey(key: "passwordErrorNum") as? String{
            passwordErrorNum =  num

        }else{
            passwordErrorNum = "0"
        }
        addSubViews([headImgV,accountLabel,promptLabel,promptDetailLabel,gHGPasswordView,loginBtn])
        
        backgroundColor = UIColor.ThemeView.bg
        addConstraints()
    }
    
    func addConstraints() {
        headImgV.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(64)
            make.height.width.equalTo(28)
            make.right.equalTo(self.accountLabel.snp.left).offset(-8)
        }
        
        accountLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(headImgV)
            make.height.equalTo(33)
            make.centerX.equalToSuperview()
//            make.width.lessThanOrEqualTo(200)
        }
        promptLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
            make.height.equalTo(28)
            make.top.equalToSuperview().offset(66)
        }
        promptDetailLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
            make.height.equalTo(16)
            make.top.equalTo(promptLabel.snp.bottom).offset(10)
        }
        gHGPasswordView.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-width_left)
            make.left.equalToSuperview().offset(width_left)
            make.top.equalTo(promptDetailLabel.snp.bottom).offset(65)
            make.height.equalTo(gHGPasswordView.snp.width)
        }
        loginBtn.snp.makeConstraints { (make) in
            make.right.left.equalToSuperview()
            make.height.equalTo(16)
//            make.top.equalTo(gHGPasswordView.snp.bottom).offset(90)
            make.bottom.equalToSuperview().offset(-(TABBAR_BOTTOM + 155))
        }
    }
    
    func setView(_ type : GestureValidationType){
        self.type = type
        let vmvc = vm?.vc
        headImgV.isHidden = type != GestureValidationType.login
        accountLabel.isHidden = headImgV.isHidden
        promptLabel.isHidden = type == GestureValidationType.login
        promptDetailLabel.isHidden = promptLabel.isHidden
        switch type {
        case .EnterAgain://Reset
            vmvc?.cancelBtn.isHidden = false
            loginBtn.isHidden = true
            promptDetailLabel.text = LanguageTools.getString(key: "safety_action_confrimGesturePassword")
            gHGPasswordView.snp.remakeConstraints { (make) in
                make.right.equalToSuperview().offset(-width_left)
                make.left.equalToSuperview().offset(width_left)
                make.top.equalTo(promptDetailLabel.snp.bottom).offset(65)
                make.height.equalTo(gHGPasswordView.snp.width)
            }
        case .input://set up
            vmvc?.cancelBtn.isHidden = false
            loginBtn.isHidden = true
            promptDetailLabel.text = LanguageTools.getString(key: "safety_action_setGesturePassword")
            gHGPasswordView.snp.remakeConstraints { (make) in
                make.right.equalToSuperview().offset(-width_left)
                make.left.equalToSuperview().offset(width_left)
                make.top.equalTo(promptDetailLabel.snp.bottom).offset(65)
                make.height.equalTo(gHGPasswordView.snp.width)
            }
        case .login://Login
            vmvc?.cancelBtn.isHidden = false
            loginBtn.isHidden = false
            loginBtn.setTitle(LanguageTools.getString(key: "login_action_otherAccount"), for: .normal)
            gHGPasswordView.snp.remakeConstraints { (make) in
                make.right.equalToSuperview().offset(-width_left)
                make.left.equalToSuperview().offset(width_left)
                make.top.equalTo(accountLabel.snp.bottom).offset(65)
                make.height.equalTo(gHGPasswordView.snp.width)
            }
        case .loginSet://Login reminder settings
            vmvc?.cancelBtn.isHidden = true
            loginBtn.isHidden = true
            promptDetailLabel.text = LanguageTools.getString(key: "safety_action_setGesturePassword")
            loginBtn.setTitle(LanguageTools.getString(key: "safety_action_faceIdNextTime"), for: .normal)
            gHGPasswordView.snp.remakeConstraints { (make) in
                make.right.equalToSuperview().offset(-width_left)
                make.left.equalToSuperview().offset(width_left)
                make.top.equalTo(promptDetailLabel.snp.bottom).offset(65)
                make.height.equalTo(gHGPasswordView.snp.width)
            }
            addSubview(actionButton)
            actionButton.snp.makeConstraints { (maker) in
                maker.top.equalTo(gHGPasswordView.snp.bottom).offset(90)
                maker.centerX.equalToSuperview()
            }
        case .loginSetAgain://Login reminder reset
            vmvc?.cancelBtn.isHidden = true
            loginBtn.isHidden = true
            loginBtn.setTitle(LanguageTools.getString(key: "safety_action_faceIdNextTime"), for: .normal)
            promptDetailLabel.text = LanguageTools.getString(key: "safety_action_confrimGesturePassword")
            gHGPasswordView.snp.remakeConstraints { (make) in
                make.right.equalToSuperview().offset(-width_left)
                make.left.equalToSuperview().offset(width_left)
                make.top.equalTo(promptDetailLabel.snp.bottom).offset(65)
                make.height.equalTo(gHGPasswordView.snp.width)
            }
        }
    }
    
    //Click on the account to log in
    @objc func clickLoginBtn(_ btn :UIButton){
        if self.type == .login{
            if let vc = self.yy_viewController as? GestureValidationVC{
                vc.popBack()
//                UserInfoEntity.sharedInstance().clearQuickToken()
                BusinessTools.modalLoginVC("1")
            }
        }else{
            self.yy_viewController?.popBack()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}

extension GestureValidationView : GHGPViewDelegate{
    func didEndSwipeWithPassword(gpView: GHGPasswordView, password: String) -> NodeState {
        var state = NodeState.normal
        let vmvc = vm?.vc
        if vmvc?.type == GestureValidationType.input || vmvc?.type == GestureValidationType.loginSet{//First setting
            if password.count < 5{
                EXAlert.showFail(msg:LanguageTools.getString(key: "common_tip_gestureLimitPoint"))
                return NodeState.normal
            }
            EXAlert.showSuccess(msg:LanguageTools.getString(key: "safety_action_confrimGesturePassword"))
            vmvc?.code = password
//            vmvc?.setPWOne(self.type)
            vmvc?.confirmGesturesBlock?(password)
        }else if vmvc?.type == .EnterAgain ||
                 vmvc?.type == .loginSetAgain {//Reset gesture password
            
            guard vmvc?.code == password else {
                EXAlert.showFail(msg: "login_tip_gestureNotMatch".localized())
                return .warning
            }
            
            vmvc?.sendGestDatas(afterLogin: vmvc?.type == .loginSetAgain)
        }
        else if vmvc?.type == GestureValidationType.login{//Login
            let entity = UserInfoEntity.sharedInstance()
            
            let mima = "jys20170921" + entity.uid + password
            
            let jiami = AppService.md5(mima)
            
            if password == XUserDefault.getGesturesPassword() || jiami == entity.gesturePwd {
                vmvc?.gestLogin()

                XUserDefault.setValueForKey("0", key: "passwordErrorNum")
            }else{
                
                if NumberHandler.handleDouble(passwordErrorNum) >= 4{
                    EXAlert.showFail(msg:LanguageTools.getString(key: "common_tip_gestureLose"))
                    XUserDefault.setValueForKey("0", key: "passwordErrorNum")

                    entity.gesturePwd = ""
                    
                    entity.reloadTmpDict("gesturePwd", value: entity.gesturePwd)
                    
                    self.yy_viewController?.popBack()
                    BusinessTools.modalLoginVC("0")
                    
                        var params : [String : Any] = [:]
                        params["uid"] = entity.uid
                        let param = NetManager.sharedInstance.handleParamter(params)
                        let url = NetManager.sharedInstance.url(EXNetworkDoctor.sharedManager.getAppAPIHost(), model: NetDefine.clean_handPwd, action: "")

//                        let url = NetManager.sharedInstance.url(NetDefine.http_host_url, model: NetDefine.clean_handPwd, action: "")
                        NetManager.sharedInstance.sendRequest(url,parameters : param, success: { (result, response, entity) in
                            
                        }, fail: { (state, error, any) in
                            
                        })
                        
                        
                }else{
                    
                    let string = NSString.init(string: "4").subtracting(passwordErrorNum, decimals: 0)
                        
                    let left = String(format:"common_tip_gestureTime".localized(),string!)
                    
                    EXAlert.showFail(msg:left)
                    
                    passwordErrorNum = NSString.init(string: "1").adding(passwordErrorNum, decimals: 0)
                    XUserDefault.setValueForKey(passwordErrorNum, key: "passwordErrorNum")

                }
                
               
                state = NodeState.warning

            }
        }
        return state
    }
}

