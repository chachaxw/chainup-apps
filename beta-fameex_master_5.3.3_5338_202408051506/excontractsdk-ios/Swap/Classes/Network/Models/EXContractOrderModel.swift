//
//  EXContractOrderModel.swift
//  Chainup
//
//  Created by ZYJ on 2023/11/8.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import EXKit
let EXContractOrderSideBuy = "BUY";
let EXContractOrderSideSell = "SELL";
let EXContractOrderTypeOpen = "OPEN";
let EXContractOrderTypeClose = "CLOSE";

enum BTContractOrderWay:Int {
   case unkown = 0
   case buy_OpenLong            // 买入开多 English: Buy Kaiduo
   case buy_CloseShort           // 买入平空 English: Buy flat
   case sell_CloseLong           // 卖出平多 English: Selling Pingduo
   case sell_OpenShort            // 卖出开空 English: Selling short positions
    
    
    /// tracking Event parameters
    var trackingEventParameters: String {
        switch self {
        case .buy_OpenLong:   return "open_long"
        case .buy_CloseShort: return "close_short"
        case .sell_CloseLong: return "close_long"
        case .sell_OpenShort: return "open_short"
        default: return ""
        }
    }
    
    
    var display:String {
        switch self {
        case .buy_OpenLong:
            return "cp_overview_text13".ex_localized()
        case .buy_CloseShort:
            return "cp_extra_text4".ex_localized()
        case .sell_CloseLong:
            return "cp_extra_text5".ex_localized()
        case .sell_OpenShort:
            return "cp_overview_text14".ex_localized()
        default:
            return ""
        }
    }

    var display1:String {
        switch self {
        case .buy_OpenLong:
            return "cp_overview_text_13".ex_localized() //cp_overview_text_13
        case .buy_CloseShort:
            return "cp_extra_text_4".ex_localized()
        case .sell_CloseLong:
            return "cp_extra_text_5".ex_localized()
        case .sell_OpenShort:
            return "cp_overview_text_14".ex_localized() //cp_overview_text_14
        default:
            return ""
        }
    }
    
    var openDiretion: String {
        switch self {
        case .buy_OpenLong:
            return "cp_order_text6".ex_localized()
        case .sell_OpenShort:
            return "cp_order_text15".ex_localized()
        default:
            return ""
        }
    }
    
    var textColor: UIColor {
        switch self {
        case .buy_OpenLong:
            return UIColor.ThemekLine.up
        case .buy_CloseShort:
            return UIColor.ThemekLine.up
        case .sell_CloseLong:
            return UIColor.ThemekLine.down
        case .sell_OpenShort:
            return UIColor.ThemekLine.down
        default:
            return UIColor.ThemekLine.up
        }
    }
    
    
    func parmDescForOpenWay() -> String! {
       switch (self) {
       case .buy_OpenLong:
           return EXContractOrderTypeOpen;
       case .buy_CloseShort:
           return EXContractOrderTypeClose;
       case .sell_CloseLong:
           return EXContractOrderTypeClose;
       case .sell_OpenShort:
           return EXContractOrderTypeOpen;
       default:
           return "";
       }
   }
    func parmDescForSideWay() -> String {
        
        switch (self) {
        case .buy_OpenLong:
                return EXContractOrderSideBuy;
        case .buy_CloseShort:
                return EXContractOrderSideBuy;
        case .sell_CloseLong:
                return EXContractOrderSideSell;
        case .sell_OpenShort:
                return EXContractOrderSideSell;
            default:
                return "";
        }
    }
}

enum BTContractOrderCategory {

    case unkown
    case normal    // 限价委托 English: limit order
    case market       // 市价委托 English: market order
    case plan       // 计划委托 English: Plan delegation
    case planMarket
    case IOC
    case FOK
    case postOnly
}
@objcMembers class EXContractOtoOrderModel:EXCOBaseModel {

    var takerProfitStatus = false
    var takerProfitTrigger = "--"
    var takerProfitPrice = "--"
    var stopLossStatus = false
    var stopLossTrigger = "--"
    var stopLossPrice = "--"
    
