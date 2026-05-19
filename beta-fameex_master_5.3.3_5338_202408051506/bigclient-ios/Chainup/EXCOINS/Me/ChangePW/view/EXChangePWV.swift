//
//  EXChangePWV.swift
//  Chainup
//
//  Created by zewu wang on 2019/4/12.
//  Copyright © 2019 zewu wang. All rights reserved.
//

import UIKit
import RxSwift
import EXKit

class EXChangePWV: UIView {
    /*
     UserInfoEntity.sharedInstance().authLevel == "1" ? [LanguageTools.getString(key: "safety_text_userIdentifier"),
         LanguageTools.getString(key: "safety_text_oldPassword"),LanguageTools.getString(key: "personal_text_newPwd"),LanguageTools.getString(key: "personal_text_confirmPwd")]
     
     */
    var tableViewNameDatas : [String] = [LanguageTools.getString(key: "safety_text_oldPassword"),LanguageTools.getString(key: "personal_text_newPwd"),LanguageTools.getString(key: "personal_text_confirmPwd")]
    
    var tableViewRowDatas : [EXChangePWEntity] = []
    
    var type : [String] = []
    
    lazy var tableView : UITableView = {
        let tableView = UITableView()
        tableView.extUseAutoLayout()
        tableView.extRegistCell([EXChangePWTC.classForCoder()], ["EXChangePWTC"])
        tableView.extSetTableView(self, self)
        return tableView
    }()
    
