//
//  EXMoblieBindingView.swift
//  Chainup
//
//  Created by zewu wang on 2023/4/16.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import RxSwift
import EXKit

class EXMoblieBindingView: UIView {
    
    var tableViewRowDatas : [EXBindingMoblieEntity] = [EXBindingMoblieEntity(),EXBindingMoblieEntity()]
    
    var phone = ""

    lazy var tableView : UITableView = {
        let tableView = UITableView()
        tableView.extUseAutoLayout()
        tableView.extRegistCell([EXMoblieTwoTC.classForCoder()], ["EXMoblieTwoTC"])
        tableView.extSetTableView(self, self)
        return tableView
    }()
    
    lazy var nextBtn : EXButton = {
        let btn = EXButton()
        btn.extUseAutoLayout()
        btn.setTitle(LanguageTools.getString(key: "common_action_next"), for: UIControl.State.normal)
        btn.extSetAddTarget(self, #selector(clickNextBtn))
        return btn
    }()
    
    var type : [String] = []
    
    override init(frame: CGRect) {
        super.init(frame : frame)
        addSubViews([tableView,nextBtn])
        tableView.snp.makeConstraints { (make) in
            make.left.right.top.equalToSuperview()
            make.bottom.equalTo(nextBtn.snp.top).offset(-10)
        }
        nextBtn.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(44)
            make.bottom.equalToSuperview().offset(-30 - TABBAR_BOTTOM)
        }
        setDatas()
        if UserInfoEntity.sharedInstance().mobileNumber != ""{
            type.append("2")
        }
        if UserInfoEntity.sharedInstance().googleStatus != "0"{
            type.append("1")
        }
    }
    
    func setDatas(){
        for i in 0..<tableViewRowDatas.count{
            let entity = tableViewRowDatas[i]
            switch i {
            case 0:
                entity.type = "0"
                let defaultCountryCode = EXAppConfigManager.sharedInstance.getDefaultCountryCode()
                let defaultCountryCodeReal = EXAppConfigManager.sharedInstance.getDefaultCountryCodeReal()
                if let region = CountryList.getRegionWithNumber(defaultCountryCodeReal){
                    if LanguageTools.isHan() == true{
                        entity.text = region.cnName + " " + region.dialingCode
                    }else{
                        entity.text = region.enName + " " + region.dialingCode
                    }
                    entity.info = region.dialingCode
                }else if let region = CountryList.getRegion(defaultCountryCode){
                    if LanguageTools.isHan() == true{
                        entity.text = region.cnName + " " + region.dialingCode
                    }else{
                        entity.text = region.enName + " " + region.dialingCode
                    }
                    entity.info = region.dialingCode
                }
            case 1:
                entity.type = "1"
                entity.placeHolder = "userinfo_tip_inputPhone".localized()
            default:
                break
            }
        }
        self.tableView.reloadData()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension EXMoblieBindingView : UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            return 50
        case 1:
            return 77
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let entity = tableViewRowDatas[indexPath.row]
        let cell : EXMoblieTwoTC = tableView.dequeueReusableCell(withIdentifier: "EXMoblieTwoTC") as! EXMoblieTwoTC
        cell.setCell(entity)
        cell.textField.input.rx.text.orEmpty.asObservable()
            .map({ [weak self] text in
                let one = self?.tableViewRowDatas[0]
                print(one!.info)
//                print(cell?.entity.info)
                if one!.info.contains("+86") {
                    return text.isChinaPhone()
                }else{
                    return text.isPhone()
                }
            })
            .bind(to:nextBtn.rx.isEnabled)
            .disposed(by: self.disposeBag)
        cell.textfieldValueChangeBlock = {[weak self]str in
            self?.phone = str
        }
        return cell
    }
}

extension EXMoblieBindingView{
    @objc func clickNextBtn(){
        if self.phone == ""{
            EXAlert.showFail(msg: "userinfo_tip_inputPhone".localized())
            return
        }
        if self.tableViewRowDatas[0].info == ""{
            EXAlert.showFail(msg: "filter_fold_country".localized())
            return
        }
        vailDataEmailOrPhone()
    }
    //Verify if the mobile email is duplicate
    func vailDataEmailOrPhone(){
        appApi.rx.request(.userUpdatePhoneOrEmail(keyWord: self.phone,isPhone: true))
            .MJObjectMap(EXVoidModel.self).subscribe(onSuccess: { [weak self] (model) in
                guard let mySelf = self else{return}
                mySelf.validation()
            }, onFailure: { (error) in
            
        }).disposed(by: self.disposeBag)
    }
    
