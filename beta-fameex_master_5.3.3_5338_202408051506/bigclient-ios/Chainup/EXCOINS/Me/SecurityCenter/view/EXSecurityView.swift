//
//  EXSecurityView.swift
//  Chainup
//
//  Created by zewu wang on 2023/3/27.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import RxSwift
import EXKit
class EXSecurityProgressView: EXView{
    lazy var nameLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.text = "personal_Center_text7".localized()
        label.font = UIFont.Ex.medium(18)
        label.textColor = UIColor.Ex.text1
        return label
    }()
    lazy var levelLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.text = "x".localized()
        label.font = UIFont.Ex.medium(20)
        label.textColor = UIColor.ThemeState.fail
        return label
    }()
    
    
    lazy var progress: UIProgressView = {
        
        let progressView = UIProgressView(progressViewStyle: .default)
//        progressView.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 40)
//        progressView.layer.position = CGPoint(x: self.view.frame.width/2, y: 90)
//        progressView.setProgress(0.3, animated: true)
        progressView.progressTintColor =  UIColor.ThemeState.fail//UIColor.green //Progress Color
//        UIColor.ThemeState.success
//        UIColor.ThemeView.yellow
        progressView.trackTintColor =  UIColor.ThemeView.seperator //Remaining progress color
        //By changing the height of the Progress bar (the width remains the same, and the height becomes twice the default)
//        progressView.transform = CGAffineTransform(scaleX: 1.0, y: 2.0)
       return progressView
    }()
    
    override func setupView() {
        self.addSubViews([nameLabel,levelLabel,progress])
        nameLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(25)
            make.height.equalTo(21)
        }
        levelLabel.snp.makeConstraints  { make in
            make.left.equalTo(nameLabel.snp.right).offset(8)
            make.centerY.equalTo(nameLabel)
        }
        
        progress.snp.makeConstraints  { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(16)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(3)
        }
    }
    
    
    func updatelevel(level: Int){
        var color =  UIColor.ThemeState.fail//
        var des = "personal_Center_text29".localized()
        switch level{
        case 1:
            break
        case 2:
            des = "personal_Center_text28".localized()
            color = UIColor.ThemeView.yellow
        case 3:
            des = "personal_Center_text27".localized()
            color = UIColor.ThemeState.success
        default:
            break
        }
        
        levelLabel.text = des
        levelLabel.textColor = color
        let p:Float = Float(level) /  3.0
        self.progress.setProgress(p, animated: false)
        self.progress.progressTintColor = color
       
    }
    
    
}
class EXSecurityView: UIView {
    
    let vm = EXOTCSafetyCheckVm()
    
