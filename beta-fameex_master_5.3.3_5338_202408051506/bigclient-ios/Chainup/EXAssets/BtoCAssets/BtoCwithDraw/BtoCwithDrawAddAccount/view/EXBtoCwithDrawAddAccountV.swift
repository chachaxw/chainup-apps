//
//  EXBtoCwithDrawAddAccountV.swift
//  Chainup
//
//  Created by zewu wang on 2023/10/23.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit

class EXBtoCwithDrawAddAccountV: UIView {
    
    typealias NeedContentBlock = () -> ()
    var needContentBlock : NeedContentBlock?
    
    var type = EXBtoCwithDrawAddAccountType.add
    {
        didSet{
            if type == .add{
                addBtn.setTitle("payMethod_action_addnew".localized(), for: UIControl.State.normal)
            }else{
                addBtn.setTitle("common_text_btnConfirm".localized(), for: UIControl.State.normal)
            }
        }
    }
    
    var model = EXBtoCwithDrawUserBankModel()

    var tableViewBankRowDatas : [EXBtoCwithDrawBankModel] = []
    
    var selectModel : EXBtoCwithDrawBankModel = EXBtoCwithDrawBankModel()
    
    var symbol = ""//Required
    
    var id = ""//Query user withdrawal ID details required
    
    var tableViewRowDatas : [EXBtoCwithDrawAddAccountModel] = []
    var tableViewEditorRowDatas : [EXBtoCwithDrawAddAccountModel] = []

    lazy var tableView : UITableView = {
        let tableView = UITableView()
        tableView.extUseAutoLayout()
        tableView.extRegistCell([EXBtoCwithDrawAddAccountTC.classForCoder()], ["EXBtoCwithDrawAddAccountTC"])
        tableView.extSetTableView(self, self)
        return tableView
    }()
    
    lazy var addBtn : EXButton = {
        let btn = EXButton()
        btn.extUseAutoLayout()
        btn.isEnabled = false
        btn.extSetCornerRadius(1.5)
        btn.isHidden = true
        btn.extSetAddTarget(self, #selector(clickAddBtn))
        return btn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubViews([tableView,addBtn])
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        addBtn.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(44)
            make.bottom.equalToSuperview().offset(-30)
        }
    }
    
    func setTableViewEditorRowDatas(){
        let entity0 = EXBtoCwithDrawAddAccountModel()
        entity0.title = "b2c_text_fiatCoin".localized()
        entity0.text = self.symbol.uppercased()
        
        let entity1 = EXBtoCwithDrawAddAccountModel()
        entity1.title = "noun_order_paymentTerm".localized()
        entity1.text = "otc_text_bankCard".localized()
        
        let entity2 = EXBtoCwithDrawAddAccountModel()
        entity2.title = "b2c_text_bank".localized()
        entity2.editor = true
        entity2.state = "1"
        entity2.text = model.bankName
        
        let entity3 = EXBtoCwithDrawAddAccountModel()
        entity3.title = "otc_text_bankBranchName".localized()
        entity3.placeHolder = "otc_tip_pleaseInputBankbranchName".localized()
        entity3.editor = true
        entity3.text = model.bankSub
        
        let entity4 = EXBtoCwithDrawAddAccountModel()
        entity4.title = "otc_text_bankCardNumber".localized()
        entity4.placeHolder = "b2c_text_inputBankNo".localized()
        entity4.editor = true
        entity4.text = model.cardNo
        
        let entity5 = EXBtoCwithDrawAddAccountModel()
        entity5.title = "otc_text_payee".localized()
        entity5.text = UserInfoEntity.sharedInstance().realName
        
        tableViewEditorRowDatas = [entity0,entity1,entity2,entity3,entity4,entity5]
        tableViewRowDatas = tableViewEditorRowDatas
    }
    
    func setData(){
        setTableViewEditorRowDatas()
        tableView.reloadData()
    }
    
