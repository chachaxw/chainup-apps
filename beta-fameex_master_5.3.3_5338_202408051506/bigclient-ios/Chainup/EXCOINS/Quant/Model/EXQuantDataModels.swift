//
//  EXQuantDataModels.swift
//  Chainup
//
//  Created by wangdong on 2023/2/1.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit

//Policy status 0: Starting 1: In progress 2: Stopping 3: Ended
enum StrategyStatus :String {
    case Launching = "0"
    case InProgress = "1"
    case Stopping = "2"
    case Closed = "3"
}

enum StrategyError :String {
    case UserStop = "1"
    case StopLossStop = "2"
    case ProfitStop = "3"
    case SystemStop = "4"
    case LowBalanceStop = "5"
    case AbnormalStop = "6"
    case LowPriceStop = "7"//Insufficient grid amount for minimum order quantity
    case GridIntervalError = "8"//Grid interval error
}

class EXQuantAIStrategyInfoDataModel: EXBaseModel {
    var configParamMap: EXQuantStrategyConfigParamDataModel?
    var symbol = ""//Currency pair
    var quantType = ""//Quantitative transaction type 1: Grid
    var strategyStatus = ""//Grid status 0: Starting 1: Executing 2: Stopping 3: Closed
    var startTime = ""//Policy start timestamp
    var endTime = ""//Policy end timestamp
    var makerFee = ""//Currency to currency handling fee
    var sevenAnnualizedYield = ""//
    var everyProfitMax = ""//Maximum profit margin
    var everyProfitMin = ""//Minimum profit margin
    var ctime = ""
    var minimumOrderQuantity:String = ""//Minimum order amount
    var limitTotalMin:String = ""//Minimum grid investment amount
    var everyGridLimitMin:String = ""//Minimum order amount per cell

    override func mj_keyValuesDidFinishConvertingToObject() {
        
    }
}

class EXCalBaseModel:EXBaseModel {
    var baseAmount:String = ""
}

class EXOrderingGridListModel:EXBaseModel {
    var SELL:[Any] = []
    var BUY:[Any] = []
    
    override func mj_keyValuesDidFinishConvertingToObject() {

    }
}

class EXFinishedGridList:EXBaseModel {
    var count:String = ""
    var page:String = ""
    var list:[EXOrderedGridListItem] = []
    override func mj_keyValuesDidFinishConvertingToObject() {
        self.list = EXOrderedGridListItem.mj_objectArray(withKeyValuesArray: self.list).copy() as! [EXOrderedGridListItem]
    }
}

class EXOrderedGridListItem:EXBaseModel {
    var buyTime:String = ""//time
    var profit:String = ""//profit
    var symbol:String = "" //Currency pair
    var strategyStatus:String = ""//Policy status 0: Starting 1: In progress 2: Stopping 3: Ended
    var buyOrder:EXOrderedItem = EXOrderedItem()
    var sellOrder:EXOrderedItem = EXOrderedItem()
    var isExpand:Bool = false //Expand or not
    
    
    func isWaitingBuy() ->Bool {
        if strategyStatus == StrategyStatus.Launching.rawValue ||
            strategyStatus == StrategyStatus.InProgress.rawValue ||
            strategyStatus == StrategyStatus.Closed.rawValue {
            if buyOrder.orderId.count == 0 {
                return true
            }else {
                return false
            }
        }else {
            return false
        }
    }
    
    func isWaitingSell() ->Bool {
        if strategyStatus == StrategyStatus.Launching.rawValue ||
            strategyStatus == StrategyStatus.InProgress.rawValue {
            if sellOrder.orderId.count == 0 {
                return true
            }else {
                return false
            }
        }else {
            return false
        }
    }
    
    func isNotSold() ->Bool {
        if strategyStatus == StrategyStatus.Closed.rawValue ||
            strategyStatus == StrategyStatus.Stopping.rawValue{
            if sellOrder.orderId.count == 0 {
                return true
            }else {
                return false
            }
        }else {
            return false
        }
    }
}

class EXOrderedItem:EXBaseModel {
    var orderId:String = ""//Order ID
    var orderSide:String = "" //Order direction, BUY/SELL
    var orderCtime:String = ""//Order creation timestamp
    var avgPrice:String = "" //Average transaction price
    var dealVolume:String = "" //Transaction quantity
    var dealMoney:String = "" //Transaction amount
    