    //Secondary validation
    func validation(){
        let sheet = EXOldActionSheetView()
        sheet.configTextfields(title: "common_text_safetyAuth".localized(), itemModels:self.models())
        sheet.actionFormCallback = {[weak self] formDic in
            guard let mySelf = self else{return}
            var googleCode = ""//Google verification code
            var oldphoneCode = ""//Old phone number verification
            var newphoneCode = ""//New phone number verification
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
                if let moblie = formDic["oldphone"]{
                    oldphoneCode = moblie
                }
                if oldphoneCode == ""{
                    EXAlert.showFail(msg: LanguageTools.getString(key: "personal_tip_inputPhoneCode"))
                    return
                }
            }
            
            if let code = formDic["newphone"]{
                newphoneCode = code
            }
            if newphoneCode == ""{
                EXAlert.showFail(msg: LanguageTools.getString(key: "personal_tip_pleaseInputBindMailCode"))
                return
            }
            
            if UserInfoEntity.sharedInstance().mobileNumber == ""{//binding
                var regionText = "86"
                let regionArray = mySelf.tableViewRowDatas[0].info.components(separatedBy: "+")
                if regionArray.count > 1{
                    regionText = regionArray[1]
                }
                appApi.rx.request(AppAPIEndPoint.bindPhone(googleCode: googleCode, countryCode: regionText, mobileNumber: mySelf.phone, smsAuthCode: newphoneCode)).MJObjectMap(EXVoidModel.self).subscribe(onSuccess: { (model) in
                    EXAlert.showSuccess(msg: LanguageTools.getString(key: LanguageTools.getString(key: "common_tip_bindSuccess"))) { [weak self] in
                        UserInfoEntity.sharedInstance().mobileNumber = mySelf.phone
                       
                        UserInfoEntity.sharedInstance().isOpenMobileCheck = "1"
                        UserInfoEntity.setTmpDict()
                        UserInfoEntity.sharedInstance().getUserInfo( {
                            
                        }) {
                            
                        }
                        self?.yy_viewController?.navigationController?.popViewController(animated: true)
                    }
                }, onFailure: { (error) in
                    
                }).disposed(by: mySelf.disposeBag)
            }else{//change
                var regionText = "86"
                let regionArray = mySelf.tableViewRowDatas[0].info.components(separatedBy: "+")
                if regionArray.count > 1{
                    regionText = regionArray[1]
                }
                appApi.rx.request(AppAPIEndPoint.updatePhone(authenticationCode: oldphoneCode, googleCode: googleCode, countryCode: regionText, mobileNumber: mySelf.phone, smsAuthCode: newphoneCode)).MJObjectMap(EXVoidModel.self).subscribe(onSuccess: { (model) in
                    EXAlert.showSuccess(msg: LanguageTools.getString(key: LanguageTools.getString(key: "common_tip_editSuccess"))) { [weak self] in
                        UserInfoEntity.sharedInstance().mobileNumber = mySelf.phone
                        UserInfoEntity.setTmpDict()
                        UserInfoEntity.sharedInstance().isOpenMobileCheck = "1"
                        UserInfoEntity.sharedInstance().getUserInfo ({
                            
                        }) {
                            
                        }
                        self?.yy_viewController?.navigationController?.popViewController(animated: true)
                    }
                }, onFailure: { (error) in
                    
                }).disposed(by: mySelf.disposeBag)
            }
        }
        sheet.itemBtnCallback = {[weak self]key in
            guard let mySelf = self else{return}
            switch key {
            case "newphone":
                mySelf.getsmsValidCode(mySelf.phone)
                break
            case "oldphone":
                mySelf.getsmsValidCode("")
            default:
                break
            }
        }
        EXAlert.showSheet(sheetView:sheet)
    }
    
    func models()->[EXOldInputSheetModel] {
        var models : [EXOldInputSheetModel] = []
        if type.contains("2"){//mobile phone
            let model = EXOldInputSheetModel.setModel(withTitle:UserInfoEntity.sharedInstance().mobileNumber,key:"oldphone",placeHolder: "personal_tip_inputPhoneCode".localized(), type: .sms , keyBoard : .numberPad)
            models.append(model)
        }
        let model1 = EXOldInputSheetModel.setModel(withTitle:self.phone,key:"newphone",placeHolder: "personal_tip_inputPhoneCode".localized(), type: .sms , keyBoard : .numberPad)
        models.append(model1)
        
        if type.contains("1"){//Google
            let model = EXOldInputSheetModel.setModel(withTitle:"personal_text_googleCode".localized(),key:"googleCode",placeHolder: "common_tip_googleAuth".localized(), type: .paste, keyBoard : .numberPad)
            models.append(model)
        }
        return models
    }
    
    //Obtain mobile verification code
    func getsmsValidCode(_ str : String){
        var regionText = "86"
        let regionArray =  self.tableViewRowDatas[0].info.components(separatedBy: "+")
        if regionArray.count > 1{
            regionText = regionArray[1]
        }
        
        var operationType = EXSendVerificationCode.updatephonewithphone
        if UserInfoEntity.sharedInstance().mobileNumber.isEmpty {
            operationType = EXSendVerificationCode.blindphone
        }
        appApi.rx.request(.getsmsValidCode(token: XUserDefault.getToken() ?? "", operationType: operationType, countryCode: str != "" ? regionText : "", mobile: str)).MJObjectMap(EXVoidModel.self).subscribe(onSuccess: { (m) in
        }) { (erro) in
            
        }.disposed(by: disposeBag)
    }
    
}

