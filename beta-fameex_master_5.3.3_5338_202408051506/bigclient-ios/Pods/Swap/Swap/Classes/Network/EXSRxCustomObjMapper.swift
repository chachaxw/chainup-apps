//
//  RxCustomObjMapper.swift
//  Chainup
//
//  Created by liuxuan on 2023/1/21.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Moya
import MJExtension
import HandyJSON
import YYModel
import EXKit
public extension PrimitiveSequence where Trait == SingleTrait, Element == Response {
    //MARK: fix 检查币币使用此语言是否有 English: MARK: Fix Check if the currency is used in this language
    func getResponseStr(_ code:Int) -> String{
        switch code{
        case NSURLErrorTimedOut , 408:
            return "common_tip_networkTimeout".ex_localized()
        case 403:
            return "common_tip_networkDisconnect".ex_localized()
        case 404:
            return "common_tip_networkDisconnect".ex_localized()
        case 500:
            return "cp_extra_text12".ex_localized()
        case NSURLErrorCannotConnectToHost , NSURLErrorNetworkConnectionLost , NSURLErrorNotConnectedToInternet:
            return "common_tip_networkDisconnect".ex_localized()
        default:
            if code > 500,code < 600{
                return "common_tip_networkDisconnect".ex_localized()
            }
        }
        return ""
    }
    
