//
//  SLContractDefine.swift
//  Chainup
//
//  Created by ZYJ on 2023/10/12.
//  Copyright © 2023 Chainup. All rights reserved.
//

import Darwin
extension String {
    
    public func ex_localized() -> String{
        return EXLanguageTools.getString(key: self)
    }
     func removeQ() -> String{
        let new = self.replacingOccurrences(of: "%@", with: " ")
        return new
    }
}
let limitedParmDesc = "1"
let marketParmDesc = "2"
let IOKParmDesc = "3"
let FOKParmDesc = "4"
let postOnlyParmDesc = "5"
let forceReducePositionParmDesc = "6"
let mergeParmDesc = "7"
let systemCloseout = "9"
let systemDelivery = "10"
let adl = "11"
public let EXContract_lineChange_Notification = "EXContract_lineChange_Notification";
public let EXContract_wslineChange_Notification = "EXContract_wslineChange_Notification";
public let EXContractLoadFuturesData_Notification = "EXContractLoadFuturesData_Notification";
public let EXContractAreaLimitNotification = "EXContract_arealimit_Notification"
public let EXContractKycLimitNotification = "EXContract_Kyclimit_Notification"

public enum EXSwapMarketOrderType:Equatable {
    
    case limited
    case market
    case planOrder(isMarket:Bool = false)
    case postOnly
    case immediateOrCance
    case fillOrKill
    case allTypes
    case forceReducePosition //历史委托类型使用-强制减仓 6 English: Historical commission type usage - forced reduction of position 6
    case positionMerge // 历史委托类型使用-仓位合并 7 English: Historical Entrustment Type Usage - Bin Merge 7
    case SystemCloseout //历史委托 -系统平仓 9 English: Historical Entrustment - System Closing 9
    case SystemDelivery //历史委托 -系统交割 10 English: Historical Commissions - System Delivery 10
    case ADL //历史委托 -自动减仓10 English: Historical entrustment - automatic position reduction 10
    /*
     when (item.source) {
         "6" -> CpLanguageUtil.getString(context,"cp_extra_text6")//强制减仓 English: Compulsory reduction of positions
         "7" -> CpLanguageUtil.getString(context,"cp_extra_text7")//仓位合并 English: Position consolidation
         "9" -> CpLanguageUtil.getString(context,"cp_other_text2")//系统平仓 English: System liquidation
         "10" -> CpLanguageUtil.getString(context,"cp_other_text3")//系统交割 English: System delivery
         else -> "error"
     }
     
     */
   
    static var parmDescDic:[String:EXSwapMarketOrderType] {
        get {
            return [limitedParmDesc:EXSwapMarketOrderType.limited,
                    marketParmDesc:EXSwapMarketOrderType.market,
                    IOKParmDesc:EXSwapMarketOrderType.immediateOrCance,
                    FOKParmDesc:EXSwapMarketOrderType.fillOrKill,
                    postOnlyParmDesc:EXSwapMarketOrderType.postOnly,
                    forceReducePositionParmDesc:EXSwapMarketOrderType.forceReducePosition,
                    mergeParmDesc:EXSwapMarketOrderType.positionMerge,
                    systemCloseout: EXSwapMarketOrderType.SystemCloseout,
                    systemDelivery: EXSwapMarketOrderType.SystemDelivery,
                                adl:EXSwapMarketOrderType.ADL
            ]
        }
    }
    
    var parmDesc:String {
        get {
            switch self {
            case .limited:
                return limitedParmDesc
            case .market:
                return marketParmDesc
            case .planOrder(let isMarket):
                return isMarket ? "2" : "1"
            case .postOnly:
                return postOnlyParmDesc
            case .fillOrKill:
                return FOKParmDesc
            case .immediateOrCance:
                return IOKParmDesc
            case .forceReducePosition:
                return forceReducePositionParmDesc
            case .positionMerge:
                return mergeParmDesc
            case .SystemDelivery:
                return systemDelivery
            case .SystemCloseout:
                return systemCloseout
            case .ADL:
                return adl
            default:
                return ""
            }
        }
    }
    
