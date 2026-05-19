//
//  EXSwapMarkOrderViewModel.swift
//  Chainup
//
//  Created by ZYJ on 2023/11/8.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import EXKit

#if DEBUG
    private let EX_SwapLogEnabled = { ProcessInfo.processInfo.environment["EX_SwapLogEnabled"] == "1" }()
#endif

///
/// - Parameters:
///   - message: Print messages
///   - file: Print Category
///   - lineNumber: Print the number of lines where the statement is located
public func EXLogLine<T>(mark: String, message : T, file : String = #file, lineNumber : Int = #line, function: String? = nil) {
    #if DEBUG
        guard EX_SwapLogEnabled else { return }
        let fileName = (file as NSString).lastPathComponent
        let log = "[\(mark)]-[function:\(function ?? "")][\(fileName):line:\(lineNumber)]-\(message)"
        let time = "-[time]" + EXSDateTools.nowTime() + "\n"
        let msg = "\n" + log + time
         
        if mark == wsWorklog {
            EXSwapLogManger.shareInstance.writeLog(content: msg)
        }
        print(msg)
    #endif
}
public func EXLogLine<T>(message : T, file : String = #file, lineNumber : Int = #line) {
    #if DEBUG
        guard EX_SwapLogEnabled else { return }
        let fileName = (file as NSString).lastPathComponent
        let log = "[\(fileName):line:\(lineNumber)]-\(message)"
        print(log)
    #endif
}




class EXSwapMarkOrderViewModel: NSObject {
    typealias MakerOrderAssetChangeBlock = () -> ()
    var makerOrderAssetChangeBlock:MakerOrderAssetChangeBlock?
    
    typealias MakerOrderUnitChangeBlock = () -> ()
    var makerOrderUnitChangeBlock:MakerOrderUnitChangeBlock?
    ///
    var itemModel : EXSwapItemModel? {
        didSet {
        }
    }
    
    var asset :EXCItemCoinModel? {
        get {
            EXSwapPersonInfo.shared.getSwapAssetItem(withCoin: itemModel?.ex_contractInfo?.margin_coin ?? "")
        }
    }
    var canUseAmount:String {
        if let a = asset {
            return  a.canUseAmount.toValuePrecision(withContract:itemModel!.instrument_id)
        }
        return "0".toValuePrecision(withContract:itemModel!.instrument_id)
    }
    
    
    /// 以币为单位 English: /In currency units
    var isCoin : Bool {
        return EXStoreData.storeBool(forKey: EXS_UNIT_VOL)
    }
    
    /// 价格单位 English: /Price unit
    var priceUnit:String {
    
        return itemModel?.ex_contractInfo?.quote_coin ?? ""
    }
    
    /// 成本单位 English: /Cost unit
    var costUnit:String {
        return itemModel?.ex_contractInfo?.margin_coin ?? ""
    }
    
    /// 数量单位 English: /Quantity unit
    var volumeUnit : String? {
        return itemModel?.ex_contractInfo?.volumeUnit ?? "-"
    }
    var openValueUnit:String {
        return itemModel?.ex_contractInfo?.openValueUnit ?? ""
    }
    /// 当前杠杆 English: /Current leverage
    var leverage : String = ""
    
    /*
     按数量下单 ： English: Order by quantity:
         正向合约：单位显示 币 or 张取用户的交易配置， English: Positive contract: The unit displays the transaction configuration of the currency or Zhang withdrawal user,
                          若为币，显示单位为基础货币，如BTCUSDT，币为BTC English: If it is in currency, the display unit is the base currency, such as BTCUSDT, and the currency is BTC
                          若为张，显示单位为张 English: If it is Zhang, the display unit is Zhang
         反向合约：单位显示 币 or 张取用户的交易配置， English: Reverse contract: Unit displays the transaction configuration of the currency or Zhang withdrawal user,
                          若为币，显示单位为计价货币，如BTCUSD，币为USD English: If it is in currency, the display unit is the pricing currency, such as BTCUSD, and the currency is USD
                          若为张，显示单位为张 English: If it is Zhang, the display unit is Zhang
     按价值下单 ： English: Order by value:
           正向合约： 单位显示为计价货币，如BTCUSDT,计价货币为USDT English: Positive contract: The unit is displayed as the pricing currency, such as BTCUSDT, and the pricing currency is USDT
           反向合约： 单位显示为基础货币，如BTCUSD,  基础货币为BTC English: Reverse contract: The unit is displayed as the base currency, such as BTCUSD, and the base currency is BTC

     */
    