    var takerProfitStatusDesc:String {
        return takerProfitStatus ? "cp_order_text88".ex_localized() : "cp_extra_text72".ex_localized()
    }
    var stopLossStatusDesc:String {
        return stopLossStatus ? "cp_order_text88".ex_localized() : "cp_extra_text72".ex_localized()
    }

    var takerProfitPriceDesc:String {
        if takerProfitPrice == "0"{
            return "cp_overview_text53".ex_localized()
        }
        return takerProfitPrice
    }

    var stopLossPriceDesc:String {
        if stopLossPrice == "0"{
            return "cp_overview_text53".ex_localized()
        }
        return stopLossPrice
    }
    
    var hasNoData:Bool {
        return (takerProfitTrigger == "--") && (stopLossTrigger == "--")
    }
    var dataCount:Int {
        var count = 0
        if takerProfitTrigger == "--" {
            count += 1
        }
        if stopLossTrigger == "--" {
            count += 1
        }
        return count
    }

}
@objcMembers public class EXContractKlineOrder: EXCOBaseModel {
    
}

@objcMembers public class EXContractOrderModel: EXCOBaseModel {
    
    var orderUnit: Int = 0 //number非必须订单单位：0:张，1:价值，2:币 English: Number is not a mandatory order unit: 0: sheet, 1: value, 2: currency

    //new
    var isCheckLiq: Int = 1 // 是否进行爆仓验证（不进行：传0或者不传，进行：传1） English: Do you want to perform stock explosion verification (do not perform: transmit 0 or do not transmit, perform: transmit 1)
    var instrument_id:Int64 = 0
    var leverage = ""     // 杠杆 English: lever
    var contractId: Int64 = 0
    var orderId = ""//订单id 用于取消订单 English: Order ID is used to cancel the order
    var triggerOrderId = "" //条件单id 用于取消订单 English: Condition sheet ID is used to cancel the order
    var triggerType = ""
    var id = ""
    var timeInForce = "" //计划委托用 timeInForce 2 市价平 English: Plan to commission timeInForce 2 at market price
    var openOrderType: EXOpenOrderType = .qty
    var priceType:EXSwapMarketOrderPriceType = .limitPrice
    var forcedPrice = "" //强平价格 English: Qiangping Price
    var takeOverPrice = "" //接管价格 English: Takeover price
    var showStopPL:Bool {
        return true
    }
    var orderDesc:String {
        if triggerType == "1" {
            return "cp_order_text62".ex_localized()
        }
        if triggerType == "2" {
            return "cp_order_text63".ex_localized()
        }
        return "cp_overview_text5".ex_localized()
    }
    var exec_px = "" // 执行价格 English: Execution price
    var takerProfitTrigger = ""
    var stopLossTrigger = ""
    var side:BTContractOrderWay = .unkown
    var orderSide = "";
    var open = "";
    var orderStatus:Int = 0;//订单状态 English: Order status
    var statusDisplay = "";//订单状态 English: Order status
    var orderType = "" //orderType--6.0 以后用 English: OrderType -- used after 6.0
    var type = "" // 特殊类型显示用 English: Special type display
    var realizedAmount = ""
    var liqPositionMsg = ""
    var category:BTContractOrderCategory = .unkown
    var maxFeeRate = "0.00075"
    var im = ""
    var position_type:BTPositionOpenType = .unKnow
    var freezAssets = "0"; // 开仓成本 English: Opening cost
    var index_px = "" // 指数价格 English: Index price
    var memo = 0 //原因 English: reason
    var memoDisplay = ""
    var orderBalance = ""
    var source = "" //订单来源 English: Order source
    var feeValue = ""
    var otoOrder = EXContractOtoOrderModel()
    var closePosition = false //是否来自平仓 English: Whether it comes from closing positions
    var liqPositionMsgTimeStamp = ""
    var shouldHiddenOtoOrderDetailView:Bool {
        return otoOrder.hasNoData

    }
    
