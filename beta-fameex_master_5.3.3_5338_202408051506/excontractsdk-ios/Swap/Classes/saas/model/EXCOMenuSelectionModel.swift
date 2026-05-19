//
//  EXMenuSelectionModel.swift
//  Chainup
//
//  Created by liuxuan on 2023/3/23.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

let EXSklineScaleKey = "ExKlineScaleKey"
let EXSklineMasterIndexKey = "klineMasterIndexKey"
let EXSklineAssitantIndexKey = "klineAssitantIndexKey"
/// 选中的 menuMode English: /Selected menuMode
class EXCOMenuSelectionModel: NSObject {
    var scaleKey:String {
        get {
            let df = UserDefaults.standard
            if let scaleKey = df.string(forKey: EXSklineScaleKey) {
//                //print("scaleKey =\(scaleKey)")
                return scaleKey
            }else {
                let scales = EXSwapKlineDataTool.getConvenienceKlineScale()
                if scales.count > 0  {
                    return scales[0]
                }else {
                    return "15min"
                }
            }
        }
        set {
            // 设置默认选中值 English: Set default selection value
            let defaults = UserDefaults.standard
            defaults.set(newValue, forKey:EXSklineScaleKey)
        }
        
    }
   
    var masterType:EXSMasterAlgorithmType {
        get {
            let df = UserDefaults.standard
            let masterTypeIdx = df.integer(forKey: EXSklineMasterIndexKey)
            if let type = EXSMasterAlgorithmType.init(rawValue: masterTypeIdx),type != .none {
                return type
            }else {
                return .MA
            }
        }
        set {
            let defaults = UserDefaults.standard
            defaults.set(newValue.rawValue, forKey:EXSklineMasterIndexKey)
        }
    }
    
    var assitantType:EXSAssistantAlgorithmType {
        get {
            let df = UserDefaults.standard
            let aTypeIdx = df.integer(forKey: EXSklineAssitantIndexKey)
            if let type = EXSAssistantAlgorithmType.init(rawValue: aTypeIdx),type != .none  {
                return type
            }else {
                return .Hides
            }
        }
        set {
            let defaults = UserDefaults.standard
            defaults.set(newValue.rawValue, forKey:EXSklineAssitantIndexKey)
        }
    }    
}

