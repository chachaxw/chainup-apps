//
//  EXSChangeLineManager.swift
//  Chainup
//
//  Created by 柴伟东 on 2022/3/9.
//  Copyright © 2022 Chainup. All rights reserved.
//

import UIKit
import Alamofire
import SwiftEventBus
import RxSwift
import EXKit
import Swap

class EXSSwapChangeHostManager: NSObject{
    static let `manager` = EXSSwapChangeHostManager()
    open class var sharedManager: EXSSwapChangeHostManager {
        return manager
    }
    
    private var timerDisposable: Disposable? = nil
    private lazy var api:EXSSwapChangeHost = {
        let a = EXSSwapChangeHost()
        a.type = .api
        return a
    }()
    private lazy var ws:EXSSwapChangeHost = {
        let a = EXSSwapChangeHost()
        a.type = .ws
        return a
    }()
    
    func changeHostLine(){
        self.api.changeHostLine()
//        pingSwapPublicInfo()
    }
    func changeWsHostline(){
        self.ws.changeWsHostline()
    }
    
    func pingSwapPublicInfo(){
        self.timerDisposable?.dispose()
        self.timerDisposable = Observable<Int>.interval(.seconds(10), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] (element) in
                guard let `self` = self else { return }
                self.onPoneAction()
            })
    }
    func onPoneAction(){
        print("====pingSwapPublicInfo===")
        EXContractNetwork.queryPublicInfo { [weak self] _ in
            self?.timerDisposable?.dispose()
        } failure: {_ in
            
        }
    }
    
}
///Find the optimal route and switch
class EXSSwapChangeHost: NSObject{
    
    private var countDownValue = 0
    private var pendingPings = [EXPing]()
    private var hostDataSource:[EXHostEntity] = []
    private var currentHost: String = ""
    private var hosts: [String]?
    var type: EXPingType = .api
    var isWorking:Bool = false
    private var lock = NSLock()
    func changeHostLine(){
        currentHost = EXNetworkDoctor.sharedManager.getNewContractAPI()
        hosts = EXNetworkDoctor.sharedManager.hosts
        type = .api
        initializeDataSource()
    }
    func changeWsHostline(){
        currentHost = EXNetworkDoctor.sharedManager.getNewContractWs()
        hosts = EXNetworkDoctor.sharedManager.wshosts
        type = .ws
        initializeDataSource()
    }
    
    
    private func initializeDataSource(){
        guard let apihosts = self.hosts,apihosts.count > 0 else {
            return
        }
        if self.isWorking == true {
            return
        }
        self.isWorking = true
        countDownValue = 0
        pendingPings.removeAll()
        hostDataSource.removeAll()
        for (_,host) in apihosts.enumerated() {
            let urlString = EXNetworkDoctor.sharedManager.changeApiTo(domain: host, oldDomainUrl: currentHost)

            let hostStatus = EXHostEntity(status: .none,
                                          host: host,
                                          selected: false )
            hostDataSource.append(hostStatus)
            let ping = EXPing(host: host,address: urlString, type: self.type)
            ping.delegate = self
            pendingPings.append(ping)
        }
        
        startPing()
    }
    ///Ws needs to be disconnected
    private func stopPing() {
        for item in pendingPings {
            item.stopWs()
        }
    }
    
    private func startPing() {
        countDownValue = 0
        for item in pendingPings {
            item.startPinging()
        }
    }
    
}
extension EXSSwapChangeHost : EXPingDelegate {
    
    func ping(_ ping: EXPing, didReceive entity: EXPingEntity) {
        lock.lock()
        countDownValue += 1
        lock.unlock()
        updateHostApitime(ping: ping, entity: entity, success: true)
        checkProcessAndRefresh()
    }
    
    func ping(_ ping: EXPing, didFail entity: EXPingEntity) {
        lock.lock()
        countDownValue += 1
        lock.unlock()
        updateHostApitime(ping: ping, entity: entity, success: false)
        checkProcessAndRefresh()
    }
    func updateHostApitime(ping: EXPing, entity:EXPingEntity, success:Bool){
        
        for (i,item) in hostDataSource.enumerated() {
            if item.host == entity.host {
                var apiTime = "+" //Failure as default
                if success {
                    apiTime = ping.type == .api ? entity.apiTime() : entity.wstime()
                }
                hostDataSource[i].apiTime = apiTime
                break
            }
        }
        
    }
    func checkProcessAndRefresh() {
        if countDownValue == pendingPings.count {
            
            let apisorted = hostDataSource.filter({return $0.apiTime != "+" }).sorted { a, b in
                let time = NumberHandler.handleDouble(a.apiTime)
                let timeB = NumberHandler.handleDouble(b.apiTime)
                return time < timeB
            }
            for item in apisorted{
//                print("Line  (item. host), time taken  (item. apiTime)")
            }
            if apisorted.count > 0 {
                let firstApi = apisorted[0]
                //Directly switch to the optimal route
//                print("Best Route= (firstApi. host)")
                switchTohost(host: firstApi.host)
            }
            
            if self.type == .ws {
                stopPing()
            }
            self.isWorking = false
            
        }
    }
    
    func switchTohost(host: String){
        if host == currentHost.hostStr() {
            return
        }
        EXNetworkDoctor.sharedManager.updateSwapDomain(selectedHost: host, isWs: self.type == .ws)
       
        if self.type == .ws { //
            
            EXSwapSocketManager.shared.reconnectServer()
            NotificationCenter.default.post(name: NSNotification.Name.init(EXContract_wslineChange_Notification), object: nil)
        }else{
//            let config = EXSwapPrivateConfig.shared
//            config.base_host =
            EXSwapPrivateConfig.shared.base_host = EXNetworkDoctor.sharedManager.getNewContractAPI()
            if  EXSwapPublicInfo.shared.marginCoinList.count == 0 {
                EXContractNetwork.queryPublicInfo { (public) in
                    
                    EXContractSDK.ex_loadFutureMarketData { (list, error) in
                        
                        if error == nil {
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: EXContract_lineChange_Notification), object: nil)
                        }
                    }
                    
                } failure: { (error) in
                }
            }else{
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: EXContract_lineChange_Notification), object: nil)
            }
        }
    }
}