    var display:String {
        get {
            switch self {
            case .limited:
                return "cp_overview_text3".ex_localized()
            case .market:
                return "cp_overview_text4".ex_localized()
            case .planOrder:
                return "cp_overview_text5".ex_localized()
            case .postOnly:
                return "cp_extra_text149".ex_localized()
            case .fillOrKill:
                return "cp_extra_text160".ex_localized()
            case .immediateOrCance:
                return "cp_extra_text161".ex_localized()
            case .allTypes:
                return "OpenOrder_text2".ex_localized()
            case .forceReducePosition:
                return "cp_extra_text6".ex_localized()
            case .positionMerge:
                return "cp_extra_text7".ex_localized()
            case .SystemDelivery:
                return "cl_other_text3".ex_localized()
            case .SystemCloseout:
                return "cl_other_text2".ex_localized()
            case .ADL:
                return "cp_order_adl1".ex_localized()
            default:
                return ""
            }
        }
    }
    //说明 English: explain
    var indicator:String {
        get {
            switch self {
            case .limited:
                return "cp_limit_order_tip_title".ex_localized()
            case .market:
                return "cp_market_order_tip_title".ex_localized()
            case .planOrder:
                return "cp_trigger_order_tip_title".ex_localized()
            case .postOnly:
                return "cp_post_only_tip_title".ex_localized()
            case .fillOrKill:
                return "cp_fok_tip_title".ex_localized()
            case .immediateOrCance:
                return "cp_ioc_tip_title".ex_localized()
            default:
                return ""
            }
        }
    }
    //具体的说明 English: Specific instructions
    var indicatorDetail:String {
        get {
            switch self {
            case .limited:
                return "cp_limit_order_tip".ex_localized()
            case .market:
                return "cp_market_order_tip".ex_localized()
            case .planOrder:
                return "cp_trigger_order_tip".ex_localized()
            case .postOnly:
                return "cp_post_only_tip".ex_localized()
            case .fillOrKill:
                return "cp_fok_tip".ex_localized()
            case .immediateOrCance:
                return "cp_ioc_tip".ex_localized()
            default:
                return ""
            }
        }
    }
    static func getOrderTypes() -> [EXSwapMarketOrderType]{
      return  [EXSwapMarketOrderType.limited,
                        EXSwapMarketOrderType.market,
                        EXSwapMarketOrderType.planOrder(),
                        EXSwapMarketOrderType.postOnly,
                        EXSwapMarketOrderType.immediateOrCance,
                        EXSwapMarketOrderType.fillOrKill]
    }
    static func creatBy(category:BTContractOrderCategory) -> EXSwapMarketOrderType? {
        switch category {
        case .normal:
            return .limited
        case .market:
            return .market
        case .plan:
            return .planOrder()
        case .planMarket:
            return .planOrder(isMarket: true)
        case .postOnly:
            return .postOnly
        case .FOK:
            return .fillOrKill
        case .IOC:
            return .immediateOrCance
        default:
            return nil
        }
    }
    
    func isHighOrderType() -> Bool {
        switch self {
        case .postOnly:
            return true
        case .fillOrKill:
            return true
        case .immediateOrCance:
            return true
        default:
            return false
        }
    }
    
    func isLimitPlan() -> Bool {
        switch self {
        case .planOrder(let isMarket):
            return !isMarket
        default:
            return false
        }
    }
    
    func isMarketOrderType() -> Bool {
        switch self {
        case .market:
            return true
        case .planOrder(let isMarket):
            return isMarket
        default:
            return false
        }
    }
}

enum EXSwapMarketOrderPriceType {
    case limitPrice
    case marketPrice
    case oppositeSideOptimal //对方最优 English: The other party is the best
    case sameSideOptimal //本方最优 English: Our best
    var parmStr:String {
        switch self {
        case .oppositeSideOptimal:
            return "0"
        case .sameSideOptimal:
            return "1"
        default:
            return ""
        }
    }
    var introduce:String {
        switch self {
        case .oppositeSideOptimal:
            return "cp_order_text45".ex_localized()
        case .sameSideOptimal:
            return "cp_order_text44".ex_localized()
        default:
            return ""
        }
    }
}

