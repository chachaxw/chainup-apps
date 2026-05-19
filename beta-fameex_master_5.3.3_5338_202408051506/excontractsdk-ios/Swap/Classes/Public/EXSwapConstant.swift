//
//  EXSwapConstant.swift
//  Chainup
//
//  Created by cwd on 2023/3/23.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import EXKit
import RxSwift

enum EXSwapTrackingEventOrderType: String {
    case limit_order // 限价单 English: Price limit order
    case market_order // 市价单 English: Market price list
}


enum EXSwapTrackingEvent: String {
  
    case app_futures_kline_page // k线页面 English: K-line page
    case app_futures_main_page // 合约主页 English: Contract homepage
    case app_futures_search_click // 合约搜索 English: Contract search
    case app_futures_switch_order // 切换到限价单:limit_order 切换市价单:market_order English: Switch to price limit order: limit_ Order Switching Market Price List: Market_ Order
    
    case app_futures_limit_order_price_input // 限价单: 输入 English: Limit Order: Enter
    case app_futures_limit_order_price_click // 限价单: 点击盘口价格 English: Price limit order: click on the opening price
    case app_futures_limit_order_quantity_input // 限价单滑杆 English: Limit order slider
    case app_futures_limit_order_quantity_slider // 限价单滑杆 English: Limit order slider
    case app_futures_limit_order_place_order //限价单(开多: open_long, 开空: open_short 平多:close_long 平少:close_short) English: Price limit order (open long: open_long, open short: open_short)
    
    case app_futures_place_order_success // limit_order market_order
    case app_futures_place_order_fail // limit_order market_order
    
    case app_futures_market_order_quantity_input // 市价单输入 English: Market price order input
    case app_futures_market_order_quantity_slider // 市价单滑杆 English: Market price single sliding rod
    case app_futures_market_order_place_order // 市价单(开多: open_long, 开空: open_short 平多:close_long 平少:close_short) English: Market price list (open long: open-long, open short: open_short)
    
    case app_futures_positions_close_all // 一键平仓 English: One click closing position
    case app_futures_positions_light_close // 闪电平仓 English: Lightning liquidation
    case app_futures_positions_close // 平仓按钮 English: Closing button
    case app_futures_positions_tpsl // 按钮 English: button
    
    case app_futures_orders_cancel_all // 全部撤单 English: Cancel All Orders
    case app_futures_orders_cancel // 撤单 English: kill an order
}

enum EXNeWTrackingPage:String {
    case home = "HomePage"
    case market = "MarketPage"
    case fiat = "FiatPage"
    case contract = "ContractPage"
    case assets = "AssetsPage"
    case leverage = "LeveragePage"
    case transaction = "SpotTransactionPage"
    case swapfirst = "合约_首页"
    case swaplossrecord = "合约_盈亏记录"
    case swapfundtransfer = "合约_资金划转"
    case swapCapitalFlow = "合约_资金流水"
    case swapcontractinformation = "合约_合约信息"
    case swaptransactionsettings = "合约_交易设置"
    case swapallcommissioned = "合约_全部委托"
    case swapcurrentcommission = "合约_当前委托"
    case swaphistoricalcommission = "合约_历史委托"
    case swapcommissiondetails = "合约_委托详情"
    case smallkline = "小k线点击"
    case stopPLInfo = "持仓_止盈止损注释"
    case onekeyClose = "持仓_一键全平"
    case showAll = "持仓_显示全部"
    case lightClose = "合约_闪电平仓"
    
}

enum EXNewTrackingEvent:String {
    case trackOrderCreate = "OrderCreate"
    case trackOrderCancel = "OrderCancel"
    case trackLeverCreate = "LeverCreate"
    case trackLeverCancel = "LeverCancel"
    case httpTrack = "httpTrack"
    case httpTrackLow = "httpTrackLow"
    case httpError = "httpError"
    case wsTrack = "wsTrack"
    case wsTrackLow = "wsTrackLow"
    case wsTrackError = "wsTrackError"
    case swapOpenPosition = "合约_下单区_开仓"
    case swapordersplaced10 = "合约_下单百分比_250%"
    case swapordersplaced20 = "合约_下单百分比_50%"
    case swapordersplaced50 = "合约_下单百分比_75%"
    case swapordersplaced100 = "合约_下单百分比_100%"
    case swapClosePosition = "合约_下单区_平仓"
    case swapCloseOpponent1 = "合约_下单区_对手1档"
    case swapCloseOpponent5 = "合约_下单区_对手5档"
    case swapCloseOpponent10 = "合约_下单区_对手10档"
    case swapOrderAreaTransfer = "合约_下单区_划转"
    case swapPositionClose  = "合约_持仓_平仓"
    case swapPositionMarketPrice  = "合约_持仓_市价"
    case swapbestcounterparty = "合约_持仓_对手方最优"
    case swapOwnBest = "合约_持仓_本方最优"
    case swapOwnShare = "合约_持仓_分享"
    case swapYingKui = "合约_盈亏分析"
    case swapOpenOrderCoin = "合约_下单_限价_币"
    case swapOpenOrderSheet = "合约_下单_限价_张"
    case swapOpenOrderValue = "合约_下单_限价_价值"
}


class EXNewTracking: NSObject {

    static let `manager` = EXNewTracking()
    let disposeBag = DisposeBag()
    open class var shared: EXNewTracking {
        return manager
    }
    //注意事项： English: Notes:
    //trackPageBegin 和trackPageEnd必须成对调用。 English: TrackPageBegin and trackPageEnd must be called in pairs.
    func trackPage(name:EXNeWTrackingPage,isEnter:Bool) {
        if isEnter {
            EXTracking.shared.track(event: name.rawValue)
        }
    }
    func track(event:EXNewTrackingEvent,label:String = "",info:[String:Any]) {
        EXTracking.shared.track(event: event.rawValue,parameters: info)
    }
}


