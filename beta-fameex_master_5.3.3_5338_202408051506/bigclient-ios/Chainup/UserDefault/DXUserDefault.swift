//
//  UserDefault.swift
//  Chainup
//
//  Created by zewu wang on 2023/8/16.
//  Copyright © 2023年 zewu wang. All rights reserved.
//

import UIKit
import EXKit
//define
extension XUserDefault{
    
    private static let token = "token"//Login token
    private static let quickToken = "quickToken" //Quick login
    static let XUUID = "XUUID"//Device ID
    
    private static let gesturesPassword = "gesturesPassword"//Gesture password
    private static let faceIdOrTouchIdPassword = "faceIdOrTouchIdPassword"//Gesture password
    
    static let collectionCoinMap = "collectionCoinMap"//Collected Coin Pairs
    
    static let collectionCoinMaySymbols = "collectionCoinMaySymbols" //Collection coin pair symbol

    static let userHasChooseLan = "userHasChooseLan"//Mobile phone number

    private static let mobileNumber = "mobileNumber"//Mobile phone number
    
    static let countryNumber = "countryNumber"//Mobile phone number
    
    private static let userInfo = "userInfo"//personal information
    
    static let loginTime = "loginTime"//login time

    static let isNextRemind = "isNextRemind"//Next reminder
    
    static let searchArray = "searchArray"//Recently viewed coin pair array
    
    static let assets = "assets"//Whether to open assets
    static let rate = "rate"//Whether to open assets
    static let hideZeroAssets = "hideZeroAssets"//Enable asset hiding 0 assets
    
    static let updateVersion = "updateVersion"//Storage interface version
    
    static let swapComfirmAlert = "swapComfirmAlert"//Contract secondary confirmation box
    
    static let homeCustomConfig = "homeCustomConfig"//Homepage Customization Configuration
    
//    static let homeRecommend = "homeRecommend"//Homepage recommended currency pairs
    
    static let homeCache = "exhomeCacheIndexModel_cache"//Homepage cache
    
    static let afetyAdvice = "safetyAdvice"
    
    
    //Clear local contract language pack
    class func clearLocalLanguageDefaultsData(contract: Bool = true){
        let userDefaults = UserDefaults.standard
        let list = userDefaults.dictionaryRepresentation()
        for dic in list {
            let key = dic.key
            let prefix = contract ? "swap_dl" : "dl_"
            if key.starts(with: prefix){
//                print("clear key = \(key)")
                userDefaults.removeObject(forKey: key)
                userDefaults.synchronize()
            }
        }
    }
}

extension XUserDefault{
    
    //Next reminder
    class func getIsNextRemind()-> String?{
        if let str = XUserDefault.getVauleForKey(key: XUserDefault.isNextRemind) as? String, str != ""{
            return str
        }
        return ""
    }
    
    class func setNextRemind(){

        XUserDefault.setValueForKey("isNextRemind", key: XUserDefault.isNextRemind)

    }


    //Get token
    class func getToken()-> String?{
//        return "031aac02d8570aad2bccfb55ef3131360250b0c782d047149f270210db6c0125"
        if let str = XUserDefault.tokenValue, str != ""{
            return str
        }
        return nil
    }
    
    class func isOffLine()-> Bool {
        return self.getToken() == nil
    }
    
    //Obtain gesture password
    class func getGesturesPassword() -> String?{
        if let str = XUserDefault.gesturesPasswordValue ,str != "" ||
                UserInfoEntity.sharedInstance().gesturePwd.ch_length > 0{
            
            if str.ch_length > 0{
                
                return str
            }
           
            return  UserInfoEntity.sharedInstance().gesturePwd
        }
        return nil
    }
    //Set gesture password
    class func setGesturesPassword(_ gpw : String){
        XUserDefault.gesturesPasswordValue = gpw
    }
    
    
    //Obtain the faceIdOrTouchId password
    class func getFaceIdOrTouchIdPassword() -> String?{
        if let str = XUserDefault.faceIdOrTouchIdPasswordValue , str != ""{
            
            return str

        }
        return ""
    }
    //Set the faceIdOrTouchId password
    class func setFaceIdOrTouchId(_ gpw : String){
        XUserDefault.faceIdOrTouchIdPasswordValue = gpw
    }
    
    
    //Obtain Favorite Coin Pairs
    class func getCollectionCoinMap() -> [String] {
        if let array = XUserDefault.getVauleForKey(key: XUserDefault.collectionCoinMap) as? [String]{
            return array.filter({return $0.count > 0})
        }
        return []
    }
    
    //Overlay Favorite Coin Pairs
    class func renewFavorites(_ names:[String]){
        XUserDefault.setValueForKey(names, key: XUserDefault.collectionCoinMap)
    }
    
    //Collection coin pair
    class func collectionCoinMap(_ name : String){
        collectionCoinMap(name, in: nil)
    }
    
