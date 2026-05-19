//
//  EXPlistFinder.swift
//  Chainup
//
//  Created by liuxuan on 2023/5/20.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

class ExGeTuiConfig: NSObject {
    var appId:String = ""
    var appSeceret:String = ""
    var appKey:String = ""
}

class EXPlistFinder: NSObject {
    
    var sourcePath:String? {
        guard let path = Bundle.main.path(forResource: "Info", ofType: "plist") else { return .none }
        return path
    }
    
    var sourceDict:NSDictionary {
        guard let dict = NSDictionary.init(contentsOfFile:sourcePath ?? "") else { return NSDictionary.init() }
        return dict
    }
    
    static let `manager` = EXPlistFinder()
    open class var shared: EXPlistFinder {
        return manager
    }
    
    func getGeTuiConfigs() -> ExGeTuiConfig {
        let config = ExGeTuiConfig()
        if let gtDict = sourceDict["ExSDKConfig"] as? [String :String] {
            if let appId = gtDict["pushAppId"] {
                config.appId = appId
            }
            if let appkey = gtDict["pushAppKey"] {
                config.appKey = appkey
            }
            if let appsecret = gtDict["pushAppSecret"] {
                config.appSeceret = appsecret
            }
        }
        return config
    }
}
