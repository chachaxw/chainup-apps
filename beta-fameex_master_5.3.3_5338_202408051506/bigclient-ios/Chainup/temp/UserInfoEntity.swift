//
//  UserInfoEntity.swift
//  Chainup
//
//  Created by zewu wang on 2023/8/10.
//  Copyright © 2023年 zewu wang. All rights reserved.
//

import UIKit
import RxSwift
import EXKit
import Swap
/**
*Certification type
*Certification status 0. Under review, 1. Passed, 2. Not passed, 3. Not certified
 */
enum UserAuthLevel:String {
    case pending = "0"
    case pass = "1"
    case reject = "2"
    case newbie = "3"
}

class UserInfoEntity: SuperEntity {
    
    static var entity : UserInfoEntity?
    public class func sharedInstance() -> UserInfoEntity{
        if entity == nil{
            let e = UserInfoEntity()
            
            entity = e
        }
        return entity!
    }

    static var userSymbolsVm = UserSymbolsVM()
    
    var feeCoinRate = ""
    var agentStatus = ""//Broker level
    var uid = ""
    
    var myMarket = ""
    
    var mobileNumber = ""
    
    var isOpenMobileCheck = "0"//Whether the phone is turned on or not, verify that 0 is not turned on
    
    var accountStatus = ""
    var withdrawWhitelistFlag = "" //0 close 1 open
    var inviteCode = ""//Invitation code
    
    var authLevel = ""//Certification status 0. Under review, 1. Passed, 2. Not passed, 3. Not certified
    
    var countryCode = ""//Country code
    
    var inviteUrl = ""//Recommendation invitation
    
    var pid: Int = -1 // 为0则不存在上级邀请人，否则返回上级uid
    var ableToAddPid: Bool = false //  true:显示添加入口，false 就不显示
    var isCanAddSuperior: Bool {
//        return pid == 0
        return ableToAddPid
    }
    
    var useFeeCoinOpen = ""
    
    var nickName = ""
    
    var googleStatus = "0"//Has Google verification been activated yet? 0 has not been activated
    
    var notPassReason = ""
    var isCapitalPwordSet = "0"//Set fund password or not
    var lastLoginTime = ""
    var feeCoin = ""
    
    var lastLoginIp = ""
    
    var userAccount = ""
    
    var email = ""//If there is, it is email login
    
    var token = ""
    
    var gesturePwd : String = ""
    
    var tmpDict : [String : Any] = [:]
    
    var creditGrade = "0"//Credit rating
    
    var realName = ""//Credit rating
    
    var otcCompanyInfo : [String : Any] = [:]
    var otcCompanyInfoModel = OtcCompanyInfoEntity()
    var userCompanyInfo : [String : Any] = [:]
    var userCompanyInfoModel = UserCompanyInfoEntity()
    var etfLocalLimit:String = ""//EtfLocalLimit: '1' This is within the region limit range of etf, which is 1 and not within the limit range of 0
    var useEtf:String = ""//UseEtf: "1" This is an ETF transaction that the user has previously used

    override func mj_keyValuesDidFinishConvertingToObject() {
        self.otcCompanyInfoModel = OtcCompanyInfoEntity.mj_object(withKeyValues: otcCompanyInfo)
        self.userCompanyInfoModel = UserCompanyInfoEntity.mj_object(withKeyValues: userCompanyInfo)
    }
    
    override static func mj_replacedKeyFromPropertyName() -> [AnyHashable : Any]! {
        return ["uid":"id"]
    }

    func dealEntity(){
        UserInfoEntity.setTmpDict()
        
        XUserDefault.setGesturesPassword(gesturePwd)
        
        if lastLoginTime == ""{
            lastLoginTime = LanguageTools.getString(key: "temp_none")
        }else{
            lastLoginTime = DateTools.strToTimeString(lastLoginTime)
        }
        
        if lastLoginIp == ""{
            lastLoginIp = LanguageTools.getString(key: "temp_none")
        }
        
        token = String(describing:XUserDefault.tokenValue ?? "")
        
        creditGrade = NSString.init(string: "1").subtracting(creditGrade, decimals: 2)
        creditGrade = NSString.init(string: creditGrade).multiplying(by: "100", decimals: 0)
    }
    
    class func setTmpDict(){
        if let data = UserInfoEntity.sharedInstance().mj_JSONData(){
            XUserDefault.userInfoValue = data
        }
    }
    
    func reloadTmpDict(_ key : String , value : String){
        if let value = dict[key]{
            UserInfoEntity.sharedInstance().tmpDict[key] = value
            UserInfoEntity.setTmpDict()
        }
    }
    
    class func getTmpDict(){
        if let data = XUserDefault.userInfoValue {
            if let en = UserInfoEntity.mj_object(withKeyValues: data){
                UserInfoEntity.entity = en
                UserInfoEntity.sharedInstance().token = ""
            }
        }
    }
    
    func otcBasicCheckPass()->Bool {
        //Enforce Google authentication
        if EXAppConfigManager.sharedInstance.isRequireGoogle() {
            if self.nickName.count > 0 &&
                self.authLevel == UserAuthLevel.pass.rawValue && self.googleStatus == "1" {
                return true
            }else {
                return false
            }
        }else {
            
            let twoPass = (isOpenMobileCheck == "1" || self.googleStatus == "1")
            if self.nickName.count > 0 &&
                self.authLevel == UserAuthLevel.pass.rawValue && twoPass{
                return true
            }
            return false
        }
    }
    
