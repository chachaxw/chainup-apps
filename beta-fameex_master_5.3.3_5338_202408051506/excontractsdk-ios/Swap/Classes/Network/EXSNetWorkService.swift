//
//  NetWorkService.swift
//  Chainup
//
//  Created by liuxuan on 2023/1/21.
//  Copyright © 2023 zewu wang. All rights reserved.
//
import Moya
import RxSwift
import Alamofire

class EXSNetWorkService<Target> : MoyaProvider<Target> where Target : TargetType {
    
    var plugin:EXSMoyaLoadingPlugin?
    
    init(
        endpointClosure: @escaping MoyaProvider<Target>.EndpointClosure = MoyaProvider.defaultEndpointMapping,
        requestClosure: @escaping MoyaProvider<Target>.RequestClosure,
        stubClosure: @escaping MoyaProvider<Target>.StubClosure = MoyaProvider.neverStub,
        plugins: [PluginType] = [EXSMoyaLoadingPlugin() as PluginType]
        ) {
        
        super.init(endpointClosure: endpointClosure,
                   requestClosure: requestClosure,
                   stubClosure: stubClosure,
                   plugins: plugins)
        plugin = plugins[0] as? EXSMoyaLoadingPlugin
    }
    
    func exs_hideAutoLoading() {
        
        plugin?.noloading()
    }
}


private let requestClosure: MoyaProvider<EXContractApiEndPoint>.RequestClosure = {( endpoint: Endpoint, closure: MoyaProvider.RequestResultClosure) in
    do {
        var urlRequest = try endpoint.urlRequest()
        urlRequest.timeoutInterval = 10
        closure(.success(urlRequest))
    }
    catch {
        
    }
}


let networkApi = EXSNetWorkService<EXContractApiEndPoint>(requestClosure: requestClosure)

class EXSVoidModel: NSObject {

}
