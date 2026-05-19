//
//  EXSFileDownLoader.swift
//  Chainup
//
//  Created by cwd on 2022/12/2.
//  Copyright © 2022 Chainup. All rights reserved.
//

import UIKit
import Moya
class EXSFileDownLoader {



}

 
//初始化请求的provider English: Initialize the requested provider
let SwapDownloadServiceProvider = MoyaProvider<SwapDLService>()
 
//请求分类 English: Request classification
public enum SwapDLService {
//    case downloadAsset(assetName:String) //下载文件 English: Download files
//    case downloadCustomAsset(assetName:String) //下载客户自定义文件 English: Download customer customization files
//    case downloadLan(url:String)
    case downloadSwapLanguage(url:String) //合约多语言 English: Contract Multilingual
}
 
//请求配置 English: Request configuration
extension SwapDLService: TargetType {
    //服务器地址 English: server address
    public var baseURL: URL {
        switch self {
//        case .downloadLan(let url):
//            return URL(string: url)!
        case .downloadSwapLanguage(let url):
            return URL(string: url)!
//        case .downloadCustomAsset:
//            return URL(string:EXNetworkDoctor.customLineUrl())!
//        default:
//            return URL(string:EXNetworkDoctor.doctorHost())!
        }
    }
     
    //各个请求的具体路径 English: Specific paths for each request
    public var path: String {
//        switch self {
//        case let .downloadAsset(assetName):
//            return "\(assetName)"
//        case let .downloadCustomAsset(assetName):
//            return "\(assetName)"
//        case .downloadLan:
//            return ""
//        default:
//            break
//        }
        return ""
    }
     
    //请求类型 English: Request type
    public var method: Moya.Method {
        return .get
    }
     
    //请求任务事件（这里附带上参数） English: Request Task Event (with parameters attached here)
    public var task: Task {
        switch self {
//        case .downloadAsset(_):
//            return .downloadDestination(DefaultDownloadDestination)
//        case .downloadLan(_):
//            return .downloadDestination(LanDownloadDestination)
        case .downloadSwapLanguage:
            return .downloadDestination(SwapLanguageDownloadDestination)
//        case .downloadCustomAsset:
//            return .downloadDestination(CompanyDownloadDestination)
        }
    }
     
    //是否执行Alamofire验证 English: Do you want to perform Alamofire verification
    public var validate: Bool {
        return false
    }
     
    //这个就是做单元测试模拟的数据，只会在单元测试文件中有作用 English: This is the data used for unit test simulation, which will only be useful in the unit test file
    public var sampleData: Data {
        return "{}".data(using: String.Encoding.utf8)!
    }
     
    //请求头 English: Request header
    public var headers: [String: String]? {
        return nil
    }
}
 


private let SwapLanguageDownloadDestination: DownloadDestination = { temporaryURL, response in
    return (SWapDefaultDownloadDir.appendingPathComponent(EXLanguageTools.getDownloadLanKey()), [.removePreviousFile])
}

//默认下载保存地址（用户文档目录） English: Default download and save address (user document directory)
let SWapDefaultDownloadDir: URL = {
    let directoryURLs = FileManager.default.urls(for: .documentDirectory,
                                                 in: .userDomainMask)
    return directoryURLs.first ?? URL(fileURLWithPath: NSTemporaryDirectory())
}()

