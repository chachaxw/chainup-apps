//
//  EXSwapKlineDataTool.swift
//  Chainup
//
//  Created by cwd on 2023/1/31.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit

public class EXSwapKlineDataTool {
  
    public static let shared = EXSwapKlineDataTool()
    private init(){}
    func titles() -> [String] {
       return EXSwapKlineDataTool.klineKeys.map { item in
            return item.ex_localized()
       }
    }
    static let klineKeys = ["cp_extra_text40","cp_extra_text41","cp_extra_text42","cp_extra_text43","cp_extra_text44","cp_extra_text45","cp_extra_text46","cp_extra_text47","cp_extra_text48","cp_extra_text49"]
   
//    public func updateLankeys(){
//        self.titles = EXSwapKlineDataTool.klineKeys.map { item in
//            return item.ex_localized()
//        }
//    }
    //合约目前使用 -获取小版k线所有的时段 展示的标题 // English: 
   static func getSmallAllKlineScale() -> [String]{
       let all = EXSwapKlineDataTool.getContractSaceKeys()
        return all.map { item -> String in
            return EXSwapKlineDataTool.getkeyTitle(scale: item)
        }
        
    }
    static func getContractSaceKeys() -> [String] {
        return ["Line","1min", "5min", "15min", "30min", "60min", "4h", "1day","1week","1month"]
    }
    static func getConvenienceKlineScale() ->  [String] {
       return ["15min", "60min","4h", "1day"]
    }

    static func getOtherKlineScale() ->  [String] {
        let klineScales = getContractSaceKeys()
        let conv = getConvenienceKlineScale()
        var menus:[String] = []
        for scale in klineScales {
            if !conv.contains(scale) {
                menus.append(scale)
            }
        }
        return menus
        
    }
    //合约和币币多语言分开，所以需要获取其对应的菜单显示的标题 English: Contracts and coins are separated into multiple languages, so it is necessary to obtain their corresponding menu display titles
    static func getkeyTitle(scale: String) -> String{
        let keys = EXSwapKlineDataTool.getContractSaceKeys()
        guard let index = keys.firstIndex(of: scale) else{
            return ""
        }
        let title = EXSwapKlineDataTool.shared.titles()[index]
        return title
    }
}

