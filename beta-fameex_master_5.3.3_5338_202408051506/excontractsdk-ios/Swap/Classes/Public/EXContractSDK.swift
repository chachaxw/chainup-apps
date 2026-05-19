//
//  EXSDK.swift
//  Chainup
//
//  Created by ZYJ on 2023/10/14.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
public typealias EXRequestCallBack = (Any,NSError?) -> ();

public class EXContractSDK:NSObject {
    public static func ex_start(AppName:String, launchOption:EXSwapPrivateConfig,finish:@escaping EXRequestCallBack) {
        EXSwapPrivateConfig.shared.appName = AppName
        if (URL(string: launchOption.base_host) != nil) {
            EXSwapPrivateConfig.shared.base_host = launchOption.base_host
        }
        EXLanguageTools.shareInstance.initUserLanguage()
        
        //MARK: 未登录的默认配置 English: MARK: Default configuration not logged in
        //设置双向持仓 English: Set up two-way positions
        EXStoreData.setStoreObjectAndKey(1, key: EXS_HOLD_MODE)
        let userSeted = EXStoreData.storeBool(forKey: contract_chart_hasSeted)
        if userSeted == false{
            //默认顶部展示 English: Default Top Display
            EXStoreData.setStoreObjectAndKey(true, key: contract_chart_open)
            EXStoreData.setStoreObjectAndKey(true, key: contract_chart_top)
        }
        EXSwapPlatformSDK.shared.upDateEXKitConfigCallBack?()
        EXContractNetwork.queryPublicInfo { (public) in
            EXContractSDK.ex_loadFutureMarketData { (list, error) in
                if error == nil {
                    finish(list,nil)
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: EXContractLoadFuturesData_Notification), object: nil)
                }
            }
            
        } failure: { (error) in
        }
    }
    public static func ex_loadFutureMarketData(finish:@escaping EXRequestCallBack) {
        
        let allInfo = EXSwapPublicInfo.shared.getAllSwapInfo()
        
        if let list = allInfo, list.count > 0 {
          
            var tickers = [EXSwapItemModel]()
            for item in list {
                let itemModel = EXSwapItemModel()
                itemModel.instrument_id = item.instrument_id;
                itemModel.symbol = item.symbol;
//                itemModel.ex_contractInfo = item;
                tickers.append(itemModel)
                EXSwapPublicInfo.shared.facePrecisionDict[item.instrument_id] = item.face_value.to_Precision()
            }
            EXSwapPublicInfo.shared.setMarketTickers(tickers)
            
            finish(list,nil)
        }
    }
    
    public static func alreadLogout() {
//        debug//print("合约##清空个人数据") English: DebugPrint ("Contract # # Clearing Personal Data")
        EXSwapPersonInfo.shared.clearPersonalSwapInfo()
        EXSwapSocketManager.shared.cancel()
        EXStoreData.clearUserPreference()
    }
}

