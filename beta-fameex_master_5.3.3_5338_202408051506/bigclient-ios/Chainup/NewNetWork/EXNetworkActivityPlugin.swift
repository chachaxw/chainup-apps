//
//  EXNetworkActivityPlugin.swift
//  Chainup
//
//  Created by 柴伟东 on 2022/3/31.
//  Copyright © 2022 Chainup. All rights reserved.
//

import UIKit
import Moya
class EXNetworkActivityPlugin: PluginType{
    
    func willSend(_ request: RequestType, target: TargetType) {
        
//        DispatchQueue.main.async {
//            ///Refresh data as empty bitmap
//            NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: relodEmptyViewKey),object: nil, userInfo: [EmptyShowKey: false])
//        }
        
        if let api = target as? EXCommonApi { //No need to rotate
            switch api {
            
            default:
                break
            }
        }
        TopVC()?.view.showLoading1()
    }
    
    func didReceive(_ result: Result<Moya.Response, MoyaError>, target: TargetType){
       
        DispatchQueue.main.async {
            TopVC()?.view.hideLoading1()
            ///Refresh data as empty bitmap
//            NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: relodEmptyViewKey),object: nil, userInfo: [EmptyShowKey: true])
        }
    }
}

