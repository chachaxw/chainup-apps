//
//  SLContractEndPoint.swift
//  Chainup
//
//  Created by ZYJ on 2023/10/12.
//  Copyright © 2023 Chainup. All rights reserved.
//

import Moya
public enum EXContractApiEndPoint {
    //公告 English: announcement
    case getNoticeInfoLogined //登录状态 0未登录，1已登录 English: Login status 0 not logged in, 1 logged in
    case getNoticeInfoNotLogined //登录状态 0未登录，1已登录 English: Login status 0 not logged in, 1 logged in
    case closeNoticeBar
    //
    case leverMagrinInfo(contractId : Int64)
    //公共信息 English: Public information
    case publicInfo
    case price_list //获取币种的标记价格和最新价格 English: Obtain the marked price and latest price of the currency
    case publicMarketInfo(symbol:String, contractId:Int64)
    case getLadderInfo(contractId:Int64)
    //创建账户 English: Create an account
    case createContractAccount(token:String)
    //喜好设置 English: Favorite settings
    case getUserConfig(id:Int64)
    case changeMarginMode(currentMode:String,id:Int64)
    case editLeverage(currentValue:String, id:Int64)
    case editUserConfig(id:Int64,positionModel:String, coUnit:String, expiredTime:String,priceBasis:String?)
    //持仓、资产 English: Positions and assets
    case getUserPositionOrAsset_new(onlyAccount:String,marginCoin:String?)
    case getUserPositionOrAsset(onlyAccount:String,marginCoin:String?)
    case getUserHistoryPosition(id:Int64,side:String, page:Int, limit:Int)

    case changePositionMargin(id:Int64, positionId:Int64, amount:String, type:String)
    case receiveCoupon

    //下单 English: Place an order
    case creatOrder(model:EXContractCreatOrder)
    case cancelOrder(contractId:Int64, orderId:Int64?, isConditionOrder:Bool, type:Int64?)
    case creatOrderForStopProfitOrStopLoss(model:SLContractCreatStopProfitOrStopLossOrder)
    case revokeOrderForStopProfitOrStopLoss(contractId:Int64, orderIds:String)
    case speedCloseOrder(contractId:Int64 ,open:String,side:String,positionType:String)
    case closeAllOrder(contractId:Int64?)
    //委托订单 English: Commissioned orders
    case currentOrderList(model:EXContractQueryCurrentOrderList)
    case queryProfitAndLossList(id:Int64, orderSide:String)
    case queryTradeDetailList(contractId:Int64, orderId:Int64?)
    //资金明细 English: Fund details
    case getTransactionRecordList(model:EXSQueryTransactionRecordList)
    //k线 English: K-line
    case depthChart(id:Int64)
    //合约划转到币币 English: Contract transfer to cryptocurrency
    //合约划转到币币 English: Contract transfer to cryptocurrency
    case transfer(coinSymbol:String,amount:String,type: String? = nil)
    case transferList(coinSymbol:String?,transactionScene:String,startTime:String?,endTime:String?,page:String)
    case riskBalanceList(coinSymbol:String,page:Int,limit:Int)
    case fundingRateList(contractId:Int64,page:Int,limit:Int)
    //获取保险基金余额 English: Obtain insurance fund balance
    case get_risk_account(coinSymbol:String)
    //汇率 English: exchange rate
    case symbol_rate_list
    //自选列表 English: Self selection list
    case contract_optional_list
    //自选设置 English: Custom settings
    case contract_optional_set(contractOptionalList:String)
    
}

extension EXContractApiEndPoint:TargetType {
    public var baseURL: URL {
        if EXSwapPrivateConfig.shared.base_host.count == 0 {
            return URL(string: "www.baidu.com")!
        }
        return URL(string: EXSwapPrivateConfig.shared.base_host)!
    }
    