    func setView(){
        switch type {
        case .editor,.add://Editing mode
            tableView.snp.remakeConstraints { (make) in
                make.left.top.right.equalToSuperview()
                make.bottom.equalTo(addBtn.snp.top).offset(-30)
            }
            addBtn.isHidden = false
            break
        }
    }
    
    func getData(){
        switch type {
        case .editor://details
            appApi.rx.request(AppAPIEndPoint.getUserBank(id: id)).MJObjectMap(EXBtoCwithDrawUserBankModel.self).subscribe(onSuccess: {[weak self] (model) in
                self?.model = model
                self?.modelTransferSelectorModel()
                self?.setData()
            }) { (error) in
                
            }.disposed(by: disposeBag)
        case .add://Editing mode
            break
        }
        appApi.rx.request(AppAPIEndPoint.getAllBank(symbol: symbol)).MJObjectMap(CommonAryModel.self).subscribe(onSuccess: {[weak self] (arr) in
            guard let mySelf = self else{return}
            if arr.dictAry.count > 0{
                for item in arr.dictAry{
                    if let model = EXBtoCwithDrawBankModel.mj_object(withKeyValues: item){
                        mySelf.tableViewBankRowDatas.append(model)
                    }
                }
                if mySelf.type == .add{
                    mySelf.selectModel = mySelf.tableViewBankRowDatas[0]
                    mySelf.selectorModelTransferModel()
                    mySelf.setData()
                }
            }
        }) { (error) in
            
            }.disposed(by: disposeBag)
    }
    
    //Convert model to selectmodel
    func modelTransferSelectorModel(){
        selectModel.accountName = model.bankName
        selectModel.bankNo = model.bankNo
    }
    //Convert selectmodel to model
    func selectorModelTransferModel(){
        model.bankName = selectModel.accountName
        model.bankNo = selectModel.bankNo
    }
    
