//
//  EXSendRedPacketView.swift
//  Chainup
//
//  Created by zewu wang on 2023/6/29.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit
enum EXSendRedPacketType {
    case normal//ordinary
    case spellLuck//Fight for luck
}

class EXSendRedPacketView: UIView {
    
    var redPakcetPublicInfoEntity = EXRedPakcetPublicInfoEntity()
    {
        didSet{
            
        }
    }
    
    var entity = EXRedPakcetPublicInfoManagerEntity()
    
    var createEntity = EXCreateRedPacketEntity()
    
    var type = EXSendRedPacketType.normal
    {
        didSet{
            self.setType()
        }
    }
    
     var bindType : [String] = []
    
    var outOrderId = ""
    
    lazy var scrollView : UIScrollView = {
        let view = UIScrollView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT - 108))
        view.contentSize = CGSize.init(width: SCREEN_WIDTH, height: SCREEN_HEIGHT - 108)
        return view
    }()
    
    lazy var backView : UIView = {
        let view = UIView()
        view.frame = CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT - 108)
        view.backgroundColor = UIColor.clear
        return view
    }()
    
    //currency
    lazy var coinTextField : EXSelectionField = {
        let textField = EXSelectionField()
        textField.extUseAutoLayout()
        textField.enableTitleModel = true
        textField.setTitle(title: "redpacket_send_currency".localized())
        textField.setPlaceHolder(placeHolder: "redpacket_send_inputCoin".localized())
        textField.textfieldValueChangeBlock = {[weak self]str in
            self?.observerBtn()
        }
        textField.textfieldDidTapBlock = {[weak self] in
            self?.showCoin()
        }
        return textField
    }()
    
    //Total amount or individual amount
    lazy var totalAmountTextField : EXTextField = {
        let textField = EXTextField()
        textField.enableTitleModel = true
        textField.setPlaceHolder(placeHolder: "redpacket_send_inputAmount".localized())
        textField.input.keyboardType = UIKeyboardType.decimalPad
        textField.textfieldValueChangeBlock = {[weak self]str in
            self?.observerBtn()
            self?.setTotalLabel()
        }
        return textField
    }()
    
    //Available balance
    lazy var availableLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.font = UIFont.ThemeFont.SecondaryBold
        label.textColor = UIColor.ThemeLabel.colorMedium
        return label
    }()
    
    //Number of red envelopes
    lazy var numTextField : EXTextField = {
        let text = EXTextField()
        text.extUseAutoLayout()
        text.enableTitleModel = true
        text.setTitle(title: "redpacket_send_num".localized())
        text.setPlaceHolder(placeHolder: "redpacket_send_enterNumber".localized())
        text.input.keyboardType = UIKeyboardType.numberPad
        text.textfieldValueChangeBlock = {[weak self]str in
            self?.observerBtn()
            self?.setTotalLabel()
        }
        return text
    }()
    
    //If the total amount is due to a lack of effort, it will not be displayed
    lazy var totalAmountLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.font = UIFont.ThemeFont.SecondaryRegular
        label.textColor = UIColor.ThemeLabel.colorMedium
        return label
    }()
    
    //Blessing Words
    lazy var wishTextField : EXTextField = {
        let text = EXTextField()
        text.extUseAutoLayout()
        text.enableTitleModel = true
        text.setTitle(title: "redpacket_send_wishes".localized())
        text.input.rx.text.orEmpty.asObservable().subscribe({ (event) in
            if let str = event.element{
                if str.count > 25{
                    text.input.text = str[0..<25]
                }
            }
        }).disposed(by: self.disposeBag)
        return text
    }()
    
    //Select button
    lazy var chooseBtn : UIButton = {
        let btn = UIButton()
        btn.extUseAutoLayout()
        btn.setEnlargeEdgeWithTop(10, left: 10, bottom: 10, right: 10)
        btn.extSetAddTarget(self, #selector(clickChooseBtn))
        btn.setImage(UIImage.themeImageNamed(imageName: "public_unselected_square"), for: UIControl.State.normal)
        let selectedImg = EXKitBundle.svgImage(named: "public_selected_square")
        btn.setImage(selectedImg, for: UIControl.State.selected)
        return btn
    }()
    
    //prompt
    lazy var promptLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.font = UIFont.ThemeFont.SecondaryRegular
        label.textColor = UIColor.ThemeLabel.colorMedium
        label.text = "redpacket_send_new".localized()
        return label
    }()
    
    //Send button
    lazy var sendBtn : EXButton = {
        let btn = EXButton()
        btn.extUseAutoLayout()
        btn.extSetCornerRadius(4)
        btn.color = UIColor.ThemeRedPacket.normalRed
        btn.backgroundColor = UIColor.ThemeRedPacket.normalRed
        btn.setTitle("redpacket_send_prepare".localized(), for: UIControl.State.normal)
        btn.titleLabel?.font = UIFont.ThemeFont.HeadBold
        btn.isEnabled = false
        btn.extSetAddTarget(self, #selector(clickSendBtn))
        return btn
    }()
    
    //Refund reminder
    lazy var refundPromptLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.textColor = UIColor.ThemeLabel.colorMedium
        label.textAlignment = .center
        label.font = UIFont.ThemeFont.SecondaryRegular
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubViews([scrollView])
        scrollView.addSubview(backView)
        self.setAvailableLabel("--")
        self.setTotalLabel()
        backView.addSubViews([coinTextField,totalAmountTextField,availableLabel,numTextField,totalAmountLabel,wishTextField,chooseBtn,promptLabel,sendBtn,refundPromptLabel])
        coinTextField.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.top.equalToSuperview().offset(15)
        }
        totalAmountTextField.snp.makeConstraints { (make) in
            make.left.right.equalTo(coinTextField)
            make.top.equalTo(coinTextField.snp.bottom).offset(20)
        }
        availableLabel.snp.makeConstraints { (make) in
            make.left.equalTo(coinTextField)
            make.height.equalTo(17)
            make.top.equalTo(totalAmountTextField.snp.bottom).offset(8)
        }
        numTextField.snp.makeConstraints { (make) in
            make.left.right.equalTo(coinTextField)
            make.top.equalTo(availableLabel.snp.bottom).offset(20)
        }
        totalAmountLabel.snp.makeConstraints { (make) in
            make.left.right.equalTo(coinTextField)
            make.height.equalTo(17)
            make.top.equalTo(numTextField.snp.bottom).offset(8)
        }
        wishTextField.snp.makeConstraints { (make) in
            make.left.right.equalTo(coinTextField)
            make.top.equalTo(totalAmountLabel.snp.bottom).offset(20)
        }
        if SCREEN_HEIGHT > 568{
            chooseBtn.snp.makeConstraints { (make) in
                make.height.width.equalTo(12)
                make.bottom.equalTo(sendBtn.snp.top).offset(-12)
                make.left.equalToSuperview().offset(15)
            }
            promptLabel.snp.makeConstraints { (make) in
                make.centerY.equalTo(chooseBtn)
                make.height.equalTo(17)
                make.left.equalTo(chooseBtn.snp.right).offset(5)
                make.right.equalToSuperview()
            }
            sendBtn.snp.makeConstraints { (make) in
                make.height.equalTo(44)
                make.left.equalToSuperview().offset(15)
                make.right.equalToSuperview().offset(-15)
                make.bottom.equalTo(refundPromptLabel.snp.top).offset(-10)
            }
            refundPromptLabel.snp.makeConstraints { (make) in
                make.bottom.equalToSuperview().offset(-30 - TABBAR_BOTTOM)
                make.height.equalTo(17)
                make.left.right.equalToSuperview()
            }
        }else{
            chooseBtn.snp.makeConstraints { (make) in
                make.height.width.equalTo(12)
                make.top.equalTo(wishTextField.snp.bottom).offset(100)
                make.left.equalToSuperview().offset(15)
            }
            promptLabel.snp.makeConstraints { (make) in
                make.centerY.equalTo(chooseBtn)
                make.height.equalTo(17)
                make.left.equalTo(chooseBtn.snp.right).offset(5)
                make.right.equalToSuperview()
            }
            sendBtn.snp.makeConstraints { (make) in
                make.height.equalTo(44)
                make.left.equalToSuperview().offset(15)
                make.right.equalToSuperview().offset(-15)
                make.top.equalTo(chooseBtn.snp.bottom).offset(12)
            }
            refundPromptLabel.snp.makeConstraints { (make) in
                make.top.equalTo(sendBtn.snp.bottom).offset(10)
                make.height.equalTo(17)
                make.left.right.equalToSuperview()
            }
        }
        
        if UserInfoEntity.sharedInstance().isOpenMobileCheck == "1"{
            bindType.append("2")
        }
        if UserInfoEntity.sharedInstance().googleStatus == "1"{
            bindType.append("1")
        }
    }
    
    func setType(){
        switch type {
        case .normal:
            if SCREEN_HEIGHT <= 568{
                backView.frame = CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height: 338 + 100 + 12 + 44 + 12 + 17 + 10 + 30)
                scrollView.contentSize = CGSize.init(width: SCREEN_WIDTH, height: 338 + 100 + 12 + 44 + 12 + 17 + 10 + 30)
            }
            totalAmountTextField.setTitle(title: "redpacket_send_each".localized())
            break
        case .spellLuck:
            if SCREEN_HEIGHT <= 568{
                backView.frame = CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height: 316 + 100 + 12 + 44 + 12 + 17 + 10 + 30)
                scrollView.contentSize = CGSize.init(width: SCREEN_WIDTH, height: 316 + 100 + 12 + 44 + 12 + 17 + 10 + 30)
            }
            totalAmountLabel.isHidden = true
            wishTextField.snp.remakeConstraints { (make) in
                make.left.right.equalTo(coinTextField)
                make.top.equalTo(numTextField.snp.bottom).offset(20)
            }
            totalAmountTextField.setTitle(title: "redpacket_send_total".localized())
        default:
            break
        }
    }
    
    func setView(_ entity : EXRedPakcetPublicInfoManagerEntity){
        coinTextField.input.text = entity.coinSymbol.aliasName()
        self.wishTextField.setPlaceHolder(placeHolder: self.redPakcetPublicInfoEntity.defaultTip)
        self.entity = entity
        setAvailableLabel(entity.fmsAmount() + entity.coinSymbol.aliasName())
        setPrompt(entity.expiredHour)
        totalAmountTextField.setExtraText(entity.coinSymbol.aliasName())
        totalAmountTextField.decimal = "\(entity.precision)"
    }
    
    //Set available balance
    func setAvailableLabel(_ text : String){
        availableLabel.text = "redpacket_send_availableBalance".localized() + " " + text
    }
    
    //Set total amount
    func setTotalLabel(){
        if type == .normal{
            guard let num = numTextField.input.text else{return}
            guard let amount = totalAmountTextField.input.text else{return}
            if num == "" || amount == ""{
                 totalAmountLabel.text = "redpacket_send_total".localized() + " --"
            }else{
                if let text = (num as NSString).multiplying(by: amount, decimals: entity.precision){
                    totalAmountLabel.text = "redpacket_send_total".localized() + " " + text + entity.coinSymbol.aliasName()
                }
            }
        }
    }
    
    func setPrompt(_ str : String){
        refundPromptLabel.text = String.init(format: "redpacket_send_prompt".localized(), str)
    }
    
    func reloadView(){
        let entity = EXRedPakcetPublicInfo.sharedInstance.getRedPacket(self.entity.coinSymbol)
        self.setView(entity)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension EXSendRedPacketView{
    
    //Pop up currency display
    func showCoin(){
        let showCoin = EXRedPacketChooseCoinView()
        if type == .normal{
            showCoin.rowDatas = EXRedPakcetPublicInfo.sharedInstance.getAllNormal()
        }else{
            showCoin.rowDatas = EXRedPakcetPublicInfo.sharedInstance.getAllSpellLuck()
        }
        showCoin.clickConfirmBlock = {[weak self]entity in
            self?.entity = entity
            self?.setView(entity)
            EXAlert.dismiss()
        }
        showCoin.clickCancelBlock = {() in
            EXAlert.dismiss()
        }
        EXAlert.showSheet(sheetView: showCoin)
    }
    
    func observerBtn(){
        if coinTextField.input.text != "",totalAmountTextField.input.text != "" , numTextField.input.text != ""{
            sendBtn.isEnabled = true
        }else{
            sendBtn.isEnabled = false
        }
    }
    
    //Click on the selection button
    @objc func clickChooseBtn(_ btn : UIButton){
        btn.isSelected = !btn.isSelected
    }
    
    //Click on the send button
    @objc func clickSendBtn(){
        
        if limitParameter() == false{
            return
        }
        
        let payConfirmAlert = EXConfirmPayAlert()
        payConfirmAlert.configAlert(title: "redpacket_payment_payment".localized(),
                                    message:"",
                                    confirmPayInfo: self.getPayConfirmAlertInfo(),
                                    passiveBtnTitle: "common_text_btnCancel".localized(),
                                    positiveBtnTitle: "common_text_btnConfirm".localized()
        )
        payConfirmAlert.alertCallback = { [weak self] idx in
            guard let `self` = self else { return }
            if idx == 0 {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.4, execute: {
                    //Click to confirm
                    self.createRedPacket()
                })
            }
        }
        EXAlert.showAlert(alertView: payConfirmAlert)
        
    }
    
    //Restriction parameters
    func limitParameter() -> Bool{
        if totalAmountTextField.input.text == ""{
            EXAlert.showFail(msg: "redpacket_send_inputAmount".localized())
            return false
        }
        if numTextField.input.text == ""{
            EXAlert.showFail(msg: "redpacket_send_enterNumber".localized())
            return false
        }
        if let num = Int(numTextField.input.text ?? "0") , num == 0{
            EXAlert.showFail(msg: "redpacket_send_enterNumber".localized())
            return false
        }
        guard let amount = totalAmountTextField.input.text else{return false}
        guard let num = numTextField.input.text else{return false}
        guard let div = (amount as NSString).dividing(by: num, decimals: self.entity.precision) else{return false}//Divisor
        guard let mul = (amount as NSString).multiplying(by: num, decimals: self.entity.precision) else{return false}//multiplier
        guard let max = (entity.singleAmountMax as NSString).multiplying(by: num, decimals: 18) else{return false}//Maximum allowable red envelope
        
        if let poor = (self.entity.singleCountMax as NSString).subtracting(num, decimals: self.entity.precision),poor.contains("-"){
            EXAlert.showFail(msg: "redpacket_send_numNotExceed".localized() + entity.singleCountMax)
            return false
        }
        
        if type == .normal{//1. Compare the input quantity with the minimum quantity for regular red envelopes. 2. Multiply the input quantity by the number and compare it with the maximum limit and user balance
            if let poor = (self.entity.amount as NSString).subtracting(mul, decimals: self.entity.precision),poor.contains("-"){
                EXAlert.showFail(msg: "redpacket_send_noMoney".localized())
                return false
            }
            if let poor = (max as NSString).subtracting(mul, decimals: self.entity.precision),poor.contains("-"){
                EXAlert.showFail(msg: "redpacket_send_notExceed".localized() + max + entity.coinSymbol.aliasName())
                return false
            }
            if let poor = (mul as NSString).subtracting(self.entity.singleAmountMin, decimals: self.entity.precision),poor.contains("-"){
                EXAlert.showFail(msg: "redpacket_send_notLess".localized() + entity.singleAmountMin + entity.coinSymbol.aliasName())
                return false
            }
            if let poor = (entity.singleAmountMax as NSString).subtracting(amount, decimals: self.entity.precision),poor.contains("-"){
                EXAlert.showFail(msg: "redpacket_send_singleNotExceed".localized() + entity.singleAmountMax + entity.coinSymbol.aliasName())
                return false
            }
            if let poor = (amount as NSString).subtracting(self.entity.singleAmountMin, decimals: self.entity.precision),poor.contains("-"){
                EXAlert.showFail(msg: "redpacket_send_notLess".localized() + entity.singleAmountMin + entity.coinSymbol.aliasName())
                return false
            }
        }else{//1. To compete for luck, you need to divide the input amount by the quantity and compare it with the minimum quantity. 2. Directly compare the input quantity with the maximum limit and user balance
            if let poor = (self.entity.amount as NSString).subtracting(amount, decimals: self.entity.precision),poor.contains("-"){
                EXAlert.showFail(msg: "redpacket_send_noMoney".localized())
                return false
            }
            if let poor = (max as NSString).subtracting(amount, decimals: self.entity.precision),poor.contains("-"){
                EXAlert.showFail(msg: "redpacket_send_notExceed".localized() + max + entity.coinSymbol.aliasName())
                return false
            }
            if let poor = (amount as NSString).subtracting(self.entity.singleAmountMin, decimals: self.entity.precision),poor.contains("-"){
                EXAlert.showFail(msg: "redpacket_send_notLess".localized() + entity.singleAmountMin + entity.coinSymbol.aliasName())
                return false
            }
            if let poor = (entity.singleAmountMax as NSString).subtracting(div, decimals: self.entity.precision),poor.contains("-"){
                EXAlert.showFail(msg: "redpacket_send_singleNotExceed".localized() + entity.singleAmountMax + entity.coinSymbol.aliasName())
                return false
            }
            if let poor = (div as NSString).subtracting(self.entity.singleAmountMin, decimals: self.entity.precision),poor.contains("-"){
                EXAlert.showFail(msg: "redpacket_send_notLess".localized() + entity.singleAmountMin + entity.coinSymbol.aliasName())
                return false
            }
        }
        
        return true
    }
    
    //Display red envelopes
    func showRedPacketView(){
        let redPacketDetailView = EXRedPacketDetailView()
        redPacketDetailView.setView(self.createEntity)
        redPacketDetailView.shareSuccessBlock = {[weak self] in
            guard let mySelf = self else{return}
            let vc = EXSendOutRedPacketDetailVC()
            vc.mainView.packetSn = mySelf.outOrderId
            self?.yy_viewController?.navigationController?.pushViewController(vc, animated: true)
        }
        redPacketDetailView.show(self.yy_viewController!)
    }
    
    //Pop up verification box
    func showGoogle(_ entity : EXCreateRedPacketEntity , total : String){
        let sheet = EXOldActionSheetView()
        sheet.configTextfields(title: "common_text_safetyAuth".localized(), itemModels:self.models())
        sheet.actionFormCallback = {[weak self] formDic in
            guard let mySelf = self else{return}
            var googleCode = ""//Google verification code
            var smsAuthCode = ""//Mobile verification code
            if mySelf.bindType.contains("1"){
                if let google = formDic["googleCode"]{
                    googleCode = google
                }
                if googleCode == ""{
                    EXAlert.showFail(msg: LanguageTools.getString(key: "common_tip_googleAuth".localized()))
                    return
                }
            }
            if mySelf.bindType.contains("2"){
                if let moblie = formDic["moblie"]{
                    smsAuthCode = moblie
                }
                if smsAuthCode == ""{
                    EXAlert.showFail(msg: LanguageTools.getString(key: "personal_tip_inputPhoneCode".localized()))
                    return
                }
            }
            if entity.isVersion2 == "1" {
                mySelf.newVersionToPay(entity, googleCode: googleCode, smsAuthCode: smsAuthCode, total: total)
            }else {
                mySelf.toPayUrl(entity , googleCode : googleCode,smsAuthCode: smsAuthCode,total : total)
            }
        }
        sheet.itemBtnCallback = {[weak self]key in
            guard let mySelf = self else{return}
            switch key {
            case "moblie":
                mySelf.getsmsValidCode()
                break
            default:
                break
            }
        }
        EXAlert.showSheet(sheetView:sheet)
    }
    
    //Obtain mobile verification code
    func getsmsValidCode(){
        appApi.rx.request(.getsmsValidCode(token: XUserDefault.getToken() ?? "", operationType: redPakcetPublicInfoEntity.operationType, countryCode: "", mobile: "")).MJObjectMap(EXVoidModel.self).subscribe(onSuccess: { (m) in
        }) { (erro) in
            
            }.disposed(by: disposeBag)
    }
    
    //Create a red envelope
    func createRedPacket(){
        let type = self.type == .normal ? "0" : "1"
        guard let amount = totalAmountTextField.input.text else{return}
        guard let num = numTextField.input.text else{return}
        guard let mul = (amount as NSString).multiplying(by: num, decimals: self.entity.precision) else{return}//multiplier
        let m = self.type == .normal ? mul : amount
        let onlyNew = chooseBtn.isSelected ? "1" : "0"
        redPacketApi.rx.request(RedPacketAPIEndPoint.createRedpacket(type: type, coinSymbol: self.entity.coinSymbol, amount: m, count: num, tip: wishTextField.input.text ?? "", onlyNew: onlyNew)).MJObjectMap(EXCreateRedPacketEntity.self).subscribe(onSuccess: {[weak self] (entity) in
            self?.createEntity = entity
            self?.showGoogle(entity ,total : m)
        }) { (error) in
            
        }.disposed(by: disposeBag)
    }
    
    //To pay
    func toPayUrl(_ entity : EXCreateRedPacketEntity , googleCode : String ,smsAuthCode : String, total : String){
        let url = entity.toPayUri
        var param : [String : Any] = [:]
        param["appKey"] = entity.appKey
        param["userId"] = entity.userId
        param["assetType"] = entity.assetType
        param["orderNum"] = entity.orderNum
        if googleCode != ""{
            param["googleCode"] = googleCode
        }
        if smsAuthCode != ""{
            param["smsAuthCode"] = smsAuthCode
        }
        redPacketApi.rx.request(RedPacketAPIEndPoint.toPayUrl(url: url, params: param)).MJObjectMap(EXPlatformPEntity.self).subscribe(onSuccess: {[weak self](entity) in
            guard let mySelf = self else{return}
            mySelf.outOrderId = entity.outOrderId
            mySelf.showRedPacketView()
            if let poor = (mySelf.entity.amount as NSString).subtracting(total, decimals: mySelf.entity.precision){
                EXRedPakcetPublicInfo.sharedInstance.setAmount(poor, coinSymbol: mySelf.entity.coinSymbol)
                mySelf.reloadView()
            }
        }) { (error) in
            
        }.disposed(by: disposeBag)
    }
    
    func newVersionToPay(_ entity : EXCreateRedPacketEntity , googleCode : String ,smsAuthCode : String, total : String){
        let orderNumber = entity.orderNum
        let googleauthCode = googleCode.isEmpty ? nil : googleCode
        let smsCode = smsAuthCode.isEmpty ? nil : smsAuthCode

        redPacketApi.rx.request(.newVersionToPay(orderNum: orderNumber, goolgeCode: googleauthCode, smsAuthCode: smsCode))
        .MJObjectMap(EXPlatformPEntity.self)
        .subscribe(onSuccess: {[weak self](entity) in
            guard let mySelf = self else{return}
            mySelf.outOrderId = entity.outOrderId
            mySelf.showRedPacketView()
            if let poor = (mySelf.entity.amount as NSString).subtracting(total, decimals: mySelf.entity.precision){
                EXRedPakcetPublicInfo.sharedInstance.setAmount(poor, coinSymbol: mySelf.entity.coinSymbol)
                mySelf.reloadView()
            }
        }) { (error) in
            
        }.disposed(by: disposeBag)
    }
    
    func models()->[EXOldInputSheetModel] {
        var models : [EXOldInputSheetModel] = []
        if bindType.contains("2"){//mobile phone
            let model = EXOldInputSheetModel.setModel(withTitle:UserInfoEntity.sharedInstance().mobileNumber,key:"moblie",placeHolder: "personal_tip_inputPhoneCode".localized(), type: .sms,keyBoard : .numberPad)
            models.append(model)
        }
        if bindType.contains("1"){//Google
            let model = EXOldInputSheetModel.setModel(withTitle:"personal_text_googleCode".localized(),key:"googleCode",placeHolder: "common_tip_googleAuth".localized(), type: .paste, keyBoard : .numberPad)
            models.append(model)
        }
        return models
    }
    
    func getPayConfirmAlertInfo() -> [EXConfirmPayAlertModel] {
        var confirmInfos:[EXConfirmPayAlertModel] = []
        
        guard let amount = totalAmountTextField.input.text else{return[]}
        guard let num = numTextField.input.text else{return[]}
        guard let mul = (amount as NSString).multiplying(by: num, decimals: self.entity.precision) else{return[]}//multiplier
        
        let model = EXConfirmPayAlertModel()
        model.title = "redpacket_payment_amount".localized()
        if type == .normal{
            model.value = mul + entity.coinSymbol.aliasName()//Total amount
        }else{
            model.value = amount + entity.coinSymbol.aliasName()//Total amount
        }
        model.valueColor = UIColor.ThemeRedPacket.text
        
        confirmInfos.append(model)
        let model2 = EXConfirmPayAlertModel()
        model2.title = "redpacket_payment_type".localized()
        model2.value = "redpacket_redpacket".localized()
        confirmInfos.append(model2)
        
        let model3 = EXConfirmPayAlertModel()
        model3.title = "redpacket_payment_account".localized()
        model3.value = "redpacket_send_exchangeAccount".localized()
        confirmInfos.append(model3)
        return confirmInfos
    }
    
}

