//
//  LanguageTools.swift
//  AppProject
//
//  Created by zewu wang on 2023/8/6.
//  Copyright © 2023年 zewu wang. All rights reserved.
//

import UIKit
import EXKit
import Moya

extension LanguageTools{
    
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
    
    func isOnlineLanSupported(lanId:String) -> String? {
        let list = EXAppConfigManager.sharedInstance.configVm.cfgModel.langList
        for item in list{
            if item.langKey == lanId, item.nowFileAddress.hasPrefix("http"){
                return item.nowFileAddress
            }
        }
        return nil
    }
    func needDownLandLan(lanId:String) -> Bool {
        let realID = lanId
        if let dlLan = XUserDefault.getVauleForKey(key:"dl_\(realID)") as? [String : String], dlLan.keys.count > 0 {
            print("lan = \(realID) has downloaded")
            return false
        }
        return isOnlineLanSupported(lanId: lanId) != nil
    }
    
    private static var lastDownloadingLanguageToken:Cancellable? = nil
    func tryDownloadCurrentLan(lanID:String, completion: ((_ success:Bool)->Void)? = nil) {
        #if DEBUG
        completion?(false)
        return
        #endif
        
        if let downLoadUrl = self.isOnlineLanSupported(lanId: lanID), !downLoadUrl.isEmpty {
            Self.lastDownloadingLanguageToken?.cancel()
            LanguageTools.shareInstance.currentDownLoadLan = lanID
            Self.lastDownloadingLanguageToken =
            DLServiceProvider.request(.downloadLan(url: downLoadUrl)) {[weak self] result in
                switch result {
                case .success:
                    self?.handleLocalFile(lanID: lanID, completion: completion)
                case .failure(_):
                    completion?(false)
                    break
                }
            }
        }else {
            completion?(false)
        }
    }
    private func handleLocalFile(lanID:String, completion: ((_ success:Bool)->Void)? = nil) {
        //print("Successfully updated online language pack  (lanID)")
        let location = DefaultDownloadDir.appendingPathComponent(lanID)
        //print("Successfully updated online language pack, path="  (location) ")
        if let jsonData = (try? Data(contentsOf: location)) ?? (NSData(contentsOfFile: location.path) as? Data) {
            do{
                guard let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String:AnyObject] else {
                    throw NSError()
                }
                guard let obj = json[lanID] as? [String:Any] else {
                    throw NSError()
                }
                let swiftDic = (obj as? [String:String]) ?? {
                    let dic = obj.compactMapValues({ ($0 as? String) ?? ($0 as? NSNumber)?.stringValue })
                    return dic.isEmpty == true ? nil : dic
                }()
                if let lanDic = swiftDic {
                    EXLanguage.updateLocalizations(of: lanID, localizations: lanDic)
                    completion?(true)
                }else {
                    throw NSError()
                }
            }catch let error as NSError{
                completion?(false)
            }
        }
    }
}


extension LanguageTools {
    func changeLan(lan:String) {
       // EXPushMsgHandler.shared.changeLan(lan: lan)
    }
}