    var tableViewNameDatas : [String] = [
        LanguageTools.getString(key: "register_text_phone"),
        LanguageTools.getString(key: "register_text_mail"),
        LanguageTools.getString(key: "title_google_verified"),
        LanguageTools.getString(key: "otc_text_pwd"),
        "safety_withdrawalWhitelist".localized(),
        LanguageTools.getString(key: "login_text_gesture")
    ]
    var tableViewRowDatas : [EXSecurityEntity] = []
    lazy var header: EXSecurityProgressView = {
        let v = EXSecurityProgressView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 86))
        
       return v
    }()
    lazy var tableView : UITableView = {
        let tableView = UITableView()
        tableView.extUseAutoLayout()
        tableView.extSetTableView(self, self)
        tableView.extRegistCell([EXSecurityTC.classForCoder(),UITableViewCell.classForCoder()], ["EXSecurityTC","UITableViewCell"])
        tableView.tableHeaderView = header
        tableView.estimatedRowHeight = 52
        return tableView
    }()
    
    var touchOrFace = "1"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        if EXAppConfigManager.sharedInstance.didOpenFiat() {
            tableViewNameDatas = [
                LanguageTools.getString(key: "register_text_phone"),
                LanguageTools.getString(key: "register_text_mail"),
                LanguageTools.getString(key: "title_google_verified"),
                LanguageTools.getString(key: "register_text_loginPwd"),
                LanguageTools.getString(key: "otc_text_pwd"),
                "safety_withdrawalWhitelist".localized(),
                LanguageTools.getString(key: "login_text_gesture")]
        }
        
        FingerPrintVerify.fingerIsSupportCallBack1 {[weak self] (type) in
            if type == "1" {
                self?.touchOrFace = "1"
                self?.tableViewNameDatas.append(LanguageTools.getString(key: "login_text_fingerprint"))
            }else if type == "2"{
                self?.touchOrFace = "2"
                self?.tableViewNameDatas.append(LanguageTools.getString(key: "login_text_face"))
            }
            self?.setData()
        }
    
    }
    
    
    func updateSafeLevel(){
        var temp = [Int]()
        if UserInfoEntity.sharedInstance().email != "" {
            temp.append(1)
        }
        if UserInfoEntity.sharedInstance().googleStatus == "1"{
            temp.append(1)
        }
        if UserInfoEntity.sharedInstance().isOpenMobileCheck == "1"{
            temp.append(1)
        }
        if temp.count == 0 {
            temp.append(1) //When none is turned on, default to a lower level
        }
        self.header.updatelevel(level: temp.count)
    }
    
    func addDelteAccount(){
        tableViewNameDatas.append("account_destory_text1".localized())
        setData()
    }
    func setData(){
      
        var arr : [EXSecurityEntity] = []
        for str in tableViewNameDatas{
            let entity = EXSecurityEntity()
            entity.name = str
            switch str{
            case "safety_withdrawalWhitelist".localized():
                entity.type = .whiteList
                entity.desc = "safety_withdrawalWhitelist_tips".localized()
                entity.switchOn = UserInfoEntity.sharedInstance().withdrawWhitelistFlag == "1"
            case LanguageTools.getString(key: "register_text_phone"):
                if UserInfoEntity.sharedInstance().mobileNumber != ""{
                    if UserInfoEntity.sharedInstance().isOpenMobileCheck == "1"{
                        entity.info = LanguageTools.getString(key: "personal_text_safeSettingOpen")
                    }else{
                        entity.info = LanguageTools.getString(key: "personal_text_safeSettingOff")
                    }
                }else{
                    entity.info = LanguageTools.getString(key: "userinfo_text_mailUnbind")
                }
                entity.type = .phone
            case LanguageTools.getString(key: "register_text_mail"):
                entity.type = .mail
                if UserInfoEntity.sharedInstance().email != ""{
                    entity.info = LanguageTools.getString(key: "common_action_edit")
                }else{
                    entity.info = LanguageTools.getString(key: "userinfo_text_mailUnbind")
                }
               
            case LanguageTools.getString(key: "title_google_verified"):
                entity.type = .gooleAuth
                if UserInfoEntity.sharedInstance().googleStatus == "1"{
                    entity.info = LanguageTools.getString(key: "personal_text_safeSettingOpen")
                }else{
                    entity.info = LanguageTools.getString(key: "userinfo_text_mailUnbind")
                }
            case LanguageTools.getString(key: "register_text_loginPwd"):
                entity.type = .loginPassWord
                entity.info = LanguageTools.getString(key: "common_action_edit")
            case LanguageTools.getString(key: "otc_text_pwd"):
                entity.type = .moneyPassWord
                if UserInfoEntity.sharedInstance().isCapitalPwordSet == "0"{
                    entity.info = LanguageTools.getString(key: "safety_fundsPass_notSet".localized())//Not set
                }else{
                    entity.info = LanguageTools.getString(key: "common_action_edit")
                    entity.showUnbind = true
                }
            case LanguageTools.getString(key: "login_text_gesture"):
                entity.type = .gestureLogin
                if XUserDefault.getGesturesPassword() != nil{
                    entity.switchOn = true
                }else{
                    entity.switchOn = false
                }
            case LanguageTools.getString(key: "login_text_fingerprint") , LanguageTools.getString(key: "login_text_face"):
                entity.type = .FingerprintOrFaceLogin
                if XUserDefault.getFaceIdOrTouchIdPassword() != ""{
                    entity.switchOn = true
                }else{
                    entity.switchOn = false
                }
            case "account_destory_text1".localized():
                //MARK: fix
                entity.info = "   "
                entity.type = .acountDelete
            default:
                break
            }
            arr.append(entity)
        }
        self.tableViewRowDatas = arr
        self.tableView.reloadData()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension EXSecurityView : UITableViewDelegate , UITableViewDataSource{
    
  
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewRowDatas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let entity = tableViewRowDatas[indexPath.row]
        let cell : EXSecurityTC = tableView.dequeueReusableCell(withIdentifier: "EXSecurityTC") as! EXSecurityTC
        cell.tag = 1000 + indexPath.row
        cell.setCell(entity)
        cell.onFundPasswordCallback = { [weak self] index in
            guard let `self` = self else { return }
            if index == 0 { //unblind
                self.exalertOTCPW(unBlind: true)
            }else{
                self.exalertOTCPW(unBlind: false)
            }
            
        }
        cell.onValueChangeCallback = {[weak self](b , entity) in
            guard let mySelf = self else{return}
            mySelf.switchV(b, entity: entity,indexPath: indexPath)
        }
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let entity = tableViewRowDatas[indexPath.row]
        switch entity.type{
        case .phone:
            if UserInfoEntity.sharedInstance().mobileNumber == ""{//Unbound to enter the binding page
                let vc = EXMoblieBindingVC()
                vc.clickBlock = {[weak self] in
                    let vc = EXGoogleBindingVC()
                    self?.yy_viewController?.navigationController?.pushViewController(vc, animated: true)
                }
                self.yy_viewController?.navigationController?.pushViewController(vc, animated: true)
            }else{//Bound to enter the set binding page
                let vc = EXMoblieOneVC()
                self.yy_viewController?.navigationController?.pushViewController(vc, animated: true)
            }
            break
        case .mail:
            let vc = EXEmailBindingVC()
            self.exalertsecuritySheet(vc,type: .mail)

            break
        case .gooleAuth:
            if UserInfoEntity.sharedInstance().googleStatus == "0"{//Unbound to enter the binding page
                let vc = EXGoogleBindingVC()
                self.yy_viewController?.navigationController?.pushViewController(vc, animated: true)
            }else{//Bound to enter the settings page
                let vc = EXGoogleOpenVC()
                self.yy_viewController?.navigationController?.pushViewController(vc, animated: true)
            }
            break
        case .loginPassWord:
            //If neither of them is turned on
            if UserInfoEntity.sharedInstance().isOpenMobileCheck == "0" && UserInfoEntity.sharedInstance().googleStatus == "0"{
                EXAlert.showFail(msg: "common_text_pleaseBindGoogleFirst".localized())
                return
            }
           self.exalertsecuritySheet(EXChangePWVC(),type: .loginPassWord)
        case .moneyPassWord:
            self.exalertOTCPW(unBlind: false)
            break
        case .gestureLogin:
            break
        case .acountDelete:
            let vc = EXAccountDeleteController()
            self.yy_viewController?.navigationController?.pushViewController(vc, animated: true)
        default:
            break
        }
    }
}

