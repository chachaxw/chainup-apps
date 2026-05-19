////
////  EXSChangeLineManager.swift
////  Chainup
////
////  Created by 柴伟东 on 2022/3/9.
////  Copyright © 2022 Chainup. All rights reserved.
////
//
//import UIKit
//import Alamofire
//import SwiftEventBus
//import RxSwift
//import EXKit
//import Starscream
//import RxCocoa
//
//
//
//class EXSSwapChangeHostManager: NSObject{
//    static let `manager` = EXSSwapChangeHostManager()
//    open class var sharedManager: EXSSwapChangeHostManager {
//        return manager
//    }
//    
//    private var timerDisposable: Disposable? = nil
//    private lazy var api:EXSSwapChangeHost = {
//        let a = EXSSwapChangeHost()
//        a.type = .api
//        return a
//    }()
//    private lazy var ws:EXSSwapChangeHost = {
//        let a = EXSSwapChangeHost()
//        a.type = .ws
//        return a
//    }()
//    
//    func changeHostLine(){
//        self.api.changeHostLine()
//    }
//    func changeWsHostline(){
//        self.ws.changeWsHostline()
//    }
//    
//    func pingSwapPublicInfo(){
//        self.timerDisposable?.dispose()
//        self.timerDisposable = Observable<Int>.interval(.seconds(10), scheduler: MainScheduler.instance)
//            .subscribe(onNext: { [weak self] (element) in
//                guard let `self` = self else { return }
//                self.onPoneAction()
//            })
//    }
//    func onPoneAction(){
//        //print("====pingSwapPublicInfo===")
//        EXContractNetwork.queryPublicInfo { [weak self] _ in
//            self?.timerDisposable?.dispose()
//            //print("====结束===") English: Print
//        } failure: {_ in
//            
//        }
//    }
//    
//}
/////寻找最优线路，切换 English: /Finding the optimal route and switching
//class EXSSwapChangeHost: NSObject{
//    
//    private var countDownValue = 0
//    private var pendingPings = [EXNewPing]()
//    private var hostDataSource:[EXNewHostEntity] = []
//    private var currentHost: String = ""
//    private var hosts: [String]?
//    var type: EXNewPingType = .api
//    var isWorking:Bool = false
//    private var lock = NSLock()
//    func changeHostLine(){
//        currentHost = EXSwapPrivateConfig.shared.base_host
//        hosts = EXSwapPrivateConfig.shared.hosts
//        type = .api
//        initializeDataSource()
//    }
//    func changeWsHostline(){
//        currentHost = EXSwapPrivateConfig.shared.ws
//        hosts = EXSwapPrivateConfig.shared.wshosts
//        type = .ws
//        initializeDataSource()
//    }
//    
//    
//    private func initializeDataSource(){
//        guard let apihosts = self.hosts,apihosts.count > 0 else {
//            return
//        }
//        if self.isWorking == true {
//            return
//        }
//        self.isWorking = true
//        countDownValue = 0
//        pendingPings.removeAll()
//        hostDataSource.removeAll()
//        for (_,host) in apihosts.enumerated() {
//            let urlString = EXNetworkDoctor.sharedManager.changeApiTo(domain: host, oldDomainUrl: currentHost)
//
//            let hostStatus = EXNewHostEntity(status: .none,
//                                          host: host,
//                                          selected: false )
//            hostDataSource.append(hostStatus)
//            let ping = EXNewPing(host: host,address: urlString, type: self.type)
//            ping.delegate = self
//            pendingPings.append(ping)
//        }
//        
//        startPing()
//    }
//    ///ws 需要断开 English: /Ws needs to be disconnected
//    private func stopPing() {
//        for item in pendingPings {
//            item.stopWs()
//        }
//    }
//    
//    private func startPing() {
//        countDownValue = 0
//        for item in pendingPings {
//            item.startPinging()
//        }
//    }
//    
//}
//extension EXSSwapChangeHost : EXNewPingDelegate {
//    
//    func ping(_ ping: EXNewPing, didReceive entity: EXNewPingEntity) {
//        lock.lock()
//        countDownValue += 1
//        lock.unlock()
//        updateHostApitime(ping: ping, entity: entity, success: true)
//        checkProcessAndRefresh()
//    }
//    
//    func ping(_ ping: EXNewPing, didFail entity: EXNewPingEntity) {
//        lock.lock()
//        countDownValue += 1
//        lock.unlock()
//        updateHostApitime(ping: ping, entity: entity, success: false)
//        checkProcessAndRefresh()
//    }
//    func updateHostApitime(ping: EXNewPing, entity:EXNewPingEntity, success:Bool){
//        
//        for (i,item) in hostDataSource.enumerated() {
//            if item.host == entity.host {
//                var apiTime = "+" //失败为默认 English: Failure as default
//                if success {
//                    apiTime = ping.type == .api ? entity.apiTime() : entity.wstime()
//                }
//                hostDataSource[i].apiTime = apiTime
//                break
//            }
//        }
//        
//    }
//    func checkProcessAndRefresh() {
//        if countDownValue == pendingPings.count {
//            
//            let apisorted = hostDataSource.filter({return $0.apiTime != "+" }).sorted { a, b in
//                let time = NumberHandler.handleDouble(a.apiTime)
//                let timeB = NumberHandler.handleDouble(b.apiTime)
//                return time < timeB
//            }
//            for item in apisorted{
//                //print("线路\(item.host),耗时\(item.apiTime)") English: Print ("Line \ (item. host), Time taken \ (item. apiTime)")
//            }
//            if apisorted.count > 0 {
//                let firstApi = apisorted[0]
//                // 直接切换最优线路 English: Directly switch to the optimal route
//                //print("最优路线 = \(firstApi.host)") English: Print ("Optimal route=\ (firstApi. host)")
//                switchTohost(host: firstApi.host)
//            }
//            
//            if self.type == .ws {
//                stopPing()
//            }
//            self.isWorking = false
//            
//        }
//    }
//    
//    func switchTohost(host: String){
//        if host == currentHost.hostStr() {
//            return
//        }
//        EXNetworkDoctor.sharedManager.updateSwapDomain(selectedHost: host, isWs: self.type == .ws)
//       
//        if self.type == .ws { //
//            
//            EXSwapSocketManager.shared.reconnectServer()
//            NotificationCenter.default.post(name: NSNotification.Name.init(EXContract_wslineChange_Notification), object: nil)
//        }else{
//            if  EXSwapPublicInfo.shared.marginCoinList.count == 0 {
//                EXContractNetwork.queryPublicInfo { (public) in
//                    EXContractSDK.ex_loadFutureMarketData { (list, error) in
//                        
//                        if error == nil {
//                            NotificationCenter.default.post(name: NSNotification.Name.init(EXContract_lineChange_Notification), object: nil)
//                        }
//                    }
//                    
//                } failure: { (error) in
//                }
//            }else{
//                NotificationCenter.default.post(name: NSNotification.Name.init(EXContract_lineChange_Notification), object: nil)
//            }
//        }
//    }
//}
//
//
//struct EXNewPingEntity {
//    
//    var host:String? = nil
//    var urlString:String? = nil
//    var sendDate:Date? = nil
//    var receiveDate:Date? = nil
//    var wsConnectDate:Date? = nil
//
//    func apiTime() -> String {
//        guard let sendDate = self.sendDate,let receiveDate = self.receiveDate, receiveDate.compare(sendDate) == .orderedDescending else {
//            return "+"
//        }
//        return String(format: "%.0f",receiveDate.timeIntervalSince(sendDate) * 1000)
//    }
//    
//    func wstime() -> String {
//        guard let sendDate = self.sendDate,let receiveDate = self.wsConnectDate, receiveDate.compare(sendDate) == .orderedDescending else {
//            return "+"
//        }
//        return String(format: "%.0f",receiveDate.timeIntervalSince(sendDate) * 1000)
//    }
//    
//    func rtt() -> (String,UIColor) {
//        
//        guard let sendDate = self.sendDate,let receiveDate = self.receiveDate, receiveDate.compare(sendDate) == .orderedDescending else {
//            return ("--",UIColor.ThemeLabel.colorMedium)
//        }
//        let timerst = (receiveDate.timeIntervalSince(sendDate) * 1000)
//        var color = UIColor.ThemeState.success
//
//        if timerst > 300 {
//            color = UIColor.extColorWithHex("#FFA757")
//        }
//
//        return (String(format: "%.0fms",timerst),color)
//    }
//    
//    func wsRtt() -> (String,UIColor) {
//        
//        guard let sendDate = self.sendDate,let connectDate = self.wsConnectDate, connectDate.compare(sendDate) == .orderedDescending else {
//            return ("--",UIColor.ThemeLabel.colorMedium)
//        }
//        
//        let timerst = (connectDate.timeIntervalSince(sendDate) * 1000)
//        var color = UIColor.ThemeState.success
//
//        if timerst > 300 {
//            color = UIColor.extColorWithHex("#FFA757")
//        }
//        return (String(format: "%.0fms",timerst),color)
//    }
//}
//
//protocol EXNewPingDelegate {
//    func ping(_ ping:EXNewPing, didReceive entity:EXNewPingEntity)
//    func ping(_ ping:EXNewPing, didFail entity:EXNewPingEntity)
//}
//
//
//enum EXNewPingType {
//    case api
//    case ws
//}
//
//class EXNewPing {
//    let address:String
//    var type:EXNewPingType
//    
//    var delegate:EXNewPingDelegate? = nil
//    var pingEntity = EXNewPingEntity()
//    var socket : WebSocket? = nil
//    var durationRelay = BehaviorRelay<String>(value:"")
//    private var countDownTimer:Timer? = nil
//    var timerDisposable: Disposable? = nil
//
//    init(host:String,address:String,type:EXNewPingType) {
//        self.type = type
//        self.address = address
//        if type == .api {
//            pingEntity.host = host
//            pingEntity.urlString = address
//        }else {
//            pingEntity.host = host
//            pingEntity.urlString = address
//            if let url = URL(string: address) {
//                socket = WebSocket(url:url)
//                socket?.delegate = self
//            }
//        }
//    }
//    
//    private func initializeTimers() {
//        if countDownTimer == nil {
//            countDownTimer = Timer.scheduledTimer(withTimeInterval: 15, repeats: false) {[weak self] _ in
//                guard let self = `self` else { return }
//                if self.type == .api {
//                    if self.pingEntity.receiveDate == nil {
//                        self.delegate?.ping(self, didFail: self.pingEntity)
//                    }
//                }else if self.type == .ws {
//                    if self.pingEntity.wsConnectDate == nil {
//                        self.delegate?.ping(self, didFail: self.pingEntity)
//                    }
//                }
//                self.stopTimer()
//            }
//        }
//    }
//    
//    func stopTimer() {
//        countDownTimer?.invalidate()
//        countDownTimer = nil
//    }
//    
//    func stopWs() {
//        socket?.disconnect()
//        socket = nil
//        self.timerDisposable?.dispose()
//    }
//    
//    func onsuccess() {
//        self.stopTimer()
//        self.pingEntity.receiveDate = Date()
//        self.durationRelay.accept(self.pingEntity.apiTime())
//        self.delegate?.ping(self, didReceive: self.pingEntity)
//    }
//    
//    func onFail() {
//        self.stopTimer()
//        self.durationRelay.accept(self.pingEntity.apiTime())
//        self.delegate?.ping(self, didFail: self.pingEntity)
//    }
//    
//    func startPinging() {
//        initializeTimers()
//        pingEntity.sendDate = Date()
//        pingEntity.receiveDate = nil
//        if self.type == .api {
//            domainSpeedTestApi.hideAutoLoading()
//            let _ = domainSpeedTestApi.rx.request(.health(host: pingEntity.host ?? ""))
//                .MJObjectMap(EXSVoidModel.self, false)
//                .subscribe(onSuccess: { [weak self] (response) in
//                    guard let `self` = self else {return}
//                    self.onsuccess()
//                }) { (_) in
//                    self.onFail()
//            }
//        }else {
//            //减少链接的通道，如果链接中，先断开，再连 English: Reduce the channels for links. If the link is in progress, disconnect it first and then connect it again
//            if let wss = socket {
//                if  wss.isConnected {
//                    wss.disconnect()
//                }
//                wss.connect()
//            }
//        }
//    }
//}
//
//extension EXNewPing {
//    
//    func isConnecting() ->Bool {
//        guard let ws = socket else {return false}
//        return ws.isConnected
//    }
//
//    /// 开始心跳 English: /Start heartbeat
//    private func startPong() {
//        self.timerDisposable?.dispose()
//        self.timerDisposable = Observable<Int>.interval(.seconds(10), scheduler: MainScheduler.instance)
//            .subscribe(onNext: { [weak self] (element) in
//                guard let `self` = self else { return }
//                self.onPoneAction()
//            })
//    }
//    // 响应心跳 English: Responding to heartbeat
//    func onPoneAction() {
//        guard let ws = socket else {return}
//        if self.isConnecting() {
//            do {
//                let jsonData = try JSONSerialization.data(withJSONObject: ["pong" :DateTools.getNowTimeInterval()], options: JSONSerialization.WritingOptions.prettyPrinted)
//                guard let jsonStr = String.init(data: jsonData, encoding: String.Encoding.utf8) else {return}
//                ws.write(string: jsonStr)
//                
//            } catch _ {
//
//            }
//        }
//    }
//    
//    private func stopPong() {
////        debug//print("心跳主动停止") English: DebugPrint ("heartbeat actively stops")
//        self.timerDisposable?.dispose()
//    }
//}
//
//extension EXNewPing:WebSocketDelegate {
//    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
//        
//    }
//    
//    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
//        
//    }
//    
//    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
//        stopPong()
//        self.stopTimer()
//        self.delegate?.ping(self, didFail: self.pingEntity)
//    }
//    
//    func websocketDidConnect(socket: WebSocketClient) {
//        startPong()
//        self.stopTimer()
//        self.pingEntity.wsConnectDate = Date()
//        self.delegate?.ping(self, didReceive: self.pingEntity)
//    }
//}
//
//
//
//enum EXNewHostStatus {
//
//    case none
//    case testing
//    case success
//    case unusable
//}
//
//struct EXNewHostEntity {
//    var status:EXNewHostStatus = .none {
//        didSet {
//            if status == .unusable {
////                apiRtt = "customSetting_action_unusable".localized()
//                rttColor = UIColor.ThemeState.fail
////                wsRtt = "customSetting_action_unusable".localized()
//                wsrttColor = UIColor.ThemeState.fail
//            }else if status == .testing {
////                apiRtt = "customSetting_action_testing".localized()
//                rttColor = UIColor.ThemeLabel.colorMedium
////                wsRtt = "customSetting_action_testing".localized()
//                wsrttColor = UIColor.ThemeLabel.colorMedium
//            }
//
//        }
//    }
//    var host = ""
//    var responseTimeStr = ""
//    var selected:Bool = false
//    var wsSelected:Bool = false
//    var apiRtt:String = "--"
//    var wsRtt:String = "--"
//    var rttColor:UIColor = UIColor.ThemeLabel.colorMedium
//    var wsrttColor:UIColor = UIColor.ThemeLabel.colorMedium
//    var apiTime:String = "--"
//    var wsTime:String = "--"
//
//    func statusStr() ->String {
//        return ""
////        switch status {
////        case .testing:
////           // return LanguageTools.getString(key: "customSetting_action_testing")
////        case .success:
////           // return "\(LanguageTools.getString(key: "customSetting_action_response"))\(responseTimeStr)"
////        case .unusable:
////           // return LanguageTools.getString(key: "customSetting_action_unusable")
////        default:
////           return ""
////        }
//    }
//}

