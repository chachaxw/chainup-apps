//
//  EXCommonApi.swift
//  Chainup
//
//  Created by 柴伟东 on 2022/3/31.
//  Copyright © 2022 Chainup. All rights reserved.
//

import UIKit
import Moya

enum EXCommonApi {
    case get_third_support_fiat //Obtain a list of legal and digital currencies for kv configuration
    case get_paycard_rate_list(fiat: String,coin: String) //Obtain a list of third-party exchange rates for the selected legal currency and digital currency
    case get_paycard_num(fiat:String,coin: String,num: String,name: String)//Name Third party name
}

extension EXCommonApi: TargetType {
    var baseURL: URL {
        return URL.init(string: EXNetworkDoctor.sharedManager.getAppAPIHost())!
        
//        switch self {
//        case .contract_agent_role:
//            return URL(string: "https://yapi.hiotc.pro/mock/50/co/agent/getAgentUser")!
//        default:
//            return URL.init(string: EXNetworkDoctor.sharedManager.getAppAPIHost())!
//        }
        
        
    }
    
    var path: String {
        switch self {
        case .get_third_support_fiat:
            return "/get_third_support_fiat"
        case .get_paycard_rate_list:
            return "/get_paycard_rate_list"
        case .get_paycard_num:
            return "/get_paycard_num"
        }
    }
    
    var method: Moya.Method {
        switch self {
//        case .getAbout:
//            return .get
        default:
            return .post
        }
    }
    
    var sampleData: Data {
        return "".data(using: String.Encoding.utf8)!
    }
    
    var task: Task {
        var parameters: [String: Any] = [:]
        switch self {
        case .get_paycard_rate_list(let fiat, let coin):
            parameters["fiat"] = fiat
            parameters["coin"] = coin
            break
        default:

            break
        }
        
        
        if self.method == .post {
            return .requestParameters(parameters: NetManager.sharedInstance.handleParamter(parameters), encoding: JSONEncoding.default)
        }else {
            switch self {
//            case .getAbout:
//                return .requestParameters(parameters: NetManager.sharedInstance.handleParamter(parameters), encoding:URLEncoding.queryString )
            default:
                return .requestParameters(parameters: NetManager.sharedInstance.handleParamter(parameters), encoding:URLEncoding.httpBody )
            }
        }
    }
    
    var headers: [String : String]? {
        let header = NetManager.sharedInstance.getHeaderParams()
        return header
    }
    
}



