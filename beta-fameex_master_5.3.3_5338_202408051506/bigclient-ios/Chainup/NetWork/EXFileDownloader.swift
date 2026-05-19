//
//  EXFileDownloader.swift
//  Chainup
//
//  Created by liuxuan on 2023/2/4.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import Moya
import EXKit

 
//Initialize the requested provider
let DLServiceProvider = MoyaProvider<DLService>()
 
//Request classification
public enum DLService {
    case downloadAsset(assetName:String) //Download files
    case downloadCustomAsset(assetName:String) //Download customer customization files
    case downloadLan(url:String)
//    case downloadSwapLanguage(url:String) //Contract Multilingual
}
 
//Request Configuration
extension DLService: TargetType {
    //server address
    public var baseURL: URL {
        switch self {
        case .downloadLan(let url):
            return URL(string: url)!
//        case .downloadSwapLanguage(let url):
//            return URL(string: url)!
        case .downloadCustomAsset:
            return URL(string:EXNetworkDoctor.customLineUrl())!
        default:
            return URL(string:EXNetworkDoctor.doctorHost())!
        }
    }
     
    //Specific paths for each request
    public var path: String {
        switch self {
        case let .downloadAsset(assetName):
            return "\(assetName)"
        case let .downloadCustomAsset(assetName):
            return "\(assetName)"
        case .downloadLan:
            return ""
        default:
            break
        }
        return ""
    }
     
    //Request Type
    public var method: Moya.Method {
        return .get
    }
     
    //Request Task Event (with parameters attached here)
    public var task: Task {
        switch self {
        case .downloadAsset(_):
            return .downloadDestination(DefaultDownloadDestination)
        case .downloadLan(_):
            return .downloadDestination(LanDownloadDestination)
//        case .downloadSwapLanguage:
//            return .downloadDestination(SwapLanguageDownloadDestination)
        case .downloadCustomAsset:
            return .downloadDestination(CompanyDownloadDestination)
        }
    }
     
    //Do you want to perform Alamofire verification
    public var validate: Bool {
        return false
    }
     
    //This is the data used for unit test simulation, which will only be useful in the unit test file
    public var sampleData: Data {
        return "{}".data(using: String.Encoding.utf8)!
    }
     
    //Request header
    public var headers: [String: String]? {
        return nil
    }
}
 
//Define DownloadDestination for Download
private let DefaultDownloadDestination: DownloadDestination = { temporaryURL, response in
    return (DefaultDownloadDir.appendingPathComponent(response.suggestedFilename!), [.removePreviousFile])
}

private let CompanyDownloadDestination: DownloadDestination = { temporaryURL, response in
    return (DefaultDownloadDir.appendingPathComponent(EXNetworkDoctor.sharedManager.companyCustomName()), [.removePreviousFile])
}

private let LanDownloadDestination: DownloadDestination = { temporaryURL, response in
    return (DefaultDownloadDir.appendingPathComponent(LanguageTools.shareInstance.currentDownLoadLan), [.removePreviousFile])
}

//private let SwapLanguageDownloadDestination: DownloadDestination = { temporaryURL, response in
//    return (DefaultDownloadDir.appendingPathComponent(EXLanguageTools.getDownloadLanKey()), [.removePreviousFile])
//}

//Default download save address (user document directory)
let DefaultDownloadDir: URL = {
    let directoryURLs = FileManager.default.urls(for: .documentDirectory,
                                                 in: .userDomainMask)
    return directoryURLs.first ?? URL(fileURLWithPath: NSTemporaryDirectory())
}()

let lanDownloadPath: URL = {
    return DefaultDownloadDir.appendingPathComponent("/lan/")
}()

