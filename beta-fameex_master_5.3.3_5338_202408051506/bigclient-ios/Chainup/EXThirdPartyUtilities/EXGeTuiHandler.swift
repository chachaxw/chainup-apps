//
//  EXGeTuiHandler.swift
//  Chainup
//
//  Created by liuxuan on 2023/5/20.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import RxSwift
import EXKit
class EXGeTuiHandler: NSObject {
    
    static let `manager` = EXGeTuiHandler()
    var cid:String = ""
    var taskId:String = ""
    let disposeBag = DisposeBag()
    
    open class var shared: EXGeTuiHandler {
        return manager
    }
    
    func register() {
        let gtSdkConfig = EXPlistFinder.shared.getGeTuiConfigs()
        if gtSdkConfig.appId.isEmpty ||
            gtSdkConfig.appKey.isEmpty ||
            gtSdkConfig.appSeceret.isEmpty {
            return
        }
//        GeTuiSdk.start(withAppId: gtSdkConfig.appId,
//                       appKey: gtSdkConfig.appKey,
//                       appSecret: gtSdkConfig.appSeceret,
//                       delegate: self)
        registerRemoteNotification()
        //Successfully monitored login
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(bindCid),
                                               name: NSNotification.Name(rawValue: "EXLoginSuccess"),
                                               object: nil)
    }
    
    func handleLaunchOptions(_ options:[UIApplication.LaunchOptionsKey: Any]?) {
        guard let remoteNotification = options?[.remoteNotification] as? [AnyHashable : Any] else {return}
        if let task = remoteNotification["_gmid_"] as? String {
            let taskids = task.components(separatedBy: ":")
            if taskids.count > 0 {
                self.taskId = taskids[0]
            }
        }
           
    }
    

    
    func bindDeviceToken(_ token:Data) {
//        GeTuiSdk.registerDeviceTokenData(token)
    }

    func registerRemoteNotification() {
        let center: UNUserNotificationCenter = UNUserNotificationCenter.current()
        center.delegate = self
        center.requestAuthorization(options: [.alert, .badge, .sound], completionHandler: { (granted: Bool, error: Error?) in
            if (granted) {
                
            } else {

            }
        })
        UIApplication.shared.registerForRemoteNotifications()
    }
    
    func getAuthorizationStatusAllowed() ->Bool  {
        var authorAllowed :Bool = false
        let semaphore = DispatchSemaphore(value:0)
        UNUserNotificationCenter.current().getNotificationSettings { (setting) in
            if setting.authorizationStatus == .authorized {
                authorAllowed = true
            }else {
                authorAllowed = false
            }
            semaphore.signal()
        }
        let timeOut = DispatchTime.now() + .seconds(5)
        if semaphore.wait(timeout: timeOut) == .timedOut {
            return false
        }
        return authorAllowed
    }
}

extension EXGeTuiHandler {
    
    @objc func bindCid() {
        if cid.isEmpty || XUserDefault.isOffLine() {
            return
        }
        appApi.rx.request(.saveAppPushDeveice(cid:cid))
            .MJObjectMap(EXVoidModel.self)
            .subscribe{ event in
                switch event {
                case .success(_):
                    break
                case .failure(_):
                    break
                }
        }.disposed(by: self.disposeBag)
    }
}

//
//extension EXGeTuiHandler:GeTuiSdkDelegate {
//    //Get a push back cid
//    func geTuiSdkDidRegisterClient(_ clientId: String!) {
//        self.cid = clientId
//    }
//
//    //Got a push through message
//    func geTuiSdkDidReceivePayloadData(_ payloadData: Data!,
//                                       andTaskId taskId: String!,
//                                       andMsgId msgId: String!,
//                                       andOffLine offLine: Bool,
//                                       fromGtAppId appId: String!) {
//        guard let data = payloadData, let payloadMsg = String(data: data, encoding: .utf8) else { return }
//        if offLine == false {
//            return
//        }
//        //Do not process from the backend to the front desk
//        if UIApplication.shared.applicationState == .inactive {
//            return
//        }
//        if self.taskId == taskId {
//            if let payloadModel = EXPayloadDataModel.mj_object(withKeyValues: payloadMsg) {
//                EXRouterHandler.shared.handleSchemeUrl(payloadModel.url)
//            }
//            self.taskId = ""
//            UIApplication.shared.applicationIconBadgeNumber = 0
//        }
//    }
//}

extension EXGeTuiHandler:UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.badge,.sound,.alert])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        
        if let task = userInfo["_gmid_"] as? String {
            let taskids = task.components(separatedBy: ":")
            if taskids.count > 0 {
                self.taskId = taskids[0]
            }
        }
        let isInactive = (UIApplication.shared.applicationState == .inactive)
        if isInactive, let payloadMsg = userInfo["payload"] as? String {
            if let payloadModel = EXPayloadDataModel.mj_object(withKeyValues: payloadMsg) {
                EXRouterHandler.shared.handleSchemeUrl(payloadModel.url)
            }
            self.taskId = ""
        }
        UIApplication.shared.applicationIconBadgeNumber = 0
//        GeTuiSdk.handleRemoteNotification(response.notification.request.content.userInfo)
        completionHandler()
    }
}

class EXPayloadDataModel:EXBaseModel {
    var title:String = ""
    var message:String = ""
    var url:String = ""
}


