//
//  EXEmailBindingView.swift
//  Chainup
//
//  Created by zewu wang on 2023/4/16.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import RxSwift
import EXKit


class oldMailView: EXView {
    override func setupView(){
        let titlelabel = UILabel()
        titlelabel.ext_UseAutoLayout()
        titlelabel.textAlignment = .left
        titlelabel.textColor = UIColor.ThemeLabel.colorLite
        titlelabel.bodyRegular()
        titlelabel.text = "personal_Center_text8".localized()
        
        let detailabel = UILabel()
        detailabel.ext_UseAutoLayout()
        detailabel.textAlignment = .right
        detailabel.textColor = UIColor.ThemeLabel.colorMedium
        detailabel.font = UIFont.ThemeFont.BodyRegular
        detailabel.text = UserInfoEntity.sharedInstance().email
        self.addSubViews([titlelabel,detailabel])
        titlelabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
        }
        detailabel.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
        }
    }
}

class EXEmailBindingView: UIView {
    
    var type : [String] = []
    
    var email : String = ""
    var sheetView: EXOldActionSheetView?
    var modify :Bool {
        //modify
        return UserInfoEntity.sharedInstance().email != ""
    }
    lazy var tableView : UITableView = {
        let tableView = UITableView()
        tableView.extUseAutoLayout()
        tableView.extSetTableView(self, self)
        tableView.extRegistCell([EXEmailBindingTC.classForCoder()], ["EXEmailBindingTC"])
        if  UserInfoEntity.sharedInstance().email != "" {
            tableView.tableHeaderView = header
        }
        return tableView
    }()
    
    
    lazy var header: oldMailView = {
        let v = oldMailView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 45))
        return v
    }()
    
    
    
    lazy var nextBtn : EXButton = {
        let btn = EXButton()
        btn.extUseAutoLayout()
        btn.extSetAddTarget(self, #selector(clickNextBtn))
        btn.setTitle(LanguageTools.getString(key: "common_action_next"), for: UIControl.State.normal)
        return btn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubViews([tableView,nextBtn])
        tableView.snp.makeConstraints { (make) in
            make.left.top.right.equalToSuperview()
            make.bottom.equalTo(nextBtn.snp.top).offset(-10)
        }
        nextBtn.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(44)
            make.bottom.equalToSuperview().offset(-30 - TABBAR_BOTTOM)
        }
        if UserInfoEntity.sharedInstance().isOpenMobileCheck == "1"{
            type.append("2")
        }
        if UserInfoEntity.sharedInstance().googleStatus == "1"{
            type.append("1")
        }
        if UserInfoEntity.sharedInstance().email != ""{
            type.append("3")
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension EXEmailBindingView : UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 73
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : EXEmailBindingTC = tableView.dequeueReusableCell(withIdentifier: "EXEmailBindingTC") as! EXEmailBindingTC
        cell.modify = self.modify
        cell.textField.input.rx.text.orEmpty.asObservable()
            .map({ text in
                return (text.count > 0)
            })
            .bind(to:nextBtn.rx.isEnabled)
            .disposed(by: self.disposeBag)
        cell.textfieldValueChangeBlock = {[weak self]str in
            self?.email = str
            self?.nextBtn.isEnabled = str.count > 0
        }
        return cell
    }
}

extension EXEmailBindingView{
    @objc func clickNextBtn(){
        if BusinessTools.isEmail(self.email) == false{
            EXAlert.showFail(msg:LanguageTools.getString(key: "safety_tip_inputMail"))
            nextBtn.hideLoading()
            return
        }
        
        if UserInfoEntity.sharedInstance().isOpenMobileCheck == "0" && UserInfoEntity.sharedInstance().googleStatus == "0"{
            EXAlert.showFail(msg: "common_text_pleaseBindGoogleFirst".localized())
            return
        }
        
        vailDataEmailOrPhone()
    }
    //Verify if the mobile email is duplicate
    func vailDataEmailOrPhone(){
        appApi.rx.request(.userUpdatePhoneOrEmail(keyWord: self.email,isPhone: false))
            .MJObjectMap(EXVoidModel.self).subscribe(onSuccess: { [weak self] (model) in
                guard let mySelf = self else{return}
                mySelf.validation()
            }, onFailure: { (error) in
                
            }).disposed(by: self.disposeBag)
        return
    }
    
