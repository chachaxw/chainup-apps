//
//  LanguageTools.swift
//  AppProject
//
//  Created by zewu wang on2020/8/6.
//  Copyright ©2020年 zewu wang. All rights reserved.
//

import UIKit
import MJExtension

public extension String {
    func localized() -> String{
        return LanguageTools.getString(key: self)
    }
}



@objcMembers public class AppCfgLanListItem : NSObject {
    public var name:String = ""
    public var selected:Bool = false
    public var id = ""
}

@objcMembers public class LanguageTools: NSObject {
    public static let shareInstance = LanguageTools()
    public var currentDownLoadLan = ""
    public var isPrivate: Bool = false

    //根据语言key获取翻译
    @objc public class func getString(key:String) -> String{
        EXLanguage.localizedString(for: key)
    }
}