    var orderValue:String {
        if let info = ex_contractInfo {
            
            let value = EXFormula.calculateContractValue(withVol: qty, price: px, contract: ex_contractInfo)
            return info.isReverse ? value.bigMul(info.marginRate) : value
        }
        
        return ""
    }
    var ex_contractInfo: EXContractsModel? {
        return EXSwapPublicInfo.shared.getSwapInfo(instrument_id)
    }
    var typeEnum:EXSwapMarketOrderType? {//计算属性，接收数据使用 English: Calculate attributes and receive data using
        
        get {
            /*
             source 订单来源, 历史订单 - 特殊类型,带说明解释弹框 English: Source order source, historical orders - special types, with explanatory pop ups
             其他用 orderType English: Other uses of orderType
             */
           
            if let orderType = EXSwapMarketOrderType.parmDescDic[orderType] {
                return orderType
            }
            
            return newTypeEnum
        }
    }
    
    var newTypeEnum:EXSwapMarketOrderType? {//详情页用 English: For the details page
        
        get {
            /*
             source 订单来源, 历史订单 - 特殊类型,带说明解释弹框 English: Source order source, historical orders - special types, with explanatory pop ups
             其他用 orderType English: Other uses of orderType
             */
           
            if let orderType = EXSwapMarketOrderType.parmDescDic[type] {
                return orderType
            }
            return nil
        }
    }
    
    
    func getSourceType() -> EXSwapMarketOrderType?{
        if source == "6"{
            return  EXSwapMarketOrderType.forceReducePosition //强制减仓 6 English: Mandatory reduction of position 6
        }else if source == "7"{
            return EXSwapMarketOrderType.positionMerge // -仓位合并 7 English: -Position consolidation 7
        }else if source == "9" {
            return EXSwapMarketOrderType.SystemCloseout
        }else if source == "10"{
            return EXSwapMarketOrderType.SystemDelivery
        }else if source == "11"{
            return EXSwapMarketOrderType.ADL
        }
        return nil
    }
    var triggerPrice = "";
    //
    var orderCycle = 0;   // 委托周期,单位小时 English: Commission period, in hours

    var fee = "";
    var feeCoinPrecision = "";
    var mtime = "";
    var expireTime = "";
    var opponentType:EXOpponentPriceType = .none
    var currentPercent = ""
    var contractName = ""
    fileprivate func setupSide() {
        if orderSide == EXContractOrderSideBuy,
           open == EXContractOrderTypeOpen {
            side = .buy_OpenLong
        }
        if orderSide == EXContractOrderSideBuy,
           open == EXContractOrderTypeClose {
            side = .buy_CloseShort
        }
        
        if orderSide == EXContractOrderSideSell,
           open == EXContractOrderTypeOpen {
            side = .sell_OpenShort
        }
        if orderSide == EXContractOrderSideSell,
           open == EXContractOrderTypeClose {
            side = .sell_CloseLong
        }
    }
    
    func modelCustomTransform(from dic: [AnyHashable : Any]) -> Bool {
        setupSide()
        return true
    }
    func isSpecialType() -> Bool {
        if let type = getSourceType(){
            return true
        }
        return false
    }
    //强制减仓 English: Compulsory reduction of positions
    func isLiquidate() -> Bool{
        if let type = getSourceType(){
            if type == .forceReducePosition{
                return true
            }
        }
        return false
    }
    
    func isADl() -> Bool{
        if let type = getSourceType(){
            if type == .ADL{
                return true
            }
        }
        return false
    }
    
    func setupDataWithInstrumentId() {
        if avg_px.isEmpty || avg_px.isZero() {
            avg_px = "0"
        }
        avg_px = avg_px.toPricePrecision(withContractID:instrument_id)
    }
    func showName() -> String {
        return ex_contractInfo?.showName() ?? ""
    }
    var px = "" // 订单价格 English: Order price
    var qty = ""// 订单量 English: Order quantity
    var qty2 = ""//反向合约使用 English: Reverse Contract Usage
    var cum_qty = ""// 成交量 English: turnover
    var created_at = ""
    var name = "" //Contract Name
    var avg_px = ""//Average transaction price
    var oid:Int64 = 0 //Order ID
    var isCompensate = false //新增字段,是否发生补偿,true发生补偿;false没补偿  New field, whether compensation occurs, true compensation occurs; faalse no compensation
    var isAdd = false//新增字段,是否展示+号,true展示;false不展示  whether to display the + sign, true display, false do notdisplay
    var tradeFee = ""

