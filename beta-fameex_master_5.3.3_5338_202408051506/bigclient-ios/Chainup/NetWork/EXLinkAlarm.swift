//
//  EXLinkAlarm.swift
//  Chainup
//
//  Created by liuxuan on 2023/12/24.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import Alamofire
import SwiftEventBus

class LinkStatus:NSObject {
    var linkName:String = ""
    var linkStatus:String = ""
}

class EXLinkAlarm: NSObject {
    let netListen = NetworkReachabilityManager()
    var linkStatus:[String:Bool] = [:]
    var isWorking:Bool = false
    var linkIdx:Int = 0
    
    static let `manager` = EXLinkAlarm()
    open class var sharedManager: EXLinkAlarm {
        return manager
    }
    
    //Check the health of the line, and if an error is reported, automatically switch to the next line
    func changeLinkForUrgentcy() {
        if let net = netListen {
            if net.isReachable {
                self.currentLineHealthCheck()
            }
        }
    }
    
    private func currentLineHealthCheck() {
        if isWorking {
            return
        }
        isWorking = true
        if let hosts = EXNetworkDoctor.sharedManager.hosts,hosts.count > 0 {
            startCheck(link: hosts[linkIdx])
        }else {
            let currentLine = EXNetworkDoctor.sharedManager.getAppAPIHost()
            startCheck(link: currentLine.hostStr())
        }
    }
    
    private func otherLinecheck() {
        linkIdx += 1
        if let hosts = EXNetworkDoctor.sharedManager.hosts,hosts.count > linkIdx {
            startCheck(link: hosts[linkIdx])
        }
    }
    
    private func startCheck(link:String) {
        print("====,\(link)")
//        domainSpeedTestApi.hideAutoLoading()
//        domainSpeedTestApi.rx.request(.health(host:link))
//            .MJObjectMap(EXVoidModel.self, false)
//            .subscribe(onSuccess: { [weak self] (_) in
//                self?.linkStatus[link] = true
//                self?.linkSuccess(link: link)
//            }) {[weak self] (_) in
//                self?.linkStatus[link] = false
//                self?.otherLinecheck()
//            }
    }
    
    private func linkSuccess(link:String) {
        let currentLine = EXNetworkDoctor.sharedManager.getAppAPIHost()
        if currentLine.hostStr() != link {
            EXNetworkDoctor.sharedManager.changeCurrentHost(selectedHost:link)

            if EXAppMarketManager.sharedInstance.getAllCoinMapInfo().count == 0 {
                //Obtaining Public Data
                EXAppConfigManager.sharedInstance.fetchAppConfig()
                EXAppMarketManager.sharedInstance.fetchMarket()
            }
            SwiftEventBus.post(EXEventBusConst.onLinkReconnected)
        }
        isWorking = false
    }
    
}



class EXWsAlarm: NSObject {
    var linkStatus:[String:Bool] = [:]
    var isWorking:Bool = false
    var linkIdx:Int = 0

    static let `manager` = EXWsAlarm()
    open class var sharedManager: EXWsAlarm {
        return manager
    }
    
    //Check the health of the line, and if an error is reported, automatically switch to the next line
    func changeLinkForUrgentcy() {
        self.currentLineHealthCheck()
    }
    
    private func currentLineHealthCheck() {
        if isWorking {
            return
        }
        isWorking = true
        if let hosts = EXNetworkDoctor.sharedManager.wshosts,hosts.count > 0 {
            startCheck(link: hosts[linkIdx])
        }else {
            let currentLine = EXNetworkDoctor.sharedManager.currentWs
            startCheck(link: currentLine.hostStr())
        }
    }
    
    private func otherLinecheck() {
        linkIdx += 1
        if let hosts = EXNetworkDoctor.sharedManager.wshosts,hosts.count > linkIdx {
            startCheck(link: hosts[linkIdx])
        }
    }
    
    private func startCheck(link:String) {
        print("==ws===,\(link)")
        return
//        domainSpeedTestApi.hideAutoLoading()
//        domainSpeedTestApi.rx.request(.health(host:link))
//            .MJObjectMap(EXVoidModel.self, false)
//            .subscribe(onSuccess: { [weak self] (_) in
//                self?.linkStatus[link] = true
//                self?.linkSuccess(link: link)
//            }) {[weak self] (_) in
//                self?.linkStatus[link] = false
//                self?.otherLinecheck()
//            }
    }
    
    private func linkSuccess(link:String) {
        let currentLine = EXNetworkDoctor.sharedManager.currentWs
        if currentLine.hostStr() != link {
            EXNetworkDoctor.sharedManager.changeWsHost(selectedHost:link)
//            SwiftEventBus.post(EXEventBusConst.onLinkReconnected)
        }
        isWorking = false
    }
    
}

