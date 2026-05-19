//
//  EXMyInfoView.swift
//  Chainup
//
//  Created by zewu wang on 2023/3/25.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import RxSwift
import EXKit
class EXMyInfoView: UIView {
    
    var tableViewNameDatas : [String] = [
        "userinfo_text_account".localized(),
        "UID",
        "userinfo_text_accountState".localized(),
        "otcSafeAlert_action_identify".localized()
    ]
    
    var tableViewRowDatas : [EXMyInfoEntity] = []
    
    lazy var tableHeaderView: EXMyInfoHeaderView = {
        let v = EXMyInfoHeaderView()
        v.updateNikeNameBlock = {[weak self] _ in
            guard let self else { return }
            self.updateNickName()
        }
        return v
    }()
    
    lazy var tableView : UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.extUseAutoLayout()
        tableView.extSetTableView(self, self)
        tableView.extRegistCell([EXMyInfoTC.classForCoder()], ["EXMyInfoTC"])
        return tableView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        let height = tableHeaderView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        tableHeaderView.height = height
        tableView.tableHeaderView = tableHeaderView
    }
    
    func setData(){
        var arr : [EXMyInfoEntity] = []
        for str in tableViewNameDatas{
            let entity = EXMyInfoEntity()
            entity.name = str
            switch str{
            case "otcSafeAlert_action_nickname".localized():
                entity.rightBtnBool = false
                var nickName = "personal_text_setNickname".localized()
                if UserInfoEntity.sharedInstance().nickName.ch_length > 0{
                    nickName =  UserInfoEntity.sharedInstance().nickName
                }
                entity.rightInfo = nickName
                break
                
            case "userinfo_text_account".localized():
                entity.rightInfo = UserInfoEntity.sharedInstance().userAccount
                break
                
            case "UID":
                entity.rightBtnBool = false
                entity.rightInfo = UserInfoEntity.sharedInstance().uid
                break
                
            case "userinfo_text_accountState".localized():
                var accountStatus = ""
                switch  UserInfoEntity.sharedInstance().accountStatus{
                case "0":
                    accountStatus = "noun_account_normal".localized()
                case "1":
                    accountStatus = "noun_account_freezeAll".localized()
                case "2":
                    accountStatus = "noun_account_freezeTransaction".localized()
                case "3":
                    accountStatus = "noun_account_freezeWithdraw".localized()
                default:
                    break
                }
                entity.rightInfo = accountStatus
                break
                
            case "otcSafeAlert_action_identify".localized():
                var authLevel = ""
                switch  UserInfoEntity.sharedInstance().authLevel{
                case "0":
                    entity.rightBtnBool = false
                    authLevel = "noun_login_pending".localized()
                case "1":
                    authLevel = "personal_text_verified".localized()
                default:
                    entity.rightBtnBool = false
                    authLevel = "personal_text_unverified".localized()
                    break
                }
                entity.rightInfo = authLevel
                break
                
            default: break
            }
            arr.append(entity)
        }
        tableViewRowDatas = arr
        tableView.reloadData()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension EXMyInfoView : UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 52
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewRowDatas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let entity = tableViewRowDatas[indexPath.row]
        let cell : EXMyInfoTC = tableView.dequeueReusableCell(withIdentifier: "EXMyInfoTC") as! EXMyInfoTC
        cell.setCell(entity)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let entity = tableViewRowDatas[indexPath.row]
        switch entity.name {
            
        case "otcSafeAlert_action_nickname".localized():
            updateNickName()
            
        case "userinfo_text_account".localized():
            break
            
        case "UID":
            let past = UIPasteboard.general
            past.string = UserInfoEntity.sharedInstance().uid
            EXAlert.showSuccess(msg: "personal_Center_text2".localized())
            break
            
        case "otcSafeAlert_action_identify".localized():
            break
            
        default:
            break
        }
    }
}

extension EXMyInfoView{
    
    func updateNickName(){
        let sheetView = EXUpdateNickNameSheetView()
        sheetView.activeFirstResponder()
        sheetView.confirmBlock = {[weak self] nickName in
            guard let self else { return }
            appApi.rx.request(AppAPIEndPoint.updateNickname(nickname: nickName))
                .MJObjectMap(EXVoidModel.self,false,errorMsg: { errinfo  in
                sheetView.errorTipShowMsg(errmsg: errinfo)
            }).subscribe(onSuccess: {(m) in
                UserInfoEntity.sharedInstance().nickName = nickName
                UserInfoEntity.setTmpDict()
                self.tableHeaderView.updateNickNameIfNeeded(nickName: nickName)
                self.setData()
                EXAlert.dismiss()
            }, onFailure: { (error) in
            }).disposed(by: self.disposeBag)
        }
        EXAlert.showSheet(sheetView: sheetView)
        
        
        
//        let sheet = EXOldActionSheetView()
//        sheet.configTextfields(title: "personal_text_setNickname".localized(), itemModels:self.models())
//        sheet.autoDismiss = false
//        sheet.footerCancelBtn.setTitle("save".localized(), for: .normal)
//        sheet.actionFormCallback = {[weak self,weak sheet] formDic in
//            guard let self else { return }
//            appApi.rx.request(AppAPIEndPoint.updateNickname(nickname: formDic["nickname"] ?? "")).MJObjectMap(EXVoidModel.self,false,errorMsg: { errinfo  in
//                sheet?.errorTipShowMsg(errmsg: errinfo)
//            }).subscribe(onSuccess: {(m) in
//                let nickName = formDic["nickname"] ?? ""
//                UserInfoEntity.sharedInstance().nickName = formDic["nickname"] ?? ""
//                UserInfoEntity.setTmpDict()
//                self.tableHeaderView.updateNickNameIfNeeded(nickName: nickName)
//                self.setData()
//                EXAlert.dismiss()
//            }, onFailure: { (error) in
//            }).disposed(by: self.disposeBag)
//        }
//        EXAlert.showSheet(sheetView:sheet)
    }
    
    func models()->[EXOldInputSheetModel] {
        let model = EXOldInputSheetModel.setModel(withTitle:"",key:"nickname",placeHolder: "userinfo_tip_inputNickname".localized(), type: .input)
        model.maxInput = 10
        model.errorTipShow = true
        model.validBlock = { str -> Bool in
            return str.count > 0 && str.count <= 10
        }
        model.validbtnEnableBlock = { str -> Bool in
            return str.count > 0 && str.count <= 10
        }
        return[model]
    }
    
    
    @objc func gotoRealNameWait(){
        let vc = EXRealNameThreeVC()
        EXAlert.showVc(controller: vc,ratio: 0.9)
    }
    
}

