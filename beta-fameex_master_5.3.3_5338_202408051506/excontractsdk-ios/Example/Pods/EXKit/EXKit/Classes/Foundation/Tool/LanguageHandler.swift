//
//  LanguageTools.swift
//  AppProject
//
//  Created by zewu wang on 2018/8/6.
//  Copyright © 2018年 zewu wang. All rights reserved.
//

import UIKit

let UserLanguage = "UserLanguage"
let AppleLanguages = "AppleLanguages"
let AppUserSelectLanguage = "k_AppUserSelectLanguage"

//这个类只管理语言bundle,其余还由原来的languagetools处理

@objcMembers public class LanguageHandler: NSObject {
    public static var priviatePhoneLanguage: String {
        var lan = LanguageHandler.phoneLanguage
        if lan == "zh_TC" { //chinese Traditonal
            lan = "el_GR"
        }
        return lan
    }
    public static var phoneLanguage = ""
    public var serverSuppotsLan:[String] = [] //设置服务端支持语言
    
    let def = UserDefaults.standard
    public var bundle : Bundle?
    
    public static var shareInstance : LanguageHandler {
        struct Static {
            static let instance : LanguageHandler = LanguageHandler()
        }
        return Static.instance
    }
    
    //初始化语言
    public func initUserLanguage() {
        var string:String = def.value(forKey: UserLanguage) as! String? ?? ""
        //if firstTime = true,use phone language
        //这里第一次进入,ios的可能是zh-CN-地区码
        if string.isEmpty {
            let languages = def.object(forKey: AppleLanguages) as? NSArray
            if languages?.count != 0 {
                let current = languages?.object(at: 0) as? String
                if current != nil {
                    string = current!
                }
            }
        }
        for lanItem in SupportLanguageList.shareInstance.allLanguages() {
            if (string.range(of: lanItem.server) != nil) {
                string = lanItem.resource
                LanguageHandler.phoneLanguage = lanItem.server
            }
            if (string.range(of: lanItem.key) != nil) {
                string = lanItem.resource
                LanguageHandler.phoneLanguage = lanItem.server
            }
        }
        let path = Bundle.main.path(forResource:string , ofType: "lproj")
        if path == nil {
            debugPrint("=====》开机语言不支持\(string),设置为英文")
            setLanguage(langeuage: string)
        }else {
            debugPrint("=====》开机设置语言\(string)")
            def.set(string, forKey: UserLanguage)
            def.synchronize()
            bundle = Bundle(path: path!)
        }
    }
    
    //设置语言
    public func setLanguage(langeuage:String) {
        debugPrint("=====》将要更改到语言\(langeuage)")

        let allLans = SupportLanguageList.shareInstance.getLocalKeys(needFormat: true)
        //如果本地语言里支持设置语言格式被转换为了zh-CN
        if allLans.contains(langeuage) {
            if let lanItem = SupportLanguageList.shareInstance.getLanItem(lan: langeuage) {
                if let  path = Bundle.main.path(forResource:lanItem.resource, ofType: "lproj") {
                    debugPrint("=====》更改本地支持设置语言\(langeuage)")
                    bundle = Bundle(path: path)
                    LanguageHandler.phoneLanguage = lanItem.server
                    def.set(lanItem.server, forKey: UserLanguage)
                    def.synchronize()
                }else {
                    debugPrint("=====》异常,英文\(langeuage)")
                    //异常了,可能谁把本地语言删了,但是没删配置文件的.导致找不到本地语言.lproj
                    self.setToEnglish()
                }
            }else {
                //异常了
                debugPrint("=====》异常,英文\(langeuage)")
                self.setToEnglish()
            }
        }else {
            debugPrint("=====》本地不支持,尝试使用下载的语言,\(langeuage)")
            // 如果有下载的新语言
            let lanPath = "dl_\(langeuage.replacingOccurrences(of: "-", with: "_"))"
            if let dlLan = UserDefaults.standard.object(forKey:lanPath) as? [String : String],dlLan.count > 0 {
                debugPrint("=====》更改网络支持设置语言\(langeuage)")
                //存档永远是服务端下划线格式 _
                let saveLan = langeuage.replacingOccurrences(of: "-", with: "_")
                bundle = nil
                LanguageHandler.phoneLanguage = saveLan
                def.set(saveLan, forKey: UserLanguage)
                def.synchronize()
            }else {
                debugPrint("=====》下载的也没有,异常,英文\(langeuage)")
                self.setToEnglish()
            }
        }
    }
    
    func setToEnglish() {
        let path = Bundle.main.path(forResource:"en" , ofType: "lproj")
        bundle = Bundle(path: path!)
        LanguageHandler.phoneLanguage = "en_US"
        def.set("en_US", forKey: UserLanguage)
        def.synchronize()
    }
    
    public func setUserSelectLan(lan:String) {
        if lan.count > 0 {
            def.set(lan.replacingOccurrences(of: "-", with: "_"), forKey: AppUserSelectLanguage)
            def.synchronize()
        }
    }
}

extension LanguageHandler{

    public func localSupportsLans() -> [String] {
        return SupportLanguageList.shareInstance.getLocalKeys()
    }
}
