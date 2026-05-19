//
//  RxCustomObjMapper.swift
//  Chainup
//
//  Created by liuxuan on 2023/1/21.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
//import Result
import Moya
import MJExtension
import Alamofire
import Swap
import HandyJSON
import EXKit
func getResponseStr(_ code:Int) -> String{
    switch code{
    case NSURLErrorTimedOut , 408:
        return "common_tip_networkTimeout".localized()
    case 403:
        return "common_tip_networkDisconnect".localized()
    case 404:
        return "common_tip_networkDisconnect".localized()
    case NSURLErrorCannotConnectToHost , NSURLErrorNetworkConnectionLost , NSURLErrorNotConnectedToInternet:
        return "common_tip_networkDisconnect".localized()
    default:
        if code >= 500 ,code < 600{
            return "common_tip_networkDisconnect".localized()
        }
    }
    return ""
}
public extension PrimitiveSequence where Trait == SingleTrait, Element == Response {
    
    func MJObjectMap<T>(_ type: T.Type,_ handleErr:Bool = true, customHandleCode: (() -> (String))? = nil,errorMsg:((String) -> ())? = nil,successMsg:((String) -> ())? = nil) -> Single<T> {
        
        return flatMap { response in
//            #if DEBUG
//
            //debugPrint("request：",response.request?.url ?? "None")
//            let body = response.request.flatMap { $0.httpBody.map { String(decoding: $0, as: UTF8.self) } } ?? "None"
//            debugPrint("Parameter：",body)
//            #endif
            
            if let code = response.response?.statusCode{
                let str = getResponseStr(code)
                if str.count > 0 {
                    #if DEBUG
                    debugPrint("ERROR：\(str) url => \(response.request?.url)")
                    #endif
                    if handleErr == true{
                        EXAlert.showFail(msg: str)
                        throw CustomNetworkError.ParseJSONError
                    }
                    EXLinkAlarm.sharedManager.changeLinkForUrgentcy()
                }
            }
            

            guard let json = try response.mapJSON() as? [String: Any] else {
                throw CustomNetworkError.ParseJSONError
            }

            #if DEBUG
//DebugPrint ("Return:", try response. mapString(). util_ SubString (end: 300)
//DebugPrint ("Return:", try response. mapString())
//            debugPrint("=======================================")
            #endif

            var strCode:String = "0"//Default Success
            if let code = json["code"] as? String {
                strCode = code
            }else if let code = json["code"] as? Int {
                strCode = "\(code)"
            }else {
                throw CustomNetworkError.ParseJSONError
            }
//            strCode = "109108"
            ///Error code for IP restricted login
//            if strCode == "109108" ||
            if  strCode == "109109" {
                EXIPLimitManger.shared.limitAlertShow(result: json)
                throw CustomNetworkError.ParseJSONError
            }
            if strCode == "10016"{ //user not exist
                
                if let msg = json["msg"] as? String{
                    EXAlert.showFail(msg: msg)
                }
                
                XUserDefault.setFaceIdOrTouchId("")
                XUserDefault.setGesturesPassword("")
                XUserDefault.quickTokenValue = nil
                XUserDefault.tokenValue = nil
                EXSwapPlatformSDK.shared.activeAccount = nil
//                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//                    BusinessTools.logoutNet()
//                    BusinessTools.modalLoginVC()
//                }

                throw CustomNetworkError.ParseJSONError
            }
            if strCode == "0" {
                
                if successMsg != nil{
                    if let msg = json["msg"] as? String {
                        successMsg!(msg)
                        let obj = (type as! NSObject.Type).mj_object(withKeyValues: ["data":""]) as! T
                        return Single.just(obj)
                    }
                }
                
                if let path = response.request?.url?.path {
                    if path.contains("health_check") {
                        //Just pick one up
                        let obj = (type as! NSObject.Type).mj_object(withKeyValues: ["data":""]) as! T
                        return Single.just(obj)
                    }
                }
                
                guard let data = json["data"] else {
                    throw  CustomNetworkError.ParseDataError
                }
                
                if let result = data as? [[String: Any]] {
                    //This is connected using CommonAryModel.self
                    let obj = (type as! NSObject.Type).mj_object(withKeyValues:["dictAry":result]) as! T
                    return Single.just(obj)
                }
                else if let result = data as? [String: Any] {
                    let obj = (type as! NSObject.Type).mj_object(withKeyValues: result) as! T
                    return Single.just(obj)
                }
                else if let result = data as? String {
                    //This is connected using CommonStringModel
                    let obj = (type as! NSObject.Type).mj_object(withKeyValues:["msg":result]) as! T
                    return Single.just(obj)
                }
                    //Some servers return 0 with null data
                else if let _ = data as? NSNull {
                    //This is connected using CommonStringModel
                    let obj = (type as! NSObject.Type).mj_object(withKeyValues:["msg":""]) as! T
                    return Single.just(obj)
                }else {
                    //And return int/double, all as if he was successful
                    let obj = (type as! NSObject.Type).mj_object(withKeyValues:["msg":""]) as! T
                    return Single.just(obj)
                }
            }else {
#if DEBUG
                debugPrint("ERROR：\(strCode) url => \(response.request?.url)")
#endif
                //test
                if let code = customHandleCode?(), (code == "10021" && strCode == "10021") {
                    throw CustomNetworkError.ExpireTokenError
                }else if strCode == "110501" {
                    EXAlert.dismiss()
                    if let msg = json["msg"] as? String{
                        EXAlert.showFail(msg: msg)
                    }
                    XUserDefault.setFaceIdOrTouchId("")
                    XUserDefault.setGesturesPassword("")
                    XUserDefault.quickTokenValue = nil
                    XUserDefault.tokenValue = nil
                    EXSwapPlatformSDK.shared.activeAccount = nil
                    if let v = TopVC(), v.isKind(of: EXAccountActionVc.self) || v.isKind(of: EXAccountNewPasswordVc.self){ //If logging out on the login interface without jumping to avoid looping
                        throw CustomNetworkError.accountdeleted
//
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        BusinessTools.logoutNet()
                        BusinessTools.modalLoginVC()
                        
                    }
                    throw CustomNetworkError.accountdeleted
                }else if strCode == "10002" || strCode == "10021" || strCode == "3" {//3 is a contract
                    XUserDefault.tokenValue = nil
                    EXSwapPlatformSDK.shared.activeAccount = nil
                    BusinessTools.logoutNet()
                    EXAlert.dismissEnd {
                        if handleErr{
                            if let msg = json["msg"] as? String{
                                EXAlert.showFail(msg: msg)
                            }
                        }
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        BusinessTools.modalLoginVC()
                    }
                    throw CustomNetworkError.ExpireTokenError
                }else if strCode == "10055" {//Sliding verification error, update public_ Info_ V5, because the validation method may have been modified or turned off
                    EXAppConfigManager.sharedInstance.fetchAppConfig()
                    throw CustomNetworkError.CaptchaError
                }else {
                    var shouldHandleErr = handleErr
                    if strCode == "200002" || strCode == "108001"{ //108001 Quick Login Expired
                        shouldHandleErr = false
                    }
                    let codeInt = Int(strCode)
                    if let code = codeInt,let msg = json["msg"] as? String {
                        let error = NSError(domain: "CustomNetworkError", code: code, userInfo:  [NSLocalizedDescriptionKey: msg])
                        if shouldHandleErr {
                            EXAlert.showFail(msg: msg)
                        }else{
                            errorMsg?(msg)
                        }
                        throw error
                    }else {
                        throw CustomNetworkError.ParseJSONError
                    }
                }
            }
        }.catchError { error in
            if let moyaerror = error as? MoyaError {
                EXLinkAlarm.sharedManager.changeLinkForUrgentcy()
                switch moyaerror {
                case .underlying(let nserror,_):
                    let nsError = nserror as NSError
                    if let api = nsError.userInfo["NSErrorFailingURLStringKey"] as? String {
                        let errorMsg = "\(api)_\(nsError.localizedDescription)_\(nsError.code)"
                        EXTracking.shared.track(event: .httpError, info:["errorApI":errorMsg])
                    }
                default:
                    break
                }
            }
            throw error
        }
    }
    
    
    
