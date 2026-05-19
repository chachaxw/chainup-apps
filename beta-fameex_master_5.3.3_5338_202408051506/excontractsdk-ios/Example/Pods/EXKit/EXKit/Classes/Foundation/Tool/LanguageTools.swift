//
//  LanguageTools.swift
//  AppProject
//
//  Created by zewu wang on 2018/8/6.
//  Copyright © 2018年 zewu wang. All rights reserved.
//

import UIKit
import MJExtension

public extension String {
    public func localized() -> String{
        return LanguageTools.getString(key: self)
    }
}

@objcMembers public class AppCfgLanListItem : NSObject {
    public var name:String = ""
    public var selected:Bool = false
    public var id = ""
    
    public override func mj_keyValuesDidFinishConvertingToObject() {
        self.id = id.replacingOccurrences(of: "_", with: "-")
    }
}

@objcMembers public class LanguageTools: NSObject {
    
    public static let shareInstance = LanguageTools()
    
    public let def = UserDefaults.standard
    //当前选中的配置语言
    public var selectedLan = AppCfgLanListItem()
    public var tempLan = AppCfgLanListItem()

    public var bundle : Bundle?
    public var currentDownLoadLan = ""
    
    //根据语言key获取翻译
    @objc public class func getString(key:String) -> String{
        if let dlLan = XUserDefault.getVauleForKey(key:"dl_\(LanguageHandler.phoneLanguage)") as? [String : String] {
            if let value = dlLan[key] {
//                debugPrint("使用在线语言包-》\(value)")
                return value.ex_localizableReplacedString()
            }else {
                return self.getDfString(key: key)
            }
        }else {
            return self.getDfString(key: key)
        }
    }
    
    @objc public class func getDfString(key:String) -> String {
        
        let bundle = LanguageHandler.shareInstance.bundle
        if let str = bundle?.localizedString(forKey: key, value: nil, table: nil){
            //找不到value,使用en的key
            if str == key {
                if let path = Bundle.main.path(forResource:"en" , ofType: "lproj") {
                    let bundle = Bundle.init(path: path)
                    if let en_str = bundle?.localizedString(forKey: key, value: nil, table: nil) {
                        return en_str.ex_localizableReplacedString()
                    }
                }
            }
            return str.ex_localizableReplacedString()
        }
        return ""
    }
}


extension String {
    fileprivate func ex_localizableReplacedString() -> String{
        var newStr = self
        if newStr.contains("%s") {
            newStr = newStr.replacingOccurrences(of: "%s", with: "%@")
        }
        if newStr.contains("$s") {
            do {
                var input = newStr
                let regex = try NSRegularExpression(pattern: #"%(\d+\$)?s"#)
                for result in regex.matches(in: input, range: NSRange(location: 0, length: input.count)).reversed() {
                    guard let range = Range(result.range, in: input) else { continue }
                    let substring = input[range]
                    let replacement = substring.replacingOccurrences(of: "s", with: "@")
                    input.replaceSubrange(range, with: replacement)
                }
                return input
            } catch {
                return newStr
            }
        }
        return newStr
    }
}
