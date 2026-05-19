//
//  EXSwpPositionModel.swift
//  Chainup
//
//  Created by ZYJ on 2023/11/8.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import RxSwift
import EXKit

enum BTPositionOpenType:Int {
    case  unKnow = 0
    case allType         // 全仓 English: Full warehouse
    case pursueType   // 逐仓 English: Warehouse by warehouse
    case bothType         // 都支持 English: All support
    var introduce:String {
        switch self {
        case .allType:
            return "cp_contract_setting_text1".ex_localized()
        case .pursueType:
            return "cp_contract_setting_text2".ex_localized()
        default:
            return ""
        }
    }
}

public enum BTPositionType:Int {
    case  unKnow = 0
    case openMore    // 开多 English: Kaiduo
    case openEmpty       // 开空 English: Open air
    
    var introduce:String {
        switch self {
        case .openMore:
            return "cp_order_text6".ex_localized()
        case .openEmpty:
            return "cp_order_text15".ex_localized()
        default:
            return ""
        }
    }
}

@objcMembers public class EXSwapPositionModel: EXCOBaseModel {
    var userPreferencesPrice = "" // 用户选中是标记和指数价格 English: User selected tags and index prices
    var openEndPrice = "" //开仓均价 (盈亏历史中使用) English: Average opening price (used in profit and loss history)
    public var instrument_id:Int64 = 0
    var cur_qty = "" // 当前持有量 English: Current holdings
    public var avg_open_px = "" // 开仓均价 English: Average opening price
    var closePrice = "" //平仓均价 English: Closing average price
    var im = ""               // 开仓保证金 English: Opening margin
    var pid:Int64 = 0      // 仓位ID English: Bin ID
    var canCloseVolume = ""
    public var index_px = "";       // 标记价格 English: Mark price
    var reducePrice = "";      // 强平价 English: Strong parity
    var marginRate = "";      //保证金率 English: Margin ratio
    var openRealizedAmount = "";   //盈亏 English: Profit and loss
    var unRealizedAmount = "";//未实现盈亏,后台给 English: Unrealized profits and losses, provided by the backend
    var realizedAmount = "";//已实现盈亏，后台给 English: Realized profits and losses, provided by the backend
    var profitRealizedAmount = ""//结算盈亏 English: Settlement profit and loss
    var historyRealizedAmount = ""//历史已实现盈亏 English: Historical realized profits and losses
    var keepRate = "";//维持保证金率 English: Maintain margin ratio
    var maxFeeRate = "";//平仓最大手续费率 English: Maximum handling fee for closing positions
    public var returnRate = "";        // 回报率 English: Return rate
    var orderSide = "";
    var openAmount = ""; //保证金后台 English: Margin backend
    var volume = "";//history的数量 English: Number of histories
    var adlLevel = 0 //adl档位 English: ADL gear
    
    var leverageLevel = "";
    var canUseAmount = "";//可用 English: available
    var canSubMarginAmount = "";//可减少保证金 English: Can reduce margin
    var positionType = "";//持仓类型 English: Position type
    var position_type:BTPositionOpenType = .unKnow
    public var side:BTPositionType = .unKnow
    var sideColor:UIColor {
        if side == .openMore {
            return UIColor.ThemekLine.up
        }else {
            return UIColor.ThemekLine.down
        }
    }
    var positionBalance = ""
    var positionvalue : String {
        if let info = ex_contractInfo {
            
            let value = EXFormula.calculateContractValue(withVol: cur_qty , price: avg_open_px, contract: ex_contractInfo)
            return info.isReverse ? value.bigMul(info.marginRate) : value
        }
        
        return ""
    }
    //1.01
    var settleProfit = ""//持仓结算 English: Position settlement
    var tradeFee = ""//交易手续费 English: Transaction fees
    var capitalFee = ""//资金费用 English: Capital expenses
    var closeProfit = "" // 平仓盈亏 English: Closing profit and loss
    var shareAmount = "" //分摊金额 English: Allocation amount
    var mtime = ""//平仓时间(毫秒时间戳) English: Closing time (millisecond timestamp)
    var contractName = ""
    //盈亏记录专用 English: Profit and loss record only
    var contractOtherName = ""
    var marginCoin = ""//保证金币种 English: Guarantee coin type
    var pricePrecision = "" //价格精度 English: Price accuracy
    var marginCoinPrecision = ""//已实现盈亏 English: Realized profit and loss
    var multiplier = ""//合约面值 English: Contract face value
//    var quote_coin = ""//
    var quote = ""
    var priceModel = EXPricelistModel() //最新价 English: Latest price
    private var _exContractInfo:EXContractsModel?
    public  var ex_contractInfo: EXContractsModel? {
        set {
            _exContractInfo = newValue
        }
        get {
            if _exContractInfo == nil {
                
                return EXSwapPublicInfo.shared.getSwapInfo(instrument_id)
            }else {
                return _exContractInfo
            }
        }
    }
    static func modelCustomPropertyMapper() -> [String : Any]? {
        return [
            "cur_qty":"positionVolume",
            "avg_open_px":"openAvgPrice",
            "instrument_id":"contractId",
            "im":"holdAmount",
            "pid":"id","index_px":"indexPrice"
        ]
    }
    //最新价 English: Latest price
    func indexPxDisplay() -> String {
        if let priceM = self.priceModel.priceModel {
            return priceM.lastPrice.toPricePrecision(withContractID: ex_contractInfo?.instrument_id ?? 0)
        }
       return ""
    }
    
