//
//  SecuritySettingVC.swift
//  AppProject
//
//  Created by zewu wang on 2018/8/6.
//  Copyright © 2018年 zewu wang. All rights reserved.
//security setting

import UIKit

class SecuritySettingVC: NavCustomVC {

    let vm = SecuritySettingVM()
    
    var tableNames : [String] = [LanguageTools.getString(key: "mobile"),LanguageTools.getString(key: "email"),LanguageTools.getString(key: "google_verification"),LanguageTools.getString(key: "title_change_pwd"),LanguageTools.getString(key: "gesture_pass")]
    
    var tableViewRowDatas : [SecurityBaseEntity] = []
    
    lazy var tableView : UITableView = {
        let tableV = UITableView()
        tableV.extUseAutoLayout()
        tableV.delegate = self
        tableV.dataSource = self
        tableV.separatorStyle = .none
        tableV.backgroundColor = UIColor.ThemeView.bg
        tableV.register(SecurityTC.classForCoder(), forCellReuseIdentifier: "SecurityTC")
        tableV.extRegistCell([SecurityNextTC.classForCoder()], ["SecurityNextTC"])
        tableV.register(SecuritySwitchTC.classForCoder(), forCellReuseIdentifier: "SecuritySwitchTC")
        return tableV
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if PublicInfoEntity.sharedInstance.haveOTC == "1"{
             tableNames = [LanguageTools.getString(key: "mobile"),LanguageTools.getString(key: "email"),LanguageTools.getString(key: "google_verification"),LanguageTools.getString(key: "title_change_pwd"),LanguageTools.getString(key: "funds_pass"),LanguageTools.getString(key: "gesture_pass")]
        }
        
        FingerPrintVerify.fingerIsSupportCallBack { (type) in
            
            if type == "1" {
                self.tableNames.append(LanguageTools.getString(key: "faceId_login"))

            }else if type == "2"{
                self.tableNames.append(LanguageTools.getString(key: "touchid_login"))

            }
            self.setDatas()
            
            self.tableView.reloadData()
        }
        
        // Do any additional setup after loading the view.
        contentView.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    override func setNavCustomV() {
        self.setTitle(LanguageTools.getString(key: "safe_setting"))
    }
    
    var alert = UIAlertWithCodeView()
    
    override func setDatas() {
        var array : [SecurityBaseEntity] = []
        for item in tableNames{
            var entity = SecurityBaseEntity()
            switch item{
            case LanguageTools.getString(key: "mobile"):
                entity = SecurityEntity()
                if UserInfoEntity.sharedInstance().mobileNumber != ""{
                    if UserInfoEntity.sharedInstance().isOpenMobileCheck == "1"{
                        (entity as? SecurityEntity)?.oneBtn = LanguageTools.getString(key: "close_verify")
                    }else{
                        (entity as? SecurityEntity)?.oneBtn = LanguageTools.getString(key: "open_cert")
                    }
                    (entity as? SecurityEntity)?.twoBtn = LanguageTools.getString(key: "title_rebind_phone")
                }
            case LanguageTools.getString(key: "email"):
                entity = SecurityEntity()
                if UserInfoEntity.sharedInstance().email != ""{
                    (entity as? SecurityEntity)?.oneBtn = LanguageTools.getString(key: "title_rebind_email")
                }
            case LanguageTools.getString(key: "google_verification"):
                entity = SecurityEntity()
                if UserInfoEntity.sharedInstance().googleStatus == "1"{
                    (entity as? SecurityEntity)?.oneBtn = LanguageTools.getString(key: "close_verify")
                }
            case LanguageTools.getString(key: "title_change_pwd"):
                entity = SecurityBaseEntity()
            case LanguageTools.getString(key: "gesture_pass"):
                entity = SecuritySwitchEntity()
            case LanguageTools.getString(key: "touchid_login"):
                entity = SecuritySwitchEntity()
            case LanguageTools.getString(key: "faceId_login"):
                entity = SecuritySwitchEntity()
            case LanguageTools.getString(key: "funds_pass"):
                entity = SecurityEntity()
                if UserInfoEntity.sharedInstance().isCapitalPwordSet == "0"{
                    
                    (entity as? SecurityEntity)?.oneBtn = LanguageTools.getString(key: "otc_not_set")  
                }else{
                    (entity as? SecurityEntity)?.oneBtn = LanguageTools.getString(key: "reset")

                }
            default:
                break
            }
            entity.name = item
            entity.defaule = LanguageTools.getString(key: "not_open")
            array.append(entity)
        }
        tableViewRowDatas = array
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setDatas()
        tableView.reloadData()
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension SecuritySettingVC : UITableViewDelegate , UITableViewDataSource{
    
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = PersonlInformationBottomView()
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 120
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewRowDatas.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 49
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let entity = tableViewRowDatas[indexPath.row]
        switch entity.name {
        case LanguageTools.getString(key: "mobile"),LanguageTools.getString(key: "email"),LanguageTools.getString(key: "google_verification"):
            let cell : SecurityTC = tableView.dequeueReusableCell(withIdentifier: "SecurityTC") as! SecurityTC
            cell.tag = indexPath.row + 1000
            if let item = entity as? SecurityEntity{
                cell.setCell(item)
                cell.clickBtnBlock = {[weak self](btnTag , cellTag,name) in
                    guard let mySelf = self else{return}
                    if cellTag == 1000{//mobile phone
                        if btnTag == 1000{//Turn off validation
                            mySelf.clickCloseMoblie()
                        }else{//Modify phone
                            mySelf.clickChangeMoblie()

                        }
                    }else if cellTag == 1001{//mailbox
                        if btnTag == 1000{//Modify email
                            mySelf.changeEmail()
                        }
                    }else if cellTag == 1002{//google
                        if btnTag == 1000{//Turn off validation
                            mySelf.clickCloseGoogle()
                        }
                    }
                    if name == LanguageTools.getString(key: "otc_not_set") || name == LanguageTools.getString(key: "reset"){
                        
                        let vc = OTCMoneyPWDVC()
                    mySelf.navigationController?.pushViewController(vc, animated: true)

                    }
                }
            }
            return cell
        case LanguageTools.getString(key: "title_change_pwd"):
            let cell : SecurityNextTC = tableView.dequeueReusableCell(withIdentifier: "SecurityNextTC") as! SecurityNextTC
            cell.setCell(entity)
            return cell
        case LanguageTools.getString(key: "gesture_pass"):
            let cell : SecuritySwitchTC = tableView.dequeueReusableCell(withIdentifier: "SecuritySwitchTC") as! SecuritySwitchTC
            if let item = entity as? SecuritySwitchEntity{
                item.switchType = XUserDefault.getGesturesPassword() == nil ? "" : "1"
                cell.setCell(item)
                cell.clickSwitchBlock = {[weak self](cellSwitch)in
                    guard let mySelf = self else {
                        return
                    }
                    mySelf.cellSwitch(cellSwitch, "0")
                }
            }
            return cell
        case LanguageTools.getString(key: "touchid_login"),LanguageTools.getString(key: "faceId_login"):
            let cell : SecuritySwitchTC = tableView.dequeueReusableCell(withIdentifier: "SecuritySwitchTC") as! SecuritySwitchTC
            if let item = entity as? SecuritySwitchEntity{
                item.switchType = XUserDefault.getFaceIdOrTouchIdPassword() == "" ? "" : "1"
                FingerPrintVerify.fingerIsSupportCallBack { (type) in
                    if type == "1"{
                        item.name = LanguageTools.getString(key: "touchid_login")

                    }else if type == "2"{
                        item.name = LanguageTools.getString(key: "faceId_login")
                    }
                    cell.setCell(item)

                }
                cell.clickSwitchBlock = {[weak self](cellSwitch)in
                    guard let mySelf = self else {
                        return
                    }
                    mySelf.cellSwitch(cellSwitch, "1")
                }
            }
            return cell
        case LanguageTools.getString(key: "funds_pass"):
            let cell : SecurityTC = tableView.dequeueReusableCell(withIdentifier: "SecurityTC") as! SecurityTC
            if let item = entity as? SecurityEntity{
                cell.setCell(item)
            }
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    //Sending gesture verification code for the first time
    func sendGestData(_ param : [String : Any] ){
        var params : [String : Any] = [:]
        let entity = UserInfoEntity.sharedInstance()
        params["uid"] = entity.uid
        
        
        vm.sendGestDatas(params).asObservable().subscribe(onNext: {[weak self] (dict) in
            guard let mySelf = self else{return}
            if let data = dict["data"] as? [String : Any]{
                if let token = data["token"] as? String{
                    mySelf.alert.removeFromSuperview()
                    mySelf.gotoGestView(token)
                }
            }
        }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
    }
    
    //Cancel gesture
    func cancelGestData(_ param : [String : Any]){
        vm.cancelGestData(param).subscribe(onNext: {[weak self] (dict) in
            guard let mySelf = self else{return}
            UserInfoEntity.sharedInstance().gesturePwd = ""
            UserInfoEntity.sharedInstance().reloadTmpDict("gesturePwd", value: UserInfoEntity.sharedInstance().gesturePwd)
            UserInfoEntity.setTmpDict()
            XUserDefault.removeKey(key: XUserDefault.gesturesPassword)
            mySelf.alert.removeFromSuperview()
        }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
    }
    
    //Turn off Google verification
    func closeGoogle(_ params: [String : Any], handle : @escaping (()->())){
        vm.closeGoogleValidation(params).asObservable().subscribe(onNext: {[weak self] (dict) in
            guard let mySelf = self else{return}
            UserInfoEntity.sharedInstance().googleStatus = "0"
            UserInfoEntity.sharedInstance().reloadTmpDict("googleStatus", value:  UserInfoEntity.sharedInstance().googleStatus)
            UserInfoEntity.setTmpDict()
            mySelf.setDatas()
            mySelf.tableView.reloadData()
            handle()
        }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
    }
    
    //Turn off mobile verification
    func closeMoblie(_ params: [String : Any], handle : @escaping (()->())){
        vm.closeMoblieValidation(params).asObservable().subscribe(onNext: {[weak self] (dict) in
            guard let mySelf = self else{return}
            UserInfoEntity.sharedInstance().isOpenMobileCheck = "0"
            UserInfoEntity.sharedInstance().reloadTmpDict("isOpenMobileCheck", value:  UserInfoEntity.sharedInstance().isOpenMobileCheck)
            UserInfoEntity.setTmpDict()
            mySelf.setDatas()
            mySelf.tableView.reloadData()
            handle()
        }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
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
            mySelf.navigationController?.pushViewController(twovc, animated: true)
        }
        self.navigationController?.pushViewController(onevc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let entity = tableViewRowDatas[indexPath.row]
        switch entity.name {
        case LanguageTools.getString(key: "mobile"):
            if UserInfoEntity.sharedInstance().mobileNumber == ""{
                let vc = UpdateMoblieVC()
                vc.setType(UpdateMoblieType.none)
                self.navigationController?.pushViewController(vc, animated: true)
            }
        case LanguageTools.getString(key: "email"):
            if UserInfoEntity.sharedInstance().email == ""{
                let vc = UpdateEmailVC()
                vc.setType(UpdateEmailType.none)
                self.navigationController?.pushViewController(vc, animated: true)
            }
        case LanguageTools.getString(key: "title_change_pwd"):
            let vc = ChangePasswordVC()
            if UserInfoEntity.sharedInstance().googleStatus == "1" && UserInfoEntity.sharedInstance().isOpenMobileCheck == "1"{
                vc.type = .googleAndMoblie
            }else if UserInfoEntity.sharedInstance().googleStatus == "1" && UserInfoEntity.sharedInstance().email != ""{
                vc.type = .googleEmail
            }else if UserInfoEntity.sharedInstance().googleStatus == "1"{
                vc.type = .google
            }else if UserInfoEntity.sharedInstance().isOpenMobileCheck == "1"{
                vc.type = .mobile
            }else{
                vc.type = .email
            }
            self.navigationController?.pushViewController(vc, animated: true)
        case LanguageTools.getString(key: "google_verification"):
            if UserInfoEntity.sharedInstance().googleStatus == "1"{
                
            }else{
                let vc = GoogleValidationVC()
                self.navigationController?.pushViewController(vc, animated: true)
            }
        case LanguageTools.getString(key: "funds_pass"):
            
            let vc = OTCMoneyPWDVC()
            self.navigationController?.pushViewController(vc, animated: true)

           
//            if UserInfoEntity.sharedInstance().googleStatus == "1"{
//
//            }else{
//            }
        default:
            break
        }
    }
    
}

extension SecuritySettingVC{
    
    //Click to turn off the phone or turn it on
    func clickCloseMoblie(){
        if UserInfoEntity.sharedInstance().googleStatus != "1"{
            ProgressHUDManager.showFailWithStatus(LanguageTools.getString(key: "toast_close_phone_verification"))
            return
        }
        if UserInfoEntity.sharedInstance().isOpenMobileCheck == "1"{//If the phone verification is enabled, it will be turned off, otherwise it will be turned on
            let alert = UIAlertMiddleTitleView()
            alert.middleTitleLabel.text = LanguageTools.getString(key: "dialog_verify_warn_text")
            alert.titleLabel.text = LanguageTools.getString(key: "title_dialog_close_mobile_verify")
            alert.clickConfirmBtnBlock = {[weak self]() in
                guard let mySelf = self else {
                    return
                }
                alert.removeFromSuperview()
                mySelf.confirmCloseMoblie("moblie")
            }
            alert.show(self.view)
        }else{
            vm.openMoblieValidation().asObservable().subscribe(onNext: {[weak self] (dict) in
                guard let mySelf = self else{return}
                UserInfoEntity.sharedInstance().isOpenMobileCheck = "1"
                UserInfoEntity.sharedInstance().reloadTmpDict("isOpenMobileCheck", value:  UserInfoEntity.sharedInstance().isOpenMobileCheck)
                UserInfoEntity.setTmpDict()
                mySelf.setDatas()
                mySelf.tableView.reloadData()
            }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
        }
    }
    
    //Confirm turning off phone and Google verification
    func confirmCloseMoblie(_ type : String){
        let alert = UIAlertWithCodeView()
        alert.alertWith(LanguageTools.getString(key: "hint_certification_code"), cellTitles: [("", "") , ("","")], cellPrompts: [LanguageTools.getString(key: "hint_certification_code_mobile") , LanguageTools.getString(key: "hint_google_certification_code")], cellshowMessageBtn: [true,false])
//        if alert.tableView.visibleCells.count > 1{
//            if let cell = alert.tableView.visibleCells[1] as? UIAlertTC{
//                cell.codeTextFiled.setattribute(false)
//            }
//        }
        alert.clickBtnBlock = {[weak self] (b , cells) in
            guard let mySelf = self else{return}
            if b == true{
                if cells[0].codeTextFiled.textfiled.text == ""{
                    ProgressHUDManager.showFailWithStatus(LanguageTools.getString(key: "toast_no_mobile_verification_code"))
                    return
                }
                if cells[1].codeTextFiled.textfiled.text == ""{
                    ProgressHUDManager.showFailWithStatus(LanguageTools.getString(key: "hint_google_certification_code"))
                    return
                }
                var params : [String : Any] = [:]
                params["smsValidCode"] = cells[0].codeTextFiled.textfiled.text
                params["googleCode"] = cells[1].codeTextFiled.textfiled.text
                if type == "moblie"{
                    mySelf.closeMoblie(params,handle : alert.removeFromSuperview)
                }else if type == "google"{
                    mySelf.closeGoogle(params,handle: alert.removeFromSuperview)
                }
            }
        }
        alert.clickCellBtnBlock = {[weak self](index,cells) in
            guard let mySelf = self else{return}
            if index == 0{
                SendVerificationCode().requestCode(["operationType" : "27"]).asObservable().subscribe(onNext: { (i ) in
                    if cells.count > index{
                        cells[index].codeTextFiled.clickGetMessageBtn()
                    }
                }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: mySelf.disposeBag)
//                    .subscribe(onNext: nil, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: mySelf.disposeBag)
            }
        }
        alert.show(self.view)
    }
    
    //Click to modify the phone
    func clickChangeMoblie(){
        let vc = UpdateMoblieVC()
        vc.setType(UpdateMoblieType.original)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    //Click to close Google
    func clickCloseGoogle(){
        if UserInfoEntity.sharedInstance().isOpenMobileCheck != "1"{
            ProgressHUDManager.showFailWithStatus(LanguageTools.getString(key: "toast_close_google_verification"))
            return
        }
        let alert = UIAlertMiddleTitleView()
        alert.middleTitleLabel.text = LanguageTools.getString(key: "dialog_verify_warn_text")
        alert.titleLabel.text = LanguageTools.getString(key: "title_dialog_close_google_verify")
        alert.clickConfirmBtnBlock = {[weak self]() in
            guard let mySelf = self else {
                return
            }
            alert.removeFromSuperview()
            mySelf.confirmCloseMoblie("google")
        }
        alert.show(self.view)
    }
    
    //Click to modify email
    func changeEmail(){
        let vc = UpdateEmailVC()
        vc.setType(UpdateEmailType.original)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    //Click on cellswitch type 0 gesture 1 touch or face id
    func cellSwitch(_ cellSwitch : Bool,_ type:NSString){
        
        if type == "1"{
            
            
            if  XUserDefault.getGesturesPassword() != nil{
                
                ProgressHUDManager.showFailWithStatus(LanguageTools.getString(key: "only_set_one_login_way"))

                self.tableView.reloadData()
                
                return ;
            }
            
            if XUserDefault.getFaceIdOrTouchIdPassword() != ""{
                self.changeFaceIdOrTouchId("0")
            }else{
               
                self.changeFaceIdOrTouchId("1")
                
            }
            


           
       
        }else{
            
            if  XUserDefault.getFaceIdOrTouchIdPassword() != ""{
                
                ProgressHUDManager.showFailWithStatus(LanguageTools.getString(key: "only_set_one_login_way"))
                self.tableView.reloadData()

                return


            }

        
        let alert = UIAlertWithCodeView()
        let googleStatus = UserInfoEntity.sharedInstance().googleStatus
        let isOpenMobileCheck = UserInfoEntity.sharedInstance().isOpenMobileCheck
        if googleStatus == "1" && isOpenMobileCheck == "1"{
            alert.alertWith(LanguageTools.getString(key: "safe_setting"), cellTitles: [("", "") , ("","") , ("","")], cellPrompts: [LanguageTools.getString(key: "login_pass") ,LanguageTools.getString(key: "toast_no_mobile_code"),LanguageTools.getString(key: "toast_no_google_code")], cellshowMessageBtn: [false , true , false])
//            if alert.tableView.visibleCells.count > 2{
//                if let cell = alert.tableView.visibleCells[2] as? UIAlertTC{
//                    cell.codeTextFiled.setattribute(false)
//                }
//            }
        }else if googleStatus == "1"{
            alert.alertWith(LanguageTools.getString(key: "safe_setting"), cellTitles: [("", "") , ("","")], cellPrompts: [LanguageTools.getString(key: "login_pass") ,LanguageTools.getString(key: "toast_no_google_code")], cellshowMessageBtn: [false , false])
//            if alert.tableView.visibleCells.count > 1{
//                if let cell = alert.tableView.visibleCells[1] as? UIAlertTC{
//                    cell.codeTextFiled.setattribute(false)
//                }
//            }
        }else if isOpenMobileCheck == "1"{
            alert.alertWith(LanguageTools.getString(key: "safe_setting"), cellTitles: [("", "") , ("","") ], cellPrompts: [LanguageTools.getString(key: "login_pass") ,LanguageTools.getString(key: "toast_no_mobile_code")], cellshowMessageBtn: [false , true])
        }else{
            alert.alertWith(LanguageTools.getString(key: "safe_setting"), cellTitles: [("", "")], cellPrompts: [LanguageTools.getString(key: "login_pass")], cellshowMessageBtn: [false])
        }
        alert.clickBtnBlock = {(b , cells) in
            if b == true{
NSLog ("Set gesture password")
                var param : [String : Any] = [:]
                if cells[0].pwTextFiled.textfiled.text == ""{
                    ProgressHUDManager.showFailWithStatus(LanguageTools.getString(key: "hint_input_login_pass"))
                    return
                }
                param["loginPwd"] = cells[0].pwTextFiled.textfiled.text
                if cells.count > 1{
                    
                    
                    if googleStatus == "1" && isOpenMobileCheck == "1"{
                        if cells[1].codeTextFiled.textfiled.text == ""{
                            ProgressHUDManager.showFailWithStatus(LanguageTools.getString(key: "toast_no_mobile_verification_code"))
                            return
                        }
                        if cells[2].codeTextFiled.textfiled.text == ""{
                            ProgressHUDManager.showFailWithStatus(LanguageTools.getString(key: "hint_google_certification_code"))
                            return
                        }
                        param["smsValidCode"] = cells[1].codeTextFiled.textfiled.text
                        param["googleCode"] = cells[2].codeTextFiled.textfiled.text
                    }else if isOpenMobileCheck == "1"{
                        if cells[1].codeTextFiled.textfiled.text == ""{
                            ProgressHUDManager.showFailWithStatus(LanguageTools.getString(key: "toast_no_mobile_verification_code"))
                            return
                        }
                        param["smsValidCode"] = cells[1].codeTextFiled.textfiled.text
                    }else if googleStatus == "1"{
                        if cells[1].codeTextFiled.textfiled.text == ""{
                            ProgressHUDManager.showFailWithStatus(LanguageTools.getString(key: "hint_google_certification_code"))
                            return
                        }
                        param["googleCode"] = cells[1].codeTextFiled.textfiled.text
                    }
                }
                if cellSwitch == true{
                    self.sendGestData(param)
                }else{
                    self.cancelGestData(param)
                }
            }else{
                self.setDatas()
                self.tableView.reloadData()
            }
        }
        alert.clickCellBtnBlock = {(index,cells) in
            if index == 1{
                SendVerificationCode().requestCode(["operationType" : "27"]).asObservable().subscribe(onNext: { (i) in
                    if cells.count > index{
                        cells[index].codeTextFiled.clickGetMessageBtn()
                    }
                }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: self.disposeBag)
//                    .subscribe(onNext: nil, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: self.disposeBag)
            }
        }
        alert.show(self.view)
        self.alert = alert
        }
    }
    
    
    func changeFaceIdOrTouchId(_ open:String) {
        
        if let v = PwdView.newShare(){
            
            v.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT)
            self.view.addSubview(v)
            
            v.back = {(t,pwd) in
                v.removeFromSuperview()

                if t == "1"{
                    self.tableView.reloadData()
                }else{
                    
                    var params : [String : Any] = [:]
                    let entity = UserInfoEntity.sharedInstance()
                    params["uid"] = entity.uid
                    
                    params["nativePwd"] = pwd
                    
                    let param = NetManager.sharedInstance.handleParamter(params)
                    
                    let url = NetManager.sharedInstance.url(NetDefine.http_host_url, model: NetDefine.pwd_same, action: "")
                    NetManager.sharedInstance.sendRequest(url,parameters : param,isShowLoading
                        :false, success: { (result, response, entity) in
                        
                        if let result = result as? [String : Any]{
                            
                            guard let data = result["data"] as? [String:Any] else {return}
                            
                            if let isPass = data["isPass"] as? Int{
                                if Int(isPass) == 1{
                                    
                                    if open == "1"{
                                        
FingerPrintVerify. fingerPrintLocalAuthenticationFallBackTitle (LanguageTools. getString (key: "Quick Login"), localizedReason: LanguageTools. getString (key: "Quick Login")) {(success, error, alert) in
                                            if success == true{
                                                XUserDefault.setFaceIdOrTouchId("100")

                                            }
                                            
                                        ProgressHUDManager.showFailWithStatus(alert ?? "")
                                            
                                            self.tableView.reloadData()

                                        }
                                        
                                    }
                                    else{
                                        XUserDefault.setFaceIdOrTouchId("")
                                        
                                    }
                                    
                                }
                                else{
                                    XUserDefault.setFaceIdOrTouchId("")
                                    
                                }
                            }else{
                                XUserDefault.setFaceIdOrTouchId("")
                                
                            }
                            
                        }else{
                            XUserDefault.setFaceIdOrTouchId("")
                            
                        }
                        
                        self.tableView.reloadData()
                    }, fail: { (state, error, any) in
                        XUserDefault.setFaceIdOrTouchId("")
                        
                        self.tableView.reloadData()
                        
                    })
                    
                }
            }
        }
        
       
        
        
    }
    
    
}

