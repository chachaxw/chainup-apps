//
//  EXContractNetwork.swift
//  Chainup
//
//  Created by ZYJ on 2023/10/12.
//  Copyright © 2023 Chainup. All rights reserved.
//

import RxSwift
public typealias SLContractNetworkCompletion = ((Bool)->())
public typealias SLContractNetworkFailure = ((Error?)->())
public typealias SLContractNetworkSuccess = (()->())

@objcMembers public class EXContractNetwork:NSObject {
   static let network = EXContractNetwork()
    static let exs_disposeBag = DisposeBag()
    open class var shared: EXContractNetwork {
        return network
    }
    static let disposeObject = DisposeBag()
//    private func synchronizedBag<T>( _ action: () -> T) -> T {
//        objc_sync_enter(self)
//        let result = action()
//        objc_sync_exit(self)
//        return result
//    }
//
//    public var disposeBag: DisposeBag {
//        get {
//            return synchronizedBag {
//                if let disposeObject = objc_getAssociatedObject(self, &disposeBagContext) as? DisposeBag {
//                    return disposeObject
//                }
//                let disposeObject = DisposeBag()
//                objc_setAssociatedObject(self, &disposeBagContext, disposeObject, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
//                return disposeObject
//            }
//        }
//        set {
//            synchronizedBag {
//                objc_setAssociatedObject(self, &disposeBagContext, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
//            }
//        }
//    }
   
    static func creatContractAccount(token:String, completion: @escaping SLContractNetworkCompletion) {
        let _ = networkApi.rx.request(.createContractAccount(token: token)).exs_MJObjectMap(EXSVoidModel.self).subscribe { (_) in
            completion(true)
        } onError: { (_) in
            completion(false)
        }
    }
    
    static func getLadderInfo(contractId:Int64,success: @escaping (EXContractLadderInfo) -> (), failure: @escaping SLContractNetworkFailure) {
        let _ = networkApi.rx.request(.getLadderInfo(contractId: contractId)).exs_MJObjectMap(EXContractLadderInfo.self).subscribe { (model) in
            success(model)
        } onError: { (error) in
            failure(error)
        }
    }
    
    static func changeMarginMode(id:Int64, currentMode:SLMarginMode, completion: @escaping SLContractNetworkCompletion) {
        var stringMode = ""
        switch currentMode {
        case .cross:
            stringMode = "1"
        case .fixed:
            stringMode = "2"
        }
        
        let _ = networkApi.rx.request(.changeMarginMode(currentMode: stringMode, id: id)).exs_MJObjectMap(EXSVoidModel.self).subscribe { (_) in
            completion(true)
        } onError: { (_) in
            completion(false)
        }
    }
    
    static func editLeverageValue(value:String, id:Int64, completion: @escaping SLContractNetworkCompletion) {
        let _ = networkApi.rx.request(.editLeverage(currentValue: value, id: id)).exs_MJObjectMap(EXSVoidModel.self).subscribe { (_) in
            completion(true)
        } onError: { (_) in
            completion(false)
        }
    }
    static func editUserConfig(id:Int64, positionModel:String, coUnit:String,expiredTime:String = "",priceType: String? = nil, completion: @escaping SLContractNetworkCompletion) {
        let positionTwoWay = EXStoreData.storeBool(forKey: EXS_HOLD_MODE) ? "2" : "1"
        let positionStr = !positionModel.isEmpty ? positionModel : positionTwoWay
        
        let isCoin = EXStoreData.storeBool(forKey: EXS_UNIT_VOL)

        let coUnitStr = !coUnit.isEmpty ? coUnit : isCoin ? "1" : "2"
        var priceTypeStr = ""
        if priceType == nil {
            let type = EXStoreData.storeBool(forKey: EXS_IS_NEWPRICE)
            priceTypeStr = type ? "0" : "1"
        }else{
            priceTypeStr = priceType!
        }
        var expiredTimeStr = expiredTime
        if expiredTime.isEmpty {
            let idx = EXStoreData.storeObject(forKey: EX_DATE_CYCLE) as? Int ?? 0

            expiredTimeStr = EXSwapPlanOrderValidityPeriod.init(rawValue: idx)?.parm() ?? ""
        }
        
        let _ = networkApi.rx.request(.editUserConfig(id:id, positionModel: positionStr, coUnit: coUnitStr,expiredTime:expiredTimeStr, priceBasis:priceTypeStr )).exs_MJObjectMap(EXSVoidModel.self).subscribe { (_) in
            completion(true)
        } onError: { (_) in
            completion(false)
        }
    }
    