   static func modelCustomPropertyMapper() -> [String : Any]? {
        return [
            "px":"price",
            "qty":"volume",
            "orderSide":"side",
          //  "orderType":"type", //新版本就是orderType English: The new version is orderType
            "orderCycle":"cycle",
            "orderStatus":"status",
            "cum_qty":"dealVolume",
            "created_at":"ctime",
            "name":"symbol",
            "avg_px":"avgPrice",
            "oid":"orderId",
        ]
    }
    var pid:Int64 = 0
     class func newContractCloseOrder(withContractId instrument_id: Int64, category: BTContractOrderCategory, way: BTContractOrderWay, positionID position_id: Int64, price: String!, vol: String!) -> EXContractOrderModel {
    
        let model = EXContractOrderModel()
        
        model.instrument_id = instrument_id
        model.category = category
        model.side = way
        model.pid = position_id
        
        if price.count > 0 {
            model.px = price
        }
        if model.isCoin {
            model.qty = EXFormula.coin(toTicket: vol, price: price, contract: model.ex_contractInfo).exs_decimalString(0)
        }else {
            model.qty = vol
        }
        return model
    }
   
    ///是否开仓 English: /Whether to open a position
     func isOpen() -> Bool {
        return open == EXContractOrderTypeOpen
    }
     func orderWayDisplay() -> String! {
        
        var typeStr = "cp_overview_text13";
        if (self.side == .sell_OpenShort) {
            typeStr = "cp_overview_text14";
        } else if (self.side == .buy_CloseShort) {
            typeStr = "cp_extra_text4";
        } else if (self.side == .sell_CloseLong) {
            typeStr = "cp_extra_text5";
        }
        return typeStr.ex_localized()
    }
    
     func parmDescForOpenWay() -> String! {
        return side.parmDescForOpenWay()
    }
    func parmDescForSideWay() -> String {
        return side.parmDescForSideWay()
    }
    
     func isOnlySubtract() -> Bool {
        return open == EXContractOrderTypeClose
    }
    class func getHistoryBuySellKlineData(orderList: [EXContractOrderModel],timeInterval:String, orginKlinedData:[EXSKLineChartItem]) -> [EXSKLineChartItem]{
        if orderList.count == 0{
            return orginKlinedData
        }
        if orginKlinedData.count == 0{
            return orginKlinedData
        }
//
//        let start = Date().timeIntervalSince1970
//        //print("AA开始---- \(start))") English: Print ("AA start -- \ (start)")
//        //print("时间周期-\(timeInterval)") English: Print ("Time period - \ (timeInterval)")
//        //print("原始订单数据-共\(orderList.count)") English: Print ("Original order data - total \ (orderList. count)")
//        //print("k线-共\(orginKlinedData.count)") English: Print ("klinedData. count")
        
        /*
         k线时间戳  1668646800 English: K-line timestamp 1668646800
         订单时间戳 1668046464000 English: Order timestamp 1668046464000
         订单数据倒序      1.10， 1.9， 1-1 English: Order data in reverse order 1.10, 1.9, 1-1
         k线数据是正序排序 - 1.1，1.2，-1.10 English: The k-line data is sorted in positive order -1.1, 1.2, -1.10
         先缩小K线的范围 订单的时间-- English: Narrow the scope of the K-line first, and the time of the order--
         */
        
        //1. 订单的时间周期-- 先缩小K线的范围 English: 1. Time cycle of the order - narrow down the range of the K-line first
       