    class func collectionCoinMap(_ name : String,in view:UIView? = nil){
        if name.isEmpty {
            return
        }
        var array = getCollectionCoinMap()
        if array.contains(name) == false{
            array.append(name)
            EXAlert.showSuccess(msg: "kline_tip_addCollectionSuccess".localized())
            XUserDefault.setValueForKey(array, key: XUserDefault.collectionCoinMap)
        }
    }
    
    //Cancel Favorite
    class func cancelCollectionCoinMap(_ name : String){
        cancelCollectionCoinMap(name, in: nil)
    }
    
    class func cancelCollectionCoinMap(_ name : String,in view:UIView? = nil){
        if name.isEmpty {
            return
        }
        var array = getCollectionCoinMap()
        if array.contains(name){
            if let index = array.firstIndex(of: name) , array.count > index{
                array.remove(at: index)
                EXAlert.showSuccess(msg: "kline_tip_removeCollectionSuccess".localized())
            }
        }
        XUserDefault.setValueForKey(array, key: XUserDefault.collectionCoinMap)
    }
    
    //Determine whether to bookmark or not
    class func whetherCollectionCoinMap(_ name : String) -> Bool{
        let array = getCollectionCoinMap()
        if array.contains(name){
            return true
        }
        return false
    }
    
    //Set login time
    class func setLoginTime(){
        let date = Date.init()
        let time = Int(date.timeIntervalSince1970)
        XUserDefault.setValueForKey(time, key: XUserDefault.loginTime)
    }
    
    //Determine if it has exceeded 7 days. True exceeds false but not exceeded
    class func getLoginTime() -> Bool{
//        if let time = XUserDefault.getVauleForKey(key: XUserDefault.loginTime) as? Int{
//            let date = Date.init()
//            let nowTime = Int(date.timeIntervalSince1970)
//            if nowTime - time >= 604800{//If it is greater than 7 days, return true 604800
//                return true
//            }else{//If not greater than, return false
//                return false
//            }
//        }
//        return true
        return false
    }
    
    //Set Recent Views
    class func setSearchArray(_ name : String){
        var array = getSearchArray()
        if array.contains(name){
            if let index = array.firstIndex(of: name) , array.count > index{
                array.remove(at: index)
            }
        }
        array.insert(name, at: 0)
        if array.count > 5{
            array = Array(array[0..<5])
        }
        XUserDefault.setValueForKey(array, key: XUserDefault.searchArray)
    }
    
    //Get Recent Views
    class func getSearchArray() -> [String]{
        if let array = XUserDefault.getVauleForKey(key: XUserDefault.searchArray) as? [String]{
            return array
        }
        return []
    }
    
    //Clear Recent Views
    class func removeSearchArray(){
        XUserDefault.setValueForKey([], key: XUserDefault.searchArray)
    }
    
    //Opening and closing assets
    class func switchAssets(_ bool : Bool){
        if bool == true{//open
            XUserDefault.setValueForKey("1", key: XUserDefault.assets)
        }else{//close
            XUserDefault.setValueForKey("0", key: XUserDefault.assets)
        }
    }
    //Enable rate discounts
    class func switchRate(_ bool : Bool){
        if bool == true{//open
            XUserDefault.setValueForKey("1", key: XUserDefault.rate)
        }else{//close
            XUserDefault.setValueForKey("0", key: XUserDefault.rate)
        }
    }
    class func getRateStatus() -> Bool{
        if let str = XUserDefault.getVauleForKey(key: XUserDefault.rate) as? String, str != ""{
            return str == "1"
        }
       return false
    }
    
    //Query Asset Status
    class func assetPrivacyIsOn () -> Bool{
        if let a = XUserDefault.getVauleForKey(key: XUserDefault.assets) as? String , a == "1"{
            return true
        }else{
            return false
        }
    }
    
    //Opening and closing assets
    class func switchZeroAssets(_ bool : Bool){
        if bool == true{//open
            XUserDefault.setValueForKey("1", key: XUserDefault.hideZeroAssets)
        }else{//close
            XUserDefault.setValueForKey("0", key: XUserDefault.hideZeroAssets)
        }
    }
    
    //Query Asset Status
    class func zeroAssetsSetting () -> Bool{
        if let a = XUserDefault.getVauleForKey(key: XUserDefault.hideZeroAssets) as? String , a == "1"{
            return true
        }else{
            return false
        }
    }
    
    class func setSafetyAdviceOff(_ bool: Bool) {
        if bool {
            XUserDefault.setValueForKey("1", key: XUserDefault.afetyAdvice)
        }
        else {
            XUserDefault.setValueForKey("0", key: XUserDefault.afetyAdvice)
        }
    }
 
    class func setUseChooseLan(_ bool: Bool) {
        let v = bool ? "1" : "0"
        XUserDefault.setValueForKey("1", key: XUserDefault.userHasChooseLan)
    }
    
    class func getUserHasChooseLan() -> Bool{
        if let str = XUserDefault.getVauleForKey(key: XUserDefault.userHasChooseLan) as? String {
            return str == "1"
        }
        return false
    }
    