    fileprivate func mapPositionType() {
        if positionType == "1" {
            position_type = .allType
        }
        if positionType == "2" {
            position_type = .pursueType
        }
    }
    
    fileprivate func mapSide() {
        if orderSide == "BUY" {
            side = .openMore
        }
        if orderSide == "SELL" {
            side = .openEmpty
        }
    }
    
    func modelCustomTransform(from dic: [AnyHashable : Any]) -> Bool {
        if !self.volume.isEmpty {
            cur_qty = self.volume
        }
        
        mapSide()
        mapPositionType()
      
        if reducePrice.lessThanOrEqual("0") {
            reducePrice = "--"
        }
        return true
    }
    
     func calculateReducePrice() -> String {
        
         if let info = ex_contractInfo {
             let value = EXFormula.adjustCalculatePositionLiquidatePrice(self, contractInfo: info)
             if value.lessThanOrEqual(BTZERO) {
                 return "--"
             }
             return value
         }
        return ""
    }
    
    func calculateLeverage() -> String {
    
        if self.ex_contractInfo != nil {
            
            return EXFormula.calculatePositionLeverage(withPosition: self, contract: self.ex_contractInfo!)
        }else {
            return ""
        }
    }

    
}

extension EXSwapPositionModel {

    ///每s 更新一下, 本地计算后获取新的刷新cell  本次只更新盈亏额和回报率2项 English: /Update every s, obtain new refresh cells after local calculation. This time, only update the profit and loss amount and return rate
    func localCalculate(pricelist: [EXPricelistModel]) -> EXSwapPositionModel{
         //用户的选择 English: User's Choice
        let isNewPrice = EXStoreData.storeBool(forKey: EXS_IS_NEWPRICE)
        var tagPrice = ""
        let selfName = self.contractName //用合于名字匹配 English: Match with Name
        for itemModel in pricelist{
            if let pm = itemModel.priceModel{
                tagPrice = isNewPrice ? pm.lastPrice : pm.tagPrice
                if tagPrice.lessThanOrEqual("0") || tagPrice.isEmpty {
                   continue
                }
                if itemModel.icon == selfName{
                    self.index_px = pm.tagPrice
//                    EXSwapLogManger.shareInstance.writeLog(content: "refresh PositionModel \(pm.tagPrice)" + "\n")
                    self.priceModel = itemModel
                    break
                }
            }
        }
        if tagPrice.lessThanOrEqual("0") || tagPrice.isEmpty {
           return self
        }
        if ex_contractInfo == nil {
            return self
        }
        self.userPreferencesPrice = tagPrice
        var openRealizedAmount = ""  //盈亏 English: Profit and loss
        var returnRate = ""       // 回报率 English: Return rate
       
        let face_value = ex_contractInfo!.face_value
        let marginRate = ex_contractInfo!.marginRate
        let avg_open_px = self.avg_open_px
        let volume = self.cur_qty
        //币本位 English: Currency standard
        if ex_contractInfo!.contractSide == "0" {
            
            if self.side == .openMore { //开多 English: Kaiduo
                openRealizedAmount = volume.bigMul(face_value).bigDiv(avg_open_px).bigSub( volume.bigMul(face_value).bigDiv(tagPrice))
            }else{ //开空 English: Open air
                openRealizedAmount = volume.bigMul(face_value).bigDiv(tagPrice).bigSub( volume.bigMul(face_value).bigDiv(avg_open_px))
            }
        }else{//正向合约 English: Forward contract
            if self.side == .openMore { //开多 English: Kaiduo
                openRealizedAmount =  tagPrice.bigSub(avg_open_px).bigMul(volume).bigMul(face_value).bigMul(marginRate)
            }else{ //开空 English: Open air
                openRealizedAmount =  avg_open_px.bigSub(tagPrice).bigMul(volume).bigMul(face_value).bigMul(marginRate)
            }
        }
        returnRate = openRealizedAmount.bigDiv(self.openAmount)
        self.openRealizedAmount =  openRealizedAmount
        self.returnRate = returnRate
//        var openRealizedAmount = ""  //盈亏 English: Profit and loss
//        var index_px = ""     // 标记价格 English: Mark price
//        var im = ""               // 开仓保证金 English: Opening margin
//        var marginRate = ""      //保证金率 English: Margin ratio
//        var reducePrice = ""     // 强平价 English: Strong parity
//        var profitRealizedAmount = ""//已结算盈亏 English: Settled profit and loss
//        var returnRate = ""       // 回报率 English: Return rate
        
        return self
    }
    
    
    /*
     6.0 调整 English: 6.0 Adjustments

     平仓和闪电平仓时，增加「预估盈亏」字段， English: When closing positions and lightning closing positions, add an "estimated profit and loss" field,
     预估盈亏计算： English: Estimated profit and loss calculation:
     市价 &对方最优& 闪电平仓  ： English: Market Price&Opponent's Best&Flash Closing:
     正向合约 多仓： 预估盈亏 = （买1 -开仓均价）*数量*面值*汇率 English: Positive contract long position: Estimated profit and loss=(buy 1- average opening price) * quantity * face value * exchange rate
     正向合约 空仓： 预估盈亏 = （开仓均价 - 卖1）*数量*面值*汇率 English: Positive contract short position: Estimated profit and loss=(average opening price - selling 1) * quantity * face value * exchange rate
     币本位合约 多仓：预估盈亏 = 数量 *面值/开仓均价 - 数量 *面值/买1 English: Currency based contracts with multiple positions: estimated profit and loss=quantity * face value/average opening price - quantity * face value/buy 1
     币本位合约 空仓：预估盈亏 =  数量 *面值/卖1 - 数量 *面值/开仓均价 English: Short positions in currency based contracts: estimated profit and loss=quantity * face value/sell 1- quantity * face value/average opening price
 
     本方最优： English: Our best:
     正向合约 多仓： 预估盈亏 = （卖1 -开仓均价）*数量*面值*汇率 English: Positive contract long position: Estimated profit and loss=(selling 1- average opening price) * quantity * face value * exchange rate
     正向合约 空仓： 预估盈亏 = （开仓均价 - 买1）*数量*面值*汇率 English: Positive contract short position: Estimated profit and loss=(average opening price - buy 1) * quantity * face value * exchange rate
     币本位合约 多仓：预估盈亏 = 数量 *面值/开仓均价 - 数量 *面值/卖1 English: Currency based contracts with multiple positions: estimated profit and loss=quantity * face value/average opening price - quantity * face value/sell 1
     币本位合约 空仓：预估盈亏 = 数量 *面值/买1 - 数量 *面值/开仓均价 English: Short positions in currency based contracts: estimated profit and loss=quantity * face value/buy 1- quantity * face value/average opening price

     限价： English: Price limit:
     正向合约 多仓： 预估盈亏 = （设置的价格 -开仓均价）*数量*面值*汇率 English: Positive contract multi position: Estimated profit and loss=(set price - average opening price) * quantity * face value * exchange rate
     正向合约 空仓： 预估盈亏 = （开仓均价 - 设置的价格）*数量*面值*汇率 English: Positive contract short position: Estimated profit and loss=(average opening price - set price) * quantity * face value * exchange rate
     币本位合约 多仓：预估盈亏 = 数量 *面值/开仓均价 - 数量 *面值/设置的价格 English: Currency based contracts with multiple positions: estimated profit and loss=quantity * face value/average opening price - quantity * face value/set price
     币本位合约 空仓：预估盈亏 = 数量 *面值/设置的价格 - 数量 *面值/开仓均价 English: Currency based contract short positions: Estimated profit and loss=quantity * face value/set price - quantity * face value/average opening price
     */
    ///平仓计算预估盈亏 - 数量 English: /Closing calculation estimated profit and loss - quantity
    func calculateEstimatedProfitAndLoss(priceType:EXSwapMarketOrderPriceType,colseVolum:String? = nil,limitPrice: String? = nil) -> String?{
        guard self.priceModel.priceModel != nil else{
            return nil
        }
        let pm = self.priceModel.priceModel!
        var setPrice = "0"
        var volume = "0"
        let face_value = ex_contractInfo!.face_value
        let marginRate = ex_contractInfo!.marginRate
        let avg_open_px = self.avg_open_px
        if priceType == .limitPrice{ //限价  数量需要x 单位 English: Limited price quantity requires x units
            setPrice = limitPrice ?? "0"
        }else if priceType == .marketPrice || priceType == .oppositeSideOptimal {  //市价 &对方最优 English: Market price&optimal counterpart
            //币本位 正向合约 无关 English: Currency based forward contract unrelated
            //只跟多空有关系 English: It's only related to Duokong
            if self.side == .openMore { //开多 English: Kaiduo
                setPrice = pm.buyOne
//                //print("买一价=\(setPrice)") English: Print ("buy one price=\ (setPrice)")
            }else{ //空 English: empty
                setPrice = pm.sellOne
//                //print("卖一价=\(setPrice)") English: Print ("selling for one price=\ (setPrice)")
            }
        }else if priceType == .sameSideOptimal{ //本方最优 English: Our best
            //币本位 正向合约 无关 English: Currency based forward contract unrelated
            //只跟多空有关系 English: It's only related to Duokong
            if self.side == .openMore { //开多 English: Kaiduo
                setPrice = pm.sellOne
//                //print("卖一价=\(setPrice)") English: Print ("selling for one price=\ (setPrice)")
            }else{ //空 English: empty
                setPrice = pm.buyOne
//                //print("买一价=\(setPrice)") English: Print ("buy one price=\ (setPrice)")
            }
            if setPrice == "0" { //不为空再计算 -防止价格 计算价格和0来回跳动 English: Do not leave empty before calculating - prevent price calculation from bouncing back and forth with 0
                return nil
            }
        }
        if let v = colseVolum {
            volume = ex_contractInfo?.orignVolum(vol: v) ?? "0"
        }
        if setPrice == "" || setPrice == "0"{ //限价可以为0 不为空再计算 -防止价格 计算价格和0来回跳动 English: The price limit can be calculated without leaving it empty - to prevent price calculation from fluctuating back and forth with 0
            return nil
        }
        if ex_contractInfo == nil {
            return nil
        }
        
        var result = ""
        //币本位 English: Currency standard
        if ex_contractInfo!.contractSide == "0" {
            if self.side == .openMore { //开多 English: Kaiduo
//                //print("币本位开多") English: Print ("Currency based open long")
                //币本位合约 多仓：预估盈亏 = 数量 *面值/开仓均价 - 数量 *面值/设置的价格 English: Currency based contracts with multiple positions: estimated profit and loss=quantity * face value/average opening price - quantity * face value/set price
                result = (volume.bigMul(face_value).bigDiv(avg_open_px)).bigSub(volume.bigMul(face_value).bigDiv(setPrice))
            }else{
//                //print("币本位开空") English: Print ("Currency based open space")
                //币本位合约 空仓：预估盈亏 = 数量 *面值/设置的价格 - 数量 *面值/开仓均价 English: Currency based contract short positions: Estimated profit and loss=quantity * face value/set price - quantity * face value/average opening price
                result = (volume.bigMul(face_value).bigDiv(setPrice)).bigSub(volume.bigMul(face_value).bigDiv(avg_open_px))
            }
        }else{//正向合约 English: Forward contract
            //正向合约 多仓： 预估盈亏 = （设置的价格 -开仓均价）*数量*面值*汇率 English: Positive contract multi position: Estimated profit and loss=(set price - average opening price) * quantity * face value * exchange rate
            if self.side == .openMore { //开多 English: Kaiduo
//                //print("正向开多") English: Print ("forward opening multiple")
                result =  (setPrice.bigSub(avg_open_px)).bigMul(volume).bigMul(face_value).bigMul(marginRate)
            }else{ //开空 English: Open air
//                //print("正向开空") English: Print ("positive open space")
                //正向合约 空仓： 预估盈亏 = （开仓均价 - 设置的价格）*数量*面值*汇率 English: Positive contract short position: Estimated profit and loss=(average opening price - set price) * quantity * face value * exchange rate
                result = (avg_open_px.bigSub(setPrice)).bigMul(volume).bigMul(face_value).bigMul(marginRate)
            }
        }
        
//        let data = [
//            "设置的价格": setPrice, English: "Set price": setPrice,
//            "开仓均价" : avg_open_px, English: Average opening price: avg_ Open_ Px,
//            "数量" : volume, English: "Quantity": volume,
//            "面值" : face_value, English: Face value_ Value,
//            "汇率": marginRate English: MarginRate
//        ]
//        //print("data = \(data)")
//        //print("result  = \(result)")
        result = result.toValuePrecision(withContract: self.instrument_id)
        //MARK:  result  = -0.000000000317
        // 处理小数位后result = 0.0000 English: After processing decimal places, result=0.0000
//        //print("处理小数位后result = \(result)") English: Print ("result after processing decimal places=\ (result)")
        return result
    }
}