    func getOpenOrderQutryUnit() -> [EXSBouncedModel]{
        guard let item = itemModel else{
            return [EXSBouncedModel(),EXSBouncedModel()]
        }
        //按数量下单 English: Order by quantity
        var qtyUnit = ""
        if (item.ex_contractInfo?.isReverse ?? false) == true { //反向 English: reverse
            
            if isCoin{
                qtyUnit = item.ex_contractInfo?.quote_coin ?? ""
            }else{
                //张 English: Zhang
                qtyUnit = "cp_overview_text9".ex_localized()
            }
            
        }else{ //正向 English: Forward
            if isCoin{
                qtyUnit = item.ex_contractInfo?.base ?? ""
            }else{
                //张 English: Zhang
                qtyUnit = "cp_overview_text9".ex_localized()
            }
        }
        let qty = EXSBouncedModel()
        qty.openType = .qty
        qty.name = qtyUnit
        //价值单位 English: Value unit
        var valueUnit = ""
        if (item.ex_contractInfo?.isReverse ?? false) == true { //反向 English: reverse
            valueUnit = item.ex_contractInfo?.base ?? ""
        }else{ //正向 English: Forward
            valueUnit = item.ex_contractInfo?.quote_coin ?? ""
        }
        let value = EXSBouncedModel()
        value.openType = .value
        value.name = valueUnit
        return [qty,value]
       
    }
    /// 杠杆类型 English: /Type of lever
    var leverage_type : BTPositionOpenType {
        set {
        }
        get {
            let data = EXStoreData.storeObject(forKey: "BTLeveageType"+String(itemModel?.instrument_id ?? 0))
            if data == nil {
                return BTPositionOpenType.unKnow
            }
            guard let dataStr = data as? String else {
                return BTPositionOpenType.unKnow
            }
            if dataStr == "cp_contract_setting_text2".ex_localized() {
                return BTPositionOpenType.pursueType
            } else if dataStr == "cp_contract_setting_text1".ex_localized() {
                return BTPositionOpenType.allType
            } else {
                return BTPositionOpenType.unKnow
            }
        }
    }
    
    /// 开多订单 English: /Open multiple orders
    var orderLongModel : EXContractOrderModel?
    /// 开空订单 English: /Open empty orders
    var orderShortModel : EXContractOrderModel?
    
    /// 平空仓订单 English: /Closing warehouse orders
    var orderCloseShortModel : EXContractOrderModel?
    /// 平多仓订单 English: /Pingduo Warehouse Order
    var orderCloseMoreModel : EXContractOrderModel?
    
    /// 买单深度 English: /Buying depth
    var buyDepthOrder : [EXOrderBookModel]? {
        get {
            return EXSwapPublicInfo.shared.getBidOrderBooks(10) ?? []
        }
    }
    
    /// 卖单深度 English: /Selling depth
    var sellDepthOrder : [EXOrderBookModel]? {
        get {
            return EXSwapPublicInfo.shared.getAskOrderBooks(0) ?? []
        }
    }
    
    /// 持多仓 English: /Holding long positions
    var buyPosition : EXSwapPositionModel? {
        get {
            return EXFormula.getUserPosition(with: itemModel!, contractWay: .buy_OpenLong)
        }
    }
    /// 持空仓 English: /Holding an empty position
    var sellPosition : EXSwapPositionModel? {
        get {
            return EXFormula.getUserPosition(with: itemModel!, contractWay: .sell_OpenShort)
        }
    }
    //持仓的仓位价值 所有仓位 English: The value of positions held All positions
    func hasOpenedPositionValue(side:BTPositionType) -> String {
        if let positions = EXSwapPersonInfo.shared.getPositions(itemModel?.instrument_id ?? 0) {
            let positionValue = positions.reduce("0", { (result, positionM) -> String in
                return result.bigAdd(positionM.positionBalance)
            })
            return positionValue
        }
        return  "0"
    }
    //委托的仓位价值 不分方向 English: The value of entrusted positions is not directional
    func hasOpenedOrderValue(side:BTContractOrderWay) -> String {
        if let orders = EXSwapPersonInfo.shared.getOrders(itemModel?.instrument_id ?? 0) {
            let orderValue = orders.reduce("0") { (result, orderModel) -> String in
                if orderModel.isOpen() {
                    return result.bigAdd(orderModel.orderBalance)
                }
                return result
            }
            return orderValue
        }
        return  "0"
    }
    
    var hasOpenedShortVolume : String {
        let a = hasOpenedPositionValue(side: .openEmpty)
        let b = hasOpenedOrderValue(side: .sell_OpenShort)
        let all = a + b
        return all
    }
    var hasOpenedMoreValue : String {
        let a = hasOpenedPositionValue(side: .openMore)
        let b = hasOpenedOrderValue(side: .buy_OpenLong)
        let all = a + b
        return all
    }
    /// 可开多 English: /Kaiduo
    var canOpenMore = "0"
    /// 可开空 English: /Can be opened empty
    var canOpenShort = "0"
    var canOpenMoreValue = "0"
    var canOpenShortValue = "0"
    