        var klineData = [EXSKLineChartItem]()
      
        
        //
        let rangeStart = (Int(orderList.last!.created_at) ?? 0) / 1000 - 3600 * 24
        let rangeEnd   = (Int(orderList.first!.created_at)   ?? 0) / 1000 + 3600 * 24
//        debug//print("KBS =订单的开始日期" + EXSDateTools.strToTimeString(String(rangeStart),dateFormat: "yyyy-MM-dd HH:mm:ss")) English: DebugPrint ("KBS=start date of order"+EXSDateTools. strToTimeString (String (rangeStart), dataFormat: "yyyy MM dd HH: mm: ss"))
//        debug//print("KBS =订单的结束日期" + EXSDateTools.strToTimeString(String(rangeEnd),dateFormat: "yyyy-MM-dd HH:mm:ss")) English: DebugPrint ("KBS=end date of order"+EXSDateTools. strToTimeString (String (rangeEnd), dataFormat: "yyyy MM dd HH: mm: ss"))
//        debug//print("KBS =缩小开始") English: DebugPrint ("KBS=shrink start")
        
        let newklineData = orginKlinedData
        for datum in newklineData {
            if datum.time >= rangeStart, datum.time < rangeEnd{
                klineData.append(datum)
            }
        }
//        debug//print("KBS =k线-all-开始日期" + EXSDateTools.strToTimeString(String(newklineData.first!.time),dateFormat: "yyyy-MM-dd HH:mm:ss")) English: DebugPrint (KBS=kline all start date+EXSDateTools. strToTimeString (String (newklineData. first!. time), dataFormat: "yyyy MM dd HH: mm: ss"))
//        debug//print("KBS =k线-all-开始结束" + EXSDateTools.strToTimeString(String(newklineData.last!.time),dateFormat: "yyyy-MM-dd HH:mm:ss")) English: DebugPrint ("KBS=kline all start end"+EXSDateTools. strToTimeString (String (newklineData. last!. time), dataFormat: "yyyy MM dd HH: mm: ss"))
//        debug//print("KBS =k线-缩小范围-开始日期" + EXSDateTools.strToTimeString(String(klineData.first!.time),dateFormat: "yyyy-MM-dd HH:mm:ss")) English: DebugPrint ("KBS=kline - shrink range - start date"+EXSDateTools. strToTimeString (String (klineData. first!. time), dataFormat: "yyyy MM dd HH: mm: ss"))
//        debug//print("KBS =k线-缩小范围-开始结束" + EXSDateTools.strToTimeString(String(klineData.last!.time),dateFormat: "yyyy-MM-dd HH:mm:ss")) English: DebugPrint ("KBS=kline - shrink range - start and end"+EXSDateTools. strToTimeString (String (klineData. last!. time), dataFormat: "yyyy MM dd HH: mm: ss"))
//        debug//print("KBS =缩小结束") English: DebugPrint ("KBS=Zoom Out End")
        if klineData.count == 0{
            return orginKlinedData
        }
        
        
        for datum in klineData {
            for order in orderList {
                let orderTimeStamp = (Int(order.created_at) ?? 0) / 1000
                let startTimeStamp  = datum.time
                //order.created_at.bigDiv("1000")
                guard self.getKLineEndStimap(orderTimeStamp: orderTimeStamp, startTimeStamp: startTimeStamp, timeInterval: timeInterval) else {
                    continue
                }
                
                // 开多或平空委托：显示为绿色标记，位于 K 线下方 English: Open or flat commission: displayed as a green mark, located below the K-line
                //开空或平多委托：显示为红色标记，位于 K 线上方 English: Open or flat commission: displayed as a red marker above the K-line
                // if datum.buySellPointShow == true{
                //    continue //已经标记过，就不用重复了 English: It has already been marked, so there is no need to repeat it
                // }
                datum.buySellPointShow = true
                if order.side == .buy_OpenLong || order.side == .sell_OpenShort {
                    datum.buySellKlineShowBottom = true
                }else{
                    datum.buySellKlineShowTop = true
                }
            }
        }
        
