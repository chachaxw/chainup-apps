////
////  NetReachTool.swift
////  Chainup
////
////  Created by 李兵兵 on 2023/2/16.
////  Copyright © 2023 Chainup. All rights reserved.
////
//
//import Foundation
//
//
//import SwiftEventBus
//import Reachability
//public struct EXReachabilityKey {
//    public static let onNetworkConnected:String = "onNetworkConnected"
//    public static let onNetworkLostConnection:String = "onNetworkLostConnection"
//}
//
//
//public class EXNetworkReachabilityManager: NSObject {
//    let reachability = Reachability(hostName:"www.baidu.com")
//    var networkStatus:String = "NONE"
//    
//    private static let `manager` = EXNetworkReachabilityManager()
//    open class var sharedManager: EXNetworkReachabilityManager {
//        return manager
//    }
//    
//    public func startListen() {
//        if reachability != nil{
//            NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(note:)), name: .reachabilityChanged, object: reachability!)
//            reachability!.startNotifier()
//        }
//       
////        do {
////            try reachability.startNotifier()
////        } catch {
////            print("Unable to start notifier")
////        }
//    }
//    
//    @objc func reachabilityChanged(note: Notification) {
//        
//        let reachability = note.object as! Reachability
//        switch reachability.currentReachabilityStatus() {
//        case .ReachableViaWiFi:
//            self.networkStatus = "WIFI"
//            print("Reachable via WIFI")
//            SwiftEventBus.post(EXReachabilityKey.onNetworkConnected)
//        case .ReachableViaWWAN:
//            self.networkStatus = "WWAN"
//            print("Reachable via WWAN")
//            SwiftEventBus.post(EXReachabilityKey.onNetworkConnected)
//        case .NotReachable:
//            self.networkStatus = "NONE"
//            print("Reachable via NONE")
//            SwiftEventBus.post(EXReachabilityKey.onNetworkLostConnection)
////        case .none:
////            self.networkStatus = "NONE"
////            SwiftEventBus.post(EXReachabilityKey.onNetworkLostConnection)
////            print("error")
//        default:
//            break
//        }
//    }
//    
//    public func netWorkIsOn() -> Bool {
//        if reachability != nil{
//        return reachability!.currentReachabilityStatus() != .NotReachable
//        }
//        return false
//        }
//    
//    //MARK: Get network status
//    public class func getNetStatus() -> String{
//      return EXNetworkReachabilityManager.sharedManager.networkStatus
//    }
//    
//}