    //Secondary validation
    func validation(){
        let sheet = EXOldActionSheetView()
        self.sheetView = sheet
        sheet.autoDismiss = false
        sheet.configTextfields(title: "common_text_safetyAuth".localized(), itemModels:self.models())
        sheet.actionFormCallback = {[weak self] formDic in
            guard let mySelf = self else{return}
            var googleCode = ""//Google verification code
            var smsAuthCode = ""//Mobile verification code
            var oldemailCode = ""//Old email
            var newmailCode = ""//New email
            if mySelf.type.contains("1"){
                if let google = formDic["googleCode"]{
                    googleCode = google
                }
                if googleCode == ""{
                    EXAlert.showFail(msg: LanguageTools.getString(key: "common_tip_googleAuth".localized()))
                    return
                }
            }
            
            if mySelf.type.contains("2"){
                if let moblie = formDic["moblie"]{
                    smsAuthCode = moblie
                }
                if smsAuthCode == ""{
                    EXAlert.showFail(msg: LanguageTools.getString(key: "personal_tip_inputPhoneCode"))
                    return
                }
            }
            
            if mySelf.type.contains("3"){
                if let email = formDic["oldemail"]{
                    oldemailCode = email
                }
                if oldemailCode == ""{
                    EXAlert.showFail(msg: LanguageTools.getString(key: "personal_tip_pleaseInputOldMailCode"))
                    return
                }
            }
            
            if let code = formDic["newmailCode"]{
                newmailCode = code
            }
            if newmailCode == ""{
                EXAlert.showFail(msg: LanguageTools.getString(key: "personal_tip_pleaseInputBindMailCode"))
                return
            }
            
            if UserInfoEntity.sharedInstance().email == ""{//binding
                appApi.rx.request(AppAPIEndPoint.bindEmail(smsValidCode: smsAuthCode, googleCode: googleCode, emailValidCode: newmailCode, email: mySelf.email)).MJObjectMap(EXVoidModel.self).subscribe(onSuccess: { (model) in
                    //                    EXAlert.dismissEnd {
                    //                        EXAlert.showSuccess(msg: LanguageTools.getString(key: LanguageTools.getString(key: "login_tip_mailBindSuccess")))
                    //                    }
                    UserInfoEntity.sharedInstance().email = mySelf.email
                    UserInfoEntity.setTmpDict()
                    EXAlert.dismissEnd {
                        
                        EXAlert.showSuccess(msg: LanguageTools.getString(key: LanguageTools.getString(key: "toast_bind_email_suc"))) { [weak self] in
                            self?.yy_viewController?.navigationController?.popViewController(animated: true)
                        }
                    }
                }, onFailure: { (error) in
                    
                }).disposed(by: mySelf.disposeBag)
            }else{//change
                appApi.rx.request(AppAPIEndPoint.updateEmailV6(emailOldValidCode: oldemailCode, emailNewValidCode: newmailCode, smsValidCode: smsAuthCode, googleCode: googleCode, emailValidCode: newmailCode, email: mySelf.email)).customObjectMap(EXEmailResultModel.self,errorModelCall: true).subscribe(onSuccess: { (model) in
                    
                    if model.pass == false {
                        self?.updateErrorInfo(emailResult: model)
                        return
                    }
                    UserInfoEntity.sharedInstance().email = mySelf.email
                    UserInfoEntity.setTmpDict()
                    EXAlert.dismissEnd {
                        EXAlert.showSuccess(msg: LanguageTools.getString(key: LanguageTools.getString(key: "common_tip_editSuccess"))) { [weak self] in
                            self?.yy_viewController?.navigationController?.popViewController(animated: true)
                        }
                    }
                }, onFailure: { (error) in
                    
                }).disposed(by: mySelf.disposeBag)
            }
        }
        sheet.itemBtnCallback = {[weak self]key in
            guard let mySelf = self else{return}
            switch key {
            case "moblie":
                mySelf.getsmsValidCode()
                break
            case "oldemail":
                //                mySelf.getemailVallidCode(UserInfoEntity.sharedInstance().email)
                mySelf.getemailVallidCode("")
            case "newmailCode":
                mySelf.getemailVallidCode(mySelf.email)
                break
            default:
                break
            }
        }
        EXAlert.showSheet(sheetView:sheet)
    }
    