    var openOrderValueMin = "0" //价值下单最小值 English: Value minimum order value
    var openOrderValueMax = "0" //价值下单最大值 English: Maximum value for placing an order
    var openOrderCoinMin = "0" //币下单最小值 English: Minimum value for coin ordering
    var openOrderCoinMax = "0" //币下单最大值 English: Maximum value of coin ordering
    var canCloseShortVolume = "0"//
    var canCloseMoreVolume = "0"//
    /// 可平空 English: /Can level the air
    var canCloseShort : String {
        get {
            if let sellP = sellPosition {
                
                var canClose = sellP.canCloseVolume
                canCloseShortVolume = canClose
                if !canClose.isEmpty {
                    
                    if isCoin {
                        canClose = EXFormula.ticket(toCoin: canClose, price: "", contract: itemModel!.ex_contractInfo)
                    }
                    return canClose
                }
            }
            return "0"
        }
    }
    /// 可平多 English: /Kepingduo
    var canCloseMore : String {
        get {
            if let buyP = buyPosition {
                
                var canClose = buyP.canCloseVolume
                canCloseMoreVolume = canClose
                if !canClose.isEmpty {
                    
                    if isCoin {
                        canClose = EXFormula.ticket(toCoin: canClose, price: "", contract: itemModel!.ex_contractInfo)
                    }
                    return canClose
                }
            }
            return "0"
        }
    }
    
    var holdMoreNum : String {
        get {
            var hold = buyPosition?.cur_qty ?? "0"
            if isCoin {
                hold = EXFormula.ticket(toCoin: hold, price: "", contract: itemModel!.ex_contractInfo)
            }
            return hold
        }
    }
    
    var holdShortNum : String {
        get {
            var hold = sellPosition?.cur_qty ?? "0"
            if isCoin {
                hold = EXFormula.ticket(toCoin: hold, price: "", contract: itemModel!.ex_contractInfo)
            }
            return hold
        }
    }
    
    
// MARK: - 生成开仓单 English: MARK: - Generate warehouse receipt
    func loadOpenOrder(px: String?,
                       emptyPx:String?,
                       opponentType:EXOpponentPriceType = .none,
                       moreQty: String?,
                       emptyQty: String?,
                       currentPercent:String = "",
                       perform_px : String?,
                       contractType: EXSwapMarketOrderType,
                       priceType: EXSwapMarketOrderPriceType,
                       planPriceType: EXSwapPlanOrderPriceType,
                       timeForce: Int,
                       openOrderType: EXOpenOrderType
    ) {
        orderLongModel = caculateOpenOrder(side: .buy_OpenLong,
                                           px: px ?? "0",
                                           opponentType:opponentType,
                                           qty: moreQty ?? "0",
                                           currentPercent: currentPercent,
                                           perform_px: perform_px ?? "0",
                                           contractType: contractType,
                                           priceType: priceType,
                                           planPriceType: planPriceType,
                                           timeForce:timeForce, openOrderType: openOrderType)
        orderShortModel = caculateOpenOrder(side: .sell_OpenShort,
                                                 px: emptyPx ?? "0",
                                                 opponentType:opponentType,
                                                 qty: emptyQty ?? "0",
                                                 currentPercent: currentPercent,
                                                 perform_px: perform_px ?? "0",
                                                 contractType: contractType,
                                                 priceType: priceType,
                                                 planPriceType: planPriceType,
                                            timeForce:timeForce, openOrderType: openOrderType)
    }
    fileprivate func canOpenAvailableText(_ contractType: EXSwapMarketOrderType, _ longNum: String, _ order: EXContractOrderModel) -> String {

        if isCoin {
            return longNum.toVolumePrecision(withContractID: itemModel!.instrument_id,holdZero: false)
        } else {
            
            return EXFormula.coin(toTicket: longNum, price: "", contract: itemModel!.ex_contractInfo).toString(0)
        }
    }
    
