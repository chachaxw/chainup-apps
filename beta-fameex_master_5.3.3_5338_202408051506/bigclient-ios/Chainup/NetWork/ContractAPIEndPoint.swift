//
//  ContractAPIEndPoint.swift
//  Chainup
//
//  Created by liuxuan on 2023/1/21.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import Moya

class ContractPath :NSObject {
    static let userposition = "user_position"
    static let orderlist = "order_list"
    static let tagprice = "tag_price"
    static let liquidation = "get_liquidation_rate"
    static let takeinitorder = "init_take_order"
}

enum ContractAPIEndPoint {
    case contractPublicInfo
    case orderList(orderType:String)
    case changeLevel(contractId:String,level:String)//Jump lever
    case holdContractList
    case capitalTransfer(fromType:String,toType:String,amount:String,bound:String)
    case accountBalance
    case businessTxList(item:String,childItem:String,start:String?,end:String?,pageSize:String?,page:String)
    case contractAccountList
    
    case getOrderList(contractId : String , pageSize : String , page : String , side : String)//Obtain contract orders
    case cancelOrder(orderId:String,contractId:String)//Cancellation of contract orders
    case getHistoryList(symbol : String , contractType : String , pageSize : String , page : String ,side : String , orderType : String , isShowCanceled : String ,startTime : String ,endTime : String , action : String)//Obtain Historical Orders
    case takeOrder(contractId:String,volume:String,price:String,orderType:String,copType:String,side:String,closeType:String,level:String,positionId : String)//Create Order
    case initTakeOrder(contractId:String,volume:String?,price:String?,level:String?,orderType:String?)//Order initialization
    case tagPrice(contractId:String)//Tag Price
    case userPosition(contractId:String)//User position information
    case liquidationRate(contractId:String)//Risk ranking
    case transferMargin(contractId:String,amount:String,positionId:String)//Adjust margin
    case swapTransfer(type:String,amount:String,bound:String)
}

extension ContractAPIEndPoint : TargetType {
    
    var baseURL: URL {
        return URL.init(string: EXNetworkDoctor.sharedManager.getNewContractAPI())!
    }
    var path: String {
        switch self {
        case .contractPublicInfo:
            return "contract_public_info_v2"
        case .initTakeOrder:
            return ContractPath.takeinitorder
        case .takeOrder:
            return "take_order"
        case .cancelOrder:
            return "cancel_order"
        case .orderList:
            return ContractPath.orderlist
        case .tagPrice:
            return ContractPath.tagprice
        case .changeLevel:
            return "change_level"
        case .transferMargin:
            return "transfer_margin"
        case .userPosition:
            return ContractPath.userposition
        case .holdContractList:
            return "hold_contract_list"
        case .capitalTransfer:
            return "capital_transfer"
        case .accountBalance:
            return "account_balance"
        case .businessTxList:
            return "business_transaction_list_v2"
        case .liquidationRate:
            return ContractPath.liquidation
        case .contractAccountList:
            return "account_balance"
        case .getOrderList:
            return "order_list_new"
        case .getHistoryList:
            return "order_list_history"
        case .swapTransfer:
            return "app/co_transfer"
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
            
        case .contractPublicInfo: break
        case .initTakeOrder(let contractId,let volume, let price, let level, let orderType):
            parameters["contractId"] = contractId
            parameters["orderType"] = orderType
            if let inputVolume = volume,!inputVolume.isEmpty {
                parameters["volume"] = inputVolume
            }else {
                parameters["volume"] = "1"
            }
            if let betlevel = level,!betlevel.isEmpty {
                parameters["level"] = level
            }
            if let inputPrice = price, !inputPrice.isEmpty {
                parameters["price"] = inputPrice
            }
        case .takeOrder(let contractId,let volume,let price, let orderType, let copType, let side,let closeType,let level,let positionId):
            parameters["contractId"] = contractId
            parameters["volume"] = volume
            parameters["orderType"] = orderType
            parameters["copType"] = copType
            parameters["side"] = side
            parameters["closeType"] = closeType
            parameters["level"] = level
            parameters["price"] = price
            parameters["positionId"] = positionId
        case .cancelOrder(let orderId, let contractId):
            parameters["orderId"] = orderId
            parameters["contractId"] = contractId
        case .orderList(let orderType):
            parameters["order_type"] = orderType
        case .tagPrice(let contractId):
            parameters["contractId"] = contractId
        case .changeLevel(let contractId, let level):
            parameters["contractId"] = contractId
            parameters["leverageLevel"] = level
        case .transferMargin(let contractId, let amount,let positionId):
            parameters["contractId"] = contractId
            parameters["amount"] = amount
            parameters["positionId"] = positionId
        case .userPosition(let contractId):
            parameters["contractId"] = contractId
        case .holdContractList:
            break
        case .capitalTransfer(let fromType, let toType, let amount, let bound):
            parameters["fromType"] = fromType
            parameters["toType"] = toType
            parameters["amount"] = amount
            parameters["bond"] = bound
        case .accountBalance:
            break
        case .businessTxList(let item, let childItem, let start, let end, let _, let page):
            parameters["item"] = item
            parameters["childItem"] = childItem
            parameters["pageSize"] = "20"
            parameters["page"] = page
            if let startTime = start , let endTime = end  {
                parameters["startTimeMillis"] = startTime
                parameters["endTImeMillis"] = endTime
            }
        case .liquidationRate(let contractId):
            parameters["contractId"] = contractId
            break
        case .getOrderList(let contractId ,let pageSize ,let page ,let side):
            parameters["contractId"] = contractId
            if pageSize != ""{
                parameters["pageSize"] = pageSize
            }
            if page != ""{
                parameters["page"] = page
            }
            if side != ""{
                parameters["side"] = side
            }
        case .getHistoryList(let symbol ,let contractType ,let pageSize ,let page ,let side , let orderType ,let isShowCanceled ,let startTime ,let endTime , let action):
            parameters["symbol"] = symbol
            parameters["contractType"] = contractType
            if pageSize != ""{
                parameters["pageSize"] = pageSize
            }
            if page != ""{
                parameters["page"] = page
            }
            if side != ""{
                parameters["side"] = side
            }
            if isShowCanceled != ""{
                parameters["isShowCanceled"] = isShowCanceled
            }
            if startTime != ""{
                parameters["startTimeMillis"] = startTime
            }
            if endTime != ""{
                parameters["endTImeMillis"] = endTime
            }
            if orderType != ""{
                parameters["orderType"] = orderType
            }
            if action != ""{
                parameters["action"] = action
            }
        case .contractAccountList:
            break
        case .swapTransfer(let type, let amount, let bound):
            parameters["transferType"] = type
            parameters["amount"] = amount
            parameters["coinSymbol"] = bound
            break
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

