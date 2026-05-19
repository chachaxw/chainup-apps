//
//  EXLanguageTools.swift
//  AppProject
//
//  Created by zewu wang on 2023/8/6.
//  Copyright © 2023年 zewu wang. All rights reserved.
//

import UIKit
import EXKit
/*
Currency Selection Language>Contract Language>System Language
 */
public let EXS_UserLanguage = "Contract_UserLanguage" //Language suitable for selection
public let EXS_AppleLanguages = "AppleLanguages"

public class EXLanguageTools: NSObject {

    static public let shareInstance = EXLanguageTools()

    let def = UserDefaults.standard

    var bundle : Bundle?
    var currentLanDic = [String:String]() //Switch Language Clear
    
    //Obtain translation based on language key
    @objc class func getString(key:String) -> String{
      
        if let value = EXLanguageTools.shareInstance.currentLanDic[key],value.count > 0{
            return value.replaceString()
        }
        if let dlLan = EXStoreData.storeObject(forKey: self.getDownloadLanKey()) as? [String : String] { //Don't worry about downloading
            if let value = dlLan[key] {
                let new = value.replaceString()
                EXLanguageTools.shareInstance.currentLanDic[key] = new
                return new
            }
        }
        return self.getDfString(key: key)
    }
    
    @objc class func getDfString(key:String) -> String {
        //The downloaded language packs and local language packs will be placed in EXLanguageTools. shareInstance. currentLanDic
        if let value = EXLanguageTools.shareInstance.currentLanDic[key],value.count > 0{
            return value.replaceString()
        }
        let bundle = EXLanguageTools.shareInstance.bundle
        //Take one locally and save one
        if let str = bundle?.localizedString(forKey: key, value: nil, table: nil){
            var newStr = str
            if str == key {
//                //print("key -> notFound -> \(key) = UseEnglishReplace")
                if let path =  EXLanguageTools.shareInstance.localBundle?.path(forResource:"en" , ofType: "lproj") {
                    let bundle = Bundle.init(path: path)
                    if let en_str = bundle?.localizedString(forKey: key, value: nil, table: nil) {
                        newStr = en_str
                    }
                }
            }
            let v = newStr.replaceString()
            EXLanguageTools.shareInstance.currentLanDic[key] = v
            return v
        }
           
        return ""
    }