    func customObjectMap<T:HandyJSON>(_ type: T.Type,_ handleErr:Bool = true,errorModelCall: Bool? = false,customHandleCode: (() -> (String))? = nil,designatedPath: String? = nil) -> Single<T> {
        
        return flatMap { response in
            #if DEBUG
            
            debugPrint("request：",response.request?.url ?? "None")
            let body = response.request.flatMap { $0.httpBody.map { String(decoding: $0, as: UTF8.self) } } ?? "None"
            debugPrint("Parameter:", body)
            #endif
            
            if let code = response.response?.statusCode{
                let str = getResponseStr(code)
                if str.count > 0 {
                    #if DEBUG
                    debugPrint("ERROR：\(str) url => \(response.request?.url)")
                    #endif
                    if handleErr == true{
                        EXAlert.showFail(msg: str)
                        throw CustomNetworkError.ParseJSONError
                    }
                    EXLinkAlarm.sharedManager.changeLinkForUrgentcy()
                }
            }
            

            guard let json = try response.mapJSON() as? [String: Any] else {
                throw CustomNetworkError.ParseJSONError
            }

            #if DEBUG
//DebugPrint ("Return:", try response. mapString(). util_ SubString (end: 300)
//            debugPrint("=======================================")
            #endif

            var strCode:String = "0"//Default Success
            if let code = json["code"] as? String {
                strCode = code
            }else if let code = json["code"] as? Int {
                strCode = "\(code)"
            }else {
                throw CustomNetworkError.ParseJSONError
            }
//            strCode = "109108"
            ///Error code for IP restricted login
            if strCode == "109109" {
                EXIPLimitManger.shared.limitAlertShow(result: json)
                throw CustomNetworkError.ParseJSONError
            }
            if strCode == "0" {
                if type == EXVoidModel.self {
                    return Single.just(EXVoidModel() as! T)
                }
                if type == EXEmailResultModel.self {
                    let m = EXEmailResultModel()
                    m.pass = true
                    return Single.just(m as! T)
                }
                
                guard let data = json["data"] else {
                    throw  CustomNetworkError.ParseDataError
                }
                
                if let result = data as? [String: Any] {
                    if designatedPath != nil{
                        if let obj = type.deserialize(from: result, designatedPath: designatedPath!){
                            return Single.just(obj)
                        }
                    }else{
                        if let obj = type.deserialize(from: result){
                            return Single.just(obj)
                        }
                    }
                }
                throw  CustomNetworkError.ParseDataError
            }else {
#if DEBUG
                debugPrint("ERROR：\(strCode) url => \(response.request?.url)")
#endif
                if strCode == "10022" {
                    guard let data = json["data"] else {
                        throw  CustomNetworkError.ParseDataError
                    }
                    if let result = data as? [String: Any] {
                        if designatedPath != nil{
                            if let obj = type.deserialize(from: result, designatedPath: designatedPath!){
                                return Single.just(obj)
                            }
                        }else{
                            if let obj = type.deserialize(from: result){
                                return Single.just(obj)
                            }
                        }
                    }
                    throw CustomNetworkError.ParseDataError
                }
                
                if let code = customHandleCode?(), (code == "10021" && strCode == "10021") {
                    throw CustomNetworkError.ExpireTokenError
                }else if strCode == "110501" {
                    XUserDefault.setFaceIdOrTouchId("")
                    XUserDefault.setGesturesPassword("")
                    XUserDefault.quickTokenValue = nil
                    XUserDefault.tokenValue = nil
                    EXSwapPlatformSDK.shared.activeAccount = nil
                    BusinessTools.logoutNet()
                    BusinessTools.modalLoginVC()
                    throw CustomNetworkError.accountdeleted
                }else if strCode == "10002" || strCode == "10021" || strCode == "3" {//3 is a contract
                    EXAlert.dismiss()
                    XUserDefault.tokenValue = nil
                    EXSwapPlatformSDK.shared.activeAccount = nil
                    BusinessTools.logoutNet()
                    BusinessTools.modalLoginVC()
                    throw CustomNetworkError.ExpireTokenError
                }else if strCode == "10055" {//Sliding verification error, update public_ Info_ V5, because the validation method may have been modified or turned off
                    EXAppConfigManager.sharedInstance.fetchAppConfig()
                    throw CustomNetworkError.CaptchaError
                }else {
                    var shouldHandleErr = handleErr
                    if strCode == "200002" {
                        shouldHandleErr = false
                    }
                    let codeInt = Int(strCode)
                    if let code = codeInt,let msg = json["msg"] as? String {
                        let error = NSError(domain: "CustomNetworkError", code: code, userInfo:  [NSLocalizedDescriptionKey: msg])
                        if shouldHandleErr {
                            EXAlert.showFail(msg: msg)
                        }
                        throw error
                    }else {
                        throw CustomNetworkError.ParseJSONError
                    }
                }

            }
        }.catchError { error in
            if let moyaerror = error as? MoyaError {
                EXLinkAlarm.sharedManager.changeLinkForUrgentcy()
                switch moyaerror {
                case .underlying(let nserror,_):
                    let nsError = nserror as NSError
                    if let api = nsError.userInfo["NSErrorFailingURLStringKey"] as? String {
                        let errorMsg = "\(api)_\(nsError.localizedDescription)_\(nsError.code)"
                        EXTracking.shared.track(event: .httpError, info:["errorApI":errorMsg])
                    }
                default:
                    break
                }
            }
            throw error
        }
    }
    