extension EXSecurityView{
    
    //Display prompts for modifying the legal currency password
    func exalertOTCPW(unBlind: Bool){
        let vc = EXChangeOTCPWVC()
        if UserInfoEntity.sharedInstance().isCapitalPwordSet == "0"{
            vc.type = .fundPasswordSet
            self.yy_viewController?.navigationController?.pushViewController(vc, animated: true)
            return
        }else{
            vc.type = .fundPasswordModify
        }
        let hour = EXAppConfigManager.sharedInstance.getUpdateWithDrawHour()
        alert(hour: hour, vc: vc,unbind: unBlind)
    }
    
    //Prompt user for 48 hours modifLoginPwd to change password
    func exalertsecuritySheet(_ vc : UIViewController, type: EXSecurityEntityTyep){
        //If the background is enabled
      if type == .mail{
            if UserInfoEntity.sharedInstance().email == "" {
                //Jump directly without setting a pop-up box
                self.yy_viewController?.navigationController?.pushViewController(vc, animated: true)
                return
            }
        }
        if type == .moneyPassWord{
            if UserInfoEntity.sharedInstance().isCapitalPwordSet == "0"{
                self.yy_viewController?.navigationController?.pushViewController(vc, animated: true)
                return
            }
        }
        let hour = EXAppConfigManager.sharedInstance.getUpdateWithDrawHour()
        alert(hour: hour, vc: vc)
        
    }
    func alert(hour: String,vc : UIViewController, unbind: Bool? = false){
        let alert = EXCommonAlert()
        var message = String(format:"login_tip_safeSettingChange".localized(),hour)
        if let newUnbind = unbind,newUnbind == true{
            message = String(format:"fundsPass_unbindConfirm".localized(),hour)
        }
        
        alert.configAlert(tipImage: nil,
                          title: message,
                          message: nil,
                          cancelBtnTitle:LanguageTools.getString(key: "common_text_btnCancel"),
                          sureBtnTitle:  LanguageTools.getString(key: "personal_Center_text32"),
                          btnLayoutStyle: .horizontal, alertCallBack: { type in
            if type == .sure{
                if let newUnbind = unbind,newUnbind == true{
                    self.safeCheck(type: .fundPasswordUnbind)
                    return
                }
                self.yy_viewController?.navigationController?.pushViewController(vc, animated: true)
            }
            
        })
        //show
        EXAlert.showAlert(alertView: alert,backgroundColor: UIColor.themeColor(keyPath:view_mask_key).withAlphaComponent(0.6))
        
    }
    func switchV(_ b : Bool , entity : EXSecurityEntity,indexPath: IndexPath){
        let cell = tableView.cellForRow(at: indexPath) as? EXSecurityTC
        switch entity.type{
        case .gestureLogin:
            if b == true,XUserDefault.getFaceIdOrTouchIdPassword() != ""{//Activate gesture
                EXAlert.showFail(msg: LanguageTools.getString(key: "login_tip_otherFastLoginIsActive"))
                entity.switchOn = false
                
                cell?.setCell(entity)
                
//                self.tableView.reloadData()
                return
            }
            gesturesValidation(entity: entity, cell: cell)
        case .FingerprintOrFaceLogin:
            if b == true ,XUserDefault.getGesturesPassword() != nil{//Turn on fingerprints and face
                EXAlert.showFail(msg: LanguageTools.getString(key: "login_tip_otherFastLoginIsActive"))
                entity.switchOn = false
                cell?.setCell(entity)
//                self.tableView.reloadData()
                return
            }
            faceortouchValidation(openFace: b,entity: entity,cell: cell)
        case .whiteList:
            entity.switchOn = b
            print("entity.switchOn = \(entity.switchOn)")
            
            let type = b ? EXSafetyCheckType.whiteListOpen : EXSafetyCheckType.whiteListClose
            self.safeCheck(type: type,open: b)
        default:
            break
        }
    }
   