enum EXSwapPlanOrderPriceType {
    case limitPlan
    case marketPlan
}
/*
 1 用户取消, English: 1. User cancels,
 2 超过有效期 English: 2. Exceeding the validity period
 3 触发成功, 执行时余额不足 English: 3 triggered successfully, insufficient balance during execution
 4 触发成功, 执行平仓时可平仓位小于执行数量 English: 4 triggered successfully. When closing positions, the number of positions that can be closed is less than the number of executed positions
 5 仓位正在执行强平或破产逻辑 English: 5 positions are undergoing strong liquidation or bankruptcy logic
 6 合约暂停交易 English: 6. Contract suspension of trading
 */
enum EXSwapPlanOrderStatusMemo:Int {
    case one = 1
    case two
    case three
    case four
    case five
    case six
    
    var introduce:String {
        switch self {
        case .one:
            return "cp_extra_text21".ex_localized()
        case .two :
            return "cp_extra_text22".ex_localized()
        case .three:
            return "cp_extra_text23".ex_localized()
        case .four:
            return "cp_extra_text24".ex_localized()
        case .five:
            return "cp_extra_text25".ex_localized()
        case .six:
            return "cp_extra_text26".ex_localized()
        }
    }
}
/*1 用户主动撤销, English: 1. The user voluntarily withdraws,
 2 异常订单, 被系统撤销, English: 2 abnormal orders, cancelled by the system,
 3 仓位发生强平, 未成交委托被系统撤销, English: 3 positions have experienced strong consolidation, and orders that were not executed have been revoked by the system,
 4 市价单对手盘不足, English: 4. The market price is insufficient for the opponent's market,
 5 FOK订单无法完全成交时被系统撤销, English: When a 5 FOK order cannot be fully executed, it is revoked by the system,
 6 IOC订单无法立即成交时部分委托被系统撤销, English: When the IOC order cannot be executed immediately, some orders are revoked by the system,
 7 被动委托, 撮合时为taker部分被系统撤销 English: 7. Passive delegation, during matchmaking, part of the taker was revoked by the system
 */
enum EXSwapOrderStatusMemo:Int {
    case one = 1
    case two
    case three
    case four
    case five
    case six
    case seven
    case eleven = 11
    case twelve = 12
    var introduce:String {
        switch self {
        case .one:
            return "cp_extra_text17".ex_localized()
        case .two :
            return "cp_extra_text73".ex_localized()
        case .three:
            return "cp_extra_text74".ex_localized()
        case .four:
            return "cp_extra_text75".ex_localized()
        case .five:
            return "cp_extra_text76".ex_localized()
        case .six:
            return "cp_extra_text77".ex_localized()
        case .seven:
            return "cp_extra_text78".ex_localized()
        case .eleven:
            return "cl_other_text1".ex_localized()
        case .twelve:
            return "cp_order_adl3".ex_localized()
        }
    }
}

enum EXSwapPlanOrderStatus:Int {
   // 0有效，1，2，3 English: 0 valid, 1, 2, 3
    case available = 0
    case timeOut
    case finish
    case failure
    case cancel
    var introduced: String {
        switch self {
        case .available:
            return "cp_extra_text162".ex_localized()
        case .timeOut:
            return "cp_order_text95".ex_localized()
        case .finish:
            return "cp_tip_text11".ex_localized()
        case .failure:
            return "cp_tip_text12".ex_localized()
        case .cancel:
            return "cp_status_text2".ex_localized()
        }
    }
}

enum EXSwapOrderStatus:Int {
    case unknow = 0
    case newOrder = 1
    case allCompleted = 2
    case portionCompleted
    case cancel //已撤销 English: rescinded
    case waitingCancel
    case error //异常 English: abnormal
    
