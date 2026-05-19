//
//  EXMenuSelectionModel.swift
//  Chainup
//
//  Created by liuxuan on 2023/3/23.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

let klineScaleKey = "ExKlineScaleKey"
let klineMasterIndexKey = "klineMasterIndexKey"
let klineAssitantIndexKey = "klineAssitantIndexKey"
///Selected menuMode
class EXMenuSelectionModel: NSObject {
    var scaleKey:String {
        get {
            let df = UserDefaults.standard
            if let scaleKey = df.string(forKey: klineScaleKey) {
                return scaleKey
            }else {
                let scales = EXAppConfigManager.sharedInstance.getConvenienceKlineScale()
                if scales.count > 0  {
                    return scales[0]
                }else {
                    return "15min"
                }
            }
        }
        set {
            //Set default selection value
            let defaults = UserDefaults.standard
            defaults.set(newValue, forKey:klineScaleKey)
        }
        
    }
    var masterType:MasterAlgorithmType {
        get {
            let df = UserDefaults.standard
            let masterTypeIdx = df.integer(forKey: klineMasterIndexKey)
            if let type = MasterAlgorithmType.init(rawValue: masterTypeIdx),type != .none {
                return type
            }else {
                return .MA
            }
        }
        set {
            let defaults = UserDefaults.standard
            defaults.set(newValue.rawValue, forKey:klineMasterIndexKey)
        }
    }
    
    var assitantType:AssistantAlgorithmType {
        get {
            let df = UserDefaults.standard
            let aTypeIdx = df.integer(forKey: klineAssitantIndexKey)
            if let type = AssistantAlgorithmType.init(rawValue: aTypeIdx),type != .none  {
                return type
            }else {
                return .Hides
            }
        }
        set {
            let defaults = UserDefaults.standard
            defaults.set(newValue.rawValue, forKey:klineAssitantIndexKey)
        }
    }    
}