    //Initialize Language
    public func initUserLanguage() {
        EXLanguageTools.shareInstance.currentLanDic.removeAll()
        //Zh Hans CN system language format
        var string:String = def.value(forKey: EXS_UserLanguage) as! String? ?? ""
        //        var string = "" //Now follow the system first
        if string == ""{
            string = LanguageHandler.priviatePhoneLanguage //get xianhuo lan
        }
        if string == "" { //
            if  let languages = def.object(forKey: EXS_AppleLanguages) as? NSArray,languages.count != 0 {
                let current = languages.object(at: 0) as? String
                if current != nil {
                    string = current!
                }
            }
        }
//        if string.range(of: "zh-Hant") != nil{
//            string = "zh-Hant"
//        }else if string.range(of: "zh") != nil{
//            string = "zh-Hans"
//        } else if string.range(of: "ko") != nil{
//            string = "ko-KR"
//        }
//        else if string.range(of: "ja") != nil{
//            string = "ja"
//
//        }
//        else if string.range(of:"vi") != nil{
//            string = "vi"
//        }
//        else if string.range(of: "en") != nil{
//            string = "en"
//
//        }
//        else if string.range(of: "es") != nil{
//            string = "es"
//        }else{
//            string = "en"
//        }
//
//        if localBundle != nil {
//
//            var path = localBundle?.path(forResource:string , ofType: "lproj")
//
//            if path == nil {
//                path = localBundle?.path(forResource:"en" , ofType: "lproj")
//                def.set("en-US", forKey: EXS_UserLanguage)
//                def.synchronize()
//            }
//            bundle = Bundle(path: path!)
//        }
        
        for lanItem in SupportLanguageList.shareInstance.supportLans {
            if (string.range(of: lanItem.server) != nil) {
                string = lanItem.resource
                break
            }
            if (string.range(of: lanItem.key) != nil) {
                string = lanItem.resource
                break
            }
        }
        if localBundle != nil {
            let path = localBundle?.path(forResource:string , ofType: "lproj")
            if path == nil {
                //print("Contract=====》init unsupporst lan\(string) setEnglish")
                setToEnglish()
            }else{
                bundle = Bundle(path: path!)
                def.set(string, forKey: EXS_UserLanguage)
                //print("Contract=====》init set lan \(string)")
                def.synchronize()
            }
        }
    }
    let localBundle = Bundle.exs_localBundle()
    //Set Language
    public func setLanguage(langeuage:String) {
        EXLanguageTools.shareInstance.currentLanDic.removeAll()
        //print("Contract=====》change to\(langeuage)")
        let allLans = SupportLanguageList.shareInstance.getLocalKeys(needFormat: true)
        if allLans.contains(langeuage) {
            if let lanItem = SupportLanguageList.shareInstance.getLanItem(lan: langeuage) {
                if let path = localBundle?.path(forResource:lanItem.resource, ofType: "lproj") {
                    //print("Contract=====》change local lan to\(langeuage)")
                    bundle = Bundle(path: path)
                    def.set(lanItem.server, forKey: EXS_UserLanguage)
                    def.synchronize()
                }else {
                  //print("Contract=====》set lan \(langeuage) error")
                    self.setToEnglish()
                }
            }else {
                //error
               //print("Contract=====》set lan \(langeuage) error")
                self.setToEnglish()
            }
        }else{
            //If there is a new language downloaded,
            if let dlLan = EXStoreData.storeObject(forKey:langeuage) as? [String : String],dlLan.count > 0 {
               //print("Contract=====set to download lan \(langeuage)")
                bundle = nil
                EXLanguageTools.shareInstance.currentLanDic = dlLan
                def.set(langeuage, forKey: EXS_UserLanguage)
                def.synchronize()
            }else {
                self.setToEnglish()
            }
        }
        
//        if langeuage == "el-GR"{
//            if let  path = localBundle?.path(forResource:"zh-Hant" , ofType: "lproj") {
//
//            bundle = Bundle(path: path)
//            def.set("zh-Hant", forKey: EXS_UserLanguage)
//
//            def.synchronize()
//            }
//
//        }else if langeuage == "zh-CN"{
//            if let  path = localBundle?.path(forResource:"zh-Hans" , ofType: "lproj") {
//
//                bundle = Bundle(path: path)
//                def.set("zh-Hans", forKey: EXS_UserLanguage)
//
//                def.synchronize()
//            }
//        }
//
//        else if langeuage == "ja-JP"{
//            if let  path = localBundle?.path(forResource:"ja" , ofType: "lproj") {
//
//                bundle = Bundle(path: path)
//                def.set("ja-JP", forKey: EXS_UserLanguage)
//
//                def.synchronize()
//            }
//        }
//        else if langeuage == "ko-KR"{
//            if let  path = localBundle?.path(forResource:"ko-KR" , ofType: "lproj") {
//
//                bundle = Bundle(path: path)
//                def.set("ko-KR", forKey: EXS_UserLanguage)
//
//                def.synchronize()
//            }
//        }
//
//        else if langeuage == "vi-VN"{
//            if let  path = localBundle?.path(forResource:"vi" , ofType: "lproj") {
//
//                bundle = Bundle(path: path)
//                def.set("vi-VN", forKey: EXS_UserLanguage)
//
//                def.synchronize()
//            }
//        }
//
//        else if langeuage == "es-ES"{
//            if let  path = localBundle?.path(forResource:"es" , ofType: "lproj") {
//                bundle = Bundle(path: path)
//                def.set("es-ES", forKey: EXS_UserLanguage)
//                def.synchronize()
//            }
//        }
//
//        else if langeuage == "en-US"{
//            if let  path = localBundle?.path(forResource:"en" , ofType: "lproj") {
//                bundle = Bundle(path: path)
//                def.set("en-US", forKey: EXS_UserLanguage)
//                def.synchronize()
//            }
//        }  else if langeuage == "th-Th"{
//            if let  path = localBundle?.path(forResource:"th-Th" , ofType: "lproj") {
//                bundle = Bundle(path: path)
//                def.set("th-Th", forKey: EXS_UserLanguage)
//                def.synchronize()
//            }
//        }  else if langeuage == "id-ID"{
//            if let  path = localBundle?.path(forResource:"id-ID" , ofType: "lproj") {
//                bundle = Bundle(path: path)
//                def.set("id-ID", forKey: EXS_UserLanguage)
//                def.synchronize()
//            }
//        }
//
//        else{
//            //If there is a new language downloaded,
//            if let dlLan = EXStoreData.storeObject(forKey:langeuage) as? [String : String],dlLan.count > 0 {
//                bundle = nil
//                EXLanguageTools.shareInstance.currentLanDic = dlLan
//            }else {
//                let path = localBundle?.path(forResource:"en" , ofType: "lproj")
//                bundle = Bundle(path: path!)
//            }
//
//            def.set(langeuage, forKey: EXS_UserLanguage)
//            def.synchronize()
//        }
        //Update the key of the K-line
//        EXSwapKlineDataTool.shared.updateLankeys()
        self.tryDownloadCurrentLan()
    }
    static func getDownloadLanKey() ->String{
        return "swap_dl_\(LanguageHandler.priviatePhoneLanguage)"
    }
}