    func models()->[EXOldInputSheetModel] {
        var models : [EXOldInputSheetModel] = []
        
        if type.contains("3"){//mailbox
            let model = EXOldInputSheetModel.setModel(withTitle:UserInfoEntity.sharedInstance().email,key:"oldemail",placeHolder: "personal_tip_inputMailCode".localized(), type: .sms , keyBoard : .numberPad)
            models.append(model)
        }
        let model1 = EXOldInputSheetModel.setModel(withTitle:self.email,key:"newmailCode",placeHolder: "personal_tip_inputMailCode".localized(), type: .sms,keyBoard : .numberPad)
        models.append(model1)
        if type.contains("2"){//mobile phone
            let model = EXOldInputSheetModel.setModel(withTitle:UserInfoEntity.sharedInstance().mobileNumber,key:"moblie",placeHolder: "personal_tip_inputPhoneCode".localized(), type: .sms,keyBoard : .numberPad)
            models.append(model)
        }
        if type.contains("1"){//Google
            let model = EXOldInputSheetModel.setModel(withTitle:"personal_text_googleCode".localized(),key:"googleCode",placeHolder: "common_tip_googleAuth".localized(), type: .paste, keyBoard : .numberPad)
            models.append(model)
        }
        return models
    }
    
    
    func updateErrorInfo(emailResult: EXEmailResultModel){
        guard self.sheetView != nil else {
            return
        }
        
        let itemModels = self.sheetView!.itemModels
        for itemModel in itemModels {
            if itemModel.key == "newmailCode"{
                itemModel.errorTipShow = !emailResult.curEmailPass
                itemModel.errorTip = emailResult.email_ver_msg
            }else if itemModel.key == "oldemail"{
                itemModel.errorTipShow = !emailResult.oldEmailPass
                itemModel.errorTip = emailResult.email_ver_msg
            }else if itemModel.key == "moblie"{
                itemModel.errorTipShow = !emailResult.smsCodePass
                itemModel.errorTip = emailResult.mobile_ver_msg
            }else if itemModel.key == "googleCode"{
                itemModel.errorTipShow = !emailResult.googleCodePass
                itemModel.errorTip = emailResult.google_ver_msg
            }
        }
        
        self.sheetView?.updateInputErrorTip()
        
    }
    //Obtain mobile verification code
    func getsmsValidCode(){
        appApi.rx.request(.getsmsValidCode(token: XUserDefault.getToken() ?? "", operationType: EXSendVerificationCode.updateemailwithphone, countryCode: "", mobile: "")).MJObjectMap(EXVoidModel.self).subscribe(onSuccess: { (m) in
        }, onFailure: { _ in
            
        }).disposed(by: disposeBag)
    }
    
    //Obtain email verification code
    func getemailVallidCode(_ email : String){
        appApi.rx.request(.getemailVallidCode(email: email, operationType: EXSendVerificationCode.updateemailwithemail,token:"")).MJObjectMap(EXVoidModel.self).subscribe(onSuccess: { (m) in
        }, onFailure: { _ in
     
        }).disposed(by: disposeBag)
    }
    
}