    public var path: String {
        switch self {
        case .getNoticeInfoLogined:
            return "get_bulletin_info"
        case .getNoticeInfoNotLogined:
            return "common/get_bulletin_info"
        case .closeNoticeBar:
            return "confirm_bulletin"
        case .leverMagrinInfo:
            return "common/public_futures_contract_info"
        case .contract_optional_set:
            return "contract_optional_set"
        case .contract_optional_list:
            return "contract_optional_list"
        case .symbol_rate_list:
            return "common/symbol_rate_list"
        case .price_list:
            return "common/price_list"
        case .getUserPositionOrAsset_new:
            return "/position/close_or_open_position"
        case .publicInfo:
            return "common/public_info"
        case .publicMarketInfo:
            return "common/public_market_info"
        case .getLadderInfo:
            return "common/get_ladder_info"
        case .getUserConfig:
            return "user/get_user_config"
        case .createContractAccount:
            return "user/create_co_id"
        case .changeMarginMode:
            return "user/margin_model_edit"
        case .editLeverage:
            return "user/level_edit"
        case .receiveCoupon:
            return "user/receive_coupon"
        case .editUserConfig:
            return "user/edit_user_page_config"
        case .getUserPositionOrAsset:
            return "position/get_assets_list"
        case .getUserHistoryPosition:
            return "position/history_position_list"
        case .changePositionMargin:
            return "position/change_position_margin"
        case .creatOrder:
            return "order/order_create"
        case .speedCloseOrder:
            return "order/light_close"
        case .closeAllOrder:
            return "order/close_all_position"
        case .cancelOrder:
            return "order/order_cancel"
        case .getTransactionRecordList:
            return "record/get_transaction_list"
        case .queryProfitAndLossList:
            return "order/take_profit_stop_loss"
        case .queryTradeDetailList:
            return "order/get_trade_info"
        case .creatOrderForStopProfitOrStopLoss:
            return "order/condition_create"
        case .revokeOrderForStopProfitOrStopLoss:
            return "order/order_tpsl_cancel"
        case .transfer:
            return "assets/saas_trans/co_to_ex"
        case .transferList:
            return "record/get_transfer_record"

        case .currentOrderList(let model):
            let needTrigger = model.needTrigger ?? false
            let isHistory = model.isHistory ?? false
            
            //普通委托 English: Ordinary entrustment
            if !needTrigger {
                //普通历史委托 English: Ordinary historical commission
                if isHistory {
                    return "order/history_order_list_V2"
                }else {//普通条件委托 English: General Condition Entrustment
                    return "order/current_order_list_V2"
                }
            }else {
                //历史条件委托 English: Historical condition commission
                if isHistory {
                    return "order/history_trigger_order_list_V2"
                    //普通条件委托 English: General Condition Entrustment
                }else {
                    return "order/trigger_order_list_V2"
                }
            }
        case .depthChart:
            return "common/depth_map"
        case .riskBalanceList:
            return "common/risk_balance_list"
        case .fundingRateList:
            return "common/funding_rate_list"
        case .get_risk_account:
            return "common/get_risk_account"
        }
    }
    
    public var method: Moya.Method {
        
        switch self {
        default:
            return .post
        }
    }
    
    public var sampleData: Data {
        
        return "".data(using: String.Encoding.utf8)!
    }
    