    func  caculateOpenOrder(side : BTContractOrderWay,
                           px: String,
                           opponentType:EXOpponentPriceType = .none,
                           qty: String,
                           currentPercent:String = "",
                           perform_px : String,
                           contractType: EXSwapMarketOrderType,
                           priceType: EXSwapMarketOrderPriceType,
                           planPriceType: EXSwapPlanOrderPriceType,
                           timeForce: Int,
                           openOrderType: EXOpenOrderType
    ) -> EXContractOrderModel {
        let order = EXContractOrderModel()
        var openOrder : EXContractsOpenModel?
        
        order.opponentType = opponentType
        order.currentPercent = currentPercent
        order.instrument_id = itemModel!.instrument_id;
        order.leverage = leverage;
        order.index_px = itemModel!.index_px;
        order.position_type = leverage_type;
        order.qty = qty
        order.qty2 = qty
//        //print(" order.qty = \(order.qty)")
        order.openOrderType = openOrderType
        EXLogLine(message: "输入 order.qty = \(order.qty)")
        //市价类型 English: Market price type
        //MARK:qty 精度是否需跟市价一致 English: MARK: Does the qty accuracy need to be consistent with the market price
        if contractType.isMarketOrderType() {
            order.qty = qty.marketPriceVolPrecision(withContract: itemModel?.ex_contractInfo?.instrument_id ?? 0)
            EXLogLine(message: "市价 =输入  精度处理后 = \(order.qty)")
        }else {
            if openOrderType == .qty { //这里是将数量统一转化成张 English: Here is the unified conversion of quantity into Zhang
                if isCoin {
                    if case .planOrder(_) = contractType, planPriceType == .limitPlan {
                        order.qty = EXFormula.coin(toTicket: qty, price: perform_px, contract: itemModel!.ex_contractInfo).toString(0)
                        EXLogLine(message: "数量下单 币  计划限价= 价格 perform_px=\(perform_px) \(order.qty)")
                    } else {
                        order.qty = EXFormula.coin(toTicket: qty, price: px, contract: itemModel!.ex_contractInfo).toString(0)
                        EXLogLine(message: "数量下单 币  非计划限价= 价格 px=\(px) \(order.qty)")
                    }
                }else {
                    EXLogLine(message: "数量下单 张 = = \(order.qty)")
                    order.qty = qty.toString(0)
                }
            }
            //价值开仓-价值转换为张 这里不能处理,校验会出错,在提交数据的时候价值转换为张 English: Value opening - value conversion to Zhang cannot be processed here, verification will result in errors. When submitting data, value conversion to Zhang
        }
        
        order.side = side;
        if contractType == .limited { // 普通单 English: Ordinary single
            if priceType == .limitPrice { // 限价单 English: Price limit order
                order.category = .normal
                order.px = px
            }
        } else if contractType.isHighOrderType() {
            if priceType == .limitPrice { // 限价单 English: Price limit order
                order.px = px
            }
            if timeForce == 1 {
                order.category = .postOnly
            } else if timeForce == 2 {
                order.category = .FOK
            } else if timeForce == 3 {
                order.category = .IOC
            }
            
        } else  if case let .planOrder(isMarket) = contractType { // 计划单 English: Plan sheet
            //            order.px = px
            
            if isMarket { //条件委托市价委托：委托价格 = 触发价格 English: Conditional commission market price commission: commission price=trigger price
                order.category = .planMarket
//                order.exec_px = middleValue()
                order.exec_px = px
            } else {
                order.category = .plan;
                order.exec_px = perform_px;
            }
            order.px = order.exec_px
            order.triggerPrice = px
            order.orderCycle = EXStoreData.storeObject(forKey: EX_DATE_CYCLE) as? Int ?? 0
            
        }else if contractType == .market {
            order.category = .market
            order.px = middleValue()
        }
        
        if let contractInfo = itemModel?.ex_contractInfo,let ass  = asset {
            
            openOrder = EXContractsOpenModel.init(orderModel: order, contractInfo: contractInfo, assets: ass)
        }
        
        if openOrder != nil {
            //市价或限价价值开单 English: Market or limit value invoicing
            if openOrderType == .value || contractType.isMarketOrderType(){
                let isMarket = contractType.isMarketOrderType()
                getValueOpenOrderMaxMinLimit(price: order.px,isMarket: isMarket)
            }

            
            if side == .buy_OpenLong {
                //1可用资产 最大可开数量-（币和张） English: 1. Maximum available assets that can be opened - (in coins and pieces)
                canOpenMore = canOpenAvailableText(contractType, openOrder?.maxOpenLong ?? "0", order)
                //2风控可开的值 = 计算当前配置的可开的最大值 -  当前持仓和委托的值 English: 2. Value that can be opened for risk control=Calculate the maximum value that can be opened for the current configuration - Current position and entrusted value
                //                //print("1可用资产 最大可开值 = \(canOpenMore) 风控可开的 =\(currentLevelMaximumCanOpen(px: order.px, side: side))") English: Print ("1. Maximum available asset opening value=\ (canOpenMore) Risk control opening value=\ (currentLevelMaximumCanOpen (px: order. px, side: side))")
                if let value = currentLevelMaximumCanOpen(px: order.px, side: side),value.greaterThanOrEqual(BTZERO),
                   canOpenMore.greaterThan(value) {
                    /// print ("1. Maximum available asset opening value= (canOpenMore) Risk control opening value= (currentLevelMaximumCanOpen (px: order. px, side: side)")
                    canOpenMore = value
                }
                //最大可价值 English: Maximum Valuable
                canOpenMoreValue = openOrder!.maxOpenValue
//                //print("asset canOpenMore= \(canOpenMore)")
                if let value = currentLevelMaximumCanOpenValue(side: side),
                   value.greaterThanOrEqual(BTZERO),canOpenMoreValue.greaterThan(value) {
                    canOpenMoreValue = value
                }
                
            } else if side == .sell_OpenShort {
                
                canOpenShort = canOpenAvailableText(contractType, openOrder?.maxOpenShort ?? "0", order)
                
                if let value = currentLevelMaximumCanOpen(px: order.px, side: side),
                   value.greaterThanOrEqual(BTZERO),
                   canOpenShort.greaterThan(value){
                    canOpenShort = value
                }
                
                canOpenShortValue = openOrder!.maxOpenValue
                if let value = currentLevelMaximumCanOpenValue(side: side),
                   value.greaterThanOrEqual(BTZERO),canOpenShortValue.greaterThan(value) {
                    canOpenShortValue = value
                }
            }
            order.freezAssets = openOrder!.freezAssets
        }
        return order
    }
    
    
    
