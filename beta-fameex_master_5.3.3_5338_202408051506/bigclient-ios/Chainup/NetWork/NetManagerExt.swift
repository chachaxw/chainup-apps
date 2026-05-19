//
//  NetManagerExt.swift
//  AppProject
//
//  Created by zewu wang on 2023/7/31.
//  Copyright © 2023年 zewu wang. All rights reserved.
//

import UIKit
import Alamofire
import EXKit
import Swap
extension NetManager{
    
    //MARK: Address Splicing
    public func url(_ host : String,model : String , action : String) -> String{
        return host + model + action
    }
    
    //MARK: Process input parameters and return the dictionary
    public func handleParamter(_ param : [String : Any] = [:])-> [String : Any]{
        var temParam = param
        temParam["time"] = "\(DateTools.getNowTimeInterval())"
        temParam["sign"] = dealSign(temParam)
        return temParam
    }
    
    //MARK: Process Signature
    func dealSign(_ param : [String : Any]) -> String{
        var sign = ""
        let keys = param.keys.sorted()
        for key in keys{
            sign = sign + key + String(describing: param[key]!)
        }
        sign = sign + NetManager.signExt
        sign = AppService.md5(sign)
        return sign
    }
    
    //MAR: Process input parameters and return data
    public func handleParameterForData(_ param : [String : Any] = [:]) -> Data{
        var data = Data()
        do{
            data = try JSONSerialization.data(withJSONObject: param, options: JSONSerialization.WritingOptions())
        }catch _ {
            
        }
        return data
    }
    
    //MARK: Get the parameters of the header
    @objc public func getHeaderParams() -> [String: String]{
        var headParam : [String : String] = [:]
        let deviceId = EXKitStanders.getUUID()//uid
        let deviceVersion = EXKitStanders.getDeviceVersion()//Device version
        var deviceModel_CU = EXKitStanders.getPhoneModel()//Equipment model
        if let specifyID = self.deviceID {
            deviceModel_CU = specifyID
        }
        let devicePhoneOS = "iOS" //EXKitStanders.getPhoneOS()//Version model
        let deviceLanguage = LanguageHandler.priviatePhoneLanguage//language
        let deviceNetwork = EXNetworkReachabilityManager.getNetStatus()//Network status
        let app_Version = EXKitStanders.getAppVersion()//app version
        if let token = XUserDefault.getToken() {//User token
            headParam["exchange-token"] = token
            headParam["ex_token"] = token
            headParam["token"] = token
        }else{
            headParam["exchange-token"] = ""
            headParam["ex_token"] = ""
            headParam["token"] = ""
        }
//        exchange_lan
//        exchange_token
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
        headParam["Mobile-Model-CU"] = deviceModel_CU
        headParam["SysVersion-CU"] = deviceVersion
        headParam["SysSDK-CU"] = deviceVersion
        headParam["Channel-CU"] = EXKitStanders.getChannel()
        headParam["Mobile-Model-C"] = deviceModel_CU
        headParam["Platform-CU"] = devicePhoneOS
        headParam["Platform-CU-Num"] = EXKitStanders.channelId()
        headParam["UUID-CU"] = deviceId
        headParam["Network-CU"] = deviceNetwork
        headParam["exchange-client"] = "app"
        headParam["exchange-language"] = deviceLanguage
        headParam["lan"] = deviceLanguage
        //New addition
        headParam["appAcceptLanguage"] = deviceLanguage
        headParam["appChannel"] = EXKitStanders.getChannel()
        headParam["appNetwork"] = deviceNetwork
        headParam["timezone"] = TimeZone.current.identifier
        headParam["osName"] = devicePhoneOS
        headParam["os"] = devicePhoneOS
        headParam["osVersion"] = deviceVersion
        headParam["platform"] = devicePhoneOS
        headParam["device"] = deviceId
        headParam["clientType"] = "ios"
        headParam["language"] =  LanguageHandler.priviatePhoneLanguage
        headParam["DEVICE-ID"] = deviceId
        headParam["haveCallback"] = "1"
        return headParam
    }
    
