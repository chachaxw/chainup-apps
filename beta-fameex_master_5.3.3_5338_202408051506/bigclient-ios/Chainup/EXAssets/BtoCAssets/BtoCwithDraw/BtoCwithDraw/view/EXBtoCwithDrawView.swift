//
//  EXBtoCwithDrawView.swift
//  Chainup
//
//  Created by zewu wang on 2023/10/24.
//  Copyright © 2023 zewu wang. All rights reserved.
//Withdrawal of legal currency

import UIKit
import EXKit
class EXBtoCwithDrawView: UIView {
    
    var entity = B2CCoinMapItem()
    
    var withDrawEntity = EXBtoCwithDrawModel()
    
    var bankModel = EXBtoCwithDrawAccountListModel()
    
    lazy var footView : BtoCAnnouncementsView = {
        let view = BtoCAnnouncementsView()
        view.isHidden = true
        view.backgroundColor = UIColor.ThemeView.bg
        return view
    }()
    
    lazy var tableView : UITableView = {
        let tableView = UITableView.init(frame: CGRect.zero, style:UITableView.Style.grouped)
        tableView.extUseAutoLayout()
        tableView.extSetTableView(self, self)
        tableView.extRegistCell([EXBtoWithDrawCell.classForCoder()], ["EXBtoWithDrawCell"])
        tableView.estimatedSectionFooterHeight = 0.1
        return tableView
    }()
    
    lazy var backView : UIView = {
        let view = UIView()
        view.extUseAutoLayout()
        view.backgroundColor = UIColor.ThemeView.bg
        return view
    }()
    
