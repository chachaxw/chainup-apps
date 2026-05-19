//
//  EXMoblieOneView.swift
//  Chainup
//
//  Created by zewu wang on 2023/4/13.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit
class EXMoblieOneView: UIView {
    
    var tableViewRowDatas : [EXBindingBaseEntity] = [EXBindingBaseEntity(),EXBindingBaseEntity()]
    
    lazy var tableView : UITableView = {
        let tableView = UITableView()
        tableView.extUseAutoLayout()
        tableView.extSetTableView(self, self)
        tableView.extRegistCell([EXBindingBaseTC.classForCoder()], ["EXBindingBaseTC"])
        tableView.estimatedRowHeight = 50
        return tableView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        //        setData()
    }
    
    func setData(){
        for i in 0..<tableViewRowDatas.count{
            let entity = tableViewRowDatas[i]
            switch i {
            case 1:
                entity.type = "0"
                entity.name = LanguageTools.getString(key: "safety_action_activePhone")
                entity.switchType = UserInfoEntity.sharedInstance().isOpenMobileCheck
            case 0:
                entity.type = "1"
                entity.name = "personal_Center_text12".localized()
                entity.rightName = UserInfoEntity.sharedInstance().mobileNumber
                //                entity.rightName = LanguageTools.getString(key: "common_action_edit")
            default:
                break
            }
        }
        tableView.reloadData()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension EXMoblieOneView : UITableViewDelegate , UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewRowDatas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let entity = tableViewRowDatas[indexPath.row]
        let cell : EXBindingBaseTC = tableView.dequeueReusableCell(withIdentifier: "EXBindingBaseTC") as! EXBindingBaseTC
        cell.setCell(entity)
        cell.valueChangeCallback = {[weak self,weak cell](tag , b) in
            guard let self else{ return }
            self.switchmoblievalidation(b)
            cell?.switchV.isOn = !b
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0{
            let vc = EXMoblieBindingVC()
            self.exalertsecuritySheet(vc)
        }
    }
    
}

extension EXMoblieOneView{
    //Prompt user for 48 hours modifLoginPwd to change password
    func exalertsecuritySheet(_ vc : UIViewController, unbind: Bool = false){
        //If the background is enabled
        let hour = EXAppConfigManager.sharedInstance.getUpdateWithDrawHour()
        alert(hour: hour, vc: vc,unbind: unbind)
    }
    func alert(hour: String,vc : UIViewController,unbind: Bool = false){
        let alert = EXCommonAlert()
        let message = String(format:"login_tip_safeSettingChange".localized(),hour)
        alert.configAlert(tipImage: nil,
                          title: message,
                          message: nil,
                          cancelBtnTitle:LanguageTools.getString(key: "common_text_btnCancel"),
                          sureBtnTitle:  LanguageTools.getString(key: "personal_Center_text32"),
                          btnLayoutStyle: .horizontal, alertCallBack: { [weak self] type in
            guard let `self` = self else { return }
            if type == .sure{
                if unbind == true{
                    self.validation()
                }else{
                    self.yy_viewController?.navigationController?.pushViewController(vc, animated: true)
                }
            }
            
        })
        //show
        EXAlert.showAlert(alertView: alert)
        
    }
    
    //Enabling and disabling mobile authentication
    func switchmoblievalidation(_ b : Bool){
        //open
        if b == true{
            //Directly opening requires an interface
            appApi.rx.request(.openMoblieValidation)
                .MJObjectMap(EXVoidModel.self)
                .subscribe(onSuccess: {[weak self] (model) in
                    UserInfoEntity.sharedInstance().isOpenMobileCheck = "1"
                    UserInfoEntity.setTmpDict()
                    self?.tableViewRowDatas[0].switchType = "1"
                    self?.tableView.reloadData()
                    self?.setData()
                }) { (error) in
                    
                }.disposed(by: disposeBag)
        }else{//close
            if UserInfoEntity.sharedInstance().googleStatus == "0"{
                EXAlert.showFail(msg: LanguageTools.getString(key: "personal_tip_pleaseOpenGoogleFirst"))
                setData()
                return
            }
            
            exalertsecuritySheet(self.yy_viewController ?? UIViewController(),unbind: true)
            //            validation()
        }
    }
    
    //Secondary validation
    func validation(){
        let sheet = EXOldActionSheetView()
        sheet.autoDismiss = false
        sheet.configTextfields(title: "common_text_safetyAuth".localized(), itemModels:self.models())
        sheet.actionFormCallback = {[weak self] formDic in
            guard let mySelf = self else{return}
            guard let googleCode = formDic["googleCode"]else{return}
            guard let smsAuthCode = formDic["smsAuthCode"] else{return}
            if googleCode == "" && smsAuthCode == ""{
                EXAlert.showFail(msg: LanguageTools.getString(key: "login_tip_inputCode"))
                return
            }
            //Turn off mobile verification
            appApi.rx.request(AppAPIEndPoint.closeMoblie(smsValidCode: smsAuthCode, googleCode: googleCode)).MJObjectMap(EXVoidModel.self).subscribe(onSuccess: { (model) in
                UserInfoEntity.sharedInstance().isOpenMobileCheck = "0"
                UserInfoEntity.setTmpDict()
                self?.setData()
                EXAlert.dismissEnd {
                    EXAlert.showSuccess(msg: LanguageTools.getString(key: "common_text_phoneAuthOff"))
                }
                
            }, onFailure: { (error) in
                
            }).disposed(by: mySelf.disposeBag)
        }
        sheet.itemBtnCallback = {[weak self]key in
            switch key {
            case "smsAuthCode":
                self?.getsmsValidCode()
                break
            default:
                break
            }
        }
        EXAlert.showSheet(sheetView:sheet)
    }
    
    func models()->[EXOldInputSheetModel] {
        var models : [EXOldInputSheetModel] = []
        let model1 = EXOldInputSheetModel.setModel(withTitle:"personal_text_googleCode".localized(),key:"googleCode",placeHolder: "common_tip_googleAuth".localized(), type: .paste , keyBoard:.numberPad)
        let model2 = EXOldInputSheetModel.setModel(withTitle:"personal_text_phoneCode".localized(),key:"smsAuthCode",placeHolder: "personal_tip_inputPhoneCode".localized(), type: .sms)
        models.append(model2)
        models.append(model1)
        return models
    }
    
    //Obtain mobile verification code
    func getsmsValidCode(){
        appApi.rx.request(.getsmsValidCode(token: XUserDefault.getToken() ?? "", operationType: EXSendVerificationCode.closegoogleAndmoblie, countryCode: "", mobile: "")).MJObjectMap(EXVoidModel.self).subscribe(onSuccess: { (m) in
        }) { (erro) in
            
        }.disposed(by: disposeBag)
    }
    
}