   func exs_MJObjectMap<T>(_ type: T.Type,_ handleErr:Bool = true) -> Single<T> {
        return flatMap { response in
            #if DEBUG
//            //print("=======================================\n")
//            //print("请求：",response.request?.url ?? "None") English: Print ("Request:", response. request?. URL?? "None")
            let body = response.request.flatMap { $0.httpBody.map { String(decoding: $0, as: UTF8.self) } } ?? "None"
//            //print("参数：",body) English: Print ("Parameter:", body)
//            //print("\n=======================================")
            #endif
            
            if let code = response.response?.statusCode{
                let str = self.getResponseStr(code)
                if str.count > 0 {
                    #if DEBUG
                  //print("ERROR：\(str) url => \(response.request?.url)")
                    #endif
                    if handleErr == true{
//                        EXAlert.showFail(msg: str)
                        throw EXSCustomNetworkError.ParseJSONError
                    }
                    EXSwapPlatformSDK.shared.changeHostLineCall?()
//                    EXSSwapChangeHostManager.sharedManager.changeHostLine()
                }
            }
            
            guard let json = try response.mapJSON() as? [String: Any] else {
                throw EXSCustomNetworkError.ParseJSONError
            }
            #if DEBUG
//            //print("response：%@",(json as NSDictionary).mj_JSONString())
//            //print("\n=======================================")
            #endif
//            //print("哈哈%@",(json as NSDictionary).mj_JSONString()) English: Print ("haha% @", (json as NSDictionary). mj_ JSONString()
            var strCode:String = "0"//默认成功 English: Default Success
            if let code = json["code"] as? String {
                strCode = code
            }else if let code = json["code"] as? Int {
                strCode = "\(code)"
            }else {
                throw EXSCustomNetworkError.ParseJSONError
            }
            
            if strCode == "0" {
                
                guard let data = json["data"] else {
                    throw  EXSCustomNetworkError.ParseJSONError
                }
                
                if let result = data as? [[String: Any]] {
                    //这个用CommonAryModel.self 接. English: This is connected using CommonAryModel.self
                    let obj = (type as! NSObject.Type).mj_object(withKeyValues:["dictAry":result]) as! T
                    return Single.just(obj)
                }
                else if let result = data as? [String: Any] {
                    if type == EXSVoidModel.self {
                        let obj = (type as! NSObject.Type).mj_object(withKeyValues: result) as! T
                        return Single.just(obj)
                    }
                    let obj = (type as! NSObject.Type).yy_model(withJSON:result) as! T
                    return Single.just(obj)

                }
                else if let result = data as? String {
                    //这个用CommonStringModel接. English: This is connected using CommonStringModel
                    let obj = (type as! NSObject.Type).mj_object(withKeyValues:["msg":result]) as! T
                    return Single.just(obj)
                }
                    //有些服务端返回0,data为null English: Some servers return 0 with null data
                else if let _ = data as? NSNull {
                    //这个用CommonStringModel接. English: This is connected using CommonStringModel
                    let obj = (type as! NSObject.Type).mj_object(withKeyValues:["msg":""]) as! T
                    return Single.just(obj)
                }else {
                    //还有返回int/double,全都当他是成功的 English: And return int/double, all as if he was successful
                    let obj = (type as! NSObject.Type).mj_object(withKeyValues:["msg":""]) as! T
                    return Single.just(obj)
                }
            }else {
                if strCode == "10065" {
                    throw EXSCustomNetworkError.openOrderTipError
                }else if strCode == "109006" { //限制地区 English: Restricted areas
                    let msg = json["msg"] as? String ?? ""
                    let alert = EXCommonAlert()
                    alert.configAlert(title: "cp_extra_text27".ex_localized(),bottomOnlyOneBtn: true)
                    EXAlert.showAlert(alertView: alert)
                    throw EXSCustomNetworkError.ExpireTokenError
                }else if strCode == "10002" || strCode == "10021" || strCode == "100106" || strCode == "3" {//3是合约 English: 3 is a contract
                    //用户不存在100106 English: User does not exist at 100106
                    EXSwapPlatformSDK.shared.activeAccount = nil
                    EXContractSDK.alreadLogout()
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "Logout_notification_name"), object: nil)
//                    BusinessTools.logoutNet()
//                    BusinessTools.modalLoginVC()
                    throw EXSCustomNetworkError.ExpireTokenError
                }else {
                    var shouldHandleErr = handleErr
                    if strCode == "200002" {
                        shouldHandleErr = false
                    }
                    let codeInt = Int(strCode)
                    if let code = codeInt,let msg = json["msg"] as? String {
                        let error = NSError(domain: "CustomNetworkError", code: code, userInfo:  [NSLocalizedDescriptionKey: msg])
                        if shouldHandleErr {
                            EXAlert.showFail(msg: error.localizedDescription )
                        }
                        throw error
                    }else {
                        throw EXSCustomNetworkError.ParseJSONError
                    }
                }
            }
        }.catchError { error in
            if let moyaerror = error as? MoyaError {
                EXSwapPlatformSDK.shared.changeHostLineCall?()
//                EXSSwapChangeHostManager.sharedManager.changeHostLine()
                switch moyaerror {
                case .underlying(let nserror,_):
                    let nsError = nserror as NSError
                    if let api = nsError.userInfo["NSErrorFailingURLStringKey"] as? String {
                        let errorMsg = "\(api)_\(nsError.localizedDescription)_\(nsError.code)"
                        //print("接口不通=\(api)")
                        EXNewTracking.shared.track(event: .httpError, info:["errorApI":errorMsg])
                    }
                default:
                    break
                }
            }
            throw error
        }
    }
    func exs_customObjectMap<T:HandyJSON>(_ type: T.Type,_ handleErr:Bool = true, customHandleCode: (() -> (String))? = nil,designatedPath: String? = nil) -> Single<T> {
        
        return flatMap { response in
            #if DEBUG
            
//            debug//print("请求：",response.request?.url ?? "None") English: DebugPrint ("Request:", response. request?. URL?? "None")
            let body = response.request.flatMap { $0.httpBody.map { String(decoding: $0, as: UTF8.self) } } ?? "None"
//            debug//print("参数：",body) English: DebugPrint ("Parameter:", body)
            #endif
            
            if let code = response.response?.statusCode{
                let str = getResponseStr(code)
                if str.count > 0 {
                    #if DEBUG
                   //print("ERROR：\(str) url => \(response.request?.url)")
                    #endif
                    if handleErr == true{
//                        EXAlert.showFail(msg: str)
                        throw NSError(domain: "CustomNetworkError", code: code, userInfo: [NSLocalizedDescriptionKey:str])
                    }
                }
            }
            

            guard let json = try response.mapJSON() as? [String: Any] else {
                throw EXSCustomNetworkError.ParseJSONError
            }

            #if DEBUG
//            debug//print("返回：",try response.mapString().util_subString(end: 300)) English: DebugPrint ("Return:", try response. mapString(). util_ SubString (end: 300))
//            debug//print("=======================================")
            #endif

            var strCode:String = "0"//默认成功 English: Default Success
            if let code = json["code"] as? String {
                strCode = code
            }else if let code = json["code"] as? Int {
                strCode = "\(code)"
            }else {
                throw EXSCustomNetworkError.ParseJSONError
            }

            if strCode == "0" {
                guard let data = json["data"] else {
                    throw  EXSCustomNetworkError.ParseDataError
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
                throw  EXSCustomNetworkError.ParseDataError
            }else {
                
                if let code = customHandleCode?(), (code == "10021" && strCode == "10021") {
                    throw EXSCustomNetworkError.ExpireTokenError
                }
                else if strCode == "10002" || strCode == "10021" || strCode == "3" {//3是合约 English: 3 is a contract
                    
                    
                    EXSwapPlatformSDK.shared.activeAccount = nil
                    EXContractSDK.alreadLogout()
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "Logout_notification_name"), object: nil)
                    throw EXSCustomNetworkError.ExpireTokenError
                }else if strCode == "10055" {//滑动验证错误，更新一下public_info_v5,因为可能修改了验证方式or关闭了验证方式 English: Sliding verification error, update public_ Info_ V5, because the verification method may have been modified or turned off
                    throw EXSCustomNetworkError.CaptchaError
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
                        throw EXSCustomNetworkError.ParseJSONError
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
                        EXNewTracking.shared.track(event: .httpError, info:["errorApI":errorMsg])
                    }
                default:
                    break
                }
            }
            throw error
        }
    }
}

enum EXSCustomNetworkError: String {
    case ParseJSONError = "Network Error"//解析错误 English: Parsing error
    case ExpireTokenError = "ExpireTokenError"//token
    case openOrderTipError = "BaocangTip"//token
    case ParseDataError = "Data Error"//没有data错误 English: No data error
    case CaptchaError = "xx"
}

extension EXSCustomNetworkError: Swift.Error {
    
}