    class func safetyAdviceIsOff() -> Bool {
        return XUserDefault.getVauleForKey(key: XUserDefault.afetyAdvice) as? String ?? "0" == "1"
    }
    
    //Set Interface Version
    class func setUpdateVersion(_ version : String) -> Bool{
        if let v = XUserDefault.getVauleForKey(key: XUserDefault.updateVersion) as? String{
            if v == version{
                return false
            }else{
                XUserDefault.setValueForKey(version, key: XUserDefault.updateVersion)
                return true
            }
        }
        return false
    }
    
    class func getHomeCustomConfig() -> String{
        guard let jsonConfig =  XUserDefault.getVauleForKey(key: XUserDefault.homeCustomConfig) as? String else {return ""}
        return jsonConfig
    }
    
    //Set the contract secondary confirmation box
    class func setComfirmSwapAlert(_ status : Bool){
        if status == true {
            XUserDefault.setValueForKey("1", key: XUserDefault.swapComfirmAlert)
        } else {
            XUserDefault.setValueForKey("0", key: XUserDefault.swapComfirmAlert)
        }
    }
    
    //Obtain the contract secondary confirmation box
    class func getOnComfirmSwapAlert() -> Bool {
        if let str = XUserDefault.getVauleForKey(key: XUserDefault.swapComfirmAlert) as? String {
            if str == "" {
                setComfirmSwapAlert(true)
                return true
            } else if str == "1" {
                return true
            } else {
                return false
            }
        }
        return false
    }
}

extension XUserDefault {
    ///
    @EXUserDefaultsValue(key: XUserDefault.mobileNumber, defaultValue: nil, isSensitive: true)
    static var mobileNumberValue:String?
    ///
    @EXUserDefaultsValue(key: XUserDefault.faceIdOrTouchIdPassword, defaultValue: nil, isSensitive: true)
    static var faceIdOrTouchIdPasswordValue:String?
    ///
    @EXUserDefaultsValue(key: XUserDefault.gesturesPassword, defaultValue: nil, isSensitive: true)
    static var gesturesPasswordValue:String?
    ///
    @EXUserDefaultsValue(key: XUserDefault.token, defaultValue: nil, isSensitive: true)
    static var tokenValue:String?
    ///
    @EXUserDefaultsValue(key: XUserDefault.quickToken, defaultValue: nil, isSensitive: true)
    static var quickTokenValue:String?
    ///
    @EXUserDefaultsValue(key: XUserDefault.userInfo, defaultValue: nil, isSensitive: true)
    static var userInfoValue:Data?
}


@propertyWrapper
struct EXUserDefaultsValue<T:Codable> {
    private let key: String
    private let defaultValue: T
    private let isSensitive:Bool
    private var value: T
    /// init an object to handle the value storage process
    /// - Parameters:
    ///   - key: the name of the key
    ///   - defaultValue: the default value
    ///   - isSensitive: whether the data is sensitive or not
    public init(key: String, defaultValue: T, isSensitive:Bool = false) {
        self.key = key
        self.defaultValue = defaultValue
        self.isSensitive = isSensitive
        if isSensitive {
            self.value = EXUserDefaultsValue.decryptedValue(for: key) ?? defaultValue
        }else{
            self.value = UserDefaults.standard.object(forKey: key) as? T ?? defaultValue
        }
    }
    ///
    var wrappedValue: T {
        get { value }
        set {
            value = newValue
            if isSensitive {
                EXUserDefaultsValue.saveEncryptedData(of: newValue, for: key)
            }else{
                UserDefaults.standard.set(newValue, forKey: key)
            }
        }
    }
    ///
    private static func saveEncryptedData(of value:T, for key:String) {
        if let data = try? JSONEncoder().encode(value),
           let encryptedData = EXCryptoTool.encryptedData(with: data, key: EXUserDefaultsAESConstants.key, iv: EXUserDefaultsAESConstants.iv) {
            UserDefaults.standard.set(encryptedData, forKey: key)
        }else{
            UserDefaults.standard.set(value, forKey: key)
        }
    }
    ///
    private static func decryptedValue(for key:String) -> T? {
        if let data = UserDefaults.standard.data(forKey: key),
           let decryptedData = EXCryptoTool.decryptedData(with: data, key: EXUserDefaultsAESConstants.key, iv: EXUserDefaultsAESConstants.iv) {
            if T.self is Data.Type {
                return decryptedData as? T
            }else if let value = try? JSONDecoder().decode(T.self, from: decryptedData) {
                return value
            }
        }
        return UserDefaults.standard.object(forKey: key) as? T
    }
}
///
private struct EXUserDefaultsAESConstants {
    static let key = Data([0xff, 0xa8, 0x36, 0xd1, 0x02])
    static let iv  = Data([0x6f, 0x9c, 0xee, 0xad, 0x57, 0xff])
}