    var introduced:String {
        get {
            switch self {
            case .unknow:
                return "cp_extra_text70".ex_localized()
            case .newOrder:
                return "cp_extra_text163".ex_localized()
            case .allCompleted:
                return "cp_status_text1".ex_localized()
            case .portionCompleted:
                return "cp_extra_text164".ex_localized()
            case .cancel:
                return "cp_status_text2".ex_localized()
            case .waitingCancel:
                return "cp_status_text4".ex_localized()
            case .error:
                return "cp_status_text3".ex_localized()
            }
        }
    }
}

enum EXSwapPlanOrderValidityPeriod:Int {
    case oneDay = 0
    case oneWeek
    case twoWeek
    case oneMonth 
    
    var introduced: String {
        get {
            switch self {
            case .oneDay:
                return "cp_extra_text88".ex_localized()
            case .oneWeek:
                return "cp_extra_text139".ex_localized()
            case .twoWeek:
                return "cp_extra_text140".ex_localized()
            case .oneMonth:
                return "cp_extra_text141".ex_localized()
            }
        }
    }
    static func initWithParm(parm:String) -> Self {
        if parm == "1" {
            return .oneDay
        }
        if parm == "7" {
            return .oneWeek
        }
        if parm == "14" {
            return .twoWeek
        }
        if parm == "30" {
            return .oneMonth
        }
        return .oneDay
    }
    func parm() -> String {
        switch self {
        case .oneDay:
            return "1"
        case .oneWeek:
            return "7"
        case .twoWeek:
            return "14"
        case .oneMonth:
            return "30"
        }
    }
   
}

public enum EXSwapTransactionRecordType:String {
    case all = ""
    case transferIn = "1"
    case transferOut = "2"
    case settlementLong = "3"
    case settlementShort = "4"
    case capitalCost = "5"
    case openRate = "6"
    case closeRate = "7"
    case apportioned = "8" // 分摊 English: share
    case dividedRate = "9"
    case couponIn = "10"
    case couponOut = "11"
    case closePnl = "13"

    public var introduce:String {
        get {
            switch self {
            case .all:
                return "cp_order_text4".ex_localized()
            case .transferIn:
                return "cp_extra_text13".ex_localized()
            case .transferOut:
                return "cp_extra_text14".ex_localized()
            case .settlementLong:
                return "cp_extra_text146".ex_localized()
            case .settlementShort:
                return "cp_extra_text147".ex_localized()
            case .capitalCost:
                return "cp_position_text3".ex_localized()
            case .openRate:
                return "cp_extra_text18".ex_localized()
            case .closeRate:
                return "cp_extra_text19".ex_localized()
            case .apportioned:
                return "cp_position_text5".ex_localized()
            case .dividedRate:
                return "cp_fee_share".ex_localized()
            case .couponIn:
                return "cp_extra_text15".ex_localized()
            case .couponOut:
                return "cp_extra_text16".ex_localized()
            case .closePnl:
                return "cp_close_pnl".ex_localized()

            }
        }
    }
}

enum EXSwapDeliveryKind:String {
    
    case Perpetual = "0"
    case Weekly = "1"
    case Bi_Weekly = "2"
    case Monthly = "3"
    case Quarterly = "4"
    
    var introduce:String {
        get {
            switch self {
            case .Perpetual:
                return "cp_extra_text121".ex_localized()
                    
            case .Weekly:
                return "cp_extra_text122".ex_localized()
            case .Bi_Weekly:
                return "cp_extra_text123".ex_localized()
            case .Monthly:
                return "cp_extra_text124".ex_localized()
            case .Quarterly:
                return "cp_extra_text125".ex_localized()
            }
            
        }
    }
}

enum EXOpponentPriceType:Int {
    case none = -1
    case one = 0
    case two = 4
    case three = 9
    var introduce:String {
        get {
            switch self {
            case .none:
                return "cp_overview_text7".ex_localized()
            case .one:
                return "cp_overview_text38".ex_localized()
            case .two:
                return "cp_overview_text39".ex_localized()
            case .three:
                return "cp_overview_text40".ex_localized()
            }
        }
    }

}