   static func changePositionMargin(id:Int64, positionId:Int64, amount:String, type:String, completion: @escaping SLContractNetworkCompletion) {
        let _ = networkApi.rx.request(.changePositionMargin(id: id, positionId: positionId, amount: amount, type:type)).exs_MJObjectMap(EXSVoidModel.self).subscribe { (_) in
            completion(true)
        } onError: { (_) in
            completion(false)
        }
    }
    
    public static func queryUserHasOpenAccount(completion:@escaping SLContractNetworkCompletion) {
       let _ = networkApi.rx
            .request(.getUserConfig(id: 0))
            .exs_MJObjectMap(SLUserConfig.self)
            .retry(3)
            .subscribe(onSuccess: { (config) in
                completion(config.hasOpenContract())
            },onError: { (_) in
                completion(false)
            })
        
    }
    static func getUserHistoryPosition(contractId:Int64,side:String, page:Int, limit:Int, success: @escaping ([EXSwapPositionModel]) -> (), failure: @escaping SLContractNetworkFailure) {
        let _ = networkApi.rx.request(.getUserHistoryPosition(id: contractId, side: side, page: page, limit: limit)).exs_MJObjectMap(EXSPositionOrAssetModel.self).subscribe { (model) in
            success(model.positionList)

        } onError: { (error) in
            failure(error)
        }
    }
    static func getPriceList(success: @escaping ([EXPricelistModel]) -> (), failure: @escaping SLContractNetworkFailure) -> Disposable {
        return networkApi.rx.request(.price_list).exs_MJObjectMap(EXSCommonAryModel.self).subscribe { (model) in
            var array = [EXPricelistModel]()
            for item in model.dictAry {
                let model = EXPricelistModel.itemWithDic(dic: item)
                if model != nil{
                    array.append(model!)
                }
            }
            if array.count > 0 {
                success(array)
            }
        } onError: { (error) in
            failure(error)
        }
    }

   public static func getUserPositionOrAsset(onlyAccount:Bool,marginCoin:String?,new:Bool? = false,success: @escaping (EXSPositionOrAssetModel) -> (), failure: @escaping SLContractNetworkFailure) -> Disposable {
        
        if let n = new, n == true { //新接口，优化 English: New interface, optimized
            return networkApi.rx.request(.getUserPositionOrAsset_new(onlyAccount: onlyAccount ? "1" : "0", marginCoin: marginCoin)).exs_MJObjectMap(EXSPositionOrAssetModel.self).subscribe { (model) in
                handleResult(model: model, onlyAccount: onlyAccount)
                success(model)
            } onError: { (error) in
                failure(error)
            }
        }
        
        return networkApi.rx.request(.getUserPositionOrAsset(onlyAccount: onlyAccount ? "1" : "0", marginCoin: marginCoin)).exs_MJObjectMap(EXSPositionOrAssetModel.self).subscribe { (model) in
            handleResult(model: model, onlyAccount: onlyAccount)
            success(model)
        } onError: { (error) in
            failure(error)
        }
        
    }
    
    static func handleResult(model:EXSPositionOrAssetModel,onlyAccount: Bool){
        EXSwapPrivateConfig.shared.profitUrl = model.assetUiUrl
        //更新合约账户信息 English: Update contract account information
        for item in model.accountList {
            let model = EXCItemCoinModel()
            model.canUseAmount = item.canUseAmount
            model.coin_code = item.symbol
            model.originalCoin = item.originalCoin
            EXSwapPersonInfo.shared.setSwapAsset(model, marginCode: item.symbol)
        }
        if !onlyAccount {
            EXSwapPersonInfo.shared.removeAllPositions()
            var dic = [Int64:[EXSwapPositionModel]]()
            for item in model.positionList {
                if var arr = dic[item.instrument_id] {
                    arr.append(item)
                    dic[item.instrument_id] = arr

                }else {
                    var arr = [EXSwapPositionModel]()
                    arr.append(item)
                    dic[item.instrument_id] = arr
                }
            }
            for (key,value) in dic {
                var positions = [EXSwapPositionModel]()
                for item in value {
                    positions.append(item)
                }
                EXSwapPersonInfo.shared.setPositions(positions, instrumentID: key)
            }
        }
    }
    static func queryProfitAndLossList(id:Int64, orderSide:String, success:@escaping ((EXContractProfitAndLossListModel)->()), failure: @escaping SLContractNetworkFailure) {
        
        let _ = networkApi.rx.request(.queryProfitAndLossList(id: id, orderSide: orderSide)).exs_MJObjectMap(EXContractProfitAndLossListModel.self).subscribe { (model) in
            success(model)
        } onError: { (error) in
            failure(error)
        }
    }
    static func queryTradeDetailList(contractId:Int64, orderId:Int64?,success: @escaping (([EXContractTradeDetailItem])->()), failure: @escaping SLContractNetworkFailure) {
        let _ = networkApi.rx.request(.queryTradeDetailList(contractId: contractId, orderId: orderId)).exs_MJObjectMap(EXContractTradeDetailListModel.self).subscribe { (model) in
            success(model.tradeList)
        } onError: { (error) in
            failure(error)
        }
    }
    
