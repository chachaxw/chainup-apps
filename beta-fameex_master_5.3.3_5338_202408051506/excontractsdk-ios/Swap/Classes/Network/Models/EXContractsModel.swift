//
//  EXContractsModel.swift
//  Chainup
//
//  Created by ZYJ on 2023/11/7.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import EXKit


public enum BTContract_Block_Type:Int {
   case CONTRACT_BLOCK_UNKOWN = 0
   case CONTRACT_BLOCK_USDT = 1        // USDT区域 English: USDT region
   case CONTRACT_BLOCK_INVERSE = 2
   case CONTRACT_BLOCK_STAND = 3      // 币本位 English: Currency standard
   case CONTRACT_BLOCK_SIMULATION  // 模拟大赛 English: Simulation Contest
   case CONTRACT_BLOCK_ALL // 全部 English: whole
    
    public var introduce:String {
        switch self {
        case .CONTRACT_BLOCK_USDT:
            return "cp_contract_data_text13".ex_localized()
        case .CONTRACT_BLOCK_INVERSE:
            return "cp_contract_data_text12".ex_localized()
        case .CONTRACT_BLOCK_STAND:
            return "cp_contract_data_text10".ex_localized()
        case .CONTRACT_BLOCK_SIMULATION:
            return "cp_contract_data_text11".ex_localized()
        case .CONTRACT_BLOCK_ALL:
            return "OpenOrder_text1".ex_localized()
        default:
            return ""
        }
    }
}
public enum EXContractArea {
    case unknow
    case USDT
    case inverse
    case stand
    case simulation
    
    public var introduce:String {
        switch self {
        case .USDT:
            return "cp_contract_data_text13".ex_localized()
        case .inverse:
            return "cp_contract_data_text12".ex_localized()
        case .stand:
            return "cp_contract_data_text10".ex_localized()
        case .simulation:
            return "cp_contract_data_text11".ex_localized()
        default:
            return ""
        }
    }
    