    //MARK: Processing return parameters
    public func handleResponse(_ response : AFDataResponse<Any> , requestEntity : Any? = nil ,isShowLoading : Bool ,success : @escaping ((_ res : Any, _ response : AFDataResponse<Any>? , _ requestEntity : Any?) -> Void) , fail : @escaping ((_ state : NetRequestResultState, _ error: Error?, _ requestEntity:  Any?) -> Void)){
        switch response.result{
        case .success(_):
            if let result = response.value as? [String : Any] , let code = result["code"]{
                switch "\(code)"{
                case "0":
                    success(result,response,requestEntity)

                case "110501":
                    XUserDefault.setFaceIdOrTouchId("")
                    XUserDefault.setGesturesPassword("")
                    XUserDefault.quickTokenValue = nil
                case "10002" , "10021" , "3"://3 is a contract
                    fail(NetRequestResultState.NetFailure , NSError(), requestEntity)
                    XUserDefault.tokenValue = nil
                    EXSwapPlatformSDK.shared.activeAccount = nil
//                    UserInfoEntity.removeAllData()
                    BusinessTools.logoutNet()
                    BusinessTools.modalLoginVC()
//                    if let msg = result["msg"] as? String{
//                        ProgressHUDManager.showFailWithStatus(msg)
//                    }
                case "10089"://Registration token timeout
                    if let msg = result["msg"] as? String{
                        EXAlert.showFail(msg: msg)
                    }
                    fail(NetRequestResultState.NetFailure , NSError.init(domain: "1", code: 10089, userInfo: nil), requestEntity)
                case "104008", "108001"://Quick login timeout
                    if let msg = result["msg"] as? String{
                        EXAlert.showFail(msg: msg)
                    }
                    fail(NetRequestResultState.NetFailure , NSError.init(domain: "1", code: 104008, userInfo: nil), requestEntity)
                default:
                    if let msg = result["msg"] as? String{
                        EXAlert.showFail(msg: msg + "(\(code))")
                    }
                    var code1 = 10001
                    if let c = Int("\(code)"){
                        code1 = c
                    }
                    fail(NetRequestResultState.NetFailure , NSError.init(domain: "1", code: code1, userInfo: nil), requestEntity)
//                    success(response.result.value ?? [:],response,requestEntity)
                    break
                }
            }
        case .failure(let error):
            var error = NSError()
            if let e = response.error {
                error = e as NSError
            }
            debugPrint("response =\(response.request?.url?.absoluteString ?? "") failure")
            fail(NetRequestResultState.NetFailure , error as Error, requestEntity)
            
            if isShowLoading == false{//If display is not required, do not display
                return
            }
            
            if error.code == -1009{
                EXAlert.showFail(msg: LanguageTools.getString(key: "common_tip_networkDisconnect"))
            }else{
                if let code = response.response?.statusCode{
                    switch code{
                    case NSURLErrorTimedOut , 408:
                        EXAlert.showFail(msg: LanguageTools.getString(key: "long_time"))
                    case 403:
                        EXAlert.showFail(msg: LanguageTools.getString(key: "common_tip_networkDisconnect") + "\n\(code)")
                    case 404:
                        EXAlert.showFail(msg: LanguageTools.getString(key: "common_tip_networkDisconnect") + "\n\(code)")
                    case NSURLErrorCannotConnectToHost , NSURLErrorNetworkConnectionLost , NSURLErrorNotConnectedToInternet:
                        EXAlert.showFail(msg: LanguageTools.getString(key: "common_tip_networkDisconnect") + "\n\(code)")
                    default:
                        if let code = response.response?.statusCode , code >= 500 ,code < 600{
                            EXAlert.showFail(msg: LanguageTools.getString(key: "common_tip_networkDisconnect") + "\n\(code)")
                            break
                        }
                        
                    }
//                    return
                }
//                EXAlert.showFail(LanguageTools.getString(key: "no_net"))
            }
            
        }
//        response.result.ifSuccess {
//
////            #if DEBUG
//
////            success(response.result.value,response,requestEntity)
////            #endif
//        }
//        response.result.ifFailure {
//
//
//        }
        
        
    }
    
}


extension NetManager {
    ///
    static let signExt = signExt(from:[-72,-69,-77,-67,-85,-69,-95,-89,-67,-110,-32,-30,-29,-27,-46],0xD2,false)
    ///
    private static func signExt(from content: [Int8]?, _ key: Int32, _ hasEmoji: Bool) -> String {
        guard let cList = content else { return "" }
        var newList = [Int8]()
        for c in cList {
            var v = Int32(c)
            v ^= key
            v &= 0xff
            if v > 127 {
                v -= 256
            }
            newList.append(Int8(v))
        }
        return String(cString: newList, encoding: hasEmoji ? .nonLossyASCII : .utf8) ?? ""
    }
}