/*
 1、盈亏额： English: 1. Profit and loss amount:
 正向合约 多仓：盈亏额=（当前标记价格-开仓均价）*数量*面值*汇率 English: Positive contract multi position: Profit and loss amount=(current marked price - average opening price) * quantity * face value * exchange rate
 正向合约 空仓：盈亏额=（开仓均价-当前标记价格）*数量*面值*汇率 English: Positive contract short position: Profit and loss amount=(average opening price - current marked price) * quantity * face value * exchange rate
 币本位合约 多仓：盈亏额=数量*面值/开仓均价-数量*面值/当前标记价格 English: Currency based contracts with multiple positions: profit and loss=quantity * face value/average opening price - quantity * face value/current marked price
 币本位合约 空仓：盈亏额二数量*面值/当前标记价格 -数量*面值/开仓均价 English: Currency based contract short positions: profit and loss amount 2, quantity * face value/current marked price - quantity * face value/average opening price
 2、回报率： English: 2. Return rate:
 
 回报率 = 盈亏额/openAmount保证金 English: Return rate=profit and loss amount/openAmount margin
 盈亏率计算调整：旵示了这个仓位的投资回报率 (ROI) English: Profit and loss ratio calculation adjustment: 旵 shows the return on investment (ROI) of this position
 盈亏率=（盈亏额/ 保证金）*100% English: Profit and loss ratio=(profit and loss amount/margin) * 100%
 逐仓保证金： English: Margin for each warehouse:
 保证金=起始保证金 English: Margin=Starting Margin
 逐仓持仓记录增加记录「起始保证金」宇段，盈亏率使用该字段计算； English: Add a record of "starting margin" to the position by position record, and use this field to calculate the profit and loss ratio;
 起始保证金的资金变化： English: Changes in initial margin funds:
 1） 加仓 English: 1) Add warehouse
 起始保证金 =原起始保证金+开仓保证金 English: Starting margin=original starting margin+opening margin
 开仓保证金 =开仓价值/杠杆 English: Opening margin=opening value/leverage
 2）增加保证金 English: 2) Increase margin
 起始保证金 =原起始保证金 ＋增加的保证金 English: Starting margin=original starting margin+increased margin
 3） 減少保证金 English: 3) Reduce margin
 起始保证金 =min（原起始保证金，仓位保证金 一 减少值） English: Starting margin=min (original starting margin, reduced value of position margin)
 全仓保证金： English: Full warehouse margin:
 保证金=开仓价值/仓位杠杆 English: Margin=opening value/position leverage
 正向：开合价值二开合均价*持合数量*合约面信*汇率 English: Positive: Opening and closing value, average opening and closing price, holding quantity, contract face letter, exchange rate
 反向：开仓价值=持仓数量*合约面值/开仓均价 English: Reverse: opening value=number of positions * contract face value/average opening price
 
 */



