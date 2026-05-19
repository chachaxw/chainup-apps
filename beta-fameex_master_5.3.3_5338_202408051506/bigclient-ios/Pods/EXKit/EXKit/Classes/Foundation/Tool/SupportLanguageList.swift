//
//  SupportLanguageList.swift
//  EXKit
//
//  Created by liuxuan on 2022/7/8.
//

import UIKit
@objcMembers public class LanguageItem:NSObject {
    public var key:String = ""
    public var resource:String = ""
    public var server:String = ""
    public class func getItemFormDic(dic:[String: String]) -> LanguageItem{
        let item = LanguageItem()
        item.key = dic["key"] ?? ""
        item.resource = dic["resource"] ?? ""
        item.server = dic["server"] ?? ""
        return item
    }
}

///
/// - Important The two list below must be synchronized with the two in EXLanguage.Resource.BuiltIn.
///
public class SupportLanguageList: NSObject {
    
    public var supportLans:[LanguageItem] {
        if LanguageTools.shareInstance.isPrivate {
            return SupportLanguageList.shareInstance.privateAllLanguages()
        }
        return SupportLanguageList.shareInstance.allLanguages()
    }
    //resource 是本地ios的文件名
    //server 是服务端返回的下划线的
    //key判断用
    static let languageList :[[String:String]] = [
        [
            "key":"zh-Hans",
            "resource": "zh-Hans",
            "server": "zh_CN"
        ],
        [
            "key":"zh-Hant",
            "resource": "zh-Hant",
            "server": "el_GR"
        ],
        [
            "key":"zh-Hant",
            "resource": "zh-Hant",
            "server": "zh_TC"//这里放在后面:el_GR和zh_TC都是繁体中文,因为使用的代码遍历没有break,所以后面的数据会生效
        ],
        [
            "key":"en",
            "resource": "en",
            "server": "en_US"
        ],
        [
            "key":"ko",
            "resource": "ko-KR",
            "server": "ko_KR"
        ],
        [
            "key":"vi",
            "resource": "vi",
            "server": "vi_VN"
        ],
        [
            "key":"ja",
            "resource": "ja",
            "server": "ja_JP"
        ]
//        [
//            "key":"th_TH",
//            "resource": "th-TH",
//            "server": "th_TH"
//        ],
//        [
//            "key":"id_ID",
//            "resource": "id-ID",
//            "server": "id_ID"
//        ]
    ]
    
    static let privatizationLanguageList :[[String:String]] = [
        [
            "key":"zh-Hans",
            "resource": "zh-Hans",
            "server": "zh_CN"
        ],
        [
            "key":"zh-Hant",
            "resource": "zh-Hant",
            "server": "el_GR"
        ],
        [
            "key":"zh-Hant",
            "resource": "zh-Hant",
            "server": "zh_TC"//这里放在后面:el_GR和zh_TC都是繁体中文,因为使用的代码遍历没有break,所以后面的数据会生效
        ],
        [
            "key":"en",
            "resource": "en",
            "server": "en_US"
        ],
        [
            "key":"ko",
            "resource": "ko-KR",
            "server": "ko_KR"
        ],
        [
            "key":"vi",
            "resource": "vi",
            "server": "vi_VN"
        ],
        [
            "key":"ja",
            "resource": "ja",
            "server": "ja_JP"
        ],
        [
            "key":"th_TH",
            "resource": "th-TH",
            "server": "th_TH"
        ],
        [
            "key":"id_ID",
            "resource": "id-ID",
            "server": "id_ID"
        ]
    ]
    public static var shareInstance : SupportLanguageList {
        struct Static {
            static let instance: SupportLanguageList = SupportLanguageList()
        }
        return Static.instance
    }
    
    lazy var _allLanguages: [LanguageItem] = {
        var items:[LanguageItem] = []
        for item in SupportLanguageList.languageList{
            let entity = LanguageItem.getItemFormDic(dic: item)
            items.append(entity)
        }
        return items
    }()
    
    lazy var _privateAllLanguages: [LanguageItem] = {
        var items:[LanguageItem] = []
        for item in SupportLanguageList.privatizationLanguageList{
            let entity = LanguageItem.getItemFormDic(dic: item)
            items.append(entity)
        }
        return items
    }()
}


public extension SupportLanguageList {
    
    //获取所有国家地区(默认过滤黑名单)
    private func allLanguages() -> [LanguageItem] { _allLanguages }
    //获取所有国家地区(默认过滤黑名单)
    private func privateAllLanguages() -> [LanguageItem] { _privateAllLanguages }
    
    func getLocalKeys(needFormat:Bool = false) ->[String] {
        if needFormat {
            return self.supportLans.map({return $0.server.replacingOccurrences(of: "_", with: "-")})
        }else {
            return self.supportLans.map({return $0.server})
        }
    }
    
    func getLanItem(lan:String) -> LanguageItem?{
        for item in self.supportLans {
            if lan == item.server || lan == item.server.replacingOccurrences(of: "_", with: "-"){
                return item
            }
        }
        return nil
    }
    
}