    func validation(){
        let sheet = EXOldActionSheetView()
        sheet.configTextfields(title: "common_text_safetyAuth".localized(), itemModels:self.models())
        sheet.autoDismiss = false
        sheet.actionFormCallback = {[weak self] formDic in
            var googleCode = ""//Google verification code
            var mobile = ""//Mobile number verification
            if UserInfoEntity.sharedInstance().googleStatus != "0"{
                if let google = formDic["googleCode"]{
                    googleCode = google
                }
                if googleCode == ""{
                    EXAlert.showFail(msg: LanguageTools.getString(key: "common_tip_googleAuth".localized()))
                    return
                }
            }
            
            if UserInfoEntity.sharedInstance().isOpenMobileCheck != "0"{
                if let moblie = formDic["mobile"]{
                    mobile = moblie
                }
                if mobile == ""{
                    EXAlert.showFail(msg: LanguageTools.getString(key: "personal_tip_inputPhoneCode"))
                    return
                }
            }
            sheet.dismiss()
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.4, execute: {
                if self?.type == .add{
                    self?.addBank(mobile, googleCode: googleCode)
                }else{
                    self?.edtiBank(mobile, googleCode: googleCode)
                }
            })
        }
        sheet.itemBtnCallback = {[weak self]key in
            guard let mySelf = self else{return}
            switch key {
            case "mobile":
                mySelf.getsmsValidCode()
            default:
                break
            }
        }
        EXAlert.showSheet(sheetView:sheet)
    }
    
    //Obtain mobile verification code
    func getsmsValidCode(){
        var type = EXSendVerificationCode.b2caddbank
        if self.type == .editor{
            type = EXSendVerificationCode.b2ceditbank
        }
        appApi.rx.request(.getsmsValidCode(token: XUserDefault.getToken() ?? "", operationType: type, countryCode: "", mobile: "")).MJObjectMap(EXVoidModel.self).subscribe(onSuccess: { (m) in
        }) { (erro) in
            
            }.disposed(by: disposeBag)
    }
    
    func models()->[EXOldInputSheetModel] {
        var models : [EXOldInputSheetModel] = []
        if UserInfoEntity.sharedInstance().isOpenMobileCheck != "0"{//mobile phone
            let model = EXOldInputSheetModel.setModel(withTitle:UserInfoEntity.sharedInstance().mobileNumber,key:"mobile",placeHolder: "personal_tip_inputPhoneCode".localized(), type: .sms , keyBoard : .numberPad)
            models.append(model)
        }
        if UserInfoEntity.sharedInstance().googleStatus != "0"{//Google
            let model = EXOldInputSheetModel.setModel(withTitle:"personal_text_googleCode".localized(),key:"googleCode",placeHolder: "common_tip_googleAuth".localized(), type: .paste, keyBoard : .numberPad)
            models.append(model)
        }
        return models
    }
    
    //Click on the add button
    @objc func clickAddBtn(){
        self.validation()
    }
    
    //Add Bank Card
    func addBank(_ mobile : String ,googleCode : String){
        let bankSub = tableViewRowDatas[3].text
        let cardNo = tableViewRowDatas[4].text
        let name = tableViewRowDatas[5].text
        appApi.rx.request(AppAPIEndPoint.addUserBank(bankId: model.bankNo, bankSub: bankSub, cardNo: cardNo, name: name, symbol: symbol, smsAuthCode: mobile, googleCode: googleCode)).MJObjectMap(EXBaseModel.self).subscribe(onSuccess: {[weak self] (model) in
            EXAlert.showSuccess(msg: "common_tip_addSuccess".localized())
            self?.needContentBlock?()
            self?.yy_viewController?.navigationController?.popViewController(animated: true)
        }) { (error) in
            
        }.disposed(by: disposeBag)
    }
    
    //Edit Bank Card
    func edtiBank(_ mobile : String ,googleCode : String){
        let bankSub = tableViewRowDatas[3].text
        let cardNo = tableViewRowDatas[4].text
        let name = tableViewRowDatas[5].text
        appApi.rx.request(AppAPIEndPoint.editUserBank(id : self.id,bankId: model.bankNo, bankSub: bankSub, cardNo: cardNo, name: name, symbol: symbol, smsAuthCode: mobile, googleCode: googleCode)).MJObjectMap(EXBaseModel.self).subscribe(onSuccess: {[weak self] (model) in
            EXAlert.showSuccess(msg: "b2c_text_editSuccess".localized())
            self?.needContentBlock?()
            self?.yy_viewController?.navigationController?.popViewController(animated: true)
        }) { (error) in
            
            }.disposed(by: disposeBag)
    }
    
    func dealEditorBtn(){
        var editor = true
        for entity in tableViewRowDatas{
            if entity.text == ""{
                editor = false
                break
            }
        }
        addBtn.isEnabled = editor
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension EXBtoCwithDrawAddAccountV : UITableViewDataSource,UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 73
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewRowDatas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let entity = tableViewRowDatas[indexPath.row]
        let cell : EXBtoCwithDrawAddAccountTC = tableView.dequeueReusableCell(withIdentifier: "EXBtoCwithDrawAddAccountTC") as! EXBtoCwithDrawAddAccountTC
        cell.setCell(entity)
        cell.tag = 1000 + indexPath.row
        cell.clickSelectFieldBlock = {[weak self]tag in
            guard let mySelf = self else{return}
            let vc = EXBtoCBankListVC()
            vc.selectModel = mySelf.selectModel
            vc.tableViewRowDatas = mySelf.tableViewBankRowDatas
            vc.clickCellBlock = {[weak self]model in
                self?.selectModel = model
                self?.selectorModelTransferModel()
                self?.setData()
            }
            self?.yy_viewController?.navigationController?.pushViewController(vc, animated: true)
        }
        cell.inputITextBlock = {[weak self](tag , str) in
            guard let mySelf = self else{return}
            mySelf.tableViewRowDatas[tag].text = str
            mySelf.dealEditorBtn()
        }
        return cell
    }
    
}

