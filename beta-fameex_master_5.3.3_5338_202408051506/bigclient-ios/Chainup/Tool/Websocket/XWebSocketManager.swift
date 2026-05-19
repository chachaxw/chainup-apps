//
//  XWebSocketManager.swift
//  Chainup
//
//  Created by zewu wang on 2023/8/30.
//  Copyright © 2023年 zewu wang. All rights reserved.
//

import UIKit
import Starscream

@objc public protocol DSWebSocketDelegate: NSObjectProtocol{
/**Websocket connection successful*/
    @objc optional func websocketDidConnect(socket: XWebSocketManager)
/**Websocket connection failed*/
    @objc  optional  func websocketDidDisconnect(socket: XWebSocketManager, error: Error?)
/**Websocket accepts text messages*/
    @objc  optional func websocketDidReceiveMessage(socket: XWebSocketManager, text: String)
/**Websocket accepts binary information*/
    @objc optional  func  websocketDidReceiveData(socket: XWebSocketManager, data: Data)
}

public class XWebSocketManager: NSObject ,WebSocketDelegate {
    
    var reConnectTime = 0//Reconnection time
    
    var heartBeat : Timer?//
    
    var index : Int?
    
    var socket:WebSocket?
    
    var url = ""
    
    var key = ""

    weak var webSocketDelegate: DSWebSocketDelegate?
    
    public static var sharedInstance : XWebSocketManager{
        struct Static {
            static let instance : XWebSocketManager = XWebSocketManager()
        }
        return Static.instance
    }
    
    public func websocketDidConnect(socket: WebSocketClient) {
//NSLog ("Link Successful")
        webSocketDelegate?.websocketDidConnect?(socket: self)
    }
    
    public func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
//NSLog ("Link failed  n% @", URL)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.webSocketDelegate?.websocketDidDisconnect?(socket: self, error: error)
            //Failed reconnection
            self.disconnect()
            self.connectSever(self.url)
        }
    }
    
    public func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
//NSLog ("Message Received")
        webSocketDelegate?.websocketDidReceiveMessage?(socket: self, text: text)
    }
    
    public func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
//NSLog ("data data")
        webSocketDelegate?.websocketDidReceiveData?(socket: self, data: data)
    }
    
    //MARK: - Link server
    public func connectSever(_ urlStr : String){
        if socket == nil{
            if let url = URL.init(string:urlStr){
                self.url = urlStr
                socket = WebSocket(url: url)
                socket?.delegate = self
                socket?.connect()
            }
        }
    }
    
    //MARK: - Close message
    public func disconnect(){
        if socket != nil{
            socket?.disconnect()
            socket = nil
        }
    }
    
    //Send a text message
    public func sendBrandStr(string:String){
        socket?.write(string: string)
    }
    
    public func sendBrandStr(string:String , func1 : @escaping (() -> ())){
        socket?.write(string: string, completion: {
            func1()
        })
    }
    
    //Initialize heartbeat
    public func initHeartBeat(){
        DispatchQueue.main.async {
            self.destoryHeartBeat()
            //The heartbeat is set to 3 minutes, and the NAT timeout is usually 5 minutes
            self.heartBeat = Timer.scheduledTimer(withTimeInterval: TimeInterval.init(60), repeats: true, block: {[weak self] (timer) in
                guard let mySelf = self else{return}
                //Agree with the server what to send as a heartbeat identifier to minimize the size of heartbeat packets as much as possible
                mySelf.sendBrandStr(string: "{message:HeartBeat}")
            })
            RunLoop.current.add(self.heartBeat!, forMode: RunLoop.Mode.common)
        }
    }
    
    //Destroy Heartbeat
    public func destoryHeartBeat(){
        DispatchQueue.main.async {
            if self.heartBeat != nil{
                self.heartBeat?.invalidate()
                self.heartBeat = nil
            }
        }
    }
    
    //Reconnection mechanism
    public func reConnect(){
        self.disconnect()
        //After more than a minute, it won't be reconnected anymore, so it's reconnected five times
        if reConnectTime > 64{
            return
        }
        //Exponential growth of reconnection time 2
        if (reConnectTime == 0) {
            reConnectTime = 2;
        }else{
            reConnectTime = reConnectTime * 2;
        }
    }
    
    //pingpong
    public func ping(){
        self.socket?.write(ping: Data())
    }
    
    
}

