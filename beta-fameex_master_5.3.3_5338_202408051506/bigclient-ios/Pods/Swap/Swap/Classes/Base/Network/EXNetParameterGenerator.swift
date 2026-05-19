//
//  EXNetParameterGenerator.swift
//  CoNetworkTest
//
//  Created by ZYJ on 2023/1/18.
//

import UIKit
import CommonCrypto
import Alamofire
import EXKit
let iOS_Sign = "iosSign"

public class EXSNetWorkManager{
    public static let shared = EXSNetWorkManager()
    private init() {
    }
    var paramterCaches = [String: [String : Any]]()
}

class EXNetParameterGenerator {
    /*
Special handling of polling interface - caching parameters to avoid duplicate MD5
     
     */
    //MARK: Process input parameters and return the dictionary
    public static func generateParamter(_ param : [String : Any] = [:], key: String? = nil)-> [String : Any]{
        if key != nil {
            if let value =  EXSNetWorkManager.shared.paramterCaches[key!]{
                return value
            }
        }
        var temParam = param
        temParam["time"] = EXSDateTools.getNowTimeInterval()
        temParam["sign"] = dealSign(temParam)
//Print ("Final result= (temParam)")
        if key != nil {
            EXSNetWorkManager.shared.paramterCaches[key!] = temParam
        }
        
        return temParam
    }
    
    //MARK: Process Signature
    static func dealSign(_ param : [String : Any]) -> String{
        var sign = ""
        let keys = param.keys.sorted()
        for key in keys{
            ////print("key = \(key),value=\(param[key]!)" )
            let value = param[key]!
            let stringValue = String(describing: value)
            sign = sign + key + stringValue
        }
        sign = sign + "jiaoyisuo@2017"
      //Print ("sign before encryption= (sign)")
        sign = md5(sign)
     //Print ("Encrypted sign= (sign)")
        return sign
    }
    
    static func md5(_ md5String:String) -> String {
        let cStr = md5String.cString(using: .utf8)
        let strLength = CUnsignedInt(md5String.lengthOfBytes(using: .utf8))
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
        CC_MD5(cStr, strLength, result);
        let hash = NSMutableString()
        for i in 0 ..< digestLen {
            hash.appendFormat("%02x", result[i])
        }
        result.deallocate()
        
        return String(format: hash as String).lowercased()
    }
    //MARK: Get the parameters of the header
    static func getHeaderParams() -> [String: String]{
        var headParam : [String : String] = [:]
        let deviceId = EXBasicParameter.getUUID()//uid
        let deviceVersion = EXBasicParameter.getDeviceVersion()//Device version
        let deviceModel_CU = EXBasicParameter.getPhoneModel()//Equipment model
        let devicePhoneOS = EXBasicParameter.getPhoneOS()//Version model
        let deviceLanguage = LanguageHandler.priviatePhoneLanguage//language
        let deviceNetwork = ""//Network status
        let app_Version = ""//app version
        headParam["iosSign"] = "1" //Server side judgment iOS_ Whether sign is empty to verify signature
        headParam["version"] = EXBasicParameter.getVersion()
        if let token = EXSwapPlatformSDK.shared.activeAccount?.token {//User token
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
        headParam["Mobile-Model-CU"] = deviceModel_CU
        headParam["SysVersion-CU"] = deviceVersion
        headParam["SysSDK-CU"] = deviceVersion
        headParam["Mobile-Model-C"] = deviceModel_CU
        headParam["Platform-CU"] = "ios"
        headParam["UUID-CU"] = deviceId
        headParam["Network-CU"] = deviceNetwork
        headParam["exchange-client"] = "app"
        headParam["exchange-language"] = deviceLanguage
        headParam["lan"] = deviceLanguage
        //New addition
        headParam["appAcceptLanguage"] = deviceLanguage
        headParam["appNetwork"] = deviceNetwork
        headParam["timezone"] = TimeZone.current.identifier
        headParam["osName"] = devicePhoneOS
        headParam["os"] = devicePhoneOS
        headParam["osVersion"] = deviceVersion
        headParam["platform"] = devicePhoneOS
        headParam["device"] = deviceId
        headParam["clientType"] = "ios"
        headParam["DEVICE-ID"] = deviceId
        headParam["haveCallback"] = "1"
        return headParam
    }
}

