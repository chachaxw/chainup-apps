//
//  EXTracking.swift
//  Chainup
//
//  Created by liuxuan on 2020/12/30.
//  Copyright © 2020 Chainup. All rights reserved.
//

import UIKit
import RxSwift
import Reachability

public class EXTracking: NSObject {
    ///
    public static var updateUserPropertyBlock: ((String, String?) -> Void)?
    public static var updateUserIDBlock: ((String?) -> Void)?
    public static var logEventBlock: ((String, [String:Any]?) -> Void)?
    ///
    public enum GlobalAttribute:String {
        case app_version
        case network
        case lan
        case device
        case os
        case identifier
    }
    ///
    public let disposeBag = DisposeBag()
    ///
    private let reachability: Reachability? = {
        let reachability = Reachability(hostName:"www.baidu.com")
        reachability?.startNotifier()
        return reachability
    }()
    ///
    private var currentReachabilityStatus: String {
        guard let reachability = reachability else { return "NONE" }
        switch reachability.currentReachabilityStatus() {
            case .ReachableViaWiFi: return "WIFI"
            case .ReachableViaWWAN: return "WWAN"
            default: return "None"
        }
    }
    ///
    public static let shared: EXTracking = {
        let manager = EXTracking()
        manager.updateGlobalAttributes(.app_version, value:EXKitStanders.getRealAppVersion())
        manager.updateGlobalAttributes(.network,     value:manager.currentReachabilityStatus)
        manager.updateGlobalAttributes(.lan,         value:LanguageHandler.phoneLanguage)
        manager.updateGlobalAttributes(.device,      value:UIDevice.modelName)
        manager.updateGlobalAttributes(.os,          value:EXKitStanders.getPhoneOS())
        manager.updateGlobalAttributes(.identifier,  value:EXKitStanders.getUUID())
        NotificationCenter.default.rx.notification(.reachabilityChanged, object: manager.reachability).subscribe {[weak manager] _ in
            guard let manager = manager else { return }
            manager.updateGlobalAttributes(.network, value:manager.currentReachabilityStatus)
        }.disposed(by: manager.disposeBag)
        return manager
    }()
    public func updateGlobalAttributes(_ attribute:GlobalAttribute, value:String?) {
        Self.updateUserPropertyBlock?(attribute.rawValue, value)
    }
    ///
    public func login(with uid:String) {
        Self.updateUserIDBlock?(uid)
    }
    ///
    public func logout() {
        Self.updateUserIDBlock?(nil)
    }
    ///
    public func track(event:String,parameters:[String:Any]? = nil) {
        Self.logEventBlock?(event, parameters)
    }
}