    /*
     //MARK:  限价委托价值限制 English: MARK: Price limit commission value limit
     1.提交开仓普通委托、条件委托、止盈止损时的委托单笔数量最小/大值限制 English: 1. The minimum/maximum limit on the number of orders submitted for opening regular orders, conditional orders, and stop loss orders
     
     1.1 价格 English: 1.1 Price
     普通委托、条件委托、止盈止损限价委托： English: Ordinary commission, conditional commission, stop loss and limit price commission:
              委托价格 = 用户设置的委托价格 English: Commission price=commission price set by the user
     普通委托市价委托： English: Ordinary commission market price commission:
              委托价格 =  中位数（买一，卖一，最新成交价） English: Commission price=median (buy one, sell one, latest transaction price)
             中位数计算规则： English: Median calculation rules:
              若不存在委托价格（没有买一、卖一和最新成交价），委托不可提交，提示“委托不可提交” English: If there is no commission price (without buy one, sell one, and the latest transaction price), the commission cannot be submitted, and a prompt "Commission cannot be submitted" is displayed
     条件委托、止盈止损市价委托： English: Conditional commission, stop loss and stop loss market price commission:
              委托价格 = 触发价格 English: Commission price=trigger price
              风险点：条件委托触发后，可能因为在最小限额的临界点导致低于单笔最小下单额，概率较低 English: Risk point: After the conditional delegation is triggered, the probability of being lower than the minimum order amount for a single transaction may be low due to being at the critical point of the minimum limit

     1.2
     最小/大下单数量按照后台配置的最小/大下单量（张）或者折算后的值进行限制 English: The minimum/maximum order quantity is limited based on the minimum/maximum order quantity (pieces) configured in the backend or the converted value

     正向合约： English: Positive contract:
     单笔最小/大下单数量（张）= 后台设置最小/大下单数量（张） English: Minimum/maximum order quantity per transaction (pieces)=Minimum/maximum order quantity set in the background (pieces)
     单笔最小/大下单数量（币） = 后台设置最小/大下单数量（张）* 合约面值 English: Minimum/maximum order quantity per transaction (in currency)=minimum/maximum order quantity set in the background (in pieces) * contract face value
     单笔最小/大下单数量（价值币种）=  后台设置最小/大下单数量（张）* 合约面值 * 委托价格 English: Minimum/maximum order quantity per transaction (value currency)=minimum/maximum order quantity set in the background (pieces) * contract face value * commission price

     反向合约： English: Reverse contract:
     单笔最小/大下单数量（张）= 后台设置最小/大下单数量（张） English: Minimum/maximum order quantity per transaction (pieces)=Minimum/maximum order quantity set in the background (pieces)
     单笔最小/大下单数量（币） = 后台设置最小/大下单数量（张）* 合约面值 English: Minimum/maximum order quantity per transaction (in currency)=minimum/maximum order quantity set in the background (in pieces) * contract face value
     单笔最小/大下单数量（价值币种）= （ 后台设置最小/大下单数量（张）* 合约面值） / 委托价格 English: Minimum/maximum order quantity per transaction (value currency)=(minimum/maximum order quantity set in the background (pieces) * contract face value)/commission price
     
     最小下单数量（价值币种）结果最大保留的小数位为最小下单额的精度，进位制 English: The precision of the minimum order quantity (value currency) result with the maximum reserved decimal places is the minimum order amount, based on the rounding system
     精度保留为后端返回的「最小下单额」的精度，进位制，如计算结果为 5.06 U，最小下单额精度为 1，则最后取值 5.1 English: The precision is retained as the precision of the "minimum order amount" returned by the backend, using a rounding system. If the calculation result is 5.06 U and the minimum order amount precision is 1, the final value is 5.1
     
     最大下单数量（价值币种）结果最大保留的小数位为最小下单额的精度，舍位制 English: The maximum order quantity (value currency) result is the precision of the minimum order amount, rounded to the nearest integer
     精度保留为后端返回的「最小下单额」的精度，舍位制，如计算结果为 50000.06 U，最小下单额精度为 1，则最后取值 50000 English: The accuracy is retained as the "minimum order amount" accuracy returned by the backend, using a rounding system. If the calculation result is 50000.06 U and the minimum order amount accuracy is 1, the final value is 50000
     
     若用户提交数量小于上述计算的最小下单数量，则提示： English: If the number of user submissions is less than the minimum order quantity calculated above, a prompt will appear:
     “委托数量须大于最小值 XXX 张”或“委托数量须大于最小值 XXX BTC”或“委托价值须大于最小值 XXX USDT” English: "The number of commissions must be greater than the minimum value of XXX sheets" or "The number of commissions must be greater than the minimum value of XXX BTC" or "The value of commissions must be greater than the minimum value of XXX USDT"

     若用户提交数量大于上述计算的最大下单数量，则提示： English: If the number of user submissions exceeds the maximum order quantity calculated above, a prompt will appear:
     “委托数量须小于最大值 XXX 张”或“委托数量须小于最大值 XXX BTC”或“委托价值须小于最大值 XXX USDT” English: "The number of commissions must be less than the maximum value of XXX sheets" or "the number of commissions must be less than the maximum value of XXX BTC" or "the commission value must be less than the maximum value of XXX USDT"
     
     */
    func getValueOpenOrderMaxMinLimit(price: String, isMarket: Bool){
        if let contractInfo = itemModel?.ex_contractInfo {
            EXLogLine(message: "市价最大量\(contractInfo.coinResultVo.maxMarketVolume) 限价最大量\(contractInfo.coinResultVo.maxLimitVolume)")
            let maxVol = isMarket ? contractInfo.coinResultVo.maxMarketVolume : contractInfo.coinResultVo.maxLimitVolume
            EXLogLine(message:"xxxx price =\(price) 最小下单量 = \(contractInfo.coinResultVo.minOrderVolume) 市价\(isMarket) 最大下单量 = \(maxVol)")
            let min = EXFormula.calculateContractValue(withVol: contractInfo.coinResultVo.minOrderVolume, price: price, contract: contractInfo)
            let max = EXFormula.calculateContractValue(withVol: maxVol, price: price, contract: contractInfo)
            let deci = Int16(EXSTools.decimalValue(px_unit: contractInfo.minOrderMoney_unit))
            EXLogLine(message:"xxxx =deci \(contractInfo.minOrderMoney_unit) = deci =\(deci)")
            openOrderValueMin = min.bigAdd("0",decimals: deci,up: true)
            openOrderValueMax = max.bigAdd("0",decimals: deci,up: false)
            EXLogLine(message:"xxxx min =\(min) 进位 = \(openOrderValueMin) max = \(max) 舍位=、\(openOrderValueMax)")
        }
    }
    func getCoinOpenOrderMaxMinLimit(){
        if let contractInfo = itemModel?.ex_contractInfo {
            EXLogLine(message: "限价最大量\(contractInfo.coinResultVo.maxLimitVolume)")
            let min = EXFormula.ticket(toCoin: contractInfo.coinResultVo.minOrderVolume, contract: contractInfo)
            let max = EXFormula.ticket(toCoin: contractInfo.coinResultVo.maxLimitVolume, contract: contractInfo)
            openOrderCoinMin = min
            openOrderCoinMax = max
            EXLogLine(message:"xxxx min =\(min) 进位 = \(openOrderCoinMin) max = \(max) 舍位=、\(openOrderCoinMax)")
        }
    }
    