    public static func generateBy(blockType:BTContract_Block_Type) -> EXContractArea {
        switch blockType {
        case .CONTRACT_BLOCK_UNKOWN:
            return .unknow
        case .CONTRACT_BLOCK_USDT :
            return .USDT
        case .CONTRACT_BLOCK_INVERSE:
            return .inverse
        case .CONTRACT_BLOCK_STAND:
            return .stand
        case .CONTRACT_BLOCK_SIMULATION:
            return .simulation
        default:
            return .unknow
        }
    }
}

 @objcMembers open class EXContractsModel: EXCOBaseModel {

    open var instrument_id:Int64 = 0        // 合约ID English: Contract ID
    open var symbol = ""               // 合约名称 English: Contract Name
    open var area:BTContract_Block_Type = .CONTRACT_BLOCK_UNKOWN
    var contractName = "" //名称 English: name
    var margin_coin = ""
    var is_reverse = false              // 是否是反向合约 English: Is it a reverse contract
    var face_value = ""           // 合约大小 English: Contract size
    var px_unit = ""             // 价格精度 English: Price accuracy
    var qty_unit = "";             // 数量精度 English: Quantity accuracy
    var value_unit = "";           // 保证金精度 English: Margin accuracy
    var marginCoin = ""           //保证金币种（注意：别名） English: Guaranteed Gold Coin Type (Note: alias)
    var originalCoin = ""         //保证金真实币种 English: Real currency of margin
    var maxLever = ""
    var minLever = ""
    var leverAndMaxCoinDic = [String:String]()
    var leverAndMaxValueDic = [String:String]()

    var ladderList = [EXContractLadderItem]()
    var base = ""
    var base_coin = ""// 基础币 English: Base currency
    var quote_coin = "";           // 计价币 English: Valuation currency
    var contractType = ""
    open var contractShowType = ""
    var capitalFrequency = ""
    var capitalStartTime = ""
    var settlementFrequency = ""
    var marginRate = ""
    var deliveryKind = ""
    var coinResultVo:EXCoinResultVoModel = EXCoinResultVoModel()
    var subSymbol = "" //真实类型_币对 English: Real type_ Coin pairs
    var contractSide = ""
    var minOrderMoney_unit = "" //市价下单最小精度 English: Minimum precision for placing orders at market price
    var nextCapitalSettTime: Double = 0 //下次时间 English: Next time
    open var sort = 0
    var deliveryKindIntroduce:String {
        get {
            return EXSwapDeliveryKind.init(rawValue: deliveryKind)?.introduce ?? ""
        }
    }
    var pointTimeArr = [Date]()
    
     func modelCustomTransform(from dic: [AnyHashable : Any]) -> Bool {
        margin_coin = marginCoin
        area = areaDesc
        is_reverse = isReverse
        px_unit = "1".mapPrecision(coinResultVo.symbolPricePrecision)
        value_unit = "1".mapPrecision(coinResultVo.marginCoinPrecision);
        qty_unit = face_value
        minOrderMoney_unit = coinResultVo.minOrderMoney
        return true
    }
     
     //获取合约列表 English: Get Contract List
     class func getSwapRecommandList() -> [RecommendItem]{
         var items = [RecommendItem]()
         if var swaps = EXSwapPublicInfo.shared.getAllSwapInfo(){
             swaps = swaps.sorted(by: { a, b in
                 return a.sort < b.sort
             })
             if swaps.count > 6 {
                 swaps = [EXContractsModel](swaps.prefix(6))
             }
             items = swaps.map { model -> RecommendItem in
                 let item = RecommendItem()
                 item.index = String(model.instrument_id)
                 item.attrtitle  = model.nameAttrStr()
                 item.subtitle = model.symbol
                 item.sigle = true
                 item.isSelected = true
                 return item
             }
         }
         return items
     }

    //转换 English: conversion
    func transToSwapModel() -> EXSwapItemModel{
        let itemModel = EXSwapItemModel()
        itemModel.instrument_id = self.instrument_id
        itemModel.symbol = self.symbol
        return itemModel
    }
     static func modelCustomPropertyMapper() -> [String : Any]? {
         return ["instrument_id":"id",
                 "base_coin":"multiplierCoin",
                 "quote_coin":"quote",
                 "face_value":"multiplier"]
    }
    //MARK: 单位修改 English: MARK: Unit modification
    var openValueUnit: String {
        return marginCoin
//        if isReverse {
//            return base
//        }
//        return quote_coin
    }
    var isReverse:Bool {
        return contractSide == "0"
    }
    func qtyPrecision() -> Int {
        if !face_value.contains(".") {
            return 0
        }
        return face_value.count - 2
    }
    
     open func wsSymbol() -> String {
        return self.subSymbol
//        //类型 + （名字 （名字中去掉"-"）） 小写 English: Type+(name (remove "-" from name) lowercase
//        let type = contractType.lowercased()
//        let symbolNew = symbol.replacingOccurrences(of: "-", with: "")
//        return type + "_" + symbolNew.lowercased()
    }
     class func getSubSymbolFromChannel(channel:String) -> String?{
          //market_e_btcusdt_ticker
          if channel.isEmpty {
              return nil
          }
          var result = channel.replacingOccurrences(of: "market_", with: "")
          result = result.replacingOccurrences(of: "_ticker", with: "")
          return result
      }
    var contractOtherName = ""

     open func showName() -> String {
        if !contractOtherName.isEmpty {
            return contractOtherName
        }
        if area == .CONTRACT_BLOCK_INVERSE ||
            area == .CONTRACT_BLOCK_SIMULATION{
            return symbol + "-" + margin_coin
        }

        return symbol
    }
    
    open func nameAttrStr() -> NSAttributedString{
        let name = showName()
        return String.getSwapCoinMapAttr(name,leftFont:UIFont().themeHNBoldFont(size: 16))
    }
    
    var classification = ""
    //新增classification字段（1,USDT合约 2,币本位合约 3,混合合约 4,模拟合约） English: New classification field (1, USDT contract 2, currency standard contract 3, mixed contract 4, simulated contract)
     var areaDesc: BTContract_Block_Type {
        get {
            if classification == "1"{
                return .CONTRACT_BLOCK_USDT
            }
            if classification == "2" {
                return .CONTRACT_BLOCK_STAND
            }
            if classification == "3" {
                return .CONTRACT_BLOCK_INVERSE
            }
            if classification == "4" {
                return .CONTRACT_BLOCK_SIMULATION
            }
            return .CONTRACT_BLOCK_UNKOWN
        }
    }
    
//    func getPointTimeArr() -> [Date] {
//
//        var retArr = [Date]()
//        if let interval = Int(capitalFrequency) ,!capitalStartTime.isEmpty {
//
//            let intervalDate:TimeInterval = TimeInterval(interval * 60 * 60)
//
//            let count = 24 / interval
//
//            let startTime = EXSDateTools.dateFor(hour: Int(capitalStartTime) ?? 0, minute: 0, second: 0)?.timeIntervalSince1970
//
//            if var sTime = startTime {
//
//                retArr.append(Date.init(timeIntervalSince1970: sTime))
//
//                for _ in 0...count {
//
//                    sTime += intervalDate
//                    retArr.append(Date.init(timeIntervalSince1970: sTime))
//                }
//            }
//
//        }
//
//        return retArr
//
//    }
    
     
    func currentAndNextRateTime() -> (String,String){
        let currentTime = EXSDateTools.getMillTimeInterval().0 + EXSwapPublicInfo.shared.localAndRemoteTimeInterval
        let nextTime = self.nextCapitalSettTime
        if nextTime - currentTime > 0 {
            let nextTimeDate = nextTime / 1000
            let nextTimeStr1 = EXSDateTools.dateToString(nextTimeDate,dateFormat: "HH:mm")
            var intervalStr = ""
            let interval = (nextTime - currentTime) / 1000
            if interval > 0 {
                intervalStr = EXSDateTools.stringWithInterval(interval)
                intervalStr = "(\(intervalStr))"
            }
            return (nextTimeStr1,intervalStr)
        }
        return ("00:00","(00:00:00)")
    }
    
    func depthPrecisions() -> [String] {
        
        return self.coinResultVo.depth.map({ (item) -> String in
            
            return "1".mapPrecision(item)
        })
    }
}
public extension EXContractsModel {
    