        //MARK: 调试打印 English: MARK: Debugging Printing
//        debug//print("KBS =最终k线数据--") English: DebugPrint ("KBS=Final k-line data --")
//        var i = 0
//        for it in klineData{
//            if it.buySellPointShow{
//                print(EXSDateTools.strToTimeString(String(it.time),dateFormat: "yyyy-MM-dd HH:mm:ss"))
//                i+=1
//            }
//        }
//
//        debug//print("KBS =订单最终k线数据--共\(i)条") English: DebugPrint ("KBS=Final k-line data of order - a total of \ (i)")
//        let end = Date().timeIntervalSince1970
//        //print("AA开结束---- \(end)") English: Print ("AA Open End - -- \ (end)")
//        let t = end - start
//        //print("AA开耗时---- \(t)-秒") English: Print ("AA startup time --- \ (t) - seconds")
        return orginKlinedData
    }
    
    static let timeIntervalMap:[String:Int] = [
        "1min":60,
        "5min":300,
        "15min":900,
        "30min":1800,
        "60min":3600,
        "1h":3600,
        "4h":3600 * 4,
        "1day":3600 * 24,
        "1week":3600 * 24 * 7
    ]
    
    /**
     orderTimeStamp 订单时间戳 English: OrderTimeStamp Order TimeStamp
     startTimeStamp k线时间戳 English: StartTimeStamp k-line timestamp
     timeInterval   k线订阅周期 English: TimeInterval k-line subscription cycle
     
     返回  订单是否在当前k线上 English: Return whether the order is on the current candlestick
     */

    class func getKLineEndStimap(orderTimeStamp:Int,startTimeStamp:Int,timeInterval:String) -> Bool{
        //计算出k线的截止时间 English: Calculate the deadline for the candlestick line
        var endTimeStap: Int = 0
        if timeInterval == "1month" { //月 English: month
            let nextM = EXSDateTools.getNextMonth(timeStamp: String(startTimeStamp))
            endTimeStap = EXSDateTools.getNowTimeInterval(date: nextM)
        }else{ //其他周期的 English: Other cycles
            guard let seconds = timeIntervalMap[timeInterval] else { return false }
            endTimeStap = startTimeStamp + seconds
        }
        //调试打印注释 English: Debugging printing comments
//        let startT = EXSDateTools.strToTimeString(String(startTimeStamp),dateFormat: "yyyy-MM-dd HH:mm:ss")
//        let endT = EXSDateTools.strToTimeString(String(endTimeStap),dateFormat: "yyyy-MM-dd HH:mm:ss")
//        //print("===========")
//        let orderT = EXSDateTools.strToTimeString(String(orderTimeStamp),dateFormat: "yyyy-MM-dd HH:mm:ss")
//            debug//print("KBS =startT = \(startT)")
//            debug//print("KBS =k线时间startT =\(startT) == 周期\(timeInterval) == endT =\(endT)") English: DebugPrint ("KBS=k-line time startT=\ (startT)==cycle \ (timeInterval)==endT=\ (endT)")
//            debug//print("KBS =订单orderT =\(orderT)") English: DebugPrint ("KBS=order orderT=\ (orderT)")
        if orderTimeStamp >= startTimeStamp, orderTimeStamp <= endTimeStap{
//            debug//print("KBS =包含)") English: DebugPrint ("KBS=included")
            return true
        }else{
//            debug//print("KBS =不包含)") English: DebugPrint ("KBS=not included")
        }
        return false
    }
    
    func getNewliqPositionMsg() -> String{
        
        let timeStamp = liqPositionMsgTimeStamp
        var times = (TimeInterval(timeStamp) ?? 0)
        //返回的 13位 1673622807000 English: Returned 13 bits 1673622807000
        if timeStamp.count == 13 {
            times = times / 1000
        }
        let newtime = EXSDateTools.timeStampToString(times)
        liqPositionMsg = EXStingTool.replaceDateWithTimeStamp(targetString: liqPositionMsg, repalceStr: newtime)
        var content = liqPositionMsg.replacingOccurrences(of: "@", with: "")
        content = content.replacingOccurrences(of: "\\n", with: "\n")
        content = content.replacingOccurrences(of: "\n", with: "\n")
        content = content.replacingOccurrences(of: "<br />", with: "\n")
        content = content.replacingOccurrences(of: "<br/>", with: "\n")
        return content
    }
    
    
}