    lazy var arrivalAmountTitleLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.text = "b2c_Arrive_Time".localized()
        label.textColor = UIColor.ThemeLabel.colorMedium
        label.font = UIFont.ThemeFont.BodyRegular
        return label
    }()
    
    lazy var arrivalAmountNumLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.textColor = UIColor.ThemeLabel.colorLite
        label.font = UIFont.ThemeFont.BodyBold
        label.layoutIfNeeded()
        label.text = "--"
        return label
    }()
    
    lazy var confirmBtn : EXButton = {
        let btn = EXButton()
        btn.extUseAutoLayout()
        btn.backgroundColor = UIColor.ThemeBtn.highlight
        btn.extSetCornerRadius(1.5)
        btn.setTitle("b2c_text_withdraw".localized(), for: UIControl.State.normal)
        btn.setTitleColor(UIColor.ThemeLabel.white, for: UIControl.State.normal)
        btn.titleLabel?.font = UIFont.ThemeFont.HeadBold
        btn.extSetAddTarget(self, #selector(clickConfirmBtn))
        btn.isEnabled = false
        return btn
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubViews([tableView,backView])
        backView.addSubViews([arrivalAmountTitleLabel,arrivalAmountNumLabel,confirmBtn])
        tableView.snp.makeConstraints { (make) in
            make.left.right.top.equalToSuperview()
            make.bottom.equalTo(backView.snp.top)
        }
        backView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(112)
        }
        arrivalAmountTitleLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.top.equalToSuperview().offset(10)
            make.height.equalTo(20)
            make.right.equalTo(arrivalAmountNumLabel.snp.left).offset(-10)
        }
        arrivalAmountNumLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(16)
            make.centerY.equalTo(arrivalAmountTitleLabel)
        }
        confirmBtn.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-30)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(44)
        }
    }
    
    //Click on the withdrawal button
    @objc func clickConfirmBtn(){
        if withDrawEntity.withdrawalAmount == ""{
            EXAlert.showFail(msg: "b2c_text_inputWithdrawAmount".localized())
            return
        }
        let withdrawalAmount = withDrawEntity.withdrawalAmount
        if (entity.withdrawMin as NSString).isBig(withdrawalAmount){
            EXAlert.showFail(msg: "b2c_text_amountNoLessthan".localized() + entity.withdrawMin + " " + entity.symbol)
            return
        }
        if (withdrawalAmount as NSString).isBig(entity.withdrawMax){
            EXAlert.showFail(msg: "b2c_text_amountNoGreaterthan".localized() + entity.withdrawMax + " " + entity.symbol)
            return
        }
        if (withdrawalAmount as NSString).isBig(entity.canWithdrawBalance){
            EXAlert.showFail(msg: "b2c_text_todaywithdraw".localized() + entity.canWithdrawBalance + " " + entity.symbol)
            return
        }
        if (withdrawalAmount as NSString).isBig(entity.normalBalance){
            EXAlert.showFail(msg: "b2c_text_availableBalance".localized() + entity.normalBalance + " " + entity.symbol)
            return
        }
        
        guard let vc = self.yy_viewController else{return}
        if EXOTCSafetyCheckVm.manager.checkWithDrawRequire(vc){
            validation()
        }
    }
    
    func setData(){
        withDrawEntity.coinSymbol = entity.symbol
        withDrawEntity.singleMin = entity.withdrawMin
        withDrawEntity.singleMax = entity.withdrawMax
        withDrawEntity.canAmount = entity.canWithdrawBalance
        withDrawEntity.canuseAmount = entity.normalBalance
        tableView.reloadData()
    }
    
    func getFiltBlance(){
        appApi.rx.request(.b2cBalance(symbol: entity.symbol))
            .MJObjectMap(EXB2CAccountListModel.self)
            .subscribe(onSuccess: {[weak self] (model) in
                if model.allCoinMap.count > 0{
                    self?.entity = model.allCoinMap[0]
                }
                if model.withdrawTip != ""{
                    self?.footView.isHidden = false
                    self?.footView.setView(model.withdrawTip)
                }else{
                    self?.footView.isHidden = true
                }
                self?.setData()
            }) { (error) in
                
        }.disposed(by: disposeBag)
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
                self?.fiatWithdraw(mobile, googleCode: googleCode)
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
        appApi.rx.request(.getsmsValidCode(token: XUserDefault.getToken() ?? "", operationType: EXSendVerificationCode.b2cwithDraw, countryCode: "", mobile: "")).MJObjectMap(EXVoidModel.self).subscribe(onSuccess: { (m) in
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
    
    func fiatWithdraw(_ smsAuthCode : String , googleCode : String){
        appApi.rx.request(AppAPIEndPoint.fiatWithdraw(symbol: entity.symbol, userWithdrawBankId: bankModel.id, amount: withDrawEntity.withdrawalAmount, smsAuthCode: smsAuthCode, googleCode: googleCode)).MJObjectMap(EXBaseModel.self).subscribe(onSuccess: {[weak self] (model) in
            EXAlert.showSuccess(msg: "b2c_text_withdrawSuccess".localized())
            self?.yy_viewController?.navigationController?.popViewController(animated: true)
        }) { (error) in
            
        }.disposed(by: disposeBag)
    }
    
    //Handling handling fees and amount received
    func dealFee(){
        if bankModel.feeType != ""{
            //Handling rate
            if bankModel.feeType == "1"{
                if let f = Double(bankModel.fee){
                    let percent = f / 100
                    
                    if let poundage = (withDrawEntity.withdrawalAmount as NSString).multiplying(by: "\(percent)", decimals:Int(entity.showPrecision) ?? 2){
                        withDrawEntity.poundage = poundage
                    }
                    if let cell = tableView.cellForRow(at: IndexPath.init(row: 0, section: 0)) as? EXBtoWithDrawCell{
                        cell.setCell(withDrawEntity, coinmapEntity: entity)
                    }
                }
                //Handling fees
            }else{
                withDrawEntity.poundage = bankModel.fee
            }
            //Received amount
            if withDrawEntity.withdrawalAmount != "" && withDrawEntity.poundage != ""{
                if let toaccountNum = (withDrawEntity.withdrawalAmount as NSString).subtracting(withDrawEntity.poundage, decimals: Int(entity.showPrecision) ?? 2){
                    arrivalAmountNumLabel.text = toaccountNum + entity.symbol
                }
            }else{
                arrivalAmountNumLabel.text = "--"
            }
        }else{//If not
            withDrawEntity.poundage = ""
            arrivalAmountNumLabel.text = "--"
        }
    }
    
    //Processing button
    func decideConfirmBtn(){
        if withDrawEntity.withdrawalAmount == "" || bankModel.id == ""{
            confirmBtn.isEnabled = false
            return
        }
        confirmBtn.isEnabled = true
    }
    
    func reloadBank(_ entity : EXBtoCwithDrawAccountListModel){
        self.bankModel = entity
        if entity.id == ""{
            self.withDrawEntity.account = ""
        }else{
            self.withDrawEntity.account = entity.bankName + "_" + "**" + entity.showCardNo
        }
        self.dealFee()
        self.decideConfirmBtn()
        tableView.reloadData()
    }
    
    func getUserBank(){
        appApi.rx.request(AppAPIEndPoint.getUserBank(id: self.bankModel.id)).MJObjectMap(EXBtoCwithDrawAccountListModel.self,false).subscribe(onSuccess: {[weak self] (model) in
            if model.id != ""{
                self?.reloadBank(model)
            }else{
                self?.reloadBank(EXBtoCwithDrawAccountListModel())
            }
        }) {[weak self] (error) in
            self?.reloadBank(EXBtoCwithDrawAccountListModel())
        }.disposed(by: disposeBag)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension EXBtoCwithDrawView : UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return footView
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 378
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : EXBtoWithDrawCell = tableView.dequeueReusableCell(withIdentifier: "EXBtoWithDrawCell") as! EXBtoWithDrawCell
        cell.setCell(withDrawEntity, coinmapEntity: entity)
        cell.chooseCoinView.clickBtoCCellBlock = {[weak self] in
            let searchVc = EXCoinSearchListVc.instanceFromStoryboard(name: StoryBoardNameAsset)
            searchVc.subsetCoinAccountType = .b2c
            searchVc.b2cOnEntityCallback = {[weak self] model in
                self?.entity = model
                self?.getFiltBlance()
            }
            searchVc.sourceType = .sourceForWithdraw
            searchVc.needPush = true
            self?.yy_viewController?.navigationController?.pushViewController(searchVc, animated: true)
        }
        cell.withDrawCoinView.withDrawCoinWriteBlock = {[weak self]str in
            self?.withDrawEntity.withdrawalAmount = str
            self?.dealFee()
            self?.decideConfirmBtn()
        }
        cell.chooseAccountView.clickAccountBlock = {[weak self] in
            guard let mySelf = self else{return}
            let vc = EXBtoCwithDrawAccountListVC()
            vc.mainView.entity = mySelf.entity
            vc.mainView.clickCellBlock = {[weak self]entity in
                self?.bankModel.id = entity.id
                self?.getUserBank()
            }
            self?.yy_viewController?.navigationController?.pushViewController(vc, animated: true)
        }
        return cell
    }
}


