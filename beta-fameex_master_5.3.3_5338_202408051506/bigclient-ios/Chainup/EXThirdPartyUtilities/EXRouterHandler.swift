//
//  EXRouterHandler.swift
//  Chainup
//
//  Created by liuxuan on 2023/5/22.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit

enum EXHostType:String {
    case hosthome = "home"
}

enum EXRouteDestination:String {
    case slcontract = "/slContract"
    case slcontractDetial = "/slContract/detail"
    case market = "/market"
    case otc = "/otc"
    case asset = "/asset"
}


class EXRouterHandler: NSObject {
    
    static let `manager` = EXRouterHandler()
    open class var shared: EXRouterHandler {
        return manager
    }
    
    var lastVc:UIViewController?
    
    func handleSchemeUrl(_ url:String) {
        if let jumpUrl = URL.init(string:url) {
            if let scheme = jumpUrl.scheme,scheme == "chainup" {
                if let hostName = jumpUrl.host {
                    if hostName == EXHostType.hosthome.rawValue {
                        let parameters = jumpUrl.queryParameters
                    
                        switch jumpUrl.path {
                        case EXRouteDestination.market.rawValue:
                            EXTabAnchor.shared.tabAnchorTo(.exMarket,parameters:parameters)
                            let param = jumpUrl.queryParameters
                            if param.count > 0 {
                                if let currentVc = EXTabAnchor.shared.currentViewController as? EXTradeCmdProtocal {
                                    currentVc.excuteCmd(symbol: param["name"] ?? "", action: "")
                                }
                            }
                
                            break
                        case EXRouteDestination.slcontract.rawValue:
                            EXTabAnchor.shared.tabAnchorTo(.slContract,parameters: parameters)
                            break
                        case EXRouteDestination.slcontractDetial.rawValue:
                            if let currentVc = AppService.topViewController() {
                                if let contract_id = parameters["contractId"] {
                                    if let last = lastVc ,last.classForCoder == currentVc.classForCoder {
                                        
                                    }else {
                                        navigate(.slContractDetail(id: contract_id), fromVc: currentVc)
                                    }
                                }
                            }
                            break
                        default:
                            break
                        }
                        self.lastVc = AppService.topViewController()
                    }
                }
            }
        }
    }
    
}

extension EXRouterHandler {
    func navigate(_ navigation: EXPushNavigation,fromVc:UIViewController) {
        Router.default.navigate(navigation, from: fromVc)
    }
}