    func isEmptyItem() ->Bool {
        return orderId.isEmpty
    }
}


class EXQuantStrategyList:EXBaseModel {
    var count:String = ""
    var page:String = ""
    var pageSize:String = ""
    var strategyVoList:[EXQuantStrategyListItem] = []
    override func mj_keyValuesDidFinishConvertingToObject() {
        self.strategyVoList = EXQuantStrategyListItem.mj_objectArray(withKeyValuesArray: self.strategyVoList).copy() as! [EXQuantStrategyListItem]
    }
}

class EXQuantStrategyListItem:EXBaseModel {
    var id :String = ""
    var uid :String = ""
    var symbol :String = ""
    var quantType :String = ""
    var strategyStatus :String = ""
    var shutdownMeta :String = ""
    var ctime:String = ""
    var startTime :String = ""
    var endTime :String = ""
    var makerFee :String = ""//Custom handling fee
    var sevenAnnualizedYield :String = ""
    var everyProfit :String = ""
    var totalProfit :String = ""
    var totalProfitRate :String = ""
    var annualizedYield :String = ""
    var positionProfit :String = ""
    var finishCount :String = ""
    var orderingCount :String = ""
    var configParamMap :EXQuantStrategyConfigParamDataModel?
    var freezQuoteAmount:String = ""//Grid Freeze
    var freezBaseAmount:String = ""//Grid Freeze
    var totalProfitTimes:String = ""//Total arbitrage
    var yesterdayProfitTimes:String = ""//24-hour arbitrage
    
    func fmtValue(_ value:String) ->String {
        if value.isBiggerThan("0") {
            return "+" + value
        }else {
            return value
        }
    }
    
    func isStatusPending() -> Bool {
        return self.strategyStatus == StrategyStatus.Launching.rawValue ||  self.strategyStatus == StrategyStatus.InProgress.rawValue
    }
    
    
    func getStatus() -> String {
        if self.strategyStatus == StrategyStatus.Launching.rawValue {
            return "quant_grid_order_status_start_ing".localized()
        }else if strategyStatus == StrategyStatus.InProgress.rawValue {
            return "quant_grid_order_status_cmd_ing".localized()
        }else if strategyStatus == StrategyStatus.Stopping.rawValue  {
            return "quant_grid_order_status_stop_ing".localized()
        }else if strategyStatus == StrategyStatus.Closed.rawValue  {
            if shutdownMeta == StrategyError.UserStop.rawValue {
                return "quant_grid_order_status_stop_user".localized()
            }else if shutdownMeta == StrategyError.StopLossStop.rawValue {
                return "quant_grid_order_status_stop_loss".localized()
            }else if shutdownMeta == StrategyError.ProfitStop.rawValue {
                return "quant_grid_order_status_stop_profit".localized()
            }else if shutdownMeta == StrategyError.SystemStop.rawValue {
                return "quant_grid_order_status_stop_sys".localized()
            }else if shutdownMeta == StrategyError.LowBalanceStop.rawValue {
                return "quant_grid_order_status_stop_user_balance".localized()
            }else if shutdownMeta == StrategyError.AbnormalStop.rawValue {
                return "quant_grid_order_status_stop_sys_fix".localized()
            }else if shutdownMeta == StrategyError.LowPriceStop.rawValue {
                return "quant_grid_order_status_stop_grid_balance".localized()
            }else if shutdownMeta == StrategyError.GridIntervalError.rawValue {
                return "quant_grid_order_status_stop_grid_interval".localized()
            }else {
                return "quant_grid_order_status_stop".localized()
            }
        }
        return ""
    }
}

class EXQuantStrategyListDataModel: EXBaseModel {
    var data:[EXQuantStrategyItemDataModel] = []
    override func mj_keyValuesDidFinishConvertingToObject() {
        self.data = EXQuantStrategyItemDataModel.mj_objectArray(withKeyValuesArray: self.data).copy() as! [EXQuantStrategyItemDataModel]
    }
}

class EXQuantStrategyItemDataModel: EXQuantAIStrategyInfoDataModel {
    var totalProfit = ""//Total Grid Profit
    var totalProfitRate = ""//profit rate
    var annualizedYield = ""//Annualized rate of return
    var positionProfit = ""//Position gains and losses
    var finishCount = ""//Total number of executed items
    var orderingCount = ""//Total number of executing items
}

