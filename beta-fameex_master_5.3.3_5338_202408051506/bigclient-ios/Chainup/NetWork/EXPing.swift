//
//  EXPing.swift
//  Chainup
//
//  Created by chainup on 2023/6/16.
//  Copyright © 2023 ChainUP. All rights reserved.
//

import UIKit
import Alamofire
import Starscream
import RxCocoa
import RxSwift
import EXKit

let defaultTimeout: TimeInterval = 5.0

struct EXPingEntity {
    
    var host:String? = nil
    var urlString:String? = nil
    var sendDate:Date? = nil
    var receiveDate:Date? = nil
    var wsConnectDate:Date? = nil

    func apiTime() -> String {
        guard let sendDate = self.sendDate,let receiveDate = self.receiveDate, receiveDate.compare(sendDate) == .orderedDescending else {
            return "+"
        }
        return String(format: "%.0f",receiveDate.timeIntervalSince(sendDate) * 1000)
    }
    
    func wstime() -> String {
        guard let sendDate = self.sendDate,let receiveDate = self.wsConnectDate, receiveDate.compare(sendDate) == .orderedDescending else {
            return "+"
        }
        return String(format: "%.0f",receiveDate.timeIntervalSince(sendDate) * 1000)
    }
    
    func rtt() -> (String,UIColor) {
        
        guard let sendDate = self.sendDate,let receiveDate = self.receiveDate, receiveDate.compare(sendDate) == .orderedDescending else {
            return ("--",UIColor.ThemeLabel.colorMedium)
        }
        let timerst = (receiveDate.timeIntervalSince(sendDate) * 1000)
        var color = UIColor.ThemeState.success

        if timerst > 300 {
            color = UIColor.extColorWithHex("#FFA757")
        }

        return (String(format: "%.0fms",timerst),color)
    }
    
    func wsRtt() -> (String,UIColor) {
        
        guard let sendDate = self.sendDate,let connectDate = self.wsConnectDate, connectDate.compare(sendDate) == .orderedDescending else {
            return ("--",UIColor.ThemeLabel.colorMedium)
        }
        
        let timerst = (connectDate.timeIntervalSince(sendDate) * 1000)
        var color = UIColor.ThemeState.success

        if timerst > 300 {
            color = UIColor.extColorWithHex("#FFA757")
        }
        return (String(format: "%.0fms",timerst),color)
    }
}

protocol EXPingDelegate {
    func ping(_ ping:EXPing, didReceive entity:EXPingEntity)
    func ping(_ ping:EXPing, didFail entity:EXPingEntity)
}


enum EXPingType {
    case api
    case ws
}

class EXPing {
    let address:String
    var type:EXPingType
    
    var delegate:EXPingDelegate? = nil
    var pingEntity = EXPingEntity()
    var socket : WebSocket? = nil
    var durationRelay = BehaviorRelay<String>(value:"")
    private var countDownTimer:Timer? = nil
    var timerDisposable: Disposable? = nil

    init(host:String,address:String,type:EXPingType) {
        self.type = type
        self.address = address
        if type == .api {
            pingEntity.host = host
            pingEntity.urlString = address
        }else {
            pingEntity.host = host
            pingEntity.urlString = address
            if let url = URL(string: address) {
                socket = WebSocket(url:url)
                socket?.delegate = self
            }
        }
    }
    
    private func initializeTimers() {
        if countDownTimer == nil {
            countDownTimer = Timer.scheduledTimer(withTimeInterval: 15, repeats: false) {[weak self] _ in
                guard let self = `self` else { return }
                if self.type == .api {
                    if self.pingEntity.receiveDate == nil {
                        self.delegate?.ping(self, didFail: self.pingEntity)
                    }
                }else if self.type == .ws {
                    if self.pingEntity.wsConnectDate == nil {
                        self.delegate?.ping(self, didFail: self.pingEntity)
                    }
                }
                self.stopTimer()
            }
        }
    }
    
    func stopTimer() {
        countDownTimer?.invalidate()
        countDownTimer = nil
    }
    
    func stopWs() {
        socket?.disconnect()
        socket = nil
        self.timerDisposable?.dispose()
    }
    
    func onsuccess() {
        self.stopTimer()
        self.pingEntity.receiveDate = Date()
        self.durationRelay.accept(self.pingEntity.apiTime())
        self.delegate?.ping(self, didReceive: self.pingEntity)
    }
    
    func onFail() {
        self.stopTimer()
        self.durationRelay.accept(self.pingEntity.apiTime())
        self.delegate?.ping(self, didFail: self.pingEntity)
    }
    
    func startPinging() {
        initializeTimers()
        pingEntity.sendDate = Date()
        pingEntity.receiveDate = nil
        if self.type == .api {
            domainSpeedTestApi.hideAutoLoading()
            let _ = domainSpeedTestApi.rx.request(.health(host: pingEntity.host ?? ""))
                .MJObjectMap(EXVoidModel.self, false)
                .subscribe(onSuccess: { [weak self] (response) in
                    guard let `self` = self else {return}
                    self.onsuccess()
                }) { (_) in
                    self.onFail()
            }
        }else {
            //Reduce the channel of the link, if the link is in progress, disconnect it first and then connect it again
            if let wss = socket {
                if  wss.isConnected {
                    wss.disconnect()
                }
                wss.connect()
            }
        }
    }
}

extension EXPing {
    
    func isConnecting() ->Bool {
        guard let ws = socket else {return false}
        return ws.isConnected
    }

    ///Start heartbeat
    private func startPong() {
        self.timerDisposable?.dispose()
        self.timerDisposable = Observable<Int>.interval(.seconds(10), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] (element) in
                guard let `self` = self else { return }
                self.onPoneAction()
            })
    }
    //Responding to heartbeat
    func onPoneAction() {
        guard let ws = socket else {return}
        if self.isConnecting() {
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: ["pong" :DateTools.getNowTimeInterval()], options: JSONSerialization.WritingOptions.prettyPrinted)
                guard let jsonStr = String.init(data: jsonData, encoding: String.Encoding.utf8) else {return}
                ws.write(string: jsonStr)
                
            } catch _ {

            }
        }
    }
    
    private func stopPong() {
//        print("Active heartbeat stop")
        self.timerDisposable?.dispose()
    }
}

extension EXPing:WebSocketDelegate {
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        stopPong()
        self.stopTimer()
        self.delegate?.ping(self, didFail: self.pingEntity)
    }
    
    func websocketDidConnect(socket: WebSocketClient) {
        startPong()
        self.stopTimer()
        self.pingEntity.wsConnectDate = Date()
        self.delegate?.ping(self, didReceive: self.pingEntity)
    }
}