extension EXLanguageTools {
    func setToEnglish(){
        let path = localBundle?.path(forResource:"en" , ofType: "lproj")
        bundle = Bundle(path: path!)
        def.set("en-US", forKey: EXS_UserLanguage)
        def.synchronize()
    }

    func tryDownloadCurrentLan() {
        let currentLan = LanguageHandler.priviatePhoneLanguage
        let lanlist = EXSwapPublicInfo.shared.languages
        for language in lanlist {
            if language.langKey == currentLan{
                let lanUrl = language.nowFileAddress
                if lanUrl.count > 0  {
                    SwapDownloadServiceProvider.request(.downloadSwapLanguage(url: lanUrl)) {[weak self] result in
                        switch result {
                        case .success:
                            self?.readLocalFile()
                        case .failure(_):
                            break
                        }
                    }
                }
                break
            }
        }
    }
    
    func readLocalFile() {
        let location = SWapDefaultDownloadDir.appendingPathComponent(EXLanguageTools.getDownloadLanKey())
        if let jsonData = NSData(contentsOfFile: location.path) {
            do{
                if let json = try JSONSerialization.jsonObject(with: jsonData as Data, options: []) as? [String:AnyObject] {
                    let lankey = LanguageHandler.priviatePhoneLanguage
                    let obj = json[lankey]
                    var swiftDic:[String: String]?
                    if let dic = obj as?  [String:String] {
                        swiftDic = dic
                        //print("lankey =\(lankey) tranform [String:String]")
                    }
                    if swiftDic == nil {
                        if let dic = obj as? NSDictionary {
                            var swiftMap = [String: String]()
                            for key in dic.allKeys{
                                if let newKey = key as? String, let v = dic.object(forKey: key) as? String{
                                    swiftMap[newKey] = v
                                }
                            }
                            swiftDic = swiftMap
                            //print("lankey =\(lankey) tranform NSDictionary")
                        }
                    }
                    if let lanDic = swiftDic {
                        //print("lankey =\(lankey) downlown")
                        EXStoreData.setStoreObjectAndKey(lanDic, key: EXLanguageTools.getDownloadLanKey())
                        EXLanguageTools.shareInstance.currentLanDic = lanDic
    //                    EXSwapKlineDataTool.shared.updateLankeys()
                    }
                }
                
            }catch let error as NSError{
//                //print("Parsing error:  (error. localizedDescription)")
            }
        }
        
    }
}


