//
//  EXChangeOTCPWView.swift
//  Chainup
//
//  Created by zewu wang on 2023/4/13.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import RxSwift
import EXKit

class EXChangeOTCPWView: UIView {
    var type: EXSafetyCheckType = .fundPasswordSet {
        didSet{
            setData()
        }
    }
   
    var setPwdTitletCallBack: EXComVoidBlock?
    var inputTypeList : [EXPasswordType] = []
    var tableViewRowDatas : [EXChangeOTCEntity] = []
    
    
    lazy var tableView : UITableView = {
        let tableView = UITableView()
        tableView.extUseAutoLayout()
        tableView.extRegistCell([EXChangeOTCPWTC.classForCoder()], ["EXChangeOTCPWTC"])
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
    }
    
    func setData(){
        if self.type == .fundPasswordForget{
            return
        }
        if self.type == .fundPasswordModify{
            inputTypeList = [.old,.new,.newConfrim]
        }else if self.type == .fundPasswordSet || self.type == .fundPasswordForgetToReset{
            inputTypeList = [.new,.newConfrim]
        }
        
        tableViewRowDatas.removeAll()
        for type in inputTypeList{
            let entity = EXChangeOTCEntity.getItemWithType(type: type)
            tableViewRowDatas.append(entity)
        }
        tableView.reloadData()

    }
    
    //monitoring
    func textfieldValueChange(){
        for entity in tableViewRowDatas{
            if entity.info == ""{
                confimBtn.isEnabled = false
                return
            }
        }
        confimBtn.isEnabled = true
    }
   
    
    @objc func forgetPwd(){
        self.type = .fundPasswordForget
        self.newValidation()
    }
    
    
    //Click Next
    @objc func clickConfimBtn(){
        var oldPw = ""
        for i in 0..<tableViewRowDatas.count{
            let entity = tableViewRowDatas[i]
            switch entity.type{
            case .old:
                if entity.info == ""{
                    EXAlert.showFail(msg: LanguageTools.getString(key: "safety_tip_inputOtcPassword"))
                    return
                }
                oldPw = entity.info
            case .new:
                if BusinessTools.numberAndCharacter(entity.info) == false{
                    EXAlert.showFail(msg: LanguageTools.getString(key: "common_tip_pwdNotice"))
                    return
                }
                
                if oldPw.count > 0 && oldPw == entity.info {
                    EXAlert.showFail(msg: LanguageTools.getString(key: "other_text1"))
                    return
                }
                if entity.info == ""{
                    EXAlert.showFail(msg: LanguageTools.getString(key: "safety_tip_inputOtcPassword"))
                    return
                }
            case .newConfrim:
                if entity.info == ""{
                    EXAlert.showFail(msg: LanguageTools.getString(key: "common_tip_inputOtcPwdAgain"))
                    return
                }
                if entity.info != tableViewRowDatas[i - 1].info{
                    EXAlert.showFail(msg: LanguageTools.getString(key: "common_tip_inputsNotMatch"))
                    return
                }
            }
        }
        newValidation()
    }
    
    
    
    
    func newValidation (){
        let manger = EXComSafeVaildManger()
        manger.safeCheck = self.type
        manger.startSafeAlert()
        manger.resultCallBack = { result in
            self.submit(result: result)
        }
    }
    
    
    func submit(result: EXCodeResult){
        
        if type == .fundPasswordForget{
            otcApi.rx.request(.capitalPasswordForget(smsAuthCode: result.phoneCode, emailAuthCode: result.emailCode, googleCode: result.googleCode)).MJObjectMap(EXVoidModel.self).subscribe(onSuccess: { [weak self] (model) in
                guard let `self` = self else { return }
                self.setPwdTitletCallBack?()
                self.type = .fundPasswordForgetToReset
            }, onFailure: { (error) in

            }).disposed(by: self.disposeBag)
            
            
            return
        }
        
        var oldPwd: String? = nil
        var newPwd: String? = nil
        var checkOldFlag: String? = nil
        for data in tableViewRowDatas {
            switch data.type {
            case .old:
                oldPwd = data.info
            case .new:
                newPwd = data.info
            case .newConfrim:
                break
            }
        }
        
        
        if type == .fundPasswordSet{
            otcApi.rx.request(.otcSetPw(newCapitalPwd: newPwd, smsAuthCode: result.phoneCode, emailAuthCode: result.emailCode, googleCode: result.googleCode)).MJObjectMap(EXVoidModel.self).subscribe(onSuccess: { [weak self] (model) in
                guard let `self` = self else { return }
                UserInfoEntity.sharedInstance().isCapitalPwordSet = "1"
                UserInfoEntity.setTmpDict()
                EXAlert.showSuccess(msg: "Success".localized())
                self.goBack()
            }, onFailure: { (error) in

            }).disposed(by: self.disposeBag)
            return
        }
        
        var sussMsg = "Success".localized()
        
        if type == .fundPasswordModify{
            checkOldFlag = "1"
//            sussMsg = "otc_tip_changePwdSuccess".localized()
        }else if type == .fundPasswordForgetToReset{
            oldPwd = nil
        }
        
        otcApi.rx.request(.modifyOtcPw(newCapitalPwd: newPwd, smsAuthCode: result.phoneCode, emailCode: result.emailCode, googleCode: result.googleCode, capitalPwd: oldPwd, checkOldFlag: checkOldFlag, securityInfo: nil)).MJObjectMap(EXVoidModel.self).subscribe(onSuccess: { [weak self] (model) in
            guard let `self` = self else { return }
            UserInfoEntity.sharedInstance().isCapitalPwordSet = "1"
            UserInfoEntity.setTmpDict()
            EXAlert.showSuccess(msg: sussMsg)
            self.goBack()
           
        }, onFailure: { (error) in

        }).disposed(by: self.disposeBag)
    }

    
    func goBack(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.yy_viewController?.navigationController?.popViewController(animated: true)
        }
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

extension EXChangeOTCPWView : UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 73
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewRowDatas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let entity = tableViewRowDatas[indexPath.row]
        let cell : EXChangeOTCPWTC = tableView.dequeueReusableCell(withIdentifier: "EXChangeOTCPWTC") as! EXChangeOTCPWTC
        cell.setCell(entity)
        cell.textfieldValueChangeBlock = {[weak self] in
            self?.textfieldValueChange()
        }
        cell.forgetPwdCallBack = { [weak self] in
            guard let `self` = self else { return }
            self.forgetPwd()
        }
        return cell
    }
}