    //当前配置的杠杆最大的可开价值 English: The maximum exploitable value of the currently configured leverage
    func currentLevelMaximumCanOpenValue(side:BTContractOrderWay) -> String? {
        if let info = itemModel?.ex_contractInfo,
           let maxValue = info.leverAndMaxValueDic[leverage] {
            if side == .sell_OpenShort {
                return maxValue.bigSub(hasOpenedShortVolume)
            }
            if side == .buy_OpenLong {
                return maxValue.bigSub(hasOpenedMoreValue)
            }
            
        }
        return nil
    }
    
//    * 最大可开张数/数量 = min{风险限额计算的可开张数，保证金计算的可开张数} English: *Maximum number of openings/quantity=min {number of openings calculated based on risk limit, number of openings calculated based on margin}
//    * <p>
//    * 风险限额计算的可开张数计算： English: *Calculation of the number of open accounts for risk limit calculation:
//    * 正向：最大可开张数 = （当前合约最大可开额度-当前合约持仓仓位价值-当前合约未成交委托价值）*汇率/（价格*面值） English: *Positive: Maximum number of open positions=(maximum open limit of current contract - value of current contract positions - value of current contract non executed commissions) * Exchange rate/(price * face value)
//    * 反向：最大可开张数 = （当前合约最大可开额度-当前合约持仓仓位价值-当前合约未成交委托价值）*价格/面值 English: *Reverse: Maximum number of open positions=(maximum open limit of current contract - value of current contract positions - value of current contract non executed commissions) * price/face value
//    * 正向：最大可开量 = （当前合约最大可开额度-当前合约持仓仓位价值-当前合约未成交委托价值）*汇率/价格 English: *Positive: Maximum opening amount=(Maximum opening amount of current contract - Value of current contract position - Value of current contract non executed commission) * Exchange rate/price
//    * 反向：最大可开量 = （当前合约最大可开额度-当前合约持仓仓位价值-当前合约未成交委托价值）*价格 English: *Reverse: Maximum open quantity=(maximum open limit of current contract - value of current contract position - value of current contract non executed commission) * price
//    * <p>
//    * 持仓价值计算： 接口返回的字段就是计算后的价格 English: *Position value calculation: The field returned by the interface is the calculated price
//    * 正向：持仓价值 = 持仓均价*持仓数量*合约面值*汇率 English: *Positive: Position value=Average position price * Position quantity * Contract face value * Exchange rate
//    * 反向：持仓价值 = 持仓数量*合约面值/持仓均价 English: *Reverse: Position value=Position quantity * Contract face value/Average position price
//    * 委托价值计算： 接口返回的字段就是计算后的价格 English: *Entrusted value calculation: The field returned by the interface is the calculated price
//    * 正向：委托价值 = 委托价格*开仓委托数量*合约面值*汇率 English: *Positive: Entrustment value=Entrustment price * Opening entrustment quantity * Contract face value * Exchange rate
//    * 反向：委托价值 = 开仓委托数量*合约面值/委托价格 English: *Reverse: Commission value=number of opening commissions * contract face value/commission price
//
    //风险限额计算的可开张数计算 English: Calculation of the number of openings available for risk limit calculation
    func currentLevelMaximumCanOpen(px:String,side:BTContractOrderWay) -> String? {
        
        if let info = itemModel?.ex_contractInfo,
           //surplusValue 差值 English: SurplusValue difference
           let surplusValue = currentLevelMaximumCanOpenValue(side: side) {
            var value = ""
            if info.isReverse {
                //反向：最大可开量   = （当前合约最大可开额度-当前合约同方向持仓仓位价值-当前合约同方向未成交委托价值）*价格 English: Reverse: Maximum open quantity=(Maximum open limit of current contract - Value of open positions in the same direction of current contract - Value of unexecuted orders in the same direction of current contract) * Price
                //反向：最大可开张数  = （当前合约最大可开额度-当前合约同方向持仓仓位价值-当前合约同方向未成交委托价值）*价格/面值 English: Reverse: Maximum number of open positions=(maximum open limit of current contract - value of open positions in the same direction of current contract - value of open orders in the same direction of current contract) * price/face value
                value = surplusValue.bigMul(px)//*价格   ->//最大可开量 English: Maximum opening capacity
            }else{
                //正向：最大可开量 = （当前合约最大可开额度-当前合约同方向持仓仓位价值-当前合约同方向未成交委托价值）*汇率/价格 English: Positive: Maximum open quantity=(Maximum open limit of current contract - Value of open positions in the same direction of current contract - Value of unsettled orders in the same direction of current contract) * Exchange rate/price
                //正向：最大可开张数 = （当前合约最大可开额度-当前合约同方向持仓仓位价值-当前合约同方向未成交委托价值）*汇率/（价格*面值） English: Positive: Maximum number of open positions=(Maximum open limit of current contract - Value of open positions in the same direction of current contract - Value of unexecuted orders in the same direction of current contract) * Exchange rate/(Price * Face value)
                value = surplusValue.bigMul(info.marginRate).bigDiv(px) //*汇率/ English: *Exchange rate/
            }
            if !isCoin { // 张数 都是最大量/面值 English: The number of sheets is the maximum amount/face value
                return EXFormula.coin(toTicket: value, price: "", contract: itemModel?.ex_contractInfo).toString(0)
            }
            return value.toVolumePrecision(withContractID: itemModel?.instrument_id ?? 0)
            
        }
        return nil
    }
    
