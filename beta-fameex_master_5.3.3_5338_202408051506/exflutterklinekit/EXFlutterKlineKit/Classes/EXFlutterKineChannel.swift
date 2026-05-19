//
//  EXCommonAlert.swift
//  EXKit
//
//  Created by cwd on 2022/7/7.
//

import UIKit
import Flutter

/// flutter回调给原生方法枚举
public enum EXKlineCallbackMethod: String {
    case reload_kline
    case more_history_kline
    case close_kline_vpage
    case kline_coin_sidebar
    case close_kline_hpage
    case kline_coin_share
    case kline_coin_collect
    case kline_switch_time_index
    case kline_enlarge
    case kline_coin_info
    case kline_order_book
    case kline_transaction_record
    case kline_coin_intro
    
    case kline_etf_coin_intro
    case kline_etf_position_record
    case kline_go_webview
    case kline_trading_sell
    case kline_trading_buy
    case kline_detail_clickMainIndex
    case flutter_canPop
    case show_native_toast
    case kline_guide_flag
}



/// 原生 to flutte方法枚举
public enum EXInvokeFlutterMethod: String {
    case setKlineBgColor = "setKlineBgColor"
    case setKlineTimeIndexList = "setKlineTimeIndexList"
    case setKlineVolState = "setKlineVolState"
    case setHistoryKlineData = "setHistoryKlineData"
    case setNewKlineData = "setNewKlineData"
    case set24HTickerData = "set24HTickerData"
    case setDepthMapData = "setDepthMapData"
    case setOrderBookData = "setOrderBookData"
    case setTransactionRecordData = "setTransactionRecordData"
    case setCoinIntroData = "setCoinIntroData"
    case setCoinETFData = "setCoinETFData"
    case setCoinETFRuleData = "setCoinETFRuleData"
    case setCoinInfo = "setCoinInfo"
    case rounter = "router"
    case updatePriceInfo = "updatePriceInfo"
    case setKlineBuySellData = "setKlineBuySellData"
    case nativeClickKTimeChange = "nativeClickKTimeChange"
    case updateMainIndexVisible = "updateMainIndexVisible"
    case updateConfig = "updateConfig"
    case updateWaterLogoPath = "updateWaterLogoPath"
}




public enum KLineCallMethod: String {
    case more_history_kline
    case kline_scroll
    case reload_kline
}


public class EXFlutterKineChannel {
    /// iOS --> flutter
    /// - Parameter messenger: messenger
    /// - Returns: FlutterMethodChannel
    public static func createInvokeChannel(messenger: FlutterBinaryMessenger) -> FlutterMethodChannel {
        let channel = FlutterMethodChannel(name: "ex.chainup.app/NV", binaryMessenger: messenger)
        return channel
    }
    /// flutter --> iOS
    /// - Parameter messenger: messenger
    /// - Returns: FlutterMethodChannel
    public static func createCallbackChannel(messenger: FlutterBinaryMessenger) -> FlutterMethodChannel {
        let channel = FlutterMethodChannel(name: "ex.chainup.app", binaryMessenger: messenger)
        return channel
    }
}