    func customArrayMap<T:HandyJSON>(_ type: T.Type,_ handleErr:Bool = true, customHandleCode: (() -> (String))? = nil,designatedPath: String? = nil) -> Single<[T?]?> {
        
        return flatMap { response in
            #if DEBUG
            //DebugPrint ("Request:", response. request?. URL?? "None")
            let body = response.request.flatMap { $0.httpBody.map { String(decoding: $0, as: UTF8.self) } } ?? "None"
            //DebugPrint ("Parameter:", body)
            #endif
            
            if let code = response.response?.statusCode{
                let str = getResponseStr(code)
                if str.count > 0 {
                    #if DEBUG
                    debugPrint("ERROR：\(str) url => \(response.request?.url)")
                    #endif
                    if handleErr == true{
                        EXAlert.showFail(msg: str)
                        throw NSError(domain: "CustomNetworkError", code: code, userInfo: [NSLocalizedDescriptionKey:str])
                    }
                }
            }
            guard let json = try response.mapJSON() as? [String: Any] else {
                throw CustomNetworkError.ParseJSONError
            }

            #if DEBUG
            #endif

            var strCode:String = "0"//Default Success
            if let code = json["code"] as? String {
                strCode = code
            }else if let code = json["code"] as? Int {
                strCode = "\(code)"
            }else {
                throw CustomNetworkError.ParseJSONError
            }

            if strCode == "0" {
                guard let data = json["data"] else {
                    throw  CustomNetworkError.ParseDataError
                }
                if let result = data as? [[String: Any]] {
                    if let obj = [T].deserialize(from: result){
                        return Single.just(obj)
                    }
                }
                throw  CustomNetworkError.ParseDataError
            }else {
                
                if let code = customHandleCode?(), (code == "10021" && strCode == "10021") {
                    throw CustomNetworkError.ExpireTokenError
                }
                else if strCode == "10002" || strCode == "10021" || strCode == "3" {//3 is a contract
                    
                    
                    EXSwapPlatformSDK.shared.activeAccount = nil
                    EXContractSDK.alreadLogout()
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "Logout_notification_name"), object: nil)
                    throw CustomNetworkError.ExpireTokenError
                }else if strCode == "10055" {//Sliding verification error, update public_ Info_ V5, because the validation method may have been modified or turned off
                    throw CustomNetworkError.CaptchaError
                }else {
                    var shouldHandleErr = handleErr
                    if strCode == "200002" {
                        shouldHandleErr = false
                    }
                    let codeInt = Int(strCode)
                    if let code = codeInt,let msg = json["msg"] as? String {
                        let error = NSError(domain: "CustomNetworkError", code: code, userInfo:  [NSLocalizedDescriptionKey: msg])
                        if shouldHandleErr {
                            EXAlert.showFail(msg:msg)
                        }
                        throw error
                    }else {
                        throw CustomNetworkError.ParseJSONError
                    }
                }
            }
        }.catchError { error in
            if let moyaerror = error as? MoyaError {
                switch moyaerror {
                case .underlying(let nserror,_):
                    let nsError = nserror as NSError
                    if let api = nsError.userInfo["NSErrorFailingURLStringKey"] as? String {
                        let errorMsg = "\(api)_\(nsError.localizedDescription)_\(nsError.code)"
//                        EXNewTracking.shared.track(event: .httpError, info:["errorApI":errorMsg])
                    }
                default:
                    break
                }
            }
            throw error
        }
    }
}

enum CustomNetworkError: String {
    case ParseJSONError = "Network Error"//Parsing error
    case ExpireTokenError = "ExpireTokenError"//token
    case ParseDataError = "Data Error"//No data error
    case CaptchaError = "Captcha Error"//Sliding verification error
    case accountdeleted = "accountdeleted"//token

}

extension CustomNetworkError: Swift.Error {
    
}