    static func revokeOrderForStopProfitOrStopLoss(contractId:Int64, orderIds:[String],success: @escaping SLContractNetworkSuccess,
                                                   failure: @escaping SLContractNetworkFailure) {
        let _  = networkApi.rx.request(.revokeOrderForStopProfitOrStopLoss(contractId: contractId, orderIds: orderIds.joined(separator:","))).exs_MJObjectMap(EXSVoidModel.self).subscribe { (_) in
            success()
        } onError: { (error) in
            failure(error)
        }
    }
    
    static func creatOrderStopProfitOrStopLossOrder(position:EXSwapPositionModel,
                                                    stopProfit:SLContractStopProfitOrStopLossOrder?,
                                                    stopLoss:SLContractStopProfitOrStopLossOrder?,
                                                    success: @escaping SLContractNetworkSuccess,
                                                    failure: @escaping (Bool) -> ()) {
    
        let creatModel = SLContractCreatStopProfitOrStopLossOrder.generateOrderBy(position: position)
        var list = [[String: Any]]()
        if let stopP = stopProfit {
            list.append(stopP.getParams())
        }
        if let stopL = stopLoss {
            list.append(stopL.getParams())
        }
        
        if let data = try? JSONSerialization.data(withJSONObject: list, options: []),let listString = String(data: data, encoding: String.Encoding.utf8)  {
          
            creatModel.orderListStr = listString;
            
            let _ = networkApi.rx.request(.creatOrderForStopProfitOrStopLoss(model: creatModel)).exs_MJObjectMap(EXProfitAndlossResponse.self).subscribe { (response) in
                
                if response.respList.count > 0 {
                    
                    let messages = response.respList.filter{$0.code != "0" }.map { (item) -> String in
                       
                        return item.msg
                    }
                    
                    if messages.count == 0 {
                        success()
                        return
                    }
                    
                    var message = messages.first
                    if message != nil, messages.count == 2 {
                        message! += "，" + messages[1]
                    }
                    failure(true)
                    EXAlert.showFail(msg: message ?? "")
                }else {
                    
                    success()
                }
                
            } onError: { (error) in
                failure(false)
            }
        }
    }
    
    static func creatOrder(order:EXContractOrderModel,success: @escaping SLContractNetworkSuccess, failure: @escaping SLContractNetworkFailure) {
        
        let creatModel = EXContractCreatOrder.generateOrderBy(order)
        let _ = networkApi.rx.request(.creatOrder(model: creatModel)).exs_MJObjectMap(EXSVoidModel.self).subscribe { (_) in
            success()
        } onError: { (error) in
            failure(error)
        }
    }
    
    static func cancelOrder(contractId:Int64, orderId:Int64?,type:Int64? = nil, isConditionOrder:Bool = false,success: @escaping SLContractNetworkSuccess, failure: @escaping SLContractNetworkFailure) {
        let _ = networkApi.rx.request(.cancelOrder(contractId: contractId, orderId: orderId,isConditionOrder:isConditionOrder,type:type)).exs_MJObjectMap(EXSVoidModel.self).subscribe { (_) in
            success()
        } onError: { (error) in
            failure(error)
        }
    }
    //k 线委托的买卖点 English: The buying and selling points entrusted by the K-line
    static func getHistoryOrderKlineData(contractId:Int64,success: @escaping (EXKlineOrderList) -> (), failure: @escaping SLContractNetworkFailure){
        let cId = contractId
        let model = EXContractQueryCurrentOrderList()
        model.isHistory =  true
        model.contractId = cId
        model.isKline = "1"
        model.page = 1
        model.limit = 200 //只要200 条 English: Just 200 pieces
        model.needTrigger = false
        
        return EXContractNetwork.queryKlineOrderList(model: model) { (orderResult) in
            if orderResult.orderList.count > 0 {
                success(orderResult)
            }
        } failure: { error in
            failure(error)
        }.disposed(by:disposeObject)

    }
    
