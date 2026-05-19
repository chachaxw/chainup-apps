//
//  EXNetworkReachabilityManager.swift
//  Chainup
//
//  Created by liuxuan on 2020/6/16.
//  Copyright © 2020 zewu wang. All rights reserved.
//

import UIKit
import Alamofire
import SwiftEventBus

class EXNetworkReachabilityManager: NSObject {
    
    let netListen = NetworkReachabilityManager()
    
    static let `manager` = EXNetworkReachabilityManager()
    open class var sharedManager: EXNetworkReachabilityManager {
        return manager
    }
    
    func startListen() {
        netListen?.listener = { status in
            switch status {
            case .reachable(.ethernetOrWiFi),
                 .reachable(.wwan):
                SwiftEventBus.post(EXEventBusConst.onNetworkConnected)
                break
            case .notReachable,
                 .unknown:
                SwiftEventBus.post(EXEventBusConst.onNetworkLostConnection)
                break
            }
        }
        self.netListen?.startListening()
    }
}
