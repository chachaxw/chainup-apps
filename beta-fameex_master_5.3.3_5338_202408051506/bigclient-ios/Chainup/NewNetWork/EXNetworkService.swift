////
////  EXNetworkService.swift
////  Chainup
////
////  Created by 柴伟东 on 2022/3/31.
////  Copyright © 2022 Chainup. All rights reserved.
////
//
//import UIKit
//import Moya
//import Alamofire
//let EXApiProvider = EXNetworkService(endpointClosure: ExApiEndpointClosure, requestClosure: EXRequestClosure)
//class EXNetworkService<Target> : MoyaProvider<Target> where Target : TargetType {
//    
//    init(
//        endpointClosure: @escaping MoyaProvider<Target>.EndpointClosure = MoyaProvider.defaultEndpointMapping,
//        requestClosure: @escaping MoyaProvider<Target>.RequestClosure,
//        stubClosure: @escaping MoyaProvider<Target>.StubClosure = MoyaProvider.neverStub,
//        plugins: [PluginType] = [EXNetworkActivityPlugin()]
//    ) {
//        
//        super.init(endpointClosure: endpointClosure,
//                   requestClosure: requestClosure,
//                   stubClosure: stubClosure,
//                   plugins: plugins)
//    }
//    
//}
//
//let EXRequestClosure: MoyaProvider<EXCommonApi>.RequestClosure = {( endpoint: Endpoint, closure: MoyaProvider.RequestResultClosure) in
//    do {
//        let urlRequest = try endpoint.urlRequest()
//        closure(.success(urlRequest))
//    }
//    catch {
//        
//    }
//}
//let ExApiEndpointClosure = { (target: EXCommonApi) -> Endpoint in
//    let sampleResponseClosure = { return EndpointSampleResponse.networkResponse(200, target.sampleData) }
//    let url = target.baseURL.appendingPathComponent(target.path).absoluteString
//    let method = target.method
//    
//    return Endpoint(url: url, sampleResponseClosure: sampleResponseClosure, method: target.method, task: target.task, httpHeaderFields: target.headers)
//}
//
//
