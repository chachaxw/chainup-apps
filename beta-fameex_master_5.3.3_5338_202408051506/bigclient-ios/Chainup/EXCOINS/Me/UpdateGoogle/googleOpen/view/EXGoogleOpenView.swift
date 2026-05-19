//
//  EXGoogleOpenView.swift
//  Chainup
//
//  Created by zewu wang on 2023/4/15.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import RxSwift
import EXKit
class EXGoogleOpenView: UIView {

    lazy var tableView : UITableView = {
        let tableView = UITableView()
        tableView.extUseAutoLayout()
        tableView.extSetTableView(self,self)
        tableView.estimatedRowHeight = 44
        tableView.extRegistCell([EXGoogleOpenTC.classForCoder()], ["EXGoogleOpenTC"])
//        tableView.extRegistCell()
        return tableView
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubViews([tableView])
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
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
                EXAlert.showFail(msg: "login_tip_inputCode".localized())
                return
            }
            //Turn off Google verification
            appApi.rx.request(.closeGoogle(smsValidCode: smsAuthCode, googleCode: googleCode)).MJObjectMap(EXVoidModel.self).subscribe(onSuccess: { (model) in
               
                UserInfoEntity.sharedInstance().googleStatus = "0"
                UserInfoEntity.setTmpDict()
                sheet.dismiss()
                EXAlert.dismissEnd {
                    EXAlert.showSuccess(msg: "common_text_googleAuthOff".localized())
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        mySelf.yy_viewController?.navigationController?.popViewController(animated: true)
                    }
                }
            }, onError: { (error) in
                
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
        let model2 = EXOldInputSheetModel.setModel(withTitle:UserInfoEntity.sharedInstance().mobileNumber,key:"smsAuthCode",placeHolder: "personal_tip_inputPhoneCode".localized(), type: .sms, keyBoard:.numberPad)
        models.append(model2)
        models.append(model1)
        return models
    }
    
    //Obtain mobile verification code
    func getsmsValidCode(){
        appApi.rx.request(.getsmsValidCode(token: "", operationType: EXSendVerificationCode.closegoogleAndmoblie, countryCode: "", mobile: "")).MJObjectMap(EXVoidModel.self).subscribe(onSuccess: { (m) in
            //EXAlert. showSuccess (msg: LanguageTools. getString (key: "Verification code sent")
        }) { (erro) in
            
            }.disposed(by: disposeBag)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func exalertsecuritySheet(_ vc : UIViewController, unbind: Bool = false){
        let hour = EXAppConfigManager.sharedInstance.getUpdateWithDrawHour()
        alert(hour: hour, vc: vc,unbind: unbind)
    }
    func alert(hour: String,vc : UIViewController,unbind: Bool = false){
        let alert = EXCommonAlert()
        let message = String(format:"login_tip_safeSettingChange".localized(),hour)
        alert.configAlert(tipImage: nil,
                          title: message,
                          message: nil,
                          cancelBtnTitle:"common_text_btnCancel".localized(),
                          sureBtnTitle: "personal_Center_text32".localized(),
                          btnLayoutStyle: .horizontal, alertCallBack: { [weak self] type in
            guard let `self` = self else { return }
            if type == .sure{
                self.validation()
            }
        })
        //show
        EXAlert.showAlert(alertView: alert)
        
    }
    
    
}

extension EXGoogleOpenView : UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : EXGoogleOpenTC = tableView.dequeueReusableCell(withIdentifier: "EXGoogleOpenTC") as! EXGoogleOpenTC
        cell.valueChangeCallback = {[weak self]b in            
            if UserInfoEntity.sharedInstance().isOpenMobileCheck == "0"{
                EXAlert.showFail(msg: "login_tip_bindPhoneFirst".localized())
                cell.switchV.isOn = true
                return
            }
            
            self?.exalertsecuritySheet(self?.yy_viewController ?? UIViewController(), unbind: b)
            cell.switchV.isOn = true
        }
        return cell
    }
    
    
}