    static func queryKlineOrderList(model:EXContractQueryCurrentOrderList, success: @escaping (EXKlineOrderList) -> (), failure: @escaping SLContractNetworkFailure) -> Disposable {
        return networkApi.rx.request(.currentOrderList(model: model)).exs_MJObjectMap(EXKlineOrderList.self).subscribe { (orderMdoel) in
            success(orderMdoel)
        } onError: { (error) in
            failure(error)
        }
    }
    
    static func queryCurrentOrderList(model:EXContractQueryCurrentOrderList, success: @escaping ([EXContractOrderModel], EXContractQueryCurrentOrderList, Int) -> (), failure: @escaping SLContractNetworkFailure) -> Disposable {
        
        return networkApi.rx.request(.currentOrderList(model: model)).exs_MJObjectMap(EXContractCurrentOrderList.self).subscribe { (orderMdoel) in
            
            var orderlist = [EXContractOrderModel]()
            if model.needTrigger == true {
                
                orderlist = orderMdoel.trigOrderList
            }else {
                orderlist = orderMdoel.orderList
                if model.contractId > 0 { //全部就不处理了 English: I won't handle everything anymore
                    EXSwapPersonInfo.shared.setOrders(orderMdoel.orderList, instrumentID: model.contractId)
                }else{
                    //                    var test = [EXContractOrderModel]()
                    //                    for i in 1...5{
                    //                        let oer = EXContractOrderModel()
                    //                        oer.contractId = Int64(i)
                    //                        oer.name = "\(i)" + "a"
                    //                        test.append(oer)
                    //                    }
                    //                    for i in 1...5{
                    //                        let oer = EXContractOrderModel()
                    //                        oer.contractId = Int64(i)
                    //                        oer.name = "\(i)" + "b"
                    //                        test.append(oer)
                    //                    }
                    //                    for i in 1...5{
                    //                        let oer = EXContractOrderModel()
                    //                        oer.contractId = Int64(i)
                    //                        oer.name = "\(i)" + "c"
                    //                        test.append(oer)
                    //                    }
                    //                    orderlist = test
                    var curretnDic = [Int64:[EXContractOrderModel]]()
                    for o in orderlist{
                        if curretnDic.keys.contains(o.contractId){
                            if var v = curretnDic[o.contractId]{
                                v.append(o)
                                curretnDic[o.contractId] = v
                            }
                        }else{
                            curretnDic[o.contractId] = [o]
                        }
                    }
                    //全部先清空 English: Empty All First
                    EXSwapPersonInfo.shared.swapOrderDict.removeAll()
                    
                    for item in curretnDic{
                        EXSwapPersonInfo.shared.setOrders(item.value, instrumentID: item.key)
                    }
                    
                }
                orderlist = orderMdoel.orderList
            }
            for item in orderlist {
                item.instrument_id = item.contractId
                item.setupDataWithInstrumentId()
                
                if model.needTrigger ?? false {
                    
                    if let status = EXSwapPlanOrderStatus.init(rawValue: item.orderStatus) {
                        item.statusDisplay = status.introduced
                    }
                    if let statusDes = EXSwapPlanOrderStatusMemo.init(rawValue: item.memo) {
                        item.memoDisplay = statusDes.introduce
                    }
                }else {
                    
                    if let status = EXSwapOrderStatus.init(rawValue: item.orderStatus) {
                        item.statusDisplay = status.introduced
                    }
                    if let statusDes = EXSwapOrderStatusMemo.init(rawValue: item.memo) {
                        item.memoDisplay = statusDes.introduce
                    }
                }
            }
            success(orderlist, model, orderMdoel.count)
        } onError: { (error) in
            failure(error)
        }
    }
    
   public static func getTransactionRecordList(model:EXSQueryTransactionRecordList,success: @escaping ([EXContractAssetRecordModel]) -> (), failure: @escaping SLContractNetworkFailure) {
        
        let _ = networkApi.rx.request(.getTransactionRecordList(model: model)).exs_MJObjectMap(EXContractAssetRecordsModel.self).subscribe { (recordsModel) in
            success(recordsModel.transList)
        } onError: { (error) in
            failure(error)
        }

    }
    
