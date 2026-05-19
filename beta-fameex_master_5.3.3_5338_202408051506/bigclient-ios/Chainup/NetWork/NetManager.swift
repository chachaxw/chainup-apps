//
//  NetManager.swift
//  AppProject
//
//  Created by zewu wang on 2023/7/31.
//  Copyright © 2023年 zewu wang. All rights reserved.
//

import UIKit
import Alamofire

//Network Request Status
public enum NetRequestResultState : String {
    
    case Success = "Success"//Request is correct, such as 200
    case NetFailure  = "NetFailure"   //Network failure, such as connection timeout without network
    case ServerFailure = "ServerFailure" //Server failure, such as 404 500
    case SendRequestFailure = "SendRequestFailure" //Failed to initiate request, about to fail request
}

//Define a structure to store authentication related information
struct IdentityAndTrust {
    var identityRef:SecIdentity
    var trust:SecTrust
    var certArray:AnyObject
}

public class NetManager: NSObject {
    
    var managerArray = NSMutableArray.init()
    var deviceID:String?
    //MARK: Single Example
    @objc public static var sharedInstance : NetManager{
        struct Static {
            static let instance : NetManager = NetManager()
        }
        Static.instance.deviceID = UIDevice.modelName
        return Static.instance
    }
    
    //MARK: Send Request
    public func sendRequest(_ urlString : String ,httpheaders : HTTPHeaders? = nil  , parameters : [String : Any]?, mothed : HTTPMethod = .post ,encoding : ParameterEncoding = JSONEncoding.default,isShowLoading : Bool = true ,outTime : Int = 10, requestEntity : Any? = nil, success : @escaping ((_ result : Any, _ response : AFDataResponse<Any>? , _ requestEntity : Any?) -> Void) , fail : @escaping ((_ state : NetRequestResultState, _ error: Error?, _ requestEntity:  Any?) -> Void)){
        
        let config = URLSessionConfiguration.default
        
        let delegate = SessionDelegate.init()
        let manager = Session(configuration: config, delegate: delegate, serverTrustManager: nil)
        managerArray.add(manager)//Prevent early release
        manager.session.configuration.timeoutIntervalForRequest = TimeInterval(outTime)
        var httphead = httpheaders
        if httpheaders == nil{
            let dic = getHeaderParams()
            httphead = HTTPHeaders.init(dic)
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
            
//            debugPrint("urlString=\(urlString),response =\(response)")
            guard let mySelf = self else{return}
            if isShowLoading {
                XHUDManager.sharedInstance.dismissWithDelay {
                    mySelf.handleResponse(response, requestEntity: requestEntity, isShowLoading: isShowLoading ,success: success, fail: fail)
                }
            } else {
                XHUDManager.sharedInstance.dismissWithDelay {
                    mySelf.handleResponse(response, requestEntity: requestEntity, isShowLoading: isShowLoading ,success: success, fail: fail)
                }
            }
            mySelf.managerArray.remove(manager)//Remove returned request management
        }
        
    }
//    //4.5.9_ Changehost removed the relevant code for authentication
//    func renzheng(_ requestUrl : @escaping (()->())){
//        requestUrl()
//    }
    
//    //Obtain client certificate related information
//    func extractIdentity() -> IdentityAndTrust {
//        var identityAndTrust:IdentityAndTrust!
//        var securityError:OSStatus = errSecSuccess
//
//        let path: String = Bundle.main.path(forResource: "client", ofType: "p12")!
//        let PKCS12Data = NSData(contentsOfFile:path)!
//        let key : NSString = kSecImportExportPassphrase as NSString
//        let options : NSDictionary = [key : "xxxxxxxxxxx"] //Client Certificate Password
//        //create variable for holding security information
//        //var privateKeyRef: SecKeyRef? = nil
//
//        var items : CFArray?
//
//        securityError = SecPKCS12Import(PKCS12Data, options, &items)
//
//        if securityError == errSecSuccess {
//            let certItems:CFArray = items as CFArray?;
//            let certItemsArray:Array = certItems as Array
//            let dict:AnyObject? = certItemsArray.first;
//            if let certEntry:Dictionary = dict as? Dictionary<String, AnyObject> {
//                // grab the identity
//                let identityPointer:AnyObject? = certEntry["identity"];
//                let secIdentityRef:SecIdentity = identityPointer as! SecIdentity!
//                print("\(identityPointer)  :::: \(secIdentityRef)")
//                // grab the trust
//                let trustPointer:AnyObject? = certEntry["trust"]
//                let trustRef:SecTrust = trustPointer as! SecTrust
//                print("\(trustPointer)  :::: \(trustRef)")
//                // grab the cert
//                let chainPointer:AnyObject? = certEntry["chain"]
//                identityAndTrust = IdentityAndTrust(identityRef: secIdentityRef,
//                                                    trust: trustRef, certArray:  chainPointer!)
//            }
//        }
//        return identityAndTrust;
//    }
}