    //Secondary verification of gestures
    func gesturesValidation(entity : EXSecurityEntity, cell: EXSecurityTC?){
        let sheet = EXOldActionSheetView()
        sheet.configTextfields(title: "common_text_safetyAuth".localized(), itemModels:self.models())
        sheet.autoDismiss = false
        sheet.actionFormCallback = {[weak self] formDic in
            guard let mySelf = self else{return}
            var googleCode = ""//Google verification code
            var mobile = ""//Mobile number verification
            var password = ""//Login password
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
            
            if let pw = formDic["password"]{
                password = pw
            }
            if password == ""{
                EXAlert.showFail(msg: LanguageTools.getString(key: "common_tip_inputLoginPwd"))
                return
            }
            
            if XUserDefault.getGesturesPassword() != nil{//Turn off gesture verification
                appApi.rx.request(AppAPIEndPoint.closeGesture(loginPwd: password, smsValidCode: mobile, googleCode: googleCode)).MJObjectMap(EXVoidModel.self).subscribe(onSuccess: { (model) in
                    EXAlert.showSuccess(msg: "login_tip_gestureClosed".localized())
                    XUserDefault.setGesturesPassword("")
                    UserInfoEntity.sharedInstance().gesturePwd = ""
//                    mySelf.setData()
                    entity.switchOn = false
                    cell?.setCell(entity)
                    sheet.dismiss()
                }, onError: { (error) in
                    
                }).disposed(by: mySelf.disposeBag)
            }else{//Turn on gesture verification
                appApi.rx.request(AppAPIEndPoint.openGesture(loginPwd: password, smsValidCode: mobile, googleCode: googleCode, uid: UserInfoEntity.sharedInstance().uid)).MJObjectMap(EXGuestureEntity.self).subscribe(onSuccess: { (model) in
                    let token = model.token
                    mySelf.gotoGestView(token)
                    sheet.dismiss()
                }, onError: { (error) in
                    
                }).disposed(by: mySelf.disposeBag)
            }
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
        sheet.actionCancelCallback = {[weak self]() in
//            self?.setData()
            cell?.setCell(entity)
        }
        EXAlert.showSheet(sheetView:sheet)
        
    }
    
    func models()->[EXOldInputSheetModel] {
        var models : [EXOldInputSheetModel] = []
        let model1 = EXOldInputSheetModel.setModel(withTitle:LanguageTools.getString(key: "register_text_loginPwd"),key:"password",placeHolder: "register_tip_inputPassword".localized(), type: .input , privacyMode : true)
        models.append(model1)
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
    
    //Facial and fingerprint secondary authentication
    func faceortouchValidation(openFace: Bool,entity : EXSecurityEntity, cell: EXSecurityTC?){
        FingerPrintVerify.fingerPrintLocalAuthenticationFallBackTitle(LanguageTools.getString(key: "login_action_oneClick"), localizedReason: LanguageTools.getString(key: "login_action_oneClick")) { (success, error, alert) in
            if success == true{
                var faceId = openFace ? "100" : ""
                XUserDefault.setFaceIdOrTouchId(faceId)
                entity.switchOn = openFace
                cell?.entity = entity
//                EXAlert.showSuccess(msg: alert ?? "")
            }else{
//                XUserDefault.setFaceIdOrTouchId("")
                EXAlert.showFail(msg: alert ?? "")
            }
//            self.setData()
          
        }
    }
    
    func facemodels()->[EXOldInputSheetModel] {
        var models : [EXOldInputSheetModel] = []
        let model1 = EXOldInputSheetModel.setModel(withTitle:LanguageTools.getString(key: "register_text_loginPwd"),key:"password",placeHolder: "register_tip_inputPassword".localized(), type: .input , privacyMode : true)
        models.append(model1)
        return models
    }
    
    //Obtain mobile verification code
    func getsmsValidCode(){
        appApi.rx.request(.getsmsValidCode(token: XUserDefault.getToken() ?? "", operationType: EXSendVerificationCode.closegoogleAndmoblie, countryCode: "", mobile: "")).MJObjectMap(EXVoidModel.self).subscribe(onSuccess: { (m) in
        }) { (erro) in
            
            }.disposed(by: disposeBag)
    }
    
    //Enter the gesture password setting page
    func gotoGestView(_ token : String){
        let onevc = GestureValidationVC()
        onevc.type = GestureValidationType.input
        onevc.gesToken = token
        onevc.confirmGesturesBlock = {[weak self](password) in
            guard let mySelf = self else{return}
            let twovc = GestureValidationVC()
            twovc.type = GestureValidationType.EnterAgain
            twovc.code = password
            twovc.gesToken = token
            onevc.popBack(false)
            mySelf.yy_viewController?.navigationController?.pushViewController(twovc, animated: true)
        }
        self.yy_viewController?.navigationController?.pushViewController(onevc, animated: true)
    }
    
    func safeCheck(type: EXSafetyCheckType,open: Bool? = nil){
        let manger = EXComSafeVaildManger()
        manger.safeCheck = type
        manger.startSafeAlert()
        manger.resultCallBack = { [weak self] result in
            guard let `self` = self else { return }
            self.submit(result: result,type: type,open: open)
        }
        manger.actionCancelCallback = { [weak self] in
            guard let `self` = self else { return }
            if type == .whiteListOpen || type == .whiteListClose{
                self.resetListCell(type: .whiteList)
            }
        }
    }
    
    //reset
    func resetListCell(type: EXSecurityEntityTyep){
        var desIndex: Int?
        for (index,item) in tableViewRowDatas.enumerated(){
            if item.type == type{
                desIndex = index
            }
        }
        if desIndex == nil {
            return
        }
        let indexPath = IndexPath(row: desIndex!, section: 0)
        if let cell = tableView.cellForRow(at: indexPath) as? EXSecurityTC{
            if type == .whiteList {
                let info = cell.entity
                info.switchOn = !info.switchOn
                cell.setCell(info)
            }else if type == .moneyPassWord{
                let entity = cell.entity
                if UserInfoEntity.sharedInstance().isCapitalPwordSet == "0"{
                    entity.info = LanguageTools.getString(key: "safety_fundsPass_notSet".localized())//Not set
                    entity.showUnbind = false
                }else{
                    entity.info = LanguageTools.getString(key: "common_action_edit")
                    entity.showUnbind = true
                }
                cell.setCell(entity)
            }
        }
    }
    
    func submit(result: EXCodeResult, type: EXSafetyCheckType,open: Bool? = nil){
        if type == .fundPasswordUnbind {
            otcApi.rx.request(.capitalPasswordUnbinding(smsAuthCode: result.phoneCode, emailAuthCode: result.emailCode, googleCode: result.googleCode)).MJObjectMap(EXVoidModel.self).subscribe(onSuccess: { (model) in
                UserInfoEntity.sharedInstance().isCapitalPwordSet = "0"
                UserInfoEntity.setTmpDict()
                EXAlert.showSuccess(msg: "Success".localized())
                
                self.resetListCell(type: .moneyPassWord)
               
            }, onFailure: { (error) in

            }).disposed(by: self.disposeBag)
        }else if type == .whiteListOpen || type == .whiteListClose{
            let status = open! ? "1" : "0"
            otcApi.rx.request(.whiteListSwitch(smsAuthCode: result.phoneCode, googleCode: result.googleCode, emailAuthCode: result.emailCode, status: status)).MJObjectMap(EXVoidModel.self).subscribe(onSuccess: { [weak self] (model) in
                guard let `self` = self else { return }
                UserInfoEntity.sharedInstance().withdrawWhitelistFlag =  open! ? "1" : "0"
                UserInfoEntity.setTmpDict()
                EXAlert.showSuccess(msg: "Success".localized())
            }, onFailure: { [weak self]  (error) in
                guard let `self` = self else { return }
                self.resetListCell(type: .whiteList)
            }).disposed(by: self.disposeBag)
            
        }
        

    }
    
    
}

