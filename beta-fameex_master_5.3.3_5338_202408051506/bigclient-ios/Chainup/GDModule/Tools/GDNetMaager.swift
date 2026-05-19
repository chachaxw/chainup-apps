//
//  GDNetMaager.swift
//  Chainup
//
//  Created by cong.lian on 2020/4/2.
//  Copyright © 2020 zewu wang. All rights reserved.
//

import UIKit
import Alamofire

//Network Request Status
//public enum NetRequestResultState : String {
//
//    case Success = "Success"//Request is correct, such as 200
//    case NetFailure  = "NetFailure"   //Network failure, such as connection timeout without network
//    case ServerFailure = "ServerFailure" //Server failure, such as 404 500
//    case SendRequestFailure = "SendRequestFailure" //Failed to initiate request, about to fail request
//}

//Define a structure to store authentication related information
//struct IdentityAndTrust {
//    var identityRef:SecIdentity
//    var trust:SecTrust
//    var certArray:AnyObject
//}
class GDNetMaager: NSObject {
    var managerArray = NSMutableArray.init()
    
    //MARK: Single Example
    @objc public static var sharedInstance : GDNetMaager{
        struct Static {
            static let instance : GDNetMaager = GDNetMaager()
        }
        return Static.instance
    }
    
    //MARK: Send Request
    public func sendRequestGDGet(_ urlString : String ,httpheaders : HTTPHeaders = [:] , parameters : [String : Any], mothed : HTTPMethod = .get ,encoding : ParameterEncoding = JSONEncoding.default,isShowLoading : Bool = true ,outTime : Int = 10, requestEntity : Any? = nil, success : @escaping ((_ result : Any, _ response : DataResponse<Any>? , _ requestEntity : Any?) -> Void) , fail : @escaping ((_ state : NetRequestResultState, _ error: Error?, _ requestEntity:  Any?) -> Void)){
        
        let config = URLSessionConfiguration.default
        
        let delegate = SessionDelegate.init()
        
        let manager = SessionManager.init(configuration: config, delegate: delegate, serverTrustPolicyManager: nil)
        
        managerArray.add(manager)//Prevent early release
        
        manager.session.configuration.timeoutIntervalForRequest = TimeInterval(outTime)
        var httphead = httpheaders
        if httpheaders.keys.count == 0{
            httphead = getGDHeaderParams()
        }
        
        var tmpEncoding = encoding
        if mothed == .get{
            tmpEncoding = URLEncoding.httpBody
        }
        
        if isShowLoading {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
                if self.managerArray.contains(manager){
                    XHUDManager.sharedInstance.loading()
                }
            }
        }

            manager.request(urlString, method: mothed, parameters: parameters, encoding: tmpEncoding, headers: httphead).validate().responseJSON {[weak self] (response) in
                guard let mySelf = self else{return}
                if isShowLoading {
                    XHUDManager.sharedInstance.dismissWithDelay {
                        success(String(data:response.data ?? NSData() as Data, encoding: String.Encoding.utf8)! ,response,requestEntity)
                    }
                }else{
                    XHUDManager.sharedInstance.dismissWithDelay {
                        success( String(data:response.data ?? NSData() as Data, encoding: String.Encoding.utf8)! ,response,requestEntity)
                    }
                }
                mySelf.managerArray.remove(manager)//Remove returned request management
            }

    }
    
    //MARK: Get the parameters of the header
    func getGDHeaderParams() -> HTTPHeaders{
        var headParam : [String : String] = [:]
        let deviceId = BasicParameter.getUUID()//uid
        let deviceVersion = BasicParameter.getDeviceVersion()//Device version
        let deviceModel_CU = BasicParameter.getPhoneModel()//Equipment model
        let devicePhoneOS = BasicParameter.getPhoneOS()//Version model
        let deviceLanguage = BasicParameter.getPhoneLanguage()//language
        let deviceNetwork = BasicParameter.getNetStatus()//Network status
        let app_Version = BasicParameter.getAppVersion()//app version
        if let token = XUserDefault.getVauleForKey(key: XUserDefault.token) as? String{//User token
            headParam["exchange-token"] = token
            headParam["ex_token"] = token
        }else{
            headParam["exchange-token"] = ""
            headParam["ex_token"] = ""
        }
        
        let info = Bundle.main.infoDictionary
        if info?.keys.contains("exChainupBundleVersion") == true{
            if let originVersion = info!["exChainupBundleVersion"] as? String {
                headParam["exChainupBundleVersion"] = originVersion
                headParam["Build-CU"] = originVersion
            }else {
                headParam["Build-CU"] = app_Version
            }
        }else {
            headParam["Build-CU"] = app_Version
        }
        
        headParam["SysVersion-CU"] = deviceVersion
        headParam["SysSDK-CU"] = deviceVersion
        headParam["Channel-CU"] = "AppStore"
        headParam["Mobile-Model-CU"] = deviceModel_CU
        headParam["Platform-CU"] = devicePhoneOS
        headParam["UUID-CU"] = deviceId
        headParam["Network-CU"] = deviceNetwork
        headParam["exchange-client"] = "app"
        headParam["exchange-language"] = deviceLanguage
        headParam["lan"] = deviceLanguage
        //New addition
        headParam["appAcceptLanguage"] = deviceLanguage
        headParam["appChannel"] = "AppStore"
        headParam["appNetwork"] = deviceNetwork
        headParam["timezone"] = TimeZone.current.identifier
        headParam["osName"] = devicePhoneOS
        headParam["os"] = devicePhoneOS
        headParam["osVersion"] = deviceVersion
        headParam["platform"] = devicePhoneOS
        headParam["device"] = deviceId
        headParam["clientType"] = "ios"
        headParam["language"] = BasicParameter.phoneLanguage
        //Add following orders
        headParam["DEVICE-ID"] = deviceId
        
        return headParam
    }
}