    func intervalForNextRateTime() -> TimeInterval? {
        
        if let nextRateTime = nextRateTime()?.timeIntervalSince1970 {
        
            return nextRateTime - Date().timeIntervalSince1970
        }
        return nil
    }
    
    func currentCountdownValue() -> String {
        
        
        
        if let interval = self.intervalForNextRateTime() {
            
            return DateTools.stringWithInterval(interval)
        }
        return ""
    }

    func nextRateTime() -> Date? {
        
//        if nextCapitalSettTime > 0 {
//            let currentTimeInterval = Date().timeIntervalSince1970.addingTimeInterval(self.nextCapitalSettTime/1000)
//            return currentTimeInterval
//        }
        
//        if pointTimeArr.count > 0 {
//
//            let currentTimeInterval = Date().timeIntervalSince1970 + TimeInterval( EXSwapPublicInfo.shared.localAndRemoteTimeInterval)
//
//            for time in pointTimeArr {
//
//                if currentTimeInterval < time.timeIntervalSince1970 {
//                    return time
//                }
//            }
//        }
        return nil
    }
}
class EXCoinResultVoModel:EXCOBaseModel {
    var minOrderVolume = ""//最小下单量 English: Minimum order quantity
    var minOrderMoney = ""//最小下单金额 English: Minimum order amount
    var maxMarketVolume = ""//市价单最大下单数量 English: Maximum order quantity for market price orders
    var maxMarketMoney = ""//市价最大下单金额 English: Maximum order amount at market price
    var maxLimitVolume = ""//限价单最大下单数量(张) English: Maximum order quantity for price limit orders (pieces)
    var maxLimitMoney = ""//限价单最大下单金额 English: Maximum order amount for price limit orders
    var priceRange = ""//下单价格最大偏离比例（不带百分号） English: Maximum deviation ratio of ordering price (without percentage sign)
    var symbolPricePrecision = ""//合约币对价格精度 English: Contract currency to price accuracy
    var marginCoinPrecision = ""//保证金币种显示精度 English: Ensure the display accuracy of gold coins
    var depth = [String]()//深度数组 English: Deep array
    /*
     本期改版只要3个字端 English: This revision only requires 3 characters
     //最小下单量 English: Minimum order quantity
     //市价单最大下单数量 English: Maximum order quantity for market price orders
     //限价单最大下单数量(张) English: Maximum order quantity for price limit orders (pieces)
     */
}