    func hasAgentStatus () -> Bool {
        
        if !agentStatus.isEmpty && agentStatus != "0"  {
            return true
        }
        return false
    }
    
    func hasNickName() ->Bool {
        return self.nickName.count > 0
    }
    
    func didBindPhone() ->Bool {
        return self.isOpenMobileCheck == "1"
    }
    
    func didBindGoolge() ->Bool {
        return self.googleStatus == "1"
    }
    
    func didBindMail() ->Bool {
        return self.email.count > 0
    }
    
    func didpassRealName() -> Bool {
        return self.authLevel ==  UserAuthLevel.pass.rawValue
    }
    
    func didSetPayPwd()->Bool {
        return self.isCapitalPwordSet == "1"
    }
    
    func otcSafetyCheckPass()->Bool {
        return true
//        if self.isCapitalPwordSet == "1" {
//            return true
//        }else {
//            return false
//        }
    }
    
    func didOpenETF() -> Bool {
        return self.useEtf == "1"
    }
    
    //empty
    public class func removeAllData(){
        UserInfoEntity.entity = nil
    }
    
    
    func canEditOtcRealName() -> Bool {
        if XUserDefault.isOffLine() {
            return false
        }
        
        if self.userCompanyInfoModel.status == "1" || self.userCompanyInfoModel.status == "3" {
            return true
        }
        return false
    }
}

extension UserInfoEntity{
    
    
    func loginSuccess(_ token : String , quickToken : String = "", account : String = "", loginPwd : String = ""){
        XUserDefault.setLoginTime()//Login successful, save login time
        
         //Successfully logged in to obtain the remote list
        
        if let temp = XUserDefault.mobileNumberValue {//If it is not the same account, delete the fingerprint and facial recognition
            if account != temp{
                XUserDefault.setFaceIdOrTouchId("")
            }
        }
        if account != ""{
            XUserDefault.mobileNumberValue = account
//            XUserDefault.setValueForKey(account , key: XUserDefault.mobileNumber)//Login successful, save login account
        }
        
        if quickToken != "" {
            XUserDefault.quickTokenValue = quickToken //Login successful, save quick login token
        }
        XUserDefault.tokenValue = token //The token will not be stored until the second login is successful
        UserInfoEntity.removeAllData()//Clean up previous personal information
        UserInfoEntity.userSymbolsVm.syncUserSysmbols()//Successfully logged in to synchronize favorites
//        NotificationCenter.default.post(name: Notification.Name(rawValue: "EXLoginSuccess"), object: nil)
    }
    
    func getUserInfo(_ complete : @escaping (()->()), _ didError: @escaping (() -> ()), postNoti: Bool? = true){
        _ = appApi.rx.request(.userInfo)
            .MJObjectMap(UserInfoEntity.self)
            .subscribe(onSuccess: { (entity) in
                UserInfoEntity.entity = entity
                UserInfoEntity.sharedInstance().dealEntity()
                complete()
                //Update contract token
                if let token = XUserDefault.getToken(), token.count > 0 {
                    let account = EXSwapAccount()
                    account.token = token
                    EXSwapPlatformSDK.shared.activeAccount = account
                    EXSwapPlatformSDK.shared.inviteUrl = UserInfoEntity.sharedInstance().inviteUrl
                }
                if let p = postNoti, p == true{
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "EXLoginSuccess"), object: nil)
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "EXGetUserInfoSuccess"), object: nil)
                }
            }) { (error) in
                didError()
                NSLog("\(error)")
            }
    }
    
    func justGetUserInfo(_ complete : @escaping (()->()), _ didError: @escaping (() -> ())){
        _ = appApi.rx.request(.userInfo)
            .MJObjectMap(UserInfoEntity.self)
            .subscribe(onSuccess: { (entity) in
                UserInfoEntity.entity = entity
                UserInfoEntity.sharedInstance().dealEntity()
            
            }) { (error) in
                didError()
                NSLog("\(error)")
            }
    }
    
    func logout() {
        XUserDefault.tokenValue = nil
        EXSwapPlatformSDK.shared.activeAccount = nil
    }
    
    func clearQuickToken() {
        XUserDefault.quickTokenValue = ""
    }
}

class OtcCompanyInfoEntity : EXBaseModel{
    var status = ""//Off site merchant status, 0: not opened, 1: open regular merchant, 2: open super merchant
    var applyStatus = ""//User Field Foreign Account Application Status, 0: Not Applied, 1: Applying, 2: Rejected, 3: Passed
    var applyComment = ""//Reason for Failure of Foreign Account Application in User Field
    var otcCompanyMarginNum = ""//Account amount
}

class UserCompanyInfoEntity : EXBaseModel{
    var marginCoinSymbol = ""//Guarantee coin type
    var docAddr = ""//Document Address
    var normalCompanyMarginNum = ""//Number of deposits for ordinary merchants
    var superCompanyMarginNum = ""//Super Merchant Deposit Quantity
    var status = ""//User Field Foreign Account Status, 0: Unauthenticated, 1: Ordinary Merchant, 2: Ordinary Merchant Release, 3: Super Merchant, 4: Super Merchant Release
    var normalTradeLimit = ""//Maximum value for regular transactions, default to 100000\
    var otcCompanyApplyEmail = ""//Apply for merchant email address
}