    lazy var confimBtn : EXButton = {
        let btn = EXButton()
        btn.extUseAutoLayout()
        btn.isEnabled = false
        btn.setTitle(LanguageTools.getString(key: "common_action_next"), for: UIControl.State.normal)
        btn.extSetAddTarget(self, #selector(clickConfimBtn))
        return btn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubViews([tableView,confimBtn])
        tableView.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(confimBtn.snp.top).offset(-10)
        }
        confimBtn.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(44)
            make.bottom.equalToSuperview().offset(-30 - TABBAR_BOTTOM)
        }
        setData()
    }
    
    func setData(){
        var arr : [EXChangePWEntity] = []
        for str in tableViewNameDatas{
            let entity = EXChangePWEntity()
            entity.name = str
            switch str{
//            case LanguageTools.getString(key: "safety_text_userIdentifier"):
//                entity.placeHolder = LanguageTools.getString(key: "personal_tip_inputIdnumber")
            case LanguageTools.getString(key: "safety_text_oldPassword"):
                entity.placeHolder = LanguageTools.getString(key: "personal_tip_inputOldPwd")
            case LanguageTools.getString(key: "personal_text_newPwd"):
                entity.placeHolder = LanguageTools.getString(key: "personal_tip_inputNewPwd")
            case LanguageTools.getString(key: "personal_text_confirmPwd"):
                entity.placeHolder = LanguageTools.getString(key: "personal_text_confirmPwd")
            default:
                break
            }
            arr.append(entity)
        }
        tableViewRowDatas = arr
        tableView.reloadData()
        if UserInfoEntity.sharedInstance().isOpenMobileCheck == "1"{
            type.append("2")
        }
        if UserInfoEntity.sharedInstance().googleStatus == "1"{
            type.append("1")
        }
    }
    
    //监听
    func textfieldValueChange(){
        
        for entity in tableViewRowDatas{
            if entity.info == ""{
                confimBtn.isEnabled = false
                return
            }
        }
        confimBtn.isEnabled = true
    }
    
    //点击修改
    @objc func clickConfimBtn(){
        var oldP = ""
        var newP = ""
        for i in 0..<tableViewRowDatas.count{
            let entity = tableViewRowDatas[i]
           
            switch entity.name{
//            case LanguageTools.getString(key: "safety_text_userIdentifier"):
//                if entity.info == ""{
//                    EXAlert.showFail(msg: LanguageTools.getString(key: "personal_tip_inputIdnumber"))
//                    return
//                }
            case LanguageTools.getString(key: "safety_text_oldPassword"):
                if entity.info == ""{
                    EXAlert.showFail(msg: LanguageTools.getString(key: "personal_tip_inputOldPwd"))
                    return
                }
                oldP = entity.info
            case LanguageTools.getString(key: "personal_text_newPwd"):
                if entity.info == ""{
                    EXAlert.showFail(msg: LanguageTools.getString(key: "login_tip_pleaseInputNewPwd"))
                    return
                }
                if BusinessTools.numberAndCharacter(entity.info) == false{
                    EXAlert.showFail(msg: LanguageTools.getString(key: "common_tip_pwdNotice"))
                    return
                }
                newP = entity.info
                
            case LanguageTools.getString(key: "personal_text_confirmPwd"):
                if entity.info == ""{
                    EXAlert.showFail(msg: LanguageTools.getString(key: "personal_tip_inputOldPwdAgain"))
                    return
                }
                
                //新旧密码不能一致
                if oldP == newP {
                    EXAlert.showFail(msg: LanguageTools.getString(key: "other_text1"))
                    return
                }
                
                if entity.info != tableViewRowDatas[i - 1].info{
                    EXAlert.showFail(msg: LanguageTools.getString(key: "common_tip_inputsNotMatch"))
                    return
                }
            default:
                break
            }
        }
       
        validation()
    }
    
    //二次验证
    func validation(){
        let sheet = EXOldActionSheetView()
        sheet.configTextfields(title: "common_text_safetyAuth".localized(), itemModels:self.models())
        sheet.actionFormCallback = {[weak self] formDic in
            guard let mySelf = self else{return}
//            let idx =  UserInfoEntity.sharedInstance().authLevel == "1" ? 1 : 0
//            let id = UserInfoEntity.sharedInstance().authLevel == "1" ? mySelf.tableViewRowDatas[0].info : ""
            
            let idx = 0
            let id = ""
            //验证谷歌
            var googleCode = ""
            if mySelf.type.contains("1"){
                guard let googleCode1 = formDic["googleCode"]else{
                    EXAlert.showFail(msg: LanguageTools.getString(key: "common_tip_googleAuth"))
                    return
                }
                googleCode = googleCode1
                if googleCode == ""{
                    EXAlert.showFail(msg: LanguageTools.getString(key: "common_tip_googleAuth"))
                    return
                }
            }
            
            //验证手机或者邮箱
            var smsAuthCode = ""
            if mySelf.type.contains("2"){
                if let moblie = formDic["moblie"]{
                    smsAuthCode = moblie
                }
            }else if mySelf.type.contains("3"){
                if let email = formDic["email"]{
                    smsAuthCode = email
                }
            }
            if googleCode == "" && smsAuthCode == ""{
                EXAlert.showFail(msg: LanguageTools.getString(key: "login_tip_inputCode"))
                return
            }
            appApi.rx.request(.changepassword(loginPword: mySelf.tableViewRowDatas[idx].info, newLoginPword: mySelf.tableViewRowDatas[idx + 1].info, smsAuthCode: smsAuthCode, googleCode: googleCode, IdentificationNumber: id)).MJObjectMap(EXVoidModel.self).subscribe(onSuccess: { (model) in
                EXAlert.showSuccess(msg: LanguageTools.getString(key: "common_tip_editpwdSuccess"))
                mySelf.yy_viewController?.navigationController?.popViewController(animated: true)
            }, onFailure: { (error) in
                
            }).disposed(by: mySelf.disposeBag)
        }
        
        sheet.itemBtnCallback = {[weak self]key in
            switch key {
            case "moblie":
                self?.getsmsValidCode()
                break
            case "email":
                self?.getemailVallidCode()
                break
            default:
                break
            }
        }
        EXAlert.showSheet(sheetView:sheet)
    }
    
    func models()->[EXOldInputSheetModel] {
        var models : [EXOldInputSheetModel] = []
        if type.contains("3"){//邮箱
            let model = EXOldInputSheetModel.setModel(withTitle:"personal_text_mailCode".localized(),key:"email",placeHolder: "personal_tip_inputMailCode".localized(), type: .sms)
            models.append(model)
        }
        if type.contains("2"){//手机
            let model = EXOldInputSheetModel.setModel(withTitle:"personal_text_phoneCode".localized(),key:"moblie",placeHolder: "personal_tip_inputPhoneCode".localized(), type: .sms)
            models.append(model)
        }
        if type.contains("1"){//谷歌
            let model = EXOldInputSheetModel.setModel(withTitle:"personal_text_googleCode".localized(),key:"googleCode",placeHolder: "common_tip_googleAuth".localized(), type: .paste)
            models.append(model)
        }
        return models
    }
    
    //获取手机验证码
    func getsmsValidCode(){
        appApi.rx.request(.getsmsValidCode(token: XUserDefault.getToken() ?? "", operationType: EXSendVerificationCode.changepassword, countryCode: "", mobile: "")).MJObjectMap(EXVoidModel.self).subscribe(onSuccess: { (m) in
//            EXAlert.showSuccess(msg: LanguageTools.getString(key: "验证码已发送"))
        }) { (erro) in
            
        }.disposed(by: disposeBag)
    }
    
    //获取邮箱验证码
    func getemailVallidCode(){
        appApi.rx.request(.getemailVallidCode(email: "", operationType: EXSendVerificationCode.changepassword,token: "")).MJObjectMap(EXVoidModel.self).subscribe(onSuccess: { (m) in
//            EXAlert.showSuccess(msg: LanguageTools.getString(key: "验证码已发送"))
        }) { (erro) in
            
            }.disposed(by: disposeBag)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension EXChangePWV : UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewRowDatas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let entity = tableViewRowDatas[indexPath.row]
        let cell : EXChangePWTC = tableView.dequeueReusableCell(withIdentifier: "EXChangePWTC") as! EXChangePWTC
        cell.setCell(entity)
        cell.textfieldValueChangeBlock = {[weak self] in
            self?.textfieldValueChange()
        }
        return cell
    }
}