    public var task: Task {
        var cachesKey: String? //请求路径 English: Request Path
        var parameters: [String: Any] = [:]
        switch self {
        case .price_list:
            cachesKey = "price_list"
        case .leverMagrinInfo(let contractId):
            parameters["contractId"] = contractId
        case .contract_optional_set(let contractOptionalList):
            parameters["contractOptionalList"] = contractOptionalList
        case .closeAllOrder(let contractId):
            if contractId != nil {
                parameters["contractId"] = contractId
            }
          //  parameters["uid"] = uid
        case .receiveCoupon:break
        case .getUserPositionOrAsset_new(let onlyAccount, let marginCoin):
            parameters["onlyAccount"] = onlyAccount
            parameters["marginCoin"] = marginCoin
//        case .publicInfo,.price_list:
//            break
        case .publicMarketInfo(let symbol, let contractId):
            parameters["symbol"] = symbol
            parameters["contractId"] = contractId
            cachesKey = "publicMarketInfo" + "\(contractId)"
        case .getLadderInfo(let contractId):
            parameters["contractId"] = contractId
        case .getUserConfig(let id):
            parameters["contractId"] = id
            cachesKey = "getUserConfig" + "\(id)"
        case .createContractAccount(let token):
            parameters["token"] = token
            break
        case .changeMarginMode( let currentMode, let id):
            parameters["contractId"] = id
            parameters["marginModel"] = currentMode
        case .editLeverage(let currentValue,let id):
            parameters["contractId"] = id
            parameters["nowLevel"] = currentValue
        case .editUserConfig(let id,let positionModel, let coUnit, let expiredTime, let priceBasis):
            parameters["contractId"] = id
            parameters["positionModel"] = positionModel
            parameters["coUnit"] = coUnit
            parameters["pcSecondConfirm"] = "1"
            parameters["expireTime"] = expiredTime
            parameters["priceBasis"] = priceBasis
        case .getUserPositionOrAsset(let onlyAccount, let marginCoin):
            parameters["onlyAccount"] = onlyAccount
            parameters["marginCoin"] = marginCoin
            cachesKey = "getUserPositionOrAsset" + onlyAccount
        case .getUserHistoryPosition(let id, let side, let page, let limit):
            if id  > 0 {
                parameters["contractId"] = id
            }
            parameters["page"] = page
            parameters["limit"] = limit
            parameters["side"] = side
        case .changePositionMargin(let id,let positionId,let amount, let type):
            parameters["id"] = id
            parameters["positionId"] = positionId
            parameters["amount"] = amount
            parameters["type"] = type
        case .creatOrder(let model):
            //不要用可选值，会导致oc找不到该类型 English: Do not use optional values as it may cause OC to not find the type
            parameters = model.getParams() //model.mj_keyValues() as! [String : Any]
        case .speedCloseOrder(let contractId,let open,let side, let positionType):
            parameters["contractId"] = contractId
            parameters["open"] = open
            parameters["side"] = side
            parameters["positionType"] = positionType
        case .creatOrderForStopProfitOrStopLoss(let model):
            parameters = model.getParams()
        case .revokeOrderForStopProfitOrStopLoss(let contractId,let orderIds):
            parameters["contractId"] = contractId
            parameters["orderIds"] = orderIds
        case .cancelOrder(let contractId, let orderId, let isConditionOrder,let type):
            if contractId > 0 {
                parameters["contractId"] = contractId
            }
            if type != nil {
                parameters["type"] = type
            }
            parameters["orderId"] = orderId
            parameters["isConditionOrder"] = isConditionOrder
        case .currentOrderList(let model):
            parameters =  model.getParams()//model.mj_keyValues() as! [String : Any]
        case .getTransactionRecordList(let model):
            parameters = model.getParams()
        case .queryProfitAndLossList(let id, let orderSide):
            parameters["contractId"] = id
            parameters["orderSide"] = orderSide
        case .queryTradeDetailList(let contractId, let orderId):
            parameters["contractId"] = contractId
            parameters["orderId"] = orderId
        case .depthChart(let id):
            parameters["contractId"] = id
        case .transfer(let coinSymbol, let amount, let type):
            parameters["coinSymbol"] = coinSymbol
            parameters["amount"] = amount
            if let t = type{
                parameters["transferType"] = type
            }

        case .transferList(let coinSymbol, let transactionScene, let startTime, let endTime, let page):
            parameters["transactionScene"] = transactionScene
            parameters["page"] = page
            parameters["pageSize"] = "20"
            if let begin = startTime, let end = endTime {
                parameters["startTimeMillis"] = begin
                parameters["endTimeMillis"] = end
            }
            if let symbol = coinSymbol {
                 parameters["coinSymbol"] = symbol
            }
        case .riskBalanceList(let coinSymbol, let page, let limit):
            parameters["symbol"] = coinSymbol
            parameters["page"] = page
            parameters["limit"] = limit
        case .fundingRateList(let contractId, let page, let limit):
            parameters["contractId"] = contractId
            parameters["page"] = page
            parameters["limit"] = limit
        case .get_risk_account(coinSymbol: let coinSymbol):
            parameters["coinSymbol"] = coinSymbol
        default:
            break
        }
        #if DEBUG
      //  //print("parameters=\(parameters)")
        #endif
        return .requestParameters(parameters: EXNetParameterGenerator.generateParamter(parameters,key: cachesKey), encoding:JSONEncoding.default)
        
    }
    public var headers: [String : String]? {
        return EXNetParameterGenerator.getHeaderParams()
    }
}