    func middleValue() -> String {
        var pxArr = [String]()
        if let px = buyDepthOrder?.first?.px {
            pxArr.append(px)
        }
        if let px = itemModel?.last_px {
            pxArr.append(px)
        }
        if let px = sellDepthOrder?.first?.px {
            pxArr.append(px)
        }
        
        if pxArr.count == 3 {
            
            pxArr = pxArr.sorted(by: { (a, b) -> Bool in
                return  a.newString() < b.newString()
            })
            EXLogLine(message: "pxArr =\(pxArr), 中位数 =\(pxArr[1])")
            return pxArr[1]
        }
        
        if pxArr.count == 2 {
            let ret = (EXSTools.handleDouble(pxArr.first ?? "") + EXSTools.handleDouble(pxArr.last ?? "")) / 2
            return "\(ret)"
        }
        
        if pxArr.count == 1 {
            return pxArr.first!
        }
        return ""
    }
// MARK:- 生成平仓单 English: MARK: - Generate closing order
    func loadCloseOrder(px: String?,
                        emptyPx:String?,
                        qty: String?,
                        qtyPrecent:String?,
                        opponentType:EXOpponentPriceType = .none,
                        perform_px : String?,
                        contractType: EXSwapMarketOrderType,
                        priceType: EXSwapMarketOrderPriceType,
                        planPriceType: EXSwapPlanOrderPriceType,
                        timeForce: Int){
        // 平空仓单 English: Flat warehouse receipt
        var closeShortQty = qty
        var closeMoreQty = qty
        if let q = qtyPrecent, q.count > 0 {
            closeShortQty = q.bigMul(canCloseShort)
            closeMoreQty = q.bigMul(canCloseMore)
        }
        orderCloseShortModel = carculteCloseOrder(side: .buy_CloseShort,
                                                  px: px ?? "0",
                                                  opponentType:opponentType,
                                                  qty: closeShortQty ?? "0",
                                                  perform_px: perform_px ?? "0",
                                                  contractType: contractType,
                                                  priceType: priceType,
                                                  planPriceType: planPriceType,
                                                  timeForce: timeForce)
        orderCloseShortModel?.pid = self.sellPosition?.pid ?? 0
        // 平多仓单 English: Ping Duo Warehouse Receipt
        orderCloseMoreModel = carculteCloseOrder(side: .sell_CloseLong,
                                                  px: emptyPx ?? "0",
                                                  opponentType:opponentType,
                                                  qty: closeMoreQty ?? "0",
                                                  perform_px: perform_px ?? "0",
                                                  contractType: contractType,
                                                  priceType: priceType,
                                                  planPriceType: planPriceType,
                                                  timeForce: timeForce)
        orderCloseMoreModel?.pid = self.buyPosition?.pid ?? 0
        
    }
    func carculteCloseOrder(side : BTContractOrderWay,
                            px: String,
                            opponentType:EXOpponentPriceType = .none,
                            qty: String,
                            perform_px : String,
                            contractType: EXSwapMarketOrderType,
                            priceType: EXSwapMarketOrderPriceType,
                            planPriceType: EXSwapPlanOrderPriceType,
                            timeForce: Int) -> EXContractOrderModel {
        let order = EXContractOrderModel()
        order.opponentType = opponentType
        order.instrument_id = itemModel!.instrument_id;
        order.leverage = leverage;
        order.index_px = itemModel!.index_px;
        order.position_type = leverage_type;
        order.qty2 = qty
        var price = px
        if contractType == .market {
            price = middleValue()
        }
        
        if isCoin {
            if case .planOrder(_) = contractType, planPriceType == .limitPlan {
                order.qty = EXFormula.coin(toTicket: qty, price: perform_px, contract: itemModel!.ex_contractInfo).toString(0)
            } else {
                order.qty = EXFormula.coin(toTicket: qty, price: price, contract: itemModel!.ex_contractInfo).toString(0)
            }
        } else {
            order.qty = qty.toString(0);
        }
        order.side = side;
        if contractType == .limited { // 普通委托 English: Ordinary entrustment
            order.px = px
            order.category = .normal
        } else if contractType.isHighOrderType() {
            order.px = px
            if timeForce == 1 {
                order.category = .postOnly
            } else if timeForce == 2 {
                order.category = .FOK
            } else if timeForce == 3 {
                order.category = .IOC
            }
        }else if contractType == .market {
            order.px = price
            order.category = .market
        } else if case let .planOrder(isMarket) = contractType { // 计划单 English: Plan sheet
            if isMarket {
                order.category = .planMarket
                order.exec_px = middleValue()
            } else {
                order.category = .plan;
                order.exec_px = perform_px;
            }

            order.px = order.exec_px
            order.triggerPrice = px
            order.orderCycle = EXStoreData.storeObject(forKey: EX_DATE_CYCLE) as? Int ?? 0
        }
        return order
    }
}

