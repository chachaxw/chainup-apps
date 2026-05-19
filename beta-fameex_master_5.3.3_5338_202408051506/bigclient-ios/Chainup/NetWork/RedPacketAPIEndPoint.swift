//
//  RedPacketAPIEndPoint.swift
//  Chainup
//
//  Created by zewu wang on 2023/7/3.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import Moya

enum RedPacketAPIEndPoint {
    case index//Red envelope homepage
    case createRedpacket(type : String , coinSymbol : String , amount : String , count : String , tip : String , onlyNew : String)//Create a red envelope
    case grantRecordInfo(packetSn : String) //Details of red packets sent/received by users
    case grantRecordList(pageSize : String , pageNum : String)//List of red envelopes sent by users
    case grantRecord//Statistical information on red packets sent by users
    case receiveRecordList(pageSize : String , pageNum : String)//List of red envelopes received by users
    case receiveRecord //Statistical information on red packets received by users
    case redPacketInfo(packetSn : String)//Red envelope sharing details
    case toPayUrl(url : String , params : [String : Any])//Go to the payment platform for payment
    case newVersionToPay(orderNum:String,goolgeCode:String?,smsAuthCode:String?)
}

extension RedPacketAPIEndPoint : TargetType {
    
    var baseURL: URL {
        switch self {
        case .toPayUrl(let url , _):
            return URL.init(string:url)!
        default:
            return URL.init(string: EXNetworkDoctor.sharedManager.getRedPackAPIHost())!
//             return URL.init(string:NetDefine.http_host_url_redpacket)!
        }
    }
    
    var path: String {
        switch self {
        case .index:
            return "red_packet/index"
        case .createRedpacket:
            return "red_packet/create_new"
        case .grantRecordInfo:
            return "red_packet/grant_record_info"
        case .grantRecordList:
            return "red_packet/grant_record_list"
        case .grantRecord:
            return "red_packet/grant_record"
        case .receiveRecordList:
            return "red_packet/receive_record_list"
        case .receiveRecord:
            return "red_packet/receive_record"
        case .redPacketInfo:
            return "red_packet/red_packet_info"
        case .toPayUrl(_ , _):
            return "toPay"
        case .newVersionToPay:
            return "red_packet/toPay"
        }
    }
    
    var method: Moya.Method {
        switch self {
        default:
            return .post
        }
    }
    
    var sampleData: Data {
        
        return "".data(using: String.Encoding.utf8)!
    }
    
    var task: Task {
        var parameters: [String: Any] = [:]
        switch self {
        case .index: break
        case .createRedpacket(let type,let coinSymbol,let amount,let count,let tip,let onlyNew):
            parameters["type"] = type
            parameters["coinSymbol"] = coinSymbol
            parameters["amount"] = amount
            parameters["count"] = count
            parameters["tip"] = tip
            parameters["onlyNew"] = onlyNew
        case .grantRecordInfo(let packetSn):
            parameters["packetSn"] = packetSn
        case .grantRecordList(let pageSize , let pageNum):
            parameters["pageSize"] = pageSize
            parameters["pageNum"] = pageNum
        case .grantRecord: break
        case .receiveRecordList(let pageSize , let pageNum):
            parameters["pageSize"] = pageSize
            parameters["pageNum"] = pageNum
        case .receiveRecord: break
        case .redPacketInfo(let packetSn):
            parameters["packetSn"] = packetSn
        case .toPayUrl(_ , let params):
            parameters = params
        case .newVersionToPay(let orderNum, let goolgeCode, let smsAuthCode):
            parameters["orderNum"] = orderNum
            if let sms = smsAuthCode {
                parameters["smsAuthCode"] = sms
            }
            if let google = goolgeCode {
                parameters["googleCode"] = google
            }
        }
        
        if self.method == .post {
            return .requestParameters(parameters: NetManager.sharedInstance.handleParamter(parameters), encoding: JSONEncoding.default)
        }else {
            return .requestParameters(parameters: NetManager.sharedInstance.handleParamter(parameters), encoding:URLEncoding.httpBody)
        }
    }
    
    var headers: [String : String]? {
        let header = NetManager.sharedInstance.getHeaderParams()
        return header
    }
}

