//
//  EXDomainSpeedTestEndPoint.swift
//  Chainup
//
//  Created by chainup on 2023/6/18.
//  Copyright © 2023 ChainUP. All rights reserved.
//

import Moya

enum EXDomainSpeedTestEndPoint {
    
    case health(host: String)
}

extension EXDomainSpeedTestEndPoint : TargetType {
    var baseURL: URL {
        switch self {
        case .health(let currentHost):
            if currentHost == "" {return URL.init(string: NetDefine.http_host_url)!}

            if NetDefine.match(currentHost,regularEnum: .ip) {
                let company = NetDefine.http_host_url.hostCompany()
                let currentUrlString = "https://" + currentHost + "/\(company)/"
                return  URL.init(string:currentUrlString)!
            }else {
                let oldDomain = NetDefine.http_host_url.hostStr()
                let currentUrlString = NetDefine.http_host_url.replacingOccurrences(of: oldDomain, with: currentHost)
                return  URL.init(string:currentUrlString)!
            }
        }
    }
    
    var path: String {
        switch self {
        case .health:
            return "health_check"
        }
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var sampleData: Data {
        return "".data(using: String.Encoding.utf8)!
        
    }
    
    var task: Task {
        return .requestPlain
        
    }
    
    var headers: [String : String]? {
        return nil
    }
}
