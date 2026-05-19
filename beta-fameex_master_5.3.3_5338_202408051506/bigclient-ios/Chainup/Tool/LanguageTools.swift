//
//  LanguageTools.swift
//  AppProject
//
//  Created by zewu wang on 2023/8/6.
//  Copyright © 2023年 zewu wang. All rights reserved.
//

import UIKit
import EXKit

extension String {
    func localized() -> String{
        return LanguageTools.getString(key: self)
    }
}


@objcMembers class LanguageTools: NSObject {
    
    static let shareInstance = LanguageTools()
    
    let def = UserDefaults.standard
    //The currently selected configuration language
    var selectedLan = AppCfgLanListItem()
    var bundle : Bundle?
    var currentDownLoadLan = ""
    
    //Obtain translation based on language key
    @objc class func getString(key:String) -> String{

        if let dlLan = XUserDefault.getVauleForKey(key:"dl_\(LanguageHandler.priviatePhoneLanguage)") as? [String : String] {
            if let value = dlLan[key] {
                return value.newReplaceString()
            }else {
                return self.getDfString(key: key)
            }
        }else {
            return self.getDfString(key: key)
        }
    }
    
    @objc class func getDfString(key:String) -> String {
        
        let bundle = LanguageHandler.shareInstance.bundle
        if let str = bundle?.localizedString(forKey: key, value: nil, table: nil){
            //Unable to find value, use en's key
            if str == key {
                if let path = Bundle.main.path(forResource:"en" , ofType: "lproj") {
                    let bundle = Bundle.init(path: path)
                    if let en_str = bundle?.localizedString(forKey: key, value: nil, table: nil) {
                        return en_str.newReplaceString()
                    }
                }
            }
            return str.newReplaceString()
        }
        // empty
        if let path = Bundle.main.path(forResource:"en" , ofType: "lproj") {
            let bundle = Bundle.init(path: path)
            if let en_str = bundle?.localizedString(forKey: key, value: nil, table: nil) {
                return en_str.newReplaceString()
            }
        }
        return ""
    }
}

extension LanguageTools{
    
    private func serverSupportLans() -> [String] {
        var serversupports:[String] = []
        //Here, you need to retrieve it from the cache, do not directly access configmanager
        if let cacheV5 = EXAppCache.sharedCache.getPbV5Cache() {
            for (key, value) in cacheV5.locales {
                if value.count > 0 {
                    serversupports.append(key)
                }
            }
        }
        return serversupports
    }
    
    func supportLan(_ lankey:String) ->Bool {
        var key = lankey
        key = key.replacingOccurrences(of: "-", with: "_")
        if LanguageHandler.shareInstance.localSupportsLans().contains(key) {
            return true
        }
        if serverSupportLans().contains(key) {
            return true
        }
        return false
    }
    
    //Is it Chinese
    class func isHan()->Bool{
        if LanguageHandler.priviatePhoneLanguage == "zh_CN" || LanguageHandler.priviatePhoneLanguage == "el_GR" {
            return true
        }else{
            return false
        }
    }
    
    //MARK: Get the phone language, ignore using Greek instead of traditional Chinese on the server
    class func getPhoneLanguage(ignoreServer:Bool = false) -> String{
        let phoneLan = LanguageHandler.priviatePhoneLanguage
        if ignoreServer,phoneLan == "el_GR" {
            return "zh-Hant"
        }else {
            return phoneLan
        }
    }
}

extension LanguageTools {
    
    func isOnlineLanSupported(lanId:String) -> String {
        let realID = lanId.replacingOccurrences(of: "-", with: "_")
        let list = EXAppConfigManager.sharedInstance.configVm.cfgModel.langList
        
        for item in list{
            if item.langKey == realID{
                return item.nowFileAddress
            }
        }
        return ""
    }
    func needDownLandLan(lanId:String) -> Bool {
        let realID = lanId.replacingOccurrences(of: "-", with: "_")
        if let dlLan = XUserDefault.getVauleForKey(key:"dl_\(realID)") as? [String : String], dlLan.keys.count > 0 {
            print("lan = \(realID) has downloaded")
            return false
        }
        let downUrl = self.isOnlineLanSupported(lanId: lanId)
        if downUrl.hasPrefix("http"){
            return true
        }
        return false
    }
    
    
    func tryDownloadCurrentLan(lanID:String,postNoti: Bool = true) {
        let downLoadUrl = self.isOnlineLanSupported(lanId: lanID)
        if downLoadUrl.count > 0 {
            let realID = lanID.replacingOccurrences(of: "-", with: "_")
            LanguageTools.shareInstance.currentDownLoadLan = realID
            DLServiceProvider.request(.downloadLan(url: downLoadUrl)) {[weak self] result in
                switch result {
                case .success:
                    self?.handleLocalFile(lanID: realID,noti: postNoti)
                case .failure(_):
                    if postNoti{
                        self?.postErrorNoti()
                    }
                    break
                }
            }
        }else {
            if postNoti{
                self.postErrorNoti()
            }
        }
    }
    private func handleLocalFile(lanID:String,noti: Bool) {
        //print("Successfully updated online language pack  (lanID)")
        let location = DefaultDownloadDir.appendingPathComponent(lanID)
        //print("Successfully updated online language pack, path="  (location) ")
        if let jsonData = NSData(contentsOfFile: location.path) {
            do{
                guard let json = try JSONSerialization.jsonObject(with: jsonData as Data, options: []) as? [String:AnyObject] else {
                    if noti{
                        postErrorNoti()
                    }
                    return
                }
                let obj = json[lanID]
                var swiftDic:[String: String]?
                if let dic = obj as?  [String:String] {
                    swiftDic = dic
                }
                if swiftDic == nil {
                    if let dic = obj as? NSDictionary {
                        var swiftMap = [String: String]()
                        for key in dic.allKeys{
                            if let newKey = key as? String, let v = dic.object(forKey: key) as? String{
                                swiftMap[newKey] = v
                            }
                        }
                        //                    print(swiftMap.keys)
                        swiftDic = swiftMap
                    }
                }
                if let lanDic = swiftDic {
#if DEBUG
                    print("bibi \(lanID) ==download success")
#endif
                    XUserDefault.setValueForKey(lanDic, key:"dl_\(lanID)")
                    LanguageHandler.shareInstance.setLanguage(langeuage: lanID.replacingOccurrences(of: "_", with: "-"))
                    if noti{
                        postNoti()
                    }
                }else {
                    if noti{
                        postErrorNoti()
                    }
                }
            }catch let error as NSError{
                if noti{
                    postErrorNoti()
                   
                }
            }
        }
    }
    
    func postNoti(){
        NotificationCenter.default.post(name: EXNoti.lanDownloadSuccess.notiName, object: nil)
    }
    
    func postErrorNoti(){
        NotificationCenter.default.post(name: EXNoti.lanDownloadFail.notiName,  object: nil)
    }
    
}


extension LanguageTools {
    func changeLan(lan:String) {
       // EXPushMsgHandler.shared.changeLan(lan: lan)
    }
}