   public static func queryPublicInfo(success: @escaping (EXPublicInfoModel) -> (), failure:@escaping (Error) -> (),showError:Bool = false) {
        let _ = networkApi.rx.request(.publicInfo).exs_MJObjectMap(EXPublicInfoModel.self,showError).subscribe { (publicInfo) in
            EXSwapPublicInfo.shared.infoModel = publicInfo
            EXSwapPublicInfo.shared.localAndRemoteTimeInterval = (publicInfo.currentTimeMillis/1000 - Date().timeIntervalSince1970) * 1000
            if publicInfo.contractList.count > 0 {
                EXSwapPublicInfo.shared.setSwapInfo(publicInfo.contractList)
                EXSwapPublicInfo.shared.marginCoinList = publicInfo.marginCoinList
            }
            EXSwapPublicInfo.shared.languages = publicInfo.langList
            EXLanguageTools.shareInstance.tryDownloadCurrentLan()
            success(publicInfo)
          
        } onError: { (error) in
            failure(error)
        }

    }
    
    public static func queryPublicInfoOnly(success: @escaping (EXPublicInfoModel) -> (), failure:@escaping (Error) -> ()) {
         let _ = networkApi.rx.request(.publicInfo).exs_MJObjectMap(EXPublicInfoModel.self,false).subscribe { (publicInfo) in
             EXSwapPublicInfo.shared.infoModel = publicInfo
             EXSwapPublicInfo.shared.localAndRemoteTimeInterval = (publicInfo.currentTimeMillis/1000 - Date().timeIntervalSince1970) * 1000
             if publicInfo.contractList.count > 0 {
                 EXSwapPublicInfo.shared.setSwapInfo(publicInfo.contractList)
                 EXSwapPublicInfo.shared.marginCoinList = publicInfo.marginCoinList
             }
             success(publicInfo)
         } onError: { (error) in
             failure(error)
         }
     }
    
    static func queryRiskBalanceList(coinSymbol:String,page:Int,limit:Int,success: @escaping (EXSInstranceModel) -> (), failure: @escaping SLContractNetworkFailure) {
       let _ = networkApi.rx
            .request(.riskBalanceList(coinSymbol: coinSymbol, page: page, limit: limit))
            .exs_MJObjectMap(EXSInstranceModel.self)
            .subscribe { (model) in
                success(model)
            } onError: { (error) in
                failure(error)
            }
    }
    
    public static func querySymboRatelist(success: @escaping (EXSymboRateList) -> (),failure: @escaping SLContractNetworkFailure){
        let _ = networkApi.rx
            .request(.symbol_rate_list)
            .exs_customObjectMap(EXSymboRateList.self)
             .subscribe { (model) in
                 success(model)
             } onError: { (error) in
                 failure(error)
             }
    }
    static func queryLeverMaginInfo(contractId:Int64,success: @escaping (EXLeverMarginData) -> (), failure: @escaping SLContractNetworkFailure) {
        let _ = networkApi.rx
             .request(.leverMagrinInfo(contractId: contractId))
             .exs_customObjectMap(EXLeverMarginData.self)
             .subscribe(onSuccess: { (model) in
                 success(model)
             },onFailure: { (error) in
                 failure(error)
             })
     }
    static func queryFundingRateList(contractId:Int64,page:Int,limit:Int,success: @escaping (EXSFundingRateModel) -> (), failure: @escaping SLContractNetworkFailure) {
        
        let _ = networkApi.rx
             .request(.fundingRateList(contractId: contractId, page: page, limit: limit))
             .exs_MJObjectMap(EXSFundingRateModel.self)
             .subscribe { (model) in
                 success(model)
             } onError: { (error) in
                 failure(error)
             }
     }
    //请求保险余额 English: Request insurance balance
    static func queryRiskBalanceAccount(coinSymbol:String,success: @escaping (EXSInstrunceblanceAmountModel) -> (), failure: @escaping SLContractNetworkFailure) {
        
       let _ = networkApi.rx
            .request(.get_risk_account(coinSymbol: coinSymbol))
            .exs_MJObjectMap(EXSInstrunceblanceAmountModel.self)
            .subscribe { (model) in
                success(model)
            } onError: { (error) in
                failure(error)
            }
    }
    
    public static func getUserConfig(){
        if EXSwapPlatformSDK.shared.activeAccount?.token == nil {
            return
        }
        let tickerArr = EXSwapPublicInfo.shared.getSortTickers(area: .CONTRACT_BLOCK_UNKOWN) ?? []
        if tickerArr.count == 0 {
           // self.queryPublicInfo(showErr: false)
            return
        }
        let instrumentId = tickerArr.first?.instrument_id ?? 0
        networkApi.rx
            .request(.getUserConfig(id: instrumentId))
            .exs_MJObjectMap(SLUserConfig.self)
            .subscribe(onSuccess: {_  in
            },onError: { _ in
            }).disposed(by: self.exs_disposeBag)
    }
}