class EXQuantStrategyConfigParamDataModel:EXBaseModel {
    var gridNumber = ""//Number of grids
    var highestPrice = ""//Grid upper limit
    var lowestPrice = ""//Grid Lower Limit
    var stopHighPrice = ""//Stop Grid Upper Limit
    var stopLowPrice = ""//Stop Grid Lower Limit
    var totalQuoteAmount = ""//Total quote assets invested by users
    var totalBaseAmount = ""//Total base assets invested by users
    var gridLineType = ""//Grid type 1: Equal difference 2: Equal ratio
    var useOwnBase = ""//Whether to use existing base assets
    var fee:String = ""//Handling fees for AI strategy, do not use anything else
}




class EXQuantSaveStrategyConfig:EXBaseModel {
    var symbol:String = "" //Currency pair
    var quantType:String = "1" //Quantitative transaction type, currently only 1=grid
    var gridLineType:String = ""//Grid type, 1 equal difference, 2 equal ratio
    var gridNumber:String = ""//Number of grids
    var lowestPrice:String = ""//Grid Lower Limit
    var highestPrice:String = ""//Grid upper limit
    var stopHighPrice:String = ""//Stop Grid Upper Limit
    var stopLowPrice:String = ""//Stop Grid Lower Limit
    var totalQuoteAmount:String = ""//User invested assets
    var useOwnBase:String = ""//Whether to use base
    var fee:String = ""//fee
    var everyProfitMin:String = ""//Minimum profit
    var everyProfitMax:String = ""//Maximum profit
    var minimumOrderQuantity:String = ""//Minimum order amount
    var limitTotalMin:String = ""//Minimum amount limit for grid investment
    var everyGridLimitMin:String = ""//Minimum order amount per cell

    func configWithAI(model:EXQuantAIStrategyInfoDataModel) {
        self.symbol = model.symbol
        if let configMap = model.configParamMap {
            self.gridLineType = configMap.gridLineType
            self.lowestPrice = configMap.lowestPrice
            self.highestPrice = configMap.highestPrice
            self.gridNumber = configMap.gridNumber
//            self.stopLowPrice = configMap.stopLowPrice
//            self.stopHighPrice = configMap.stopHighPrice
            self.useOwnBase = configMap.useOwnBase
            self.everyProfitMin = model.everyProfitMin
            self.everyProfitMax = model.everyProfitMax
            self.minimumOrderQuantity = model.minimumOrderQuantity
            self.limitTotalMin = model.limitTotalMin
            self.everyGridLimitMin = model.everyGridLimitMin
            self.fee = model.makerFee
        }
    }
     
    func configWithCustom(model:EXQuantAIStrategyInfoDataModel) {
        self.symbol = model.symbol
        self.fee = model.makerFee
//        self.everyProfitMin = model.everyProfitMin
//        self.everyProfitMax = model.everyProfitMax
        self.minimumOrderQuantity = model.minimumOrderQuantity
        self.limitTotalMin = model.limitTotalMin
        self.everyGridLimitMin = model.everyGridLimitMin
        self.useOwnBase = "0"
        self.gridLineType = "1"
    }
    
    func isCustomHasEmpty() -> Bool {
        if self.lowestPrice.isEmpty ||
            self.highestPrice.isEmpty ||
            self.gridNumber.isEmpty ||
            self.totalQuoteAmount.isEmpty {
            return true
        }
//        if self.stopLowPrice.count > 0 && self.stopHighPrice.isEmpty {
//            return true
//        }
//        if self.stopHighPrice.count > 0 && self.stopLowPrice.isEmpty {
//            return true
//        }
        
        return false
    }
    
    func isAiHasEmpty() -> Bool {
        if self.totalQuoteAmount.isEmpty {
            return true
        }
//        if self.stopLowPrice.count > 0 && self.stopHighPrice.isEmpty {
//            return true
//        }
//        if self.stopHighPrice.count > 0 && self.stopLowPrice.isEmpty {
//            return true
//        }
        return false
    }
    
    func clearAIConfig() {
        self.totalQuoteAmount = ""
        self.stopLowPrice = ""
        self.stopHighPrice = ""
    }
    
    func clearCustomConfig() {
        self.totalQuoteAmount = ""
        self.stopLowPrice = ""
        self.stopHighPrice = ""
        self.lowestPrice = ""
        self.highestPrice = ""
        self.gridNumber = ""
    }
}

